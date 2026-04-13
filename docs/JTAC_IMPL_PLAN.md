# JTAC Implementation Plan

> Derived from the finalized [JTAC_SPEC.md](JTAC_SPEC.md). Each phase lists the spec sections it satisfies.  
> All code follows the **nested-if guard pattern** (no early returns) per §1.2.

---

## Phase 1 — Bug Fixes in Existing Code

Fix all known bugs in the current `Components/JTAC.lua` before any structural changes.  
These are line-level fixes; no function signatures change yet.

| # | Bug | Fix |
|---|-----|-----|
| 1.1 | `event .initiator` — space in property access (line 27) | Remove space → `event.initiator` |
| 1.2 | `Group:getUnit(1)` — class-level call instead of instance (line 82) | Change to `group:getUnit(1)` using existing `group` variable |
| 1.3 | `timer:getTime()` — colon notation on module-level table (lines 199, 234) | Change to `timer.getTime()` |
| 1.4 | `lasing[jtacUnit]` — keyed by Unit object, but later keyed by string | Always key by `jtacUnitName` (string). Audit all `lasing[]` accesses |
| 1.5 | `"Lasing taget: " .. target` — concatenating Unit object, not name; also typo "taget" | Use `target:getName()` and fix spelling |
| 1.6 | `jtac.jtacs[param.jtacName].stopLasing` — `stopLasing` never initialised | Set `stopLasing = false` in `registerJtac` |
| 1.7 | `if lasing[param.jtacName].startTime + jtac.missionLength > timer:getTime()` — colon + inverted condition | Fix to `timer.getTime()` and invert comparison to `<` |
| 1.8 | `jtac.populateMenus({group = group:getName()})` — called without checking if JTAC menus are initialised per-group properly | Will be fully replaced in Phase 5, but guard for now |
| 1.9 | `trackLaser` — `param.code` used but never passed from laseAvailableTarget | Include `code` in the param table passed to `scheduleFunction` |

**Test:** Module loads without errors. `registerJtac` + `startMission` + `trackLaser` cycle completes on a debug spawn without crash.

---

## Phase 2 — Module Restructure & Config  
*Spec: §1, §2, §11*

Restructure the module top-level table and registration to match the spec.

### 2.1 Config table

Replace the current `jtac` local table with the full config from §11:

```lua
local jtac = {
    distanceLimit       = 10000,
    trackingInterval    = 10,
    CLONEGROUP          = "JTAC_TEMPLATE",
    jtacHeight          = 1.8,
    vehicleHeight       = 2.5,
    queueStatusDuration = 30,
    noTargetScanInterval= 30,
    freqLower           = 225.0,
    freqUpper           = 399.975,
    freqStep            = 0.025,
    guardFreq           = 243.0,
    callsignPool        = { ... }, -- §15.1 full list
    usedCallsigns       = {},
    usedFrequencies     = {},
    excludedFrequencies = {},
    jtacs               = {},
    jtacMenu            = {},
}
```

Remove `missionLength`, `updateInterval`, `jtacMenu = nil`.  
Remove debug flags (`debug`, `lightDebug`, `spawnDebug`); replace with gated `env.info` calls that are always present but compile to no-ops via a single `local DEBUG = false` flag.

### 2.2 Session factory

Create `jtac.newSession()` returning the session table from §3.1:

```lua
function jtac.newSession()
    return {
        state                    = "IDLE",
        controlledFlight         = nil,
        controlledFlightPlayerName = nil,
        flightQueue              = {},
        queueStatusActive        = false,
        currentTarget            = nil,
        briefData                = nil,
        retransmitTimer          = nil,
        lastMessage              = nil,
        messageDuration          = 15,
        noTargetScanActive       = false,
    }
end
```

### 2.3 Registration (§2.1)

Rewrite `JTAC.registerJtac(name, coalitionId)`:
- Nil-check `Unit.getByName(name)`.
- Generate callsign (§15 — implemented in Phase 3).
- Generate frequency (§16 — implemented in Phase 3).
- Build entry with all fields from §2.1.
- Attach `jtac.newSession()`.
- Set `stopLasing = false`.

### 2.4 Deregistration (§2.3)

Rewrite `JTAC.deRegisterJtac(name)`:
1. Nil-check `jtac.jtacs[name]`.
2. Destroy active laser if `lasing[name]` exists.
3. Broadcast `"[callsign] is out of action!"` via `jtac.transmit`.
4. Release callsign → remove from `usedCallsigns`.
5. Release frequency → remove from `usedFrequencies`.
6. Destroy DCS group (nil-check group).
7. Remove entry from `jtac.jtacs`.

### 2.5 Spawning (§2.2)

Rewrite `JTAC.spawnJtacAtPoint(point, coalitionId)`:
- Accept optional `coalitionId` (default 2).
- Clone template, register first unit via `JTAC.registerJtac(unitName, coalitionId)`.
- Nil-check every step: `mist.teleportToPoint` return, `Group.getByName`, `getUnit(1)`.

### 2.6 Remove dead code

Delete: `checkIn`, `confirmCheckIn`, `established`, `startMission`.  
These are replaced by the state-machine flow in Phase 4.

---

## Phase 3 — Callsign & Frequency Generation  
*Spec: §15, §16*

### 3.1 Callsign generation (§15.2)

```lua
function jtac.generateCallsign()
```

- Copy pool into a temp list, shuffle with Fisher-Yates.
- Return first unused entry (not in `usedCallsigns`).
- If all used, append a numeric suffix to a random pool entry (`"PLAYBOY-2"`, etc.).
- Add result to `usedCallsigns`.

### 3.2 Frequency assignment (§16.3)

```lua
function jtac.generateFrequency(coalitionId)
```

- Build exclusion set: `guardFreq`, `BLUECASFREQ` / `REDCASFREQ` (if globals exist), all `usedFrequencies`, all `excludedFrequencies`.
- Generate random channel in range, check exclusion set.
- Retry up to 100 times, then sequential scan.
- Add result to `usedFrequencies`.

### 3.3 Wire into registerJtac

Call `generateCallsign()` and `generateFrequency(coalitionId)` in Phase 2's `registerJtac`, storing results.

---

## Phase 4 — Transmit & Retransmit System  
*Spec: §4.1, §4.2*

### 4.1 Rewrite `jtac.transmit`

```lua
function jtac.transmit(jtacName, message, duration)
```

- Nil-check `jtac.jtacs[jtacName]`, `Group.getByName(jtacName)`, `:getController()`.
- Issue `TransmitMessage` with duration and subtitle.
- Store `session.lastMessage = message`, `session.messageDuration = duration`.

### 4.2 Retransmit scheduler

```lua
function jtac.scheduleRetransmit(jtacName, expectedState)
```

- Reads `session.messageDuration` to compute delay.
- Schedules `jtac.retransmitCheck` via `timer.scheduleFunction`.
- Stores the scheduled-function return value in `session.retransmitTimer` (informational only; DCS cannot cancel timers).

### 4.3 Retransmit callback

```lua
function jtac.retransmitCheck(param)
```

- Param: `{jtacName, expectedState}`.
- Guard: `jtac.jtacs[jtacName]` nil → return.
- If `session.state == expectedState` → retransmit `session.lastMessage`, reschedule.
- If state changed → no-op.

---

## Phase 5 — 9-Line CAS Brief  
*Spec: §5*

### 5.1 IP/BP resolution (§5.3)

```lua
function jtac.findNearestBP(jtacName)
```

- Iterate all BattlePositions where `ownedBy == jtac coalition`.
- Select closest by `Utils.PointDistance`.
- Return formatted string: `"BP [zoneName], [bearing]° [distance]km"`.
- Fallback: `"N/A"`.
- Nil-check BattlePosition module availability and each BP entry.

### 5.2 Friendlies resolution (§5.4)

```lua
function jtac.findNearestFriendlies(jtacName, targetPoint)
```

- `coalition.getGroups(coalitionId, Group.Category.GROUND)`.
- For each group → get unit(1) → get point → compute distance from `targetPoint`.
- Pick nearest within `distanceLimit`.
- Format: `"[compass] [distance]km"` or `"None in area"`.
- Nil-check every group, unit, point.

### 5.3 Egress resolution (§5.5)

```lua
function jtac.computeEgress(jtacPoint, targetPoint)
```

- Bearing from target to JTAC → `Utils.degToCompass`.
- Format: `"Egress [compass]"`.

### 5.4 Build 9-line (§5.1, §5.2)

```lua
function jtac.build9Line(jtacName, targetName)
```

- Nil-check JTAC unit, target unit.
- Gather all 9 fields per §5.1 table.
- Format per §5.2 template.
- Store result in `session.briefData`.
- Return formatted string.
- Uses `land.getHeight` for elevation, converts to feet.
- Uses `coord.LLtoMGRS(coord.LOtoLL(...))` for MGRS.

---

## Phase 6 — State Machine & Flow Handlers  
*Spec: §3, §6, §7*

This is the core of the rewrite. Each handler corresponds to a state transition from §3.3.

### 6.1 Check-in handler

```lua
function jtac.handleCheckIn(jtacName, groupName)
```

- Guard: `jtac.jtacs[jtacName]`, `Unit.getByName(jtacName)`.
- If JTAC already controlling another flight → queue (Phase 7).
- Set `session.controlledFlight = groupName`.
- Look up `playerName` via group → unit(1) → `getPlayerName()`. Store in `session.controlledFlightPlayerName`.
- Detect targets: `jtac.detectUnits(jtacName)`.
- **Targets found:** Categorise → prioritise → pick top target → `build9Line` → `transmit` 9-line → set state `BRIEF_SENT` → `scheduleRetransmit(jtacName, "BRIEF_SENT")`.
- **No targets:** Transmit "No targets" message → keep state `IDLE` with `controlledFlight` set → start no-target re-scan timer → `updateMenusForState` (show Abort).

### 6.2 Readback handler

```lua
function jtac.handleReadback(jtacName, groupName)
```

- Guard: state is `BRIEF_SENT`, `controlledFlight == groupName`.
- Set state → `CLEARED_HOT`.
- Start lasing: `jtac.laseTarget(jtacName)`.
- Transmit "Cleared Hot" message with laser code.
- `scheduleRetransmit(jtacName, "CLEARED_HOT")` — retransmit until player acts (New Target / Abort) or target dies.
- Update menus.

### 6.3 Lase target

```lua
function jtac.laseTarget(jtacName)
```

- Get top-priority target from `session.currentTarget` (already picked during `handleCheckIn` or `handleNewTarget`).
- Nil-check JTAC unit, target unit, points.
- Create laser: `Spot.createLaser(jtacUnit, {x=0,y=1.8,z=0}, targetPoint, code)`.
- Store in `lasing[jtacName]`.
- Schedule `trackLaser`.

### 6.4 Track laser (§6.3, §6.4)

```lua
function jtac.trackLaser(param)
```

Rewrite of existing `trackLaser`. Param: `{jtacName = string}`.

- Guard: `jtac.jtacs[param.jtacName]` nil → return (stale timer).
- Check `stopLasing` flag → if true, destroy laser, nil lasing entry, set `stopLasing = false`, return.
- Check JTAC alive → if dead, `JTAC.deRegisterJtac`, return.
- Check target alive:
  - **Alive + laser valid:** Update laser point → reschedule.
  - **Dead:** Destroy laser → call `jtac.handleBDA(jtacName)`.
- **No closures.** Reuse `param` table. No `world.searchObjects` in this function. No `coalition.getGroups`.

### 6.5 BDA handler

```lua
function jtac.handleBDA(jtacName)
```

- Nil-check JTAC data, session.
- Get `session.currentTarget` desc for BDA message.
- Nil `lasing[jtacName]`.
- Detect new targets → prioritise.
- **More targets:** Set `currentTarget` → `build9Line` → transmit combined BDA + new 9-line → state → `BRIEF_SENT` → `scheduleRetransmit`.
- **No more targets:** Transmit BDA + "No further targets. RTB." → state → `IDLE` → dequeue next flight → update menus.

### 6.6 New Target handler

```lua
function jtac.handleNewTarget(jtacName, groupName)
```

- Guard: state is `CLEARED_HOT`, `controlledFlight == groupName`.
- Set `stopLasing = true` (trackLaser will clean up laser).
- Detect new targets → prioritise.
- **Found:** Set `currentTarget` → `build9Line` → transmit → state → `BRIEF_SENT` → `scheduleRetransmit` → update menus.
- **None:** Transmit "No further targets" → state → `IDLE` → dequeue → update menus.

### 6.7 Abort handler

```lua
function jtac.handleAbort(jtacName, groupName)
```

- Guard: state is `BRIEF_SENT` or `CLEARED_HOT`, `controlledFlight == groupName`.
- If `CLEARED_HOT`, set `stopLasing = true`.
- Transmit abort ack.
- Reset session → state `IDLE`, clear `controlledFlight`, `controlledFlightPlayerName`, `currentTarget`, `briefData`.
- Dequeue next flight.
- Update menus for the aborting player (back to Check In).

### 6.8 No-target re-scan callback (§4.4)

```lua
function jtac.noTargetScanCheck(param)
```

- Param: `{jtacName = string}`.
- Guard: `jtac.jtacs[jtacName]` nil or `session.noTargetScanActive == false` → return.
- Guard: `session.controlledFlight` nil → cancel scan (player left) → return.
- Detect targets.
- **Found:** Set `noTargetScanActive = false`, pick target, `build9Line`, transmit "Targets in the area" + 9-line, state → `BRIEF_SENT`, `scheduleRetransmit`, update menus.
- **Not found:** Reschedule self for `noTargetScanInterval` later.

### 6.9 Laser code change handler (§6.1, §6.2)

```lua
function jtac.handleLaserCodeChange(jtacName, groupName, newCode)
```

- Guard: state is `BRIEF_SENT` or `CLEARED_HOT`, `controlledFlight == groupName`.
- Update `jtac.jtacs[jtacName].code = newCode`.
- If laser is active (`lasing[jtacName]`):
  - Destroy current laser.
  - Recreate with new code and current target point.
- Transmit "Copy, laser code [code]."

### 6.10 Target detection & prioritisation (§7)

Retain existing `jtac.getUnitsInRadius`, `JTAC.targetTypeList`, `jtac.getPriorityList` with nil-check fixes from Phase 1. Wrap the detect-categorise-prioritise sequence into:

```lua
function jtac.detectAndPrioritise(jtacName)
```

Returns the priority-ordered target list, or nil if no targets found.

---

## Phase 7 — Flight Queue  
*Spec: §9*

### 7.1 Queue entry

Inside `handleCheckIn` — when `controlledFlight ~= nil`:
- Append `{groupName = groupName, playerName = playerName}` to `session.flightQueue`.
- Transmit queue position message.
- Update menus for queued player (show "Leave Queue").
- If not already running, start queue status timer (`session.queueStatusActive = true`).

### 7.2 Queue periodic status (§9.2)

```lua
function jtac.retransmitQueueStatus(param)
```

- Param: `{jtacName = string}`.
- Guard: JTAC data nil → return. Queue empty → set `queueStatusActive = false` → return.
- Build combined message listing all queued flights with positions.
- Transmit with `queueStatusDuration`.
- Reschedule self for `queueStatusDuration` later.

### 7.3 Dequeue (§9.3)

```lua
function jtac.dequeueNext(jtacName)
```

- If queue non-empty:
  - Remove first entry.
  - Verify group still exists (nil-check `Group.getByName`). If gone, skip to next.
  - Call `jtac.handleCheckIn(jtacName, entry.groupName)` for the dequeued flight.
  - Transmit updated queue positions to remaining.
- If queue empty:
  - Set `queueStatusActive = false`.

### 7.4 Leave queue (§9.4)

```lua
function jtac.handleLeaveQueue(jtacName, groupName)
```

- Find and remove entry from `session.flightQueue`.
- Transmit "Removed from stack" ack.
- Transmit updated positions to remaining.
- Update menus for departing player (back to Check In).
- If queue now empty, set `queueStatusActive = false`.

---

## Phase 8 — Player Menu System  
*Spec: §8*

### 8.1 Menu state builder

```lua
function jtac.updateMenusForState(jtacName, groupName)
```

- Remove existing JTAC submenu for this group/JTAC combination.
- Determine the player's relationship to this JTAC:
  - Not controlled, not queued → **Check In** menu.
  - Controlled, state `IDLE`, `noTargetScanActive` → **Abort** only.
  - Controlled, state `BRIEF_SENT` → **Readback**, **Request Laser Code ▸**, **Abort**.
  - Controlled, state `CLEARED_HOT` → **New Target**, **Request Laser Code ▸**, **Abort**.
  - Queued → **Leave Queue**.
- Rebuild submenu with appropriate commands.

### 8.2 Laser code submenu (§6.2)

Under "Request Laser Code", add commands for each preset code. Each calls `jtac.handleLaserCodeChange(jtacName, groupName, code)`.

### 8.3 Root menu management

- Maintain `jtac.jtacMenu[groupName]` table keyed by JTAC name.
- Root "JTAC" submenu created once per group.
- Each JTAC gets a submenu titled `"[frequency] AM - [callsign]"`.

### 8.4 Rewrite `populateMenus` and `removeMenus`

- `jtac.populateMenus(groupName)` — creates root + per-JTAC submenus for a group. Calls `updateMenusForState` for each JTAC.
- `jtac.removeMenus(groupName)` — removes root menu for group, cleans up `jtac.jtacMenu[groupName]`.

---

## Phase 9 — Event Handling  
*Spec: §10*

### 9.1 Rewrite `jtacEvents:onEvent`

Handle events per §10.1 table:

- **S_EVENT_TAKEOFF:** Nil-check initiator, group, playerName. Call `jtac.populateMenus(groupName)`.
- **S_EVENT_PILOT_DEAD / EJECTION / PLAYER_LEAVE_UNIT / LAND:** Nil-check initiator, group. Call `jtac.removeMenus(groupName)`. For each JTAC, check if this group is `controlledFlight` → if yes, reset session + dequeue. Check if in queue → if yes, remove from queue.

### 9.2 Player cleanup

```lua
function jtac.cleanupPlayer(groupName)
```

- Iterate all JTACs in `jtac.jtacs`.
- For each: check if `session.controlledFlight == groupName` → abort + dequeue.
- Check if in `session.flightQueue` → remove + update queue.
- Remove menus.

---

## Phase 10 — Integration & Robustness Audit  
*Spec: §1.2, §12*

### 10.1 Public API surface

Verify only these functions are on the global `JTAC` table (§12):
- `JTAC.registerJtac(name, coalitionId)`
- `JTAC.deRegisterJtac(name)`
- `JTAC.spawnJtacAtPoint(point, coalitionId)`
- `JTAC.targetTypeList(targets)`

All flow handlers, transmit functions, menu builders, queue functions remain on `jtac` (local).

### 10.2 Nil-guard audit

Walk every function and verify nil checks per §1.2. Audit table:

| Function | DCS API Calls to Guard |
|----------|----------------------|
| `registerJtac` | `Unit.getByName`, `timer.getTime` |
| `deRegisterJtac` | `jtac.jtacs[name]`, `lasing[name]`, `Unit.getByName`, `getGroup`, `getController` |
| `spawnJtacAtPoint` | `mist.teleportToPoint` return, `Group.getByName`, `getUnit(1)` |
| `transmit` | `jtac.jtacs[jtacName]`, `Group.getByName`, `getController` |
| `handleCheckIn` | `jtac.jtacs[jtacName]`, `Unit.getByName` (JTAC), `Group.getByName` (player), `getUnit(1)`, `getPlayerName` |
| `handleReadback` | `jtac.jtacs[jtacName]`, `Unit.getByName`, session, `controlledFlight` |
| `handleAbort` | `jtac.jtacs[jtacName]`, `Unit.getByName`, session, `controlledFlight` |
| `handleNewTarget` | `jtac.jtacs[jtacName]`, `Unit.getByName`, session, `controlledFlight` |
| `handleBDA` | `jtac.jtacs[jtacName]`, session, `currentTarget`, `Unit.getByName` (target — may already be nil, handle gracefully) |
| `handleLaserCodeChange` | `jtac.jtacs[jtacName]`, session, `controlledFlight`, `lasing[jtacName]` |
| `handleLeaveQueue` | `jtac.jtacs[jtacName]`, session, `flightQueue` |
| `laseTarget` | `jtac.jtacs[jtacName]`, `Unit.getByName` (JTAC), `Unit.getByName` (target), points |
| `trackLaser` | `jtac.jtacs[param.jtacName]`, `Unit.getByName` (JTAC), `lasing[jtacName]`, `Unit.getByName` (target), `laser:setPoint` |
| `retransmitCheck` | `jtac.jtacs[param.jtacName]`, session |
| `noTargetScanCheck` | `jtac.jtacs[param.jtacName]`, session, `controlledFlight` |
| `retransmitQueueStatus` | `jtac.jtacs[param.jtacName]`, session, queue entries |
| `dequeueNext` | `jtac.jtacs[jtacName]`, session, `Group.getByName` for dequeued entry |
| `cleanupPlayer` | All JTAC entries, sessions |
| `detectAndPrioritise` | `Unit.getByName` (JTAC), getCoalition, getPoint |
| `getUnitsInRadius` | Point validity, `foundItem:getCoalition`, `getDesc`, `getName`, `getPoint`, `land.isVisible` |
| `build9Line` | `Unit.getByName` (JTAC), `Unit.getByName` (target), `getPoint` × 2, `getDesc`, `land.getHeight`, `coord` calls |
| `findNearestBP` | BattlePosition module exists, each BP entry, `.point`, `.ownedBy` |
| `findNearestFriendlies` | `coalition.getGroups`, each group, `getUnit(1)`, `getPoint` |
| `computeEgress` | Points non-nil (caller guarantees) |
| `generateCallsign` | `callsignPool` non-empty |
| `generateFrequency` | Range validity |
| `updateMenusForState` | `jtac.jtacs[jtacName]`, `Group.getByName`, `getID` |
| `populateMenus` | `Group.getByName`, `getID` |
| `removeMenus` | `Group.getByName`, `jtac.jtacMenu[groupName]` |

### 10.3 Performance audit

- [ ] `world.searchObjects` called only in `getUnitsInRadius`, never in `trackLaser`.
- [ ] `coalition.getGroups` called only in `findNearestFriendlies`, never in `trackLaser`.
- [ ] `trackLaser` creates no closures, no new tables (reuses param).
- [ ] `updateMenusForState` only called on state transitions, not on timer ticks.
- [ ] Timer intervals: `trackingInterval >= 10`, `noTargetScanInterval >= 30`, `queueStatusDuration >= 30`.

### 10.4 Nested-if pattern audit

- [ ] No `return` inside a nil-check block (except at function bottom for fail-safe).
- [ ] Every guard is a forward-nesting `if`, not `if not ... then return end`.

### 10.5 Verification scenarios

| Scenario | Expected |
|----------|----------|
| Register → Check In → 9-line → Readback → Cleared Hot → target dies → BDA → next target → Readback → target dies → RTB | Full happy path, two targets |
| Check In → no targets → hold → targets appear → 9-line | No-target re-scan flow |
| Check In while JTAC busy → queue → wait → dequeue → 9-line | Queue flow |
| Two players queue → first dequeues → second dequeues | Multi-queue ordering |
| Abort during BRIEF_SENT | Clean return to IDLE + dequeue |
| Abort during CLEARED_HOT | Laser destroyed + IDLE + dequeue |
| Player dies during CLEARED_HOT | Cleanup + laser destroyed + dequeue |
| JTAC dies during CLEARED_HOT | Coalition broadcast, all cleanup |
| Change laser code during CLEARED_HOT | Laser destroyed + recreated with new code |
| Leave Queue | Removed from queue, menu reverts |
| No retransmit after player responds | State guard prevents stale retransmit |
| Retransmit on no response | Same message re-sent after duration expires |

---

## Phase Summary

| Phase | Spec Sections | Description |
|-------|---------------|-------------|
| 1 | — | Bug fixes (9 items) |
| 2 | §1, §2, §11 | Module restructure, config, registration, session factory |
| 3 | §15, §16 | Callsign generation, frequency assignment |
| 4 | §4.1, §4.2 | Transmit, retransmit system |
| 5 | §5 | 9-line brief (BP, friendlies, egress, builder, formatter) |
| 6 | §3, §6, §7 | State machine, all flow handlers, trackLaser, BDA |
| 7 | §9 | Flight queue (entry, periodic, dequeue, leave) |
| 8 | §8 | Menu system (5 menu states, laser code submenu) |
| 9 | §10 | Event handling, player cleanup |
| 10 | §1.2, §12 | Public API lockdown, nil-guard audit, perf audit, pattern audit, verification |

---

## Implementation Order & Dependencies

```
Phase 1 (bugs)
    │
    ▼
Phase 2 (restructure + config + registration)
    │
    ├──► Phase 3 (callsign + freq) ───► wire into Phase 2 registerJtac
    │
    ▼
Phase 4 (transmit + retransmit)
    │
    ▼
Phase 5 (9-line builder)
    │
    ▼
Phase 6 (state machine + flow handlers)  ◄── depends on 4 + 5
    │
    ├──► Phase 7 (queue) ◄── integrates with handleCheckIn, dequeue
    │
    ▼
Phase 8 (menus) ◄── depends on 6 state definitions
    │
    ▼
Phase 9 (events) ◄── depends on 8 menus + 7 queue cleanup
    │
    ▼
Phase 10 (audit + verification)
```

Phases 3 and 7 can be developed in parallel with their predecessors and wired in at the integration points noted above.
