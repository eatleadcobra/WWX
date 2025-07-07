local debug = false
local torp = {}
local activeTorpInfo = {
    updateRate = 1,
    speed = 20, --m/s
    lifeTime = 360,
    detonateRange = 12, --m
    searchDepth = -25, --m
}
local torpEvents = {}
local subTypes = {
    ["santafe"] = 1,
    ["Type_093"] = 1,
}
function torpEvents:onEvent(event)
    --on hit
    if event.id == 1 and event.weapon and event.weapon.getTypeName then
        if event.weapon:getTypeName() == "LTF_5B" or event.weapon:getTypeName() == "Mark_46" then
            local torpedoPlayerName = ""
            if event.initiator and event.initiator.getPlayerName then
                torpedoPlayerName = event.initiator:getPlayerName()
            end
            torp.TrackTorpedo({torpedo = event.weapon, startTime = timer.getTime(), playerName = torpedoPlayerName, coalitionId = event.weapon:getCoalition()})
        end
        -- elseif event.weapon:getTypeName() == "Mark_46" then
        --     local torpedoPlayerName = ""
        --     local torpedoPlayerGroupID = 0
        --     if event.initiator and event.initiator.getPlayerName and event.initiator:getGroup() then
        --         torpedoPlayerGroupID = event.initiator:getGroup():getID()
        --         torpedoPlayerName = event.initiator:getPlayerName()
        --     end
        --     torp.trackActiveTorpedo({torpedo = event.weapon, startTime = timer.getTime(), playerGroupId = torpedoPlayerGroupID, playerName = torpedoPlayerName, coalitionId = event.weapon:getCoalition()})
        -- end
    end
end
function torp.trackActiveTorpedo(param)
    if param.torpedo:isExist() then
        local vec = param.torpedo:getVelocity()
        if vec ~= nil then
            local weaponPos = param.torpedo:getPosition()
            if weaponPos ~= nil then
                local weaponSpeed = (vec.x^2 + vec.y^2 + vec.z^2)^0.5
                local impactPoint = land.getIP(weaponPos.p, weaponPos.x, weaponSpeed * 0.3)
                if impactPoint then
                    local isWater = land.getSurfaceType({x = impactPoint.x, y = impactPoint.z})
                    if isWater == 2 or isWater == 3 then
                        weaponPos.p.y = activeTorpInfo.searchDepth
                        weaponPos.x.y = 0
                        local simParam = {startTime = param.startTime, playerName = param.playerName, playerGroupId = param.playerGroupId, playerCoalition = param.coalitionId, position = weaponPos, tracking = false, target = nil}
                        param.torpedo:destroy()
                        torp.simulateTorpedo(simParam)
                    end
                else
                    timer.scheduleFunction(torp.trackActiveTorpedo, param, timer.getTime()+0.1)
                end
            end
        end
    end
end
function torp.simulateTorpedo(param)
    trigger.action.outTextForGroup(param.playerGroupId, "Torpedo active!", activeTorpInfo.updateRate, false)
    if param.tracking == false then
        local volP = {
            id = world.VolumeType.PYRAMID,
            params = {
                pos = param.position,
                length = 3200,
                halfAngleHor = 25,
                halfAngleVer = 30,
            }
        }
        local foundSubs = {}
        local ifFound = function(foundItem, val)
            if foundItem:getDesc().category == 3 and foundItem:getPoint().y <=0 and subTypes[foundItem:getTypeName()] then
                table.insert(foundSubs, foundItem)
            end
        end
        world.searchObjects(Object.Category.UNIT, volP, ifFound)
        if #foundSubs > 0 then
            param.target = foundSubs[1]
            param.tracking = true
        end
    end
    if param.tracking == false then
        local threeHundredTime = 300/(activeTorpInfo.speed*activeTorpInfo.updateRate)
        local fiveHundredTime = 500/(activeTorpInfo.speed*activeTorpInfo.updateRate)
        local oneFiveKTime = 1500/(activeTorpInfo.speed*activeTorpInfo.updateRate)
        local twoFiveKTime = 2500/(activeTorpInfo.speed*activeTorpInfo.updateRate)
        local fourKTime = 4000/(activeTorpInfo.speed*activeTorpInfo.updateRate)
        local sixKTime = 6000/(activeTorpInfo.speed*activeTorpInfo.updateRate)
        local elapsedTime = timer:getTime()-param.startTime
        local turnDeg = 7
        if elapsedTime < threeHundredTime then
            turnDeg = 0
        elseif elapsedTime > fiveHundredTime and elapsedTime <= oneFiveKTime then
            turnDeg = 6
        elseif elapsedTime > oneFiveKTime and elapsedTime <= twoFiveKTime then
            turnDeg = 5
        elseif elapsedTime > twoFiveKTime and elapsedTime < fourKTime then
            turnDeg = 4
        elseif elapsedTime > fourKTime and elapsedTime <= sixKTime then
            turnDeg = 3
        elseif elapsedTime > sixKTime then
            turnDeg = 2
        end
        param.position.x = Utils.RotateVector(param.position.x, math.rad(turnDeg))
        param.position.p = Utils.VectorAdd(param.position.p, Utils.ScalarMult(param.position.x, (activeTorpInfo.speed * activeTorpInfo.updateRate)))
    else
        if param.target ~= nil then
            local targetPoint = param.target:getPoint()
            local torpPoint = param.position.p
            local targetVector = {x = targetPoint.x - torpPoint.x, y = targetPoint.y - torpPoint.y, z = targetPoint.z - torpPoint.z}
            ---@diagnostic disable-next-line: deprecated
            local tgtBearing = math.atan2(targetVector.z, targetVector.x)
            ---@diagnostic disable-next-line: deprecated
            local torpHeading = math.atan2(param.position.x.z, param.position.x.x)
            local relativeBearing = tgtBearing-torpHeading
            param.position.x = Utils.RotateVector(param.position.x, relativeBearing)
            param.position.p = Utils.VectorAdd(param.position.p, Utils.ScalarMult(param.position.x, (activeTorpInfo.speed * activeTorpInfo.updateRate)))
            local torpDistance = Utils.PointDistance(param.position.p, targetPoint)
            if torpDistance < activeTorpInfo.detonateRange then
                trigger.action.explosion(targetPoint, 300)
                trigger.action.outTextForGroup(param.playerGroupId, "Torpedo detonated!", 15, false)
                WWEvents.playerDestroyedSubmarine(param.playerName, param.playerCoalition, "killed a submarine!")
                return
            end
        end
    end
    if timer:getTime() - param.startTime < activeTorpInfo.lifeTime then
        timer.scheduleFunction(torp.simulateTorpedo, param, timer:getTime() + activeTorpInfo.updateRate)
    else
        trigger.action.outTextForGroup(param.playerGroupId, "Torpedo is dead in the water!", 10, false)
    end
end
function torp.TrackTorpedo(param)
    local torpedoPoint = {}
    if param.torpedo:isExist() then
        if timer.getTime() - param.startTime > 180 then
            param.torpedo:destroy()
            return
        end
        torpedoPoint = param.torpedo:getPoint()
        if torpedoPoint ~= nil then
            local shipPoint = torp.DetonateTorpedo(torpedoPoint)
            if shipPoint ~= nil then
                trigger.action.explosion(shipPoint, 1000)
                if WWEvents then
                    WWEvents.playerTorpedoedShip(param.playerName, " hit a ship with a torpedo. That's badass!", param.coalitionId)
                end
                if param.torpedo:isExist() then param.torpedo:destroy() end
            end
        end
        timer.scheduleFunction(torp.TrackTorpedo, param, timer.getTime() + 0.2)
    end
end
function torp.DetonateTorpedo(torpedoPoint)
    local shipPoint = nil
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = torpedoPoint,
            radius = 20
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 then
            env.info("TORP: Ship found: " .. foundItem:getTypeName(), false)
            local shipBox = foundItem:getDesc().box
            local shipOrigin = foundItem:getPoint()
            local shipPosition = foundItem:getPosition()
            local shipLength = math.abs(shipBox.max.x) + math.abs(shipBox.min.x)
            local shipWidth = math.abs(shipBox.max.z) + math.abs(shipBox.min.z)
            local collideDistance = math.max(shipLength/3.0, shipWidth)
            collideDistance = collideDistance * 1.2

            local frontPoint = torp.VectorAdd(shipOrigin, torp.ScalarMult(shipPosition.x, collideDistance))
            local rearPoint = torp.VectorSub(shipOrigin, torp.ScalarMult(shipPosition.x, collideDistance))

            local distance1 = torp.PointDistance(torpedoPoint, shipOrigin)
            local distance2 = torp.PointDistance(torpedoPoint, frontPoint)
            local distance3 = torp.PointDistance(torpedoPoint, rearPoint)
            if distance1 <= collideDistance or distance2 <= collideDistance or distance3 <= collideDistance then
                shipPoint = foundItem:getPoint()
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    return shipPoint
end
function torp.ScalarMult(vec, mult)
    return {x = vec.x*mult, y = vec.y*mult, z = vec.z*mult}
end
function torp.VectorMagnitude(vec)
    return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end
function torp.VectorAdd(vec1, vec2)
    return {x = vec1.x + vec2.x, y = vec1.y + vec2.y, z = vec1.z + vec2.z}
end
function torp.VectorSub(vec1, vec2)
    return {x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z}
end
function torp.MakeVec3(vec, y)
    if not vec.z then
        if vec.alt and not y then
            y = vec.alt
        elseif not y then
            y = 0
        end
        return {x = vec.x, y = y, z = vec.y}
    else
        return {x = vec.x, y = vec.y, z = vec.z}	-- it was already Vec3, actually.
    end
end
function torp.PointDistance(point1, point2)
    point1 = torp.MakeVec3(point1)
    point2 = torp.MakeVec3(point2)
    return torp.VectorMagnitude({x = point1.x - point2.x, y = 0, z = point1.z - point2.z})
end
world.addEventHandler(torpEvents)