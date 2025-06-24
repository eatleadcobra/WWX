--track existing companies: DONE
--deploy mobile troops when they are not moving: DONE
--undeploy mobile troops when they are moving: DONE
--remove lost units from available: DONE
--persist and have provisions to respawn companies on mission load: DONE
local cpyctl = {}
CpyControl = {}
local convoyPltTypes = {
    [1] = 4,
    [2] = 5,
    [3] = 6,
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
    local convoyParam = {convoyName = "", escortName = nil}
    local newCpy = Company.new(coalitionId, true, {8}, false, false, true, convoyParam, true)
    newCpy:setWaypoints(cpyctl.getShipPoints(coalitionId), -1, 12)
    newCpy:spawn()
    return newCpy.groupName
end
function cpyctl.updateMission(coalitionId, companyId, newPoints)
    local cpy = Companies[CompanyIDs[coalitionId][companyId]]
    if cpy then
        cpy:savePosition()
        cpy:updateMission(newPoints)
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
local cpysPerLoop = 6
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
                    if cpy.casTracked and designated[c][cpy.groupName] == nil then
                        CAS.checkGroup(cpy.groupName)
                        CAS.designateGroup(cpy.groupName)
                        designated[c][cpy.groupName] = true
                        timer.scheduleFunction(cpyctl.cleanDesGroup, {coalitionId = c, groupName = cpy.groupName}, timer:getTime() + 30)
                    end
                    cpy:updateUnits(cpyGroup:getUnits())
                    local lastUnit = cpyGroup:getUnit(cpyGroup:getSize())
                    local firstUnit = cpyGroup:getUnit(1)
                    if lastUnit and firstUnit then
                        local lastUnitVelocity = lastUnit:getVelocity()
                        local firstUnitVelocity = firstUnit:getVelocity()
                        if lastUnitVelocity and firstUnitVelocity then
                            if Utils.getSpeed(firstUnitVelocity) <= 0.3 and Utils.getSpeed(lastUnitVelocity) <= 0.3 and cpy.isDeployed == false then
                                cpy:deploy()
                            elseif (Utils.getSpeed(firstUnitVelocity) > 0.3 or Utils.getSpeed(lastUnitVelocity) > 0.3) and cpy.isDeployed then
                                cpy:undeploy()
                            end
                        end
                    end
                else
                    trigger.action.removeMark(cpy.markUps.destination)
                    trigger.action.removeMark(cpy.markUps.marker)
                    if cpy.casTracked then
                        CAS.cleanGroupMarkups(cpy.groupName)
                    end
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
    timer.scheduleFunction(cpyctl.cpyStatusLoop, nil, timer:getTime() + 10)
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

function cpyctl.getShipPoints(coalitionId)
    local lowerLeftBoundPoint = trigger.misc.getZone(coalitionId.."-shipzone-SW").point
    local upperRightBoundPoint = trigger.misc.getZone(coalitionId.."-shipzone-NE").point
    local xDiff = upperRightBoundPoint.x - lowerLeftBoundPoint.x
    local zDiff = upperRightBoundPoint.z - lowerLeftBoundPoint.z
    local shipStartPoint = {x = lowerLeftBoundPoint.x + math.random(0, xDiff), y=0, z = lowerLeftBoundPoint.z + math.random(0, zDiff)}
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
