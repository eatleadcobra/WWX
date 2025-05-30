local shrikeEvents = {}
function shrikeEvents:onEvent(event)
    --on hit
    if event and event.id == world.event.S_EVENT_HIT and event.weapon and event.target then
        if string.find(event.weapon:getTypeName(), 'AGM_45A') then
            if event.target:getCategory() == 2 then
                if event.target and event.target.enableEmission then event.target:enableEmission(false) end
            end
        end
    end
end
world.addEventHandler(shrikeEvents)