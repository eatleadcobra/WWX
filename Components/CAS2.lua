-- track a group, allow configuration of what kind of coordinator is present (none v jtac) and what designation is available (none, pave penny, LGB guidance)-- function to follow a group

CAS = {}
CAS.JTACType = {
    NONE = 1,
    JTAC = 2,
    JTAC_DESIGNATOR = 3,
}
local cas = {}
local groups = {

}
cas.loopInterval = 4
cas.battleLoopInterval = 9
cas.engagementDistance = 3000
cas.dangerClose = 1200
function CAS.followGroup(coalitionId, groupName, jtacType)
    trigger.action.outText("following group: " .. groupName, 10, false)
    groups[groupName] = { currentPoint = {}, coalitionId = coalitionId, groupName = groupName, jtacType = jtacType, followStartTime = timer:getTime(), inContact = false, contactStartTime = -1, isMoving = false, targetGroups = {}, smokeTime = -1}
end
function cas.loop()
    for groupName, groupInfo in pairs(groups) do
        trigger.action.outText("looping group: " .. groupName, cas.loopInterval, false)
        local group = Group.getByName(groupName)
        if group then
            cas.checkGroup(groupName)
        else
            groups[groupName] = nil
        end
    end
    timer.scheduleFunction(cas.loop, nil, timer:getTime() + cas.loopInterval)
end
function cas.checkGroup(groupName)
    local checkingGroup = Group.getByName(groupName)
    if checkingGroup then
        local checkingUnit = checkingGroup:getUnit(1)
        if checkingUnit then
            local checkingPoint = checkingUnit:getPoint()
            groups[groupName].isMoving = Utils.getSpeed(checkingUnit:getVelocity()) > 0.1
            if checkingPoint then
                groups[groupName].currentPoint = checkingPoint
                local cgController = checkingGroup:getController()
                if cgController then
                    local detectedEnemies = cgController:getDetectedTargets(Controller.Detection.VISUAL,Controller.Detection.OPTIC)
                    local detectedGroups = {}
                    if #detectedEnemies > 0 then
                        for i = 1, #detectedEnemies do
                            if detectedEnemies[i].object:getDesc().category == 2 and detectedEnemies[i].object:hasAttribute("Armed vehicles") then
                                trigger.action.outText("ground unit detected", cas.loopInterval, false)
                                detectedGroups[detectedEnemies[i].object:getGroup():getName()] = 1
                            end
                        end
                        for k,v in pairs(detectedGroups) do
                            local detectedGroup = Group.getByName(k)
                            if detectedGroup then
                                local leadDetectedUnit = detectedGroup:getUnit(1)
                                if leadDetectedUnit then
                                    local leadPoint = leadDetectedUnit:getPoint()
                                    if leadPoint then
                                        local detectedDistance = Utils.PointDistance(checkingPoint, leadPoint)
                                        local bearingToTgt = Utils.GetBearingDeg(checkingPoint, leadPoint)
                                        if detectedDistance <= cas.engagementDistance then
                                            trigger.action.outText("in range " .. k, 10, false)
                                            groups[groupName].targetGroups[k] = { distanceToTgt = detectedDistance, bearingToTgt = bearingToTgt}
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
end

function cas.designationLoop()
    trigger.action.outText("Des loop", 5, false)
    for k,v in pairs(groups) do
        trigger.action.outText("group: " .. k  ..": ".. #v.targetGroups .. " targets: " .. Utils.dump(v.targetGroups), 5, false)

        local targetCount = #v.targetGroups
        local targetCountString = targetCount .. " enemy groups "
        if targetCount == 1 then targetCountString = " one enemy group " end
        local casMessage = "This is " .. k .. ". We are in contact with" .. targetCountString
        local locationMessage = "\nWe are located at "
        local groupLat, groupLong, groupAlt = coord.LOtoLL(v.currentPoint)
        local groupMGRS = coord.LLtoMGRS(groupLat, groupLong)
        local eastingString = tostring(groupMGRS.Easting)
        local northingString = tostring(groupMGRS.Northing)
        for i = 1, 5 - #eastingString do
            eastingString = tostring(0)..eastingString
        end
        for i = 1, 5 - #northingString do
            northingString = tostring(0)..northingString
        end
        local location = groupMGRS.MGRSDigraph .. eastingString:sub(1,2)..northingString:sub(1,2)
        locationMessage = locationMessage .. location
        if v.isMoving then
            locationMessage = locationMessage .. "\nWe are on the move."
        end
        casMessage = casMessage .. locationMessage
        local groupCount = 1
        for group, targetInfo in pairs(v.targetGroups) do
            local tgtGroup = Group.getByName(group)
            if tgtGroup then
                local bearingToTgt = math.floor(targetInfo.bearingToTgt)
                local distanceToTgt = targetInfo.distanceToTgt / 1000
                casMessage = casMessage .. "\nGroup " .. groupCount .. ": Bearing: " .. bearingToTgt .. " for " .. string.format("%.1f", distanceToTgt) .. "km"
                if v.isMoving == false and distanceToTgt < cas.dangerClose then
                    casMessage = casMessage .. "\nEnemy is danger close! Our position is marked with smoke."
                    if v.smokeTime == -1 or timer:getTime() - v.smokeTime > 300 then
                        trigger.action.smoke(v.currentPoint, v.coalitionId)
                        v.smokeTime = timer:getTime()
                    end
                end
                groupCount = groupCount + 1
            else
                groupCount = groupCount - 1
                trigger.action.outText("Target destroyed!", 30, false)
                v.targetGroups[group] = nil
            end
        end
        if groupCount > 0 then
            trigger.action.outText(casMessage, 30, false)
        end
    end
    timer.scheduleFunction(cas.designationLoop, nil, timer:getTime() + 5)
end

cas.loop()
cas.designationLoop()
CAS.followGroup(2, "test", CAS.JTACType.NONE)

--assert(loadfile("F:\\Games\\WWX\\Components\\CAS2.lua"))()