local ironDome = {}
function ironDome:onEvent(event)
    if event then
        -- initiator is CAP group
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group then
                local groupName = group:getName()
                if groupName then
                    if DFS.status[1].capGroup and DFS.status[2].capGroup then -- as long as a cap group has spawed at least once this should be true, dosn't matter if group is dead or alive
                        env.info("Cap groups found: " .. DFS.status[1].capGroup .. " and " .. DFS.status[2].capGroup, false)
                        if groupName == DFS.status[1].capGroup or groupName == DFS.status[2].capGroup then
                            env.info("CAP group event: " .. event.id, false)
                            -- misile shot
                            if event.id == world.event.S_EVENT_SHOT then
                                env.info("CAP Missile shot event", false)
                                local okWeaponExists, weaponExists = pcall(function()
                                    return event.weapon:isExist()
                                end)
                                local okTarget, target = pcall(function()
                                    return event.weapon:getTarget()
                                end)

                                if event.weapon and okWeaponExists and weaponExists and okTarget and target then
                                    local okTargetName, targetName = pcall(function()
                                        return target:getName()
                                    end)
                                    local okHelicopter, isHelicopter = pcall(function()
                                        return target:hasAttribute("Helicopters")
                                    end)

                                    if okTargetName then
                                        env.info("CAP Missile target: " .. targetName, false)
                                    end

                                    if okHelicopter and isHelicopter then
                                        env.info("CAP Missile target is a Helicopter", false)
                                        -- blow up the missile
                                        if event.weapon and event.weapon.destroy then
                                            local okDestroy = pcall(function()
                                                event.weapon:destroy()
                                            end)
                                            if okDestroy then
                                                env.info("Destroying missile", false)
                                            end
                                        end
                                        ironDome.resetROE(groupName)
                                    end
                                end
                            end
                            -- gunshot
                            if event.id == world.event.S_EVENT_SHOOTING_START then
                                env.info("CAP Gunshot event", false)
                                local okTarget, isHelicopter = pcall(function()
                                    return event.target:hasAttribute("Helicopters")
                                end)

                                if event.target and okTarget and isHelicopter then
                                    env.info("CAP Gunshot target is a Helicopter", false)
                                    ironDome.resetROE(groupName)
                                end
                            end
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
            controller:setOption(0, 2) -- set ROE to Open Fire (Only Designated): AI will engage only targets specified in its taskings.
            controller:resetTask() -- Hopfully reset the ROE set in the ME? if not we will need MORE ZONES for a search and engage in zone task. (or we could just blow up the unit lmao)
        end
    end
end
world.addEventHandler(ironDome)