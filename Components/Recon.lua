-- Requires Utils/utils.lua
-- Requires Utils/drawingTools.lua
Recon = {}
local recon = {}
local reconParams = {
    pointRadius = 1000,
    minAGL = 610,
    maxAGL = 3049,
    maxPitch = 0.18,
    maxRoll = 0.27
}
local maxCaptures = 4
local missionTypes = {
    [1] = "BDA",
    [2] = "Suspected Enemy Location",
    [3] = "Convoy",
    [4] = "BP"
}
local missionIdCounter = 1
local missionExpireTime = 3600
local missionTemplate = {
    id = 0,
    type = 1,
    coalition = 1,
    point = {},
    groupName = nil,
    capturedBy = nil,
    markId = 0
}
local captures = {}
local currentMissions = {
    [1] = {
    },
    [2] = {
    },
}
local reconJetTypes = {
    ["Yak-52"] = 1,
    ["TF-51D"] = 1,
}
local currentReconJets = {

}
local reconGroupIdentifier = "RECON"
local reconEvents = {}
function reconEvents:onEvent(event)
    if event.id == world.event.S_EVENT_TAKEOFF then
        if  event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local groupName = group:getName()
                if string.find(groupName, reconGroupIdentifier) or reconJetTypes[event.initiator:getTypeName()] then
                    currentReconJets[groupName] = group:getID()
                    trigger.action.outTextForGroup(group:getID(), "Valid recon flight being tracked.", 10, false)
                    trigger.action.outTextForGroup(group:getID(), "Recon parameters:\nMax Roll: " .. math.floor(math.deg(reconParams.maxRoll)).."°\nMax Pitch: " .. math.floor(math.deg(reconParams.maxPitch)) .. "°\nMax AGL: " .. math.floor(3.28*reconParams.maxAGL).."ft".."\nMin AGL: " .. math.floor(3.28*reconParams.minAGL).."ft" , 30, false)
                    recon.trackReconJet(groupName)
                end
            end
        end
    end
    if event.id == world.event.S_EVENT_LAND then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local groupName = group:getName()
                if string.find(groupName, reconGroupIdentifier) or reconJetTypes[event.initiator:getTypeName()] then
                    currentReconJets[group:getName()] = nil
                    local unit = group:getUnit(1)
                    if unit then
                        local player = unit:getPlayerName()
                        if player and event.place and event.place and event.place.getCoalition and event.place:getCoalition() == group:getCoalition() and event.place:getDesc().category == 0 then
                            recon.processPlayerFilm(group:getCoalition(), player, group:getID())
                        end
                    end
                end
            end
        end
    end
    --on death or slot out 
    if event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_EJECTION  or event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                currentReconJets[group:getName()] = nil
                local unit = group:getUnit(1)
                if unit then
                    local player = unit:getPlayerName()
                    if player then
                        recon.purgePlayerCaptures(group:getCoalition(), player)
                    end
                end
            end
        end
    end
end
world.addEventHandler(reconEvents)
function recon.newBaseMission(coalitionId, missionPoint)
    env.info("Creating Base Mission",false)
    local newMissionId = recon.getNewMissionId()
    local newMission = Utils.deepcopy(missionTemplate)
    newMission.id = newMissionId
    newMission.coalitionId = coalitionId
    newMission.point = missionPoint
    env.info("Base Mission Created", false)
    timer.scheduleFunction(recon.destroyMission, {coalitionId = coalitionId, missionId = newMissionId}, timer:getTime() + missionExpireTime)
    return newMission
end
function Recon.createBDAMission(coalitionId, bdaPoint)
    env.info("Creating BDA Mission", false)
    local missionMarkId = DrawingTools.newMarkId()
    trigger.action.circleToAll(coalitionId, missionMarkId, bdaPoint, reconParams.pointRadius, {0.3,1,0,1}, {0,0,0,0.2}, 4, true, nil)
    local newMission = recon.newBaseMission(coalitionId, bdaPoint)
    newMission.type = 1
    newMission.markId = missionMarkId
    currentMissions[coalitionId][newMission.id] = newMission
    env.info("BDA Mission Created", false)
    return newMission.id
end
function Recon.createEnemyLocationMission(coalitionId, missionPoint, missionGroupName)
    env.info("Creating Enemy Location Mission", false)
    local missionMarkId = DrawingTools.newMarkId()
    missionPoint.x = missionPoint.x + math.random(-300, 300)
    missionPoint.z = missionPoint.z + math.random(-300, 300)
    trigger.action.circleToAll(coalitionId, missionMarkId, missionPoint, reconParams.pointRadius, {0.3,1,0,1}, {0,0,0,0.2}, 3, true, nil)
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.groupName = missionGroupName
    newMission.type = 2
    newMission.markId = missionMarkId
    currentMissions[coalitionId][newMission.id] = newMission
    env.info("Enemy Location Mission Created", false)
    return newMission.id
end
function Recon.createBPScoutingMission(coalitionId, missionPoint, bp)
    env.info("Creating Battle Position Scouting Mission", false)
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.type = 4
    newMission.bp = bp
    currentMissions[coalitionId][newMission.id] = newMission
    env.info("Battle Position Scouting Mission Created", false)
    return newMission.id
end

function Recon.createEnemyLocationMissionNoMarker(coalitionId, missionPoint, missionGroupName)
    env.info("Creating Enemy Location Mission No Marker", false)
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.groupName = missionGroupName
    newMission.type = 2
    currentMissions[coalitionId][newMission.id] = newMission
    env.info("Enemy Location Mission Created No Marker", false)
    return newMission.id
end
function Recon.createConvoyLocationMission(coalitionId, convoyGroupName)
    
end
function recon.trackReconJet(reconGroupName)
    if currentReconJets[reconGroupName] then
        local reconGroup = Group.getByName(reconGroupName)
        if reconGroup then
            local reconUnit = reconGroup:getUnit(1)
            if reconUnit then
                local reconCoalition = reconUnit:getCoalition()
                local reconPoint = reconUnit:getPoint()
                local reconPos = reconUnit:getPosition()
                if reconPoint and reconPos and recon.inParams(reconPos, reconPoint) then
                    local closestMission = recon.getMissionInCaptureRange(reconCoalition, reconPoint)
                    if closestMission ~= -1 then
                        recon.captureMission(closestMission, reconUnit:getPlayerName(), reconCoalition, reconGroup:getID())
                    end
                end
                timer.scheduleFunction(recon.trackReconJet, reconGroupName, timer:getTime() + 0.5)
            end
        end
    end
end
function recon.inParams(position, point)
    local pitch = math.abs(math.asin(position.x.y))
    local roll = math.abs(math.atan2(-position.z.y, position.y.y))
    local AGL = Utils.getAGL(point)
    --trigger.action.outText("Pitch: " .. pitch .. " Roll: " .. roll .. " AGL: " .. AGL, 1, false)
    if pitch < reconParams.maxPitch and roll < reconParams.maxRoll and (reconParams.minAGL < AGL and AGL < reconParams.maxAGL ) then
        --trigger.action.outText("In params", 1, false)
        return true
    else
        return false
    end
end
function recon.getMissionInCaptureRange(coalitionId, playerPoint)
    local closestDistance = 1000000
    local closestMissionId = -1
    for k,v in pairs(currentMissions[coalitionId]) do
        local missionPoint = v.point
        local distanceToMission = Utils.PointDistance(playerPoint, missionPoint)
        if distanceToMission < reconParams.pointRadius and v.capturedBy == nil then
            if distanceToMission < closestDistance then
                closestDistance = distanceToMission
                closestMissionId = k
            end
        end
    end
    return closestMissionId
end
function recon.captureMission(missionId, playerName, coalitionId, playerGroupId)
    env.info(playerName.." Capturing Mission: " .. missionId, false)
    if captures[playerName] == nil then
        captures[playerName] = {}
    end
    if #captures[playerName] < maxCaptures then
        captures[playerName][missionId] = {coalitionId = coalitionId, missionId = missionId, captureTime = timer:getTime()}
        currentMissions[coalitionId][missionId].capturedBy = playerName
        trigger.action.outTextForGroup(playerGroupId, "Mission Captured Successfully!", 10, false)
        if #captures[playerName] >= maxCaptures then
            trigger.action.outTextForGroup(playerGroupId, "You are out of film. RTB to deliver your photos and collect more film!", 15, false)
        end
    else
        trigger.action.outTextForGroup(playerGroupId, "You are out of film. RTB to deliver your photos and collect more film!", 15, false)
    end
end
function recon.purgePlayerCaptures(coalitionId, playerName)
    if captures[playerName] and #captures[playerName] ~= nil then
        for k,v in pairs (captures[playerName]) do
            local mission = currentMissions[coalitionId][v.missionId]
            if mission then
            mission.capturedBy = nil
            end
        end
        captures[playerName] = nil
    end
end
function recon.processPlayerFilm(coalitionId, playerName, playerGroupId)
    --trigger.action.outText("Processing Film For " .. playerName, 5, false)
    if captures[playerName] then
        for k,v in pairs (captures[playerName]) do
            if v.missionId then
                recon.processCompletedMission(coalitionId, v.missionId, playerGroupId)
            else
                env.info("processing mission failed, no id", false)
            end
        end
        --recon.purgePlayerCaptures(coalitionId, playerName)
    end
end
function recon.processCompletedMission(coalitionId, missionId, playerGroupId)
    env.info("Processing Completed Mission " .. missionId, false)
    local mission = currentMissions[coalitionId][missionId]
    if mission then
        local completedBy = mission.capturedBy
        local missionType = mission.type
        env.info("completedBy: " .. completedBy .. " missionType: " .. missionTypes[missionType], false)
        if missionType == 1 then
            recon.processBDA(mission, playerGroupId)
        elseif missionType == 2 then
            recon.processLocation(mission, playerGroupId)
        elseif missionType == 3 then

        elseif missionType == 4 then
            recon.processBP(mission, playerGroupId)
        end
        recon.cleanMission(coalitionId, missionId)
    end
end
function recon.cleanMission(coalitionId, missionId)
    env.info("cleaning mission", false)
    local missionMarkId = currentMissions[coalitionId][missionId].markId
    local capturedBy = currentMissions[coalitionId][missionId].capturedBy
    if capturedBy then
        captures[capturedBy][missionId] = nil
    end
    if missionMarkId then
        env.info("removing mark", false)
        trigger.action.removeMark(missionMarkId)
    end
    currentMissions[coalitionId][missionId] = nil
end
--coalitionId, missionId
function recon.destroyMission(param)
    local missionToDestroy = currentMissions[param.coalitionId][param.missionId]
    if missionToDestroy then
        local missionCaptured = missionToDestroy.capturedBy ~= nil
        if missionCaptured and captures[missionToDestroy.capturedBy] then
            timer.scheduleFunction(recon.destroyMission, param, timer:getTime() + missionExpireTime/4)
            return
        else
            env.info("Destroying recon mission: " .. param.missionId, false)
            recon.cleanMission(param.coalitionId, param.missionId)
        end
    end
end
function recon.processBDA(mission, playerGroupId)
    env.info("Processing BDA Mission", false)
    local enemyCoalition = 1
    if mission.coalitionId == 1 then enemyCoalition = 2 end
    if DFS then
        DFS.status[enemyCoalition].health = DFS.status[enemyCoalition].health - 1
    end
    trigger.action.outTextForGroup(playerGroupId, "BDA Mission Completed!", 5, false)
end
function recon.processLocation(mission, playerGroupId)
    env.info("Processing Location Mission", false)
    local discoveredGroupName = mission.groupName
    env.info("discoveredGroupName: " ..  discoveredGroupName, false)
    local discoveredGroup = Group.getByName(discoveredGroupName)
    if discoveredGroup then
        for i = 1, discoveredGroup:getSize() do
            local markingUnit = discoveredGroup:getUnit(i)
            if markingUnit then
                env.info("drawing marks", false)
                local markId1, markId2 = DrawingTools.drawX(mission.coalitionId, markingUnit:getPoint())
                timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                timer.scheduleFunction(trigger.action.removeMark, markId2, timer:getTime() + 3600)
            else
                break
            end
        end
    end
    trigger.action.outTextForGroup(playerGroupId, "Scouting Mission Completed!", 5, false)
end
function recon.processBP(mission, playerGroupId)
    env.info("Processing BP Mission", false)
    local reconnedUnitPoints = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = mission.point,
            radius = 1200
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() then
            table.insert(reconnedUnitPoints, foundItem:getPoint())
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    if #reconnedUnitPoints > 0 then
        for i = 1, #reconnedUnitPoints do
            env.info("drawing marks", false)
            local markId1, markId2 = DrawingTools.drawX(mission.coalitionId, reconnedUnitPoints[i])
            timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
            timer.scheduleFunction(trigger.action.removeMark, markId2, timer:getTime() + 3600)
        end
    end
    if BattleControl then
        BattleControl.reconBP(mission.coalitionId, mission.bp)
    end
    trigger.action.outTextForGroup(playerGroupId, "Scouting Mission Completed!", 5, false)
end
function recon.getNewMissionId()
    local returnId = missionIdCounter
    missionIdCounter = missionIdCounter + 1
    return returnId
end
function recon.statusLoop()
    env.info("Recon Missions Status: " .. Utils.dump(currentMissions), false)
    env.info("Recon Captures Status: " .. Utils.dump(captures), false)
    timer.scheduleFunction(recon.statusLoop, nil, timer:getTime() + 600)
end
recon.statusLoop()
function recon.quickTest()
    local testGroupName = "test"
    local testGroupPoint = Group.getByName("test"):getUnit(1):getPoint()
    local newMissionId = Recon.createEnemyLocationMission(2, testGroupPoint, testGroupName)
    local newMissionId2 = Recon.createBDAMission(2, trigger.misc.getZone("bda").point)
end
--recon.quickTest()