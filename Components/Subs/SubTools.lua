SubTools = {}
local subSearchRadius = 35000

function SubTools.newCalculateIntercept(shipPoint, subPoint, shipPosition, shipVelocity, subSpeed)
    trigger.action.outText("calculating intercept", 10, false)

    local shipSpeed = (shipVelocity.x^2 + shipVelocity.y^2 + shipVelocity.z^2)^0.5
    local interceptFound = false
    local calcTries = 0
    
    local subTimeToRadius = (subSearchRadius/subSpeed)

    local shipTravelDistanceInTime = shipSpeed*subTimeToRadius
    local searchIncrement = 200
    local searchCutoff = math.floor(shipTravelDistanceInTime/searchIncrement)

    local shipIntPoint = {}
    local shipIntDistance = 1
    local interceptSpeed = subSpeed

    while interceptFound == false do
        calcTries = calcTries + 1
        if calcTries > searchCutoff then
            env.info("Sub Intercept calculation failed", false)
            trigger.action.outText("Sub Intercept calculation failed", 10, false)
            break
        end

        -- where the ship will be in x meters
        shipIntPoint = Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPosition.x, (searchIncrement*calcTries)))
        -- how long will it take to get there
        local shipTimeToPoint = (Utils.PointDistance(shipPoint, shipIntPoint)/shipSpeed)
        -- how far can the submarine travel in this time
        local subRadiusInShipTravelTime = subSpeed * shipTimeToPoint
        -- is this ship point within the subs radius
        local pointRechableBySub = ( (shipIntPoint.x - subPoint.x)^2 + (shipIntPoint.z - subPoint.z)^2 < (subRadiusInShipTravelTime^2) )
        if pointRechableBySub then
            trigger.action.outText("Attempt " .. calcTries, 1, false)
            trigger.action.outText("Sub Can Reach this point", 10, false)
            interceptSpeed = Utils.PointDistance(subPoint, shipIntPoint)/shipTimeToPoint
            interceptFound = true
        end
    end
    if interceptFound then
        trigger.action.outText("Intercept Found", 10, false)
        local runInOne = Utils.VectorAdd(shipIntPoint, Utils.ScalarMult(Utils.RotateVector(shipPosition.x, 1.5708), 3000))
        local runInTwo = Utils.VectorAdd(shipIntPoint, Utils.ScalarMult(Utils.RotateVector(shipPosition.x, -1.5708), 3000))
        local closestRunIn = runInOne
        if Utils.PointDistance(subPoint, runInTwo) < Utils.PointDistance(subPoint, runInOne) then closestRunIn = runInTwo end
        local speedToRunIn = interceptSpeed
        local vector = Utils.VecNormalize({x = closestRunIn.x - subPoint.x, y = closestRunIn.y - subPoint.y, z = closestRunIn.z - subPoint.z})
        local bearing = math.atan2(vector.z, vector.x)
        local attackRunVector = Utils.VecNormalize({x = shipIntPoint.x - closestRunIn.x, y = shipIntPoint.y - closestRunIn.y, z = shipIntPoint.z - closestRunIn.z})
        local attackRunEndPoint = Utils.VectorAdd(closestRunIn, Utils.ScalarMult(attackRunVector, subSpeed*(300)))
        return closestRunIn, attackRunEndPoint, bearing, speedToRunIn
    else
        return nil
    end
end






function SubTools.calculateIntercept(shipPoint, subPoint, shipPosition, shipVelocity, subSpeed)
    trigger.action.outText("calculating interept", 10, false)
    local shipSpeed = (shipVelocity.x^2 + shipVelocity.y^2 + shipVelocity.z^2)^0.5
    local interceptFound = false
    local calcTries = 1
    local subToShipDistance = Utils.PointDistance(subPoint, shipPoint)
    local shipTravelTime = math.floor(subToShipDistance/shipSpeed)
    trigger.action.outText("ship travel time: " .. shipTravelTime, 10, false)
    local interceptBuffer = 30
    local interceptSpeed = subSpeed
    local shipIntPoint = {}
    local shipIntPointOffest = {}
    while interceptFound == false do
        shipIntPoint = Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPosition.x, subToShipDistance))
        local subTimeToIntPoint = Utils.PointDistance(subPoint, shipIntPoint)/subSpeed
        trigger.action.outText("Sub time to int point: " .. subTimeToIntPoint, 10, false)
        if subTimeToIntPoint < (shipTravelTime-interceptBuffer) then
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
        elseif subTimeToIntPoint > (shipTravelTime+interceptBuffer) then
            shipTravelTime = shipTravelTime + 30
            calcTries = calcTries + 1
        elseif subTimeToIntPoint == shipTravelTime then
            interceptFound = true
            shipIntPointOffest = Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPosition.x, shipSpeed*(shipTravelTime+500)))
            break
        end
        if calcTries > 100 then
            env.info("Sub Intercept calculation failed", false)
            trigger.action.outText("Sub Intercept calculation failed", 10, false)
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
            if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 3 and foundItem:getCoalition() ~= subCoalition then
                trigger.action.outText("found enemy ship", 10, false)
                local shipPoint = foundItem:getPoint()
                if shipPoint ~= nil then
                    local distance = Utils.PointDistance(subPoint, shipPoint)
                    if distance ~= nil then
                        if SubTools.newCalculateIntercept(shipPoint, subPoint, foundItem:getPosition(), foundItem:getVelocity(), subSpeed) and (closestShip.distance == nil or distance < closestShip.distance) then
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