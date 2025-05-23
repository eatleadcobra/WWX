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
            convoyParam = v.convoyParam
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
function CpyControl.newConvoy(coalitionId, convoyType, startPoint, destination, convoyParam)
    local newCpy = Company.new(coalitionId, true, {convoyPltTypes[convoyType]}, true, true, convoyParam)
    newCpy:setWaypoints({startPoint, destination}, -1, 999)
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
function cpyctl.cpyStatusLoop()
    for c = 1,2 do
        for i = 1, #CompanyIDs[c] do
            local cpy = Companies[CompanyIDs[c][i]]
            if cpy then
                cpy:updateMarks()
                local destinationPoint = cpy.waypoints[#cpy.waypoints]
                local currentPoint = cpy.point
                if Utils.PointDistance(currentPoint, destinationPoint) < 200 then
                    cpy.arrived = true
                end
                local cpyGroup = Group.getByName(cpy.groupName)
                if cpyGroup then
                    cpy:updateUnits(cpyGroup:getUnits())
                    local lastUnit = cpyGroup:getUnit(cpyGroup:getSize())
                    local firstUnit = cpyGroup:getUnit(1)
                    if lastUnit and firstUnit then
                        local lastUnitVelocity = lastUnit:getVelocity()
                        local firstUnitVelocity = firstUnit:getVelocity()
                        if lastUnitVelocity and firstUnitVelocity then
                            if Utils.getSpeed(firstUnitVelocity) < 0.1 and Utils.getSpeed(lastUnitVelocity) < 0.1 and cpy.isDeployed == false then
                                cpy:deploy()
                            elseif (Utils.getSpeed(firstUnitVelocity) > 0.1 or Utils.getSpeed(lastUnitVelocity) > 0.1) and cpy.isDeployed then
                                cpy:undeploy()
                            end
                        end
                    end
                else
                    trigger.action.removeMark(cpy.markUps.destination)
                    trigger.action.removeMark(cpy.markUps.marker)
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

cpyctl.getCompanies()
cpyctl.spawnCompanies()

cpyctl.saveLoop()
cpyctl.cpyStatusLoop()
