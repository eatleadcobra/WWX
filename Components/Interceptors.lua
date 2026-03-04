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
            -- set interceptor task to engage target new position if detected on bulls
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
                local controller = Group.getByName(param.groupName):getController()
                if controller then
                    controller:pushTask(interceptPoint)
                    controller:setTask(interceptTask)
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
function Intr.interceptorLoop()
    local blueInterceptTargets = intr.getInterceptorPriority(Utils.checkZoneIntersection(1, "InterceptorZoneBlue"), "InterceptorZoneBlue")
    if INTERCEPTORS.intercept_limit == nil then INTERCEPTORS.intercept_limit = 1 end
    if blueInterceptTargets then
        for i = 1, INTERCEPTORS.intercept_limit do
            if i <= #blueInterceptTargets then
                if intr.detectedOnBulls(2, blueInterceptTargets[i].name) then
                    env.info("target " .. blueInterceptTargets[i].name .. " detected on bulls, spawning interceptor", false)
                    if not currentlyIntercepting[2][blueInterceptTargets[i].name] and totalIntercepting[2] < INTERCEPTORS.intercept_limit then
                        intr.spawnInterceptor(2, blueInterceptTargets[i].name)
                    else
                        env.info("Already intercepting target " .. blueInterceptTargets[i].name, false)
                    end
                end
            end
        end
    end
    local redInterceptTargets = intr.getInterceptorPriority(Utils.checkZoneIntersection(2, "InterceptorZoneRed"), "InterceptorZoneRed")
    if redInterceptTargets then
        for i = 1, INTERCEPTORS.intercept_limit do
            if i <= #redInterceptTargets then
                if intr.detectedOnBulls(1, redInterceptTargets[i].name) then
                    env.info("target " .. redInterceptTargets[i].name .. " detected on bulls, spawning interceptor", false)
                    if not currentlyIntercepting[1][redInterceptTargets[i].name] and totalIntercepting[1] < INTERCEPTORS.intercept_limit then
                        intr.spawnInterceptor(1, redInterceptTargets[i].name)
                    else
                        env.info("Already intercepting target " .. redInterceptTargets[i].name, false)
                    end
                end
            end
        end
    end
    timer.scheduleFunction(Intr.interceptorLoop, nil, timer.getTime() + updateInterval)
end
env.info("Initializing Interceptors...", false)
intr.initTables()
Intr.interceptorLoop()