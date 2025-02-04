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
    position = {},
    platoons = {},
    waypoints = {},
    groupName = ""
}
function Company:new(coalitionId, platoons)
    local newCpy = Company:deepcopy()
    newCpy.id = Utils.uuid()
    newCpy.coalitionId = coalitionId
end
function Company:spawn(waypoints)
    --create waypoint table from waypoints list
    --create group table using waypoints and platoons
    --spawn group
    --set position and groupname
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