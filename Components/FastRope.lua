FR = {}
local frEvents = {}
local ropeLength = 8 --meters
local velocityThreshold = 0.5 --m/s
local fastRopeCheckDuration = 60 --seconds
local shipLengthDiff = 80 --meters
local shipWidthDiff = 7 --meters
local shipDeckHeight = 13 --meters
function frEvents:onEvent(event)
    --on birth
    if (event.id == world.event.S_EVENT_BIRTH) then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group and group:getCategory() == 1 then
                --missionCommands.addCommandForGroup(group:getID(), "Begin Fast Rope (60s)", {}, FR.ropeLoop, {groupName = group:getName(), startTime = 0})
            end
        end
    end
end
--world.addEventHandler(frEvents)
--groupName, startTime
function FR.ropeLoop(param)
    -- get group,unit,point, and pos
    -- if over water, search directly beneath for a ship
    -- if AGL < rope length (8m?) and velocity < 0.5 (relative to ground or ship beneath if applicable) then deploy troops
    if param.startTime == 0 then param.startTime = timer:getTime() end
    local ropingGroup = Group.getByName(param.groupName)
    if ropingGroup then
        trigger.action.outTextForGroup(ropingGroup:getID(), "Fast Roping In Progress...", 1, false)
        local ropingUnit = ropingGroup:getUnit(1)
        if ropingUnit then
            local ropingPoint = ropingUnit:getPoint()
            local ropingPos = ropingUnit:getPosition()
            local ropingVelo = ropingUnit:getVelocity()
            if ropingPoint and ropingPos and ropingVelo then
                local heading = math.atan2(ropingPos.x.z, ropingPos.x.x)
                if heading < 0 then heading = heading + (2 * math.pi) end
                local searchPoint = {x = ropingPoint.x, y = ropingPoint.y - ropeLength, z = ropingPoint.z}
                local searchRadius = 1
                local searchVolume = {
                    id = world.VolumeType.SPHERE,
                    params = {
                      point = searchPoint,
                      radius = searchRadius
                    }
                }
                local foundShip = false
                local landingShipName = ""
                local ifFound = function(foundItem, val)
                    if foundItem:getDesc().category == 3 then
                        foundShip = true
                        landingShipName = foundItem:getGroup():getName()
                    end
                    return true
                end
                world.searchObjects(Object.Category.UNIT, searchVolume, ifFound)
                local relativeVel = {x = 0, y = 0, z = 0}
                local inBounds = Utils.getAGL(ropingPoint) <= ropeLength
                if foundShip then
                    local shipGroup = Group.getByName(landingShipName)
                    if shipGroup then
                        local shipUnit = shipGroup:getUnit(1)
                        if shipUnit then
                            inBounds = false
                            local shipVelocity = shipUnit:getVelocity()
                            local shipPoint = shipUnit:getPoint()
                            local shipPos = shipUnit:getPosition()
                            if shipVelocity and shipPoint and shipPos then
                                local checkPoints = {}
                                local pointCount = math.floor(shipLengthDiff/shipWidthDiff)
                                for i = 1, pointCount do
                                    table.insert(checkPoints, Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPos.x, shipWidthDiff*i)))
                                    table.insert(checkPoints, Utils.VectorAdd(shipPoint, Utils.ScalarMult(shipPos.x, -shipWidthDiff*i)))
                                end
                                for i = 1, #checkPoints do
                                    if Utils.PointDistance(ropingPoint, checkPoints[i]) < shipWidthDiff then
                                        if ropingPoint.y - shipDeckHeight <= ropeLength then
                                            inBounds = true
                                        end
                                    end
                                end
                                if inBounds then trigger.action.outTextForGroup(ropingGroup:getID(), "Over deck!", 1, false) end
                                relativeVel = {x = shipVelocity.x, y = shipVelocity.y, z = shipVelocity.z}
                            end
                        end
                    end
                end
                local relativeX = ropingVelo.x - relativeVel.x
                local relativeY = ropingVelo.y - relativeVel.y
                local relativeZ = ropingVelo.z - relativeVel.z
                local xInParam =  math.abs(relativeX) < velocityThreshold
                local yInParam = math.abs(relativeY) < velocityThreshold
                local zInParam = math.abs(relativeZ) < velocityThreshold
                if xInParam and yInParam and zInParam and inBounds then
                    missionCommands.removeItemForGroup(ropingGroup:getID(), {[1] = "Begin Fast Rope (60s)"})
                    missionCommands.removeItemForGroup(ropingGroup:getID(), {[1] = "Cargo/Troop Transport", [2] = "Troop Transportation", [3] = "Drop " .. DFS.supplyNames[DFS.supplyType.SF]})
                    trigger.action.outTextForGroup(ropingGroup:getID(), "Deploying Troops!", 5, false)
                    param.startTime = 0
                    DFS.troopUnloadExternal(param.groupName, DFS.supplyType.SF, nil)
                    return
                end
                if timer:getTime() - param.startTime > fastRopeCheckDuration then
                    trigger.action.outTextForGroup(ropingGroup:getID(), "Fast Rope Expired", 5, false)
                    param.startTime = 0
                    return
                else
                    timer.scheduleFunction(FR.ropeLoop, {groupName = param.groupName, startTime = param.startTime}, timer:getTime() + 1)
                end
            end
        end
    end
end