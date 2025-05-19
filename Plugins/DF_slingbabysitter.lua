-- sling loading baby sitter to stand in until ED fixes slinging (lol)
-- initiate babysitting once a cargo object has moved from its initial point
env.info("loading sling babysitter", false)
SBS = {}
local sbs = {}
local loopTime = 0.5
sbs.trackedCargos = {

}
--coalition, cargo, supplyType, spawnTime, seaPickup , frontPickup , groupId, modifier, groupName, successfulDeployChecks
function SBS.watchCargo(param)
    --add cargo to tracking table, begin loop
    env.info("watching cargo: " .. param.cargo, false)
    local cargo = StaticObject.getByName(param.cargo)
    if cargo then
        local cargoPoint = cargo:getPoint()
        if cargoPoint then
            sbs.trackedCargos[param.cargo] = param
            sbs.trackedCargos[param.cargo].lastPoint = cargoPoint
            sbs.trackedCargos[param.cargo].lastAGL = Utils.getAGL(cargoPoint)
            sbs.watchLoop(param.cargo)
        end
    end
end
function sbs.watchLoop(cargoName)
    --monitor cargo position and speed and try to catch teleporting or disappearing cargo.
    --suspicious conditions: 
        -- difference between last position and current position greater than (speed*looptime)+20%
        -- cargo not found and last position is negative AGL
    if sbs.trackedCargos[cargoName] then
        local cargo = StaticObject.getByName(cargoName)
        if cargo then
            local cargoPoint = cargo:getPoint()
            sbs.trackedCargos[cargoName].lastPoint = cargoPoint
            sbs.trackedCargos[cargoName].lastAGL = Utils.getAGL(cargoPoint)
            if sbs.trackedCargos[cargoName].lastAGL < 0 then
                sbs.trackedCargos[cargoName].belowAGL = true
            end
        else --cargo lost, verify last position
            if sbs.trackedCargos[cargoName].belowAGL then
                env.info("SBS alert: cargo : ".. cargoName .." lost and last pos is below ground level. Recovering", false)
                sbs.recoverCargo(cargoName)
            else
                SBS.endWatch(cargoName)
            end
        end

        timer.scheduleFunction(sbs.watchLoop, cargoName, timer:getTime() + loopTime)
    end
end
function SBS.endWatch(cargoName)
    sbs.trackedCargos[cargoName] = nil
end
function sbs.recoverCargo(cargoName)
    -- if slinger group exists, spawn a new cargo of the same type at the ground beneath the slinger
    -- stop tracking old cargo
    local oldCargo = sbs.trackedCargos[cargoName]
    if oldCargo then
        SBS.endWatch(cargoName)
        local droppingGroup = Group.getByName(oldCargo.groupName)
        if droppingGroup then
            local droppingUnit = droppingGroup:getUnit(1)
            if droppingUnit then
                local droppingPoint = droppingUnit:getPoint()
                if droppingPoint then
                    --coalition, country, spawnPoint, supplyType, spawnTime, seaPickup, frontPickup, isSlung, groupId, modifier, groupName
                    local respawnParams = {
                        coalition = droppingGroup:getCoalition(),
                        country = droppingUnit:getCountry(),
                        spawnPoint = {x = droppingPoint.x, y = land.getHeight({x = droppingPoint.x, y = droppingPoint.z}), z = droppingPoint.z},
                        seaPickup = oldCargo.seaPickup,
                        frontPickup = oldCargo.frontPickup,
                        isSlung = true,
                        groupId = droppingGroup:getID(),
                        modifier = oldCargo.modifier,
                        groupName = oldCargo.groupName,
                        supplyType = oldCargo.supplyType
                    }
                    DFS.spawnCargo(respawnParams)
                end
            end
        end
    end
end