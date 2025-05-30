VB = {}
local staticId = 10
local vb = {}
local flagMinHeight =  0.2
local heights = {
    ["tower"] = 210.81,
    ["watertower"] = 18,
    ["container"] = 2.7,
    ["box"] = 1.004,
    ["tire"] = 0.1
}
local shapes = {
    ["tower"] = {
        ["category"] = "Fortifications",
        ["shape_name"] = "tele_bash",
		["type"] = "TV tower",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
    },
    ["watertower"] = {
        ["category"] = "Fortifications",
        ["shape_name"] = "wodokachka_a",
        ["type"] = "Water tower A",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
    },
    ["container"] = {
        ["category"] = "Fortifications",
        ["shape_name"] = "M92_Container_10ft",
        ["type"] = "Container_10ft",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
    },
    ["box"] = {
        ["category"] = "Fortifications",
        ["shape_name"] = "M92_Cargo05",
		["type"] = "Cargo05",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
    },
    ["tire"] = {
        ["category"] = "Fortifications",
        ["shape_name"] = "H-tyre_B",
        ["type"] = "Black_Tyre",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
    },
    ["flag"] = {
        ["category"] = "Fortifications",
        ["shape_name"] = "H-tyre_B_RF",
		["type"] = "Black_Tyre_RF",
        ["y"] = 0,
        ["x"] = 0,
        ["name"] = "",
        ["heading"] = 0,
    },
}
function VB.createDCpoint(point, coalitionId)
    local alt, depth = land.getSurfaceHeightWithSeabed({x = point.x, y = point.z})
    depth = depth + point.y
    local runningDepth = depth
    local towerCount = math.floor(runningDepth/heights["tower"])
    if towerCount > 0 then runningDepth = runningDepth - towerCount*heights["tower"] end

    local containerCount = math.floor(runningDepth/heights["container"])
    if containerCount > 0 then runningDepth = runningDepth - containerCount*heights["container"] end

    local boxCount = math.floor(runningDepth/heights["box"])
    if boxCount > 0 then
        runningDepth = runningDepth - boxCount*heights["box"]
        if runningDepth > flagMinHeight then boxCount = boxCount+1 end
    end
    local removeList = {}
    for i = 1, towerCount do
        local tower = vb.spawnStatic("tower", point, coalitionId)
        table.insert(removeList, tower)
    end
    for i = 1, containerCount do
        local container = vb.spawnStatic("container", point, coalitionId)
        table.insert(removeList, container)
    end
    for i = 1, boxCount do
        local box = vb.spawnStatic("box", point, coalitionId)
        table.insert(removeList, box)
    end
    local flagName = vb.spawnStatic("flag", point, coalitionId)
    for i = 1, #removeList do
        VB.destroyStatic(removeList[i])
    end
   removeList = {}
    return flagName
end

function VB.createBuoy(point, coalitionId)
    local alt, depth = land.getSurfaceHeightWithSeabed({x = point.x, y = point.z})
    local runningDepth = depth
    local towerCount = math.floor(runningDepth/heights["tower"])
    if towerCount > 0 then runningDepth = runningDepth - towerCount*heights["tower"] end

    local containerCount = math.floor(runningDepth/heights["container"])
    if containerCount > 0 then runningDepth = runningDepth - containerCount*heights["container"] end

    local boxCount = math.floor(runningDepth/heights["box"])
    if boxCount > 0 then
        runningDepth = runningDepth - boxCount*heights["box"]
        if runningDepth > flagMinHeight then boxCount = boxCount+1 end
    end
    local removeList = {}
    for i = 1, towerCount do
        local tower = vb.spawnStatic("tower", point, coalitionId)
        table.insert(removeList, tower)
    end
    for i = 1, containerCount do
        local container = vb.spawnStatic("container", point, coalitionId)
        table.insert(removeList, container)
    end
    for i = 1, boxCount do
        local box = vb.spawnStatic("box", point, coalitionId)
        table.insert(removeList, box)
    end
    local flagName = vb.spawnStatic("flag", point, coalitionId)
    for i = 1, #removeList do
        VB.destroyStatic(removeList[i])
    end
    removeList = {}
    return flagName
end
function vb.spawnStatic(type, point, coalitionId)
    local countryCode = 80 + (2 - coalitionId)
    local staticName = nil
    local id = staticId
    staticId = staticId + 1
    local cargoPoint = point
    local staticTemplate = vb.copyTemplate(shapes[type])
    staticTemplate["name"] = type.."-".."-"..id
    staticName = staticTemplate["name"]
    staticTemplate["y"] = cargoPoint.z
    staticTemplate["x"] = cargoPoint.x
    coalition.addStaticObject(countryCode, staticTemplate)
    return staticName
end
function vb.copyTemplate(templateTable)
    local newTable = {}
    for k,v in pairs(templateTable) do
        if type(v) == "table" then
            newTable[k] = vb.copyTemplate(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end
function VB.destroyStatic(name)
    local destroyStatic = StaticObject.getByName(name)
    if destroyStatic and destroyStatic.destroy then
        destroyStatic:destroy()
    end
end