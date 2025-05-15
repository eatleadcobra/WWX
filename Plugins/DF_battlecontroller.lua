--check BPs for ownership
BattleControl = {}
local positionsCountLimit = 20
local bc = {}
local bcmarkups = {
    lines = {
        [0] = {0,0,0,1},
        [1] = {1,0,0,1},
        [2] = {0,0,1,1}
    },
    fills = {
        [0] = {0,0,0,0.2},
        [1] = {1,0,0,0.2},
        [2] = {0,0,1,0.2}
    }
}
local battlePositions = {}
local bpIds = {}
local reconnedBPs = {
    [1] = {},
    [2] = {},
}
function BattleControl.reconBP(coalitionId, bpID)
    reconnedBPs[coalitionId][bpID] = true
end

function bc.getPositions()
    for i = 1, positionsCountLimit do
        local bpZone = trigger.misc.getZone("BP-"..i)
        if bpZone then
            local newBP = BattlePosition.new(bpZone.point, bpZone.radius, "BP-"..i)
            battlePositions[newBP.id] = newBP
            table.insert(bpIds, newBP.id)
        end
    end
end
--set markups
function bc.setBPMarkups()
    for k,v in pairs(battlePositions) do
        if v.markupId ~= 0 then
            trigger.action.removeMark(v.markupId)
        end
        local newMarkId = DrawingTools.newMarkId()
        trigger.action.circleToAll(-1, newMarkId, v.point, v.radius, bcmarkups.lines[v.ownedBy], bcmarkups.fills[v.ownedBy], 1, true, "")
        v.markupId = newMarkId
    end
    timer.scheduleFunction(bc.setBPMarkups, nil, timer:getTime() + 30)
end
function bc.bpRecon()
    for c = 1, 2 do
        for k,v in pairs(battlePositions) do
            local enemyCoalition = 2
            if c == 2 then enemyCoalition = 1 end
            if v.ownedBy == enemyCoalition then
                Recon.createBPScoutingMission(c, v.point, v.id)
            end
        end
    end
    timer.scheduleFunction(bc.bpRecon, nil, timer:getTime() + 3600)
end

function bc.main()
    for k,v in pairs(battlePositions) do
        local redUnits = 0
        local blueUnits = 0
        local reconnedUnitPoints = {}
        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
                point = v.point,
                radius = v.radius
            }
        }
        local ifFound = function(foundItem, val)
            if foundItem:isExist() and foundItem:isActive() then
                if foundItem:getCoalition() == 1 then
                    redUnits = redUnits + 1
                elseif foundItem:getCoalition() == 2 then
                    blueUnits = blueUnits + 1
                end
            end
            return true
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        local ownedBy = 0
        if blueUnits > redUnits then
            ownedBy = 2
        elseif redUnits > blueUnits then
            ownedBy = 1
        end
        v.ownedBy = ownedBy
    end
    for c = 1, 2 do
        local potentialtargets = {}
        for k,v in pairs(battlePositions) do
            if v.ownedBy ~= c then
                table.insert(potentialtargets, k)
            end
        end
        local distanceToClosestBp = -1
        local closestNeutralBp = -1
        local closestFd = -1
        for i = 1, #potentialtargets do
            if battlePositions[potentialtargets[i]].ownedBy == 0 then
                local bpPoint = battlePositions[potentialtargets[i]].point
                if closestNeutralBp == -1 then
                    closestNeutralBp = potentialtargets[i]
                else
                    local shortestDistanceToBp = -1
                    local closerFd = -1
                    for j = 1, #DFS.status[c].spawns.fd do
                        local depotPoint = trigger.misc.getZone(DFS.spawnNames[c].depot..DFS.status[c].spawns.fd[j].spawnZone).point
                        local depotDist = Utils.PointDistance(depotPoint, bpPoint)
                        if shortestDistanceToBp == -1 or depotDist < shortestDistanceToBp then
                            shortestDistanceToBp = depotDist
                            closerFd = j
                        end
                    end
                    if closerFd ~= -1 and shortestDistanceToBp ~= -1 then
                        if distanceToClosestBp == -1 or shortestDistanceToBp < distanceToClosestBp then
                            distanceToClosestBp = shortestDistanceToBp
                            closestNeutralBp = potentialtargets[i]
                            closestFd = closerFd
                        end
                    end
                end
            end
        end
        if closestNeutralBp ~= -1 and closestFd ~= -1 then
            bc.sendCompany(c, closestNeutralBp, closestFd)
        else

        end
    end
    timer.scheduleFunction(bc.main, nil, timer:getTime() + 120)
end
function bc.sendCompany(coalitionId, targetBP, spawnDepot)
    local cpyAlreadyAssignedToBP = false
    if Companies then
        for k,v in pairs(Companies) do
            if v.coalitionId == coalitionId and v.bp == targetBP then
                cpyAlreadyAssignedToBP = true
            end
        end
    end
    if cpyAlreadyAssignedToBP then
        return
    else
        local startPoint = trigger.misc.getZone(DFS.spawnNames[coalitionId].depot..spawnDepot).point
        startPoint.x = startPoint.x + 50
        startPoint.z = startPoint.z + 50
        local destination = trigger.misc.getZone(battlePositions[targetBP].zoneName).point
        local strengthTable = bc.getAvailableStrengthTable(coalitionId)
        local newCpy = Company.new(coalitionId, true, strengthTable, false)
        Companies[newCpy.id] = newCpy
        table.insert(CompanyIDs[newCpy.coalitionId], newCpy.id)
        newCpy:setWaypoints({startPoint, destination}, targetBP, 999)
        newCpy:spawn()
    end
end
function bc.getAvailableStrengthTable(coalitionId)
    return {1,2,3}
end

bc.getPositions()
bc.setBPMarkups()
bc.bpRecon()
--for each coalition, find the best target (balance of distance and defensive strength)
--determine strongest available company (already made or can be made)
--  -- if all available companies are weaker than what can be made now, bolster most strategic BP
-- assign companies to BPs
bc.main()