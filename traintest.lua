
local startPoint = trigger.misc.getZone("start-train").point
local endPoint = trigger.misc.getZone("end-train").point
local endRadius = trigger.misc.getZone("end-train").radius
local groupTable = {
    ["visible"] = false,
    ["lateActivation"] = false,
    ["tasks"] = {},
    ["uncontrollable"] = false,
    ["task"] = "Ground Nothing",
    ["taskSelected"] = true,
    ["route"] = 
    {
        ["spans"] = 
        {
        }, -- end of ["spans"]
        ["points"] = 
        {
            [1] = 
            {
                ["alt"] = 444,
                ["type"] = "On Railroads",
                ["ETA"] = 0,
                ["alt_type"] = "BARO",
                ["formation_template"] = "",
                ["y"] = startPoint.z,
                ["x"] = startPoint.x,
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
            }, -- end of [1]
            [2] = 
            {
                ["alt"] = 290,
                ["type"] = "On Railroads",
                ["ETA"] = 2552.2416366473,
                ["alt_type"] = "BARO",
                ["formation_template"] = "",
                ["y"] = endPoint.z,
                ["x"] = endPoint.x,
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
            }, -- end of [2]
        }, -- end of ["points"]
        ["routeRelativeTOT"] = false,
    }, -- end of ["route"]
    ["groupId"] = 1,
    ["hidden"] = false,
    ["units"] = 
    {
        [1] = 
        {
            ["skill"] = "Average",
            ["coldAtStart"] = false,
            ["type"] = "Train",
            ["unitId"] = 1,
            ["y"] = startPoint.z,
            ["x"] = startPoint.x,
            ["name"] = "Ground-1-1",
            ["heading"] = 5.2535949800736,
            ["playerCanDrive"] = false,
            ["wagons"] =
            {
                [6] = "Coach a tank blue",
                [2] = "Coach a tank blue",
                [3] = "Coach a tank blue",
                [1] = "Locomotive",
                [4] = "Coach a tank blue",
                [5] = "Coach a tank blue",
                [7] = "Coach a tank blue",
                [8] = "Coach a tank blue",
                [9] = "Coach a tank blue",
            }, -- end of ["wagons"]
        }, -- end of [1]
    }, -- end of ["units"]
    ["y"] = startPoint.z,
    ["x"] = startPoint.x,
    ["name"] = "Train",
    ["start_time"] = 0,
} -- end of [1]
local countryId = country.id.CJTF_BLUE
local groupType = 4
local groupName = coalition.addGroup(countryId, groupType, groupTable):getName()

function trackTrain(groupName)
    local trainPoint = Group.getByName(groupName):getUnit(1):getPoint()
    local vec = {x = trainPoint.x - endPoint.x, y = 0, z = trainPoint.z - endPoint.z}
    local trainDistance = (vec.x^2 + vec.y^2 + vec.z^2)^0.5
    trigger.action.outText("Train is " .. trainDistance .."m away from destination", 10, false)
    trigger.action.outText("Train health: " .. Group.getByName(groupName):getUnit(1):getLife(), 10, false)
    trigger.action.outText("Train group size: " .. Group.getByName(groupName):getSize(), 10, false)
    trigger.action.outText("Train: " .. dump(Group.getByName(groupName):getUnit(1):getDesc()), 10, false)
    if trainDistance > endRadius then
        timer.scheduleFunction(trackTrain, groupName, timer:getTime() + 15)
    else
        trigger.action.outText("ARRIVED", 60, false)
        --trigger.action.explosion(trainPoint, 1000)
        timer.scheduleFunction(cleanjunk, nil, timer:getTime() + 15)
    end
end
function cleanjunk()
    trigger.action.outText("removing junk", 10, false)
    local removeJunkPoint = { x = endPoint.x, y = land.getHeight({x = endPoint.x, y = endPoint.z}), z = endPoint.z}
    local junkSphere = {
    id = world.VolumeType.SPHERE,
        params = {
            point = removeJunkPoint,
            radius = 1200
        }
    }
    world.removeJunk(junkSphere)
end
function dump(o)
    if o == nil then
        return "~nil~"
    elseif type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
trackTrain(groupName)