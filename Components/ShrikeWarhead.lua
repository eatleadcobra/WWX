local shrikeEvents = {}
function shrikeEvents:onEvent(event)
    --on hit
    if event and event.id == world.event.S_EVENT_HIT and event.weapon and event.target then
        local okExists, exists = pcall(function()
            return event.weapon:isExist()
        end)
        local okType, weaponType = pcall(function()
            return event.weapon:getTypeName()
        end)

        if okExists and exists and okType and string.find(weaponType, 'AGM_45A') then
            if event.target:getCategory() == 2 then
                if event.target and event.target.enableEmission then event.target:enableEmission(false) end
            end
        end
    end
end
world.addEventHandler(shrikeEvents)