local flightplanner = {}
local flightplanmarks = {}
local fpEvents = {}
function fpEvents:onEvent(event)
    --on mark change
    if (event.id == world.event.S_EVENT_MARK_CHANGE) then
        local playerName = nil
        local playerCoalition = nil
        
        local firstChr = string.sub(event.text,1,1)
        local secondChr = string.sub(event.text,2,2)
        local firstMatch = false
        local secondMatch = false
        if string.find(firstChr, "[Ff]") then
            firstMatch = true
        end
        if string.find(secondChr, "[Pp]") then
            secondMatch = true
        end
        if firstMatch and secondMatch then
            local legNum = tonumber(string.sub(event.text,3,3))
            if legNum then
                local speed = tonumber(string.sub(event.text,4,#event.text-1))
                local units = string.sub(event.text,#event.text,#event.text)
                local unitsString = "knots"
                if units and not tonumber(units) then
                    if units == "M" or units == "m" then
                        unitsString = "kph"
                    end
                    trigger.action.outText("Found flight plan entry " .. legNum .. " for a speed of " .. speed .. " " .. unitsString, 10, false)
                    if not flightplanmarks["test"] then flightplanmarks["test"] = {} end
                    flightplanmarks["test"][legNum] = { point = event.pos, speed = speed, units = units, markups = {circle = 0, text = 0, line = 0}, id = event.idx, legNum = legNum}
                    flightplanner.updatePlayerFlightPlan("test")
                end
            end
        end
        
        if event.idx then
            if event.initiator ~= nil then
                playerName = event.initiator:getPlayerName()
                playerCoalition = event.initiator:getCoalition()
            end
            if playerName and playerCoalition and event.pos then
                -- local firstChr = string.sub(event.text,1,1)
                -- local secondChr = string.sub(event.text,2,2)
                -- local firstMatch = false
                -- local secondMatch = false
                -- if string.find(firstChr, "F") then
                --     firstMatch = true
                -- end
                -- if string.find(secondChr, "P") then
                --     secondMatch = true
                -- end
                -- if firstMatch and secondMatch then
                --     local legNum = tonumber(string.sub(event.text,3,3))
                --     if legNum then
                --         local speed = tonumber(string.sub(event.text,4,#event.text))
                --         trigger.action.outText("Found flight plan entry " .. legNum .. " for a speed of " .. speed, 10, false)
                --     end
                -- end
            end
        end
    end
    -- on mark remove
    if (event.id == world.event.S_EVENT_MARK_REMOVED) then
        if event.idx then
            local playerName = nil
            local playerCoalition = nil
            if event.initiator ~= nil then
                playerName = event.initiator:getPlayerName()
                playerCoalition = event.initiator:getCoalition()
            end
            local fpNum = tonumber(string.sub(event.text,3,3))
            if fpNum and flightplanmarks["test"] and flightplanmarks["test"][fpNum] then
                flightplanner.erasePlayerFlightPlan("test")
                flightplanmarks["test"][fpNum] = nil
            end
        end
    end
end

function flightplanner.updatePlayerFlightPlan(playerName)
    local playerFlightPlan = flightplanmarks[playerName]
    if playerFlightPlan then
        local fpLength = #playerFlightPlan
        local validPlan = true
        local counter = 0
        for k,v in pairs(flightplanmarks[playerName]) do
            counter = counter + 1
        end
        if fpLength < counter then
            validPlan = false
        end
        if validPlan then
            flightplanner.drawFlightPlan(playerFlightPlan)
        end
    end
end

function flightplanner.erasePlayerFlightPlan(playerName)
    local playerFlightPlan = flightplanmarks[playerName]
    if playerFlightPlan then
        flightplanner.eraseFlightPlan(playerFlightPlan)
    end
end

function flightplanner.drawFlightPlan(playerFlightPlan)
    for i = 1, #playerFlightPlan do
        if playerFlightPlan[i] then
            local circleId = DrawingTools.newMarkId()
            playerFlightPlan[i].markups.circle = circleId
            trigger.action.circleToAll(2, circleId, playerFlightPlan[i].point, 200, {0,0,0,1}, {0,0,0,0}, 1, true, nil)
            if i < #playerFlightPlan and playerFlightPlan[i+1] then
                local lineId = DrawingTools.newMarkId()
                playerFlightPlan[i].markups.line = lineId
                trigger.action.lineToAll(2, lineId, playerFlightPlan[i].point, playerFlightPlan[i+1].point, {0,0,0,1}, 1, true, nil)
            end
        end
    end
end

function flightplanner.eraseFlightPlan(playerFlightPlan)
    trigger.action.outText("Erasing flight plan: " .. Utils.dump(playerFlightPlan), 10, false)
    local counter = 0
    for legNum, leg in pairs(playerFlightPlan) do
        trigger.action.removeMark(leg.markups.line)
        trigger.action.removeMark(leg.markups.circle)
        counter = counter + 1
    end
    trigger.action.outText("Removed " .. counter .. " legs", 10, false)
end
world.addEventHandler(fpEvents)
trigger.action.outText("Loaded flight planner", 10, false)