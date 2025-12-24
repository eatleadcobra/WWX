--track existing companies: DONE
--deploy mobile troops when they are not moving: DONE
--undeploy mobile troops when they are moving: DONE
--remove lost units from available: DONE
--persist and have provisions to respawn companies on mission load: DONE
local cpyctl = {}
local tankFuelConsumption = 0.5--(PltCosts[1][1]/2)
local ifvFuelConsumption = 0
local apcFuelConsumption = 0
local cpyTimeLimit = 2700

local fuelConsumptionInterval = 1800
CpyControl = {}
local convoyPltTypes = {
    [1] = 4,
    [2] = 5,
    [3] = 6,
}
local companyStatuses = {
    ["Inactive"] = 1,
    ["Moving"] = 2,
    ["Defending"] = 3,
    ["Under Attack"] = 4,
    ["Defeated"] = 5,
}
function cpyctl.fileExists(file)
    local f = io.open(file, 'rb')
    if f then f:close() end
    return f ~= nil
end

Companies = {}
CompanyIDs = {
    [1] = {},
    [2] = {}
}


local missionName = env.mission["date"]["Year"]
local companyState = lfs.writedir() .. [[Logs/]] .. 'companies'..missionName..'.txt'
function cpyctl.saveCompanies()
    local cpyFile = companyState
    local f = io.open(cpyFile, 'w')
    local companiesData = {}
    for k,v in pairs(Companies) do
        local cpyData = {
            id = v.id,
            coalitionId = v.coalitionId,
            status = v.status,
            statusChangedTime = v.statusChangedTime,
            point = v.point,
            heading = v.heading,
            initUnits = v.initUnits,
            units = v.units,
            waypoints = v.waypoints,
            groupName = v.groupName,
            deployedGroupNames = v.deployedGroupNames,
            deployableGroups = v.deployableGroups,
            arrived = v.arrived,
            onRoad = v.onRoad,
            speed = v.speed,
            bp = v.bp,
            isConvoy = v.isConvoy,
            isShip = v.isShip,
            convoyParam = v.convoyParam,
            groupType = v.groupType,
        }
        companiesData[v.id] = cpyData
    end
    f:write("return " .. Utils.saveToString(companiesData))
    f:close()
end
function cpyctl.getCompanies()
    if cpyctl.fileExists(companyState) then
        local f = io.open(companyState, 'r')
        local cpyData = dofile(companyState)
        for k,v in pairs(cpyData) do
            local newCpy = Company.newFromTable(v)
            if newCpy.isShip then
                newCpy:setWaypoints((cpyctl.getShipPoints(newCpy.coalitionId, newCpy.point)), -1, 12)
            end
            Companies[newCpy.id] = newCpy
            table.insert(CompanyIDs[newCpy.coalitionId], newCpy.id)
        end
        f:close()
    end
end
function cpyctl.spawnCompanies()
    for k,v in pairs(Companies) do
        v:spawn()
    end
end
function CpyControl.setShipCargo(shipGroupName, cargoLoad)
    local boatGroup = Group.getByName(shipGroupName)
    if boatGroup then
        local boatCtrl = boatGroup:getController()
        local leadUnit = boatGroup:getUnit(1)
        if boatCtrl and leadUnit then
            local leadUnitId = leadUnit:getID()
            if leadUnitId then
                local command = {
                    ["id"] = "LoadingShip",
                    ["params"] =
                    {
                        ["cargo"] = cargoLoad,
                        ["unitId"] = leadUnitId,
                    },
                }
                boatCtrl:setCommand(command)
            end
        end
    end
end
function CpyControl.wipeCompanies()
    local cpyFile = companyState
    local f = io.open(cpyFile, 'w')
    if f then
        f:write("return {}")
        f:close()
    end
end
function CpyControl.newConvoy(coalitionId, convoyType, startPoint, destination, convoyParam, navalConvoy)
    local newCpy = Company.new(coalitionId, true, {convoyPltTypes[convoyType]}, true, true, false, convoyParam, navalConvoy)
    local convoySpeed = 999
    if navalConvoy then convoySpeed = 7.2 end
    newCpy:setWaypoints({startPoint, destination}, -1, convoySpeed)
    newCpy:spawn()
    return newCpy.groupName
end
function CpyControl.newShip(coalitionId, escort)
    local convoyParam = {convoyName = "", escortName = nil, coalitionId = coalitionId}
    local newCpy = Company.new(coalitionId, true, {8}, false, false, true, convoyParam, true)
    newCpy:setWaypoints(cpyctl.getShipPoints(coalitionId), -1, 12)
    newCpy:spawn()
    return newCpy.groupName
end
function CpyControl.getUnarmoredFrontlineCpy(coalitionId)
    local returnCpy = nil
    for i = 1, #CompanyIDs[coalitionId] do
        local evalCpy = Companies[CompanyIDs[coalitionId][i]]
        if evalCpy then
            if evalCpy.isConvoy == false and evalCpy.isShip == false then
                local isArmored = false
                if evalCpy.units then
                    for j = 1, #evalCpy.units do
                        if evalCpy.units[j] == Platoons[coalitionId]["Armor"][1] then
                            isArmored = true
                        end
                    end
                end
                if isArmored == false then
                    returnCpy = evalCpy
                    break
                end
            end
        end
    end
    return returnCpy
end
function CpyControl.getFrontlineCpy(coalitionId)
    local returnCpy = nil
    for i = 1, #CompanyIDs[coalitionId] do
        local evalCpy = Companies[CompanyIDs[coalitionId][i]]
        if evalCpy then
            if evalCpy.isConvoy == false and evalCpy.isShip == false and evalCpy.arrived == true then
                returnCpy = evalCpy
                break
            end
        end
    end
    return returnCpy
end
function cpyctl.updateMission(coalitionId, companyId, newPoints)
    local cpy = Companies[CompanyIDs[coalitionId][companyId]]
    if cpy then
        cpy:savePosition()
        cpy:updateMission(newPoints)
    end
end
local evaded = {}
function CpyControl.checkEvasion(companyId, shipunit)
    if cpyctl.underAirAttack(shipunit) and evaded[companyId] == nil then
        cpyctl.zigzag(Companies[companyId])
        evaded[companyId] = true
        timer.scheduleFunction(cpyctl.clearEvasion, companyId, timer:getTime() + 360)
    end
end
function cpyctl.clearEvasion(companyId)
    evaded[companyId] = nil
end
local attackrange = 12000
function cpyctl.underAirAttack(shipunit)
    local isUnderAttack = false
    if shipunit then
        local shipCtrl = shipunit:getController()
        if shipCtrl then
            local targets = shipCtrl:getDetectedTargets(Controller.Detection.VISUAL,Controller.Detection.OPTIC)
            local checkNum = #targets
            if checkNum > 5 then checkNum = 5 end
            for i = 1, checkNum do
                local tgt = targets[i].object
                if tgt then
                    local tgtPoint = tgt:getPoint()
                    local shipPoint = shipunit:getPoint()
                    if tgtPoint and shipPoint then
                        local distantToTgt = Utils.PointDistance(shipPoint, tgtPoint)
                        if distantToTgt < attackrange then
                            isUnderAttack = true
                            env.info("Ship " .. shipunit:getName() .. " is under attack", false)
                        end
                    end
                end
            end
        end
    end
    return isUnderAttack
end
local evadeLegLength = 400
function cpyctl.zigzag(company)
    if company then
        local cpyGroup = Group.getByName(company.groupName)
        if cpyGroup then
            local leadUnit = cpyGroup:getUnit(1)
            if leadUnit then
                local leadUnitPoint = leadUnit:getPoint()
                local leadUnitPos = leadUnit:getPosition()
                if leadUnitPoint and leadUnitPos then
                    company:savePosition()
                    local currentWaypoints = company.waypoints
                    local evasionPoints = {}
                    for i = 1, 6 do
                        local flipflop = -1
                        if i%2 == 0 then flipflop = 1 end
                        local evadePoint = Utils.VectorAdd(leadUnitPoint, Utils.ScalarMult(Utils.RotateVector(leadUnitPos.x, (0.15 * flipflop)), evadeLegLength*(i*1.5)))
                        table.insert(evasionPoints, evadePoint)
                    end
                    local newWaypoints = {}
                    table.insert(newWaypoints, currentWaypoints[1])
                    for i = 1, #evasionPoints do
                        table.insert(newWaypoints, evasionPoints[i])
                    end
                    table.remove(currentWaypoints, 1)
                    for i = 1, #currentWaypoints do
                        table.insert(newWaypoints, currentWaypoints[i])
                    end
                    company:updateMission(newWaypoints, -1, 12)
                end
            end
        end
    end
end
function cpyctl.saveLoop()
    if MissionOver == false then
        for k,v in pairs(Companies) do
            Companies[k]:savePosition()
        end
        cpyctl.saveCompanies()
        timer.scheduleFunction(cpyctl.saveLoop, nil, timer:getTime()+10)
    end
end
-- this really isn't mission specific and should be moved to a file in components
local cpyIndices = {
    [1] = 1,
    [2] = 1,
}
local designated = {
    [1] = {},
    [2] = {}
}
-- coalitionId, groupId
function cpyctl.cleanDesGroup(param)
    designated[param.coalitionId][param.groupName] = nil
end
local cpysPerLoop = 12
function cpyctl.cpyStatusLoop()
    for c = 1,2 do
        local startIndex = cpyIndices[c]
        if startIndex > #CompanyIDs[c] then startIndex = 1 end
        local endIndex = startIndex + (cpysPerLoop-1)
        if endIndex > #CompanyIDs[c] then endIndex = #CompanyIDs[c] end
        env.info("Cpy loop checking " .. c .. " companies " .. startIndex .. " through " .. endIndex, false)
        cpyIndices[c] = endIndex+1
        for i = startIndex, endIndex do
            local cpy = Companies[CompanyIDs[c][i]]
            if cpy then
                --cpy:updateMarks()
                local destinationPoint = cpy.waypoints[#cpy.waypoints]
                local currentPoint = cpy.point
                if Utils.PointDistance(currentPoint, destinationPoint) < 200 then
                    cpy.arrived = true
                    if cpy.status == companyStatuses["Defeated"] then
                        cpy:despawn()
                        cpyctl.reclaimCompany(cpy)
                        cpy = nil
                        break
                    end
                end
                if cpy.isShip then
                    if #cpy.waypoints > 2 then
                        if Utils.PointDistance(currentPoint, cpy.waypoints[2]) < 200 then
                            local newWaypoints = {[1] = currentPoint}
                            for j = 3, #cpy.waypoints do
                                table.insert(newWaypoints, cpy.waypoints[j])
                            end
                            cpy:setWaypoints(newWaypoints)
                        end
                    end
                end
                local cpyGroup = Group.getByName(cpy.groupName)
                if cpyGroup then
                    cpy:updateUnits(cpyGroup:getUnits())
                    if cpy.casTracked and designated[c][cpy.groupName] == nil then
                        CAS.checkGroup(cpy.groupName)
                        CAS.designateGroup(cpy.groupName)
                        designated[c][cpy.groupName] = true
                        timer.scheduleFunction(cpyctl.cleanDesGroup, {coalitionId = c, groupName = cpy.groupName}, timer:getTime() + 30)
                    end
                    if cpy.isShip == false and cpy.isConvoy == false and cpy.spawnTime and cpy.spawnTime ~= 0 then
                        if timer:getTime() - cpy.spawnTime > cpyTimeLimit then
                            cpy:savePosition()
                            cpy:despawn()
                            cpy:spawn()
                            break
                        end
                    end
                    local firstUnit = cpyGroup:getUnit(1)
                    if firstUnit then
                        local firstUnitVelocity = firstUnit:getVelocity()
                        if firstUnitVelocity then
                            if Utils.getSpeed(firstUnitVelocity) <= 0.3 and cpy.isDeployed == false then
                                cpy:deploy()
                            elseif Utils.getSpeed(firstUnitVelocity) > 0.3 and cpy.isDeployed then
                                cpy:undeploy()
                            end
                        end
                    end
                else
                    trigger.action.removeMark(cpy.markUps.destination)
                    trigger.action.removeMark(cpy.markUps.marker)
                    env.info("Clean group markups for dead group: " .. cpy.groupName, false)
                    CAS.cleanGroupMarkups(cpy.groupName)
                    Companies[CompanyIDs[c][i]] = nil
                    table.remove(CompanyIDs[c], i)
                    break
                end
            else
                table.remove(CompanyIDs[c], i)
                break
            end
        end
    end
    timer.scheduleFunction(cpyctl.cpyStatusLoop, nil, timer:getTime() + 5)
end
local fuelConsumptionTeam = math.random(1,2)
function cpyctl.teamFuelConsumptionLoop()
    local c = fuelConsumptionTeam
    if fuelConsumptionTeam == 2 then
        fuelConsumptionTeam = 1
    else
        fuelConsumptionTeam = 2
    end
    local teamFuelConsumption = 0
    -- for i = 1, #CompanyIDs[c] do
    --     local company = Companies[CompanyIDs[c][i]]
    --     if company then
    --         if company.isShip == false and company.isConvoy == false and company.status ~= companyStatuses["Defeated"] then
    --             teamFuelConsumption = teamFuelConsumption + cpyctl.getCompanyFuelCost(company)
    --         end
    --     end
    -- end
    -- DFS.decreaseFrontSupply({coalitionId = c, type = DFS.supplyType.FUEL, amount = math.floor(teamFuelConsumption)})
    if DFS.status[c].supply.front[DFS.supplyType.FUEL] <= 0 then
        cpyctl.sendHomeArmoredGroup(c)
    end
    timer.scheduleFunction(cpyctl.teamFuelConsumptionLoop, nil, timer:getTime() + fuelConsumptionInterval/2)
end
function cpyctl.sendHomeArmoredGroup(coalitionId)
    local cpyToReturn = nil
    for i = 1, #CompanyIDs[coalitionId] do
        local company = Companies[CompanyIDs[coalitionId][i]]
        if company then
            if company.isConvoy == false and company.status ~= companyStatuses["Defeated"] then
                if company.groupName then
                    local cpyGroup = Group.getByName(company.groupName)
                    if cpyGroup then
                        local cpyUnits = cpyGroup:getUnits()
                        if cpyUnits then
                            for j = 1, #cpyUnits do
                                local evalUnit = cpyUnits[j]
                                if evalUnit then
                                    if evalUnit:hasAttribute("Tanks") then
                                        cpyToReturn = company
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if cpyToReturn then
        local returnDepot = math.random(1,2)
        cpyToReturn:setStatus(companyStatuses["Defeated"])
        cpyToReturn.arrived = false
        local startPoint = cpyToReturn.point
        local destination = trigger.misc.getZone(DFS.spawnNames[coalitionId].depot..returnDepot).point
        cpyToReturn:updateMission({startPoint, destination}, -1)
        if cpyToReturn.callsign ~= nil then
            trigger.action.outTextForCoalition(coalitionId, "Company " .. cpyToReturn.callsign .. " does not have enough fuel to remain on the front and is returning to base.", 30, false)
        else
            trigger.action.outTextForCoalition(coalitionId, "One of our tank companies does not have enough fuel to remain on the front and is returning to base.", 30, false)
        end
        local enemyCoalition = 2
        if coalitionId == 2 then enemyCoalition = 1 end
        if WWEvents then WWEvents.tankCpyStalled(enemyCoalition) end
        if STATS then STATS.addStat(enemyCoalition, STATS.statID["TANK_CPY_STALLED"]) end
    end
end
function cpyctl.getCompanyStrength(cpy)
    local tankCount = 0
    local carrierCount = 0
    local cpyGroup = Group.getByName(cpy.groupName)
    if cpyGroup then
        local cpyUnits = cpyGroup:getUnits()
        if cpyUnits then
            for i = 1, #cpyUnits do
                local evalUnit = cpyUnits[i]
                if evalUnit then
                    if evalUnit:hasAttribute("Tanks") then
                        tankCount = tankCount + 1
                    elseif evalUnit:hasAttribute("IFV") or evalUnit:hasAttribute("APC") then
                        carrierCount = carrierCount+1
                    end
                end
            end
        end
    end
    local strengthscore = math.floor(tankCount * 16.6) + math.floor(carrierCount * 8.3)
    return strengthscore
end
function cpyctl.reclaimCompany(company)
    if company then
        local cpyCoaltion = company.coalitionId
        local pltEquipment = 0
        for i = 1, #CompanyCompTiers[1].composition do
            pltEquipment = pltEquipment + PltCosts[CompanyCompTiers[1].composition[i]][DFS.supplyType.EQUIPMENT]
        end
        DFS.IncreaseFrontSupply({coalitionId = cpyCoaltion, amount = pltEquipment, type = DFS.supplyType.EQUIPMENT})
    end
end
function cpyctl.getCompanyFuelCost(cpy)
    local fuelCost = 0
    if cpy.groupName then
        local tankCount = 0
        local ifvCount = 0
        local apcCount = 0
        local cpyGroup = Group.getByName(cpy.groupName)
        if cpyGroup then
            local cpyUnits = cpyGroup:getUnits()
            if cpyUnits then
                for i = 1, #cpyUnits do
                    local evalUnit = cpyUnits[i]
                    if evalUnit then
                        if evalUnit:getTypeName() == Platoons[cpy.coalitionId]["Armor"][1] then
                            tankCount = tankCount + 1
                        elseif evalUnit:getTypeName() == Platoons[cpy.coalitionId]["Mech"][1] then
                            ifvCount = ifvCount+1
                        elseif evalUnit:getTypeName() == Platoons[cpy.coalitionId]["Inf"][1] then
                            apcCount = apcCount+1
                        end
                    end
                end
            end
        end
        fuelCost = (tankCount * tankFuelConsumption) + (ifvCount * ifvFuelConsumption) + math.floor(apcCount * apcFuelConsumption)
    end
    return fuelCost
end

function cpyctl.getShipPoints(coalitionId, overrideStartPoint)
    local lowerLeftBoundPoint = trigger.misc.getZone(coalitionId.."-shipzone-SW").point
    local upperRightBoundPoint = trigger.misc.getZone(coalitionId.."-shipzone-NE").point
    local xDiff = upperRightBoundPoint.x - lowerLeftBoundPoint.x
    local zDiff = upperRightBoundPoint.z - lowerLeftBoundPoint.z
    local shipStartPoint = {x = lowerLeftBoundPoint.x + math.random(0, xDiff), y=0, z = lowerLeftBoundPoint.z + math.random(0, zDiff)}
    if overrideStartPoint then
        shipStartPoint = overrideStartPoint
    end
    local shipPoints = {}
    table.insert(shipPoints, shipStartPoint)
    for i = 1, 20 do
        local nextShipWP = trigger.misc.getZone(coalitionId.."-shiproute-"..i)
        if nextShipWP then
            local shipPoint = nextShipWP.point
            table.insert(shipPoints, shipPoint)
        end
    end
    return shipPoints
end

cpyctl.getCompanies()
cpyctl.spawnCompanies()

cpyctl.saveLoop()
cpyctl.cpyStatusLoop()
cpyctl.teamFuelConsumptionLoop()