local dsm = {}
local airbaseList = world.getAirbases()
function dsm.loop()
    for i = 1, #airbaseList do
        local airframeslist = airbaseList[i]:getWarehouse():getInventory().aircraft
        local airbaseCoalition = airbaseList[i]:getCoalition()
        local airbaseName = airbaseList[i]:getName()

        --removing planes that should not be present
        for k,v in pairs(airframeslist) do
            if Airframes[airbaseCoalition].main[k] == nil then
                env.info(k .. " should not be present at " .. airbaseName .. "!", false)
                airbaseList[i]:getWarehouse():removeItem(k, v)
            end
            if ForwardAirbases[airbaseCoalition][airbaseName] then
                if Airframes[airbaseCoalition].forward[k] == nil then
                    env.info(k .. " should not be present at forward airbase " .. airbaseName,false)
                    airbaseList[i]:getWarehouse():removeItem(k, v)
                end
            end
        end
        -- adding planes that should be present
        for c = 1, 2 do
            if airbaseCoalition == c then
                if ForwardAirbases[airbaseCoalition][airbaseName] == nil then
                    for name, number in pairs(Airframes[c].main) do
                        if airframeslist[name] == 0 or airframeslist[name] == nil then
                            env.info(name .. " should be present at " .. airbaseName, false)
                            airbaseList[i]:getWarehouse():setItem(name, 100000)
                        end
                    end
                else
                    for name, number in pairs(Airframes[c].forward) do
                        if airframeslist[name] == 0 or airframeslist[name] == nil then
                            env.info(name .. " should be present at " .. airbaseName, false)
                            airbaseList[i]:getWarehouse():setItem(name, 100000)
                        end
                    end
                end
            end
        end
    end
    timer.scheduleFunction(dsm.loop, nil, timer:getTime() + 10)
end
dsm.loop()