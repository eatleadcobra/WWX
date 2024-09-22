MAD = {}
local MADRadius = 1000
local madReadoutIncrement = 10
local madAltLimit = 200
local madloopTime = 1
local madLoopTimeLimit = 180
local commandName = "Enable MAD"
local subTypes = {
    ["santafe"] = 1,
    ["Type_093"] = 1,
}
function MAD.searchPointForSubs(point)
    local foundSubs = {}
    local searchVolume = {
        id = world.VolumeType.SPHERE,
        params = {
          point = point,
          radius = MADRadius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 and foundItem:getPoint().y <=0 and subTypes[foundItem:getTypeName()] then
            table.insert(foundSubs, foundItem:getPoint())
        end
    end
    world.searchObjects(Object.Category.UNIT, searchVolume, ifFound)
    return foundSubs
end
--groupName, runs
function MADLoop(param)
    local searchingGroup = Group.getByName(param.groupName)
    if searchingGroup then
        missionCommands.removeItemForGroup(searchingGroup:getID(), {[1] = commandName})
        local runTime = param.runs * madloopTime
        if runTime > madLoopTimeLimit then
            trigger.action.outTextForGroup(searchingGroup:getID(), "MAD search time limit expired!", 5, false)
            MAD.addCommand(param.groupName)
            return
        end
        local searchingUnit = searchingGroup:getUnit(1)
        if searchingUnit then
            local searchPoint = searchingUnit:getPoint()
            local searchPos = searchingUnit:getPosition()
            if searchPoint and searchPos then
                if searchPoint.y <= madAltLimit then
                    local subPoints = MAD.searchPointForSubs(searchPoint)
                    local madAmplitude = 0
                    for i = 1, #subPoints do
                        local distanceToSub = Utils.PointDistance(subPoints[i], searchPoint)
                        if distanceToSub < MADRadius then
                            local amp = MADRadius - distanceToSub
                            if amp > madAmplitude then
                                madAmplitude = MADRadius - distanceToSub
                            end
                        end
                    end
                    local madString ="|"
                    local spaces = math.floor(madAmplitude/madReadoutIncrement)
                    for i = 1, spaces do
                        madString = madString .. " "
                    end
                    madString = madString .. "*"
                    for i = spaces, ((MADRadius/madReadoutIncrement)-2) do
                        madString = madString.." "
                    end
                    madString = madString .. "|"
                    trigger.action.outTextForGroup(searchingGroup:getID(), madString, madloopTime+15, false)
                    param.runs = param.runs + 1
                    timer.scheduleFunction(MADLoop, param, timer:getTime() + madloopTime)
                else
                    trigger.action.outTextForGroup(searchingGroup:getID(), "You are too high to use your MAD!", 10, false)
                    MAD.addCommand(param.groupName)
                end
            end
        end
    end
end
function MAD.addCommand(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup then
        missionCommands.addCommandForGroup(addGroup:getID(), commandName, nil, MADLoop, {groupName = groupName, runs = 0})
    end
end
function MAD.removeRadioCommandsForGroup(groupID)
        missionCommands.removeItemForGroup(groupID, {[1] = commandName})
end