--check BPs for ownership
BattleControl = {}
local positionsCountLimit = 20
local junkRemoval = true
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
local reconnedBPMarkups = {
    [1] = {},
    [2] = {},
}
local priorityBPs = {
    [1] = {bpId = 0, priority = ""},
    [2] = {bpId = 0, priority = ""},
}
local priorityMarkupIds = {
    [1] = {},
    [2] = {}
}
local radioObjectiveMessages = {
    ["complete"] = "l10n/DEFAULT/ObjectiveComplete.ogg",
    ["failed"] = "l10n/DEFAULT/ObjectiveFailed.ogg",
}
local pltStrengths = {
    [1] = 15,
    [2] = 4 + #Platoons[1]["DeployedInf"],
    [3] = 3 + #Platoons[1]["DeployedInf"],
    [7] = 2
}
local pltCosts = {
    [1] = {
        [DFS.supplyType.FUEL] = 8,
        [DFS.supplyType.AMMO] = 15,
        [DFS.supplyType.EQUIPMENT] = 4
    },
    [2] = {
        [DFS.supplyType.FUEL] = 4,
        [DFS.supplyType.AMMO] = 4,
        [DFS.supplyType.EQUIPMENT] = 2
    },
    [3] = {
        [DFS.supplyType.FUEL] = 3,
        [DFS.supplyType.AMMO] = 2,
        [DFS.supplyType.EQUIPMENT] = 1
    },
    [7] = {
        [DFS.supplyType.FUEL] = 4,
        [DFS.supplyType.AMMO] = 2,
        [DFS.supplyType.EQUIPMENT] = 2
    },
}
local companyCompTiers = {
    [0] = {composition = nil},
    [1] = {
        --tank, tank, apc, AD
        composition = {3,1,1,7},
    },
    [2] = {
        --tank, ifv, apc, AD
        composition = {2,1,3,7},
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
        composition = {3,1,3,7},
    },
    [6] = {
        --tank, ifv, apc
        composition = {3,1,2},
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
function bc.fileExists(file)
    local f = io.open(file, 'rb')
    if f then f:close() end
    return f ~= nil
end
local missionName = env.mission["date"]["Year"]
local priorityBPFile = lfs.writedir() .. [[Logs/]] .. 'priorityBPs'..missionName..'.txt'

function bc.savePriorities()
    if MissionOver == false then
        local bpFile = priorityBPFile
        local f = io.open(bpFile, 'w')
        if f then
            f:write("return " .. Utils.saveToString(priorityBPs))
        end
        f:close()
    end
end
function bc.loadPriorities()
    if bc.fileExists(priorityBPFile) then
        local f = io.open(priorityBPFile, 'r')
        local priorityData = dofile(priorityBPFile)
        priorityBPs = priorityData
        f:close()
        for c = 1,2 do
            local battlePosition = battlePositions[priorityBPs[c].bpId]
            if battlePosition then
                local priorityPoint = {x = battlePosition.point.x, y = 0, z = battlePosition.point.z - battlePosition.radius - 200}
                priorityMarkupIds[c] = DrawingTools.drawPriorityMarker(c, priorityPoint, priorityBPs[c].priority)
            end
        end
    end
end

function BattleControl.reconBP(coalitionId, bpID, markIds)
    reconnedBPs[coalitionId][bpID] = true
    reconnedBPMarkups[coalitionId][bpID] = markIds
    bc.fillCamera(coalitionId,bpID)
end
function BattleControl.endMission()
    priorityBPs = {[1] = {}, [2] = {}}
end
function bc.getPositions()
    for i = 1, positionsCountLimit do
        local bpZone = trigger.misc.getZone("BP-"..i)
        if bpZone then
            local bpPoint = {x = bpZone.point.x, y = land.getHeight({x = bpZone.point.x, y = bpZone.point.z}), z = bpZone.point.z}
            local newBP = BattlePosition.new(i, bpPoint, bpZone.radius, "BP-"..i)
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
        DrawingTools.numberBP(v.point, v.radius, v.id, #battlePositions)
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
--- for each team
--- check how many neutral BPs exist
--- check how many we own with insufficient strength to hold
--- check how many the enemy owns
--- check how many the enemy needs to win
--- If enemy needs only 1-2 BPs, prioritize capturing max available points
--- Otherwise: 
---     Can we create a strong reinforcement unit for a BP in need? Send it
---     Can we create a strong group to capture a neutral BP? Send it
---     Can we create a strong group to capture an enemy BP? Send it
---     Can we create any group to capture any neutral BP? Send it
---     Else, wait for next turn.

function bc.deployments()
    local evalCoalition = math.random(2)
    for c = 1, 2 do
        local coalitionId = evalCoalition
            if coalitionId == 1 then
                evalCoalition = 2
            else
                evalCoalition = 1
            end
            local listOfNeutralBPsByDistance = {}
            local listOfEnemyBPsByDistance = {}
            local listOfFriendlyBPsNeedingReinforcementByDistance = {}
            local totalBPs = #battlePositions

            local neutralBPs = 0
            local coalitionBPs = {
                [1] = 0,
                [2] = 0
            }
            local enemyCoalition = 2
            if coalitionId == 2 then enemyCoalition = 1 end
            local enemyAvailableStr = bc.companyToStrength(companyCompTiers[bc.getAvailableStrengthTableTier(enemyCoalition)].composition)
            enemyAvailableStr = enemyAvailableStr * ((1 + ((math.random(-2, 2)/10))))

            for k, v in pairs(battlePositions) do
                if v.ownedBy == 0 then
                    neutralBPs = neutralBPs + 1
                else
                    coalitionBPs[v.ownedBy] = coalitionBPs[v.ownedBy] + 1
                end
                local bpPoint = v.point
                local closerDepot = -1
                local closerDistance = -1
                for j = 1, #DFS.status[coalitionId].spawns.fd do
                    local depotPoint = trigger.misc.getZone(DFS.spawnNames[coalitionId].depot..DFS.status[coalitionId].spawns.fd[j].spawnZone).point
                    local depotDist = Utils.PointDistance(depotPoint, bpPoint)
                    if closerDistance == -1 or depotDist < closerDistance then
                        closerDepot = j
                        closerDistance = depotDist
                    end
                end
                if v.ownedBy == 0 then
                    if bc.companyAssignedToBp(coalitionId, k) == false then
                        table.insert(listOfNeutralBPsByDistance, {bpId = k, distance = closerDistance, fromDepot = closerDepot, strength = bc.assessBpStrength(coalitionId, k), ownedBy = v.ownedBy})
                    end
                elseif v.ownedBy == enemyCoalition then
                    if bc.companyAssignedToBp(coalitionId, k) == false then
                        table.insert(listOfEnemyBPsByDistance, {bpId = k, distance = closerDistance, fromDepot = closerDepot, strength = bc.assessBpStrength(coalitionId, k), ownedBy = v.ownedBy})
                    end
                elseif v.ownedBy == coalitionId then
                    local bpStrength = bc.assessBpStrength(coalitionId, k)
                    if bpStrength < (enemyAvailableStr*(3/4)) then
                        table.insert(listOfFriendlyBPsNeedingReinforcementByDistance, {bpId = k, distance = closerDistance, fromDepot = closerDepot, strength = bpStrength, ownedBy = v.ownedBy})
                    end
                end
            end
            local enemyPointsToWin = totalBPs - coalitionBPs[enemyCoalition]
            local ourPointsToWin = totalBPs - coalitionBPs[coalitionId]
            local tierToSpawn = 1
            local strengthToHold = 0
            local desperate = false
            for i = 1, #companyCompTiers do
                local tierStrength = bc.companyToStrength(companyCompTiers[i].composition)
                if tierStrength >= enemyAvailableStr then
                    tierToSpawn = i
                    strengthToHold = tierStrength
                end
            end
            env.info(coalitionId .. "-Tier needed to hold point: " .. tierToSpawn, false)
            if enemyPointsToWin < 2 then
                strengthToHold = 0
                desperate = true
                env.info("Enemy victory is imminent, send any avilable troops.", false)
            end
            local priority = "REINFORCE"
            if enemyPointsToWin < 3 or enemyAvailableStr <= bc.companyToStrength(companyCompTiers[math.floor(#companyCompTiers/2)]) or ourPointsToWin < 3 or ourPointsToWin > math.floor((3*totalBPs)/4) then
                priority = "CAPTURE"
            end
            env.info("Priority: " .. priority, false)
            table.sort(listOfNeutralBPsByDistance, function(a, b) return a.distance < b.distance end)
            table.sort(listOfEnemyBPsByDistance, function(a, b) return a.distance < b.distance end)
            table.sort(listOfFriendlyBPsNeedingReinforcementByDistance, function(a, b) return a.distance < b.distance end)

            local priorityTargetsTables = {}
            if priority == "REINFORCE" then
                priorityTargetsTables = {
                    [1] = listOfFriendlyBPsNeedingReinforcementByDistance,
                    [2] = listOfNeutralBPsByDistance,
                    [3] = listOfEnemyBPsByDistance
                }
            elseif priority == "CAPTURE" then
                priorityTargetsTables = {
                    [1] = listOfNeutralBPsByDistance,
                    [2] = listOfEnemyBPsByDistance,
                    [3] = listOfFriendlyBPsNeedingReinforcementByDistance,
                }
            end
            local sentCount = 0
            for i = 1, #priorityTargetsTables do
                local targetTable = priorityTargetsTables[i]
                for j = 1, #targetTable do
                    local availableCpyTier = bc.getAvailableStrengthTableTier(coalitionId)
                    local availableStr = bc.companyToStrength(companyCompTiers[availableCpyTier].composition)
                    env.info("Our strength: " .. availableStr, false)
                    env.info("strength to hold: " .. strengthToHold, false)
                    if availableStr > 0 and availableStr >= strengthToHold then
                        local sendCpy = nil
                        if priority == "REINFORCE" then
                            sendCpy = bc.getReinforcementNeeded(targetTable[j].strength, strengthToHold)
                        end
                        env.info("Sufficient company possible, sending", false)
                        bc.sendCompany(coalitionId, targetTable[j].bpId, targetTable[j].fromDepot, availableCpyTier, desperate, sendCpy)
                        env.info("SentCount: " .. sentCount, false)
                        sentCount = sentCount + 1
                        if sentCount == 1 then
                            if priorityBPs[coalitionId].bpId and priorityBPs[coalitionId].bpId == 0 or bc.priortyAchieved(coalitionId) then
                                bc.assignPriorityBp(coalitionId, targetTable[j].bpId, priority)
                            end
                        end
                    else
                        env.info("No Sufficient company possible, waiting", false)
                    end
                end
            end
    end
end
function bc.priortyAchieved(coalitionId)
    local priorityAchieved = false
    local priorityBP = priorityBPs[coalitionId].bpId
    local priortyCpyId = bc.companyAssignedToBp(coalitionId, priorityBP)
    local clearPriority = false
    if priortyCpyId == -1 then
        env.info("No company assigned to priority BP", false)
        clearPriority = true
    else
        local priorityCompany = Companies[priortyCpyId]
        if priorityCompany then
            if priorityCompany.arrived or priorityCompany:getRemainingStrength() < 60 then
                env.info("priority company arrived or is damaged", false)
                priorityAchieved = true
            end
        else
            env.info("priority company doesn't exist", false)
            clearPriority = false
        end
    end
    if clearPriority then
        env.info("clearing priority", false)
        priorityBP[coalitionId] = 0
        priorityAchieved = true
    end
    return priorityAchieved
end
function bc.main()
    local redPositions = 0
    local bluePositions = 0
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
            if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 2 then
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
        if ownedBy == 1 then redPositions = redPositions + 1 end
        if ownedBy == 2 then bluePositions = bluePositions + 1 end
        if v.ownedBy ~= ownedBy then
            if junkRemoval then
                local junkPoint = v.point
                local junkRadius = v.radius
                local junkSphere = {
                id = world.VolumeType.SPHERE,
                    params = {
                        point = junkPoint,
                        radius = junkRadius
                    }
                }
                world.removeJunk(junkSphere)
            end
            local rcnMissionCltn = 1
            if v.ownedBy == 1 then
                rcnMissionCltn = 2
            end
            local bpReconMarkIds = reconnedBPMarkups[rcnMissionCltn][v.id]
            if bpReconMarkIds then
                for i = 1, #bpReconMarkIds do
                    trigger.action.removeMark(bpReconMarkIds[i])
                end
            end
            if v.reconMarkups.fillIds then
                for i = 1, #v.reconMarkups.fillIds do
                    trigger.action.removeMark(v.reconMarkups.fillIds[i])
                end
            end
            if v.reconMissionId ~= -1 and v.ownedBy ~= 0 then
                Recon.cleanmission(rcnMissionCltn, v.reconMissionId)
            end
            if ownedBy ~= 0 then
                local reconCoalitionId = 1
                if ownedBy == 1 then reconCoalitionId = 2 end
                v.reconMissionId = Recon.createBPScoutingMission(reconCoalitionId, v.point, v.id, true)
                bc.notifyTeamofBPChange(ownedBy, ownedBy, v.id, true)
                bc.notifyTeamofBPChange(v.ownedBy, ownedBy, v.id, false)
            else
                bc.notifyTeamofBPChange(v.ownedBy, ownedBy, v.id, false)
            end
            v.ownedBy = ownedBy
        end
    end
    DFS.status[1].health = redPositions
    DFS.status[2].health = bluePositions
    if redPositions == #battlePositions then
        DFS.endMission(1)
    elseif bluePositions == #battlePositions then
        DFS.endMission(2)
    end
    bc.deployments()
    bc.savePriorities()
    timer.scheduleFunction(bc.main, nil, timer:getTime() + 120)
end
function bc.assignPriorityBp(coalitionId, bpId, priority)
    env.info("new priority BP for " .. coalitionId .. " ID: " .. bpId .. " priority: " .. priority, false)
    if priorityBPs[coalitionId].bpId ~= 0 then
        for i = 1, #priorityMarkupIds[coalitionId] do
            local markId = priorityMarkupIds[coalitionId][i]
            if markId then trigger.action.removeMark(markId) end
        end
    end
    priorityBPs[coalitionId].bpId = bpId
    priorityBPs[coalitionId].priority = priority
    local priorityString = ""
    if priority == "CAPTURE" then
        priorityString = "Our priority objective is to capture Battle Position " .. bpId .. "! Friendly ground forces are en route, give them air support."
    elseif priority == "REINFORCE" then
        priorityString = "Our priority objective is to hold Battle Position " .. bpId .. "! Provide air support until reinforcements arrive."
    end
    trigger.action.outTextForCoalition(coalitionId, priorityString, 60, false)
    local battlePosition = battlePositions[bpId]
    if battlePosition then
        local priorityPoint = {x = battlePosition.point.x, y = 0, z = battlePosition.point.z - battlePosition.radius - 200}
        priorityMarkupIds[coalitionId] = DrawingTools.drawPriorityMarker(coalitionId, priorityPoint, priority)
        env.info("priority marker draw", false)
    end
end
function bc.companyAssignedToBp(coalitionId, targetbp)
    local cpyAlreadyAssignedToBP = false
    for i = 1, #CompanyIDs[coalitionId] do
        local company = Companies[CompanyIDs[coalitionId][i]]
        if company then
            if company.bp == targetbp then
                cpyAlreadyAssignedToBP = true
            end
        end
    end
    return cpyAlreadyAssignedToBP
end
function bc.getCompanyAssignedToBp(coalitionId, targetbp)
    local assignedCompanyId = -1
    for i = 1, #CompanyIDs[coalitionId] do
        if Companies[CompanyIDs[coalitionId][i]].bp == targetbp then
            assignedCompanyId = CompanyIDs[coalitionId][i]
        end
    end
    return assignedCompanyId
end
function bc.companyToStrength(companyTable)
    if companyTable == nil then return 0 end
    local cpyStrength = 0
    for i = 1, #companyTable do
        cpyStrength = cpyStrength + pltStrengths[companyTable[i]]
    end
    return cpyStrength
end
function bc.getReinforcementNeeded(currentBpStrength, strengthToHold)
    local strDiff = strengthToHold - currentBpStrength
    if strDiff < 1 then return nil end
    local reinforcementsTable = {}
    local loopCount = 0
    while strDiff > 1 do
        local addedStr = 0
        if pltStrengths[1] < strDiff then
            table.insert(reinforcementsTable, 1)
            addedStr = pltStrengths[1]
        elseif pltStrengths[2] < strDiff then
            table.insert(reinforcementsTable, 2)
            addedStr = pltStrengths[2]
        else
            table.insert(reinforcementsTable, 3)
            addedStr = pltStrengths[3]
        end
        loopCount = loopCount + 1
        strDiff = strDiff - addedStr
        if loopCount > 30 then
            trigger.action.outText("INFINITE LOOP REEEEEEE", 10, false)
            break
        end
    end
    env.info("reinforcements required: " .. Utils.dump(reinforcementsTable), false)
    return reinforcementsTable
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
function bc.sendCompany(coalitionId, targetBP, spawnDepot, strengthTableTier, desperate, overrideTable)
    if strengthTableTier > 0 or overrideTable then
        local strengthTable = companyCompTiers[strengthTableTier].composition
        if strengthTable or overrideTable then
            local startPoint = trigger.misc.getZone(DFS.spawnNames[coalitionId].depot..spawnDepot).point
            startPoint.x = startPoint.x + 50
            startPoint.z = startPoint.z + 50
            local destination = trigger.misc.getZone(battlePositions[targetBP].zoneName).point
            local companyCost = bc.companyToCost(strengthTable)
            local canAfford = true
            for i = 1, 3 do
                if DFS.status[coalitionId].supply.front[i] < companyCost[i] then
                    canAfford = false
                end
            end
            if overrideTable then
                local overrideCost = bc.companyToCost(overrideTable)
                for i = 1, 3 do
                    if DFS.status[coalitionId].supply.front[i] < overrideCost[i] then
                        canAfford = false
                    end
                end
            end
            if (strengthTable or overrideTable) and canAfford then
                local newCpy = {}
                if overrideTable then
                    newCpy = Company.new(coalitionId, true, overrideTable, false)
                else
                    newCpy = Company.new(coalitionId, true, strengthTable, false)
                end
                Companies[newCpy.id] = newCpy
                table.insert(CompanyIDs[newCpy.coalitionId], newCpy.id)
                newCpy:setWaypoints({startPoint, destination}, targetBP, 999)
                newCpy:spawn()
                DFS.decreaseFrontSupply({coalitionId = coalitionId, type = DFS.supplyType.EQUIPMENT, amount = companyCost[DFS.supplyType.EQUIPMENT]})
                DFS.decreaseFrontSupply({coalitionId = coalitionId, type = DFS.supplyType.FUEL, amount = companyCost[DFS.supplyType.FUEL]})
                DFS.decreaseFrontSupply({coalitionId = coalitionId, type = DFS.supplyType.AMMO, amount = companyCost[DFS.supplyType.AMMO]})
            elseif overrideTable == nil then
                env.info(coalitionId .. " - Cannot send company this company, not enough supply.", false)
                if desperate then
                    env.info(coalitionId .. " - Cannot send company this company. Trying lower tier.", false)
                    strengthTableTier = strengthTableTier + 1
                    if strengthTableTier < 10 then
                        bc.sendCompany(coalitionId, targetBP, spawnDepot, strengthTableTier, desperate)
                    end
                end
            end
        end
    else
        env.info(coalitionId .. " - Cannot send company this company, not enough supply", false)
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
function bc.getAvailableStrengthTableTier(coalitionId)
    local availableEquipmentPct =  bc.availableEquipmentPct(coalitionId)
    local cpyTier = math.ceil((100-availableEquipmentPct)/10)
    if cpyTier == 0 then cpyTier = 1 end
    if cpyTier < 10 then
        return cpyTier
    else
        return 0
    end
end
function bc.availableEquipmentPct(coalitionId)
    return math.floor(DFS.status[coalitionId].supply.front[DFS.supplyType.EQUIPMENT] / DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT] * 100)
end
function bc.notifyTeamofBPChange(coalitionId, newOwnerCoalition, bpId, gained)
    local bpIdString = tostring(bpId)
    local message = ""
    local audioMessage = nil
    if gained then
        local teamString = "Red"
        if coalitionId == 2 then teamString = "Blue" end
        if WWEvents then WWEvents.battlePositionCapture(bpId, "  captured by " .. teamString) end
        message = "We have captured battle position " .. bpIdString .. "!"
        audioMessage = radioObjectiveMessages["complete"]
    else
        if newOwnerCoalition == 1 or newOwnerCoalition == 2 then
            message = "The enemy has taken battle position " .. bpIdString .."!"
            audioMessage = radioObjectiveMessages["failed"]
        else
            message = "Our units in battle position " .. bpIdString .. " have been destroyed!"
            audioMessage = radioObjectiveMessages["failed"]
        end
    end
    trigger.action.outTextForCoalition(coalitionId, message, 30, false)
    if audioMessage then
        trigger.action.outSoundForCoalition(coalitionId, audioMessage)
    end
end

bc.getPositions()
bc.setBPMarkups()
bc.loadPriorities()
bc.main()