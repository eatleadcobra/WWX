SubTools = {}
local subSearchRadius = 35000

function SubTools.calculateIntercept(shipPoint, subPoint, shipPosition, shipVelocity, subSpeed)
    local shipSpeed = (shipVelocity.x^2 + shipVelocity.y^2 + shipVelocity.z^2)^0.5
    local interceptFound = false
    local calcTries = 1
    local shipTravelTime = 600
    local interceptSpeed = subSpeed
    local shipIntPoint = {}
    local shipIntPointOffest = {}
    while interceptFound == false do
        shipIntPoint = Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPosition.x, shipSpeed*shipTravelTime))
        local subTimeToIntPoint = Utils.PointDistance(subPoint, shipIntPoint)/subSpeed
        if subTimeToIntPoint < shipTravelTime then
            local speedRequired = Utils.PointDistance(subPoint, shipIntPoint)/shipTravelTime
            if speedRequired >= subSpeed/2 then
                interceptSpeed = speedRequired
                interceptFound = true
                shipIntPointOffest = Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPosition.x, shipSpeed*(shipTravelTime+500)))
                break
            else
                shipTravelTime = shipTravelTime - 30
                calcTries = calcTries + 1
            end
        elseif subTimeToIntPoint > shipTravelTime then
            shipTravelTime = shipTravelTime + 30
            calcTries = calcTries + 1
        elseif subTimeToIntPoint == shipTravelTime then
            interceptFound = true
            shipIntPointOffest = Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPosition.x, shipSpeed*(shipTravelTime+500)))
            break
        end
        if calcTries > 5000 then
            env.info("Sub Intercept calculation failed", false)
            break
        end
    end
    if interceptFound then
        local runInOne = Utils.VectorAdd(shipIntPoint, Utils.ScalarMult(Utils.RotateVector(shipPosition.x, 1.5708), 3000))
        local runInTwo = Utils.VectorAdd(shipIntPoint, Utils.ScalarMult(Utils.RotateVector(shipPosition.x, -1.5708), 3000))
        local closestRunIn = runInOne
        if Utils.PointDistance(subPoint, runInTwo) < Utils.PointDistance(subPoint, runInOne) then closestRunIn = runInTwo end
        local speedToRunIn = interceptSpeed
        local distanceToRunIn = Utils.PointDistance(subPoint, closestRunIn)
        speedToRunIn = distanceToRunIn/shipTravelTime
        local vector = Utils.VecNormalize({x = closestRunIn.x - subPoint.x, y = closestRunIn.y - subPoint.y, z = closestRunIn.z - subPoint.z})
        local bearing = math.atan2(vector.z, vector.x)
        local attackRunVector = Utils.VecNormalize({x = shipIntPoint.x - closestRunIn.x, y = shipIntPoint.y - closestRunIn.y, z = shipIntPoint.z - closestRunIn.z})
        local attackRunEndPoint = Utils.VectorAdd(closestRunIn, Utils.ScalarMult(attackRunVector, subSpeed*(300)))
        return closestRunIn, attackRunEndPoint, bearing, speedToRunIn
    else
        return nil
    end
end

function SubTools.findClosestShip(subPoint, subCoalition, subSpeed)
    local closestShip = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = subPoint,
            radius = subSearchRadius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 then
            if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 3 and foundItem:getCoalition() ~= subCoalition and foundItem:hasAttribute("Unarmed ships") then
                local shipPoint = foundItem:getPoint()
                if shipPoint ~= nil then
                    local distance = Utils.PointDistance(subPoint, shipPoint)
                    if distance ~= nil then
                        if SubTools.calculateIntercept(shipPoint, subPoint, foundItem:getPosition(), foundItem:getVelocity(), subSpeed) and (closestShip.distance == nil or distance < closestShip.distance) then
                            closestShip.distance = distance
                            closestShip.point = shipPoint
                            closestShip.velocity = foundItem:getVelocity()
                            closestShip.position = foundItem:getPosition()
                            closestShip.coalition = foundItem:getCoalition()
                        end
                    end
                end
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    return closestShip
end