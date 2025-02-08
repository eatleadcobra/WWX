--check BPs for ownership
local positionsCountLimit = 20
local bc = {}
local bcmarkups = {
    lines = {
        [0] = {0,0,0,1},
        [1] = {1,0,0,1},
        [2] = {0,0,1,1}
    },
    fills = {
        [0] = {0,0,0,0.2},
        [1] = {1,0,0,0.2},
        [2] = {0,0,1,0.2}
    }
}
local battlePositions = {}
local bpIds = {}

function bc.getPositions()
    for i = 1, positionsCountLimit do
        local bpZone = trigger.misc.getZone("BP-"..i)
        if bpZone then
            local newBP = BattlePosition.new(bpZone.point, bpZone.radius)
            battlePositions[newBP.id] = newBP
            table.insert(bpIds, newBP.id)
        end
    end
end
--set markups
function bc.setBPMarkups()
    for k,v in pairs(battlePositions) do
        if v.markupId ~= 0 then
            trigger.action.removeMark(v.markupId)
        end
        local newMarkId = DrawingTools.newMarkId()
        trigger.action.circleToAll(-1, newMarkId, v.point, v.radius, bcmarkups.lines[v.ownedBy], bcmarkups.fills[v.ownedBy], 1, true, "")
        v.markupId = newMarkId
    end
end

bc.getPositions()
bc.setBPMarkups()
battlePositions[bpIds[1]]:setOwner(1)
bc.setBPMarkups()
--for each coalition, find the best target (balance of distance and defensive strength)
--determine strongest available company (already made or can be made)
--  -- if all available companies are weaker than what can be made now, bolster most strategic BP
-- assign companies to BPs