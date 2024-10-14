local cb = {}
local interval = 30
local casRadius = 4000
local casHeight = 1000
local casTimeLimit = 1799
local casReassignTime = 299
local smokeColors = {
    [0] = "green",
    [1] = "red",
    [2] = "white",
    [3] = "orange",
    [4] = "blue"
}
local previousLists = {
    [1] = {},
    [2] = {}
}
local currentLists = {
    [1] = {},
    [2] = {}
}
local assignments = {
    [1] = {},
    [2] = {}
}
local stackZones = {
    [1] = "RedCas",
    [2] = "BlueCas"
}
local stackPoints = {
    [1] = {},
    [2] = {}
}
function cb.load()
    local redZone = trigger.misc.getZone(stackZones[1])
    local blueZone = trigger.misc.getZone(stackZones[2])
    if redZone and blueZone then
        stackPoints[1] = {x=redZone.point.x, y = land.getHeight({x = redZone.point.x, y = redZone.point.z})+casHeight, z = redZone.point.z}
        trigger.action.circleToAll(1, DrawingTools.newMarkId(), stackPoints[1], casRadius, {1,0,0,0.6}, {0,0,0,0}, 4, true, nil)
        trigger.action.textToAll(1, DrawingTools.newMarkId(), stackPoints[1], {1,0,0,0.6}, {1,1,1,0.9}, 10, true, "CAS Stack")
        stackPoints[2] = {x=blueZone.point.x, y = land.getHeight({x = blueZone.point.x, y = blueZone.point.z})+casHeight, z = blueZone.point.z}
        trigger.action.circleToAll(2, DrawingTools.newMarkId(), stackPoints[2], casRadius, {0,0,1,0.6}, {0,0,0,0}, 4, true, nil)
        trigger.action.textToAll(2, DrawingTools.newMarkId(), stackPoints[2], {0,0,1,0.6}, {1,1,1,0.9}, 10, true, "CAS Stack")
        cb.main()
    end
end
function cb.main()
    cb.searchCasZones()
    cb.trackCas()
    timer.scheduleFunction(cb.main, nil, timer:getTime() + interval)
end
function cb.searchCasZones()
    for c = 1,2 do
        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
                point = stackPoints[c],
                radius = casRadius
            }
        }
        local ifFound = function(foundItem, val)
            env.info("CAS search", false)
            if (foundItem:getDesc().category == 0 or foundItem:getDesc().category == 1) and foundItem:isExist() and foundItem:isActive() and foundItem:getCoalition() == c then
                local foundPlayerName = foundItem:getPlayerName()
                local playerCoalition = foundItem:getCoalition()
                local playerGroup = foundItem:getGroup()
                if playerGroup then
                    local playerGroupID = playerGroup:getID()
                    if foundPlayerName and playerCoalition and playerGroupID then
                        env.info("Found player: "..foundPlayerName, false)
                        if assignments[c][foundPlayerName] == nil then
                            env.info("player added to list: "..foundPlayerName, false)
                            currentLists[c][foundPlayerName] = {name = foundPlayerName, coalition = playerCoalition, groupID = playerGroupID}
                        end
                    end
                end
            end
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        for k,v in pairs(currentLists[c]) do
            if previousLists[c][k] and assignments[c][k] == nil or previousLists[c][k] and (assignments[c][k].startTime > casReassignTime) then
                assignments[c][k] = nil
                cb.assignCas(v.name, v.coalition, v.groupID)
                env.info("player assigned: ".. v.name, false)
            else
                trigger.action.outTextForGroup(v.groupID, "You are on station for CAS. Stand by for assignment.", 20, false)
            end
        end
        previousLists[c] = {}
        previousLists[c] = Utils.deepcopy(currentLists[c])
        currentLists[c] = {}
    end
end
function cb.assignCas(playerName, coalitionId, playerGroupID)
    local smokeNum = math.random(0,4)
    local smokeColor = smokeColors[smokeNum]
    local enemyCoalition = 2
    if coalitionId == 2 then
        enemyCoalition = 1
    end
    local missionGroupSpawn = DFS.status[enemyCoalition].spawns.front[math.random(#DFS.status[enemyCoalition].spawns.front)]
    if missionGroupSpawn then
    local missionGroupName = missionGroupSpawn.groupName
        if missionGroupName then
            local missionGroup = Group.getByName(missionGroupName)
            if missionGroup then
                assignments[coalitionId][playerName] = {name = playerName, target = missionGroupName, groupID = playerGroupID, startTime = timer:getTime(), smokeTime = timer:getTime(), smokeNum = smokeNum}
                trigger.action.outTextForGroup(playerGroupID, "Target assigned and marked with ".. smokeColor .." smoke! You are cleared hot.", 20, false)
				DFS.smokeGroup(missionGroupName, smokeNum)
				local unitGroup = missionGroup:getUnit(1)
				local groupPoint = unitGroup:getPoint()
				local missionTime = timer.getAbsTime()
				if 27000 > missionTime or missionTime > 68400 then
					trigger.action.illuminationBomb({x=groupPoint.x, y=groupPoint.y + 500, z=groupPoint.z}, 5000)
				end
            end
        end
    end
end
function cb.trackCas()
    for c = 1, 2 do
        local playerActive = false
        for k,v in pairs(assignments[c]) do
            local currentPlayers = coalition.getPlayers(c)
            for j = 1, #currentPlayers do
                if v.name == Unit.getPlayerName(currentPlayers[j]) then
                    playerActive = true
                end
            end
            if playerActive then
                local targetGroup = Group.getByName(v.target)
                local isDead = false
                if targetGroup == nil or targetGroup:getSize() == 0 then
                    isDead = true
                end
                if isDead then
                    trigger.action.outTextForGroup(v.groupID, "Mission accomplished! Return to CAS stack for further assignment.", 30, false)
                    if WWEvents then
                        WWEvents.playerCasMissionCompleted(v.name, c, "completed a CAS mission!")
                    end
                    assignments[c][v.name] = nil
                elseif timer:getTime() - v.startTime > casTimeLimit then
                    assignments[c][v.name] = nil
                    trigger.action.outTextForGroup(v.groupID, "Mission not completed! Return to CAS stack for further assignment.", 30, false)
                elseif  timer:getTime() - v.smokeTime > 300 then
                    DFS.smokeGroup(v.target, v.smokeNum)
                    v.smokeTime = timer:getTime()
                end
            else
                assignments[c][v.name] = nil
            end
        end
    end
end
cb.load()