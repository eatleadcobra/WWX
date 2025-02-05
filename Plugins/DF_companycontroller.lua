--track existing companies
--deploy mobile troops when they are not moving
--undeploy mobile troops when they are moving
--remove lost units from available
--persist and have provisions to respawn companies on mission load
Companies = {}
CompanyIDs = {
    [1] = {},
    [2] = {}
}


local startPoint = trigger.misc.getZone(DFS.spawnNames[2].depot..2).point
local destination = trigger.misc.getZone("BP-1").point
local testCpy = Company.new(2, {1,2,3})
testCpy:setWaypoints({startPoint, destination})
testCpy:spawn()
timer.scheduleFunction(Company.despawn, testCpy, timer:getTime() + 30)
timer.scheduleFunction(Company.spawn, testCpy, timer:getTime() + 40)