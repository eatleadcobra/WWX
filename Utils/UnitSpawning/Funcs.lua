SpawnFuncs = {}
SpawnFuncs.groupId = 42069
function SpawnFuncs.setGroupWaypoints(groupTable, listOfWaypoints)
    --local wpSetGroup = SpawnFuncs.deepcopy(groupTable)
    for i = 1, #listOfWaypoints do
        groupTable["route"]["points"][i] = listOfWaypoints[i]
    end
    groupTable["y"] = listOfWaypoints[1].y
    groupTable["x"] = listOfWaypoints[1].x
    for i = 1, #groupTable["units"] do
        groupTable["units"][i].x = listOfWaypoints[1].x
        groupTable["units"][i].y = listOfWaypoints[1].y
    end
end
function SpawnFuncs.createWPListFromPoints(listOfPoints, speed)
    local wps = {}
    for i = 1, #listOfPoints do
        local point = SpawnFuncs.deepcopy(SpawnTemplates.pointTemplate)
        if point then
            point.x = listOfPoints[i].x
            if listOfPoints[i].z then
                point.y = listOfPoints[i].z
            else
                point.y = listOfPoints[i].y
            end
            if speed then
                point.speed = speed
            end
            wps[#wps+1] = point
        end
    end
    return wps
end
function SpawnFuncs.createMission(listOfWaypoints)
    local missionTable = Utils.deepcopy(SpawnTemplates.missionTemplate)
    for i = 1, #listOfWaypoints do
        missionTable["params"]["route"]["points"][i] = listOfWaypoints[i]
    end
    return missionTable
end
function SpawnFuncs.createGroupTableFromListofUnitTypes(coalitionId, groupType, listOfUnitTypeNames, listOfWaypoints)
    local newGroupId = SpawnFuncs.getNextGroupId()
    local countryId = 80 + (2-coalitionId)
    local groupTable = SpawnFuncs.deepcopy(SpawnTemplates.groupTemplate)
    groupTable["name"] = groupType .. newGroupId
    groupTable["groupId"] = newGroupId
    local unitsTable = {}
    for i = 1, #listOfUnitTypeNames do
        local addUnitTable = SpawnFuncs.deepcopy(SpawnTemplates.unitTemplates[groupType])
        addUnitTable["type"] = listOfUnitTypeNames[i]
        addUnitTable["name"] = listOfUnitTypeNames[i] .. newGroupId .. i
        unitsTable[#unitsTable+1] = addUnitTable
        addUnitTable = {}
    end
    groupTable["units"] = unitsTable
    SpawnFuncs.setGroupWaypoints(groupTable, listOfWaypoints)
    return groupTable
end
function SpawnFuncs.spawnCustomGroundGroup(coalitionId, groupType, groupTypespawnPoint, listOfUnitTypeNames, formation)
    local newGroupId = SpawnFuncs.getNextGroupId()
    local countryId = 80 + (2-coalitionId)
    local groupTable = SpawnFuncs.deepcopy(SpawnTemplates.groupTemplate)
    groupTable["name"] = groupType .. newGroupId
    groupTable["groupId"] = newGroupId
    local unitsTable = {}
    for i = 1, #listOfUnitTypeNames do
        local addUnitTable = SpawnFuncs.deepcopy(SpawnTemplates.unitTemplates[groupType])
        addUnitTable["type"] = listOfUnitTypeNames[i]
        addUnitTable["name"] = listOfUnitTypeNames[i] .. newGroupId .. i
        unitsTable[#unitsTable+1] = addUnitTable
        addUnitTable = {}
    end
    groupTable["units"] = unitsTable
    local groupName = coalition.addGroup(countryId, type, groupTable):getName()
    return groupName
end

function SpawnFuncs.getNextGroupId()
    local returnId = SpawnFuncs.groupId
    SpawnFuncs.groupId = SpawnFuncs.groupId+1
    return returnId
end
function SpawnFuncs.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[SpawnFuncs.deepcopy(orig_key)] = SpawnFuncs.deepcopy(orig_value)
        end
        setmetatable(copy, SpawnFuncs.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function SpawnFuncs.dump(o)
    if o == nil then
        return "~nil~"
    elseif type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. SpawnFuncs.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end