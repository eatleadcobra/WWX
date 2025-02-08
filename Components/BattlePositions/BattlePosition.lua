BattlePosition = {
    id = 0,
    ownedBy = 0,
    markupId = 0,
    point = {},
    radius = 0,
    strength = 0,
}
function BattlePosition.new(point, radius)
    local newBP = Utils.deepcopy(BattlePosition)
    newBP.id = Utils.uuid()
    newBP.point = point
    newBP.radius = radius
    return newBP
end
function BattlePosition.setOwner(self, coalitionId)
    self.ownedBy = coalitionId
end
function BattlePosition.setStrength(self, strength)
    self.strength = strength
end