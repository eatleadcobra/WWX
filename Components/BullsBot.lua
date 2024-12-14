local bulls = {}
local bullsRadius = 200000
Bulls = {}
local bullsPoints = {
    [1] = {},
    [2] = {}
}
local groupsList = {
    [1] = {},
    [2] = {},
}
local radioUnits = {
    [1] = {
        [1] = "RedBulls-1",
        [2] = "RedBulls-2",
        [3] = "RedBulls-3",
        [4] = "RedBulls-4"
    },
    [2] = {
        [1] = "BlueBulls-1",
        [2] = "BlueBulls-2",
        [3] = "BlueBulls-3",
    },
}
local radioDistanceUnits = {
    [1] = {
        ["RedBulls-1"] = "imperial",
        ["RedBulls-2"] = "imperial",
        ["RedBulls-3"] = "metric",
        ["RedBulls-4"] = "metric",
    },
    [2] = {
        ["BlueBulls-1"] = "imperial",
        ["BlueBulls-2"] = "imperial",
        ["BlueBulls-3"] = "metric",
        ["BlueBulls-4"] = "metric",
    }
}
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
function bulls.getTargets(coalitionId, targetGroupName)
    local foundGroups = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = bullsPoints[coalitionId],
            radius = bullsRadius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 0 and foundItem:getPoint().y > 0 then
            local isFriendly = false
            if foundItem:getCoalition() == coalitionId then
                isFriendly = true
            end
            if land.isVisible({x = bullsPoints[coalitionId].x, y = land.getHeight({x = bullsPoints[coalitionId].x, y = bullsPoints[coalitionId].z}) + 10, z = bullsPoints[coalitionId].z}, foundItem:getPoint()) then
                local foundGroup = foundItem:getGroup()
                if foundGroup then
                    local foundGroupName = foundGroup:getName()
                    if (targetGroupName and foundGroupName == targetGroupName) or targetGroupName == nil then
                        if #foundGroups < 1 then
                            foundGroups[#foundGroups+1] = {groupName = foundGroupName, isFriendly = isFriendly}
                        else
                            local alreadyFound = false
                            for i = 1, #foundGroups do
                                if foundGroups[i].groupName == foundGroupName then
                                    alreadyFound = true
                                end
                            end
                            if alreadyFound == false then
                                foundGroups[#foundGroups+1] = {groupName = foundGroupName, isFriendly = isFriendly}
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
function bulls.vectorTargets(coalitionId)
    for i = 1, #groupsList[coalitionId] do
        for j = 1, #radioUnits[coalitionId] do
            local vectorString = bulls.pointsVector(bullsPoints[coalitionId], groupsList[coalitionId][i].groupName, radioDistanceUnits[coalitionId][radioUnits[coalitionId][j]], groupsList[coalitionId][i].isFriendly)
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
function bulls.pointsVector(bullsPoint, targetGroupName, units, isFriendly)
    local targetGroup = Group.getByName(targetGroupName)
    if targetGroup then
        local leadUnit = targetGroup:getUnit(1)
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
                local targetAltAngels = math.floor(targetAltInFt/1000)
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
                local bullsString = "--BULLS " ..bullsPrefix..  bearingString .. "° for " .. distanceToTargetString .. " | " .. altString .. " | " .. targetHeadingCardinal .." | " .. targetType
                return bullsString
            end
        end
    end
end
bulls.getBulls()
Bulls.loop()