SBLOCKER = {}
SBLOCKER.blockedGroups = {}
SBLOCKER.originalGroups = {}

local sblocker = {}
sblocker.tolerance = 0.1 -- 10% of initial size

local missionName = env.mission["date"]["Year"]
local spawnState = lfs.writedir() .. [[Logs/]] .. 'spawns'..missionName..'.txt'

function SBLOCKER.run()
    for groupName, _ in pairs(PERSISTENTDEATH) do
        local checkgroup = Group.getByName(groupName)
        local groupDead = false
        if checkgroup then
            if checkgroup:getSize() / checkgroup:getInitialSize() <= sblocker.tolerance then
                groupDead = true
            end
        else
            groupDead = true
        end
        if groupDead then
            SBLOCKER.blockedGroups[groupName] = true
            RESPAWNGROUPS[groupName] = nil
            PERSISTENTDEATH[groupName] = nil
            env.info("SBLOCKER: Group " .. groupName .. " is dead and in the persistent death list, adding to blocked respawn groups.", false)
            sblocker.savePersistance()
        end
    end
end
function sblocker.killOnRestart()
    for groupName, _ in pairs(SBLOCKER.blockedGroups) do
        local checkgroup = Group.getByName(groupName)
        if checkgroup then
            checkgroup:destroy()
            env.info("SBLOCKER: Group " .. groupName .. " is blocked and has been destroyed on mission restart.", false)
        end
    end
end
function sblocker.loadPersistance()
    if Utils.fileExists(spawnState) then
        local f = io.open(spawnState)
        local spawnData = dofile(spawnState)
        for k,v in pairs(spawnData) do
            SBLOCKER.blockedGroups[k] = v
        end
        f:close()
    end
end
function sblocker.savePersistance()
    local spawnFile = spawnState
    local f = io.open(spawnFile, 'w')
    f:write("return " .. Utils.saveToString(SBLOCKER.blockedGroups))
    f:close()
end
function sblocker.clearPersistance()
    local spawnFile = spawnState
    local f = io.open(spawnFile, 'w')
    if f then
        f:write("return {}")
        f:close()
    end
end

env.info("SBLOCKER: Persistent Respawn Blocker loaded.", false)
SBLOCKER.originalGroups = PERSISTENTDEATH -- Keep original groups for ME restart purposes
sblocker.loadPersistance()
sblocker.killOnRestart()