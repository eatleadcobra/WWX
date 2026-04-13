# JTAC Module Specification

## 1. Overview

The JTAC (Joint Terminal Attack Controller) module provides automated close air support (CAS) terminal control for player aircraft in DCS World. A JTAC ground unit detects enemy vehicles within line-of-sight, prioritises them, and talks a player flight onto target using a standard 9-line CAS brief transmitted over radio. The JTAC lases the target for laser-guided weapons delivery.

All JTAC-to-player communication is via the DCS `TransmitMessage` radio command. Players must be tuned to the JTAC's frequency to receive messages.

### 1.1 Scope

- Blue coalition (coalition 2) only. The implementation must parameterise coalition so red-side JTACs can be added later without structural changes.
- One flight controlled per JTAC at a time. Additional flights are queued.
- The JTAC module depends on: `Utils` (coordinate/distance functions), `mist` (cloning/teleport), DCS Scripting Engine APIs.

### 1.2 Robustness & Performance

DCS aggressively garbage-collects units, groups, and objects. Any DCS object reference (Unit, Group, Spot) can become nil or invalid between frames. The JTAC module must be defensive throughout:

**Nil safety rules:**
- Every call to `Unit.getByName()`, `Group.getByName()`, `Unit:getGroup()`, `Unit:getPoint()`, `Unit:getLife()`, `Unit:getDesc()`, `Unit:getPlayerName()`, and `Unit:getAmmo()` must be nil-checked before use.
- Every access to `jtac.jtacs[name]` must verify the entry still exists (the JTAC may have been deregistered by another code path between timer callbacks).
- Every access to `session.controlledFlight` and queue entries must verify the group/unit still exists before operating on it.
- Laser spot references (`lasing[name].laser`) must be nil-checked before calling `:destroy()` or `:setPoint()`.
- Chain-access patterns like `group:getUnit(1):getPlayerName()` are forbidden — each step must be guarded independently.

**Guard style:** The WWX codebase uses nested `if` blocks rather than early returns. All nil checks must follow this pattern:

```lua
-- CORRECT (nested ifs):
function jtac.handleReadback(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local session = jtacData.session
            if session and session.state == "BRIEF_SENT" then
                -- ... do work ...
            end
        else
            JTAC.deRegisterJtac(jtacName)
        end
    end
end

-- WRONG (early returns):
function jtac.handleReadback(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if not jtacData then return end
    local jtacUnit = Unit.getByName(jtacName)
    if not jtacUnit then JTAC.deRegisterJtac(jtacName) return end
    ...
end
```

**Fail-safe behaviour:**
- If a nil is encountered in a flow function (handleCheckIn, handleReadback, etc.), the function must return early without crashing. If the nil indicates the JTAC or controlled flight is gone, it should trigger cleanup (deregister or dequeue) rather than silently returning.
- Timer callbacks (`trackLaser`, `retransmitCheck`, `noTargetScanCheck`, `retransmitQueueStatus`) must guard against the JTAC entry being nil at entry. A nil JTAC entry means the timer is stale — return immediately.

**Performance rules:**
- `world.searchObjects` (used in target detection) is expensive. Never call it more than once per engagement step. Cache the result for the duration of a single check-in or BDA cycle.
- `coalition.getGroups` (used in friendlies detection) iterates all groups. Cache the result for the duration of a single `build9Line` call. Do not call it in `trackLaser`.
- Timer intervals must not be reduced below their specified values. `trackingInterval` (10s) and `noTargetScanInterval` (30s) are the minimum acceptable polling rates.
- Avoid creating closures or tables inside `trackLaser` — it fires every 10 seconds per active JTAC. Reuse the param table passed by `scheduleFunction`.
- The `getUnitsInRadius` LOS check (`land.isVisible`) is called per-unit in the search volume. This is acceptable at 10km radius but must not be extended without profiling.
- Menu rebuilds (`updateMenusForState`) involve DCS API calls. Only rebuild when state actually changes, not on every timer tick.

---

## 2. JTAC Registration & Lifecycle

### 2.1 Registration

A JTAC is registered by unit name via `JTAC.registerJtac(name, coalitionId)`.

Registration creates an entry in the internal `jtac.jtacs` table:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `spawnTime` | number | `timer.getTime()` | Mission time when JTAC was spawned |
| `code` | number | `1688` | Laser designator code |
| `callsign` | string | *(generated, see §15)* | JTAC radio callsign |
| `frequency` | number | *(generated, see §16)* | Radio frequency in MHz |
| `modulation` | string | `"AM"` | Radio modulation type |
| `coalition` | number | `2` | Coalition ID |
| `stopLasing` | boolean | `false` | Flag to signal laser shutdown |
| `session` | table | *(see §3)* | Communication session state |

### 2.2 Spawning

`JTAC.spawnJtacAtPoint(point)` clones the template group `JTAC_TEMPLATE` to the given point using `mist.teleportToPoint`, then registers the first unit.

If `point` is nil, the template is cloned at its default position.

### 2.3 Deregistration

`JTAC.deRegisterJtac(name)` must:
1. Destroy any active laser for this JTAC (clean up `lasing` table entry).
2. Notify the controlled flight (if any) and all queued flights via coalition-wide broadcast: `"[callsign] is out of action!"`.
3. Reset session state and clear the flight queue.
4. Destroy the JTAC's DCS group.
5. Remove the entry from `jtac.jtacs`.

---

## 3. Session State Machine

Each registered JTAC has a `session` table tracking the current communication state with a player flight.

### 3.1 Session Data

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `state` | string | `"IDLE"` | Current state (see §3.2) |
| `controlledFlight` | string/nil | `nil` | Group name of the flight being controlled |
| `controlledFlightPlayerName` | string/nil | `nil` | Player name of the controlled flight (for addressed transmissions) |
| `flightQueue` | table | `{}` | Ordered list of `{groupName, playerName}` entries waiting for control |
| `queueStatusActive` | boolean | `false` | Whether the periodic queue retransmit timer is running |
| `currentTarget` | string/nil | `nil` | Unit name of the current/most recent lased target |
| `briefData` | table/nil | `nil` | The 9-line data table for the current engagement |
| `retransmitTimer` | number/nil | `nil` | Scheduled function ID for retransmit |
| `lastMessage` | string/nil | `nil` | Last transmitted message text (for retransmit) |
| `messageDuration` | number | `15` | Duration of last message (for retransmit timing) |
| `noTargetScanActive` | boolean | `false` | Whether the periodic no-target re-scan timer is running |

### 3.2 States

```
IDLE ──────────────┐
  ▲                ▼  Player selects "Check In"
  │          CHECKIN_RECEIVED
  │                │
  │                ▼  JTAC detects targets, builds 9-line, transmits brief
  │           BRIEF_SENT  ◄──────────────┐
  │                │                     │
  │                ▼  Player "Readback"  │
  │           CLEARED_HOT                │
  │                │                     │
  │      ┌─────────┼──────────┐          │
  │      ▼         ▼          ▼          │
  │   target    player     player        │
  │   dies     "Abort"   "New Target"    │
  │      │         │          │          │
  │      ▼         ▼          │          │
  │  JTAC auto  return to     │          │
  │  reports    IDLE          │          │
  │  BDA         │            │          │
  │      │       └──►dequeue  │          │
  │      ▼                    ▼          │
  │  more targets? ──yes──► detect next ─┘
  │      │
  │      no
  │      │
  │      ▼
  │  "No further targets. RTB."
  │      │
  └──────┘  (dequeue next flight)
```

### 3.3 State Transitions

| From | Trigger | To | Action |
|------|---------|----|--------|
| `IDLE` | Player "Check In" + targets exist | `BRIEF_SENT` | Detect targets, build 9-line, transmit brief. `CHECKIN_RECEIVED` is transient (does not persist). |
| `IDLE` | Player "Check In" + no targets | `IDLE` | Transmit "no targets, hold", start periodic re-scan. `controlledFlight` remains set so the JTAC knows who to brief when targets appear. Another player checking in while a flight is held will be queued (guard: `controlledFlight ~= nil`). |
| `BRIEF_SENT` | Player "Readback" | `CLEARED_HOT` | Transmit "Cleared Hot", start lasing |
| `CLEARED_HOT` | Target dies (detected by `trackLaser`) + more targets | `BRIEF_SENT` | JTAC transmits BDA, auto-detects next target, sends new 9-line |
| `CLEARED_HOT` | Target dies (detected by `trackLaser`) + no more targets | `IDLE` | JTAC transmits BDA + "no further targets, RTB", dequeue next flight |
| `CLEARED_HOT` | Player "New Target" | `BRIEF_SENT` | Stop lasing current target, detect next target, send new 9-line |
| `CLEARED_HOT` | Player "New Target" + no more targets | `IDLE` | Stop lasing, transmit "no further targets, RTB", dequeue |
| `CLEARED_HOT` | Player "Abort" | `IDLE` | Stop lasing, transmit abort ack, dequeue next flight |
| `BRIEF_SENT` | Player "Abort" | `IDLE` | Transmit abort ack, dequeue next flight |
| *any* | JTAC unit dies | `IDLE` | Coalition-wide broadcast, clean up all state |
| *any* | Controlled flight dies/disconnects | `IDLE` | Clean up, dequeue next flight |

---

## 4. Communication Protocol

### 4.1 Transmission Method

All JTAC messages use the DCS `TransmitMessage` command via the JTAC unit's group controller:

```lua
{
    id = 'TransmitMessage',
    params = {
        duration = <seconds>,
        subtitle = <message text>,
        loop = false,
        file = "l10n/DEFAULT/Alert.ogg",
    }
}
```

Players must be tuned to the JTAC's radio frequency and modulation to receive transmissions.

### 4.2 Retransmit Mechanism

When the JTAC transmits a message that expects a player response (i.e., during states `BRIEF_SENT` and `CLEARED_HOT`), a retransmit timer is scheduled.

**Behaviour:**
1. JTAC transmits message with duration `D` seconds.
2. A timer is scheduled for `D` seconds later.
3. When the timer fires:
   - If the session state has **not** changed (player didn't respond): retransmit the same message and schedule another timer.
   - If the session state **has** changed (player responded via menu): do nothing (no-op).
4. The JTAC retransmits indefinitely until the player responds, the JTAC dies, or the session is reset.

**Implementation:** The retransmit callback stores the `expectedState` at schedule time and compares against the current state when it fires. DCS `timer.scheduleFunction` cannot be cancelled, so stale timers are made harmless by the state guard.

### 4.3 Queue Status Transmission

Queued flights receive periodic position updates via `TransmitMessage`. Since TransmitMessage broadcasts to all listeners on the frequency, queued flights hear their position along with everyone else on that freq.

- **On queue entry:** Immediate transmission with queue position.
- **Periodic:** Retransmit queue status every `queueStatusDuration` (30 seconds). Timer self-cancels when queue empties.
- **On dequeue:** Immediate transmission to all remaining queued flights with updated positions.

### 4.4 No-Target Re-scan

When a player checks in but no targets are detected:
1. JTAC transmits "No targets at this time. Hold and standby."
2. A periodic re-scan timer starts (interval: `noTargetScanInterval`, default 30 seconds).
3. Each scan checks for targets within range and LOS.
4. When targets are found: JTAC transmits notification and auto-builds 9-line, transitioning to `BRIEF_SENT`.
5. The timer self-cancels when targets are found or the player disconnects/dies.

---

## 5. 9-Line CAS Brief

### 5.1 Data Fields

| Line | Field | Source | Description |
|------|-------|--------|-------------|
| 1 | IP/BP | `jtac.findNearestBP(jtacName)` | Nearest friendly BattlePosition zone name and bearing/distance from JTAC. Falls back to `"N/A"` if no BPs registered. See §5.3. |
| 2 | Heading | `Utils.GetBearingDeg(jtacPoint, targetPoint)` | Bearing from JTAC to target, 3-digit format |
| 3 | Distance | `Utils.PointDistance(jtacPoint, targetPoint)` | Distance in km, 1 decimal place |
| 4 | Elevation | `land.getHeight({x=tp.x, y=tp.z})` × 3.28084 | Target elevation in feet MSL (converted from meters) |
| 5 | Target Description | `target:getDesc().displayName` or `target:getTypeName()` | Human-readable target type |
| 6 | Target Coordinates | `coord.LLtoMGRS(coord.LOtoLL(targetPoint))` | MGRS grid reference |
| 7 | Mark Type | `"Laser " .. code` | Laser designation with code |
| 8 | Friendlies | `jtac.findNearestFriendlies(jtacName, targetPoint)` | Compass direction and distance of the nearest friendly ground unit(s) from the target. See §5.4. |
| 9 | Egress | `jtac.computeEgress(jtacPoint, targetPoint)` | Compass direction away from the target, back towards the JTAC (i.e., towards friendly lines). See §5.5. |
| — | Remarks | `""` | Optional remarks |

### 5.2 Transmission Format

```
[playerName], [callsign], 9-LINE follows:
1. IP/BP: [ip]
2. HDG: [heading]
3. DIST: [distance] km
4. ELEV: [elevation] ft MSL
5. TGT: [targetDesc]
6. COORDS: [targetCoords]
7. MARK: [markType]
8. FRDLY: [friendlies]
9. EGRESS: [egress]
REMARKS: [remarks]
READBACK
```

Duration: 30 seconds (longer than standard messages due to information density).

### 5.3 IP/BP Resolution

The IP/Battle Position field is populated by finding the nearest friendly `BattlePosition` to the JTAC unit.

**Algorithm:**
1. Iterate all registered BattlePositions where `ownedBy == jtac.coalition`.
2. Compute `Utils.PointDistance(jtacPoint, bp.point)` for each.
3. Select the closest BP.
4. Format as: `"BP [zoneName], [bearing]° [distance]km"` where bearing and distance are from the BP to the target.
5. If no friendly BPs exist, fall back to `"N/A"`.

**Dependency:** Requires the `BattlePosition` module to be loaded and BPs to be registered.

### 5.4 Friendlies Resolution

The friendlies field warns the pilot about nearby friendly ground forces relative to the target.

**Algorithm:**
1. Get all friendly ground groups: `coalition.getGroups(jtacCoalition, Group.Category.GROUND)`.
2. For each group, get the lead unit's position.
3. Compute distance from the target point to each friendly unit.
4. Select the nearest friendly unit within `distanceLimit` (10km).
5. Compute compass direction from the target to the nearest friendly: `Utils.degToCompass(Utils.GetBearingDeg(targetPoint, friendlyPoint))`.
6. Compute distance in km: `Utils.PointDistance(targetPoint, friendlyPoint) / 1000`.
7. Format as: `"[compass] [distance]km"` (e.g., `"South 1.2km"`).
8. If no friendly ground units within range, format as: `"None in area"`.

### 5.5 Egress Resolution

The egress direction tells the pilot which way to fly after weapons release to head back towards friendly lines.

**Algorithm:**
1. Compute the bearing from the target back towards the JTAC: `Utils.GetBearingDeg(targetPoint, jtacPoint)`.
2. The JTAC is assumed to be on the friendly side of the line — egressing towards the JTAC moves the pilot away from the enemy and towards friendlies.
3. Convert to compass cardinal: `Utils.degToCompass(bearing)`.
4. Format as: `"Egress [compass]"` (e.g., `"Egress SW"`).

---

## 6. Laser Designation

### 6.1 Laser Code

- Default code: `1688`, assigned at JTAC registration.
- Only the checked-in (controlled) flight may request a different code via the "Request Laser Code" submenu, available during `BRIEF_SENT` and `CLEARED_HOT` states. The JTAC updates `jtac.jtacs[name].code` and confirms the new code via transmission.
- Valid laser codes: 4-digit numbers where the first digit is 1 and remaining digits are 1-8 (DCS convention). Validation is not required for the initial implementation — the player selects from a preset list.

### 6.2 Laser Code Menu

Provide a submenu under the JTAC menu with common laser codes:
- `1688` (default)
- `1111`
- `1511`
- `1522`
- `1533`
- `1544`
- `1555`
- `1566`
- `1577`

When the player selects a code, the JTAC transmits: `"Copy, laser code [code]."` and updates the stored code. If a laser is currently active, it is destroyed and recreated with the new code so the change takes effect immediately.

### 6.3 Lasing Behaviour

- Laser is created via `Spot.createLaser(jtacUnit, offset, targetPoint, code)`.
- Laser offset from JTAC unit: `{x=0, y=1.8, z=0}` (head height).
- The `trackLaser` function updates the laser point every `trackingInterval` (10 seconds) to follow moving targets.
- LOS check: JTAC point (+ 1.8m height) to target point (+ 2.5m vehicle height) via `land.isVisible()`.

### 6.4 Target Death Detection

The `trackLaser` function detects target death when `Unit.getByName(targetName)` returns nil or target life <= 0. On detection:
1. Destroy the laser spot.
2. JTAC transmits BDA to player: `"Good hit on [targetDesc]. Target destroyed."`.
3. If more targets in range: auto-detect next priority target, build new 9-line, transition to `BRIEF_SENT`. The BDA and new 9-line are combined into a single transmission.
4. If no more targets: transmit `"No further targets. RTB."`, transition to `IDLE`, dequeue next flight.

---

## 7. Target Detection & Prioritisation

### 7.1 Detection

Search a sphere of radius `distanceLimit` (10,000m) around the JTAC for enemy ground vehicles:
- Volume search: `world.searchObjects(Object.Category.UNIT, sphere, callback)`
- Filter: opposite coalition, category 2 (ground), has attribute `"Ground vehicles"`
- LOS check: `land.isVisible(jtacPoint + height, targetPoint + vehicleHeight)`

### 7.2 Target Categories

Units are classified by DCS attributes:

| Category | Attribute |
|----------|-----------|
| SAM | `"SAM"` |
| AAA | `"AAA"` |
| Heavy Armor | `"HeavyArmoredUnits"` |
| Light Armor | `"LightArmoredUnits"` |
| Armed Vehicles | `"Armed vehicles"` |

A unit matches the **first** category in this list (no double-counting).

### 7.3 Priority Order

1. SAM
2. Heavy Armor
3. Light Armor
4. Armed Vehicles
5. AAA

The JTAC always engages the highest-priority visible target. Within a category, order is arbitrary (first found).

---

## 8. Player Menu System

### 8.1 Menu Lifecycle

- **Created:** On `S_EVENT_TAKEOFF` for player groups.
- **Removed:** On `S_EVENT_PILOT_DEAD`, `S_EVENT_EJECTION`, `S_EVENT_PLAYER_LEAVE_UNIT`, `S_EVENT_LAND`.
- Menus are per-group (using `missionCommands.addSubMenuForGroup` / `addCommandForGroup`).

### 8.2 Menu Structure

The menu structure changes based on the JTAC's session state **relative to the player's group**:

#### When player is not the controlled flight and not in queue (or state is IDLE):

```
F10 Other...
  └─ JTAC
      └─ [frequency] [modulation] - [callsign]
          └─ Check In
```

#### When player is the controlled flight, state is IDLE, holding for targets (no-target re-scan active):

```
F10 Other...
  └─ JTAC
      └─ [frequency] [modulation] - [callsign]
          └─ Abort
```

#### When player is the controlled flight and state is BRIEF_SENT:

```
F10 Other...
  └─ JTAC
      └─ [frequency] [modulation] - [callsign]
          ├─ Readback
          ├─ Request Laser Code ►
          │     ├─ 1688
          │     ├─ 1111
          │     ├─ 1511
          │     ├─ ...
          │     └─ 1577
          └─ Abort
```

#### When player is the controlled flight and state is CLEARED_HOT:

```
F10 Other...
  └─ JTAC
      └─ [frequency] [modulation] - [callsign]
          ├─ New Target
          ├─ Request Laser Code ►
          │     ├─ 1688
          │     ├─ 1111
          │     ├─ 1511
          │     ├─ ...
          │     └─ 1577
          └─ Abort
```

Note: The JTAC performs BDA automatically. "New Target" lets the player request a different target if they cannot engage the current one. The JTAC stops lasing the current target, detects the next priority target, and sends a new 9-line. "Request Laser Code" is only available to the checked-in flight.

#### When player is in the queue:

```
F10 Other...
  └─ JTAC
      └─ [frequency] [modulation] - [callsign]
          └─ Leave Queue
```

### 8.3 Menu Updates

`jtac.updateMenusForState(jtacName, groupName)` is called on every state transition. It removes the JTAC's submenu for the group and recreates it with the appropriate options for the new state.

---

## 9. Flight Queue

### 9.1 Behaviour

- Maximum one flight controlled per JTAC at a time.
- When a player selects "Check In" and the JTAC is busy, the player's `{groupName, playerName}` is appended to `session.flightQueue`.
- JTAC transmits: `"[callsign], standby. Currently controlling traffic. [playerName], you are number [N] in the stack."`.
- Menu changes to show "Leave Queue" only.

### 9.2 Periodic Status

A recurring timer transmits queue position to all listeners:
- Interval: `queueStatusDuration` (30 seconds), matching message display duration so the status is always visible.
- Message is a single combined transmission listing all queued flights: `"[callsign] stack: [player1] #1, [player2] #2, ..."`. This avoids TransmitMessage overlapping.
- Timer self-cancels when queue is empty.
- Timer guards against stale state (checks queue non-empty before transmitting).

### 9.3 Dequeue

When the current engagement ends (BDA completion, abort, or controlled flight death):
1. The first entry in `flightQueue` is removed.
2. `handleCheckIn` is called automatically for that flight.
3. All remaining queued flights receive an immediate position update.

### 9.4 Leave Queue

Player selects "Leave Queue" to voluntarily exit. Their entry is removed from `flightQueue`, remaining flights get updated positions, and their menu reverts to "Check In".

### 9.5 Cleanup

On player death/ejection/disconnect (via event handler):
- If controlled flight: end session, dequeue next.
- If queued: remove from queue, notify remaining.

---

## 10. Event Handling

### 10.1 Handled Events

| Event | Action |
|-------|--------|
| `S_EVENT_TAKEOFF` | Create JTAC menus for the player's group |
| `S_EVENT_PILOT_DEAD` | Remove menus, clean up from session/queue |
| `S_EVENT_EJECTION` | Remove menus, clean up from session/queue |
| `S_EVENT_PLAYER_LEAVE_UNIT` | Remove menus, clean up from session/queue |
| `S_EVENT_LAND` | Remove menus, clean up from session/queue |

### 10.2 JTAC Death

Not handled via events in the current design. JTAC death is detected when:
- `startMission` or `trackLaser` finds that `Unit.getByName(jtacName)` returns nil.
- Action: call `JTAC.deRegisterJtac(name)` which broadcasts a coalition-wide message and cleans up all state.

*Future consideration:* Add an event handler for JTAC unit death events to handle this more promptly.

---

## 11. Configuration

All configuration values are defined at the top of the module in the `jtac` local table:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `distanceLimit` | `10000` | Target detection/lasing range in meters |
| `trackingInterval` | `10` | Laser tracking update interval in seconds |
| `CLONEGROUP` | `"JTAC_TEMPLATE"` | DCS group name used as the spawn template |
| `jtacHeight` | `1.8` | Height offset for JTAC LOS checks (meters) |
| `vehicleHeight` | `2.5` | Height offset for target vehicle LOS checks (meters) |
| `queueStatusDuration` | `30` | Queue status message display/retransmit interval (seconds) |
| `noTargetScanInterval` | `30` | Interval for re-scanning when no targets found (seconds) |
| `freqLower` | `225.0` | Lower bound for JTAC frequency assignment (MHz) |
| `freqUpper` | `399.975` | Upper bound for JTAC frequency assignment (MHz) |
| `freqStep` | `0.025` | Frequency channel step size (MHz) |
| `guardFreq` | `243.0` | Guard frequency to exclude from assignment (MHz) |
| `callsignPool` | *(see §15)* | List of NATO JTAC-style callsign words |
| `usedCallsigns` | `{}` | Set of callsigns currently in use |
| `usedFrequencies` | `{}` | Set of frequencies currently in use |
| `excludedFrequencies` | `{}` | Mission-configurable list of MHz values to exclude (e.g., BullsBot GCI freqs) |

---

## 12. Public API

Functions exposed on the global `JTAC` table (accessible by other modules):

| Function | Parameters | Description |
|----------|------------|-------------|
| `JTAC.registerJtac(name, coalitionId)` | unit name, coalition (default 2) | Register a JTAC unit |
| `JTAC.deRegisterJtac(name)` | unit name | Deregister and destroy a JTAC |
| `JTAC.spawnJtacAtPoint(point, coalitionId)` | Vec3 or nil, coalition (default 2) | Spawn a JTAC from template at point |
| `JTAC.targetTypeList(targets)` | table of unit names | Categorise targets by type |

All other functions are local to the module (`jtac.*` on the local table).

---

## 13. Message Catalogue

All JTAC transmissions, listed by context:

| Context | Message Template | Duration |
|---------|-----------------|----------|
| Check-in ack + 9-line | `"[playerName], [callsign], 9-LINE follows:\n..."` (see §5.2) | 30s |
| No targets on check-in | `"[playerName], [callsign]. Copy check-in. No targets at this time. Hold and standby."` | 15s |
| Cleared hot | `"[playerName], readback correct. CLEARED HOT. Laser code [code]."` | 15s |
| JTAC-reported BDA (destroyed) | `"Good hit on [targetDesc]. Target destroyed."` | 15s |
| JTAC-reported BDA (next target) | `"Good hit on [targetDesc]. Target destroyed. New target, 9-LINE follows:\n..."` | 30s |
| No further targets | `"[playerName], no further targets. RTB."` | 15s |
| New target ack (more targets) | `"[playerName], copy. New target, 9-LINE follows:\n..."` | 30s |
| New target ack (no targets) | `"[playerName], no further targets. RTB."` | 15s |
| Abort ack | `"[playerName], copy abort. Mission terminated. RTB."` | 15s |
| Queue entry | `"[callsign], standby. Currently controlling traffic. [playerName], you are number [N] in the stack."` | 30s |
| Queue periodic | `"[callsign] stack: [player1] #1, [player2] #2, ..."` | 30s |
| Targets found (after hold) | `"[playerName], [callsign]. Targets in the area. Stand by for 9-LINE."` | 15s |
| Laser code change | `"[playerName], copy, laser code [code]."` | 10s |
| JTAC death | `"[callsign] is out of action!"` | 15s |
| Leave queue ack | `"[playerName], copy. Removed from stack."` | 10s |

---

## 14. Known Limitations & Future Work

| Item | Description |
|------|-------------|
| Red coalition JTAC | Architecture supports it via `coalitionId` parameter but no red-side flow exists. |
| JTAC death detection | Relies on polling (via `trackLaser` and flow functions). Could be improved with a dedicated death event handler. |
| Multiple JTACs coordinating | No handoff or deconfliction between JTACs. |
| Timer cancellation | DCS `timer.scheduleFunction` cannot be cancelled. Stale timers are handled via state guards. This is acceptable but produces unnecessary timer callbacks. |

---

## 15. Callsign Generation

### 15.1 Callsign Pool

JTAC callsigns are drawn from a predefined NATO JTAC-style word list:

```lua
jtac.callsignPool = {
    "PLAYBOY", "WARRIOR", "REAPER", "HAMMER", "DAGGER",
    "FALCON", "PHANTOM", "VIPER", "SPARTAN", "RAIDER",
    "SHADOW", "COBRA", "TALON", "WARHOG", "ANVIL",
    "SABER", "RAPTOR", "VIKING", "STRIKER", "PALADIN"
}
```

### 15.2 Assignment

On registration (`JTAC.registerJtac`), a callsign is selected at random from the pool. Used callsigns are tracked in `jtac.usedCallsigns` (a set keyed by callsign string) to prevent duplicates across active JTACs.

**Algorithm:**
1. Shuffle or randomly index into `callsignPool`.
2. If the selected callsign is in `usedCallsigns`, try the next one.
3. If all callsigns are exhausted, append a numeric suffix: `"PLAYBOY-2"`, `"PLAYBOY-3"`, etc.
4. Add the chosen callsign to `usedCallsigns`.
5. On deregistration, remove the callsign from `usedCallsigns`.

### 15.3 Configuration

The callsign pool is defined in the `jtac` config table and can be overridden by mission-specific override files if needed.

---

## 16. Frequency Assignment

### 16.1 Frequency Range

| Parameter | Value |
|-----------|-------|
| Band | UHF AM |
| Lower bound | `225.0` MHz |
| Upper bound | `399.975` MHz |
| Step | `0.025` MHz (25 kHz channels) |
| Modulation | `"AM"` |

### 16.2 Excluded Frequencies

The following frequencies are excluded from random assignment to avoid collisions:

| Frequency | Reason |
|-----------|--------|
| `243.0` MHz | International guard/emergency frequency |
| `BLUECASFREQ` | Mission-assigned blue CAS frequency (if global exists) |
| `REDCASFREQ` | Mission-assigned red CAS frequency (if global exists) |
| Any frequency already assigned to another active JTAC | Tracked in `jtac.usedFrequencies` |
| Any frequency in `jtac.excludedFrequencies` | Mission-configurable exclusion list (e.g., BullsBot GCI frequencies) |

`jtac.excludedFrequencies` is an array of MHz values that override files can populate before JTACs are spawned. Example:

```lua
-- In an override file:
jtac.excludedFrequencies = { 251.0, 264.0 }  -- BullsBot freqs for this mission
```

### 16.3 Assignment Algorithm

1. Generate a random frequency within the range: `lower + math.random(0, steps) * step` where `steps = (upper - lower) / step`.
2. Round to nearest 0.025 MHz to ensure valid channel.
3. Check against exclusion list (`usedFrequencies`, guard freq, CAS freqs).
4. If collision, regenerate (retry up to 100 times, then fall back to sequential scan).
5. Store in `jtac.usedFrequencies` (set keyed by frequency number).
6. On deregistration, remove from `usedFrequencies`.

### 16.4 Configuration

Frequency bounds are defined in the `jtac` config table:

```lua
jtac.freqLower = 225.0
jtac.freqUpper = 399.975
jtac.freqStep = 0.025
jtac.guardFreq = 243.0
```
