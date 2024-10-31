-- Requires Utils/utils.lua
-- Requires Utils/drawingTools.lua
Recon = {}
local recon = {}
local reconParams = {
    pointRadius = 2000,
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
local missionIdCounter = 0
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
local reconJets = {
    --lookup type names for F-14A, F-4E, F1EE, MB-339A
}
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
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.groupName = missionGroupName
    newMission.type = 2
    currentMissions[coalitionId][newMission.id] = newMission
    trigger.action.outText("Enemy Location Mission Created", 5, false)
    return newMission.id
end
function Recon.createConvoyLocationMission(coalitionId, convoyGroupName)
    
end
function recon.trackReconJet(reconGroupName)
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
function recon.inParams(position, point)
    local pitch = math.abs(math.asin(position.x.y))
    local roll = math.abs(math.asin(position.x.z))
    local AGL = Utils.getAGL(point)
    if pitch < reconParams.maxPitch and roll < reconParams.maxRoll and (reconParams.minAGL < AGL < reconParams.maxAGL ) then
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
    --table.insert(captures[playerName], {coalitionId = coalitionId, missionId = missionId})
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
    local mission = currentMissions[coalitionId][missionId]
    if mission then
        local completedBy = mission.capturedBy
        local missionType = mission.type
        if missionType == 1 then
            
        elseif missionType == 2 then
            recon.processLocation(mission)
        elseif missionTypes == 3 then

        end
        currentMissions[coalitionId][missionId] = nil
    end
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
    local newMissionId = Recon.createEnemyLocationMission(1, testGroupPoint, testGroupName)
    recon.captureMission(newMissionId, "EatLeadCobra", 1)
    recon.processPlayerFilm(1, "EatLeadCobra")
end
--recon.quickTest()