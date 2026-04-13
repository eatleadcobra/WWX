-- =============================================================================
-- JTAC Module — Full CAS terminal control with state machine, 9-line briefs,
-- flight queue, retransmit, and radio comms via TransmitMessage.
-- Spec: docs/JTAC_SPEC.md
-- =============================================================================

JTAC = {}

local DEBUG = true

-- ─── Configuration (§11) ────────────────────────────────────────────────────

local jtac = {
    distanceLimit        = 10000,
    trackingInterval     = 0.05,
    CLONEGROUP           = "JTAC_TEMPLATE",
    jtacHeight           = 1.8,
    vehicleHeight        = 2.5,
    queueStatusDuration  = 30,
    responseDelay        = 5,
    laserTimeout         = 120,
    noTargetScanInterval = 30,
    freqLower            = 225.0,
    freqUpper            = 399.975,
    freqStep             = 0.025,
    guardFreq            = 243.0,
    callsignPool         = {
        "PLAYBOY", "WARRIOR", "REAPER", "HAMMER", "DAGGER",
        "FALCON", "PHANTOM", "VIPER", "SPARTAN", "RAIDER",
        "SHADOW", "COBRA", "TALON", "WARHOG", "ANVIL",
        "SABER", "RAPTOR", "VIKING", "STRIKER", "PALADIN",
    },
    usedCallsigns        = {},
    usedFrequencies      = {},
    excludedFrequencies  = {},
    jtacs                = {},
    jtacMenu             = {},
    laserCodes           = { 1688, 1111, 1511, 1522, 1533, 1544, 1555, 1566, 1577 },
}

local lasing = {}
local jtacEvents = {}

-- ─── Session Factory (§3.1) ─────────────────────────────────────────────────

function jtac.newSession()
    return {
        state                      = "IDLE",
        controlledFlight           = nil,
        controlledFlightPlayerName = nil,
        flightQueue                = {},
        queueStatusActive          = false,
        currentTarget              = nil,
        briefData                  = nil,
        retransmitTimer            = nil,
        lastMessage                = nil,
        messageDuration            = 15,
        noTargetScanActive         = false,
    }
end

-- ─── Callsign Generation (§15) ──────────────────────────────────────────────

function jtac.generateCallsign()
    local pool = {}
    for i = 1, #jtac.callsignPool do
        pool[i] = jtac.callsignPool[i]
    end
    -- Fisher-Yates shuffle
    for i = #pool, 2, -1 do
        local j = math.random(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end
    for i = 1, #pool do
        if not jtac.usedCallsigns[pool[i]] then
            jtac.usedCallsigns[pool[i]] = true
            return pool[i]
        end
    end
    -- All exhausted — append numeric suffix
    local suffix = 2
    while true do
        local base = pool[math.random(1, #pool)]
        local candidate = base .. "-" .. suffix
        if not jtac.usedCallsigns[candidate] then
            jtac.usedCallsigns[candidate] = true
            return candidate
        end
        suffix = suffix + 1
    end
end

-- ─── Frequency Assignment (§16) ─────────────────────────────────────────────

function jtac.generateFrequency(coalitionId)
    local excluded = {}
    excluded[jtac.guardFreq] = true
    if BLUECASFREQ then
        excluded[BLUECASFREQ] = true
    end
    if REDCASFREQ then
        excluded[REDCASFREQ] = true
    end
    for freq, _ in pairs(jtac.usedFrequencies) do
        excluded[freq] = true
    end
    for i = 1, #jtac.excludedFrequencies do
        excluded[jtac.excludedFrequencies[i]] = true
    end

    local steps = math.floor((jtac.freqUpper - jtac.freqLower) / jtac.freqStep)
    for attempt = 1, 100 do
        local idx = math.random(0, steps)
        local freq = jtac.freqLower + idx * jtac.freqStep
        freq = math.floor(freq * 1000 + 0.5) / 1000 -- round to nearest kHz
        if not excluded[freq] then
            jtac.usedFrequencies[freq] = true
            return freq
        end
    end
    -- Sequential fallback
    for idx = 0, steps do
        local freq = jtac.freqLower + idx * jtac.freqStep
        freq = math.floor(freq * 1000 + 0.5) / 1000
        if not excluded[freq] then
            jtac.usedFrequencies[freq] = true
            return freq
        end
    end
    -- Should never happen — return a default
    return 250.0
end

-- ─── Registration & Lifecycle (§2) ──────────────────────────────────────────

function JTAC.registerJtac(name, coalitionId)
    local cid = coalitionId or 2
    local jtacUnit = Unit.getByName(name)
    if jtacUnit then
        local callsign = jtac.generateCallsign()
        local frequency = jtac.generateFrequency(cid)
        jtac.jtacs[name] = {
            spawnTime  = timer.getTime(),
            code       = 1688,
            callsign   = callsign,
            frequency  = frequency,
            modulation = "AM",
            coalition  = cid,
            stopLasing = false,
            session    = jtac.newSession(),
        }
        -- Set the JTAC group's radio frequency so TransmitMessage works
        local jtacGroup = jtacUnit:getGroup()
        if jtacGroup then
            local controller = jtacGroup:getController()
            if controller then
                controller:setCommand({
                    id = "SetFrequency",
                    params = {
                        frequency = frequency * 1000000,
                        modulation = 0, -- AM
                    }
                })
            end
        end
        env.info("JTAC registered: " .. name .. " as " .. callsign .. " on " .. frequency .. " AM", false)
    end
end

function JTAC.deRegisterJtac(name)
    local jtacData = jtac.jtacs[name]
    if jtacData then
        -- Destroy active laser
        if lasing[name] then
            if lasing[name].laser then
                lasing[name].laser:destroy()
            end
            lasing[name] = nil
        end
        -- Broadcast death
        trigger.action.outTextForCoalition(jtacData.coalition, "JTAC " .. jtacData.callsign .. " is out of action!", 15, false)
        -- Release callsign and frequency
        jtac.usedCallsigns[jtacData.callsign] = nil
        jtac.usedFrequencies[jtacData.frequency] = nil
        -- Destroy DCS group
        local jtacUnit = Unit.getByName(name)
        if jtacUnit then
            local jtacGroup = jtacUnit:getGroup()
            if jtacGroup then
                jtacGroup:destroy()
            end
        end
        -- Remove entry
        jtac.jtacs[name] = nil
    end
end

function JTAC.spawnJtacAtPoint(point, coalitionId)
    local cid = coalitionId or 2
    local result
    if point then
        result = mist.teleportToPoint({groupName = jtac.CLONEGROUP, point = point, action = "clone"})
    else
        result = mist.cloneGroup(jtac.CLONEGROUP, true)
    end
    if result then
        local groupName = result.name
        if groupName then
            local jtacGroup = Group.getByName(groupName)
            if jtacGroup then
                local jtacUnit = jtacGroup:getUnit(1)
                if jtacUnit then
                    JTAC.registerJtac(jtacUnit:getName(), cid)
                end
            end
        end
    end
end

-- ─── Transmission (§4.1) ────────────────────────────────────────────────────

function jtac.transmit(jtacName, message, duration, repeatMessage, sender)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local jtacGroup = jtacUnit:getGroup()
            if jtacGroup then
                local controller = jtacGroup:getController()
                if controller then
                    local prefix = tostring(sender or jtacData.callsign) .. ":\n> "
                    controller:setCommand({
                        id = "TransmitMessage",
                        params = {
                            duration = duration,
                            subtitle = prefix .. message,
                            loop = false,
                            file = "l10n/DEFAULT/Alert.ogg",
                        }
                    })
                    local session = jtacData.session
                    if session and repeatMessage ~= false then
                        session.lastMessage = message
                        session.messageDuration = duration
                    end
                end
            end
        end
    end
end

function jtac.getPlayerCallsign(groupName)
    local callsign = "Flight"
    local group = Group.getByName(groupName)
    if group then
        local unit1 = group:getUnit(1)
        if unit1 then
            local pn = unit1:getPlayerName()
            if pn then
                callsign = pn
            end
        end
    end
    return callsign
end

function jtac.transmitPlayer(jtacName, playerCallsign, message, duration)
    jtac.transmit(jtacName, message, duration or 10, false, playerCallsign)
end

function jtac.scheduleCheckIn(param)
    jtac.handleCheckIn(param.jtacName, param.groupName)
end

function jtac.scheduleNewTarget(param)
    jtac.handleNewTarget(param.jtacName, param.groupName)
end

function jtac.scheduleAbort(param)
    jtac.handleAbort(param.jtacName, param.groupName)
end

function jtac.scheduleLeaveQueue(param)
    jtac.handleLeaveQueue(param.jtacName, param.groupName)
end

function jtac.scheduleLaserCodeChange(param)
    jtac.handleLaserCodeChange(param.jtacName, param.groupName, param.newCode)
end

-- ─── Retransmit (§4.2) ──────────────────────────────────────────────────────

function jtac.scheduleRetransmit(jtacName, expectedState)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            local delay = session.messageDuration + 1
            timer.scheduleFunction(jtac.retransmitCheck, {jtacName = jtacName, expectedState = expectedState}, timer.getTime() + delay)
        end
    end
end

function jtac.retransmitCheck(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if session.state == param.expectedState then
                local message = session.lastMessage
                if param.expectedState == "CLEARED_HOT" then
                    message = "LASERS HOT"
                end
                if message then
                    jtac.transmit(param.jtacName, message, session.messageDuration or 15, false)
                    jtac.scheduleRetransmit(param.jtacName, param.expectedState)
                end
            end
        end
    end
end

function jtac.performBrief(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if session.controlledFlight == param.groupName then
                if session.currentTarget then
                    local briefText = jtac.build9Line(param.jtacName, session.currentTarget)
                    if briefText then
                        session.state = "BRIEF_SENT"
                        local message = briefText
                        if param.prefix then
                            message = param.prefix .. "\n" .. briefText
                        end
                        jtac.transmit(param.jtacName, message, 30)
                        jtac.scheduleRetransmit(param.jtacName, "BRIEF_SENT")
                        jtac.updateMenusForState(param.jtacName, param.groupName)
                    end
                end
            end
        end
    end
end

function jtac.performReadback(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if session.state == "BRIEF_SENT" then
                if session.controlledFlight == param.groupName then
                    session.state = "CLEARED_HOT"
                    jtac.laseTarget(param.jtacName)
                    local playerName = session.controlledFlightPlayerName or "Flight"
                    local msg = playerName .. ", readback correct. CLEARED HOT. Laser code " .. jtacData.code .. "."
                    jtac.transmit(param.jtacName, msg, 15)
                    jtac.scheduleRetransmit(param.jtacName, "CLEARED_HOT")
                    jtac.updateMenusForState(param.jtacName, param.groupName)
                end
            end
        end
    end
end

-- ─── Target Detection & Prioritisation (§7) ─────────────────────────────────

function jtac.getUnitsInRadius(coalitionId, point, radius)
    local findCoalition = 2
    if coalitionId == 2 then
        findCoalition = 1
    end
    local jtacPoint = {x = point.x, y = point.y + jtac.jtacHeight, z = point.z}
    local units = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = point,
            radius = radius,
        }
    }
    local ifFound = function(foundItem, val)
        local itemCoalition = foundItem:getCoalition()
        if itemCoalition == findCoalition then
            local desc = foundItem:getDesc()
            if desc then
                if desc.category == 2 and foundItem:hasAttribute("Ground vehicles") then
                    local targetPoint = foundItem:getPoint()
                    if targetPoint then
                        local tp = {x = targetPoint.x, y = targetPoint.y + jtac.vehicleHeight, z = targetPoint.z}
                        if land.isVisible(jtacPoint, tp) then
                            local unitName = foundItem:getName()
                            if unitName then
                                units[#units + 1] = unitName
                            end
                        end
                    end
                end
            end
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    return units
end

function JTAC.targetTypeList(targets)
    local targetTable = {
        ["SAM"] = {},
        ["AAA"] = {},
        ["HeavyArmoredUnits"] = {},
        ["LightArmoredUnits"] = {},
        ["Armed vehicles"] = {},
    }
    for i = 1, #targets do
        local targetObject = Unit.getByName(targets[i])
        if targetObject then
            local desc = targetObject:getDesc()
            if desc then
                if desc.category == 2 then
                    local targetName = targetObject:getName()
                    if targetName then
                        if targetObject:hasAttribute("SAM") then
                            targetTable["SAM"][#targetTable["SAM"] + 1] = targetName
                        elseif targetObject:hasAttribute("AAA") then
                            targetTable["AAA"][#targetTable["AAA"] + 1] = targetName
                        elseif targetObject:hasAttribute("HeavyArmoredUnits") then
                            targetTable["HeavyArmoredUnits"][#targetTable["HeavyArmoredUnits"] + 1] = targetName
                        elseif targetObject:hasAttribute("LightArmoredUnits") then
                            targetTable["LightArmoredUnits"][#targetTable["LightArmoredUnits"] + 1] = targetName
                        elseif targetObject:hasAttribute("Armed vehicles") then
                            targetTable["Armed vehicles"][#targetTable["Armed vehicles"] + 1] = targetName
                        end
                    end
                end
            end
        end
    end
    return targetTable
end

function jtac.getPriorityList(targets)
    local priorityTable = {
        [1] = "SAM",
        [2] = "HeavyArmoredUnits",
        [3] = "LightArmoredUnits",
        [4] = "Armed vehicles",
        [5] = "AAA",
    }
    local targetList = {}
    for i = 1, #priorityTable do
        local category = priorityTable[i]
        if targets[category] then
            for j = 1, #targets[category] do
                local targetName = targets[category][j]
                if Unit.getByName(targetName) then
                    targetList[#targetList + 1] = targetName
                end
            end
        end
    end
    return targetList
end

function jtac.detectUnits(jtacUnitName)
    local unit = Unit.getByName(jtacUnitName)
    if unit then
        local coalitionId = unit:getCoalition()
        if coalitionId then
            local point = unit:getPoint()
            if point then
                local detectedTargets = jtac.getUnitsInRadius(coalitionId, point, jtac.distanceLimit)
                if detectedTargets then
                    return detectedTargets
                end
            end
        end
    end
end

function jtac.detectAndPrioritise(jtacName)
    local targets = jtac.detectUnits(jtacName)
    if targets and #targets > 0 then
        local targetTypes = JTAC.targetTypeList(targets)
        if targetTypes then
            local priorityList = jtac.getPriorityList(targetTypes)
            if priorityList and #priorityList > 0 then
                return priorityList
            end
        end
    end
    return nil
end

-- ─── 9-Line CAS Brief (§5) ──────────────────────────────────────────────────

function jtac.findNearestBP(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local jtacPoint = jtacUnit:getPoint()
            if jtacPoint then
                if BattleControl and BattleControl.getClosestBp then
                    local bpId, dist = BattleControl.getClosestBp(jtacPoint)
                    if bpId and bpId > 0 then
                        local bpPoint = BattleControl.getBPPoint(bpId)
                        if bpPoint then
                            local bearing = Utils.GetBearingDeg(bpPoint, jtacPoint)
                            local direction
                            local offset
                            if (bearing >= 315 or bearing < 45) then
                                direction = "north"
                                if bearing >= 315 then
                                    offset = 360 - bearing
                                else
                                    offset = bearing
                                end
                            elseif bearing >= 45 and bearing < 135 then
                                direction = "east"
                                offset = bearing - 90
                            elseif bearing >= 135 and bearing < 225 then
                                direction = "south"
                                offset = 180 - bearing
                            else
                                direction = "west"
                                offset = bearing - 270
                            end
                            offset = math.floor(math.abs(offset) + 0.5)
                            if offset == 0 then
                                return string.format("BP-%d", bpId)
                            end
                            return string.format("IP %d degrees %s of BP-%d", offset, direction, bpId)
                        end
                    end
                end
            end
        end
    end
    return "N/A"
end
function jtac.calculateIP(targetPoint, playerGroupName)
    if targetPoint and playerGroupName then
        local playerGroup = Group.getByName(playerGroupName)
        if playerGroup then
            local playerUnit = playerGroup:getUnit(1)
            if playerUnit then
                local playerPoint = playerUnit:getPoint()
                if playerPoint then
                    local bearingToAircraft = Utils.GetBearingDeg(targetPoint, playerPoint)
                    local ipDistance = 15 * 1852
                    local rad = math.rad(bearingToAircraft)
                    local ipPoint = {
                        x = targetPoint.x + math.sin(rad) * ipDistance,
                        y = targetPoint.y,
                        z = targetPoint.z + math.cos(rad) * ipDistance,
                    }
                    return ipPoint
                end
            end
        end
    end
end
function jtac.calculateVectorFromBulls(point, playerGroupName)
    if point then
        local group = Group.getByName(playerGroupName)
        if group then
            local coalitionId = group:getCoalition()
            local bullsPoint = coalition.getMainRefPoint(coalitionId)
            if bullsPoint then
                local bullsBearing = Utils.GetBearingDeg(bullsPoint, point)
                local bullsDist = Utils.PointDistance(bullsPoint, point)
                local bullsDistNm = tonumber(string.format("%.0f", (bullsDist / 1000 / 1.852)))
                local bearingInt = math.floor(bullsBearing + 0.5)
                if bearingInt >= 360 then
                    bearingInt = bearingInt - 360
                end
                local lat, long, alt = coord.LOtoLL(point)
                local coords = mist.tostringLL(lat, long, 2)
                if coords then
                    return string.format("IP %03d° %dNM from BULLS (%s)", bearingInt, bullsDistNm, coords)
                end
                return string.format("IP %03d° %dNM from BULLS", bearingInt, bullsDistNm)
            end
        end
    end
    return nil
end
function jtac.findNearestFriendlies(jtacName, targetPoint)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local groups = coalition.getGroups(jtacData.coalition, Group.Category.GROUND)
        if groups then
            local nearestDist = jtac.distanceLimit + 1
            local nearestPoint = nil
            for i = 1, #groups do
                local grp = groups[i]
                if grp then
                    local unit1 = grp:getUnit(1)
                    if unit1 then
                        local fPoint = unit1:getPoint()
                        if fPoint then
                            local dist = Utils.PointDistance(targetPoint, fPoint)
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestPoint = fPoint
                            end
                        end
                    end
                end
            end
            if nearestPoint then
                local compass = Utils.degToCompass(Utils.GetBearingDeg(targetPoint, nearestPoint))
                local distKm = nearestDist / 1000
                return string.format("%s %.1fkm", compass, distKm)
            end
        end
    end
    return "None in area"
end

function jtac.computeEgress(jtacPoint, targetPoint)
    local bearing = Utils.GetBearingDeg(targetPoint, jtacPoint)
    local compass = Utils.degToCompass(bearing)
    return "Egress " .. compass
end

function jtac.build9Line(jtacName, targetName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local jtacPoint = jtacUnit:getPoint()
            if jtacPoint then
                local target = Unit.getByName(targetName)
                if target then
                    local targetPoint = target:getPoint()
                    if targetPoint then
                        local targetDesc = target:getTypeName()
                        local desc = target:getDesc()
                        if desc and desc.displayName then
                            targetDesc = desc.displayName
                        end

                        local session = jtacData.session
                        local ip = jtac.calculateIP(targetPoint, session.controlledFlight)
                        local tplat, tplong, tpalt = coord.LOtoLL(targetPoint)
                        local ipString = jtac.calculateVectorFromBulls(ip, session.controlledFlight)
                        local heading = string.format("%03d", Utils.GetBearingDeg(ip, targetPoint))
                        local distance = string.format("%.1f", Utils.PointDistance(ip, targetPoint) / 1000)
                        local elevM = land.getHeight({x = targetPoint.x, y = targetPoint.z})
                        local elevation = string.format("%d", math.floor(elevM * 3.28084)) -- convert to feet
                        local targetCoords = mist.tostringLL(tplat, tplong, 2)
                        local markType = "Laser " .. jtacData.code
                        local friendlies = jtac.findNearestFriendlies(jtacName, targetPoint)
                        local egress = jtac.computeEgress(jtacPoint, targetPoint)

                        local session = jtacData.session
                        if session then
                            session.briefData = {
                                ip = ipString or "N/A",
                                heading = heading,
                                distance = distance,
                                elevation = elevation,
                                targetDesc = targetDesc,
                                targetCoords = targetCoords,
                                markType = markType,
                                friendlies = friendlies,
                                egress = egress,
                            }
                        end

                        local playerName = ""
                        if session and session.controlledFlightPlayerName then
                            playerName = session.controlledFlightPlayerName
                        end

                        local briefText = playerName .. ", " .. jtacData.callsign .. ", 9-LINE follows:\n"
                            .. "1. IP/BP: " .. ipString .. "\n"
                            .. "2. HDG: " .. heading .. "\n"
                            .. "3. DIST: " .. distance .. " km\n"
                            .. "4. ELEV: " .. elevation .. " ft MSL\n"
                            .. "5. TGT: " .. targetDesc .. "\n"
                            .. "6. COORDS: " .. tostring(targetCoords) .. "\n"
                            .. "7. MARK: " .. markType .. "\n"
                            .. "8. FRDLY: " .. friendlies .. "\n"
                            .. "9. EGRESS: " .. egress .. "\n"
                            .. "REMARKS: N/A\n"
                            .. "\nREADBACK"

                        return briefText
                    end
                end
            end
        end
    end
    return nil
end

-- ─── Laser Designation (§6) ──────────────────────────────────────────────────

function jtac.laseTarget(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.currentTarget then
            local jtacUnit = Unit.getByName(jtacName)
            if jtacUnit then
                local target = Unit.getByName(session.currentTarget)
                if target then
                    local targetPoint = target:getPoint()
                    if targetPoint then
                        lasing[jtacName] = {
                            laser = Spot.createLaser(jtacUnit, {x = 0, y = 1.8, z = 0}, targetPoint, jtacData.code),
                            targetName = session.currentTarget,
                            expiry = timer.getTime() + jtac.laserTimeout,
                        }
                        timer.scheduleFunction(jtac.trackLaser, {jtacName = jtacName}, timer.getTime() + jtac.trackingInterval)
                        timer.scheduleFunction(jtac.stopLaserTimeout, {jtacName = jtacName}, timer.getTime() + jtac.laserTimeout)
                    end
                end
            end
        end
    end
end

function jtac.trackLaser(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if not jtacData then
        return
    end
    if jtacData.stopLasing then
        if lasing[param.jtacName] then
            if lasing[param.jtacName].laser then
                lasing[param.jtacName].laser:destroy()
            end
            lasing[param.jtacName] = nil
        end
        jtacData.stopLasing = false
        return
    end
    local jtacUnit = Unit.getByName(param.jtacName)
    if jtacUnit then
        local lasingInfo = lasing[param.jtacName]
        if lasingInfo then
            local target = Unit.getByName(lasingInfo.targetName)
            if target then
                local life = target:getLife()
                if life and life > 0 then
                    local tp = target:getPoint()
                    if tp then
                        if lasingInfo.laser then
                            lasingInfo.laser:setPoint(tp)
                        end
                        timer.scheduleFunction(jtac.trackLaser, param, timer.getTime() + jtac.trackingInterval)
                    else
                        lasing[param.jtacName] = nil
                        jtac.handleBDA(param.jtacName)
                    end
                else
                    -- Target Dead
                    if lasingInfo.laser then
                        lasingInfo.laser:destroy()
                    end
                    lasing[param.jtacName] = nil
                    jtac.handleBDA(param.jtacName)
                end
            else
                -- Target nil
                if lasingInfo.laser then
                    lasingInfo.laser:destroy()
                end
                lasing[param.jtacName] = nil
                jtac.handleBDA(param.jtacName)
            end
        end
    else
        -- JTAC dead
        JTAC.deRegisterJtac(param.jtacName)
    end
end

function jtac.stopLaserTimeout(param)
    local lasingInfo = lasing[param.jtacName]
    if lasingInfo then
        local now = timer.getTime()
        if lasingInfo.expiry and now >= lasingInfo.expiry then
            local target = Unit.getByName(lasingInfo.targetName)
            if target and target:getLife() and target:getLife() > 0 then
                if lasingInfo.laser then
                    jtac.jtacs[param.jtacName].stopLasing = true
                end
                lasing[param.jtacName] = nil
            end
        end
    end
end

-- ─── State Machine Flow Handlers (§3) ───────────────────────────────────────

function jtac.requestCheckIn(jtacName, groupName)
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Check in", 10)
    timer.scheduleFunction(jtac.scheduleCheckIn, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleCheckIn(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local session = jtacData.session
            if session then
                -- If already controlling a flight, queue this one
                if session.controlledFlight then
                    jtac.enqueueFlight(jtacName, groupName)
                else
                    -- Resolve player name
                    local playerName = "Flight"
                    local playerGroup = Group.getByName(groupName)
                    if playerGroup then
                        local unit1 = playerGroup:getUnit(1)
                        if unit1 then
                            local pn = unit1:getPlayerName()
                            if pn then
                                playerName = pn
                            end
                        end
                    end
                    session.controlledFlight = groupName
                    session.controlledFlightPlayerName = playerName

                    -- Detect targets
                    local priorityList = jtac.detectAndPrioritise(jtacName)
                    if priorityList then
                        session.currentTarget = priorityList[1]
                        timer.scheduleFunction(jtac.performBrief, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
                    else
                        -- No targets — hold
                        local msg = playerName .. ", " .. jtacData.callsign .. ". Copy check-in. No targets at this time. Hold and standby."
                        jtac.transmit(jtacName, msg, 15)
                        session.noTargetScanActive = true
                        timer.scheduleFunction(jtac.noTargetScanCheck, {jtacName = jtacName}, timer.getTime() + jtac.noTargetScanInterval)
                        jtac.updateMenusForState(jtacName, groupName)
                    end
                end
            end
        else
            JTAC.deRegisterJtac(jtacName)
        end
    end
end

function jtac.requestReadback(jtacName, groupName)
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Readback", 10)
    timer.scheduleFunction(jtac.performReadback, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.requestNewTarget(jtacName, groupName)
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Request new target", 10)
    timer.scheduleFunction(jtac.scheduleNewTarget, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleNewTarget(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local session = jtacData.session
            if session and session.state == "CLEARED_HOT" and session.controlledFlight == groupName then
                jtacData.stopLasing = true
                local playerName = session.controlledFlightPlayerName or "Flight"
                local priorityList = jtac.detectAndPrioritise(jtacName)
                if priorityList then
                    session.currentTarget = priorityList[1]
                    timer.scheduleFunction(jtac.performBrief, {jtacName = jtacName, groupName = groupName, prefix = playerName .. ", copy. New target, 9-LINE follows:"}, timer.getTime())
                else
                    local msg = playerName .. ", no further targets. RTB."
                    jtac.transmit(jtacName, msg, 15)
                    jtac.resetSession(jtacName)
                    jtac.updateMenusForState(jtacName, groupName)
                    jtac.dequeueNext(jtacName)
                end
            end
        else
            JTAC.deRegisterJtac(jtacName)
        end
    end
end

function jtac.requestAbort(jtacName, groupName)
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "No longer avilable for tasking", 10)
    timer.scheduleFunction(jtac.scheduleAbort, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleAbort(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local session = jtacData.session
            if session and session.controlledFlight == groupName then
                if session.state == "BRIEF_SENT" or session.state == "CLEARED_HOT" or session.noTargetScanActive then
                    if session.state == "CLEARED_HOT" then
                        jtacData.stopLasing = true
                    end
                    local playerName = session.controlledFlightPlayerName or "Flight"
                    local msg = playerName .. ", copy abort. Mission terminated. RTB."
                    jtac.transmit(jtacName, msg, 15)
                    session.noTargetScanActive = false
                    jtac.resetSession(jtacName)
                    jtac.updateMenusForState(jtacName, groupName)
                    jtac.dequeueNext(jtacName)
                end
            end
        else
            JTAC.deRegisterJtac(jtacName)
        end
    end
end

function jtac.handleBDA(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            local playerName = session.controlledFlightPlayerName or "Flight"
            local targetDesc = "target"
            if session.currentTarget then
                local target = Unit.getByName(session.currentTarget)
                if target then
                    local desc = target:getDesc()
                    if desc and desc.displayName then
                        targetDesc = desc.displayName
                    end
                else
                    -- Target is gone — use briefData if available
                    if session.briefData and session.briefData.targetDesc then
                        targetDesc = session.briefData.targetDesc
                    end
                end
            end

            -- Look for more targets
            local priorityList = jtac.detectAndPrioritise(jtacName)
            if priorityList then
                session.currentTarget = priorityList[1]
                local briefText = jtac.build9Line(jtacName, priorityList[1])
                if briefText then
                    jtac.transmit(jtacName, "Good hit on " .. targetDesc .. ". Target destroyed. New target detected. Stand by for 9-LINE.", 15)
                    timer.scheduleFunction(jtac.performBrief, {jtacName = jtacName, groupName = session.controlledFlight}, timer.getTime()+16)
                end
            else
                local msg = "Good hit on " .. targetDesc .. ". Target destroyed.\n" .. playerName .. ", no further targets. RTB."
                jtac.transmit(jtacName, msg, 15)
                local controlledFlight = session.controlledFlight
                jtac.resetSession(jtacName)
                if controlledFlight then
                    jtac.updateMenusForState(jtacName, controlledFlight)
                end
                jtac.dequeueNext(jtacName)
            end
        end
    end
end

function jtac.requestLaserCodeChange(jtacName, groupName, newCode)
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Request laser code " .. tostring(newCode), 10)
    timer.scheduleFunction(jtac.scheduleLaserCodeChange, {jtacName = jtacName, groupName = groupName, newCode = newCode}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleLaserCodeChange(jtacName, groupName, newCode)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.controlledFlight == groupName then
            if session.state == "BRIEF_SENT" or session.state == "CLEARED_HOT" then
                jtacData.code = newCode
                -- Recreate laser if active
                if lasing[jtacName] then
                    if lasing[jtacName].laser then
                        lasing[jtacName].laser:destroy()
                    end
                    local jtacUnit = Unit.getByName(jtacName)
                    if jtacUnit then
                        if session.currentTarget then
                            local target = Unit.getByName(session.currentTarget)
                            if target then
                                local targetPoint = target:getPoint()
                                if targetPoint then
                                    lasing[jtacName].laser = Spot.createLaser(jtacUnit, {x = 0, y = 1.8, z = 0}, targetPoint, newCode)
                                end
                            end
                        end
                    end
                end
                local playerName = session.controlledFlightPlayerName or "Flight"
                local msg = playerName .. ", copy, laser code " .. newCode .. "."
                jtac.transmit(jtacName, msg, 10, false)
            end
        end
    end
end

-- ─── No-Target Re-scan (§4.4) ───────────────────────────────────────────────

function jtac.noTargetScanCheck(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if not session.noTargetScanActive then
                return
            end
            if not session.controlledFlight then
                session.noTargetScanActive = false
                return
            end
            -- Check player still exists
            local playerGroup = Group.getByName(session.controlledFlight)
            if not playerGroup then
                session.noTargetScanActive = false
                jtac.resetSession(param.jtacName)
                jtac.dequeueNext(param.jtacName)
                return
            end
            local priorityList = jtac.detectAndPrioritise(param.jtacName)
            if priorityList then
                session.noTargetScanActive = false
                session.currentTarget = priorityList[1]
                local briefText = jtac.build9Line(param.jtacName, priorityList[1])
                if briefText then
                    local playerName = session.controlledFlightPlayerName or "Flight"
                    timer.scheduleFunction(jtac.performBrief, {jtacName = param.jtacName, groupName = session.controlledFlight, prefix = playerName .. ", " .. jtacData.callsign .. ". Targets in the area. Stand by for 9-LINE:"}, timer.getTime())
                end
            else
                timer.scheduleFunction(jtac.noTargetScanCheck, param, timer.getTime() + jtac.noTargetScanInterval)
            end
        end
    end
end

-- ─── Session Reset ──────────────────────────────────────────────────────────

function jtac.resetSession(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        jtacData.session = jtac.newSession()
    end
end

-- ─── Flight Queue (§9) ──────────────────────────────────────────────────────

function jtac.enqueueFlight(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            local playerName = "Flight"
            local playerGroup = Group.getByName(groupName)
            if playerGroup then
                local unit1 = playerGroup:getUnit(1)
                if unit1 then
                    local pn = unit1:getPlayerName()
                    if pn then
                        playerName = pn
                    end
                end
            end
            session.flightQueue[#session.flightQueue + 1] = {groupName = groupName, playerName = playerName}
            local pos = #session.flightQueue
            local msg = jtacData.callsign .. ", standby. Currently controlling traffic. " .. playerName .. ", you are number " .. pos .. " in the stack."
            jtac.transmit(jtacName, msg, 30)
            jtac.updateMenusForState(jtacName, groupName)
            -- Start periodic queue status if not running
            if not session.queueStatusActive then
                session.queueStatusActive = true
                timer.scheduleFunction(jtac.retransmitQueueStatus, {jtacName = jtacName}, timer.getTime() + jtac.queueStatusDuration)
            end
        end
    end
end

function jtac.retransmitQueueStatus(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if #session.flightQueue == 0 then
                session.queueStatusActive = false
                return
            end
            local msg = jtacData.callsign .. " stack:"
            for i = 1, #session.flightQueue do
                local entry = session.flightQueue[i]
                msg = msg .. " " .. entry.playerName .. " #" .. i
                if i < #session.flightQueue then
                    msg = msg .. ","
                end
            end
            jtac.transmit(param.jtacName, msg, jtac.queueStatusDuration)
            timer.scheduleFunction(jtac.retransmitQueueStatus, param, timer.getTime() + jtac.queueStatusDuration)
        end
    end
end

function jtac.dequeueNext(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            while #session.flightQueue > 0 do
                local entry = table.remove(session.flightQueue, 1)
                local grp = Group.getByName(entry.groupName)
                if grp then
                    -- Update remaining queue positions
                    if #session.flightQueue > 0 then
                        jtac.broadcastQueuePositions(jtacName)
                    else
                        session.queueStatusActive = false
                    end
                    jtac.handleCheckIn(jtacName, entry.groupName)
                    return
                end
                -- Group gone — skip and try next
            end
            -- Queue empty
            session.queueStatusActive = false
        end
    end
end

function jtac.requestLeaveQueue(jtacName, groupName)
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Leave queue", 10)
    timer.scheduleFunction(jtac.scheduleLeaveQueue, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleLeaveQueue(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            -- Find and remove from queue
            for i = #session.flightQueue, 1, -1 do
                if session.flightQueue[i].groupName == groupName then
                    local playerName = session.flightQueue[i].playerName
                    table.remove(session.flightQueue, i)
                    local msg = playerName .. ", copy. Removed from stack."
                    jtac.transmit(jtacName, msg, 10)
                    break
                end
            end
            if #session.flightQueue > 0 then
                jtac.broadcastQueuePositions(jtacName)
            else
                session.queueStatusActive = false
            end
            jtac.updateMenusForState(jtacName, groupName)
        end
    end
end

function jtac.broadcastQueuePositions(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session and #session.flightQueue > 0 then
            local msg = jtacData.callsign .. " stack:"
            for i = 1, #session.flightQueue do
                local entry = session.flightQueue[i]
                msg = msg .. " " .. entry.playerName .. " #" .. i
                if i < #session.flightQueue then
                    msg = msg .. ","
                end
            end
            jtac.transmit(jtacName, msg, jtac.queueStatusDuration)
        end
    end
end

-- ─── Menu System (§8) ───────────────────────────────────────────────────────

function jtac.populateMenus(groupName)
    local group = Group.getByName(groupName)
    if group then
        local groupId = group:getID()
        if groupId then
            if not jtac.jtacMenu[groupName] then
                jtac.jtacMenu[groupName] = {}
            end
            -- Create root JTAC menu
            if not jtac.jtacMenu[groupName]["root"] then
                jtac.jtacMenu[groupName]["root"] = missionCommands.addSubMenuForGroup(groupId, "JTAC")
            end
            -- Create submenu for each active JTAC
            for jtacName, data in pairs(jtac.jtacs) do
                jtac.updateMenusForState(jtacName, groupName)
            end
        end
    end
end

function jtac.removeMenus(groupName)
    local group = Group.getByName(groupName)
    if group then
        local groupId = group:getID()
        if groupId then
            if jtac.jtacMenu[groupName] then
                if jtac.jtacMenu[groupName]["root"] then
                    missionCommands.removeItemForGroup(groupId, jtac.jtacMenu[groupName]["root"])
                end
                jtac.jtacMenu[groupName] = nil
            end
        end
    end
end

function jtac.updateMenusForState(jtacName, groupName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local group = Group.getByName(groupName)
        if group then
            local groupId = group:getID()
            if groupId then
                if not jtac.jtacMenu[groupName] then
                    jtac.jtacMenu[groupName] = {}
                end
                if not jtac.jtacMenu[groupName]["root"] then
                    jtac.jtacMenu[groupName]["root"] = missionCommands.addSubMenuForGroup(groupId, "JTAC")
                end
                -- Remove existing JTAC-specific submenu for this group
                if jtac.jtacMenu[groupName][jtacName] then
                    missionCommands.removeItemForGroup(groupId, jtac.jtacMenu[groupName][jtacName])
                    jtac.jtacMenu[groupName][jtacName] = nil
                end

                -- Create JTAC submenu
                local menuTitle = jtacData.frequency .. " AM - " .. jtacData.callsign
                local jtacSub = missionCommands.addSubMenuForGroup(groupId, menuTitle, jtac.jtacMenu[groupName]["root"])
                jtac.jtacMenu[groupName][jtacName] = jtacSub

                local session = jtacData.session
                if session then
                    -- Determine player's relationship to this JTAC
                    local isControlled = session.controlledFlight == groupName
                    local isQueued = false
                    for i = 1, #session.flightQueue do
                        if session.flightQueue[i].groupName == groupName then
                            isQueued = true
                            break
                        end
                    end

                    if isQueued then
                        -- Queue menu
                        missionCommands.addCommandForGroup(groupId, "Leave Queue", jtacSub, jtac.requestLeaveQueue, jtacName, groupName)
                    elseif isControlled then
                        if session.state == "IDLE" and session.noTargetScanActive then
                            -- Holding for targets
                            missionCommands.addCommandForGroup(groupId, "Abort", jtacSub, jtac.requestAbort, jtacName, groupName)
                        elseif session.state == "BRIEF_SENT" then
                            missionCommands.addCommandForGroup(groupId, "Readback", jtacSub, jtac.requestReadback, jtacName, groupName)
                            -- Laser code submenu
                            local laserSub = missionCommands.addSubMenuForGroup(groupId, "Request Laser Code", jtacSub)
                            for _, code in ipairs(jtac.laserCodes) do
                                missionCommands.addCommandForGroup(groupId, tostring(code), laserSub, jtac.requestLaserCodeChange, jtacName, groupName, code)
                            end
                            missionCommands.addCommandForGroup(groupId, "Abort", jtacSub, jtac.requestAbort, jtacName, groupName)
                        elseif session.state == "CLEARED_HOT" then
                            missionCommands.addCommandForGroup(groupId, "New Target", jtacSub, jtac.requestNewTarget, jtacName, groupName)
                            -- Laser code submenu
                            local laserSub = missionCommands.addSubMenuForGroup(groupId, "Request Laser Code", jtacSub)
                            for _, code in ipairs(jtac.laserCodes) do
                                missionCommands.addCommandForGroup(groupId, tostring(code), laserSub, jtac.requestLaserCodeChange, jtacName, groupName, code)
                            end
                            missionCommands.addCommandForGroup(groupId, "Abort", jtacSub, jtac.requestAbort, jtacName, groupName)
                        else
                            -- IDLE with no scan active — shouldn't happen if controlled, but show Check In as fallback
                            missionCommands.addCommandForGroup(groupId, "Check In", jtacSub, jtac.requestCheckIn, jtacName, groupName)
                        end
                    else
                        -- Not controlled, not queued — show Check In
                        missionCommands.addCommandForGroup(groupId, "Check In", jtacSub, jtac.requestCheckIn, jtacName, groupName)
                    end
                end
            end
        end
    end
end

-- ─── CAS Frequency Broadcast ────────────────────────────────────────────────

function JTAC.broadcastActiveJtacs()
    -- Collect active JTACs per coalition
    local coalitionJtacs = { [1] = {}, [2] = {} }
    for jtacName, jtacData in pairs(jtac.jtacs) do
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit and jtacData.coalition then
            local jtacPoint = jtacUnit:getPoint()
            local bpStr = "N/A"
            if jtacPoint and BattleControl and BattleControl.getClosestBp then
                local bpId, dist = BattleControl.getClosestBp(jtacPoint)
                if bpId and bpId > 0 then
                    bpStr = "BP-" .. bpId
                end
            end
            local entry = string.format("  %s  %s AM  near %s", jtacData.callsign, jtacData.frequency, bpStr)
            local cid = jtacData.coalition
            coalitionJtacs[cid][#coalitionJtacs[cid] + 1] = entry
        end
    end
    -- Broadcast per coalition on CAS frequency
    local casFreqs = { [1] = REDCASFREQ, [2] = BLUECASFREQ }
    for cid = 1, 2 do
        if #coalitionJtacs[cid] > 0 and casFreqs[cid] then
            local msg = "Active JTACs:\n" .. table.concat(coalitionJtacs[cid], "\n")
            trigger.action.outTextForCoalition(cid, msg, 30, false)
        end
    end
end

-- ─── Player Cleanup ─────────────────────────────────────────────────────────

function jtac.cleanupPlayer(groupName)
    for jtacName, jtacData in pairs(jtac.jtacs) do
        if jtacData then
            local session = jtacData.session
            if session then
                if session.controlledFlight == groupName then
                    if session.state == "CLEARED_HOT" then
                        jtacData.stopLasing = true
                    end
                    session.noTargetScanActive = false
                    jtac.resetSession(jtacName)
                    jtac.dequeueNext(jtacName)
                else
                    -- Check queue
                    for i = #session.flightQueue, 1, -1 do
                        if session.flightQueue[i].groupName == groupName then
                            table.remove(session.flightQueue, i)
                        end
                    end
                    if #session.flightQueue == 0 then
                        session.queueStatusActive = false
                    end
                end
            end
        end
    end
end

-- ─── Event Handling (§10) ───────────────────────────────────────────────────

function jtacEvents:onEvent(event)
    if event.id == world.event.S_EVENT_TAKEOFF or (event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT and DEBUG) then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group then
                local playerName = event.initiator:getPlayerName()
                if playerName then
                    local groupName = group:getName()
                    if groupName then
                        jtac.populateMenus(groupName)
                    end
                end
            end
        end
    end
    if event.id == world.event.S_EVENT_PILOT_DEAD
        or event.id == world.event.S_EVENT_EJECTION
        or event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT
        or event.id == world.event.S_EVENT_LAND then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group then
                local groupName = group:getName()
                if groupName then
                    jtac.cleanupPlayer(groupName)
                    jtac.removeMenus(groupName)
                end
            end
        end
    end
end
world.addEventHandler(jtacEvents)

if DEBUG then
    local point = trigger.misc.getZone("JTAC_DEBUG_POINT").point
    JTAC.spawnJtacAtPoint(point)
end
