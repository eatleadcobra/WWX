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
local radioUnits = {
    [1] = {},
    [2] = {},
}
local radioDistanceUnits = {
    [1] = {},
    [2] = {}
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
        },
        [2] = {
            [1] = "Blackjack",
            [2] = "Lancer",
            [3] = "Wasp",
            [4] = "Patriot",
            [5] = "Wichita",
            [6] = "Domino"
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
    local callsign = bulls.callsigns.alphanumerics[coalitionId][bulls.callsigns.counts[coalitionId].alpha] .. "-" .. bulls.callsigns.counts[coalitionId].number
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
    groupsList[1] = {}
    bulls.getTargets(2)
    bulls.vectorTargets(2)
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
            if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 0 and foundItem:getPoint().y > 0 then
                local isFriendly = false
                if foundItem:getCoalition() == coalitionId then
                    isFriendly = true
                end
                if land.isVisible({x = ewrPoint.x, y = land.getHeight({x = ewrPoint.x, y = ewrPoint.z}) + 10, z = ewrPoint.z}, foundItem:getPoint()) then
                    local foundGroup = foundItem:getGroup()
                    if foundGroup then
                        local foundGroupName = foundGroup:getName()
                        if (targetGroupName and foundGroupName == targetGroupName) or targetGroupName == nil then
                            if #foundGroups < 1 then
                                local groupCallsign = contactCallsigns[foundGroupName]
                                if isFriendly then
                                    if groupCallsign == nil then
                                        groupCallsign = bulls.newCallsign(coalitionId)
                                        contactCallsigns[foundGroupName] = groupCallsign
                                        trigger.action.outTextForGroup(foundGroup:getID(), "Your callsign is " .. groupCallsign, 60, false)
                                    end
                                end
                                foundGroups[#foundGroups+1] = {groupName = foundGroupName, isFriendly = isFriendly, callsign = groupCallsign}
                            else
                                local alreadyFound = false
                                for i = 1, #foundGroups do
                                    if foundGroups[i].groupName == foundGroupName then
                                        alreadyFound = true
                                    end
                                end
                                if alreadyFound == false then
                                    local groupCallsign = contactCallsigns[foundGroupName]
                                    if isFriendly then
                                        if groupCallsign == nil then
                                            groupCallsign = bulls.newCallsign(coalitionId)
                                            contactCallsigns[foundGroupName] = groupCallsign
                                            trigger.action.outTextForGroup(foundGroup:getID(), "Your callsign is " .. groupCallsign, 60, false)
                                        end
                                    end
                                    foundGroups[#foundGroups+1] = {groupName = foundGroupName, isFriendly = isFriendly, callsign = groupCallsign}
                                end
                            end
                        end
                    end
                end
            end
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        groupsList[coalitionId] = foundGroups
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
function bulls.vectorTargets(coalitionId)
    for i = 1, #groupsList[coalitionId] do
        for j = 1, #radioUnits[coalitionId] do
            local vectorString = bulls.pointsVector(bullsPoints[coalitionId], groupsList[coalitionId][i].groupName, radioDistanceUnits[coalitionId][radioUnits[coalitionId][j]], groupsList[coalitionId][i].isFriendly, 1, groupsList[coalitionId][i].callsign)
            if vectorString then
                --trigger.action.outText("radio group: " .. radioUnits[coalitionId][j], 5)
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
                local targetType = "Fighter"
                if leadUnit:hasAttribute("Bombers") then
                    targetType = "Bomber"
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
                    if targetIndex < targetGroup:getSize() then
                        local nextUnit = targetGroup:getUnit(targetIndex+1)
                        if nextUnit then
                            local nextUnitPoint = nextUnit:getPoint()
                            if Utils.PointDistance(nextUnitPoint, targetPoint) > mergedRange then
                                local subUnitCallsign = nil
                                if callsign then
                                    subUnitCallsign = callsign .. "-targetIndex"
                                end
                                bullsString = bullsString .. "\n" .. bulls.pointsVector(bullsPoint, targetGroupName, units, isFriendly, targetIndex + 1, subUnitCallsign)
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