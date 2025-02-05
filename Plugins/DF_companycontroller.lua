--track existing companies
--deploy mobile troops when they are not moving
--undeploy mobile troops when they are moving
--remove lost units from available
--persist and have provisions to respawn companies on mission load
local cpyctl = {}
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
            units = v.units,
            waypoints = v.waypoints,
            groupName = v.groupName,
            deployedGroupNames = v.deployedGroupNames,
            arrived = v.arrived
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

-- local startPoint = trigger.misc.getZone("spawn").point
-- local destination = trigger.misc.getZone("BP-1").point
-- local testCpy = Company.new(2, {1,2,3})
-- Companies[testCpy.id] = testCpy
-- table.insert(CompanyIDs[testCpy.coalitionId], testCpy.id)
-- testCpy:setWaypoints({startPoint, destination})
-- testCpy:spawn()
-- testCpy:savePosition()
-- cpyctl.saveCompanies()
cpyctl.getCompanies()
cpyctl.spawnCompanies()

function cpyctl.updateMission()
    trigger.action.outText("Updating mission", 10, false)
    local cpy = Companies[CompanyIDs[2][1]]
    cpy:savePosition()

    local newWaypoints = SpawnFuncs.createWPListFromPoints({[1]=cpy.point,[2]=trigger.misc.getZone("BP-6").point})
    local newMission = SpawnFuncs.createMission(newWaypoints)
    cpy:updateMission(newMission)
    trigger.action.outText("Updated mission", 10, false)
end
timer.scheduleFunction(cpyctl.updateMission, nil, timer:getTime() + 15)