local dsm = {}
local airbaseList = world.getAirbases()

function dsm.loop()
    for i = 1, #airbaseList do
        local airbase = airbaseList[i]
        if airbase then
            local airframeslist = airbase:getWarehouse():getInventory().aircraft
            local airbaseCoalition = airbase:getCoalition()
            local airbaseName = airbase:getName()
            local airbaseCategory = airbase:getDesc().category
            --removing planes that should not be present
            for k,v in pairs(airframeslist) do
                if airbaseCategory == 0 and Airframes[airbaseCoalition].main[k] == nil then
                    env.info(k .. " should not be present at " .. airbaseName .. "!", false)
                    airbaseList[i]:getWarehouse():removeItem(k, v)
                end
                if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] then
                    if Airframes[airbaseCoalition].forward[k] == nil then
                        env.info(k .. " should not be present at forward airbase " .. airbaseName,false)
                        airbaseList[i]:getWarehouse():removeItem(k, v)
                    end
                end
                if airbaseCategory == 1 and Airframes[airbaseCoalition].farp[k] == nil then
                    env.info(k .. " should not be present at " .. airbaseName .. "!", false)
                    airbaseList[i]:getWarehouse():removeItem(k, v)
                end
            end
            -- adding planes that should be present
            for c = 1, 2 do
                if airbaseCoalition == c then
                    if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] == nil then
                        for name, number in pairs(Airframes[c].main) do
                            if airframeslist[name] == 0 or airframeslist[name] == nil then
                                env.info(name .. " should be present at " .. airbaseName, false)
                                airbaseList[i]:getWarehouse():setItem(name, 100)
                            end
                        end
                    elseif airbase == 0 then
                        for name, number in pairs(Airframes[c].forward) do
                            if airframeslist[name] == 0 or airframeslist[name] == nil then
                                env.info(name .. " should be present at " .. airbaseName, false)
                                airbaseList[i]:getWarehouse():setItem(name, 100)
                            end
                        end
                    elseif airbaseCategory == 1 then
                        for name, number in pairs(Airframes[c].farp) do
                            if airframeslist[name] == 0 or airframeslist[name] == nil then
                                env.info(name .. " should be present at " .. airbaseName, false)
                                airbaseList[i]:getWarehouse():setItem(name, 100)
                            end
                        end
                    end
                end
            end
        end
        timer.scheduleFunction(dsm.loop, nil, timer:getTime() + 120)
    end
end
dsm.loop()