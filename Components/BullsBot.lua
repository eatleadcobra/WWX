local bulls = {}
local bullsRadius = 200000
local ewrRadius = 90000
local mergedRange = 300
local maxBullsUnits = 5
local maxEWRZones = 5
local mergeRange = 5 * 1852 --5 NM in meters
local mergeDecayTime = 60 -- seconds before a merge callout can repeat
local activeMerges = {} -- track active merges: key -> expiry time
local bullsUnitPrefixes = {
    [1] = "RedBulls-",
    [2] = "BlueBulls-"
}
local ewrZonePrefixes = {
    [1] = "RedEWR-",
    [2] = "BlueEWR-",
}
Bulls = {}
local bullsPoints = {
    [1] = {},
    [2] = {}
}
local ewrPoints = {
    [1] = {},
    [2] = {}
}
local groupsList = {
    [1] = {},
    [2] = {},
}
local friendliesList = {
    [1] = {},
    [2] = {},
}
local radioUnits = {
    [1] = {},
    [2] = {},
}
local radioDistanceUnits = {
    [1] = {},
    [2] = {}
}
local interceptors = {
    [1] = {},
    [2] = {}
}
local unitTypes = {
    ["An-26B"] = "Transport",
    ["An-30M"] = "Transport",
    ["C-17A"] = "Transport",
    ["il-76md"] = "Transport",
    ["il-78m"] = "Transport",
    ["C-130J-30"] = "Transport",
    ["Bf-109K-4"] = "Single-engine prop",
    ["FW-190A8"] = "Single-engine prop",
    ["FW-190D9"] = "Single-engine prop",
    ["MiG-15Bis"] = "Fighter",
    ["MiG-19P"] = "Fighter",
    ["MiG-21Bis"] = "Fighter",
    ["MB-339A"] = "Attack",
    ["MiG-29 Fulcrum"] = "Fighter",
    ["M-2000C"] = "Fighter",
    ["Mirage-F1CE"] = "Fighter",
    ["Mirage-F1BE"] = "Fighter",
    ["Mirage-F1EE"] = "Fighter",
    ["AJS37"] = "Strike",
    ["JF-17"] = "Fighter",
    ["Su-25"] = "Attack",
    ["Su-25T"] = "Attack",
    ["Yak-52"] = "Single-engine prop",
    ["I-16"] = "Single-engine prop",
    ["L-39C"] = "Attack",
    ["L-39ZA"] = "Attack",
    ["A-10A"] = "Attack",
    ["A-10C"] = "Attack",
    ["A-10C_2"] = "Attack",
    ["AV8BNA"] = "Attack",
    ["C-101CC"] = "Attack",
    ["F-4E-45MC"] = "Fighter",
    ["F-5E-3"] = "Fighter",
    ["F-5E-3_FC"] = "Fighter",
    ["F-15ESE"] = "Strike Fighter",
    ["F-15C"] = "Fighter",
    ["F-16C_50"] = "Fighter",
    ["FA-18C_hornet"] = "Fighter",
    ["C-101EB"] = "Attack",
    ["F4U-1D"] = "Single-engine prop",
    ["P-47D-30bl1"] = "Single-engine prop",
    ["P-47D-30"] = "Single-engine prop",
    ["P-47D-40"] = "Single-engine prop",
    ["P-51D"] = "Single-engine prop",
    ["P-51D-30-NA"] = "Single-engine prop",
    ["MosquitoFBMkVI"] = "Multi-engine prop",
    ["F-86F Sabre"] = "Fighter",
    ["F-86F_FC"] = "Fighter",
    ["F-14A-135-GR-Early"] = "Fighter",
    ["F-14A-135-GR"] = "Fighter",
    ["F-14B"] = "Fighter",
    ["B-1B"] = "Bomber",
    ["b-52H"] = "Large Bomber",
    ["Tu-22M3"] = "Bomber",
    ["Tornado IDS"] = "Strike",
    ["Tornado GR4"] = "Strike",
    ["Su-24M"] = "Strike",
    ["A-20G"] = "Bomber",
    ["A6E"] = "Attack",
    ["SpitfireLFMkIX"] = "Single-engine prop",
    ["SpitfireLFMkIXCW"] = "Single-engine prop",

}
local contactCallsigns = {

}
bulls.callsigns = {
    --TODO move these to overrides
    alphanumerics = {
        [1] = {
            [1] = "10",
            [2] = "20",
            [3] = "30",
            [4] = "40",
            [5] = "50",
            [6] = "60",
            [7] = "60",
            [8] = "60",
        },
        [2] = {
            [1] = "Blackjack",
            [2] = "Lancer",
            [3] = "Wasp",
            [4] = "Patriot",
            [5] = "Wichita",
            [6] = "Domino",
            [7] = "Devil",
            [8] = "Cutlass"
        }
    },
    numberLimit = 6,
    counts = {
        [1] = {
            alpha = 1,
            number = 1,
        },
        [2] = {
            alpha = 1,
            number = 1,
        },
    }
}
local bullsEvents = {}
function bullsEvents:onEvent(event)
    --on death or slot out 
    if event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_EJECTION  or event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local groupName = group:getName()
                local groupCoalition = group:getCoalition()
                if groupName and groupCoalition then
                    interceptors[groupCoalition][groupName] = nil
                end
            end
        end
    end
end
if INTERCEPT then
    world.addEventHandler(bullsEvents)
end
function bulls.newCallsign(coalitionId)
    local callsign = bulls.callsigns.alphanumerics[coalitionId][bulls.callsigns.counts[coalitionId].alpha] .. bulls.callsigns.counts[coalitionId].number
    if coalitionId == 2 then
        callsign = bulls.callsigns.alphanumerics[coalitionId][bulls.callsigns.counts[coalitionId].alpha] .. "-" .. bulls.callsigns.counts[coalitionId].number
    end
    bulls.callsigns.counts[coalitionId].number = bulls.callsigns.counts[coalitionId].number + 1
    if bulls.callsigns.counts[coalitionId].number > bulls.callsigns.numberLimit then
        bulls.callsigns.counts[coalitionId].alpha = bulls.callsigns.counts[coalitionId].alpha + 1
        bulls.callsigns.counts[coalitionId].number = 1
        if bulls.callsigns.counts[coalitionId].alpha > #bulls.callsigns.alphanumerics[coalitionId] then
            bulls.callsigns.counts[coalitionId].alpha = 1
        end
    end
    return callsign
end
function Bulls.loop()
    groupsList[1] = {}
    groupsList[2] = {}
    bulls.getTargets(1)
    bulls.vectorTargets(1)
    bulls.getTargets(2)
    bulls.vectorTargets(2)
    bulls.checkForMergedContacts()
    timer.scheduleFunction(Bulls.loop, nil, timer:getTime() + 11)
end
function bulls.getBulls()
    bullsPoints[1] = coalition.getMainRefPoint(1)
    bullsPoints[2] = coalition.getMainRefPoint(2)
end
function bulls.getUnits()
    for c = 1, 2 do
        for i = 1, maxBullsUnits do
            local units = "metric"
            local bullsGroupName = bullsUnitPrefixes[c]..i.."M"
            local bullsGroup = Group.getByName(bullsGroupName)
            if bullsGroup == nil then
                bullsGroupName = bullsUnitPrefixes[c]..i.."I"
                bullsGroup = Group.getByName(bullsGroupName)
                units = "imperial"
            end
            if bullsGroup then
                table.insert(radioUnits[c], bullsGroupName)
                radioDistanceUnits[c][bullsGroupName] = units
            end
        end
    end
end
function bulls.getEWRs()
    for c = 1, 2 do
        for i = 1, maxEWRZones do
            local ewrZoneName = ewrZonePrefixes[c]..i
            local ewrZone = trigger.misc.getZone(ewrZoneName)
            if ewrZone then
                table.insert(ewrPoints[c], ewrZone.point)
            end
        end
    end
end
function bulls.getTargets(coalitionId, targetGroupName)
    local foundGroups = {}
    local foundFriendlies = {}
    for e = 1, #ewrPoints[coalitionId] do
        local ewrPoint = ewrPoints[coalitionId][e]
        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
                point = ewrPoint,
                radius = ewrRadius
            }
        }
        local ifFound = function(foundItem, val)
            if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 0 and Utils.getAGL(foundItem:getPoint()) > 0 then
                local isFriendly = false
                if foundItem:getCoalition() == coalitionId then
                    isFriendly = true
                end
                if land.isVisible({x = ewrPoint.x, y = land.getHeight({x = ewrPoint.x, y = ewrPoint.z}) + 100, z = ewrPoint.z}, foundItem:getPoint()) then
                    local foundGroup = foundItem:getGroup()
                    if foundGroup then
                        local foundGroupName = foundGroup:getName()
                        if (targetGroupName and foundGroupName == targetGroupName) or targetGroupName == nil then
                            local alreadyFound = false
                            for i = 1, #foundGroups do
                                if foundGroups[i].groupName == foundGroupName then
                                    alreadyFound = true
                                end
                            end
                            for i = 1, #foundFriendlies do
                                if foundFriendlies[i].groupName == foundGroupName then
                                    alreadyFound = true
                                end
                            end
                            if alreadyFound == false then
                                local groupCallsign = contactCallsigns[foundGroupName]
                                if groupCallsign == nil then
                                    groupCallsign = bulls.newCallsign(foundItem:getCoalition())
                                    contactCallsigns[foundGroupName] = groupCallsign
                                    trigger.action.outTextForGroup(foundGroup:getID(), "Your callsign is " .. groupCallsign, 60, false)
                                end
                                if isFriendly then
                                    foundFriendlies[#foundFriendlies+1] = {groupName = foundGroupName, isFriendly = true, callsign = groupCallsign}
                                    local foundGroupId = foundGroup:getID()
                                    if INTERCEPT and interceptors[coalitionId][foundGroupName] == nil then
                                        interceptors[coalitionId][foundGroupName] = { groupName = foundGroupName, groupId = foundGroupId, cancelGuidance = false, target = nil}
                                        local interceptPath = missionCommands.addSubMenuForGroup(foundGroupId, "Intercept Controller", nil)
                                        missionCommands.addCommandForGroup(foundGroupId, "Cancel Guidance", interceptPath, bulls.cancelGuidance, {coalitionId = foundItem:getCoalition(), groupName = foundGroupName, groupId = foundGroupId})
                                        local targetPath = missionCommands.addSubMenuForGroup(foundGroupId, "Targets", interceptPath)
                                        for i = 1, 9 do
                                            missionCommands.addCommandForGroup(foundGroupId, "Target group " .. i, targetPath, bulls.requestGuidance, {coalitionId = foundItem:getCoalition(), targetNum = i, groupId = foundGroupId, groupName = foundGroupName})
                                        end
                                        trigger.action.outTextForGroup(foundGroupId, "GCI guidance is available in the radio F10 menu.", 15, false)
                                    end
                                else
                                    foundGroups[#foundGroups+1] = {groupName = foundGroupName, isFriendly = false, callsign = groupCallsign}
                                end
                            end
                        end
                    end
                end
            end
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
    end
    groupsList[coalitionId] = foundGroups
    friendliesList[coalitionId] = foundFriendlies
end
--coalitionId, groupName
function bulls.cancelGuidance(param)
    trigger.action.outTextForGroup(param.groupId, "Standby...", 5, false)
    interceptors[param.coalitionId][param.groupName].cancelGuidance = true
    interceptors[param.coalitionId][param.groupName].target = nil
    timer.scheduleFunction(bulls.resumeGuidance, param, timer:getTime() + 7)
end
function bulls.resumeGuidance(param)
    trigger.action.outTextForGroup(param.groupId, "Guidance request canceled.", 5, false)
    interceptors[param.coalitionId][param.groupName].cancelGuidance = false
end
--requestingGroupName, targetGroupName
function bulls.BRAA(param)
    DF_UTILS.vector({from = param.requestingGroupName, to = param.targetGroupName, units = param.units, targetCallsign = param.targetCallsign})
end
--coalitionId, targetNum, groupId, groupName
function bulls.requestGuidance(param)
    local targetGroup = groupsList[param.coalitionId][param.targetNum]
    if targetGroup then
       bulls.BRAALoop({coalitionId = param.coalitionId, groupId = param.groupId, requestingGroupName = param.groupName, targetGroupName = targetGroup.groupName, targetCallsign = targetGroup.callsign})
    else
        trigger.action.outTextForGroup(param.groupId, "Not a valid group selection", 10, false)
    end
end


--coalitionId, groupId, requestingGroupName, requestingGroupId, targetGroupName, targetCallsign
function bulls.BRAALoop(param)
    local targetGroup = Group.getByName(param.targetGroupName)
    if targetGroup then
        if contactCallsigns[param.targetGroupName] then
            local interceptor = interceptors[param.coalitionId][param.requestingGroupName]
            if interceptor then
                local onScope = false
                for i = 1, #friendliesList[param.coalitionId] do
                    if friendliesList[param.coalitionId][i].groupName == param.requestingGroupName then
                        onScope = true
                    end
                end
                if onScope == false then
                    trigger.action.outTextForGroup(param.groupId, "Cannot provide guidance, you are not on scope!", 10, false)
                    interceptor.target = nil
                    return
                end
                if interceptor.cancelGuidance == false then
                    if interceptor.target == nil then
                        interceptor.target = param.targetGroupName
                    end
                    if interceptor.target == param.targetGroupName then
                        bulls.BRAA({requestingGroupName = param.requestingGroupName, targetGroupName = param.targetGroupName, targetCallsign = param.targetCallsign})
                        timer.scheduleFunction(bulls.BRAALoop, param, timer:getTime() + 6)
                    else
                        trigger.action.outTextForGroup(param.groupId, "Guidance already in progress.\nCancel guidance request before requesting another vector.", 10, false)
                    end
                end
            end
        else
            local interceptor = interceptors[param.coalitionId][param.requestingGroupName]
            if interceptor then
                trigger.action.outTextForGroup(param.groupId, "Target lost", 10, false)
                interceptor.target = nil
            end
        end
    else
       local interceptor = interceptors[param.coalitionId][param.requestingGroupName]
        if interceptor then
            trigger.action.outTextForGroup(param.groupId, "Target lost", 10, false)
            interceptor.target = nil
        end
    end
end
function bulls.cleanCallsignsLoop()
    for groupname, callsign in pairs(contactCallsigns) do
        local group = Group.getByName(groupname)
        if group == nil then
            contactCallsigns[groupname] = nil
        end
    end
    timer.scheduleFunction(bulls.cleanCallsignsLoop, nil, timer:getTime() + 63)
end
function bulls.cleanInterceptorsLoop()
    for i = 1, 2 do
        for groupName, values in pairs(interceptors[i]) do
            local group = Group.getByName(groupName)
            if group == nil then
                interceptors[i][groupName] = nil
            end
        end
    end
    timer.scheduleFunction(bulls.cleanInterceptorsLoop, nil, timer:getTime() + 63)
end
function bulls.vectorTargets(coalitionId)
    for i = 1, #groupsList[coalitionId] do
        for j = 1, #radioUnits[coalitionId] do
            local vectorString = bulls.pointsVector(bullsPoints[coalitionId], groupsList[coalitionId][i].groupName, radioDistanceUnits[coalitionId][radioUnits[coalitionId][j]], groupsList[coalitionId][i].isFriendly, 1, groupsList[coalitionId][i].callsign)
            if vectorString then
                local radioGroup = Group.getByName(radioUnits[coalitionId][j])
                if radioGroup then
                    local msg = {
                        id = 'TransmitMessage',
                        params = {
                        duration = 10,
                        subtitle = vectorString,
                        loop = false,
                        file ="l10n/DEFAULT/Alert.ogg",
                        }
                    }
                    radioGroup:getController():setCommand(msg)
                end
            end
        end
    end
    for j = 1, #radioUnits[coalitionId] do
        local radioGroup = Group.getByName(radioUnits[coalitionId][j])
        if radioGroup then
            local msg = {
                id = 'TransmitMessage',
                params = {
                duration = 10,
                subtitle = "\n---------------------------------------------------------------------------------------------\n",
                loop = false,
                file ="l10n/DEFAULT/Alert.ogg",
                }
            }
            radioGroup:getController():setCommand(msg)
        end
    end
    for i = 1, #friendliesList[coalitionId] do
        for j = 1, #radioUnits[coalitionId] do
            local vectorString = bulls.pointsVector(bullsPoints[coalitionId], friendliesList[coalitionId][i].groupName, radioDistanceUnits[coalitionId][radioUnits[coalitionId][j]], friendliesList[coalitionId][i].isFriendly, 1, friendliesList[coalitionId][i].callsign)
            if vectorString then
                local radioGroup = Group.getByName(radioUnits[coalitionId][j])
                if radioGroup then
                    local msg = {
                        id = 'TransmitMessage',
                        params = {
                        duration = 10,
                        subtitle = vectorString,
                        loop = false,
                        file ="l10n/DEFAULT/Alert.ogg",
                        }
                    }
                    radioGroup:getController():setCommand(msg)
                end
            end
        end
    end
end
function bulls.pointsVector(bullsPoint, targetGroupName, units, isFriendly, targetIndex, callsign)
    local targetGroup = Group.getByName(targetGroupName)
    if targetGroup then
        if targetIndex == nil then targetIndex = 1 end
        if targetIndex <= targetGroup:getSize() then
            local leadUnit = targetGroup:getUnit(targetIndex)
            if leadUnit then
                local targetType = unitTypes[leadUnit:getTypeName()]
                if targetType == nil then
                    targetType = "Unknown"
                end
                local targetPoint = leadUnit:getPoint()
                local targetPos = leadUnit:getPosition()
                if targetPoint and targetPos then
                    local vector = {x = targetPoint.x - bullsPoint.x, y = targetPoint.y - bullsPoint.y, z = targetPoint.z - bullsPoint.z}
                    ---@diagnostic disable-next-line: deprecated
                    local bearing = math.atan2(vector.z, vector.x)
                    if bearing < 0 then bearing = bearing + (2 * math.pi) end
                    local bearingInDeg = bearing * (180/math.pi)
                    local reverseBearingInDeg = bearingInDeg + 180
                    if reverseBearingInDeg > 360 then reverseBearingInDeg = reverseBearingInDeg - 360 end
                    --trigger.action.outText("Bearing from Tgt to Interceptor: " .. reverseBearingInDeg, 1)
                    ---@diagnostic disable-next-line: deprecated
                    local targetHeadingRad = math.atan2(targetPos.x.z, targetPos.x.x)
                    if targetHeadingRad < 0 then targetHeadingRad = targetHeadingRad + (2 * math.pi) end
                    local targetHeadingDeg = targetHeadingRad * (180/math.pi)
                    local targetHeadingCardinal = "North"
                    if targetHeadingDeg >= 22.5 and targetHeadingDeg < 67.5 then
                        targetHeadingCardinal = "Northeast"
                    elseif targetHeadingDeg >= 67.5 and targetHeadingDeg < 112.5 then
                        targetHeadingCardinal = "East"
                    elseif targetHeadingDeg >= 112.5 and targetHeadingDeg < 157.5 then
                        targetHeadingCardinal = "Southeast"
                    elseif targetHeadingDeg >= 157.5 and targetHeadingDeg < 202.5 then
                        targetHeadingCardinal = "South"
                    elseif targetHeadingDeg >= 202.5 and targetHeadingDeg < 247.5 then
                        targetHeadingCardinal = "Southwest"
                    elseif targetHeadingDeg >= 247.5 and targetHeadingDeg < 292.5 then
                        targetHeadingCardinal = "West"
                    elseif targetHeadingDeg >= 292.5 and targetHeadingDeg < 337.5 then
                        targetHeadingCardinal = "Northwest"
                    end
                    local xDistance = bullsPoint.x - targetPoint.x
                    local yDistance = bullsPoint.z - targetPoint.z
                    local distanceToTarget = tonumber(math.sqrt(xDistance*xDistance + yDistance*yDistance))
                    local distanceToTargetNM = tonumber(string.format("%.0f", distanceToTarget * 0.000539957))
                    local distanceToTargetString = string.format("%.0f",distanceToTarget/1000)

                    local targetAltInFt = targetPoint.y * 3.28084
                    local targetAltAngezls = math.floor(targetAltInFt/1000)
                    local altString = string.format("%.0f", math.floor(targetPoint.y/100)*100) .. 'm'
                    if units == "imperial" then
                        altString = "" .. string.format("%.0f", math.floor(targetAltInFt/100)*100) .. "ft"
                        distanceToTargetString = string.format("%.0f",distanceToTargetNM)
                    end
                    local bearingString = string.format("%.0f", bearingInDeg)
                    if string.len(bearingString) == 2 then
                        bearingString = "0"..bearingString
                    elseif string.len(bearingString) == 1 then
                        bearingString = "00"..bearingString
                    end
                    local bullsPrefix = ""
                    if isFriendly then
                        bullsPrefix = "FRIENDLY "
                    end
                    if callsign then
                        bullsPrefix = bullsPrefix .."("..callsign ..") "
                    end
                    local bullsString = "--BULLS " ..bullsPrefix..  bearingString .. "° for " .. distanceToTargetString .. " | " .. altString .. " | " .. targetHeadingCardinal .." | " .. targetType
                    if targetIndex <= targetGroup:getSize() and targetGroup:getSize() > 1 then
                        bullsPrefix = ""
                        if isFriendly then
                            bullsPrefix = "FRIENDLY "
                        end
                        if callsign then
                            bullsPrefix = bullsPrefix .."("..callsign .."-" ..targetIndex ..") "
                        end
                        bullsString = "--BULLS " ..bullsPrefix..  bearingString .. "° for " .. distanceToTargetString .. " | " .. altString .. " | " .. targetHeadingCardinal .." | " .. targetType
                        local nextUnit = targetGroup:getUnit(targetIndex+1)
                        if nextUnit then
                            local nextUnitPoint = nextUnit:getPoint()
                            if Utils.PointDistance(nextUnitPoint, targetPoint) > mergedRange then
                                bullsString = bullsString .. "\n" .. bulls.pointsVector(bullsPoint, targetGroupName, units, isFriendly, targetIndex+1, callsign)
                            end
                        end
                    end
                    return bullsString
                end
            end
        end
    end
end

function Bulls.getTargetsOnScope(coalitionId)
    return groupsList[coalitionId]
end

function Bulls.getTargetType(targetTypeName)
    local targetType = nil
    if unitTypes[targetTypeName] then targetType = unitTypes[targetTypeName] end
    return targetType
end

function bulls.checkForMergedContacts()
    -- run the distance check only once, as distances are symetric this halfs our execution set. also only run if at least one of the contacts is a player to further reduce execution set.
    -- this set is keyed on red group name so this needs to be remembered when unserialising.
    local distanceCache = {}
    for _, friendly in ipairs(friendliesList[1]) do
        local friendlyGroup = Group.getByName(friendly.groupName)
        if friendlyGroup then
            local friendlyUnit = friendlyGroup:getUnit(1)
            if friendlyUnit then
                local friendlyPlayer = Unit.getPlayerName(friendlyUnit)
                local friendlyPos = friendlyUnit:getPoint()
                if friendlyPos then
                    for _, enemy in ipairs(groupsList[1]) do 
                        local enemyGroup = Group.getByName(enemy.groupName)
                        if enemyGroup then
                            local enemyUnit = enemyGroup:getUnit(1)
                            if enemyUnit then
                                local enemyPlayer = Unit.getPlayerName(enemyUnit)
                                local enemyPos = enemyUnit:getPoint()
                                if enemyPos and (friendlyPlayer or enemyPlayer) then -- only calculate merges if one of the groups has a player in it, to save on performance and avoid spamming about AI only merges
                                    local dist = Utils.PointDistance(friendlyPos, enemyPos)
                                    if dist <= mergeRange then
                                        if not distanceCache[friendly.groupName] or dist < distanceCache[friendly.groupName].distance then
                                            distanceCache[friendly.groupName] = {
                                                distance = dist,
                                                friendlyGroupName = friendly.groupName,
                                                friendlyCallsign = friendly.callsign,
                                                enemyGroupName = enemy.groupName,
                                                enemyCallsign = enemy.callsign,
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for _, data in pairs(distanceCache) do
        for coalitionId = 1, 2 do
            local friendlyGroupName, enemyGroupName, friendlyCallsign, enemyCallsign
            if coalitionId == 1 then
                friendlyGroupName = data.friendlyGroupName
                enemyGroupName    = data.enemyGroupName
                friendlyCallsign  = data.friendlyCallsign
                enemyCallsign     = data.enemyCallsign
            else
                friendlyGroupName = data.enemyGroupName
                enemyGroupName    = data.friendlyGroupName
                friendlyCallsign  = data.enemyCallsign
                enemyCallsign     = data.friendlyCallsign
            end
            local mergeKey = coalitionId .. "|" .. friendlyGroupName .. "|" .. enemyGroupName
            if not activeMerges[mergeKey] or timer:getTime() >= activeMerges[mergeKey] then
                local braa = DF_UTILS.calculateBRAA({from = friendlyGroupName, to = enemyGroupName})
                if braa then
                    local bearingStr = string.format("%03d", math.floor(braa.bearingInDeg + 0.5))
                    local distStr, altStr
                    local friendlyGroup = Group.getByName(friendlyGroupName)
                    -- tailor callout to avionics units if possible, else fall back to nm
                    if friendlyGroup then
                        local friendlyUnit = friendlyGroup:getUnit(1)
                        if friendlyUnit then
                            local avionicsType = DF_UTILS.avionicsUnits[friendlyUnit:getTypeName()]
                            if avionicsType == "Metric" then
                                distStr = braa.distanceToTargetStringM .. "km"
                                altStr  = braa.altStringM
                            else
                                distStr = braa.distanceToTargetStringI .. "nm"
                                altStr  = braa.altStringI
                            end
                            local playerName = Unit.getPlayerName(friendlyUnit)
                            if playerName then
                                friendlyCallsign = playerName .. " (" .. friendlyCallsign .. ")"
                            end
                            local message = "\n> " .. friendlyCallsign .. " MERGED with (" .. enemyCallsign ..
                                ")\n   BRAA: " .. bearingStr .. " for " .. distStr .. ", " .. altStr .. ", " .. braa.aspectString
                            bulls.transmit({coalitionId = coalitionId, message = message})
                            env.info(friendlyCallsign .. " merged with " .. enemyCallsign, false)
                            activeMerges[mergeKey] = timer:getTime() + mergeDecayTime
                            bulls.alertNearbyFriendlies(coalitionId, friendlyGroupName, friendlyCallsign, enemyGroupName, enemyCallsign)
                        end
                    end
                end
            end
        end
    end
    -- expire decayed merge keys
    for key, expiry in pairs(activeMerges) do
        if timer:getTime() >= expiry then
            activeMerges[key] = nil
        end
    end
end
-- coalitionId, friendlyGroupName, friendlyCallsign, enemyGroupName, enemyCallsign
function bulls.alertNearbyFriendlies(coalitionId, friendlyGroupName, friendlyCallsign, enemyGroupName, enemyCallsign)
    local nearbyAlertRange = 10 * 1852
    local enemyGroupObj = Group.getByName(enemyGroupName)
    if not enemyGroupObj then return end
    local enemyUnit = enemyGroupObj:getUnit(1)
    if not enemyUnit then return end
    local enemyPos = enemyUnit:getPoint()
    env.info("Checking for friendlies within " .. (nearbyAlertRange/1852) .. " NM of merged contact to alert...", false)
    for _, nearbyFriendly in ipairs(friendliesList[coalitionId]) do
        if nearbyFriendly.groupName ~= friendlyGroupName then
            local nearbyGroup = Group.getByName(nearbyFriendly.groupName)
            if nearbyGroup then
                local nearbyUnit = nearbyGroup:getUnit(1)
                local nearbyFriendlyPlayer = nearbyUnit and Unit.getPlayerName(nearbyUnit)
                if nearbyFriendlyPlayer then
                    if Utils.PointDistance(nearbyUnit:getPoint(), enemyPos) <= nearbyAlertRange then
                        local nearbyBraa = DF_UTILS.calculateBRAA({from = nearbyFriendly.groupName, to = enemyGroupName})
                        if nearbyBraa then
                            local nearbyBearingStr = string.format("%03d", math.floor(nearbyBraa.bearingInDeg + 0.5))
                            local nearbyAvionics = DF_UTILS.avionicsUnits[nearbyUnit:getTypeName()]
                            local nearbyDistStr, nearbyAltStr
                            if nearbyAvionics == "Metric" then
                                nearbyDistStr = nearbyBraa.distanceToTargetStringM .. "km"
                                nearbyAltStr  = nearbyBraa.altStringM
                            else
                                nearbyDistStr = nearbyBraa.distanceToTargetStringI .. "nm"
                                nearbyAltStr  = nearbyBraa.altStringI
                            end
                            local alertMsg = "\n> " .. nearbyFriendlyPlayer .. ": Friendly " .. friendlyCallsign .. " near you is under attack by (" .. enemyCallsign ..
                                ")\n   BRAA " .. nearbyBearingStr .. " for " .. nearbyDistStr .. ", " .. nearbyAltStr .. ", " .. nearbyBraa.aspectString

                            env.info("Alerting " .. nearbyFriendlyPlayer .. " of merged contact engaging nearby friendly " .. friendlyCallsign .. " with enemy " .. enemyCallsign, false)
                            timer.scheduleFunction(bulls.transmit, {coalitionId = coalitionId, message = alertMsg}, timer:getTime() + 2)
                            return
                        end
                    end
                    env.info("Nearby friendly " .. nearbyFriendly.groupName .. " is not within alert range of enemy contact, no alert sent.", false)
                end
            end
        end
    end
end
function bulls.transmit(params)
    local coalitionId = params.coalitionId
    local message = params.message
    for _, radioUnitName in ipairs(radioUnits[coalitionId]) do
        local radioGroup = Group.getByName(radioUnitName)
        if radioGroup then
            local msg = {
                id = 'TransmitMessage',
                params = {
                    duration = 10,
                    subtitle = message,
                    loop = false,
                    file = "l10n/DEFAULT/Alert.ogg",
                }
            }
            radioGroup:getController():setCommand(msg)
        end
    end
end

bulls.getBulls()
bulls.getUnits()
bulls.getEWRs()
bulls.cleanCallsignsLoop()
Bulls.loop()
