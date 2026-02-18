local dsm = {}

local dsmEvents = {}
function dsmEvents:onEvent(event)
    if event.id == world.event.S_EVENT_BASE_CAPTURED then
        dsm.loop()
    end
end
world.addEventHandler(dsmEvents)

function dsm.loop()
    local airbaseList = world.getAirbases()
    for i = 1, #airbaseList do
        local airbase = airbaseList[i]
        if airbase and airbase:isExist() then
            local airframeslist = airbase:getWarehouse():getInventory().aircraft
            local airbaseCoalition = airbase:getCoalition()
            local airbaseName = airbase:getName()
            local airbaseCategory = airbase:getDesc().category
            --removing planes that should not be present
            if airbaseCoalition == 1 or airbaseCoalition == 2 then
                if IgnoreAirbases[airbaseName] == nil then
                    env.info("Managing airfield: " .. airbaseName, false)
                    env.info("Airfield category: " .. tostring(airbaseCategory), false)
                    if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] == nil and FARPAirfields[airbaseCoalition][airbaseName] == nil then
                        env.info("Main Airbase", false)
                    end
                    if ForwardAirbases[airbaseCoalition][airbaseName] then
                        env.info("Forward Airbase", false)
                    end
                    if (airbaseCategory == 1 or (airbaseCategory == 2 and not Carriers[airbaseCoalition][airbaseName])) or (airbaseCategory == 0 and FARPAirfields[airbaseCoalition][airbaseName]) then
                        env.info("FARP", false)
                    end
                    if (airbaseCategory == 2 and Carriers[airbaseCoalition][airbaseName]) then
                        env.info("Carrier", false)
                    end
                    for k,v in pairs(airframeslist) do
                        if v > 0 then
                            env.info("Blanking airframe count for " ..  k, false)
                            airbaseList[i]:getWarehouse():setItem(k, 0)
                        end
                    end
                    -- adding planes that should be present
                    for c = 1, 2 do
                        if airbaseCoalition == c then
                            if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] == nil and FARPAirfields[airbaseCoalition][airbaseName] == nil then
                                for name, number in pairs(Airframes[c].main) do
                                    env.info("Main airbase should have airframe: " .. name, false)
                                    airbaseList[i]:getWarehouse():setItem(name, 200)
                                end
                            elseif airbaseCategory == 0 and FARPAirfields[airbaseCoalition][airbaseName] == nil then
                                for name, number in pairs(Airframes[c].forward) do
                                    env.info("Forward airbase should have airframe: " .. name, false)
                                    airbaseList[i]:getWarehouse():setItem(name, 200)
                                end
                            elseif (airbaseCategory == 1 or (airbaseCategory == 2 and not Carriers[airbaseCoalition][airbaseName])) or (airbaseCategory == 0 and FARPAirfields[airbaseCoalition][airbaseName]) then
                                for name, number in pairs(Airframes[c].farp) do
                                    env.info("FARP should have airframe: " .. name, false)
                                    airbaseList[i]:getWarehouse():setItem(name, 200)
                                end
                            elseif (airbaseCategory == 2 and Carriers[airbaseCoalition][airbaseName]) then
                                for name, number in pairs(Airframes[c].carrier) do
                                    env.info("Carrier should have airframe: " .. name, false)
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