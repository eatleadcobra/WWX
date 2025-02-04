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
    groupName = ""
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
function Company:spawn(waypoints)
    --create waypoint table from waypoints list
    local groupWaypoints = SpawnFuncs.createWPListFromPoints(waypoints)
    --create group table using waypoints and platoons
    local unitsList = Company:convertPlatoonsToUnitList()
    local cpyGroupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(Company.coalitionId, 2, unitsList, groupWaypoints)
    self.groupName = cpyGroupTable["name"]
    --spawn group
    coalition.addGroup(80+(2-self.coalitionId), 2, cpyGroupTable)
end
function Company.convertPlatoonsToUnitList(self)
    local unitList = {}
    for i = 1, #Company.platoons do
        for j = 1, #Company.platoons[i] do
            local unitType = Company.platoons[i][j]
            if unitType then
                table.insert(unitList, unitType)
            end
        end
    end
    return unitList
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