local cm = {}
cm.status = {
    [0] = "Inactive",
    [1] = "Moving",
    [2] = "Defending",
    [3] = "Under Attack",
    [4] = "Defeated"
}
Company = {
    id = 0,
    coalitionId = 0,
    status = nil,
    statusChangedTime = 0,
    point = {},
    platoons = {},
    waypoints = {},
    groupName = "",
    deployedGroupName = "",
    arrived = false
}
function Company:new(coalitionId, platoons)
    local newCpy = Company:deepcopy()
    newCpy.id = Utils.uuid()
    newCpy.coalitionId = coalitionId
    for i = 1, #platoons do
        table.insert(self.platoons, Company.deepcopy(Platoons[PlatoonTypes[platoons[i]]]) )
    end
    return newCpy
end
function Company.setWaypoints(self, waypoints)
    self.waypoints = waypoints
end
function Company.spawn(self, deployed)
    local vector = Utils.VecNormalize({x = self.waypoints[1].x - self.waypoints[2].x, y = self.waypoints[1].y - self.waypoints[2].y, z = self.waypoints[1].z - self.waypoints[2].z})
    local formPoint = Utils.VectorAdd(self.waypoints[2], Utils.ScalarMult(vector, 200))
    --create waypoint table from waypoints list
    local points = {[1] = self.waypoints[1], [2] = formPoint, [3] = self.waypoints[2]}
    local groupWaypoints = SpawnFuncs.createWPListFromPoints(points)
    --create group table using waypoints and platoons
    local unitsList = Company:convertPlatoonsToUnitList(deployed)
    local cpyGroupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(Company.coalitionId, 2, unitsList, groupWaypoints)
    cpyGroupTable["route"]["points"][#cpyGroupTable["route"]["points"]].action = "Rank"
    self.groupName = cpyGroupTable["name"]
    --spawn group
    coalition.addGroup(80+(2-self.coalitionId), 2, cpyGroupTable)
end
function Company.convertPlatoonsToUnitList(self, deployed)
    local unitList = {}
    for i = 1, #self.platoons do
        for j = 1, #self.platoons[i] do
            local unitType = self.platoons[i][j]
            if unitType then
                if unitType == "IFV" or unitType == "APC" then
                    if deployed then
                        table.insert(unitList, unitType)
                        table.insert(unitList, "Inf")
                        table.insert(unitList, "MG")
                        table.insert(unitList, "RPG")
                        table.insert(unitList, "Inf")
                    else
                        table.insert(unitList, unitType)
                    end
                else
                    table.insert(unitList, unitType)
                end
            end
        end
    end
    return unitList
end
function Company.deploy(self)
    self:despawn()
    self:spawn(true)
end
function Company.undeploy(self)
    self:despawn()
    self:spawn(false)
end
function Company.despawn(self)
    local cpyGroup = Group.getByName(self.groupName)
    if cpyGroup then
        local cpyLead = cpyGroup:getUnit(1)
        if cpyLead then
            local cpyPoint = cpyLead:getPoint()
            if cpyPoint then
                self.point = cpyPoint
                self.waypoints[1] = cpyPoint
            end
        end
        cpyGroup:destroy()
        self.status = 0
    end
end
function Company.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Company.deepcopy(orig_key)] = Company.deepcopy(orig_value)
        end
        setmetatable(copy, Company.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end