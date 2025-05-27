-- track a group, allow configuration of what kind of coordinator is present (none v jtac) and what designation is available (none, pave penny, LGB guidance)-- function to follow a group
-- if group detects a target:
    -- hold position
    -- set the target invisible
    -- start shooting at a point around the target
    -- based on available units, destroy enemy units periodically
        -- eg, don't destroy tanks without anti tank weapons present in your group, etc. more firepower = more kills per "turn"
    -- integrate with CAS system so troops in combat can direct friendly aircraft onto enemies
    -- after time is up or target(s) are dead, continue movement and become visible
CAS = {}
CAS.JTACType = {
    NONE = 1,
    JTAC = 2,
    JTAC_DESIGNATOR = 3,
}
local cas = {}
local groups = {

}
cas.loopInterval = 4
cas.battleLoopInterval = 9
cas.engagementDistance = 3000
function CAS.followGroup(groupName, jtacType)
    trigger.action.outText("following group: " .. groupName, 10, false)
    groups[groupName] = { groupName = groupName, jtacType = jtacType, followStartTime = timer:getTime(), inBattle = false, battleStartTime = -1 }
end
function cas.loop()
    for groupName, groupInfo in pairs(groups) do
        if groupInfo.inBattle == false then
            trigger.action.outText("looping group: " .. groupName, cas.loopInterval, false)
            local group = Group.getByName(groupName)
            if group then
                cas.checkGroup(groupName)
            else
                groups[groupName] = nil
            end
        end
    end
    timer.scheduleFunction(cas.loop, nil, timer:getTime() + cas.loopInterval)
end
function cas.checkGroup(groupName)
    trigger.action.outText("checking group: " .. groupName, cas.loopInterval, false)
    local checkingGroup = Group.getByName(groupName)
    if checkingGroup then
        trigger.action.outText("group found", cas.loopInterval, false)
        local checkingUnit = checkingGroup:getUnit(1)
        if checkingUnit then
            local checkingPoint = checkingUnit:getPoint()
            if checkingPoint then
                local cgController = checkingGroup:getController()
                if cgController then
                    trigger.action.outText("controller found", cas.loopInterval, false)
                    local detectedEnemies = cgController:getDetectedTargets(Controller.Detection.VISUAL,Controller.Detection.OPTIC)
                    local detectedGroups = {}
                    if #detectedEnemies > 0 then
                        trigger.action.outText("enemies detected", cas.loopInterval, false)
                        for i = 1, #detectedEnemies do
                            trigger.action.outText("detected enemy type: " .. detectedEnemies[i].object:getDesc().category, cas.loopInterval, false)
                            if detectedEnemies[i].object:getDesc().category == 2 and detectedEnemies[i].object:hasAttribute("Armed vehicles") then
                                trigger.action.outText("ground unit detected", cas.loopInterval, false)
                                detectedGroups[detectedEnemies[i].object:getGroup():getName()] = 1
                            end
                        end
                        for k,v in pairs(detectedGroups) do
                            trigger.action.outText(groupName .. " has detected the group: " .. k, 10, false)
                            local detectedGroup = Group.getByName(k)
                            if detectedGroup then
                                trigger.action.outText("retrieved detected group" .. k, 10, false)
                                local leadDetectedUnit = detectedGroup:getUnit(1)
                                if leadDetectedUnit then
                                    trigger.action.outText("retrieved detected group lead unit" .. k, 10, false)
                                    local leadPoint = leadDetectedUnit:getPoint()
                                    if leadPoint then
                                        trigger.action.outText("retrieved detected group lead unit point" .. k, 10, false)
                                        local detectedDistance = Utils.PointDistance(checkingPoint, leadPoint)
                                        if detectedDistance <= cas.engagementDistance then
                                            trigger.action.outText("in range" .. k, 10, false)
                                            cas.initiateBattle(groupName, k)
                                            groups[groupName] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function cas.initiateBattle(initiatorGroupName, targetGroupName)
    trigger.action.outText("Initiating battle between " .. initiatorGroupName .. " and " .. targetGroupName, 9, false)
    local initGroup = Group.getByName(initiatorGroupName)
    if initGroup then
        local initController = initGroup:getController()
        if initController then
            local stopRoute = {
                id = 'StopRoute',
                params = {
                    value = true,
                }
            }
            initController:setCommand(stopRoute)
            initController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
            trigger.action.outText("stop route command set", 10, false)
        end
    end
    groupsInBattle[initiatorGroupName] = {targetGroupName = targetGroupName, battleStartTime = timer:getTime()}
    trigger.action.outText("added to table", 9, false)
end
function cas.battleLoop()
    trigger.action.outText("battle loop start", 9, false)
    for initiatorGroupName, targetGroups in pairs(groupsInBattle) do
        if targetGroups == nil or #targetGroups == 0 then
            groupsInBattle[initiatorGroupName] = nil
            local initGroup = Group.getByName(initiatorGroupName)
            if initGroup then
                local initController = initGroup:getController()
                if initController then
                    local stopRoute = {
                        id = 'StopRoute',
                        params = {
                            value = false,
                        }
                    }
                    initController:setCommand(stopRoute)
                    trigger.action.outText("start route command set", 10, false)
                    initController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                    timer.scheduleFunction(CAS.followGroup, "test", timer:getTime() + 30)
                end
            end
            return
        end
        trigger.action.outText("initiator: " .. initiatorGroupName, cas.battleLoopInterval, false)
        trigger.action.outText("targets: " .. Utils.dump(targetGroups), cas.battleLoopInterval, false)
        if #targetGroups > 0 then
            for i = 1, #targetGroups do
                trigger.action.outText(initiatorGroupName .. " is battling with " .. targetGroups[i].targetGroupName, 10, false)
                trigger.action.outText("Battle duration: " .. timer:getTime() - targetGroups[i].battleStartTime, cas.battleLoopInterval, false)
            end
        else
            trigger.action.outText("no target groups", 9, nil)
        end
    end
    timer.scheduleFunction(cas.battleLoop, nil, timer:getTime() + cas.battleLoopInterval)
end


cas.loop()
cas.battleLoop()
CAS.followGroup("test", CAS.JTACType.NONE)

--assert(loadfile("F:\\Games\\WWX\\Components\\CAS2.lua"))()