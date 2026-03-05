--- @module Interceptors
--- @author "George "Gepset" Brooker"
--- @description "This module handles spawning interceptors to engage targets in specific zones. It checks for targets in the zones, prioritizes them based on distance to the zone, and spawns interceptors to engage them if they are detected on bulls. Interceptors will continue to engage their target as long as it is detected on bulls, even if it leaves the zone. If an interceptor is destroyed or lands, it will be removed from the currentlyIntercepting table and a new interceptor can be spawned for that target if it is still detected on bulls and within the intercept limit."
--- @version "1.0.0"

-- For V2 create more optimised zone search logic by filtering units by bulls detection first and only checking targets on bulls for zone intersection.
-- TODO finish multiple zone logic and linked airframes system


-- Template to follow when creating your override file. should be named INTERCEPTORS in the override file.
local templateOverride = {
    -- REQUIRED
    interval = 600, --seconds for a new interceptor to spawn after the last one dies (each interceptor has its own cooldown applied individually
    intercept_limit = 3, -- total number of interceptors that can be in the air at one time
    -- OPTIONAL
    multipleZones = true, -- if true, will look for targets in multiple zones with the same name and a number at the end (e.g. InterceptorZoneRed-1, InterceptorZoneRed-2, etc.) and will prioritize targets in the closest zone to the interceptor spawn point. If false, will look for targets in a single zone (InterceptorZoneRed and InterceptorZoneBlue)
    independantZones = true, -- if true, will treat each zone as independent for interceptor spawning (e.g. target priority will be determined relative to interceptrZone1, if zones are independant, each zone will have its own priority list and interceptors will spawn based on that list instead of a combined list for all zones). Interceptors are tasked randomly among the zones.
    linkedAirframes = true, -- if true each zone will be linked to a specific interceptor group with the same name and a number at the end (e.g. InterceptorZoneRed-1 will be linked to Red-Interceptor-1). If false, will use the same interceptor group for all zones (Red-Interceptor and Blue-Interceptor)
    noGci = false, -- if true, intercept points will not be updated via script, interceptors will need to use their own sensors to find the target.
    sensorRestriction = "RADAR,IRST", -- if set, will restrict interceptor from using certain sensors to detect the target (e.g. "RADAR", "DATALINK", etc.)
}

Intr = {}
local intr = {}
local currentlyIntercepting = {
    [1] = {
    },
    [2] = {
    }
}
local lastInterceptorTime = {
    [1] = {
    },
    [2] = {
    }
}
local totalIntercepting = {
    [1] = 0,
    [2] = 0,
}
local updateInterval = 60
function intr.initTables()
    if INTERCEPTORS.intercept_limit == nil then INTERCEPTORS.intercept_limit = 1 end
    for i = 1, INTERCEPTORS.intercept_limit do
        lastInterceptorTime[1][i] = 0
        lastInterceptorTime[2][i] = 0
    end
end
function intr.spawnInterceptor(coalitionId, target)
    local targetUnit = Unit.getByName(target)
    local number = -1
    if targetUnit then
        local targetPoint = targetUnit:getPoint()
        if targetPoint == nil then
            env.info("Could not get target point for interceptor spawn, aborting", false)
            return
        end
    else
        env.info("Could not find target unit for interceptor spawn, aborting", false)
        return
    end

    local cloneGroupName = 'Red-Interceptor'
    if coalitionId == 2 then cloneGroupName = 'Blue-Interceptor' end
    env.info("Spawning interceptor " .. cloneGroupName .. " for target " .. target .. " with number " .. number, false)
    -- get first available interceptor slot for coalitionId
    for i = 1, INTERCEPTORS.intercept_limit do
        if lastInterceptorTime[coalitionId][i] - timer:getTime() < INTERCEPTORS.interval then
            number = i
            break
        end
    end
    if number == -1 then
        env.info("No interceptor slots available for coalition " .. coalitionId .. ", aborting spawn", false)
        return
    end
    local groupName = mist.cloneGroup(cloneGroupName, true).name
    totalIntercepting[coalitionId]= totalIntercepting[coalitionId] + 1
    -- set interceptor task to engage target
    local interceptPoint = {
        id = 'Orbit',
            params = {
            pattern = 'Circle',
            point = targetUnit:getPoint(),
            speed = 200,
            altitude = 8000,
        } 
    }
    local interceptTask = {
        id = "EngageUnit",
        params = {
            unitId = targetUnit:getID(),
        }
    }
    local controller = Group.getByName(groupName):getController()
    if controller then
        controller:pushTask(interceptPoint)
        controller:setTask(interceptTask)
    end

    lastInterceptorTime[coalitionId][number] = timer:getTime()
    currentlyIntercepting[coalitionId][target] = true
    intr.checkInterceptor({groupName = groupName, coalitionId = coalitionId, number = number, target = target})
end
function intr.checkInterceptor(param)
    env.info("Checking interceptor group " .. param.groupName, false)
    local group = Group.getByName(param.groupName)
    local target = Unit.getByName(param.target)
    if group ~= nil then
        if group:getSize() == 0 or group:getUnit(1) == nil or group:getUnit(1):inAir() == false then
            env.info("Interceptor group " .. param.groupName .. " has been destroyed or is on the ground", false)
            group:destroy()
            lastInterceptorTime[param.coalitionId][param.number] = timer:getTime()
            currentlyIntercepting[param.coalitionId][param.target] = nil
            totalIntercepting[param.coalitionId] = totalIntercepting[param.coalitionId] - 1
        elseif target ~= nil then
            local controller = Group.getByName(param.groupName):getController()
            if controller then
                if not controller:isTargetDetected(target) then -- if target is no longer detected, check if it's still on bulls and update task to new position if so
                    if intr.detectedOnBulls(param.coalitionId, param.target) then
                        env.info("Target " .. param.target .. " still detected on bulls, updating interceptor task", false)
                        local targetPoint = target:getPoint()
                        if targetPoint == nil then
                            env.info("Could not get target point for interceptor task update, aborting task update", false)
                            timer.scheduleFunction(intr.checkInterceptor, param, timer.getTime() + updateInterval)
                            return
                        end
                        local interceptPoint = {
                        id = 'Orbit',
                            params = {
                            pattern = 'Circle',
                            point = targetPoint,
                            speed = 1000,
                            altitude = targetPoint.y,
                            } 
                        }
                        local interceptTask = {
                            id = "EngageUnit",
                            params = {
                                unitId = target:getID(),
                            }
                        }
                        controller:pushTask(interceptPoint)
                        controller:setTask(interceptTask)
                    end
                end
            else
                env.info("Target " .. param.target .. " no longer detected on bulls, interceptor will continue to last known position", false)
            end
            timer.scheduleFunction(intr.checkInterceptor, param, timer.getTime() + updateInterval)
        else
            timer.scheduleFunction(intr.checkInterceptor, param, timer.getTime() + updateInterval)
        end
    else
        if param.target then
            currentlyIntercepting[param.coalitionId][param.target] = nil
        end
        totalIntercepting[param.coalitionId] = totalIntercepting[param.coalitionId] - 1
        lastInterceptorTime[param.coalitionId][param.number] = timer:getTime()
    end
end
function intr.detectedOnBulls(coalitionId, unitName)
    local group = Unit.getByName(unitName):getGroup()
    local targets = Bulls.getTargetsOnScope(coalitionId)
    if group and targets then
        for i = 1, #targets do
            env.info("checking group " .. group:getName() .. " against target " .. targets[i]["groupName"], false)
            if group:getName() == targets[i]["groupName"] then
                return true
            end
        end
    end
end
function intr.getInterceptorPriority(units, zoneName)
    if INTERCEPTORS.independantZones and zoneName:sub(-1) == "-" then
        local i = 1
        local priorityZones = {}
        while trigger.misc.getZone(zoneName .. i) do
            local indUnits = intr.getInterceptorPriority(units, zoneName .. i)
            if #indUnits > 0 then
                priorityZones[zoneName .. i] = indUnits
            end
            i = i + 1
        end
        priorityZones.independent = true
        return priorityZones
    end
    if zoneName:sub(-1) == "-" then 
        zoneName = zoneName.."1" -- first zone will be the priority zone.
    end
    local priorityUnits = {}
    local zone = trigger.misc.getZone(zoneName)
    for i = 1, #units do
        local unit = Unit.getByName(units[i])
        if unit then
            local unitPoint = unit:getPoint()
            if unitPoint then
                local distanceToZone = Utils.PointDistance(unitPoint, zone.point)
                priorityUnits[#priorityUnits + 1] = {name = units[i], distance = distanceToZone}
            end
        end
    end
    table.sort(priorityUnits, function(a, b) return a.distance < b.distance end)
    return priorityUnits
end
function intr.scrambleInterceptors(coalitionId, targets)
    if targets then
        if INTERCEPTORS.independantZones then
            for i=1, INTERCEPTORS.intercept_limit do
                local randomZone = math.random(1, #targets)
                target = randomZone[1] -- take higest priority target from random zone
                if target then
                    table.remove(target, 1) -- remove target from zone priority list so next interceptor will take next target in that zone if selected again
                    if intr.detectedOnBulls(coalitionId, target.name) then
                        env.info("target " .. target.name .. " detected on bulls, spawning interceptor", false)
                        if not currentlyIntercepting[coalitionId][target.name] and totalIntercepting[coalitionId] < INTERCEPTORS.intercept_limit then
                            intr.spawnInterceptor(coalitionId, target.name)
                        else
                            env.info("Already intercepting target " .. target.name, false)
                        end
                    end
                end
            end
        end
        for i = 1, INTERCEPTORS.intercept_limit do
            if i <= #blueInterceptTargets then
                if intr.detectedOnBulls(coalitionId, targets[i].name) then
                    env.info("target " .. targets[i].name .. " detected on bulls, spawning interceptor", false)
                    if not currentlyIntercepting[coalitionId][targets[i].name] and totalIntercepting[coalitionId] < INTERCEPTORS.intercept_limit then
                        intr.spawnInterceptor(coalitionId, targets[i].name)
                    else
                        env.info("Already intercepting target " .. targets[i].name, false)
                    end
                end
            end
        end
    end

function Intr.interceptorLoop()
    local blueZone = "InterceptorZoneBlue"
    local redZone = "InterceptorZoneRed"
    if INTERCEPTORS.multipleZones then
        blueZone = "InterceptorZoneBlue-"
        redZone = "InterceptorZoneRed-"
    end
    local blueInterceptTargets = intr.getInterceptorPriority(Utils.checkZoneIntersection(1, blueZone), blueZone)
    intr.scrambleInterceptors(1, blueInterceptTargets)

    local redInterceptTargets = intr.getInterceptorPriority(Utils.checkZoneIntersection(2, redZone), redZone)
    intr.scrambleInterceptors(2, redInterceptTargets)

    timer.scheduleFunction(Intr.interceptorLoop, nil, timer.getTime() + updateInterval)
end
env.info("Initializing Interceptors...", false)
intr.initTables()
Intr.interceptorLoop()