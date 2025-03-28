DFSubs = {}
DFSubs.subs = {
    [1] = {},
    [2] = {}
}
local subRespawnTime = 600
local maxSubRuninDistance = 4500
--coalitionId subtype
function DFSubs.initSub(param)
    if param.subType == nil then param.subType = "santafe" end
    local initZone = math.random(1,7)
    local startZone = param.coalitionId.."-sub-start-"..initZone
    local endZone = param.coalitionId.."-sub-end-"..initZone
    local startPoint = trigger.misc.getZone(startZone).point
    local endPoint = trigger.misc.getZone(endZone).point
    local interceptSpeed = SubControl.subValues[param.subType].maxSpeed
    if startPoint and endPoint and interceptSpeed then
        local closestShip = SubTools.findClosestShip(startPoint, param.coalitionId, interceptSpeed)
        if closestShip.distance then
            local spawnedSubName, runInPoint = SubControl.createSubWithIntercept(param.coalitionId, startPoint, param.subType, nil, closestShip)
            DFSubs.subs[param.coalitionId] = { groupName = spawnedSubName, subType = param.subType, intercepting = true, damaged = false, spawnTime = timer:getTime(), kills = 0, runInPoint = runInPoint }
        else
            local spawnedSubName = SubControl.createSubWithNoIntercept(param.coalitionId, startPoint,  endPoint, param.subType, nil, nil)
            DFSubs.subs[param.coalitionId] = { groupName = spawnedSubName, subType = param.subType, intercepting = false, damaged = false, spawnTime = timer:getTime(), kills = 0, runInPoint = nil}
        end
    else
        env.info("No valid start and end point found for submarine. Coalition: " .. param.coalitionId .. " Zones: Start: " .. startZone .. " End: " .. endZone, false)
    end
    timer.scheduleFunction(DFSubs.subLoop, param.coalitionId, timer:getTime() + 60)
end
function DFSubs.subDamaged(coalitionId)
    env.info("sub damaged", false)
    local groupName = DFSubs.subs[coalitionId].groupName
    local subGroup = Group.getByName(groupName)
    if subGroup then
        local subUnit = subGroup:getUnit(1)
        if subUnit then
            local currentPoint = subUnit:getPoint()
            local currentDepth = currentPoint.y
            local endPoint = trigger.misc.getZone(coalitionId.."-sub-end-"..math.random(1,7)).point
            if endPoint then
                SubControl.updateSubMissionWithNoIntercept(groupName, currentPoint, endPoint, DFSubs.subs[coalitionId].subType, currentDepth, 0)
                DFSubs.subs[coalitionId].intercepting = false
                DFSubs.subs[coalitionId].damaged = true
            end
        end
    end
end
function DFSubs.subSearch(coalitionId)
    local sub = DFSubs.subs[coalitionId]
    local groupName = sub.groupName
    local subGroup = Group.getByName(groupName)
    if subGroup then
        local subUnit = subGroup:getUnit(1)
        if subUnit then
            local currentPoint = subUnit:getPoint()
            local currentDepth = currentPoint.y
            local closestShip = SubTools.findClosestShip(currentPoint, coalitionId, SubControl.subValues[sub.subType].maxSpeed)
            if closestShip.distance then
                SubControl.updateSubMissionWithIntercept(groupName, currentPoint, sub.subType, currentDepth, closestShip)
                env.info(coalitionId.."-sub reassigned with target", false)
                DFSubs.subs[coalitionId].intercepting = true
            end
        end
    end
end
function DFSubs.subLoop(coalitionId)
    local sub = DFSubs.subs[coalitionId]
    --groupName subType intercepting damaged spawnTime , kills = 0
    env.info(coalitionId .."-sub loop. Kills: " .. DFSubs.subs[coalitionId].kills .. " subType: " .. DFSubs.subs[coalitionId].subType.. " intercepting: " .. tostring(DFSubs.subs[coalitionId].intercepting).. " damaged: " .. tostring(DFSubs.subs[coalitionId].damaged), false)
    local groupName = sub.groupName
    local subGroup = Group.getByName(groupName)
    if subGroup then
        local subUnit = subGroup:getUnit(1)
        if subUnit then
            if sub.intercepting then
                --check if complete
                local taskComplete = false
                if Utils.getSpeed(subUnit:getVelocity()) < 1 then
                    taskComplete = true
                end
                local onAttackRun = false
                if subUnit:getPoint().y <= SubControl.subValues[sub.subType].periscopeDepth then
                    onAttackRun = true
                end
                if onAttackRun then
                    sub.kills = sub.kills + SubControl.engage(coalitionId, groupName)
                end
                local distanceFromRunIn = 0
                if onAttackRun then
                    local subPoint = subUnit:getPoint()
                    local runInPoint = DFSubs.subs[coalitionId].runInPoint
                    if subPoint and runInPoint then
                        distanceFromRunIn = Utils.PointDistance(subPoint, runInPoint)
                    end
                end
                if taskComplete or (onAttackRun and (distanceFromRunIn > maxSubRuninDistance)) then
                    local currentPoint = subUnit:getPoint()
                    if currentPoint then
                        local currentDepth = currentPoint.y
                        local endZone = coalitionId.."-sub-end-"..math.random(1,7)
                        env.info(coalitionId.."-sub task completed: moving to " .. endZone, false)
                        local endPoint = trigger.misc.getZone(endZone).point
                        if endPoint then
                            SubControl.updateSubMissionWithNoIntercept(groupName, currentPoint, endPoint, sub.subType, currentDepth)
                            DFSubs.subs[coalitionId].intercepting = false
                        end
                    end
                end
            elseif sub.damaged == false then
                DFSubs.subSearch(coalitionId)
            elseif Utils.getSpeed(subUnit:getVelocity()) < 1 then
                env.info(coalitionId.."-sub stuck in place. Kills: " .. sub.kills, false)
                subUnit:destroy()
                timer.scheduleFunction(DFSubs.initSub, {coalitionId = coalitionId, subType = sub.subType}, timer:getTime() + 10)
            end
            timer.scheduleFunction(DFSubs.subLoop, coalitionId, timer:getTime() + 30)
        else
            env.info(coalitionId.."-sub dead. Kills: " .. sub.kills, false)
            timer.scheduleFunction(DFSubs.initSub, {coalitionId = coalitionId, subType = sub.subType}, timer:getTime() + subRespawnTime)
        end
    else
        env.info(coalitionId.."-sub dead. Kills: " .. sub.kills, false)
        timer.scheduleFunction(DFSubs.initSub,  {coalitionId = coalitionId, subType = sub.subType}, timer:getTime() + subRespawnTime)
    end
end