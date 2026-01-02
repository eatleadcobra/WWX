Reaper = {}
local reaper = {}
reaper.callIns = {}
local droneInterval = 300
local reaperGroupNames = {
    [1] = "Reaper",
    [2] = "Reaper"
}

function Reaper.addRadioCommandsForReaperGroup(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup then
        if REAPER then
            reaper.addCommand(groupName)
        end
    end
end
function reaper.addCommand(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup then
        local addId = addGroup:getID()
        if addId then
            local reaperMenu = missionCommands.addSubMenuForGroup(addId, "Call Reaper Drone to BP", nil)
            local bpCount = 9
            for i = 1, bpCount do
                missionCommands.addCommandForGroup(addId, "Battle Position " .. i, reaperMenu, reaper.callDrone, {requestingGroupName = groupName, targetBp = i})
            end
        end
    end
end
--requestingGroupName, targetBp
function reaper.callDrone(param)
    if reaper.callIns[param.requestingGroupName] == nil then
        reaper.callIn(param.requestingGroupName, param.targetBp)
    else
        local lastDroneTime = reaper.callIns[param.requestingGroupName].lastDroneTime
        if timer.getTime() - lastDroneTime > droneInterval then
            reaper.callIn(param.requestingGroupName, param.targetBp)
        else
            local requestingGroup = Group.getByName(param.requestingGroupName)
            if requestingGroup then
                local requestingGroupId = requestingGroup:getID()
                if requestingGroupId then
                    trigger.action.outTextForGroup(requestingGroupId, "You must wait " .. droneInterval .. "s between drone call-ins.", 10, false)
                end
            end
        end
    end
end
function reaper.callIn(requestingGroupName, targetBp)
    if reaper.callIns[requestingGroupName] ~= nil then
        -- destroy current drone
        local currentUserDrone = Group.getByName(reaper.callIns[requestingGroupName].droneName)
        if currentUserDrone then
            currentUserDrone:destroy()
        end
    end
    local bpPoint = BattleControl.getBPPoint(targetBp)
    if bpPoint then

        local droneParams = {
            pattern      = "Circle",
            point        = { x = bpPoint.x, y = bpPoint.z},
            altitude     = (env.mission.weather.clouds.base - 200),
        }
        local afac = {id = 'Orbit', params = droneParams}
        local droneGroupName = mist.cloneGroup(reaperGroupNames[2], false).name
        reaper.callIns[requestingGroupName] = { droneName = droneGroupName, lastDroneTime = timer.getTime()}
        timer.scheduleFunction(reaper.tasking, {groupName = droneGroupName, droneMission = afac}, timer.getTime() + 5)
        local requestingGroup = Group.getByName(requestingGroupName)
        if requestingGroup then
            local requestingGroupId = requestingGroup:getID()
            if requestingGroupId then
                trigger.action.outTextForGroup(requestingGroupId, "Reaper drone inbound to Battle Position " .. targetBp, 10, false)
            end
        end
    else
        env.info("Reaper call in error. No point returned for BPID", false)
    end
end
--groupName, droneMission
function reaper.tasking(param)
    local droneGroup = Group.getByName(param.groupName)
    if droneGroup then
        local droneController = droneGroup:getController()
        if droneController then
            droneController:setTask(param.droneMission)
        end
    end
end
