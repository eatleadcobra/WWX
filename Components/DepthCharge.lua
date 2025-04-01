local depthCharge = {}
local dcEvents = {}
local chargeDepths = {}
local dcDamageRange = 150
local dcKillRange = 50
local subTypes = {["santafe"] = 1, ["Type_093"] = 2}
function dcEvents:onEvent(event)
	--on weapon release
	if event.id == 1 then
        if event.weapon and event.initiator and event.weapon:getDesc().category == 3 then
            local playerName = event.initiator:getPlayerName()
            depthCharge.trackBomb({weapon = event.weapon, initiator = event.initiator, playerName = playerName, coalition = event.initiator:getCoalition()})
        end
    end
end
--weapon, initiator
function depthCharge.trackBomb(param)
    if param.weapon:isExist() then
        local vec = param.weapon:getVelocity()
        if vec ~= nil then
            local weaponPos = param.weapon:getPosition()
            if weaponPos ~= nil then
                local weaponSpeed = (vec.x^2 + vec.y^2 + vec.z^2)^0.5
                local impactPoint = land.getIP(weaponPos.p, weaponPos.x, weaponSpeed * 0.3)
                if impactPoint then
                    local isWater = land.getSurfaceType({x = impactPoint.x, y = impactPoint.z})
                    if isWater == 2 or isWater == 3 then
                        --local depth = (depthCharge.getDepthForInitiator(param.initiator)) * 0.3048 -- this will be the location to look up the depth charge depth set by the event initiator
                        local explDelay = 4
                        local warhead = param.weapon:getDesc().warhead
                        local warheadMass = 50
                        if warhead ~= nil then
                            if warhead.warheadMass ~= nil then
                                warheadMass = warhead.warheadMass
                            end
                        end
                        timer.scheduleFunction(depthCharge.explodeCharge, {explodePoint = impactPoint, power = warheadMass, playerName = param.playerName, coalition = param.coalition}, timer:getTime() + explDelay)
                    end
                else
                    timer.scheduleFunction(depthCharge.trackBomb, {weapon = param.weapon, initiator = param.initiator, playerName = param.playerName, coalition = param.coalition}, timer.getTime()+0.1)
                end
            end
        end
    end
end
--explodePoint, depth
function depthCharge.explodeCharge(param)
    param.explodePoint.y = param.explodePoint.y - 25
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = param.explodePoint,
            radius = 350
        }
    }
    local closestSub = {}
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 then
            local subPoint = foundItem:getPoint()
            if subPoint ~= nil then
                local distance = VectorMagnitude({x = param.explodePoint.x - subPoint.x, y = param.explodePoint.y - subPoint.y, z = param.explodePoint.z - subPoint.z})
                if distance ~= nil and subTypes[foundItem:getTypeName()] ~= nil then
                    if closestSub.distance == nil or distance < closestSub.distance then
                        closestSub.distance = distance
                        closestSub.point = subPoint
                        closestSub.coalition = foundItem:getCoalition()
                    end
                end
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    --local dcTarget = VB.createDCpoint(param.explodePoint, param.coalition)
    trigger.action.explosion(param.explodePoint, param.power)
    if closestSub.distance ~= nil then
        if closestSub.distance < dcDamageRange then
            DFSubs.subDamaged(closestSub.coalition)
        end
    end
end
function VectorMagnitude(vec)
    return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end
--groupName, chargeDepth
function depthCharge.setDepth(param)
    local groupFound = false
    for i = 1, #chargeDepths do
        if chargeDepths[i].groupName == param.groupName then
            groupFound = true
            chargeDepths[i].chargeDepth = param.chargeDepth
            break
        end
    end
    if not groupFound then
        table.insert(chargeDepths, {groupName = param.groupName, chargeDepth = param.chargeDepth})
    end
end

world.addEventHandler(dcEvents)