Mine = {}
local mineTemplate = {
	["heading"] = 0,
	["shape_name"] = "landmine",
	["type"] = "Landmine",
	["name"] = "",
	["category"] = "Fortifications",
	["y"] = 0,
	["x"] = 0,
}
local mineCount = 5
local clusterBombs = {
    ["BLU-3_GROUP"] = 1,
    ["BLU-3B_GROUP"] = 1,
    ["BLU-4B_GROUP"] = 1,
    ["CBU_52B"] = 1,
    ["ROCKEYE"] = 1,
    ["CBU_87"] = 1,
}
local mine = {}
local nextGroupId = 1000
function mine.copyTemplate(templateTable)
    local newTable = {}
    for k,v in pairs(templateTable) do
        if type(v) == "table" then
            newTable[k] = mine.copyTemplate(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end
function mine.newGroupId()
    local newId = nextGroupId
    nextGroupId = nextGroupId+1
    return newId
end
function Mine.spawnPublic(impactPoint, position)
    mine.spawn({impactPoint = impactPoint, position = position})
end
--impactPoint, position
function mine.spawn(param)
    local id = mine.newGroupId()
    local countryId = 22
    local ninetydegRad = 1.571
    local seventytwodegRad = 1.25664
    --minecount+1 for star, minecount for line
    for i = 1, mineCount+1 do
        local minePoint = param.impactPoint
        --minePoint = Utils.VectorAdd(minePoint, Utils.ScalarMult(Utils.RotateVector(param.position.x, ninetydegRad), -6 + (3*(i-1))))
        if i > 1 then
            minePoint = Utils.VectorAdd(minePoint, Utils.ScalarMult(Utils.RotateVector(param.position.x, (seventytwodegRad*(i-1))+1), 6))
        end
        local staticTemplate = mine.copyTemplate(mineTemplate)
        staticTemplate["name"] = country.name[countryId]..id.."-"..i
        staticTemplate["y"] = minePoint.z
        staticTemplate["x"] = minePoint.x
        coalition.addStaticObject(countryId, staticTemplate)
    end
end
local mineEvents = {}
function mineEvents:onEvent(event)
     if event and event.id then
        --on weapon fire
        if (event.id == world.event.S_EVENT_SHOT and event.initiator and event.weapon) then
            if string.find(event.weapon:getTypeName(), 'BDU') or string.find(event.weapon:getTypeName(), 'FAB_50') or string.find(event.weapon:getTypeName(), 'AN_M30A1') or event.weapon:getTypeName() == 'FAB_100' then
                env.info("tracking mine: " .. event.weapon:getTypeName(), false)
                mine.trackBomb(event.weapon)
            end
        end
    end
end
function mine.trackBomb(weapon)
    if weapon:isExist() then
        local vec = weapon:getVelocity()
        if vec ~= nil then
            local weaponPos = weapon:getPosition()
            if weaponPos ~= nil then
                local weaponSpeed = (vec.x^2 + vec.y^2 + vec.z^2)^0.5
                local impactPoint = land.getIP(weaponPos.p, weaponPos.x, weaponSpeed * 0.3)
                if impactPoint then
                    local isLand = land.getSurfaceType({x = impactPoint.x, y = impactPoint.z})
                    if isLand ~= 2 and isLand ~= 3 then
                        if weapon.getPosition then
                            local position = weapon:getPosition()
                            if position then
                                weapon:destroy()
                                timer.scheduleFunction(mine.spawn, {impactPoint = impactPoint, position = position}, timer:getTime() + 2)
                            end
                        end
                    end
                else
                    timer.scheduleFunction(mine.trackBomb, weapon, timer:getTime() + 0.1)
                end
            end
        end
    end
end
world.addEventHandler(mineEvents)
