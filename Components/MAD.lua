MAD = {}
local MADRadius = 1000
local dcRadius = 150
local madReadoutIncrement = 10
local madAltLimit = 200
local madloopTime = 1
local madLoopTimeLimit = 180
local smokeTimeInterval = 30
local commandName = "Enable MAD"
local madSoundPath = "l10n/DEFAULT/MAD.ogg"
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
                    local markDeflection = false
                    local smokeInterval = false
                    for i = 1, #subPoints do
                        local distanceToSub = Utils.PointDistance(subPoints[i], searchPoint)
                        if distanceToSub < MADRadius then
                            if distanceToSub <= (madReadoutIncrement*5) then
                                markDeflection = true
                                if timer:getTime() - param.smokeTime > smokeTimeInterval then
                                    smokeInterval = true
                                end
                            end
                            local amp = MADRadius - distanceToSub
                            if amp > madAmplitude then
                                madAmplitude = MADRadius - distanceToSub
                            end
                        end
                    end
                    local fiveHundredMeterIndex = math.floor((MADRadius - 500)/madReadoutIncrement)
                    local threeHundredMeterIndex = math.floor((MADRadius - 300)/madReadoutIncrement)
                    local dcDistanceIndex = math.floor((MADRadius - dcRadius)/madReadoutIncrement)
                    if param.runs == 0 then
                        local markerString = "|"
                        for i = 1, ((MADRadius/madReadoutIncrement)+1) do
                            if i == fiveHundredMeterIndex then
                                markerString = markerString .. "|"
                            elseif i == threeHundredMeterIndex then
                                markerString = markerString .. "|"
                            elseif i == dcDistanceIndex then
                                markerString = markerString .. "|"
                            else
                                markerString = markerString .. " "
                            end
                        end
                        markerString = markerString .. "|"
                        trigger.action.outTextForGroup(searchingGroup:getID(), markerString, madLoopTimeLimit, false)
                    end
                    local madString ="|"
                    local spaces = math.floor(madAmplitude/madReadoutIncrement)
                    for i = 1, spaces do
                        madString = madString .. " "
                    end
                    madString = madString .. "*"
                    for i = spaces, ((MADRadius/madReadoutIncrement)-2) do
                        madString = madString .. " "
                    end
                    madString = madString .. "|"
                    trigger.action.outTextForGroup(searchingGroup:getID(), madString, madloopTime+15, false)
                    if markDeflection and smokeInterval then
                        trigger.action.outSoundForGroup(searchingGroup:getID(), madSoundPath)
                        local smokeName = searchingUnit:getName() .. tostring(timer:getTime())
                        trigger.action.smoke({x = searchPoint.x, y = 0, z = searchPoint.z}, 0, smokeName)
                        local plotterMarkId = DrawingTools.drawCircle(searchingGroup:getCoalition(), searchPoint)
                        timer.scheduleFunction(trigger.action.removeMark, plotterMarkId, timer:getTime()+300)
                        timer.scheduleFunction(trigger.action.effectSmokeStop, smokeName, timer:getTime()+300)
                        param.smokeTime = timer:getTime()
                    end
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
        missionCommands.addCommandForGroup(addGroup:getID(), commandName, nil, MADLoop, {groupName = groupName, runs = 0, smokeTime = 0})
    end
end
function MAD.removeRadioCommandsForGroup(groupID)
        missionCommands.removeItemForGroup(groupID, {[1] = commandName})
end