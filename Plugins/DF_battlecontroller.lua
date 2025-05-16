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
local pltStrengths = {
    [1] = 15,
    [2] = 5 + #Platoons[1]["DeployedInf"],
    [3] = 3 + #Platoons[1]["DeployedInf"],
    [7] = 2
}
local companyCompTiers = {
    [1] = {
        --tank, tank, apc, AD
        composition = {1,1,3,7},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [2] = {
        --tank, ifv, apc, AD
        composition = {1,2,3,7},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [3] = {
        --ifv, ifv, apc, AD
        composition = {2,2,3,7},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [4] = {
        --ifv, apc, apc, AD
        composition = {2,3,3,7},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [5] = {
        --tank, tank, apc
        composition = {1,1,3},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [6] = {
        --tank, ifv, apc
        composition = {1,2,3},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [7] = {
        -- ifv, ifv, apc
        composition = {2,2,3},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [8] = {
        -- ifv, apc, apc
        composition = {2,3,3},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
    [9] = {
        -- apc, apc, apc
        composition = {3,3,3},
        --fuel, ammo, equipment
        cost = {5, 10, 6}
    },
}
function BattleControl.reconBP(coalitionId, bpID)
    reconnedBPs[coalitionId][bpID] = true
end

function bc.getPositions()
    for i = 1, positionsCountLimit do
        local bpZone = trigger.misc.getZone("BP-"..i)
        if bpZone then
            local newBP = BattlePosition.new(i, bpZone.point, bpZone.radius, "BP-"..i)
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
    reconnedBPs = { [1] = {}, [2] = {}}
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
        local listOfNeutralBPsByDistance = {}
        local listOfEnemyBPsByDistance = {}
        for k,v in pairs(battlePositions) do
            if v.ownedBy ~= c then
                table.insert(potentialtargets, k)
            end
        end
        for i = 1, #potentialtargets do
            local bpPoint = battlePositions[potentialtargets[i]].point
            local closerDepot = -1
            local closerDistance = -1
            for j = 1, #DFS.status[c].spawns.fd do
                local depotPoint = trigger.misc.getZone(DFS.spawnNames[c].depot..DFS.status[c].spawns.fd[j].spawnZone).point
                local depotDist = Utils.PointDistance(depotPoint, bpPoint)
                if closerDistance == -1 or depotDist < closerDistance then
                    closerDepot = j
                    closerDistance = depotDist
                end
            end
            local bpOwner = battlePositions[potentialtargets[i]].ownedBy
            if bpOwner == 0 then
                table.insert(listOfNeutralBPsByDistance, {bpId = potentialtargets[i], distance = closerDistance, fromDepot = closerDepot, strength = bc.assessBpStrength(c, potentialtargets[i]), ownedBy = battlePositions[potentialtargets[i]].ownedBy})
            else
                table.insert(listOfEnemyBPsByDistance, {bpId = potentialtargets[i], distance = closerDistance, fromDepot = closerDepot, strength = bc.assessBpStrength(c, potentialtargets[i]), ownedBy = battlePositions[potentialtargets[i]].ownedBy})
            end
        end
        table.sort(listOfNeutralBPsByDistance, function(a, b) return a.distance < b.distance end)
        table.sort(listOfEnemyBPsByDistance, function(a, b) return a.distance < b.distance end)
        local targetbp = -1
        local fromDepot = -1
        for i = 1, #listOfNeutralBPsByDistance do
            local target = listOfNeutralBPsByDistance[i]
            trigger.action.outText(c .. "-team evaluating potential target: " .. target.bpId, 10, false)
            if target.ownedBy == 0 then
                trigger.action.outText("BP: " .. target.bpId .. " is neutral", 10, false)
                if bc.companyAssignedToBp(c, target.bpId) == false then
                    trigger.action.outText("BP: " .. target.bpId .. " is not assigned to any company", 10, false)
                    targetbp = target.bpId
                    fromDepot = target.fromDepot
                    break
                end
            end
        end
        --only evaluate enemy BPs if no neutral BPs remain
        if targetbp == -1 then
            for i = 1, #listOfEnemyBPsByDistance do
                local target = listOfEnemyBPsByDistance[i]
                trigger.action.outText(c .. "-team evaluating potential target: " .. target.bpId, 10, false)
                if target.ownedBy ~= 0 and target.ownedBy ~= c then
                    if target.strength < bc.companyToStrength(bc.getAvailableStrengthTable(c)) then
                        targetbp = target.bpId
                        fromDepot = target.fromDepot
                        break
                    end
                end
            end
        end
        if targetbp ~= -1 then
            bc.sendCompany(c, targetbp, fromDepot)
        end
    end
    timer.scheduleFunction(bc.main, nil, timer:getTime() + 120)
end
function bc.companyAssignedToBp(coalitionId, targetbp)
    local cpyAlreadyAssignedToBP = false
    if Companies then
        for k,v in pairs(Companies) do
            if v.coalitionId == coalitionId and v.bp == targetbp then
                cpyAlreadyAssignedToBP = true
            end
        end
    end
    return cpyAlreadyAssignedToBP
end
function bc.companyToStrength(companyTable)
    local cpyStrength = 0
    for i = 1, #companyTable do
        cpyStrength = pltStrengths[companyTable[i]]
    end
    return cpyStrength
end
function bc.sendCompany(coalitionId, targetBP, spawnDepot)
    trigger.action.outText("Coaltion: " .. coalitionId .. " is sending a company to BP: " .. targetBP .. " from depot " .. spawnDepot, 10, false)
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
function bc.assessBpStrength(coalitionId, bpId)
    local battlePosition = battlePositions[bpId]
    local positionRealStrength = 0
    local positionAssessedStrength = 0
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = battlePosition.point,
            radius = battlePosition.radius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() and foundItem:getCoalition() == battlePosition.ownedBy then
            if foundItem:hasAttribute("Tanks") then
                positionRealStrength = positionRealStrength + 6
            elseif foundItem:hasAttribute("IFV") then
                positionRealStrength = positionRealStrength + 4
            elseif foundItem:hasAttribute("APC") then
                positionRealStrength = positionRealStrength + 3
            else
                positionRealStrength = positionRealStrength + 1
            end
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    if reconnedBPs[coalitionId][bpId] then
        positionAssessedStrength = positionRealStrength
    else
        positionAssessedStrength = positionRealStrength * (1 + ((math.random(-4, 4)/10)))
    end
    return positionAssessedStrength
end
function bc.getAvailableStrengthTable(coalitionId)
    return companyCompTiers[math.random(1,9)].composition
    --strongest comp is two tanks + motor infantry + embedded AD
    --weakest comp is three APC plts
end

bc.getPositions()
bc.setBPMarkups()
bc.bpRecon()
--for each coalition, find the best target (balance of distance and defensive strength)
--determine strongest available company (already made or can be made)
--  -- if all available companies are weaker than what can be made now, bolster most strategic BP
-- assign companies to BPs
bc.main()