Troopmarks = {}
local tdEvents = {}
function tdEvents:onEvent(event)
    --on mark change
    if (event.id == world.event.S_EVENT_MARK_CHANGE) then
        local playerName = nil
        local playerCoalition = nil
        if event.idx then
            if event.initiator ~= nil then
                playerName = event.initiator:getPlayerName()
                playerCoalition = event.initiator:getCoalition()
            end
            if playerName and playerCoalition and event.pos then
                if (string.upper(event.text) == 'SOF') then
                    Troopmarks[playerName] = event.pos
                    trigger.action.outTextForCoalition(playerCoalition, "SOF marker added for " .. playerName, 5, false)
                end
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
            if playerName and playerCoalition then
                Troopmarks[playerName] = nil
                trigger.action.outTextForCoalition(playerCoalition, "SOF marker removed for " .. playerName, 5, false)
            end
        end
    end
end
world.addEventHandler(tdEvents)