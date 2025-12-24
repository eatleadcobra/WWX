local bulls = {}
local bullsRadius = 200000
local ewrRadius = 90000
local mergedRange = 300
local maxBullsUnits = 5
local maxEWRZones = 5
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
    ["C-130J-30"] = "Transport",
    ["MiG-19P"] = "Fighter",
    ["MiG-21Bis"] = "Fighter",
    ["MB-339A"] = "Attack",
    ["MiG-29 Fulcrum"] = "Fighter",
    ["M-2000C"] = "Fighter",
    ["Mirage-F1CE"] = "Fighter",
    ["Mirage-F1BE"] = "Fighter",
    ["Mirage-F1EE"] = "Fighter",
    ["AJS37"] = "Attack",
    ["JF-17"] = "Fighter",
    ["Su-25"] = "Attack",
    ["Su-25T"] = "Attack",
    ["Yak-52"] = "Single engine prop",
    ["L-39ZA"] = "Attack",
    ["A-10A"] = "Attack",
    ["A-10C"] = "Attack",
    ["A-10C_2"] = "Attack",
    ["AV8BNA"] = "Attack",
    ["C-101CC"] = "Attack",
    ["F-4E-45MC"] = "Fighter",
    ["F-5E-3"] = "Fighter",
    ["F-5E-3_FC"] = "Fighter",
    ["F-15ESE"] = "Fighter",
    ["F-16C_50"] = "Fighter",
    ["C-101EB"] = "Attack",
    ["F4U-1D"] = "Single-engine prop",
    ["MosquitoFBMkVI"] = "Multi-engine prop",
    ["F-86F Sabre"] = "Fighter",
    ["F-86F_FC"] = "Fighter",
    ["F-14A-135-GR-Early"] = "Fighter",
    ["F-14A-135-GR"] = "Fighter",
    ["F-14B"] = "Fighter",
    ["B-1B"] = "Bomber",
    ["Tu-22M3"] = "Bomber",
    ["Tornado IDS"] = "Bomber",
    ["Su-24M"] = "Bomber",
    ["A-20G"] = "Bomber",
    ["A-6E"] = "Attack"

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
    bulls.getTargets(1)
    bulls.vectorTargets(1)
    bulls.getTargets(2)
    bulls.vectorTargets(2)
    bulls.populateInterceptMenus()
    groupsList[1] = {}
    groupsList[2] = {}
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
                                    interceptors[foundItem:getCoalition()][foundGroupName] = { groupName = foundGroupName, groupId = foundGroup:getID(), cancelGuidance = false, target = nil}
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
function bulls.populateInterceptMenus()
    for i = 1, 2 do
        for groupName, values in pairs(interceptors[i]) do
            missionCommands.removeItemForGroup(values.groupId, {[1] = "Intercept Controller"})
            local interceptMenu = missionCommands.addSubMenuForGroup(values.groupId, "Intercept Controller", nil)
            for j = 1, 9 do
                if groupsList[i][j] and groupsList[i][j].callsign and groupsList[i][j].groupName then
                    --missionCommands.removeItemForGroup(values.groupId, {[1] = "Intercept Controller", [2] = "Request vectors to " .. groupsList[i][j].callsign })
                    missionCommands.addCommandForGroup(values.groupId, "Request vectors to " .. groupsList[i][j].callsign, interceptMenu, bulls.BRAALoop, {coalitionId = i, groupId = values.groupId, requestingGroupName = groupName, targetGroupName = groupsList[i][j].groupName, targetCallsign =  groupsList[i][j].callsign})
                else
                    break
                end
            end
            missionCommands.addCommandForGroup(values.groupId, "Cancel Guidance", interceptMenu, bulls.cancelGuidance, {coalitionId = i, groupName = groupName, groupId = values.groupId})
        end
    end
end
--coalitionId, groupName
function bulls.cancelGuidance(param)
    trigger.action.outTextForGroup(param.groupId, "Standby...", 5, false)
    interceptors[param.coalitionId][param.groupName].cancelGuidance = true
    interceptors[param.coalitionId][param.groupName].target = nil
    timer.scheduleFunction(bulls.resumeGuidance, param, timer:getTime() + 7)
end
function bulls.resumeGuidance(param)
    trigger.action.outTextForGroup(param.groupId, "Guidance request cleared.", 5, false)
    interceptors[param.coalitionId][param.groupName].cancelGuidance = false
end
--requestingGroupName, targetGroupName
function bulls.BRAA(param)
    DF_UTILS.vector({from = param.requestingGroupName, to = param.targetGroupName, units = param.units, targetCallsign = param.targetCallsign})
end
--coalitionId, groupId, requestingGroupName, targetGroupName
function bulls.BRAALoop(param)
    if Group.getByName(param.targetGroupName) then
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
        for groupname, values in pairs(interceptors[i]) do
            local group = Group.getByName(groupname)
            if group == nil then
                interceptors[i][groupname] = nil
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
                    elseif string.len(bearingString) == 2 then
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
bulls.getBulls()
bulls.getUnits()
bulls.getEWRs()
bulls.cleanCallsignsLoop()
Bulls.loop()