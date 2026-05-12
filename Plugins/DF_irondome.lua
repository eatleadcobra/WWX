local ironDome = {}
function ironDome:onEvent(event)
    if event then
        -- initiator is CAP group
        if event.initiator and event.initiator:getGroup() then
            local groupName = event.initiator:getGroup():getName()
            if DFS.status[1].capGroup and DFS.status[2].capGroup then -- as long as a cap group has spawed at least once this should be true, dosn't matter if group is dead or alive
                env.info("Cap groups found: " .. DFS.status[1].capGroup .. " and " .. DFS.status[2].capGroup, false)
                if groupName == DFS.status[1].capGroup or groupName == DFS.status[2].capGroup then
                    env.info("CAP group event: " .. event.id, false)
                    -- misile shot
                    if event.id == world.event.S_EVENT_SHOT then
                        env.info("CAP Missile shot event", false)
                        if event.weapon and event.weapon:getTarget() then
                            local target = event.weapon:getTarget()
                            env.info("CAP Missile target: " .. target:getName(), false)
                            if target:hasAttribute("Helicopters") then
                                env.info("CAP Missile target is a Helicopter", false)
                                -- blow up the missile
                                event.weapon:destroy()
                                ironDome.resetROE(groupName)
                            end
                        end
                    end
                    -- gunshot
                    if event.id == world.event.S_EVENT_SHOOTING_START then
                        env.info("CAP Gunshot event", false)
                        if event.target and event.target:hasAttribute("Helicopters") then
                            env.info("CAP Gunshot target is a Helicopter", false)
                            ironDome.resetROE(groupName)
                        end
                    end
                end
            end
        end
    end
end
function ironDome.resetROE(groupName)
    local group = Group.getByName(groupName)
    if group then
        local controller = group:getController()
        if controller then
            env.info("Resetting ROE for group: " .. groupName, false)
            controller:resetTask() -- Hopfully reset the ROE set in the ME? if not we will need MORE ZONES for a search and engage in zone task. (or we could just blow up the unit lmao)
        end
    end
end