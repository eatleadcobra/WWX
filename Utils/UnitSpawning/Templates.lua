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
    ["formation_template"] = "DepotSpawnTemplate",
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
SpawnTemplates.trainPointTemplate = {
    ["alt"] = 444,
    ["type"] = "On Railroads",
    ["ETA"] = 0,
    ["alt_type"] = "BARO",
    ["formation_template"] = "",
    ["y"] = 0,
    ["x"] = 0,
    ["ETA_locked"] = false,
    ["speed"] = 100,
    ["action"] = "On Railroads",
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
    [4] = {
        ["skill"] = "Average",
        ["coldAtStart"] = false,
        ["type"] = "Train",
        ["unitId"] = 1,
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 5.2535949800736,
        ["playerCanDrive"] = false,
        ["wagons"] =
        {
            [1] = "Locomotive",
            [2] = "Locomotive",
            [3] = "Coach cargo",
            [4] = "Coach cargo",
            [5] = "Coach cargo",
            [6] = "Coach cargo",
            [7] = "Coach cargo",
            [8] = "Coach cargo",
            [9] = "Coach cargo",
            [10] = "Coach cargo",
            [11] = "Coach cargo",
            [12] = "Coach cargo",
            [13] = "Coach cargo",
            [14] = "Coach cargo",
            [15] = "Coach cargo",
            [16] = "Coach cargo",
            [17] = "Coach cargo",
            [18] = "Coach cargo",
            [19] = "Coach cargo",
            [20] = "Coach cargo",
            [21] = "Coach cargo",
            [22] = "Coach cargo",
            [23] = "Coach cargo",
            [24] = "Locomotive",
            [25] = "Locomotive",
        }, -- end of ["wagons"]
    }
}