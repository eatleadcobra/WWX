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
    [2] = 4 + #Platoons[1]["DeployedInf"],
    [3] = 3 + #Platoons[1]["DeployedInf"],
    [7] = 2
}
local pltCosts = {
    [1] = {
        [DFS.supplyType.FUEL] = 2,
        [DFS.supplyType.AMMO] = 5,
        [DFS.supplyType.EQUIPMENT] = 4
    },
    [2] = {
        [DFS.supplyType.FUEL] = 1,
        [DFS.supplyType.AMMO] = 2,
        [DFS.supplyType.EQUIPMENT] = 2
    },
    [3] = {
        [DFS.supplyType.FUEL] = 1,
        [DFS.supplyType.AMMO] = 1,
        [DFS.supplyType.EQUIPMENT] = 1
    },
    [7] = {
        [DFS.supplyType.FUEL] = 1,
        [DFS.supplyType.AMMO] = 3,
        [DFS.supplyType.EQUIPMENT] = 2
    },
}
local companyCompTiers = {
    [1] = {
        --tank, tank, apc, AD
        composition = {1,1,3,7},
    },
    [2] = {
        --tank, ifv, apc, AD
        composition = {1,2,3,7},
    },
    [3] = {
        --ifv, ifv, apc, AD
        composition = {2,2,3,7},
    },
    [4] = {
        --ifv, apc, apc, AD
        composition = {2,3,3,7},
    },
    [5] = {
        --tank, tank, apc
        composition = {1,1,3},
    },
    [6] = {
        --tank, ifv, apc
        composition = {1,2,3},
    },
    [7] = {
        -- ifv, ifv, apc
        composition = {2,2,3},
    },
    [8] = {
        -- ifv, apc, apc
        composition = {2,3,3},
    },
    [9] = {
        -- apc, apc, apc
        composition = {3,3,3},
    },
}
function BattleControl.reconBP(coalitionId, bpID)
    reconnedBPs[coalitionId][bpID] = true
    bc.fillCamera(coalitionId,bpID)
end

function bc.getPositions()
    for i = 1, positionsCountLimit do
        local bpZone = trigger.misc.getZone("BP-"..i)
        if bpZone then
            local newBP = BattlePosition.new(i, bpZone.point, bpZone.radius, "BP-"..i)
            battlePositions[newBP.id] = newBP
            table.insert(bpIds, newBP.id)
            bc.drawCamera(newBP.id)
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
            v:resetReconMarkers()
            local enemyCoalition = 2
            if c == 2 then enemyCoalition = 1 end
            if v.ownedBy == enemyCoalition then
                Recon.createBPScoutingMission(c, v.point, v.id)
            end
        end
    end
    timer.scheduleFunction(bc.bpRecon, nil, timer:getTime() + 3600)
end
function bc.drawCamera(bpId)
    local battlePosition = battlePositions[bpId]
    if battlePosition then
        local cameraPoint = {x = battlePosition.point.x + battlePosition.radius + 150, y = 0, z = battlePosition.point.z}
        local cameraCenterPoint = DrawingTools.drawCamera(-1, cameraPoint)
        battlePosition.reconMarkups.cameraCenterPoint = cameraCenterPoint
    end
end
function bc.fillCamera(coalitionId, bpId)
    local battlePosition = battlePositions[bpId]
    if battlePosition then
        local checkStartPoint = {x = battlePosition.reconMarkups.cameraCenterPoint.x - 50, y=0, z = battlePosition.reconMarkups.cameraCenterPoint.z }
        local leftCheckEnd = {x = battlePosition.reconMarkups.cameraCenterPoint.x, y=0, z = battlePosition.reconMarkups.cameraCenterPoint.z - 50}
        local rightCheckEnd = {x = battlePosition.reconMarkups.cameraCenterPoint.x + 30, y=0, z = battlePosition.reconMarkups.cameraCenterPoint.z + 70}
        local leftCheckId = DrawingTools.newMarkId()
        local rightCheckId = DrawingTools.newMarkId()
        trigger.action.lineToAll(coalitionId, leftCheckId, checkStartPoint, leftCheckEnd, {0,1,0,1}, 1, true, nil)
        trigger.action.lineToAll(coalitionId, rightCheckId, checkStartPoint, rightCheckEnd, {0,1,0,1}, 1, true, nil)
        battlePosition.reconMarkups.fillIds = {[1] = leftCheckId, [2] = rightCheckId}
    end
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
        if v.ownedBy ~= ownedBy then
            if v.reconMissionId ~= -1 then
                Recon.cleanmission(v.ownedBy, v.reconMissionId)
            end
            if ownedBy ~= 0 then
                local reconCoalitionId = 1
                if ownedBy == 1 then reconCoalitionId = 2 end
                v.reconMissionId = Recon.createBPScoutingMission(reconCoalitionId, v.point, v.id)
            end
            v.ownedBy = ownedBy
        end
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
        local targetStrength = 0
        for i = 1, #listOfNeutralBPsByDistance do
            local target = listOfNeutralBPsByDistance[i]
            if target.ownedBy == 0 then
                if bc.companyAssignedToBp(c, target.bpId) == false then
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
                if target.ownedBy ~= 0 and target.ownedBy ~= c then
                    if target.strength < bc.companyToStrength(bc.getAvailableStrengthTable(c)) then
                        targetbp = target.bpId
                        fromDepot = target.fromDepot
                        targetStrength = target.strength
                        break
                    end
                end
            end
        end
        if targetbp ~= -1 then
            bc.sendCompany(c, targetbp, fromDepot, targetStrength)
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
        cpyStrength = cpyStrength + pltStrengths[companyTable[i]]
    end
    return cpyStrength
end
function bc.companyToCost(companyTable)
    local cpyCost = {
        [DFS.supplyType.FUEL] = 0,
        [DFS.supplyType.AMMO] = 0,
        [DFS.supplyType.EQUIPMENT] = 0,
    }
    for i = 1, #companyTable do
        cpyCost[DFS.supplyType.FUEL] = cpyCost[DFS.supplyType.FUEL] + pltCosts[companyTable[i]][DFS.supplyType.FUEL]
        cpyCost[DFS.supplyType.AMMO] = cpyCost[DFS.supplyType.AMMO] + pltCosts[companyTable[i]][DFS.supplyType.AMMO]
        cpyCost[DFS.supplyType.EQUIPMENT] = cpyCost[DFS.supplyType.EQUIPMENT] + pltCosts[companyTable[i]][DFS.supplyType.EQUIPMENT]
    end
    return cpyCost
end
function bc.sendCompany(coalitionId, targetBP, spawnDepot, targetStrength)
    local startPoint = trigger.misc.getZone(DFS.spawnNames[coalitionId].depot..spawnDepot).point
    startPoint.x = startPoint.x + 50
    startPoint.z = startPoint.z + 50
    local destination = trigger.misc.getZone(battlePositions[targetBP].zoneName).point
    local strengthTable = bc.getAvailableStrengthTable(coalitionId, targetStrength)
    if strengthTable then
        local companyCost = bc.companyToCost(strengthTable)
        local canAfford = true
        for i = 1, 3 do
            if DFS.status[coalitionId].supply.front[i] < companyCost[i] then
                canAfford = false
            end
        end
        if strengthTable and canAfford then
            local newCpy = Company.new(coalitionId, true, strengthTable, false)
            Companies[newCpy.id] = newCpy
            table.insert(CompanyIDs[newCpy.coalitionId], newCpy.id)
            newCpy:setWaypoints({startPoint, destination}, targetBP, 999)
            newCpy:spawn()
            DFS.decreaseFrontSupply({coalitionId = coalitionId, type = DFS.supplyType.EQUIPMENT, amount = companyCost[DFS.supplyType.EQUIPMENT]})
            DFS.decreaseFrontSupply({coalitionId = coalitionId, type = DFS.supplyType.FUEL, amount = companyCost[DFS.supplyType.FUEL]})
            DFS.decreaseFrontSupply({coalitionId = coalitionId, type = DFS.supplyType.AMMO, amount = companyCost[DFS.supplyType.AMMO]})
        else
            env.info(coalitionId .. " - Cannot send company, not enough equipment", false)
        end
    end
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
function bc.getAvailableStrengthTable(coalitionId, targetStrength)
    local availableEquipmentPct =  math.floor(DFS.status[coalitionId].supply.front[DFS.supplyType.EQUIPMENT] / DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT] * 100)
    local cpyTier = math.ceil((100-availableEquipmentPct)/10)
    if cpyTier < 10 then
        if targetStrength > 0 then
            return companyCompTiers[cpyTier].composition
        else
            --send weakest available unit to neutral BP
            return companyCompTiers[#companyCompTiers].composition
        end
    else
        return nil
    end
end

bc.getPositions()
bc.setBPMarkups()
bc.main()