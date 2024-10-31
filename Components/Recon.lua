-- Requires Utils/utils.lua
-- Requires Utils/drawingTools.lua
Recon = {}
local recon = {}
local reconParams = {
    pointRadius = 20000,
    minAGL = 610,
    maxAGL = 4572,
    maxPitch = 0.18,
    maxRoll = 0.26
}
local missionTypes = {
    [1] = "BDA",
    [2] = "Suspected Enemy Location",
    [3] = "Convoy",
}
local missionIdCounter = 1
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
local currentReconPlayers = {
    [1] = {},
    [2] = {}

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
                if string.find(groupName, reconGroupIdentifier) then
                    --currentReconJets[groupName] = {}
                    currentReconJets[groupName] = 1
                    recon.trackReconJet(groupName)
                end
            end
        end
    end
    if event.id == world.event.S_EVENT_LAND then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                currentReconJets[group:getName()] = nil
                local unit = group:getUnit(1)
                if unit then
                    local player = unit:getPlayerName()
                    if player then
                        recon.processPlayerFilm(group:getCoalition(), player)
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
    trigger.action.outText("Creating Base Mission", 5, false)
    local newMissonId = recon.getNewMissionId()
    local newMission = Utils.deepcopy(missionTemplate)
    newMission.id = newMissonId
    newMission.coalitionId = coalitionId
    newMission.point = missionPoint
    trigger.action.outText("Base Mission Created", 5, false)
    return newMission
end
function Recon.createBDAMission(coalitionId, bdaPoint)
    local newMissonId = recon.getNewMissionId()
end
function Recon.createEnemyLocationMission(coalitionId, missionPoint, missionGroupName)
    trigger.action.outText("Creating Enemy Location Mission", 5, false)
    local missionMarkId = DrawingTools.newMarkId()
    trigger.action.circleToAll(coalitionId, missionMarkId, missionPoint, reconParams.pointRadius, {1,0.6,0,1}, {0,0,0,0}, 7, true, nil)
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.groupName = missionGroupName
    newMission.type = 2
    newMission.markId = missionMarkId
    currentMissions[coalitionId][newMission.id] = newMission
    trigger.action.outText("Enemy Location Mission Created", 5, false)
    return newMission.id
end
function Recon.createConvoyLocationMission(coalitionId, convoyGroupName)
    
end
function recon.trackReconJet(reconGroupName)
    if currentReconJets[reconGroupName] then
        trigger.action.outText("tracking recon jet: " .. reconGroupName, 5, false)
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
                        recon.captureMission(closestMission, reconUnit:getPlayerName(), reconCoalition)
                    end
                end
                timer.scheduleFunction(recon.trackReconJet, reconGroupName, timer:getTime() + 1)
            end
        end
    end
end
function recon.inParams(position, point)
    local pitch = math.abs(math.asin(position.x.y))
    local roll = math.abs(math.atan2(-position.z.y, position.y.y))
    local AGL = Utils.getAGL(point)
    trigger.action.outText("Pitch: " .. pitch .. " Roll: " .. roll .. " AGL: " .. AGL, 1, false)
    if pitch < reconParams.maxPitch and roll < reconParams.maxRoll and (reconParams.minAGL < AGL and AGL < reconParams.maxAGL ) then
        trigger.action.outText("In params", 1, false)
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
function recon.captureMission(missionId, playerName, coalitionId)
    trigger.action.outText(playerName.." Capturing Mission: " .. missionId, 5, false)
    if captures[playerName] == nil then
        captures[playerName] = {}
    end
    captures[playerName][#captures[playerName]+1] = {coalitionId = coalitionId, missionId = missionId}
    currentMissions[coalitionId][missionId].capturedBy = playerName
    trigger.action.outText("Mission Captured", 5, false)
end
function recon.purgePlayerCaptures(coalitionId, playerName)
    for i = 1, #captures[playerName] do
        local mission = currentMissions[coalitionId][captures[playerName][i].missionId]
        if mission then
           mission.capturedBy = nil
        end
    end
    captures[playerName] = nil
end
function recon.processPlayerFilm(coalitionId, playerName)
    trigger.action.outText("Processing Film For " .. playerName, 5, false)
    for i = 1, #captures[playerName] do
        recon.processCompletedMission(coalitionId, captures[playerName][i].missionId)
    end
    recon.purgePlayerCaptures(coalitionId, playerName)
end
function recon.processCompletedMission(coalitionId, missionId)
    trigger.action.outText("Processing Completed Mission " .. missionId, 5, false)
    trigger.action.outText(Utils.dump(currentMissions[coalitionId]), 5, false)
    local mission = currentMissions[coalitionId][missionId]
    if mission then
        local completedBy = mission.capturedBy
        local missionType = mission.type
        trigger.action.outText("completedBy: " .. completedBy .. " missionType: " .. missionTypes[missionType], 5, false)
        if missionType == 1 then
            
        elseif missionType == 2 then
            recon.processLocation(mission)
        elseif missionTypes == 3 then

        end
        recon.cleanMission(coalitionId, missionId)
    end
end
function recon.cleanMission(coalitionId, missionId)
    trigger.action.outText("cleaning mission", 5, false)
    local missionMarkId = currentMissions[coalitionId][missionId].markId
    if missionMarkId then
        trigger.action.outText("removing mark", 5, false)
        trigger.action.removeMark(missionMarkId)
    end
    currentMissions[coalitionId][missionId] = nil
end
function recon.processLocation(mission)
    trigger.action.outText("Processing Location Mission", 5, false)
    local discoveredGroupName = mission.groupName
    trigger.action.outText("discoveredGroupName: " ..  discoveredGroupName, 5, false)
    local discoveredGroup = Group.getByName(discoveredGroupName)
    if discoveredGroup then
        trigger.action.outText("group exists", 5, false)
        for i = 1, discoveredGroup:getSize() do
            trigger.action.outText("in loop: " .. i, 5, false)
            local markingUnit = discoveredGroup:getUnit(i)
            if markingUnit then
                trigger.action.outText("drawing marks", 5, false)
                local markId1, markId2 = DrawingTools.drawX(mission.coalitionId, markingUnit:getPoint())
                timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                timer.scheduleFunction(trigger.action.removeMark, markId2, timer:getTime() + 3600)
            else
                break
            end
        end
    end
    trigger.action.outText("Processed Mission", 5, false)
end
function recon.getNewMissionId()
    local returnId = missionIdCounter
    missionIdCounter = missionIdCounter + 1
    return returnId
end

function recon.quickTest()
    local testGroupName = "test"
    local testGroupPoint = Group.getByName("test"):getUnit(1):getPoint()
    local newMissionId = Recon.createEnemyLocationMission(2, testGroupPoint, testGroupName)
end
recon.quickTest()