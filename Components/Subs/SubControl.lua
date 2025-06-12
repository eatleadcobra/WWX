SubControl = {}
SubControl.subValues = {
    ["type93"] = {
        maxSpeed = 4.16,
        maxDepth = -100,
        periscopeDepth = -12,
    },
    ["santafe"] = {
        maxSpeed = 4.16,
        maxDepth = -56,
        periscopeDepth = -9,
    }
}
function SubControl.createSubWithIntercept(coalitionId, point, subType, depth, closestShip)
    if closestShip.distance then
        local closestRunIn, attackRunEndPoint, bearing, speedToRunIn = SubTools.newCalculateIntercept(closestShip.point, point, closestShip.position, closestShip.velocity, SubControl.subValues[subType].maxSpeed)
        if closestRunIn then
            local wpList = SpawnFuncs.createWPListFromPoints({point, closestRunIn, attackRunEndPoint, point})
            local groupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(coalitionId, 3, {subType}, wpList)
            local point1depth = SubControl.subValues[subType].maxDepth/2
            if depth then point1depth = depth end
            groupTable["units"][1]["heading"] = bearing
            groupTable["route"]["points"][1].alt = point1depth
            groupTable["route"]["points"][1].speed = speedToRunIn
            groupTable["route"]["points"][2].alt = SubControl.subValues[subType].maxDepth/2
            groupTable["route"]["points"][2].speed = speedToRunIn
            groupTable["route"]["points"][3].alt = SubControl.subValues[subType].periscopeDepth
            groupTable["route"]["points"][3].speed = SubControl.subValues[subType].maxSpeed
            groupTable["route"]["points"][4].alt = SubControl.subValues[subType].maxDepth
            groupTable["route"]["points"][4].speed = SubControl.subValues[subType].maxSpeed
            coalition.addGroup(80+(2-coalitionId), 3, groupTable)
            return groupTable["name"], closestRunIn
        else
            return nil
        end
    end
end
function SubControl.updateSubMissionWithIntercept(groupName, point, subType, depth, closestShip)
    trigger.action.outText("Update sub with intercept", 10, false)
    if closestShip.distance then
        local closestRunIn, attackRunEndPoint, bearing, speedToRunIn = SubTools.newCalculateIntercept(closestShip.point, point, closestShip.position, closestShip.velocity, SubControl.subValues[subType].maxSpeed)
        if closestRunIn then
            local wpList = SpawnFuncs.createWPListFromPoints({point, closestRunIn, attackRunEndPoint, point})
            local missionTable = SpawnFuncs.createMission(wpList)
            local point1depth = SubControl.subValues[subType].maxDepth/2
            if depth then point1depth = depth end
            missionTable["params"]["route"]["points"][1].alt = point1depth
            missionTable["params"]["route"]["points"][1].speed = speedToRunIn
            missionTable["params"]["route"]["points"][2].alt = SubControl.subValues[subType].maxDepth/2
            missionTable["params"]["route"]["points"][2].speed = speedToRunIn
            missionTable["params"]["route"]["points"][3].alt = SubControl.subValues[subType].periscopeDepth
            missionTable["params"]["route"]["points"][4].speed = SubControl.subValues[subType].maxSpeed
            missionTable["params"]["route"]["points"][4].alt = SubControl.subValues[subType].maxDepth
            missionTable["params"]["route"]["points"][4].speed = SubControl.subValues[subType].maxSpeed
            local subGroup = Group.getByName(groupName)
            if subGroup then
                local SubController = subGroup:getController()
                if SubController then
                    SubController:setTask(missionTable)
                end
            end
        else
            return nil
        end
    end
end
function SubControl.createSubWithNoIntercept(coalitionId, startPoint, endPoint, subType, startDepth, endDepth)
    local wpList = SpawnFuncs.createWPListFromPoints({startPoint, endPoint})
    local groupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(coalitionId, 3, {subType}, wpList)
    local point1depth = (SubControl.subValues[subType].maxDepth)/2
    local point2depth = (SubControl.subValues[subType].maxDepth)/2
    if startDepth then point1depth = startDepth end
    if endDepth then point2depth = endDepth end
    local vector = Utils.VecNormalize({x = endPoint.x - startPoint.x, y = endPoint.y - startPoint.y, z = endPoint.z - startPoint.z})
    local bearing = math.atan2(vector.z, vector.x)
    groupTable["units"][1]["heading"] = bearing
    groupTable["route"]["points"][1].alt = point1depth
    groupTable["route"]["points"][1].speed = SubControl.subValues[subType].maxSpeed
    groupTable["route"]["points"][2].alt = point2depth
    groupTable["route"]["points"][2].speed = SubControl.subValues[subType].maxSpeed
    coalition.addGroup(80+(2-coalitionId), 3, groupTable)
    return groupTable["name"]
end
function SubControl.updateSubMissionWithNoIntercept(groupName, startPoint, endPoint, subType, startDepth, endDepth)
    trigger.action.outText("Update sub no intercept", 10, false)
    local wpList = SpawnFuncs.createWPListFromPoints({startPoint, endPoint})
    local missionTable = SpawnFuncs.createMission(wpList)
    local point1depth = (SubControl.subValues[subType].maxDepth)/2
    local point2depth = (SubControl.subValues[subType].maxDepth)/2
    if startDepth then point1depth = startDepth end
    if endDepth then point2depth = endDepth end
    local vector = Utils.VecNormalize({x = endPoint.x - startPoint.x, y = endPoint.y - startPoint.y, z = endPoint.z - startPoint.z})
    missionTable["params"]["route"]["points"][1].alt = point1depth
    missionTable["params"]["route"]["points"][1].speed = SubControl.subValues[subType].maxSpeed
    missionTable["params"]["route"]["points"][2].alt = point2depth
    missionTable["params"]["route"]["points"][2].speed = SubControl.subValues[subType].maxSpeed
    local subGroup = Group.getByName(groupName)
    if subGroup then
        local SubController = subGroup:getController()
        if SubController then
            SubController:setTask(missionTable)
        end
    end
end
function SubControl.engage(coalitionId, groupName)
    env.info("Sub engage start", false)
    trigger.action.outText("Sub engage start", 10, false)
    local subGroup = Group.getByName(groupName)
    if subGroup ~= nil then
        local subUnit = subGroup:getUnit(1)
        if subUnit ~= nil then
            local subPos = subUnit:getPosition()
            local subPoint = subUnit:getPoint()
            local volP = {
                id = world.VolumeType.PYRAMID,
                params = {
                    pos = subPos,
                    length = 5000,
                    halfAngleHor = math.rad(22.5),
                    halfAngleVer = math.rad(5)
                }
            }
            local closestShip = {}
            local ifFound = function(foundItem, val)
                trigger.action.outText("Found something", 10, false)
                if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 3 and foundItem:getCoalition() ~= coalitionId and foundItem:hasAttribute("Unarmed ships") then
                    local shipPoint = foundItem:getPoint()
                    env.info("Sub Engage Found: " .. foundItem:getName(), false)
                    trigger.action.outText("Found: " .. foundItem:getName(), 10, false)
                    if shipPoint ~= nil then
                        local xDistance = math.abs(subPoint.x - shipPoint.x)
                        local yDistance = math.abs(subPoint.z - shipPoint.z)
                        local distance = math.sqrt(xDistance*xDistance + yDistance*yDistance)
                        if distance ~= nil then
                            if closestShip.distance == nil or distance < closestShip.distance then
                                closestShip.distance = distance
                                closestShip.point = shipPoint
                                closestShip.coalition = foundItem:getCoalition()
                            end
                        end
                    end
                end
            end
            world.searchObjects(Object.Category.UNIT, volP, ifFound)
            if closestShip.distance ~= nil and closestShip.point ~= nil then
                local explosionPower = 1200
                trigger.action.explosion(closestShip.point, explosionPower)
                env.info("Ship killed by sub: " .. coalitionId, false)
                trigger.action.outTextForCoalition(closestShip.coalition, "Ship destroyed by enemy sub!!", 30, false)
                return 1
            end
            return 0
        end
    end
end