--- @module Interceptors
--- @author "George "Gepset" Brooker"
--- @description "This module handles spawning interceptors to engage targets in specific zones. It checks for targets in the zones, prioritizes them based on distance to the zone, and spawns interceptors to engage them if they are detected on bulls. Interceptors will continue to engage their target as long as it is detected on bulls, even if it leaves the zone. If an interceptor is destroyed or lands, it will be removed from the currentlyIntercepting table and a new interceptor can be spawned for that target if it is still detected on bulls and within the intercept limit."
--- @version "1.0.0"

-- PLANNED OPTIMISATIONS:
 -- Filter by bulls first then check zone intersections
 -- early exit target match loop once all slots are filled
 -- pop units from target matching as interceptors are assigned to reduce comparisions for each interceptor spawn
 -- dont even run interceptor task loop if we are already at max interceptors in the air 

-- REQUIRED ZONES:
-- InterceptorZoneRed and InterceptorZoneBlue (or InterceptorZoneRed-1, InterceptorZoneRed-2, etc. if multipleZones is enabled)

-- REQUIRED GROUP TEMPLATES:
-- Red-Interceptor and Blue-Interceptor (or Red-Interceptor-1..etc and Blue-Interceptor..1etc if linkedAirframes is enabled)
-- Interceptors dont need any waypoints or advanced actions, just set the task to CAP and set the speed as required

-- OVERRIDE TEMPLATE. should be named INTERCEPTORS in the override file.
local templateOverride = {
    -- REQUIRED
    interval = 600, --seconds for a new interceptor to spawn after the last one dies (each interceptor has its own cooldown applied individually
    interceptLimit = 3, -- total number of interceptors that can be in the air at one time
    -- OPTIONAL
    multipleZones = true, -- if true, will look for targets in multiple zones with the same name and a number at the end (e.g. InterceptorZoneRed-1, InterceptorZoneRed-2, etc.) and will prioritize targets in the closest zone to the interceptor spawn point. If false, will look for targets in a single zone (InterceptorZoneRed and InterceptorZoneBlue)
    independantZones = true, -- if true, will treat each zone as independent for interceptor spawning (e.g. target priority will be determined relative to interceptrZone1, if zones are independant, each zone will have its own priority list and interceptors will spawn based on that list instead of a combined list for all zones). Interceptors are tasked randomly among the zones.
    linkedAirframes = {
        [1] = {[1] = 1, [2] = 1, [3] = 2}, -- Red coalition, zone 1 and 2 will use Red-Interceptor-1 template, zone 3 will use Red-Interceptor-2 template
        [2] = {[1] = 1, [2] = 1, [3] = 2}, -- Blue coalition, zone 1 and 2 will use Blue-Interceptor-1 template, zone 3 will use Blue-Interceptor-2 template
    }, -- if true each zone will be linked to a specific interceptor group template, defined by the number (e.g. if 1, will use Red-Interceptor-1 and Blue-Interceptor-1 templates, if 2, will use Red-Interceptor-2 and Blue-Interceptor-2 templates, etc.). If false, will use the same interceptor group template for all zones. There is required to be an entry for all zones if enabled. 
    noGci = false, -- if true, intercept points will not be updated via script, interceptors will need to use their own sensors to find the target.
}
local debug = false
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
    if INTERCEPTORS.interceptLimit == nil then INTERCEPTORS.interceptLimit = 1 end
    for i = 1, INTERCEPTORS.interceptLimit do
        lastInterceptorTime[1][i] = -1
        lastInterceptorTime[2][i] = -1
    end
end
function intr.spawnInterceptor(coalitionId, target)
    env.info("Spawning interceptor for target " .. target.name .. " in coalition " .. coalitionId, true)
    local targetUnit = Unit.getByName(target.name)
    local number = -1
    if targetUnit then
        local targetPoint = targetUnit:getPoint()
        if targetPoint == nil then
            env.info("Could not get target point for interceptor spawn, aborting", debug)
            return
        end
    else
        env.info("Could not find target unit for interceptor spawn, aborting", debug)
        return
    end

    local cloneGroupName = 'Red-Interceptor'
    if coalitionId == 2 then cloneGroupName = 'Blue-Interceptor' end
    if INTERCEPTORS.linkedAirframes and INTERCEPTORS.multipleZones then
        local zoneNumber = tonumber(target.zone:match("%d+$")) or 1 -- extract number at end of target name, default to 1 if not found
        local linkedGroupNumber = INTERCEPTORS.linkedAirframes[coalitionId][zoneNumber]
        if linkedGroupNumber then
            cloneGroupName = cloneGroupName .. "-" .. linkedGroupNumber
            env.info("Using linked interceptor group " .. cloneGroupName .. " for coalition " .. coalitionId .. " and zone number " .. zoneNumber, debug)
        else
            env.info("No linked interceptor group found for coalition " .. coalitionId .. " and zone number " .. zoneNumber, true)
        end
    end
    env.info("Spawning interceptor " .. cloneGroupName .. " for target " .. target.name .. " with number " .. number, true)
    -- get first available interceptor slot for coalitionId
    for i = 1, INTERCEPTORS.interceptLimit do
        env.info("Checking slot " .. i .. " for coalition " .. coalitionId .. ", last interceptor time: " .. lastInterceptorTime[coalitionId][i] - timer:getTime() .. "interval: " .. INTERCEPTORS.interval, debug)
        if lastInterceptorTime[coalitionId][i] - timer:getTime() < INTERCEPTORS.interval then
            number = i
            break
        end
    end
    if number == -1 then
        env.info("No interceptor slots available for coalition " .. coalitionId .. ", aborting spawn", debug)
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
    currentlyIntercepting[coalitionId][target.name] = true
    intr.checkInterceptor({groupName = groupName, coalitionId = coalitionId, number = number, target = target.name})
end
function intr.checkInterceptor(param)
    env.info("Checking interceptor group " .. param.groupName, true)
    local group = Group.getByName(param.groupName)
    local target = Unit.getByName(param.target)
    if group ~= nil then
        if group:getSize() == 0 or group:getUnit(1) == nil or group:getUnit(1):inAir() == false then
            env.info("Interceptor group " .. param.groupName .. " has been destroyed or is on the ground", debug)
            group:destroy()
            lastInterceptorTime[param.coalitionId][param.number] = timer:getTime()
            currentlyIntercepting[param.coalitionId][param.target] = nil
            totalIntercepting[param.coalitionId] = totalIntercepting[param.coalitionId] - 1
        elseif target ~= nil then
            local controller = Group.getByName(param.groupName):getController()
            if controller then
                if not controller:isTargetDetected(target) then -- if target is no longer detected, check if it's still on bulls and update task to new position if so
                    if intr.detectedOnBulls(param.coalitionId, param.target) and not INTERCEPTORS.noGci then
                        env.info("Target " .. param.target .. " still detected on bulls, updating interceptor task", debug)
                        local targetPoint = target:getPoint()
                        if targetPoint == nil then
                            env.info("Could not get target point for interceptor task update, aborting task update", debug)
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
                env.info("Target " .. param.target .. " no longer detected on bulls, interceptor will continue to last known position", debug)
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
            env.info("checking group " .. group:getName() .. " against target " .. targets[i]["groupName"], debug)
            if group:getName() == targets[i]["groupName"] then
                return true
            end
        end
    end
end
function intr.getInterceptorPriority(coalitionId, zoneName)
    if INTERCEPTORS.independantZones and zoneName:sub(-1) == "-" then
        local i = 1
        local priorityZones = {}
        while trigger.misc.getZone(zoneName .. i) do
            local indUnits = intr.getInterceptorPriority(coalitionId, zoneName .. i)
            if #indUnits > 0 then
                priorityZones[zoneName .. i] = indUnits
            end
            i = i + 1
        end
        return priorityZones
    end
    local units = Utils.checkZoneIntersection(coalitionId, zoneName)
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
                priorityUnits[#priorityUnits + 1] = {name = units[i], distance = distanceToZone, zone = zoneName}
            end
        end
    end
    table.sort(priorityUnits, function(a, b) return a.distance < b.distance end)
    return priorityUnits
end
function intr.scrambleInterceptors(coalitionId, targets)
    if targets then
        if INTERCEPTORS.independantZones then
            local zonePrefix = "InterceptorZoneBlue-"
            if coalitionId == 1 then zonePrefix = "InterceptorZoneRed-" end
            for i=1, INTERCEPTORS.interceptLimit do
                local randomZone = math.random(1, Utils.getlengthOfTable(targets))
                env.info("Selected random zone " .. randomZone .. " with name " .. zonePrefix .. randomZone, debug)
                if randomZone then
                    env.info("Selected random zone " .. randomZone .. " with name " .. zonePrefix .. randomZone.."\nTargets:\n"..Utils.dump(targets).."\nPri:"..Utils.dump(targets[zonePrefix..randomZone]), true)
                    if next(targets) then
                        local target = targets[zonePrefix .. randomZone][1] -- take higest priority target from random zone
                        if target then
                            table.remove(targets[zonePrefix .. randomZone], 1) -- remove target from zone priority list so next interceptor will take next target in that zone if selected again
                            if intr.detectedOnBulls(coalitionId, target.name) then
                                env.info("target " .. target.name .. " detected on bulls, spawning interceptor", true)
                                if not currentlyIntercepting[coalitionId][target.name] and totalIntercepting[coalitionId] < INTERCEPTORS.interceptLimit then
                                    intr.spawnInterceptor(coalitionId, target)
                                else
                                    env.info("Already intercepting target " .. target.name, true)
                                end
                            end
                        end
                    end
                end
            end
        else
            for i = 1, INTERCEPTORS.interceptLimit do
                if i <= #targets then
                    if intr.detectedOnBulls(coalitionId, targets[i].name) then
                        env.info("target " .. targets[i].name .. " detected on bulls, spawning interceptor", debug)
                        if not currentlyIntercepting[coalitionId][targets[i].name] and totalIntercepting[coalitionId] < INTERCEPTORS.interceptLimit then
                            intr.spawnInterceptor(coalitionId, targets[i])
                        else
                            env.info("Already intercepting target " .. targets[i].name, debug)
                        end
                    end
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
    local blueInterceptTargets = intr.getInterceptorPriority(1, blueZone)
    intr.scrambleInterceptors(2, blueInterceptTargets)

    local redInterceptTargets = intr.getInterceptorPriority(2, redZone)
    intr.scrambleInterceptors(1, redInterceptTargets)

    timer.scheduleFunction(Intr.interceptorLoop, nil, timer.getTime() + updateInterval)
end
env.info("Initializing Interceptors...", debug)
intr.initTables()
Intr.interceptorLoop()