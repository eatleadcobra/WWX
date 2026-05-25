local shrikeEvents = {}
function shrikeEvents:onEvent(event)
    --on hit
    if event and event.id == world.event.S_EVENT_HIT and event.weapon and event.target then
        local okExists, exists = pcall(event.weapon.isExist, event.weapon)
        local okType, weaponType = pcall(event.weapon.getTypeName, event.weapon)

        if okExists and exists and okType and string.find(weaponType, 'AGM_45A') then
            if event.target:getCategory() == 2 then
                if event.target and event.target.enableEmission then event.target:enableEmission(false) end
            end
        elseif not okExists or not okType then Utils.logWeaponFailure(event.weapon) end
    end
end
world.addEventHandler(shrikeEvents)