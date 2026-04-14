Troopmarks = {}
Recontroopmarks = {}
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
                    Troopmarks[playerName] = {point = event.pos, id = event.idx}
                    trigger.action.outTextForCoalition(playerCoalition, "SOF marker added for " .. playerName, 5, false)
                elseif (string.upper(event.text) == 'RECON') then
                    Recontroopmarks[playerName] = {point = event.pos, id = event.idx}
                    trigger.action.outTextForCoalition(playerCoalition, "RECON marker added for " .. playerName, 5, false)
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
            if playerName and playerCoalition and Troopmarks[playerName] and Troopmarks[playerName].id == event.idx then
                Troopmarks[playerName] = nil
                trigger.action.outTextForCoalition(playerCoalition, "SOF marker removed for " .. playerName, 5, false)
            elseif playerName and playerCoalition and Recontroopmarks[playerName] and Recontroopmarks[playerName].id == event.idx then
                Recontroopmarks[playerName] = nil
                trigger.action.outTextForCoalition(playerCoalition, "RECON marker removed for " .. playerName, 5, false)
            end
        end
    end
end
world.addEventHandler(tdEvents)