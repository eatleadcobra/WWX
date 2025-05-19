-- function to follow a group
-- if group detects a target:
    -- hold position
    -- set the target invisible
    -- start shooting at a point around the target
    -- based on available units, destroy enemy units periodically
        -- eg, don't destroy tanks without anti tank weapons present in your group, etc. more firepower = more kills per "turn"
    -- integrate with CAS system so troops in combat can direct friendly aircraft onto enemies
    -- after time is up or target(s) are dead, continue movement and become visible
BattleSim = {}
local tbs = {}
local groups = {

}
local groupsInBattle = {

}
tbs.loopInterval = 4
tbs.battleLoopInterval = 9
tbs.engagementDistance = 3000
function BattleSim.followGroup(groupName)
    trigger.action.outText("following group: " .. groupName, 10, false)
    groups[groupName] = true
end
function tbs.loop()
    for groupName, present in pairs(groups) do
        if groupsInBattle[groupName] == nil then
            trigger.action.outText("looping group: " .. groupName, tbs.loopInterval, false)
            local group = Group.getByName(groupName)
            if group then
                tbs.checkGroup(groupName)
            else
                groups[groupName] = nil
            end
        end
    end
    timer.scheduleFunction(tbs.loop, nil, timer:getTime() + tbs.loopInterval)
end
function tbs.checkGroup(groupName)
    trigger.action.outText("checking group: " .. groupName, tbs.loopInterval, false)
    local checkingGroup = Group.getByName(groupName)
    if checkingGroup then
        trigger.action.outText("group found", tbs.loopInterval, false)
        local checkingUnit = checkingGroup:getUnit(1)
        if checkingUnit then
            local checkingPoint = checkingUnit:getPoint()
            if checkingPoint then
                local cgController = checkingGroup:getController()
                if cgController then
                    trigger.action.outText("controller found", tbs.loopInterval, false)
                    local detectedEnemies = cgController:getDetectedTargets(Controller.Detection.VISUAL,Controller.Detection.OPTIC)
                    local detectedGroups = {}
                    if #detectedEnemies > 0 then
                        trigger.action.outText("enemies detected", tbs.loopInterval, false)
                        for i = 1, #detectedEnemies do
                            trigger.action.outText("detected enemy type: " .. detectedEnemies[i].object:getDesc().category, tbs.loopInterval, false)
                            if detectedEnemies[i].object:getDesc().category == 2 then
                                trigger.action.outText("ground unit detected", tbs.loopInterval, false)
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
                                        if detectedDistance <= tbs.engagementDistance then
                                            trigger.action.outText("in range" .. k, 10, false)
                                            tbs.initiateBattle(groupName, k)
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

function tbs.initiateBattle(initiatorGroupName, targetGroupName)
    trigger.action.outText("Initiating battle between " .. initiatorGroupName .. " and " .. targetGroupName, 60, false)
    groupsInBattle[initiatorGroupName] = {}
    table.insert(groupsInBattle[initiatorGroupName], {targetGroupName = targetGroupName, battleStartTime = timer:getTime()})
end
function tbs.battleLoop()
    for initiatorGroupName, targetGroups in pairs(groupsInBattle) do
        if targetGroups == nil or #targetGroups == 0 then
            groupsInBattle[initiatorGroupName] = nil
            return
        end
        trigger.action.outText("initiator: " .. initiatorGroupName, tbs.battleLoopInterval, false)
        trigger.action.outText("targets: " .. Utils.dump(targetGroups), tbs.battleLoopInterval, false)
        if #targetGroups > 0 then
            for i = 1, #targetGroups do
                trigger.action.outText(initiatorGroupName .. " is battling with " .. targetGroups[i].targetGroupName, 10, false)
                trigger.action.outText("Battle duration: " .. timer:getTime() - targetGroups[i].battleStartTime, tbs.battleLoopInterval, false)
            end
        end
    end
    timer.scheduleFunction(tbs.battleLoop, nil, timer:getTime() + tbs.battleLoopInterval)
end


tbs.loop()
tbs.battleLoop()
BattleSim.followGroup("test")


--assert(loadfile("F:\\Games\\WWX\\Components\\BattleSim\\BattleSim.lua"))()