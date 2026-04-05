--check BPs for ownership
BattleControl = {}
PltCosts = {
    [1] = {
        [1] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.FUEL]/8), --fuel
        [2] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.AMMO]/10), --ammo
        [3] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/8), --equipment
    },
    [2] = {
        [1] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/16), --fuel
        [2] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/16), --ammo
        [3] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/16), --equipment
    },
    [3] = {
        [1] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --fuel
        [2] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --ammo
        [3] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --equipment
    },
    [7] = {
        [1] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --fuel
        [2] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/16), --ammo
        [3] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --equipment
    },
    [9] = {
        [1] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --fuel
        [2] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/16), --ammo
        [3] = math.floor(DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]/24), --equipment
    },
}
local attackPlan = {
    attackingCoalition = 0,
    targetBPs = {},
    startTime = 0,
    startTimeString = "",
    requiredSupply = {},
    markups = {
        orders = {},
        supplies = {},
        attackPoints = {},
    },
    status = "PREP",
    attackingCompanyIds = {},
}
local attackPlanFiled = {
    [1] = false,
    [2] = false,
}
local attackPlans = {
    [1] = nil,
    [2] = nil
}
local maxCapAmount = 3
local maxAttackDuration = 2700
local positionsCountLimit = 20
local bpRequiredStrength = 1
local junkRemoval = true
local bc = {}
local bcmarkups = {
    lines = {
        [0] = {0,0,0,1},
        [1] = {1,0,0,1},
        [2] = {0,0,1,1}
    },
    fills = {
        [0] = {0,0,0,0.5},
        [1] = {1,0,0,0.5},
        [2] = {0,0,1,0.5}
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
local radioObjectiveMessages = {
    ["complete"] = "l10n/DEFAULT/ObjectiveComplete.ogg",
    ["failed"] = "l10n/DEFAULT/ObjectiveFailed.ogg",
}

function BattleControl.reconBP(coalitionId, bpID, markIds)
    reconnedBPs[coalitionId][bpID] = true
    reconnedBPMarkups[coalitionId][bpID] = markIds
    bc.fillCamera(coalitionId,bpID)
end
function BattleControl.revealPlan(coalitionId)
    local enemyCoalitionId = 2
    if coalitionId == 2 then enemyCoalitionId = 1 end
    if attackPlans[1] and attackPlans[2] then
        local defendMarks = {}
        if attackPlans[coalitionId].targetBPs then
            for i = 1, #attackPlans[coalitionId].targetBPs do
                local targetBP = attackPlans[coalitionId].targetBPs[i]
                if targetBP then
                    if BattleControl.getBPOwner(targetBP.id) == enemyCoalitionId then
                        local bpPoint = BattleControl.getBPPoint(targetBP.id)
                        if bpPoint then
                            table.insert(defendMarks, DrawingTools.drawShield(enemyCoalitionId, {x = bpPoint.x + 200, y = 0, z = bpPoint.z + 200}))
                        end
                    end
                end
            end
            if #defendMarks > 0 then
                attackPlans[enemyCoalitionId].markups.revealed = defendMarks
                local drawingOriginFrontZone = trigger.misc.getZone(DFS.spawnNames[enemyCoalitionId].frontSupplyDrawing)
                if drawingOriginFrontZone then
                    local drawingOriginFront = drawingOriginFrontZone.point
                    local markId = DrawingTools.newMarkId()
                    trigger.action.textToAll(enemyCoalitionId, markId, {x = drawingOriginFront.x -300, y = drawingOriginFront.y, z = drawingOriginFront.z}, {0,0,0,1}, {1,0.9,0.8,0.9}, 14, true, "  The enemy attack plans have been captured!\n  Defend the marked objectives from their attack!  ")
                    attackPlans[enemyCoalitionId].markups.revealedText = markId
                end
            end
        end
    end
end
function BattleControl.endMission()
    return
end
function BattleControl.getClosestBp(location)
    local distance = -1
    local closestBp = -1
    for bpId, values in pairs(battlePositions) do
        local distanceToBp = Utils.PointDistance(location, values.point)
        if distance == -1 or distanceToBp < distance then
            closestBp = values.id
            distance = distanceToBp
        end
    end
    return closestBp, distance
end
function BattleControl.getBPPoint(bpId)
    local returnPoint = nil
    local position = battlePositions[bpIds[bpId]]
    if position then
        returnPoint = position.point
    end
    return returnPoint
end
function BattleControl.getBPOwner(bpId)
    local ownedBy = nil
    local position = battlePositions[bpIds[bpId]]
    if position then
        ownedBy = position.ownedBy
    end
    return ownedBy
end
function BattleControl.getAvailableStrengthTableTier(params)
    return bc.getAvailableStrengthTableTier(params.coalitionId)
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
    local bpCount = #battlePositions
    env.info("Loaded " .. bpCount .. " battle positions.", false)
    trigger.action.setUserFlag("TOTAL_BPS", bpCount)
end
--set markups
function bc.setBPMarkups()
    for k,v in pairs(battlePositions) do
        if v.markupId == 0 then
            local newMarkId = DrawingTools.newMarkId()
            trigger.action.circleToAll(-1, newMarkId, v.point, v.radius, bcmarkups.lines[v.ownedBy], bcmarkups.fills[v.ownedBy], 1, true, "")
            DrawingTools.numberBP(v.point, v.radius, v.id, #battlePositions)
            v.markupId = newMarkId
        else
            trigger.action.setMarkupColorFill(v.markupId, bcmarkups.fills[v.ownedBy])
        end
    end
    timer.scheduleFunction(bc.setBPMarkups, nil, timer:getTime() + 10)
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

--new battle logic:
--pick a number of BPs to attack
--determine strength of companies needed to attack
--create attack order markup so players can see target BPs, supplies needed, and attack start time.
--when start time is reached, the attack happens no matter what. If the supply state is not adequate for the desired companies, send a lower tier.
--the number of target BPs is determined by how many neutral are available and the expected enemy strength. Strong enemy and no neutral BPs leads to lower attacked BPs.
--the "ideal" attack for a max strength team against a weak opponent / neutral BPs is taking 3 BPs with max strength companies (1 tank platoon + 2 mobile infantry platoons.)
function bc.deployments()
    for c = 1,2 do
        if not attackPlanFiled[c] then
            env.info("beginning deployment loop team: " .. c, false)
            -- step one, determine the number of target BPs. 
            local enemyCoalition = 2
            if c == 2 then enemyCoalition = 1 end
            local neutralBPs = {}
            local friendlyBPs = {}
            local enemyBPs = {}
            for k, v in pairs(battlePositions) do
                local bpPoint = v.point
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
                if v.ownedBy == 0 then
                    if bc.companyAssignedToBp(c, k) == false then
                        table.insert(neutralBPs, {bpId = k, distance = closerDistance, fromDepot = closerDepot, ownedBy = v.ownedBy})
                    end
                elseif v.ownedBy == enemyCoalition then
                    if bc.companyAssignedToBp(c, k) == false then
                        table.insert(enemyBPs, {bpId = k, distance = closerDistance, fromDepot = closerDepot, ownedBy = v.ownedBy})
                    end
                elseif v.ownedBy == c then
                    if bc.needsReinforcement(c, v.id) and bc.companyAssignedToBp(c, k) == false then
                        table.insert(friendlyBPs, {bpId = k, distance = closerDistance, fromDepot = closerDepot, ownedBy = v.ownedBy})
                    end
                end
            end
            env.info("bp lists created", false)
            if #neutralBPs == 0 and #enemyBPs == 0 and #friendlyBPs == 0 then
                env.info("No valid BPs for team: " .. c, false)
            else
                table.sort(neutralBPs, function(a, b) return a.distance < b.distance end)
                table.sort(enemyBPs, function(a, b) return a.distance < b.distance end)
                table.sort(friendlyBPs, function(a, b) return a.distance < b.distance end)
                env.info("bp lists sorted", false)
                local newAttackPlan = Utils.deepcopy(attackPlan)
                newAttackPlan.attackingCoalition = c
                local assignedBPs = 0
                if assignedBPs < maxCapAmount then
                    env.info("looking for reinforce", false)
                    if friendlyBPs[1] then
                        env.info("reinforce found", false)
                        table.insert(newAttackPlan.targetBPs, {id = friendlyBPs[1].bpId, state = "F"})
                    end
                    if friendlyBPs[2] then
                        env.info("second reinforce found", false)
                        table.insert(newAttackPlan.targetBPs, {id = friendlyBPs[2].bpId, state = "F"})
                    end
                end
                if #neutralBPs > 0 then
                    env.info("neutral BP assignment", false)
                    while assignedBPs < 3 do
                        if neutralBPs[assignedBPs+1] then
                            local bp = neutralBPs[assignedBPs+1]
                            if bp then
                                table.insert(newAttackPlan.targetBPs, {id = bp.bpId, state = "N", fromDepot = bp.fromDepot})
                                assignedBPs = assignedBPs + 1
                            end
                        else
                            break
                        end
                    end
                end
                if assignedBPs < maxCapAmount then
                    env.info("assigning additional BPs", false)
                    local amountCanCap = 1
                    amountCanCap = bc.findCanCap(c)
                    local leftToAssign = maxCapAmount - assignedBPs
                    local bpsToAttack = amountCanCap
                    if amountCanCap > leftToAssign then
                        bpsToAttack = leftToAssign
                    end
                    for i = 1, bpsToAttack do
                        if enemyBPs[i] then
                            local bp = enemyBPs[i]
                            if bp then
                                table.insert(newAttackPlan.targetBPs, {id = bp.bpId, state = "E", fromDepot = bp.fromDepot} )
                                assignedBPs = assignedBPs + 1
                            end
                        end
                    end
                end
                -- battle plan now how a full list of target BPs. Create plan markup and determine needed tiers.
                -- For enemy BPs, send strongest possible
                -- For neutral BPs, send mid tier
                -- For friendly BPs, send a smaller group but strong unit like tank or IFV
                bc.prepareAttack(newAttackPlan)
                attackPlanFiled[c] = true
            end
        end
    end
end
function bc.prepareAttack(filedAttackPlan)
    env.info("preparing attack for team: " .. filedAttackPlan.attackingCoalition, false)
    -- determine amount of supplies needed for attack
    -- set attack time roughly based on how much supply is currently needed at the front depots
    -- minimum attack start time is 20 minutes - 1200s
    -- maximum attack start time is 50 minutes - 3000s
    local requiredSupply = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    }
    local targetBPString =  ""
    for i = 1, #filedAttackPlan.targetBPs do
        env.info("adding up costs", false)
        local targetBP = filedAttackPlan.targetBPs[i]
        if targetBP then
            if string.len(targetBPString) > 0 then
                targetBPString = targetBPString .. ","
            end
            targetBPString = targetBPString .. targetBP.id
            if targetBP.state == "E" then
                env.info("calc enemy cost", false)
                local bpSupply = bc.companyToCost(CompanyCompTiers[1].composition)
                bc.costAdd(requiredSupply, bpSupply)
            elseif targetBP.state == "N" then
                env.info("calc neutral cost", false)
                local bpSupply = bc.companyToCost(CompanyCompTiers[5].composition)
                bc.costAdd(requiredSupply, bpSupply)
            elseif targetBP.state == "F" then
                env.info("calc reinforce cost", false)
                local bpSupply = bc.companyToCost({1})
                bc.costAdd(requiredSupply, bpSupply)
            else
                env.info("something is fucked up", false)
                trigger.action.outText("Something is fucked up", 10, false)
                break
            end
        end
    end
    filedAttackPlan.requiredSupply = requiredSupply
    filedAttackPlan.targetBPString = targetBPString
    local supplyDelta = {
        [1] = DFS.status[filedAttackPlan.attackingCoalition].supply.front[1] - requiredSupply[1],
        [2] = DFS.status[filedAttackPlan.attackingCoalition].supply.front[2] - requiredSupply[2],
        [3] = DFS.status[filedAttackPlan.attackingCoalition].supply.front[3] - requiredSupply[3],
    }
    local timePenalty = 1200
    for i = 1, 3 do
        if supplyDelta[i] < 0 then
            -- if another convoy is needed, add 10 minutes
            timePenalty = timePenalty + 600
        end
    end
    local startTime = timer:getTime() + timePenalty
    local startTimeAbs = timer:getAbsTime() + timePenalty
    local startTimeHours = math.floor(startTimeAbs/3600)
    local startTimeMinutes = tostring(math.floor((startTimeAbs-(startTimeHours*3600))/60))
    if string.len(startTimeMinutes) == 1 then
        startTimeMinutes = "0"..startTimeMinutes
    end
    filedAttackPlan.startTime = startTime
    filedAttackPlan.startTimeString = startTimeHours..":"..startTimeMinutes
    timer.scheduleFunction(bc.executeAttack, filedAttackPlan, startTime)
    env.info("start time determined", false)
    for i = 1, #filedAttackPlan.targetBPs do
        env.info("marking target BPs", false)
        local bpPoint = Utils.deepcopy(BattleControl.getBPPoint(filedAttackPlan.targetBPs[i].id))
        if bpPoint then
            bpPoint.z = bpPoint.z - 300
            local markIds = DrawingTools.drawSwords(filedAttackPlan.attackingCoalition, bpPoint)
            table.insert(filedAttackPlan.markups.attackPoints, markIds)
        end
    end
    if WWEvents then
        WWEvents.attackScheduled(filedAttackPlan.attackingCoalition, math.floor(timePenalty/60), targetBPString, (timePenalty>1200))
    end
    attackPlans[filedAttackPlan.attackingCoalition] = filedAttackPlan
    bc.drawRequiredSupplies(filedAttackPlan)
    bc.drawAttackMsg(filedAttackPlan)
end
function bc.executeAttack(filedAttackPlan)
    env.info("executing attack for team " .. filedAttackPlan.attackingCoalition, false)
    if filedAttackPlan.status == "PREP" then
        if #DFS.status[filedAttackPlan.attackingCoalition].spawns.fd > 0 then
            local supplyRequiredForCurrentCompanies = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            }
            for i = 1, #filedAttackPlan.targetBPs do
                local targetBP = filedAttackPlan.targetBPs[i]
                if targetBP then
                    if targetBP.state == "N" then
                        targetBP.attackWithTier = 5
                        targetBP.attackWith = CompanyCompTiers[targetBP.attackWithTier].composition
                        targetBP.canLower = true
                        bc.costAdd(supplyRequiredForCurrentCompanies, bc.companyToCost(targetBP.attackWith))
                    elseif targetBP.state == "E" then
                        targetBP.attackWithTier = 1
                        targetBP.attackWith = CompanyCompTiers[targetBP.attackWithTier].composition
                        targetBP.canLower = true
                        bc.costAdd(supplyRequiredForCurrentCompanies, bc.companyToCost(targetBP.attackWith))
                    elseif targetBP.state == "F" then
                        targetBP.attackWith = {1}
                        targetBP.canLower = true
                        bc.costAdd(supplyRequiredForCurrentCompanies, bc.companyToCost(targetBP.attackWith))
                    end
                end
            end
            local canAffordAttack = bc.sufficient(DFS.status[filedAttackPlan.attackingCoalition].supply.front, supplyRequiredForCurrentCompanies)
            local loopTries = 0
            while canAffordAttack == false do
                env.info("Cannot afford attack, lowering tiers", false)
                loopTries = loopTries + 1
                if loopTries > 100 then
                    trigger.action.outText("INFINITE LOOP REEEEEEEEE", 10, false)
                    return
                end
                supplyRequiredForCurrentCompanies = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                }
                for i = 1, #filedAttackPlan.targetBPs do
                    local canlowercount = 0
                    local targetBP = filedAttackPlan.targetBPs[i]
                    if targetBP and targetBP.canLower then
                        canlowercount = canlowercount + 1
                        if targetBP.attackWithTier then
                            targetBP.attackWithTier = targetBP.attackWithTier + 1
                            targetBP.attackWith = CompanyCompTiers[targetBP.attackWithTier].composition
                            if targetBP.attackWithTier == 10 then
                                targetBP.canLower = false
                            end
                        else
                            targetBP.attackWith[1] = targetBP.attackWith[1] + 1
                            if targetBP.attackWith[1] == 3 then
                                targetBP.canLower = false
                            end
                        end
                        bc.costAdd(supplyRequiredForCurrentCompanies, bc.companyToCost(targetBP.attackWith))
                    elseif canlowercount == 0 then
                        trigger.action.outTextForCoalition(filedAttackPlan.attackingCoalition, "Our attack has been delayed because of insufficient materiel!\nProtect our convoys and deliver supplies to our front depots!", 10, false)
                        bc.rescheduleAttack(filedAttackPlan)
                        return
                    end
                end
                canAffordAttack = bc.sufficient(DFS.status[filedAttackPlan.attackingCoalition].supply.front, supplyRequiredForCurrentCompanies)
            end
            DFS.decreaseFrontSupply(({coalitionId = filedAttackPlan.attackingCoalition, type = DFS.supplyType.FUEL, amount = supplyRequiredForCurrentCompanies[DFS.supplyType.FUEL]}))
            DFS.decreaseFrontSupply(({coalitionId = filedAttackPlan.attackingCoalition, type = DFS.supplyType.AMMO, amount = supplyRequiredForCurrentCompanies[DFS.supplyType.AMMO]}))
            DFS.decreaseFrontSupply(({coalitionId = filedAttackPlan.attackingCoalition, type = DFS.supplyType.EQUIPMENT, amount = supplyRequiredForCurrentCompanies[DFS.supplyType.EQUIPMENT]}))
            for i = 1, #filedAttackPlan.targetBPs do
                local targetBP = filedAttackPlan.targetBPs[i]
                if targetBP then
                    local fromDepot = targetBP.fromDepot
                    if not DFS.depotActive(filedAttackPlan.attackingCoalition, targetBP.fromDepot) then
                        if DFS.status[filedAttackPlan.attackingCoalition].spawns.fd[1] then
                            fromDepot = DFS.status[filedAttackPlan.attackingCoalition].spawns.fd[1].spawnZone
                        end
                    end
                    local sentCpyId = bc.sendCompany(filedAttackPlan.attackingCoalition, targetBP.id, fromDepot, targetBP.attackWith)
                    if sentCpyId then
                        table.insert(filedAttackPlan.attackingCompanyIds, sentCpyId)
                    end
                end
            end
            filedAttackPlan.status = "EXECUTING"
            trigger.action.setMarkupText(filedAttackPlan.markups.orders, "  ATTACK IS IN PROGRESS\n  Support the attack on the marked battle positions!  ")
            if WWEvents and filedAttackPlan.targetBPString then
                WWEvents.attackStarted(filedAttackPlan.attackingCoalition, filedAttackPlan.targetBPString)
            end
            for i = 1, #filedAttackPlan.markups.supplies do
                trigger.action.removeMark(filedAttackPlan.markups.supplies[i])
            end
            bc.followAttack(filedAttackPlan)
            env.info("Attack plan execution complete", false)
        else
            trigger.action.outTextForCoalition(filedAttackPlan.attackingCoalition, "Our attack has been delayed because our front depots are destroyed!\nProtect our front depots!!", 30, false)
            bc.rescheduleAttack(filedAttackPlan)
        end
    end
end
function bc.rescheduleAttack(filedAttackPlan)
    local startTime = timer:getTime() + 1200
    local startTimeAbs = timer:getAbsTime() + 1200
    local startTimeHours = math.floor(startTimeAbs/3600)
    local startTimeMinutes = tostring(math.floor((startTimeAbs-(startTimeHours*3600))/60))
    if string.len(startTimeMinutes) == 1 then
        startTimeMinutes = "0"..startTimeMinutes
    end
    filedAttackPlan.startTime = startTime
    filedAttackPlan.startTimeString = startTimeHours..":"..startTimeMinutes
    timer.scheduleFunction(bc.executeAttack, filedAttackPlan, startTime)
    trigger.action.setMarkupText(filedAttackPlan.markups.orders,"  Attacking marked Battle Positions at " .. filedAttackPlan.startTimeString.." local time.\n  Ensure all front supply meters are above the orange lines for an effective attack!  ")
end
function bc.followAttack(filedAttackPlan)
    if timer:getTime() - filedAttackPlan.startTime < maxAttackDuration then
        local targetBPCount = #filedAttackPlan.targetBPs
        local ownedBPs = 0
        for i = 1, #filedAttackPlan.targetBPs do
            if BattleControl.getBPOwner(filedAttackPlan.targetBPs[i].id) == filedAttackPlan.attackingCoalition then
                ownedBPs = ownedBPs + 1
            end
        end
        if targetBPCount == ownedBPs then
            trigger.action.outTextForCoalition(filedAttackPlan.attackingCoalition, "Our attack was a success! Keep up the good work!", 30, false)
            if WWEvents and filedAttackPlan.targetBPString then
                WWEvents.attackCompleted(filedAttackPlan.attackingCoalition, "success", filedAttackPlan.targetBPString)
            end
            env.info(filedAttackPlan.attackingCoalition .. " team attack success", false)
            bc.cleanupAttack(filedAttackPlan)
            return
        end
        local livingCpyCount = 0
        for i = 1, #filedAttackPlan.attackingCompanyIds do
            local cpy = Companies[filedAttackPlan.attackingCompanyIds[i]]
            if cpy then
                local cpyGroup = Group.getByName(cpy.groupName)
                if cpyGroup then
                    livingCpyCount = livingCpyCount + 1
                end
            end
        end
        if livingCpyCount > 0 and livingCpyCount >= targetBPCount then
            env.info(filedAttackPlan.attackingCoalition .. " team attack in progress", false)
            timer.scheduleFunction(bc.followAttack, filedAttackPlan, timer:getTime() + 60)
        elseif livingCpyCount > 0 and livingCpyCount < targetBPCount then
            if ownedBPs == livingCpyCount then
                trigger.action.outTextForCoalition(filedAttackPlan.attackingCoalition, "Our attack was only a partial success!\nWe need support for our attacking companies!", 30, false)
                env.info(filedAttackPlan.attackingCoalition .. " team attack partial success, captured " .. ownedBPs .. " objectives.", false)
                if WWEvents then
                    WWEvents.attackCompleted(filedAttackPlan.attackingCoalition, "partial success")
                end
                bc.cleanupAttack(filedAttackPlan)
                return
            end
            env.info(filedAttackPlan.attackingCoalition .. " team attack in progress", false)
            timer.scheduleFunction(bc.followAttack, filedAttackPlan, timer:getTime() + 60)
        else
            trigger.action.outTextForCoalition(filedAttackPlan.attackingCoalition, "Our attack was a complete failure!\nWe need support for our attacking companies!", 30, false)
            env.info(filedAttackPlan.attackingCoalition .. " team attack failed", false)
            if WWEvents then
                    WWEvents.attackCompleted(filedAttackPlan.attackingCoalition, "failure")
                end
            bc.cleanupAttack(filedAttackPlan)
            return
        end
    else
        trigger.action.outTextForCoalition(filedAttackPlan.attackingCoalition, "Our attack has stalled out!\nWe are planning a follow up attack!", 30, false)
        env.info(filedAttackPlan.attackingCoalition .. " team attack stalled", false)
        bc.cleanupAttack(filedAttackPlan)
        return
    end
end
function bc.cleanupAttack(filedAttackPlan)
    attackPlanFiled[filedAttackPlan.attackingCoalition] = false
    attackPlans[filedAttackPlan] = nil
    --remove all markups
    if filedAttackPlan.markups.supplies then
        for i = 1, #filedAttackPlan.markups.supplies do
            trigger.action.removeMark(filedAttackPlan.markups.supplies[i])
        end
    end
    if filedAttackPlan.markups.orders then
        trigger.action.removeMark(filedAttackPlan.markups.orders)
    end
    if filedAttackPlan.markups.attackPoints then
        for i = 1, #filedAttackPlan.markups.attackPoints do
            local attackPoint = filedAttackPlan.markups.attackPoints[i]
            for j = 1, #attackPoint do
                trigger.action.removeMark(attackPoint[j])
            end
        end
    end
    if filedAttackPlan.markups.revealed then
        for i = 1, #filedAttackPlan.markups.revealed do
            local defendPoint = filedAttackPlan.markups.revealed[i]
            if defendPoint then
                trigger.action.removeMark(defendPoint)
            end
        end
    end
    if filedAttackPlan.markups.revealedText then
        trigger.action.removeMark(filedAttackPlan.markups.revealedText)
    end
end
function bc.costAdd(table1, table2)
    for i = 1,3 do
        table1[i] = table1[i] + table2[i]
    end
end
function bc.sufficient(supplyTable, costTable)
    local sufficient = true
    for i = 1, 3 do
        local supplyDelta = supplyTable[i] - costTable[i]
        if supplyDelta < 0 then
            sufficient = false
        end
    end
    return sufficient
end
function bc.drawRequiredSupplies(filedAttackPlan)
    local coalitionId = filedAttackPlan.attackingCoalition
    local requiredSupply = filedAttackPlan.requiredSupply
    local drawingOriginFrontZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].frontSupplyDrawing)
    if drawingOriginFrontZone then
        local drawingOriginFront = drawingOriginFrontZone.point
        for i = 1, 3 do
            local boxOrigin = {x = drawingOriginFront.x, y = drawingOriginFront.y, z = drawingOriginFront.z - (DFS.supplyDrawing.counterOffeset*i)}
            local xOffset = (DFS.supplyDrawing.counterHeight * (requiredSupply[i]/DFS.status.maxSuppliesFront[i]))
            local supplyCounterLineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z}
            local supplyCounterLineEnd = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
            local fillId = DrawingTools.newMarkId()
            trigger.action.lineToAll(coalitionId, fillId, supplyCounterLineStart, supplyCounterLineEnd, {1, 0.5, 0, 1}, 1, true, nil)
            table.insert(filedAttackPlan.markups.supplies, fillId)
        end
    end
end
function bc.drawAttackMsg(filedAttackPlan)
    local drawingOriginFrontZone = trigger.misc.getZone(DFS.spawnNames[filedAttackPlan.attackingCoalition].frontSupplyDrawing)
    if drawingOriginFrontZone then
        local drawingOriginFront = drawingOriginFrontZone.point
        local markId = DrawingTools.newMarkId()
        trigger.action.textToAll(filedAttackPlan.attackingCoalition, markId, {x = drawingOriginFront.x + 300, y = drawingOriginFront.y, z = drawingOriginFront.z}, {0,0,0,1}, {1,0.9,0.8,0.9}, 14, true, "  Attacking marked Battle Positions at " .. filedAttackPlan.startTimeString.."\n  Ensure all front supply meters are above the orange lines for an effective attack!  ")
        filedAttackPlan.markups.orders = markId
    end
end
function bc.main()
    if not MissionOver then
        local redPositions = 0
        local bluePositions = 0
        local positionNotifications = {}
        local checkTime = timer.getTime()
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
                local bpStrength = bc.getRealBpStrength(2, v.id)
                env.info("Blue units ("..blueUnits ..") outnumber red (" .. redUnits .. ") in BP: " .. v.id.."\nBP Stregnth: " .. bpStrength, false)
                if bpStrength > bpRequiredStrength then
                    ownedBy = 2
                end
            elseif redUnits > blueUnits then
                local bpStrength = bc.getRealBpStrength(1, v.id)
                env.info("Red units ("..redUnits ..") outnumber blue (" .. blueUnits .. ") in BP: " .. v.id.."\nBP Stregnth: " .. bpStrength, false)
                if bpStrength > bpRequiredStrength then
                    ownedBy = 1
                end
            else
                env.info("No units found in BP: " ..v.id, false)
            end
            if ownedBy == 1 then redPositions = redPositions + 1 end
            if ownedBy == 2 then bluePositions = bluePositions + 1 end
            if v.ownedBy ~= ownedBy then
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
                    if checkTime > 10 then
                        table.insert(positionNotifications, {coalitionId = ownedBy, newCoalitionId = ownedBy, bpId = v.id, gained = true, prevCoalition = v.ownedBy})
                        table.insert(positionNotifications, {coalitionId = v.ownedBy, newCoalitionId = ownedBy, bpId = v.id, gained = false, prevCoalition = v.ownedBy})
                    end
                else
                    if checkTime > 10 then
                        table.insert(positionNotifications, {coalitionId = v.ownedBy, newCoalitionId = ownedBy, bpId = v.id, gained = false, prevCoalition = v.ownedBy})
                    end
                end
                v.ownedBy = ownedBy
            end
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
                ---world.removeJunk(junkSphere)
                timer.scheduleFunction(world.removeJunk, junkSphere, timer:getTime() + 300)
            end
        end
        DFS.status[1].health = redPositions
        DFS.status[2].health = bluePositions
        for i = 1, #positionNotifications do
            local notification = positionNotifications[i]
            if notification then
                bc.notifyTeamofBPChange(notification.coalitionId, notification.newCoalitionId, notification.bpId, notification.gained, notification.prevCoalition)
                if notification.gained == false and notification.coalitionId ~= 0 then
                    if CSAR then
                        env.info("About to call CSB.createCasEvac from battlecontroller with coalitionId: " .. notification.coalitionId .. " | bpId: " .. notification.bpId .. " | newCoalitionId: " .. notification.newCoalitionId .. " | prevCoalition: " .. notification.prevCoalition,false)
                        CSB.createCasEvac(notification.coalitionId, notification.bpId, notification.newCoalitionId)
                    end
                end
            end
        end
        if redPositions == #battlePositions then
            DFS.endMission(1)
        elseif bluePositions == #battlePositions then
            DFS.endMission(2)
        end
        timer.scheduleFunction(bc.deployments, nil, timer:getTime() + 60)
        timer.scheduleFunction(bc.main, nil, timer:getTime() + 30)
    end
end

function bc.findCanCap(coalitionId)
    local enemyCoalition = 2
    if coalitionId == 2 then enemyCoalition = 1 end
    --return math.random(1,3)
    return 3
end
function bc.companyAssignedToBp(coalitionId, targetbp)
    local cpyAlreadyAssignedToBP = false
    for i = 1, #CompanyIDs[coalitionId] do
        local company = Companies[CompanyIDs[coalitionId][i]]
        if company then
            if company.bp == targetbp and company.arrived == false then
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
        cpyStrength = cpyStrength + PltStrengths[companyTable[i]]
    end
    return cpyStrength
end
function bc.companyToCost(companyTable)
    local cpyCost = {
        [DFS.supplyType.FUEL] = 0,
        [DFS.supplyType.AMMO] = 0,
        [DFS.supplyType.EQUIPMENT] = 0,
    }
    if companyTable then
        for i = 1, #companyTable do
            local pltCost = PltCosts[companyTable[i]]
            if pltCost then
                cpyCost[DFS.supplyType.FUEL] = cpyCost[DFS.supplyType.FUEL] + PltCosts[companyTable[i]][DFS.supplyType.FUEL]
                cpyCost[DFS.supplyType.AMMO] = cpyCost[DFS.supplyType.AMMO] + PltCosts[companyTable[i]][DFS.supplyType.AMMO]
                cpyCost[DFS.supplyType.EQUIPMENT] = cpyCost[DFS.supplyType.EQUIPMENT] + PltCosts[companyTable[i]][DFS.supplyType.EQUIPMENT]
            end
        end
    end
    return cpyCost
end
function bc.sendCompany(coalitionId, targetBP, spawnDepot, cpyTable)
    local sentCpyId = nil
    local startZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].depot..spawnDepot)
    if startZone then
        local startPoint = startZone.point
        startPoint.x = startPoint.x + 50
        startPoint.z = startPoint.z + 50
        local destination = trigger.misc.getZone(battlePositions[targetBP].zoneName).point
        local coalitionOffset = 15
        if coalitionId == 2 then coalitionOffset = -15 end
        destination.x = destination.x + coalitionOffset
        destination.z = destination.z + coalitionOffset
        local newCpy = Company.new(coalitionId, true, cpyTable, false)
        if newCpy == nil then return end
        Companies[newCpy.id] = newCpy
        table.insert(CompanyIDs[newCpy.coalitionId], newCpy.id)
        newCpy:setWaypoints({startPoint, destination}, targetBP, 999)
        newCpy:spawn()
        sentCpyId = newCpy.id
    end
    return sentCpyId
end
function bc.needsReinforcement(coalitionId, bpId)
    local battlePosition = battlePositions[bpId]
    local tankCount = 0
    local ifvCount = 0
    local apcCount = 0
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = battlePosition.point,
            radius = battlePosition.radius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() and foundItem:getCoalition() == coalitionId then
            if foundItem:hasAttribute("Tanks") then
                tankCount = tankCount + 1
            elseif foundItem:hasAttribute("IFV") or foundItem:hasAttribute("AA_flak") then
                ifvCount = ifvCount + 1
            elseif foundItem:hasAttribute("APC") then
                apcCount = apcCount + 1
            end
        end
    end
    if tankCount < 2 and (ifvCount + apcCount) < 3 then
        return true
    else
        return false
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
end

function bc.getRealBpStrength(coalitionId, bpId)
    local battlePosition = battlePositions[bpId]
    local positionRealStrength = 0
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = battlePosition.point,
            radius = battlePosition.radius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() and foundItem:getCoalition() == coalitionId then
            if foundItem:hasAttribute("Tanks") then
                positionRealStrength = positionRealStrength + 5
            elseif foundItem:hasAttribute("IFV") or foundItem:hasAttribute("AA_flak") then
                positionRealStrength = positionRealStrength + 3
            elseif foundItem:hasAttribute("APC") then
                positionRealStrength = positionRealStrength + 2
            else
                positionRealStrength = positionRealStrength + 0.25
            end
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    return math.floor(positionRealStrength)
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
    local availableEquipmentPct = bc.availableSupplyPct(coalitionId, DFS.supplyType.EQUIPMENT)
    local availableFuelPct = bc.availableSupplyPct(coalitionId, DFS.supplyType.FUEL)
    local cpyTier = math.ceil((100-availableEquipmentPct)/10)
    if cpyTier == 0 then cpyTier = 1 end
    if cpyTier < 10 then
        if cpyTier == 1 or cpyTier == 2 then
            if availableFuelPct < 33 then
                cpyTier = 3
            end
        end
        return cpyTier
    else
        return 0
    end
end
function bc.availableSupplyPct(coalitionId, supplyType)
    return math.floor(DFS.status[coalitionId].supply.front[supplyType] / DFS.status.maxSuppliesFront[supplyType] * 100)
end
function bc.notifyTeamofBPChange(coalitionId, newOwnerCoalition, bpId, gained, prevCoalition)
    local bpIdString = tostring(bpId)
    local message = ""
    local audioMessage = nil
    if gained then
        local teamString = "Red"
        if coalitionId == 2 then teamString = "Blue" end
        if WWEvents then WWEvents.battlePositionCapture(bpId, " captured by " .. teamString, prevCoalition, newOwnerCoalition) end
        message = "We have captured battle position " .. bpIdString .. "!"
        audioMessage = radioObjectiveMessages["complete"]
    else
        if newOwnerCoalition == 1 or newOwnerCoalition == 2 then
            message = "The enemy has taken battle position " .. bpIdString .."!"
            audioMessage = radioObjectiveMessages["failed"]
        else
            message = "Our units in battle position " .. bpIdString .. " have been destroyed!"
            audioMessage = radioObjectiveMessages["failed"]
            local teamString = "Red"
            if coalitionId == 2 then teamString = "Blue" end
            if WWEvents then WWEvents.battlePositionCapture(bpId, " has been lost by " .. teamString, prevCoalition, newOwnerCoalition) end
        end
    end
    trigger.action.outTextForCoalition(coalitionId, message, 30, false)
    if audioMessage then
        trigger.action.outSoundForCoalition(coalitionId, audioMessage)
    end
end

bc.getPositions()
bc.setBPMarkups()
bc.main()