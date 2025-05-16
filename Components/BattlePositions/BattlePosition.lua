BattlePosition = {
    id = 0,
    ownedBy = 0,
    markupId = 0,
    point = {},
    radius = 0,
    strength = 0,
    zoneName = "",
}
function BattlePosition.new(id, point, radius, zoneName)
    local newBP = Utils.deepcopy(BattlePosition)
    newBP.id = id
    newBP.point = point
    newBP.radius = radius
    newBP.zoneName = zoneName
    return newBP
end
function BattlePosition.setOwner(self, coalitionId)
    self.ownedBy = coalitionId
end
function BattlePosition.setStrength(self, strength)
    self.strength = strength
end