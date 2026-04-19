JTAC = {}
JTAC.enableInitSpawn = JTACS.spawnOnMissionStart or false
JTAC.enableSpawnOnBpCapture = JTACS.spawnOnBpCapture or false
local DEBUG = false
M_TO_NM = 1 / 1852
NM = 1852
local jtac = {
    distanceLimit        = 10000,
    trackingInterval     = 0.05,
    visualRange          = 5 * NM,
    ipRange              = 10 * NM,
    jtacHeight           = 1.8,
    vehicleHeight        = 2.5,
    queueStatusDuration  = 30,
    responseDelay        = 3,
    missionTimeout       = 900,
    noTargetScanInterval = 30,
    visualCheckInterval  = 5,
    mapLabelRefreshInterval = 10,
    maxActivePerCoalition = 9,
    freqLower            = 225.0,
    freqUpper            = 399.975,
    freqStep             = 0.025,
    guardFreq            = 243.0,
    callsignPool         = JTACS.callsignOverride or {
        "PLAYBOY", "WARRIOR", "REAPER", "HAMMER", "DAGGER",
        "FALCON", "PHANTOM", "VIPER", "SPARTAN", "RAIDER",
        "SHADOW", "COBRA", "TALON", "WARHOG", "ANVIL",
        "SABER", "RAPTOR", "VIKING", "STRIKER", "PALADIN",
    },
    usedCallsigns        = {},
    usedFrequencies      = {},
    excludedFrequencies  = JTACS.excludedFrequencies or {},
    jtacs                = {}, -- Use this for actual functional use
    jtacList             = {}, -- Used to preserve menu order, yes this is poorly named
    jtacMenu             = {},
    idleBroadcastInterval = 30,
    laserCodes           = { 1688, 1113, 1776, 1522, 1533, 1544, 1555, 1566, 1577 },
}
local lasing = {}
local jtacEvents = {}
function jtac.newSession()
    return {
        state                      = "IDLE",
        controlledFlight           = nil,
        controlledFlightPlayerName = nil,
        flightQueue                = {},
        queueStatusActive          = false,
        currentTarget              = nil,
        briefData                  = nil,
        lastMessage                = nil,
        messageDuration            = 15,
        noTargetScanActive         = false,
        visualCalloutSent          = false,
        targetCount                = 0,
        lastUpdateTime             = timer.getTime()
    }
end
-- helpers and shit
function jtac.generateCallsign()
    local pool = {}
    for i = 1, #jtac.callsignPool do
        pool[i] = jtac.callsignPool[i]
    end
    jtac.shuffleList(pool)
    for i = 1, #pool do
        if not jtac.usedCallsigns[pool[i]] then
            jtac.usedCallsigns[pool[i]] = true
            return pool[i]
        end
    end
    -- add numbers if no callsigns left
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
function jtac.updateMapLabel(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local point = jtacUnit:getPoint()
            if point and jtacData.mapMarkId then
                local displayCallsign = jtacData.callsign
                local labelPoint = {x = point.x, y = point.y + 20, z = point.z}
                trigger.action.textToAll(jtacData.coalition, jtacData.mapMarkId, labelPoint, {0,0,0,1}, {1,1,1,1}, 8, true, displayCallsign)
                return
            end
        end
    end
    jtac.clearMapLabel(jtacName)
end
function jtac.updateMapLabels()
    local deadJtacs = {}
    for jtacName, jtacData in pairs(jtac.jtacs) do
        if jtacName and jtacData then
            local jtacUnit = Unit.getByName(jtacName)
            if jtacUnit then
                jtac.updateMapLabel(jtacName)
            else
                deadJtacs[#deadJtacs + 1] = jtacName
            end
        end
    end
    for i = 1, #deadJtacs do
        JTAC.deRegisterJtac(deadJtacs[i])
    end
    return timer.getTime() + jtac.mapLabelRefreshInterval
end

function jtac.removeJtacMenus(jtacName)
    for groupName, menuData in pairs(jtac.jtacMenu) do
        if groupName and menuData then
            if menuData[jtacName] then
                local group = Group.getByName(groupName)
                if group then
                    local groupId = group:getID()
                    if groupId then
                        missionCommands.removeItemForGroup(groupId, menuData[jtacName])
                    end
                end
                menuData[jtacName] = nil
            end
        end
    end
end
function jtac.clearMapLabel(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        if jtacData.mapMarkId then
            trigger.action.removeMark(jtacData.mapMarkId)
        end
    end
end
function jtac.generateFrequency(coalitionId) -- coalitionid is to support different coalition ranges in future
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
    for i = 1, 100 do
        local idx = math.random(0, steps)
        local freq = jtac.freqLower + idx * jtac.freqStep
        freq = math.floor(freq * 1000 + 0.5) / 1000 -- round to nearest kHz
        if not excluded[freq] then
            jtac.usedFrequencies[freq] = true
            return freq
        end
    end
    return 250.0
end

function jtac.shuffleList(list)
    for i = #list, 2, -1 do
        local j = math.random(1, i)
        list[i], list[j] = list[j], list[i]
    end
end

function jtac.generateReadbackCode()
    local letters = "1234567890"
    local code = ""
    for i = 1, 4 do
        local idx = math.random(1, 10)
        code = code .. letters:sub(idx, idx)
    end
    return code
end
function jtac.refreshReadbackCodes(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            local codes = {}
            local correctCode = jtac.generateReadbackCode()
            codes[#codes + 1] = correctCode
            while #codes < 4 do
                local code = jtac.generateReadbackCode()
                local unique = true
                for i = 1, #codes do
                    if codes[i] == code then
                        unique = false
                        break
                    end
                end
                if unique then
                    codes[#codes + 1] = code
                end
            end
            jtac.shuffleList(codes)
            session.readbackCode = correctCode
            session.readbackCodes = codes
        end
    end
end

-- spawning and managing

function JTAC.registerJtac(name, coalitionId)
    local cid = coalitionId or 2
    local jtacUnit = Unit.getByName(name)
    if JTAC.getActiveJtacCountByCoalition(cid) >= jtac.maxActivePerCoalition then
        local oldest = JTAC.getOldestJtacByCoalition(cid)
        if oldest then
            env.info("JTAC: coalition " .. tostring(cid) .. " max active JTACs reached, deregistering oldest JTAC " .. oldest, false)
            JTAC.deRegisterJtac(oldest)
        end
    end
    if jtacUnit then
        local callsign = jtac.generateCallsign()
        local frequency = jtac.generateFrequency(cid)
        jtac.jtacs[name] = {
            spawnTime      = timer.getTime(),
            code           = 1688,
            callsign       = callsign,
            mapMarkId      = DrawingTools.newMarkId(),
            frequency      = frequency,
            modulation     = "AM",
            coalition      = cid,
            stopLasing     = false,
            session        = jtac.newSession(),
        }
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
        if not jtac.mapLabelsScheduled then
            jtac.mapLabelsScheduled = true
            timer.scheduleFunction(jtac.updateMapLabels, {}, timer.getTime() + jtac.mapLabelRefreshInterval)
        end
        jtac.jtacList[#jtac.jtacList + 1] = name
        jtac.updateMapLabel(name)
        timer.scheduleFunction(jtac.idleStatusBroadcast, {jtacName = name}, timer.getTime() + jtac.idleBroadcastInterval)
        env.info("JTAC registered: " .. name .. " as " .. callsign .. " on " .. frequency .. " AM", false)
    end
end

function JTAC.deRegisterJtac(name)
    local jtacData = jtac.jtacs[name]
    if jtacData then
        if lasing[name] then
            if lasing[name].laser then
                lasing[name].laser:destroy()
            end
            lasing[name] = nil
        end

        trigger.action.outTextForCoalition(jtacData.coalition, "JTAC " .. jtacData.callsign .. " is out of action!", 15, false)

        jtac.usedCallsigns[jtacData.callsign] = nil
        jtac.usedFrequencies[jtacData.frequency] = nil

        local jtacUnit = Unit.getByName(name)
        if jtacUnit then
            local jtacGroup = jtacUnit:getGroup()
            if jtacGroup then
                jtacGroup:destroy()
            end
        end

        for i = #jtac.jtacList, 1, -1 do
            if jtac.jtacList[i] == name then
                table.remove(jtac.jtacList, i)
                break
            end
        end
        env.info("JTAC deregistered: " .. tostring(name), false)
        jtac.removeJtacMenus(name)
        jtac.clearMapLabel(name)
        jtac.jtacs[name] = nil
    end
end

function JTAC.spawnJtacAtPoint(point, coalitionId, persistent)
    if not persistent then persistent = false end
    local platoonTable = {
        [1] = "Soldier M4 GRG",
    }
    -- coalitionId, persistent, units, onRoad, convoy, ship, convoyParam, navalUnit
    local newCpy = Company.newCustomPlt(coalitionId, persistent, platoonTable, false, false, false, nil, false, false, "JTAC")
    local waypoints = {
        [1] = {
            x = point.x,
            y = point.y,
            z = point.z,
        },
        [2] = {
            x = point.x + 1,
            y = point.y,
            z = point.z + 1,
        }
    }
    newCpy:setWaypoints({waypoints[1], waypoints[2]}, -1, 12)
    newCpy:spawn()

    local jtacGroupName = newCpy.groupName
    if jtacGroupName and not persistent then
        local jtacGroup = Group.getByName(jtacGroupName)
        if jtacGroup then
            local jtacUnit = jtacGroup:getUnit(1)
            if jtacUnit then
                JTAC.registerJtac(jtacUnit:getName(), coalitionId)
            end
        end
    end
    return newCpy
end

function JTAC.getActiveJtacCount()
    local count = 0
    for _, _ in pairs(jtac.jtacs) do
        count = count + 1
    end
    return count
end

function JTAC.getActiveJtacCountByCoalition(coalitionId)
    local count = 0
    for _, jtacData in pairs(jtac.jtacs) do
        if jtacData and jtacData.coalition == coalitionId then
            count = count + 1
        end
    end
    return count
end

function JTAC.getOldestJtac()
    local oldestName = nil
    local oldestTime = math.huge
    for jtacName, jtacData in pairs(jtac.jtacs) do
        if jtacData and jtacData.spawnTime and jtacData.spawnTime < oldestTime then
            oldestName = jtacName
            oldestTime = jtacData.spawnTime
        end
    end
    return oldestName
end

function JTAC.getOldestJtacByCoalition(coalitionId)
    local oldestName = nil
    local oldestTime = math.huge
    for jtacName, jtacData in pairs(jtac.jtacs) do
        if jtacData and jtacData.coalition == coalitionId then
            if jtacData.spawnTime and jtacData.spawnTime < oldestTime then
                oldestName = jtacName
                oldestTime = jtacData.spawnTime
            end
        end
    end
    return oldestName
end
function jtac.isBpWatched(bpId, coalitionId)
    for jtacName, jtacData in pairs(jtac.jtacs) do
        if jtacData and jtacData.coalition == coalitionId then
            local bpinfo = jtac.getNearestBpInfo(jtacName)
            if bpinfo and bpinfo.bpId == bpId then
                return true
            end
        end
    end
    return false
end
function jtac.getBPSamplePoints(bpCenter, bpRadius)
    local points = {}
    points[#points + 1] = {x = bpCenter.x, z = bpCenter.z}
    local sampleRadius = math.max(bpRadius * 0.75, 1)
    points[#points + 1] = {x = bpCenter.x + sampleRadius, z = bpCenter.z}
    points[#points + 1] = {x = bpCenter.x - sampleRadius, z = bpCenter.z}
    points[#points + 1] = {x = bpCenter.x, z = bpCenter.z + sampleRadius}
    points[#points + 1] = {x = bpCenter.x, z = bpCenter.z - sampleRadius}
    return points
end
function jtac.findSpawnPointForBP(bpId, coalitionId)
    if not jtac.isBpWatched(bpId, coalitionId) then
        local zoneName = "BP-" .. tostring(bpId)
        local zone = trigger.misc.getZone(zoneName)
        if zone and zone.point then
            local bpCenter = {x = zone.point.x, z = zone.point.z}
            local bpRadius = zone.radius or 0
            local bpPoints = jtac.getBPSamplePoints(bpCenter, bpRadius)
            local depot = BattleControl.getNearestDepotFromBP(bpId, coalitionId)
            local depotBearing = nil
            if depot then
                depotBearing = BattleControl.getBearingToDepotFromBP(bpId, depot)
            end
            local function hasLoS(candidate)
                for i = 1, #bpPoints do
                    local sample = bpPoints[i]
                    local sampleHeight = land.getHeight({x = sample.x, y = sample.z})
                    if sampleHeight then
                        local target = {x = sample.x, y = sampleHeight + (jtac.jtacHeight/2), z = sample.z} -- add some height to avoid bushes and low cover, but not too much or we will get a bad sample
                        if land.isVisible(candidate, target) then
                            return true
                        end
                    end
                end
                return false
            end
            local minRadius = bpRadius + 2000
            local maxRadius = bpRadius + 5000
            local radiusStep = 250
            local bearingStep = 20
            local bearStart = 0
            local bearStop = 330
            if depotBearing then
                bearStart = depotBearing - 80
                bearStop = depotBearing + 80
            end
            env.info("Jtac spawning between bearing " .. tostring(bearStart) .. " and " .. tostring(bearStop) .. " from BP-" .. tostring(bpId), false)
            for radius = minRadius, maxRadius, radiusStep do
                for bearing = bearStart, bearStop, bearingStep do
                    local rad = math.rad(bearing)
                    local candidateX = bpCenter.x + radius * math.cos(rad)
                    local candidateZ = bpCenter.z + radius * math.sin(rad)
                    local distance = Utils.PointDistance({x = bpCenter.x, y = 0, z = bpCenter.z}, {x = candidateX, y = 0, z = candidateZ})
                    if distance >= minRadius and distance <= maxRadius then
                        local groundHeight = land.getHeight({x = candidateX, y = candidateZ})
                        if groundHeight then
                            local candidate = {x = candidateX, y = groundHeight + jtac.jtacHeight, z = candidateZ}
                            if hasLoS(candidate) then
                                candidate.y = candidate.y + - jtac.jtacHeight
                                return candidate
                            end
                        end
                    end
                end
            end
        end
        env.info("Failed to find spawn point for BP-" .. tostring(bpId) .. " for coalition " .. tostring(coalitionId), false)
        return
    end
    env.info("BP " .. tostring(bpId) .. " is already being watched by a JTAC of coalition " .. tostring(coalitionId) .. " or no valid spawn point found, skipping JTAC spawn", false)
end

function JTAC.spawnJtacNearCapturedBP(bpId, coalitionId)
    local cid = coalitionId
    if bpId then
        local spawnPoint = jtac.findSpawnPointForBP(bpId, coalitionId)
        if spawnPoint then
            env.info("JTAC: spawning near BP-" .. tostring(bpId) .. " for coalition " .. tostring(cid), false)
            JTAC.spawnJtacAtPoint(spawnPoint, cid)
            return
        end
        env.info("JTAC: failed to find spawn point for BP-" .. tostring(bpId) .. ", skipping spawn", false)
        return
    end
    env.info("JTAC: invalid BP ID " .. tostring(bpId) .. ", skipping spawn", false)
end

function jtac.getNearestBpInfo(jtacName)
    local result = nil
    local jtacUnit = Unit.getByName(jtacName)
    if jtacUnit then
        local jtacPoint = jtacUnit:getPoint()
        if jtacPoint then
            local bestBp, distToBp = BattleControl.getClosestBp(jtacPoint)
            if bestBp then
                local bpPoint = BattleControl.getBPPoint(bestBp)
                if bpPoint then
                    local bearing = Utils.GetBearingDeg(bpPoint, {x = jtacPoint.x, y = 0, z = jtacPoint.z})
                    if bearing >= 360 then
                        bearing = bearing - 360
                    end
                    local distanceNm = tonumber(string.format("%.0f", distToBp / 1852))
                    result = {bpId = bestBp, bearing = math.floor(bearing + 0.5), distanceNm = distanceNm}
                end
            end
        end
    end
    return result
end

-- TODO merge this into the noTargetScanInterval function
function jtac.countDetectedTargets(param)
    local jtacName = param.jtacName
    local targetCount = 0
    local targets = jtac.detectUnits(jtacName)
    if targets then
        targetCount = #targets
    end
    if jtac.jtacs[jtacName] and jtac.jtacs[jtacName].session then
        jtac.jtacs[jtacName].session.targetCount = targetCount
        timer.scheduleFunction(jtac.countDetectedTargets, {jtacName = jtacName}, timer.getTime() + 120)
    end
end

function jtac.buildIdleStatusMessage(jtacName)
    local message = nil
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local priorityList = jtac.detectAndPrioritise(jtacName)
        local targetCount
        if priorityList and #priorityList > 0 then
            targetCount = #priorityList
        else
            targetCount = 0
        end
        jtacData.session.targetCount = targetCount
        local bpInfo = jtac.getNearestBpInfo(jtacName)
        local targetText = targetCount == 0 and "no targets" or tostring(targetCount) .. " target" .. (targetCount == 1 and "" or "s")
        if bpInfo then
            message = string.format("%s available for laser. Nearest BP-%d, %03d° at %d NM. %s.", jtacData.callsign, bpInfo.bpId, bpInfo.bearing, bpInfo.distanceNm, targetText)
        else
            message = string.format("%s available for laser. %s.", jtacData.callsign, targetText)
        end
    end
    env.info("JTAC " .. jtacName .. " idle status: " .. tostring(message), false)
    return message
end

function jtac.idleStatusBroadcast(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.state == "IDLE" and not session.controlledFlight then
            local message = jtac.buildIdleStatusMessage(param.jtacName)
            if message then
                jtac.transmit(param.jtacName, message, 15, false)
            end
        end
    end

    timer.scheduleFunction(jtac.idleStatusBroadcast, param, timer.getTime() + jtac.idleBroadcastInterval)
end

function JTAC.spawnJtacsAtRandomBPs(count, coalitionId)
    local bpIds = BattleControl.getAllBPIds()
    if #bpIds == 0 then
        env.info("JTAC: no BP zones found for debug spawn", false)
        return
    end

    local attempts = math.min(count, #bpIds)
    for i = 1, attempts do
        if #bpIds == 0 then
            break
        end
        local idx = math.random(1, #bpIds)
        local bpId = table.remove(bpIds, idx)
        if bpId then
            env.info("JTAC debug: attempting spawn at BP-" .. tostring(bpId), false)
            JTAC.spawnJtacNearCapturedBP(bpId, coalitionId)
        end
    end
end

-- radio shit

function jtac.transmit(jtacName, message, duration, repeatMessage, sender)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local jtacGroup = jtacUnit:getGroup()
            if jtacGroup then
                local controller = jtacGroup:getController()
                if controller then
                    controller:setCommand({ id = "StopTransmission", params = {} })
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
                    return
                end
            end
        end
    end
    env.info("JTAC " .. tostring(jtacName) .. " not found for transmission, likely dead, de registering", false)
    jtac.deRegisterJtac(jtacName)
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
                    if session.briefData and session.briefData.targetDesc then
                        local targetDesc = session.briefData.targetDesc
                        message = "LASER HOT on " .. targetDesc .. ". code " .. jtacData.code
                    else
                        message = "LASER HOT. code " .. jtacData.code
                    end
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
                        jtac.setSessionState(param.jtacName, param.groupName, "BRIEF_SENT")
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

function jtac.performIncorrectReadbackBrief(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if session.controlledFlight == param.groupName then
                if session.currentTarget then
                    local briefText = jtac.build9Line(param.jtacName, session.currentTarget)
                    if briefText then
                        jtac.setSessionState(param.jtacName, param.groupName, "READBACK_INCORRECT")
                        local message = "Incorrect readback. 9-LINE follows:\n" .. briefText
                        jtac.transmit(param.jtacName, message, 30)
                        jtac.scheduleRetransmit(param.jtacName, "READBACK_INCORRECT")
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
            if session.state == "BRIEF_SENT" or session.state == "READBACK_INCORRECT" then
                if session.controlledFlight == param.groupName then
                    jtac.setSessionState(param.jtacName, param.groupName, "CLEARED_HOT")
                    jtac.laseTarget(param.jtacName)
                    session.visualCalloutSent = false
                    timer.scheduleFunction(jtac.visualCheck, {jtacName = param.jtacName}, timer.getTime() + 1)
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

-- Targeting

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
        [2] = "AAA",
        [3] = "HeavyArmoredUnits",
        [4] = "LightArmoredUnits",
        [5] = "Armed vehicles",
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

-- flavour text

function jtac.calculateIP(targetPoint, playerGroupName)
    if targetPoint and playerGroupName then
        local playerGroup = Group.getByName(playerGroupName)
        if playerGroup then
            local playerUnit = playerGroup:getUnit(1)
            if playerUnit then
                local playerPoint = playerUnit:getPoint()
                if playerPoint then
                    local bearingToAircraft = Utils.GetBearingDeg(targetPoint, playerPoint)
                    local ipDistance = jtac.ipRange
                    local rad = math.rad(bearingToAircraft)
                    local ipPoint = {
                        x = targetPoint.x + math.cos(rad) * ipDistance,
                        y = targetPoint.y,
                        z = targetPoint.z + math.sin(rad) * ipDistance,
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

function jtac.buildVectorFromJtac(jtacPoint, targetPoint)
    if jtacPoint and targetPoint then
        local bearing = Utils.GetBearingDeg(jtacPoint, targetPoint)
        local distanceNm = Utils.PointDistance(jtacPoint, targetPoint) / 1852
        return string.format("%03d for %.1f NM", bearing, distanceNm)
    end
    return "unknown"
end
function jtac.requestMarkJtacWithFlare(param)
    local jtacName = param.jtacName
    if param.groupName then
        local playerCallsign = jtac.getPlayerCallsign(param.groupName)
        jtac.transmitPlayer(jtacName, playerCallsign, "Request Flare", 30)

        local colour = math.random(0, 3)
        local flareColour               
        if colour == 0 then
            flareColour = "green"
        elseif colour == 1 then
            flareColour = "red"
        elseif colour == 2 then
            flareColour = "white"
        elseif colour == 3 then
            flareColour = "yellow"
        end
        local msg = "Affirm, marking my location with " .. flareColour .. " flare."
        local jtacData = jtac.jtacs[jtacName]
        if jtacData then
            local session = jtacData.session
            if session and session.currentTarget then
                local target = Unit.getByName(session.currentTarget)
                local jtacUnit = Unit.getByName(jtacName)
                if target and jtacUnit then
                    local targetPoint = target:getPoint()
                    local jtacPoint = jtacUnit:getPoint()
                    if targetPoint and jtacPoint then
                        local vector = jtac.buildVectorFromJtac(jtacPoint, targetPoint)
                        if vector then
                            msg = "Affirm, marking my location with " .. flareColour .. " flare. Target is " .. vector .. " from my position."
                        end
                    end
                end
            end
        end
        timer.scheduleFunction(jtac.scheduleTransmit, {jtacName = jtacName, message = msg, duration = 30}, timer.getTime() + jtac.responseDelay)
        timer.scheduleFunction(jtac.markJtacWithFlare, {jtacName = jtacName, colour = colour}, timer.getTime() + jtac.responseDelay)
    end
end
function jtac.scheduleTransmit(param)
    jtac.transmit(param.jtacName, param.message, param.duration, false)
end
function jtac.markJtacWithFlare(param)
    local jtacName = param.jtacName
    local colour = param.colour
    if not colour then
        colour = 0
    end
    local jtacUnit = Unit.getByName(jtacName)
    if jtacUnit then
        local point = jtacUnit:getPoint()
        if point then
            local flarePoint = {
                x = point.x,
                y = land.getHeight({x = point.x, y = point.z}) + 1,
                z = point.z,
            }
            timer.scheduleFunction(jtac.scheduleFlare, {point = flarePoint, colour = colour , azimuth = 0}, timer.getTime() + 1.5)
            timer.scheduleFunction(jtac.scheduleFlare, {point = flarePoint, colour = colour , azimuth = 120}, timer.getTime() + 2)
            timer.scheduleFunction(jtac.scheduleFlare, {point = flarePoint, colour = colour , azimuth = 240}, timer.getTime() + 2.5)
        end
    end
end
function jtac.scheduleFlare(param)
    trigger.action.signalFlare(param.point, param.colour, param.azimuth)
end
function jtac.visualCheck(param)
    local nextRun = nil
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session and not session.visualCalloutSent and session.state == "CLEARED_HOT" then
            if session.controlledFlight and session.currentTarget then
                nextRun = timer.getTime() + jtac.visualCheckInterval
                local playerGroup = Group.getByName(session.controlledFlight)
                if playerGroup then
                    local playerUnit = playerGroup:getUnit(1)
                    local target = Unit.getByName(session.currentTarget)
                    local jtacUnit = Unit.getByName(param.jtacName)
                    if playerUnit and target and jtacUnit then
                        local playerPoint = playerUnit:getPoint()
                        local targetPoint = target:getPoint()
                        local jtacPoint = jtacUnit:getPoint()
                        if playerPoint and targetPoint and jtacPoint then
                            local distToTarget = Utils.PointDistance(playerPoint, targetPoint)
                            if distToTarget <= jtac.visualRange then
                                local playerName = session.controlledFlightPlayerName or "Flight"
                                local vector = jtac.buildVectorFromJtac(jtacPoint, targetPoint)
                                local colour = math.random(0, 3)
                                local flareColour               
                                if colour == 0 then
                                    flareColour = "green"
                                elseif colour == 1 then
                                    flareColour = "red"
                                elseif colour == 2 then
                                    flareColour = "white"
                                elseif colour == 3 then
                                    flareColour = "yellow"
                                end
                                local msg = playerName .. ", I have you visually! Marking my location with " .. flareColour .. " flare. Target is " .. vector .. " from my position."
                                jtac.markJtacWithFlare({jtacName = param.jtacName, colour = colour})
                                jtac.transmit(param.jtacName, msg, 30, false)
                                session.visualCalloutSent = true
                            end
                        end
                    end
                end
            end
        end
    end
    return nextRun
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
                        local distance = string.format("%.1f", Utils.PointDistance(ip, targetPoint) / 1852)
                        local elevM = land.getHeight({x = targetPoint.x, y = targetPoint.z})
                        local elevation = string.format("%d", math.floor(elevM * 3.28084)) -- convert to feet
                        local targetCoords = mist.tostringLL(tplat, tplong, 2)
                        local markType = "Laser " .. jtacData.code
                        local friendlies = jtac.findNearestFriendlies(jtacName, targetPoint)
                        local egress = jtac.computeEgress(jtacPoint, targetPoint)

                        if session then
                            session.briefData = {
                                ip = ipString or "N/A",
                                ipPoint = ip,
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
                        jtac.refreshReadbackCodes(jtacName)
                        local briefText = playerName .. ", " .. jtacData.callsign .. ", 9-LINE follows:\n"
                            .. "> IP/BP: " .. ipString .. "\n"
                            .. "> HDG: " .. heading .. "\n"
                            .. "> DIST: " .. distance .. " NM\n"
                            .. "> ELEV: " .. elevation .. " ft MSL\n"
                            .. "> TGT: " .. targetDesc .. "\n"
                            .. "> COORDS: " .. tostring(targetCoords) .. "\n"
                            .. "> MARK: " .. markType .. "\n"
                            .. "> FRDLY: " .. friendlies .. "\n"
                            .. "> EGRESS: " .. egress .. "\n"
                            .. "REMARKS: N/A\n"
                            .. "\nREADBACK CODE: " .. session.readbackCode

                        return briefText
                    end
                end
            end
        end
    end
    return nil
end

-- lasing

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
                        }
                        timer.scheduleFunction(jtac.trackLaser, {jtacName = jtacName}, timer.getTime() + jtac.trackingInterval)
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
                            tp.y = tp.y + 1 -- laser seems to be on the very bottom of the vehicle, adjustment to hopefully make it hit the middle
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
        env.info("JTAC " .. param.jtacName .. " is no longer alive, stopping lasing", false)
        JTAC.deRegisterJtac(param.jtacName)
    end
end

-- state management

function jtac.setSessionState(jtacName, groupName, newState)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            session.state = newState
            session.awaitingMissionConfirm = false
            if newState == "BRIEF_SENT" or newState == "READBACK_INCORRECT" or newState == "CLEARED_HOT" then
                timer.scheduleFunction(jtac.missionTimeoutCheck, {jtacName = jtacName, groupName = groupName, state = newState}, timer.getTime() + jtac.missionTimeout)
            end
        end
    end
end
function jtac.missionTimeoutCheck(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session and not session.awaitingMissionConfirm then
            if session.lastUpdateTime and ((timer.getTime() - session.lastUpdateTime) > jtac.missionTimeout) then
                if session.controlledFlight == param.groupName then
                    local playerName = session.controlledFlightPlayerName or "Flight"
                    local msg = playerName .. ", still inbound? Reply on the JTAC menu: YES to continue, NO to abort."
                    jtac.transmit(param.jtacName, msg, 20, false)
                    session.awaitingMissionConfirm = true
                    session.confirmationDeadline = timer.getTime() + 60
                    jtac.updateMenusForState(param.jtacName, param.groupName)
                    timer.scheduleFunction(jtac.missionConfirmationTimeout, {jtacName = param.jtacName, groupName = param.groupName, state = param.state}, timer.getTime() + 60)
                end
            end
        end
    end
end

function jtac.missionConfirmationTimeout(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.awaitingMissionConfirm then
            if session.controlledFlight == param.groupName and session.confirmationDeadline and timer.getTime() >= session.confirmationDeadline then
                jtac.transmit(param.jtacName, "No confirmation received. Mission terminated. RTB.", 15, false)
                if lasing[param.jtacName] and lasing[param.jtacName].laser then
                    lasing[param.jtacName].laser:destroy()
                end
                lasing[param.jtacName] = nil
                jtacData.stopLasing = false
                session.awaitingMissionConfirm = false
                session.confirmationDeadline = nil
                jtac.resetSession(param.jtacName)
                jtac.updateMenusForState(param.jtacName, param.groupName)
                jtac.dequeueNext(param.jtacName)
            end
        end
    end
end

function jtac.confirmInboundYes(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.awaitingMissionConfirm and session.controlledFlight == groupName then
            jtac.transmit(jtacName, "Copy inbound. Continue mission.", 10, false)
            session.awaitingMissionConfirm = false
            session.confirmationDeadline = nil
            session.lastUpdateTime = timer.getTime()
            jtac.updateMenusForState(jtacName, groupName)
            timer.scheduleFunction(jtac.missionTimeoutCheck, {jtacName = jtacName, groupName = groupName, state = session.state}, timer.getTime() + jtac.missionTimeout)
        end
    end
end

function jtac.confirmInboundNo(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.awaitingMissionConfirm and session.controlledFlight == groupName then
            jtac.transmit(jtacName, "Copy abort. Mission terminated. RTB.", 15, false)
            if lasing[jtacName] and lasing[jtacName].laser then
                lasing[jtacName].laser:destroy()
            end
            lasing[jtacName] = nil
            jtacData.stopLasing = false
            session.awaitingMissionConfirm = false
            session.confirmationDeadline = nil
            jtac.resetSession(jtacName)
            jtac.updateMenusForState(jtacName, groupName)
            jtac.dequeueNext(jtacName)
        end
    end
end

-- player interaction
function jtac.requestCheckIn(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Check in", 10)
    timer.scheduleFunction(jtac.handleCheckIn, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleCheckIn(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
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
                        jtac.updateMenusForState(jtacName, groupName)
                    else
                        local msg = playerName .. ", " .. jtacData.callsign .. ". Copy check-in. No targets at this time. Hold and standby."
                        jtac.transmit(jtacName, msg, 15)
                        session.noTargetScanActive = true
                        timer.scheduleFunction(jtac.noTargetScanCheck, {jtacName = jtacName}, timer.getTime() + jtac.noTargetScanInterval)
                        jtac.updateMenusForState(jtacName, groupName)
                    end
                end
            end
        else
            env.info("JTAC " .. jtacName .. " unit not found during check in, de-registering JTAC", false)
            JTAC.deRegisterJtac(jtacName)
        end
    end
end

function jtac.requestReadbackCode(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local selectedCode = param.selectedCode
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Readback " .. selectedCode, 10)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        if session then
            if (session.state == "BRIEF_SENT" or session.state == "READBACK_INCORRECT") and session.controlledFlight == groupName then
                if session.readbackCode == selectedCode then
                    timer.scheduleFunction(jtac.performReadback, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
                else
                    timer.scheduleFunction(jtac.performIncorrectReadbackBrief, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
                    jtac.updateMenusForState(jtacName, groupName)
                end
            end
        end
    end
end

function jtac.requestNewTarget(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Request new target", 10)
    timer.scheduleFunction(jtac.handleNewTarget, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleNewTarget(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local session = jtacData.session
            if session and session.state == "CLEARED_HOT" and session.controlledFlight == groupName then
                if lasing[jtacName] then
                    if lasing[jtacName].laser then
                        lasing[jtacName].laser:destroy()
                    end
                    lasing[jtacName] = nil
                end
                jtacData.stopLasing = false
                local playerName = session.controlledFlightPlayerName or "Flight"
                local priorityList = jtac.detectAndPrioritise(jtacName)
                if priorityList then
                    session.currentTarget = priorityList[1]
                    session.visualCalloutSent = false
                    jtac.updateMenusForState(jtacName, groupName)
                    timer.scheduleFunction(jtac.performBrief, {jtacName = jtacName, groupName = groupName, prefix = playerName .. ", copy. New target, 9-LINE follows:"}, timer.getTime() + jtac.responseDelay)
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

function jtac.requestAbort(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "No longer avilable for tasking", 10)
    timer.scheduleFunction(jtac.handleAbort, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleAbort(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local jtacUnit = Unit.getByName(jtacName)
        if jtacUnit then
            local session = jtacData.session
            if session and session.controlledFlight == groupName then
                if session.state == "BRIEF_SENT" or session.state == "READBACK_INCORRECT" or session.state == "CLEARED_HOT" or session.noTargetScanActive then
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
            local playerGroup = session.controlledFlight
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
                if #session.flightQueue > 0 and session.controlledFlight then
                    local oldFlight = session.controlledFlight
                    jtac.enqueueFlight(jtacName, oldFlight)
                    session.controlledFlight = nil
                    session.controlledFlightPlayerName = nil
                    session.currentTarget = nil
                    session.briefData = nil
                    session.noTargetScanActive = false
                    session.awaitingMissionConfirm = false
                    session.readbackCode = nil
                    session.readbackCodes = nil
                    jtac.updateMenusForState(jtacName, oldFlight)
                    jtac.transmit(jtacName, "Good hit on " .. targetDesc .. ". Target destroyed. Next flight up for tasking.", 15)
                    jtac.dequeueNext(jtacName)
                else
                    session.currentTarget = priorityList[1]
                    local target = Unit.getByName(session.currentTarget)
                    local jtacUnit = Unit.getByName(jtacName)
                    if target and jtacUnit then
                        local targetPoint = target:getPoint()
                        local jtacPoint = jtacUnit:getPoint()
                        if targetPoint and jtacPoint then
                            local vector = jtac.buildVectorFromJtac(jtacPoint, targetPoint)
                            jtac.transmit(jtacName, "Good hit on " .. targetDesc .. ". Target destroyed. New target detected. " .. vector .. " from my position", 15)
                            jtac.laseTarget(jtacName)
                        end
                    end
                end
            else
                local msg = "Good hit on " .. targetDesc .. ". Target destroyed.\n" .. playerName .. ", no further targets. RTB."
                jtac.transmit(jtacName, msg, 15)
                jtac.resetSession(jtacName)
                if playerGroup then
                    jtac.updateMenusForState(jtacName, playerGroup)
                end
                jtac.dequeueNext(jtacName)
            end
        end
    end
end

function jtac.requestLaserCodeChange(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local newCode = param.newCode
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Request laser code " .. tostring(newCode), 10)
    timer.scheduleFunction(jtac.handleLaserCodeChange, {jtacName = jtacName, groupName = groupName, newCode = newCode}, timer.getTime() + jtac.responseDelay)
end

function jtac.requestSmokeOnIp(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Request smoke on IP", 10)
    timer.scheduleFunction(jtac.smokeIp, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.smokeIp(param)
    local jtacData = jtac.jtacs[param.jtacName]
    if jtacData then
        local session = jtacData.session
        if session and session.controlledFlight == param.groupName then
            local playerName = session.controlledFlightPlayerName or "Flight"
            local ipPoint = session.briefData and session.briefData.ipPoint
            if ipPoint then
                local smokePoint = {x = ipPoint.x, y = land.getHeight({x = ipPoint.x, y = ipPoint.z}), z = ipPoint.z}
                trigger.action.smoke(smokePoint, 2)
                jtac.transmit(param.jtacName, playerName .. ", copy. Smoke on IP.", 10, false)
            else
                jtac.transmit(param.jtacName, playerName .. ", unable to mark IP", 10, false)
            end
        end
    end
end

function jtac.handleLaserCodeChange(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local newCode = param.newCode
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
                session.visualCalloutSent = false
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

function jtac.resetSession(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local oldQueue = {}
        local oldQueueActive = false
        if jtacData.session then
            oldQueue = jtacData.session.flightQueue or {}
            oldQueueActive = jtacData.session.queueStatusActive or false
        end
        jtacData.session = jtac.newSession()
        jtacData.session.flightQueue = oldQueue
        jtacData.session.queueStatusActive = oldQueueActive
    end
end

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
            timer.scheduleFunction(jtac.retransmitQueueStatus, param, timer.getTime() + jtac.queueStatusDuration*2)
        end
    end
end

function jtac.dequeueNext(jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if jtacData then
        local session = jtacData.session
        session.controlledFlight = nil
        session.controlledFlightPlayerName = nil
        if session then
            while #session.flightQueue > 0 do
                local entry = table.remove(session.flightQueue, 1)
                local grp = Group.getByName(entry.groupName)
                if grp then
                    if #session.flightQueue > 0 then
                        jtac.broadcastQueuePositions(jtacName)
                    else
                        session.queueStatusActive = false
                    end
                    jtac.handleCheckIn({jtacName = jtacName, groupName = entry.groupName})
                    return
                end
            end
            session.queueStatusActive = false
        end
    end
end

function jtac.requestLeaveQueue(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
    local playerCallsign = jtac.getPlayerCallsign(groupName)
    jtac.transmitPlayer(jtacName, playerCallsign, "Leave queue", 10)
    timer.scheduleFunction(jtac.handleLeaveQueue, {jtacName = jtacName, groupName = groupName}, timer.getTime() + jtac.responseDelay)
end

function jtac.handleLeaveQueue(param)
    local jtacName = param.jtacName
    local groupName = param.groupName
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

-- menus

function jtac.clearJtacSubmenus(groupName, groupId)
    if jtac.jtacMenu[groupName] then
        for i = 1, #jtac.jtacList do
            local jtacName = jtac.jtacList[i]
            local submenuId = jtac.jtacMenu[groupName][jtacName]
            if submenuId then
                missionCommands.removeItemForGroup(groupId, submenuId)
                jtac.jtacMenu[groupName][jtacName] = nil
            end
        end
    end
end

function jtac.createJtacSubmenu(groupName, groupId, jtacName)
    local jtacData = jtac.jtacs[jtacName]
    if not jtacData then
        return
    end

    local group = Group.getByName(groupName)
    if group then
        local playerCoalition = group:getCoalition()
        if playerCoalition and playerCoalition == jtacData.coalition then
            local menuTitle = jtacData.frequency .. " AM - " .. jtacData.callsign
            local jtacSub = missionCommands.addSubMenuForGroup(groupId, menuTitle, jtac.jtacMenu[groupName]["root"])
            jtac.jtacMenu[groupName][jtacName] = jtacSub

            local session = jtacData.session
            if session then
                session.lastUpdateTime = timer.getTime()
                local isControlled = session.controlledFlight == groupName
                local isQueued = false
                for i = 1, #session.flightQueue do
                    if session.flightQueue[i].groupName == groupName then
                        isQueued = true
                        break
                    end
                end

                if isQueued then
                    missionCommands.addCommandForGroup(groupId, "Leave Queue", jtacSub, jtac.requestLeaveQueue, {jtacName = jtacName, groupName = groupName})
                elseif isControlled then
                    if session.awaitingMissionConfirm then
                        missionCommands.addCommandForGroup(groupId, "Yes, still inbound", jtacSub, jtac.confirmInboundYes, {jtacName = jtacName, groupName = groupName})
                        missionCommands.addCommandForGroup(groupId, "No, abort mission", jtacSub, jtac.confirmInboundNo, {jtacName = jtacName, groupName = groupName})
                    elseif session.state == "IDLE" and session.noTargetScanActive then
                        missionCommands.addCommandForGroup(groupId, "Abort", jtacSub, jtac.requestAbort, {jtacName = jtacName, groupName = groupName})
                    elseif session.state == "BRIEF_SENT" or session.state == "READBACK_INCORRECT" then
                        if not session.readbackCodes then
                            jtac.refreshReadbackCodes(jtacName)
                        end
                        local readbackSub = missionCommands.addSubMenuForGroup(groupId, "Readback & Report Established", jtacSub)
                        if session.readbackCodes then
                            for _, code in ipairs(session.readbackCodes) do
                                missionCommands.addCommandForGroup(groupId, code, readbackSub, jtac.requestReadbackCode, {jtacName = jtacName, groupName = groupName, selectedCode = code})
                            end
                        end
                        missionCommands.addCommandForGroup(groupId, "Smoke IP", jtacSub, jtac.requestSmokeOnIp, {jtacName = jtacName, groupName = groupName})
                        local laserSub = missionCommands.addSubMenuForGroup(groupId, "Request Laser Code", jtacSub)
                        for _, code in ipairs(jtac.laserCodes) do
                            missionCommands.addCommandForGroup(groupId, tostring(code), laserSub, jtac.requestLaserCodeChange, {jtacName = jtacName, groupName = groupName, newCode = code})
                        end
                        missionCommands.addCommandForGroup(groupId, "Abort", jtacSub, jtac.requestAbort, {jtacName = jtacName, groupName = groupName})
                    elseif session.state == "CLEARED_HOT" then
                        missionCommands.addCommandForGroup(groupId, "New Target", jtacSub, jtac.requestNewTarget, {jtacName = jtacName, groupName = groupName})
                        local laserSub = missionCommands.addSubMenuForGroup(groupId, "Request Laser Code", jtacSub)
                        for _, code in ipairs(jtac.laserCodes) do
                            missionCommands.addCommandForGroup(groupId, tostring(code), laserSub, jtac.requestLaserCodeChange, {jtacName = jtacName, groupName = groupName, newCode = code})
                        end
                        missionCommands.addCommandForGroup(groupId, "Mark JTAC with flare", jtacSub, jtac.requestMarkJtacWithFlare, {jtacName = jtacName, groupName = groupName})
                        missionCommands.addCommandForGroup(groupId, "Abort", jtacSub, jtac.requestAbort, {jtacName = jtacName, groupName = groupName})
                    else
                        missionCommands.addCommandForGroup(groupId, "Check In", jtacSub, jtac.requestCheckIn, {jtacName = jtacName, groupName = groupName})
                    end
                else
                    missionCommands.addCommandForGroup(groupId, "Check In", jtacSub, jtac.requestCheckIn, {jtacName = jtacName, groupName = groupName})
                end
            end
        end
    end
end

function jtac.buildJtacSubmenusForGroup(groupName)
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

            jtac.clearJtacSubmenus(groupName, groupId)

            for i = 1, #jtac.jtacList do
                jtac.createJtacSubmenu(groupName, groupId, jtac.jtacList[i])
            end
        end
    end
end

function jtac.populateMenus(groupName)
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

            jtac.buildJtacSubmenusForGroup(groupName)
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
    if not jtac.jtacMenu[groupName] or not jtac.jtacMenu[groupName]["root"] then
        jtac.populateMenus(groupName)
        return
    end

    jtac.buildJtacSubmenusForGroup(groupName)
end

-- events

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
if JTAC.enableInitSpawn then
    JTAC.spawnJtacsAtRandomBPs(3, 2) -- could maybe leave this in even in non-debug for some random JTACs on the field, but for now just for testing
    JTAC.spawnJtacsAtRandomBPs(3, 1)
end
