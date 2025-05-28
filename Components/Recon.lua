-- Requires Utils/utils.lua
-- Requires Utils/drawingTools.lua
Recon = {}
local recon = {}
local potentialReconJets = {

}
local reconParams = {
    pointRadius = 1000,
    minAGL = 200,
    maxASL = env.mission.weather.clouds.base,
    maxPitch = 0.35,
    maxRoll = 0.55
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
local currentReconJets = {

}
local reconEvents = {}
function reconEvents:onEvent(event)
    if event.id == world.event.S_EVENT_TAKEOFF then
        if  event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local groupName = group:getName()
                if potentialReconJets[groupName] then
                    currentReconJets[groupName] = group:getID()
                    trigger.action.outTextForGroup(group:getID(), "Valid recon flight being tracked.", 10, false)
                    trigger.action.outTextForGroup(group:getID(), "Recon parameters:\nMax Roll: " .. math.floor(math.deg(reconParams.maxRoll)).."°\nMax Pitch: " .. math.floor(math.deg(reconParams.maxPitch)) .. "°\nMax ASL: " .. math.floor(3.28*reconParams.maxASL).."ft".."\nMin AGL: " .. math.floor(3.28*reconParams.minAGL).."ft" , 30, false)
                    recon.trackReconJet(groupName)
                   missionCommands.removeItemForGroup(group:getID(), {[1] = "Unload Recon Equipment"})
                else
                    Recon.removeRadioCommandsForGroup(group:getID())
                end
            end
        end
    end
    if event.id == world.event.S_EVENT_LAND then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local groupName = group:getName()
                if currentReconJets[groupName] then
                    currentReconJets[groupName] = nil
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
                potentialReconJets[group:getName()] = nil
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
function recon.newBaseMission(coalitionId, missionPoint, noExpire)
    local newMissionId = recon.getNewMissionId()
    local newMission = Utils.deepcopy(missionTemplate)
    newMission.id = newMissionId
    newMission.coalitionId = coalitionId
    newMission.point = missionPoint
    if noExpire then
        return newMission
    else
        timer.scheduleFunction(recon.destroyMission, {coalitionId = coalitionId, missionId = newMissionId}, timer:getTime() + missionExpireTime)
    end
    return newMission
end
function Recon.createBDAMission(coalitionId, bdaPoint)
    local missionMarkId = DrawingTools.newMarkId()
    trigger.action.circleToAll(coalitionId, missionMarkId, bdaPoint, reconParams.pointRadius, {0.3,1,0,1}, {0,0,0,0.2}, 4, true, nil)
    local newMission = recon.newBaseMission(coalitionId, bdaPoint)
    newMission.type = 1
    newMission.markId = missionMarkId
    currentMissions[coalitionId][newMission.id] = newMission
    return newMission.id
end
function Recon.createEnemyLocationMission(coalitionId, missionPoint, missionGroupName)
    local missionMarkId = DrawingTools.newMarkId()
    missionPoint.x = missionPoint.x + math.random(-300, 300)
    missionPoint.z = missionPoint.z + math.random(-300, 300)
    trigger.action.circleToAll(coalitionId, missionMarkId, missionPoint, reconParams.pointRadius, {0.3,1,0,1}, {0,0,0,0.2}, 3, true, nil)
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.groupName = missionGroupName
    newMission.type = 2
    newMission.markId = missionMarkId
    currentMissions[coalitionId][newMission.id] = newMission
    return newMission.id
end
function Recon.createBPScoutingMission(coalitionId, missionPoint, bp, noExpire)
    local newMission = recon.newBaseMission(coalitionId, missionPoint, noExpire)
    newMission.type = 4
    newMission.bp = bp
    currentMissions[coalitionId][newMission.id] = newMission
    return newMission.id
end

function Recon.createEnemyLocationMissionNoMarker(coalitionId, missionPoint, missionGroupName)
    local newMission = recon.newBaseMission(coalitionId, missionPoint)
    newMission.groupName = missionGroupName
    newMission.type = 2
    currentMissions[coalitionId][newMission.id] = newMission
    return newMission.id
end
function Recon.createConvoyLocationMission(coalitionId, convoyGroupName)
    
end
function Recon.cleanmission(coalitionId, missionId)
    recon.cleanMission(coalitionId, missionId)
end
function Recon.addRadioCommandsForGroup(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup ~= nil then
        local addID = addGroup:getID()
        missionCommands.addCommandForGroup(addID, "Load Recon Equipment", nil, recon.registerReconGroup, groupName)
    end
end
function Recon.removeRadioCommandsForGroup(groupID)
    missionCommands.removeItemForGroup(groupID, {[1] = "Load Recon Equipment"})
    missionCommands.removeItemForGroup(groupID, {[1] = "Check Recon Parameters"})
    missionCommands.removeItemForGroup(groupID, {[1] = "Unload Recon Equipment"})
end
function recon.registerReconGroup(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup ~= nil then
        local addID = addGroup:getID()
        potentialReconJets[groupName] = true
        missionCommands.removeItemForGroup(addID, {[1] = "Load Recon Equipment"})
        missionCommands.addCommandForGroup(addID, "Check Recon Parameters", nil, recon.checkReconParams, addID)
        local param = {groupName = groupName, groupID = addID}
        missionCommands.addCommandForGroup(addID, "Unload Recon Equipment", nil, recon.deregisterReconGroup, param)
    end
end
function recon.deregisterReconGroup(param)
    potentialReconJets[param.groupName] = nil
    missionCommands.removeItemForGroup(param.groupID, {[1] = "Unload Recon Equipment"})
    missionCommands.removeItemForGroup(param.groupID, {[1] = "Check Recon Parameters"})
    missionCommands.addCommandForGroup(param.groupID, "Load Recon Equipment", nil, recon.registerReconGroup, param.groupName)
end
function recon.checkReconParams(groupID)
    trigger.action.outTextForGroup(groupID, "Recon parameters:\nMax Roll: " .. math.floor(math.deg(reconParams.maxRoll)).."°\nMax Pitch: " .. math.floor(math.deg(reconParams.maxPitch)) .. "°\nMax ASL: " .. math.floor(3.28*reconParams.maxASL).."ft".."\nMin AGL: " .. math.floor(3.28*reconParams.minAGL).."ft" , 30, false)
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
    if pitch < reconParams.maxPitch and roll < reconParams.maxRoll and (reconParams.minAGL < AGL and point.y < reconParams.maxASL ) then
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
    local mission = currentMissions[coalitionId][missionId]
    if mission then
        local missionMarkId = mission.markId
        local capturedBy = mission.capturedBy
        if capturedBy then
            captures[capturedBy][missionId] = nil
        end
        if missionMarkId then
            trigger.action.removeMark(missionMarkId)
        end
        currentMissions[coalitionId][missionId] = nil
    end
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
            recon.cleanMission(param.coalitionId, param.missionId)
        end
    end
end
function recon.processBDA(mission, playerGroupId)
    local enemyCoalition = 1
    if mission.coalitionId == 1 then enemyCoalition = 2 end
    if DFS then
        DFS.status[enemyCoalition].health = DFS.status[enemyCoalition].health - 1
    end
    trigger.action.outTextForGroup(playerGroupId, "BDA Mission Completed!", 5, false)
end
function recon.processLocation(mission, playerGroupId)
    local discoveredGroupName = mission.groupName
    local discoveredGroup = Group.getByName(discoveredGroupName)
    if discoveredGroup then
        for i = 1, discoveredGroup:getSize() do
            local markingUnit = discoveredGroup:getUnit(i)
            if markingUnit then
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
    local reconnedUnits = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = mission.point,
            radius = 1200
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() and foundItem:getCoalition() ~= mission.coalitionId then
            table.insert(reconnedUnits, foundItem)
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    local unitMarkIds = {}
    if #reconnedUnits > 0 then
        for i = 1, #reconnedUnits do
            local reconnedUnit = reconnedUnits[i]
            if reconnedUnit then
                if reconnedUnit:hasAttribute("Infantry") then
                    local markId1, markId2 = DrawingTools.drawX(mission.coalitionId, reconnedUnit:getPoint())
                    unitMarkIds[#unitMarkIds+1] = markId1
                    unitMarkIds[#unitMarkIds+1] = markId2
                    timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                    timer.scheduleFunction(trigger.action.removeMark, markId2, timer:getTime() + 3600)
                elseif reconnedUnit:hasAttribute("Trucks") then
                    local markId1 = DrawingTools.drawCircle(mission.coalitionId, reconnedUnit:getPoint(), 12)
                    unitMarkIds[#unitMarkIds+1] = markId1
                    timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                elseif reconnedUnit:hasAttribute("APC") or reconnedUnit:hasAttribute("IFV") then
                    local markId1, markId2 = DrawingTools.drawX(mission.coalitionId, reconnedUnit:getPoint())
                    local markId3 = DrawingTools.drawCircle(mission.coalitionId, reconnedUnit:getPoint(), 12)
                    unitMarkIds[#unitMarkIds+1] = markId1
                    unitMarkIds[#unitMarkIds+1] = markId2
                    unitMarkIds[#unitMarkIds+1] = markId3
                    timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                    timer.scheduleFunction(trigger.action.removeMark, markId2, timer:getTime() + 3600)
                    timer.scheduleFunction(trigger.action.removeMark, markId3, timer:getTime() + 3600)
                elseif reconnedUnit:hasAttribute("Tanks") then
                    local markId1, markId2 = DrawingTools.drawChevron(mission.coalitionId, reconnedUnit:getPoint())
                    unitMarkIds[#unitMarkIds+1] = markId1
                    unitMarkIds[#unitMarkIds+1] = markId2
                    timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                    timer.scheduleFunction(trigger.action.removeMark, markId2, timer:getTime() + 3600)
                elseif reconnedUnit:hasAttribute("Armed Air Defence") then
                    local markId1 = DrawingTools.drawTriangle(mission.coalitionId, reconnedUnit:getPoint())
                    unitMarkIds[#unitMarkIds+1] = markId1
                    timer.scheduleFunction(trigger.action.removeMark, markId1, timer:getTime() + 3600)
                end
            end
        end
    end
    if BattleControl then
        BattleControl.reconBP(mission.coalitionId, mission.bp, unitMarkIds)
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
    local testGroupPoint = Group.getByName("test"):getUnit(1):getPoint()
    local newMissionId = Recon.createBPScoutingMission(2, testGroupPoint, 1)
    recon.processBP(currentMissions[2][newMissionId], Group.getByName("test"):getID())
end
--recon.quickTest()