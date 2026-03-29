Troopmarks = {}
local tdEvents = {}
function tdEvents:onEvent(event)
    --on mark change
    if (event.id == world.event.S_EVENT_MARK_CHANGE) then
        trigger.action.outText("mark change", 10, false)
        local playerName = nil
        if event.idx then
            if event.initiator ~= nil then
                playerName = event.initiator:getPlayerName()
            end
            if playerName and event.pos then
                if (string.upper(event.text) == 'SOF') then
                    Troopmarks[playerName] = event.pos
                end
            end
        end
    end
    -- on mark remove
    if (event.id == world.event.S_EVENT_MARK_REMOVED) then
        if event.idx then
            local playerName = nil
            if event.initiator ~= nil then
                playerName = event.initiator:getPlayerName()
            end
            if playerName then
                Troopmarks[playerName] = nil
            end
        end
    end
end
world.addEventHandler(tdEvents)