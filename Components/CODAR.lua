-- codar should piggy back on existing sonobuoy stuff
CODAR = {}
local pairMaxDistance = 4000
local pairMinDistance = 800
local basePairRange = 5500
local searchInterval = 30
local pairId = 1
local buoys = {
    [1] = {},
    [2] = {}
}
local buoyPairs = {
    [1] = {},
    [2] = {},
}
function CODAR.newBuoy(coalitionId, point, buoyId)
    local buoy = {
        coalitionId = coalitionId,
        point = point,
        buoyId = buoyId,
        paired = false,
        pairId = nil,
    }
    buoys[coalitionId][buoyId] = buoy
    CODAR.checkPair(coalitionId, buoyId)
end
function CODAR.removeBuoy(coalitionId, buoyId)
    local buoy = buoys[coalitionId][buoyId]
    if buoy.paired then
        CODAR.breakPair(coalitionId, buoy.pairId)
    end
    buoys[coalitionId][buoyId] = nil
end
function CODAR.breakPair(coalitionId, buoyPairId)
    local buoyPair = buoyPairs[coalitionId][buoyPairId]
    if buoyPair then
        local buoy1 = buoys[coalitionId][buoyPair.buoyIds[1]]
        local buoy2 = buoys[coalitionId][buoyPair.buoyIds[2]]
        if buoy1 then
            buoy1.paired = false
            CODAR.checkPair(coalitionId, buoy1.buoyId)
        end
        if buoy2 then
            buoy2.paired = false
            CODAR.checkPair(coalitionId, buoy2.buoyId)
        end
        if buoyPair.markups.pairLine then
            trigger.action.removeMark(buoyPair.markups.pairLine)
        end
        if buoyPair.markups.midPoint then
            trigger.action.removeMark(buoyPair.markups.midPoint)
        end
        if buoyPair.markups.bearingLineId then
            trigger.action.removeMark(buoyPair.markups.bearingLineId)
        end
        buoyPairs[coalitionId][buoyPairId] = nil
    end
end
function CODAR.checkPair(coalitionId, buoyId)
    local checkingBuoy = buoys[coalitionId][buoyId]
    local closestDistance = nil
    local closestBuoyId = nil
    for k,v in pairs(buoys[coalitionId]) do
        if k ~= buoyId then
            if v.paired == false then
                local buoyDistance = Utils.PointDistance(checkingBuoy.point, v.point)
                if buoyDistance <= pairMaxDistance and buoyDistance >= pairMinDistance and (closestDistance == nil or buoyDistance < closestDistance) then
                    closestDistance = buoyDistance
                    closestBuoyId = k
                end
            end
        end
    end
    if closestBuoyId then
        CODAR.createPair(coalitionId, buoyId, closestBuoyId)
    end
end
function CODAR.createPair(coalitionId, buoy1id, buoy2id)
    local buoy1 = buoys[coalitionId][buoy1id]
    local buoy2 = buoys[coalitionId][buoy2id]
    if buoy1 and buoy2 then
        local pairPoint = Utils.getMidpoint(buoy1.point, buoy2.point)
        local pairLineId = DrawingTools.newMarkId()
        trigger.action.lineToAll(coalitionId, pairLineId, buoy1.point, buoy2.point, {0,0,0,1}, 3, true, nil)
        local midPointId = DrawingTools.newMarkId()
        trigger.action.circleToAll(coalitionId, midPointId, pairPoint, 300, {0,0,0,1}, {0,0,0,0}, 3, true, nil)
        local pair = {
            pairId = CODAR.newPairId(),
            point = pairPoint,
            codar = false,
            buoyIds = {
                [1] = buoy1id,
                [2] = buoy2id,
            },
            markups = {
                pairLine = pairLineId,
                midPoint = midPointId,
                bearingLineId = nil,
            }
        }
        buoyPairs[coalitionId][pair.pairId] = pair
        buoy1.pairId = pair.pairId
        buoy2.pairId = pair.pairId
        buoy1.paired = true
        buoy2.paired = true
    end
end
function CODAR.newPairId()
    local returnId = pairId
    pairId = pairId + 1
    return returnId
end
function CODAR.pairsLoop()
    for c = 1,2 do
        for k,v in pairs(buoyPairs[c]) do
            if v.markups.bearingLineId ~= nil then trigger.action.removeMark(v.markups.bearingLineId) end
            local closestSub = CODAR.searchFromPoint(v.point, basePairRange)
            if closestSub then
                local subPoint = closestSub.point
                local bearingToPoint = Utils.VecNormalize({x = subPoint.x - v.point.x, y = subPoint.y - v.point.y, z = subPoint.z - v.point.z})
                local bearingLineEndPoint = Utils.VectorAdd(v.point, Utils.ScalarMult(bearingToPoint, basePairRange))
                local newBearingLineId = DrawingTools.newMarkId()
                trigger.action.lineToAll(c, newBearingLineId, v.point, bearingLineEndPoint, {0,0,0,1}, 1, true, nil)
                v.markups.bearingLineId = newBearingLineId
            end
        end
    end
    timer.scheduleFunction(CODAR.pairsLoop, nil, timer:getTime() + searchInterval)
end
function CODAR.searchFromPoint(point, range)
    local closestSub = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = point,
            radius = range
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 and foundItem:isExist() and foundItem:isActive() and (SUBTYPE and foundItem:getTypeName() == SUBTYPE) then
            local subPoint = foundItem:getPoint()
            if subPoint ~= nil then
                local distance = Utils.PointDistance(point, subPoint)
                env.info("CODAR Found submarine " .. foundItem:getName() .. " distance: " .. distance, false)
                if distance ~= nil then
                    if closestSub.distance == nil or distance < closestSub.distance then
                        closestSub.distance = distance
                        closestSub.point = subPoint
                    end
                end
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    if closestSub ~= nil and closestSub.distance ~= nil then
        return closestSub
    else
        return nil
    end
end
CODAR.pairsLoop()
