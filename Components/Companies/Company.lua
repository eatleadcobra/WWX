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
    units = {},
    waypoints = {},
    groupName = "",
    deployedGroupNames = {},
    arrived = false
}
function Company.new(coalitionId, platoons)
    local newCpy = Company:deepcopy()
    newCpy.id = Utils.uuid()
    newCpy.coalitionId = coalitionId
    for i = 1, #platoons do
        local pltUnits = Company.deepcopy(Platoons[PlatoonTypes[platoons[i]]])
        for j = 1, #pltUnits do
            table.insert(newCpy.units, pltUnits[j])
        end
    end
    return newCpy
end
function Company.setWaypoints(self, waypoints)
    self.waypoints = waypoints
end
function Company.spawn(self)
    local vector = Utils.VecNormalize({x = self.waypoints[1].x - self.waypoints[2].x, y = self.waypoints[1].y - self.waypoints[2].y, z = self.waypoints[1].z - self.waypoints[2].z})
    local formPoint = Utils.VectorAdd(self.waypoints[2], Utils.ScalarMult(vector, 200))
    --create waypoint table from waypoints list
    local points = {[1] = self.waypoints[1], [2] = formPoint, [3] = self.waypoints[2]}
    local groupWaypoints = SpawnFuncs.createWPListFromPoints(points)
    --create group table using waypoints and platoons
    local cpyGroupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(Company.coalitionId, 2, self.units, groupWaypoints)
    cpyGroupTable["route"]["points"][#cpyGroupTable["route"]["points"]].action = "Rank"
    self.groupName = cpyGroupTable["name"]
    --spawn group
    coalition.addGroup(80+(2-self.coalitionId), 2, cpyGroupTable)
end

function Company.deploy(self)
    self:undeploy()
    local cpyGroup = Group.getByName(self.groupName)
    for i = 1, cpyGroup:getSize() do
        local unit = cpyGroup:getUnit(i)
        if unit then
            if PlatoonUnitTypeNames[unit:getTypeName()] == "APC" or PlatoonUnitTypeNames[unit:getTypeName()] == "IFV" then
                local pltUnits = {}
                for p = 1, #Platoons["DeployedInf"] do
                    table.insert(pltUnits, Platoons["DeployedInf"][p])
                end
                local groupWaypoints = SpawnFuncs.createWPListFromPoints({[1] = unit:getPoint()})
                local deployedGroupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(Company.coalitionId, 2, pltUnits, groupWaypoints)
                for j = 1, #deployedGroupTable["units"] do
                    local deployPoint = Utils.VectorAdd(unit:getPoint(), Utils.ScalarMult(Utils.RotateVector(unit:getPosition().x, 0.52 + (0.14 * (j-1))), 8+(((j-1)/2))))
                    deployedGroupTable["units"][j].x = deployPoint.x
                    deployedGroupTable["units"][j].y = deployPoint.z
                end
                table.insert(self.deployedGroupNames, deployedGroupTable["name"])
                --spawn group
                coalition.addGroup(80+(2-self.coalitionId), 2, deployedGroupTable)
            end
        end
    end
end
function Company.undeploy(self)
    for i = 1, #self.deployedGroupNames do
        local deployedGroup = Group.getByName(self.deployedGroupNames[i])
        if deployedGroup then
            deployedGroup:destroy()
            self.deployedGroupName = nil
        end
    end
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