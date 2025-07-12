local statsFile = ""

local missionName = env.mission["date"]["Year"]
local validLoad = false
if missionName ~= nil then
    statsFile = lfs.writedir() .. [[Logs/]] .. 'stats_'..missionName..'.txt'
    validLoad = true
end
if validLoad then
    STATS = {}
    STATS.statID = {
        ["FRONT_DEPOT_DESTROYED"] = 1,
        ["REAR_DEPOT_DESTROYED"] = 2,
        ["TANK_CPY_STALLED"] = 3,
        ["CONVOY_DESTROYED"] = 4,
        ["SHIP_SUNK"] = 5,
    }
    local stats = {}
    stats.teamStats = {
        [1] = {
            [1] = 0,
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0,
        },
        [2] = {
            [1] = 0,
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0,
        }
    }

    if Utils.fileExists(statsFile) then
        local f = io.open(statsFile, 'r')
        if f then
            local statsData = dofile(statsFile)
            if statsData then
                stats.teamStats = statsData
            end
            f:close()
        end
    end

    function stats.save()
        local f = io.open(statsFile, 'w')
        if f then
            f:write("return " .. Utils.saveToString(stats.teamStats))
            f:close()
        end
    end
    function STATS.addStat(coalitionId, statId)
        if coalitionId and statId then
            stats.teamStats[coalitionId][statId] = stats.teamStats[coalitionId][statId] + 1
        else
            env.info("Add stat called with invalid parameters", false)
        end
    end
end