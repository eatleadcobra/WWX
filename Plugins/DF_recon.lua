local dfrecon = {}
local reconInterval = 1800
local missionExpireTime = 3600
function dfrecon.loop()
    for c = 1, 2 do
        local enemyCoalition = 2
        if c == 2 then enemyCoalition = 1 end
        local missionGroupSpawn = DFS.status[enemyCoalition].spawns.front[math.random(#DFS.status[enemyCoalition].spawns.front)]
        if missionGroupSpawn then
            local missionGroupName = missionGroupSpawn.groupName
            if missionGroupName then
                local missionGroup = Group.getByName(missionGroupName)
                if missionGroup then
                    local missionUnit = missionGroup:getUnit(1)
                    if missionUnit then
                        local missionPoint = missionUnit:getPoint()
                        if missionPoint then
                            Recon.createEnemyLocationMission(c, missionPoint, missionGroupName)
                        end
                    end
                end
            end
        end
    end
    timer.scheduleFunction(dfrecon.loop, nil, timer:getTime() + reconInterval)
end
function dfrecon.depotLoop()
    for c = 1, 2 do
        local enemyCoalition = 2
        if c == 2 then enemyCoalition = 1 end
        for i = 1, #DFS.status[enemyCoalition].spawns.fd do
            local depotGroupSpawn = DFS.status[enemyCoalition].spawns.fd[i]
            if depotGroupSpawn then
                local missionGroupName = depotGroupSpawn.groupName
                if missionGroupName then
                    local missionGroup = Group.getByName(missionGroupName)
                    if missionGroup then
                        local missionUnit = missionGroup:getUnit(1)
                        if missionUnit then
                            local missionPoint = missionUnit:getPoint()
                            if missionPoint then
                                Recon.createEnemyLocationMissionNoMarker(c, missionPoint, missionGroupName)
                            end
                        end
                    end
                end
            end
        end
    end
    timer.scheduleFunction(dfrecon.loop, nil, timer:getTime() + missionExpireTime)
end
function dfrecon.aaLoop()
    for c = 1, 2 do
        local enemyCoalition = 2
        if c == 2 then enemyCoalition = 1 end
        for i = 1, #DFS.status[enemyCoalition].spawns.aa do
            local aaGroupSpawn = DFS.status[enemyCoalition].spawns.aa[i]
            if aaGroupSpawn then
                local missionGroupName = aaGroupSpawn.groupName
                if missionGroupName then
                    local missionGroup = Group.getByName(missionGroupName)
                    if missionGroup then
                        local missionUnit = missionGroup:getUnit(1)
                        if missionUnit then
                            local missionPoint = missionUnit:getPoint()
                            if missionPoint then
                                Recon.createEnemyLocationMissionNoMarker(c, missionPoint, missionGroupName)
                            end
                        end
                    end
                end
            end
        end
    end
    timer.scheduleFunction(dfrecon.loop, nil, timer:getTime() + missionExpireTime)
end
dfrecon.loop()
dfrecon.depotLoop()
dfrecon.aaLoop()