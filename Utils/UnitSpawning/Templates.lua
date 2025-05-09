SpawnTemplates = {}
SpawnTemplates.missionTemplate = {
    id = 'Mission',
    params = {
        airborne = false,
        route = {
            points = {},
        },
    },
}
SpawnTemplates.pointTemplate = {
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
}
SpawnTemplates.groupTemplate = {
    ["visible"] = false,
    ["tasks"] = {},
    ["uncontrollable"] = false,
    ["task"] = "Ground Nothing",
    ["route"] = {
        ["points"] = {},
    },
    ["groupId"] = 1,
    ["hidden"] = false,
    ["units"] = {},
    ["y"] = 0,
    ["x"] = 0,
    ["name"] = nil,
    ["start_time"] = 0,
}
SpawnTemplates.unitTemplates = {
    [0] = {

    },
    [1] = {},
    [2] = {
        ["skill"] = "Excellent",
        ["coldAtStart"] = false,
        ["type"] = "",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
    [3] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
        ["playerCanDrive"] = false,
    },
}