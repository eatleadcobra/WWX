local debug = false
local torp = {}
local torpEvents = {}
function torpEvents:onEvent(event)
    --on hit
    if event.id == 1 and event.weapon and event.weapon.getTypeName then
        if event.weapon:getTypeName() == "LTF_5B" or event.weapon:getTypeName() == "Mark_46" then
            local torpedoPlayerName = ""
            if event.initiator and event.initiator.getPlayerName then
                torpedoPlayerName = event.initiator:getPlayerName()
            end
            env.info("Tracking torpedo: " .. event.weapon:getCategory(), false)
            torp.TrackTorpedo({torpedo = event.weapon, startTime = timer.getTime(), playerName = torpedoPlayerName, coalitionId = event.weapon:getCoalition()})
        end
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
                env.info("Detonate", false)
                trigger.action.explosion(shipPoint, 1000)
                if WWEvents then
                    WWEvents.playerTorpedoedShip(param.playerName, param.playerName .. " hit a ship with a torpedo. That's badass!", param.coalitionId)
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