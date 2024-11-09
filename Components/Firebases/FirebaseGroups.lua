FirebaseGroups = {}
local nextGroupId = 100
local fbg = {}
fbg.typeCounts = {
    ["MORTAR"] = 3,
    ["TRUCK"] = 1,
    ["HOWITZER"] = 1,
    ["SPG"] = 1,
    ["inf"] = 1,
    ["249"] = 1,
    ["rpg"] = 1,
}
fbg.infIncluded = {
    ["MORTAR"] = false,
    ["TRUCK"] = false,
    ["HOWITZER"] = false,
    ["SPG"] = false,
}
fbg.immortalGroup = {
    ["MORTAR"] = false,
    ["TRUCK"] = true,
    ["HOWITZER"] = false,
    ["SPG"] = false,
}
local routes = {
    ["pirate"] = {
        [1] = {
            ["route"] =
            {
                ["routeRelativeTOT"] = true,
                ["points"] =
                {
                    [1] =
                    {
                        ["alt"] = 0,
                        ["type"] = "Turning Point",
                        ["ETA"] = 0,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = 0,
                        ["x"] = 0,
                        ["ETA_locked"] = true,
                        ["speed"] = 0,
                        ["action"] = "Turning Point",
                        ["task"] = 
                        {
                            ["id"] = "ComboTask",
                            ["params"] = 
                            {
                                ["tasks"] = {},
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [1]
                    [2] =
                    {
                        ["alt"] = 0,
                        ["type"] = "Turning Point",
                        ["ETA"] = 2255.7423551568,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = -178745.64295892,
                        ["x"] = -6187.9059623402,
                        ["ETA_locked"] = false,
                        ["speed"] = 30,
                        ["action"] = "Turning Point",
                        ["task"] =
                        {
                            ["id"] = "ComboTask",
                            ["params"] =
                            {
                                ["tasks"] = {},
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [2]
                    [3] = 
                    {
                        ["alt"] = 0,
                        ["type"] = "Turning Point",
                        ["ETA"] = 2528.0331099412,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = -183395.45753542,
                        ["x"] = 528.28745589716,
                        ["ETA_locked"] = false,
                        ["speed"] = 30,
                        ["action"] = "Turning Point",
                        ["task"] =
                        {
                            ["id"] = "ComboTask",
                            ["params"] =
                            {
                                ["tasks"] = {},
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [3]
                }, -- end of ["points"]
            }, -- end of ["route"]
        },
        [2] = {
            ["route"] =
            {
                ["routeRelativeTOT"] = true,
                ["points"] =
                {
                    [1] =
                    {
                        ["alt"] = 0,
                        ["type"] = "Turning Point",
                        ["ETA"] = 0,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = 0,
                        ["x"] = 0,
                        ["ETA_locked"] = true,
                        ["speed"] = 0,
                        ["action"] = "Turning Point",
                        ["task"] = 
                        {
                            ["id"] = "ComboTask",
                            ["params"] = 
                            {
                                ["tasks"] = {},
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [1]
                    [2] =
                    {
                        ["alt"] = 0,
                        ["type"] = "Turning Point",
                        ["ETA"] = 1693.6531190227,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = -260419.73926264,
                        ["x"] = 60044.547433579,
                        ["ETA_locked"] = false,
                        ["speed"] = 30,
                        ["action"] = "Turning Point",
                        ["task"] = 
                        {
                            ["id"] = "ComboTask",
                            ["params"] = 
                            {
                                ["tasks"] = {},
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [2]
                    [3] =
                    {
                        ["alt"] = 0,
                        ["type"] = "Turning Point",
                        ["ETA"] = 2535.7723796395,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = -266675.1848208,
                        ["x"] = 53251.621261534,
                        ["ETA_locked"] = false,
                        ["speed"] = 30,
                        ["action"] = "Turning Point",
                        ["task"] =
                        {
                            ["id"] = "ComboTask",
                            ["params"] =
                            {
                                ["tasks"] = {},
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [3]
                }, -- end of ["points"]
            }, -- end of ["route"]
        }
    }
}
local groupTemplate =
{
    ["visible"] = false,
    ["tasks"] = {},
    ["uncontrollable"] = false,
    ["task"] = "Ground Nothing",
    ["route"] = {},
    ["groupId"] = 1,
    ["hidden"] = false,
    ["units"] = {},
    ["y"] = 0,
    ["x"] = 0,
    ["name"] = nil,
    ["start_time"] = 0,
}
local unitTemplates = {
    ["MORTAR"] = {
        ["skill"] = "Excellent",
        ["coldAtStart"] = false,
        ["type"] = "2B11 mortar",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "mortar",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["HOWITZER"] = {
        ["skill"] = "Excellent",
        ["coldAtStart"] = false,
        ["type"] = "SAU Gvozdika",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "howitzer",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["SPG"] = {
        ["skill"] = "Excellent",
        ["coldAtStart"] = false,
        ["type"] = "SAU Akatsia",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "howitzer",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["inf"] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "Infantry AK ver2",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "infantry",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["m249"] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "Soldier M249",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "infantry",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["rpg"] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "Paratrooper RPG-16",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "infantry",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["shipaa"] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "ZU-23 Emplacement",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "shipaa",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["pirate"] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "speedboat",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "[pirateboat]",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    ["TRUCK"] = {
        ["livery_id"] = "spring",
        ["skill"] = "Average",
        ["AddPropVehicle"] =
        {
            ["Tent"] = 3,
        }, -- end of ["AddPropVehicle"]
        ["coldAtStart"] = false,
        ["type"] = "Bedford_MWD",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "truck",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    }
}
function FirebaseGroups.spawnPirateBoat(point, boatCoalition)
    local newGroupId = fbg.newGroupId()
    local countryId = country.id.CJTF_BLUE
    if boatCoalition == 1 then countryId = country.id.CJTF_RED end
    local type = 3
    local groupTable = fbg.copyTemplate(groupTemplate)
    groupTable["name"] = country.name[countryId] .. newGroupId
    groupTable["y"] = point.z
    groupTable["x"] = point.x
    groupTable["groupId"] = newGroupId
    groupTable["route"] = fbg.copyTemplate(routes["pirate"][boatCoalition]["route"])
    groupTable["route"]["points"][1].x = point.x
    groupTable["route"]["points"][1].y = point.z
    local unitsTable = {}
    local addUnitTable = fbg.copyTemplate(unitTemplates["pirate"])
    addUnitTable["x"] = point.x
    addUnitTable["y"] = point.z
    addUnitTable["name"] = addUnitTable["name"] .. newGroupId .. 1
    unitsTable[#unitsTable+1] = addUnitTable
    addUnitTable = {}
    groupTable["units"] = unitsTable
    local groupName = coalition.addGroup(countryId, type, groupTable):getName()
    return groupName
end
function FirebaseGroups.spawnCustomGroup(basePoint, groups, unitCoalition, heading)
    local newGroupId = fbg.newGroupId()
    local countryId = country.id.CJTF_BLUE
    if unitCoalition == 1 then countryId = country.id.CJTF_RED end
    local type = 2
    local groupTable = fbg.copyTemplate(groupTemplate)
    groupTable["name"] = country.name[countryId] .. newGroupId
    groupTable["y"] = basePoint.z
    groupTable["x"] = basePoint.x
    groupTable["groupId"] = newGroupId
    local unitsTable = {}
    for i = 1, #groups do
        local addUnitTable = fbg.copyTemplate(unitTemplates[groups[i].type])
        addUnitTable["x"] = groups[i].point.x
        addUnitTable["y"] = groups[i].point.z
        addUnitTable["heading"] = heading
        addUnitTable["name"] = addUnitTable["name"] .. newGroupId .. i
        unitsTable[#unitsTable+1] = addUnitTable
        addUnitTable = {}
    end
    groupTable["units"] = unitsTable
    local groupName = coalition.addGroup(countryId, type, groupTable):getName()
    return groupName
end
function FirebaseGroups.spawn(unitType, location, unitCoalition, heading)
    local newGroupId = fbg.newGroupId()
    local countryId = country.id.CJTF_BLUE
    if unitCoalition == 1 then countryId = country.id.CJTF_RED end
    local type = 2
    local groupTable = fbg.copyTemplate(groupTemplate)
    groupTable["name"] = country.name[countryId] .. newGroupId
    groupTable["y"] = location.z
    groupTable["x"] = location.x
    groupTable["groupId"] = newGroupId
    local unitsTable = {}
    for i = 1, fbg.typeCounts[unitType] do
        local addUnitTable = fbg.copyTemplate(unitTemplates[unitType])
        addUnitTable["x"] = location.x+(i*3)
        addUnitTable["y"] = location.z+(i*3)
        addUnitTable["heading"] = heading
        addUnitTable["name"] = addUnitTable["name"] .. newGroupId .. i
        unitsTable[#unitsTable+1] = addUnitTable
        addUnitTable = {}
        if fbg.infIncluded[unitType] then
            addUnitTable = fbg.copyTemplate(unitTemplates["inf"])
            addUnitTable["x"] = location.x+(i*3)-1
            addUnitTable["y"] = location.z+(i*3)
            addUnitTable["heading"] = heading
            addUnitTable["name"] = addUnitTable["name"] .. newGroupId .. i
            unitsTable[#unitsTable+1] = addUnitTable
            addUnitTable = {}
            addUnitTable = fbg.copyTemplate(unitTemplates["inf"])
            addUnitTable["x"] = location.x+(i*3)-1
            addUnitTable["y"] = location.z+(i*3)-1
            addUnitTable["heading"] = heading
            addUnitTable["name"] = addUnitTable["name"] .. newGroupId .. i
            unitsTable[#unitsTable+1] = addUnitTable
            addUnitTable = {}
        end
    end
    groupTable["units"] = unitsTable
    local groupName = coalition.addGroup(countryId, type, groupTable):getName()
    return groupName
end
function fbg.newGroupId()
    local newId = nextGroupId
    nextGroupId = nextGroupId+1
    return newId
end
function fbg.copyTemplate(templateTable)
    local newTable = {}
    for k,v in pairs(templateTable) do
        if type(v) == "table" then
            newTable[k] = fbg.copyTemplate(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end