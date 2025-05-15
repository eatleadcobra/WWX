--check BPs for ownership
BattleControl = {}
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
local reconnedBPs = {
    [1] = {},
    [2] = {},
}
function BattleControl.reconBP(coalitionId, bpID)
    reconnedBPs[coalitionId][bpID] = true
end

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
function bc.bpRecon()
    for c = 1, 2 do
        for k,v in pairs(battlePositions) do
            local enemyCoalition = 2
            if c == 2 then enemyCoalition = 1 end
            if v.ownedBy == enemyCoalition then
                Recon.createBPScoutingMission(c, v.point, v.id)
            end
        end
    end
    timer.scheduleFunction(bc.bpRecon, nil, timer:getTime() + 3600)
end




bc.getPositions()
bc.setBPMarkups()
for k,v in pairs(battlePositions) do
    v:setOwner(math.random(1,2))
end
bc.setBPMarkups()
bc.bpRecon()
--for each coalition, find the best target (balance of distance and defensive strength)
--determine strongest available company (already made or can be made)
--  -- if all available companies are weaker than what can be made now, bolster most strategic BP
-- assign companies to BPs