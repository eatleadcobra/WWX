local dsm = {}
local airbaseList = world.getAirbases()


local dsmEvents = {}
function dsmEvents:onEvent(event)
    if event.id == world.event.S_EVENT_BASE_CAPTURED then
        dsm.loop()
    end
end
world.addEventHandler(dsmEvents)

function dsm.loop()
    for i = 1, #airbaseList do
        local airbase = airbaseList[i]
        if airbase then
            local airframeslist = airbase:getWarehouse():getInventory().aircraft
            local airbaseCoalition = airbase:getCoalition()
            local airbaseName = airbase:getName()
            local airbaseCategory = airbase:getDesc().category
            --removing planes that should not be present
            if airbaseCoalition == 1 or airbaseCoalition == 2 then
                if IgnoreAirbases[airbaseName] == nil then
                    env.info("Managing airfield: " .. airbaseName, false)
                    env.info("Airfield category: " .. tostring(airbaseCategory), false)
                    for k,v in pairs(airframeslist) do
                        if v > 0 then
                            if airbaseCategory == 0 and Airframes[airbaseCoalition].main[k] == nil then
                                env.info("This coalition airbase should not have airframe: " .. k, false)
                                airbaseList[i]:getWarehouse():setItem(k, 0)
                            elseif airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] then
                                if Airframes[airbaseCoalition].forward[k] == nil then
                                    env.info("Forward airbase should not have airframe: " .. k, false)
                                    airbaseList[i]:getWarehouse():setItem(k, 0)
                                end
                            elseif airbaseCategory == 1 and Airframes[airbaseCoalition].farp[k] == nil then
                                env.info("FARP should not have airframe: " .. k, false)
                                airbaseList[i]:getWarehouse():setItem(k, 0)
                            end
                        end
                    end
                    -- adding planes that should be present
                    for c = 1, 2 do
                        if airbaseCoalition == c then
                            if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] == nil then
                                for name, number in pairs(Airframes[c].main) do
                                    env.info("Main airbase should have airframe: " .. name, false)
                                    airbaseList[i]:getWarehouse():setItem(name, 200)
                                end
                            elseif airbaseCategory == 0 then
                                for name, number in pairs(Airframes[c].forward) do
                                    env.info("Forward airbase should have airframe: " .. name, false)
                                    airbaseList[i]:getWarehouse():setItem(name, 200)
                                end
                            elseif airbaseCategory == 1 then
                                for name, number in pairs(Airframes[c].farp) do
                                    env.info("FARP should have airframe: " .. name, false)
                                    airbaseList[i]:getWarehouse():setItem(name, 200)
                                end
                            end
                        end
                    end
                else
                    env.info("Ignoring airfield: " .. airbaseName, false)
                end
            end
        end
        --timer.scheduleFunction(dsm.loop, nil, timer:getTime() + 1800)
    end
end
dsm.loop()