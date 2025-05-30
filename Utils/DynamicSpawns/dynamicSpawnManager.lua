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
            if airbaseCoalition == 1 or airbaseCoalition == 2 then
                if IgnoreAirbases[airbaseName] == nil then
                    for k,v in pairs(airframeslist) do
                        if v > 0 then
                            if airbaseCategory == 0 and Airframes[airbaseCoalition].main[k] == nil then
                                airbaseList[i]:getWarehouse():removeItem(k, v)
                            end
                            if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] then
                                if Airframes[airbaseCoalition].forward[k] == nil then
                                    airbaseList[i]:getWarehouse():removeItem(k, v)
                                end
                            end
                            if airbaseCategory == 2 and Airframes[airbaseCoalition].farp[k] == nil then
                                airbaseList[i]:getWarehouse():removeItem(k, v)
                            end
                        end
                    end
                    -- adding planes that should be present
                    for c = 1, 2 do
                        if airbaseCoalition == c then
                            if airbaseCategory == 0 and ForwardAirbases[airbaseCoalition][airbaseName] == nil then
                                for name, number in pairs(Airframes[c].main) do
                                    if airframeslist[name] == 0 or airframeslist[name] == nil then
                                        airbaseList[i]:getWarehouse():setItem(name, 200)
                                    end
                                end
                            elseif airbase == 0 then
                                for name, number in pairs(Airframes[c].forward) do
                                    if airframeslist[name] == 0 or airframeslist[name] == nil then
                                        airbaseList[i]:getWarehouse():setItem(name, 200)
                                    end
                                end
                            elseif airbaseCategory == 1 then
                                for name, number in pairs(Airframes[c].farp) do
                                    if airframeslist[name] == 0 or airframeslist[name] == nil then
                                        airbaseList[i]:getWarehouse():setItem(name, 200)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        --timer.scheduleFunction(dsm.loop, nil, timer:getTime() + 1800)
    end
end
dsm.loop()