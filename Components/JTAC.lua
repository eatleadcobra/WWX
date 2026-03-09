JTAC = {}
local jtac = {
    distanceLimit = 10000, -- Set the distance limit for lasing targets (in meters) using 10 kilometers cause google said 5-20
    trackingInterval = 10,
    missionLength = 30,
    jtacs = {},
    updateInterval = 30,
    CLONEGROUP = "JTAC_TEMPLATE"
}
local lasing = {}
-- use events to handle death of target better. if player kills, good kill and exit loop, if not player kill immediatly lase new target.

local debug = false
local lightDebug = false
local spawnDebug = true
if debug then lightDebug = true end

function JTAC.targetTypeList(targets) -- Used with detectedTargets not just a unit list
    local targetTable = {
        ["SAM"] = {},
        ["AAA"] = {},
        ["HeavyArmoredUnits"] = {},
        ["LightArmoredUnits"] = {},
        ["Armed vehicles"] = {}
    }
    for i = 1, #targets do
        local targetObject = targets[i].object
        if targetObject then
            if targetObject:getDesc().category == 2 then
                local targetName = targetObject:getName()
                if targetObject:hasAttribute("SAM") then
                    targetTable["SAM"][#targetTable["SAM"] + 1] = targetName
                elseif targetObject:hasAttribute("AAA") then
                    targetTable["AAA"][#targetTable["AAA"] + 1] = targetName
                elseif targetObject:hasAttribute("HeavyArmoredUnits") then
                    targetTable["HeavyArmoredUnits"][#targetTable["HeavyArmoredUnits"] + 1] = targetName
                elseif targetObject:hasAttribute("LightArmoredUnits") then
                    targetTable["LightArmoredUnits"][#targetTable["LightArmoredUnits"] + 1] = targetName
                elseif targetObject:hasAttribute("Armed vehicles") then
                    targetTable["Armed vehicles"][#targetTable["Armed vehicles"] + 1] = targetName
                end
            end
        end
    end
    return targetTable
end
function jtac.getPriorityList(targets)
    local priorityTable = {
        [1] = "SAM",
        [2] = "HeavyArmoredUnits",
        [3] = "LightArmoredUnits",
        [4] = "Armed vehicles",
        [5] = "AAA"
    }
    local targetList = {}
    for i = 1, #priorityTable do
        local category = priorityTable[i]
        if targets[category] then
            for j = 1, #targets[category] do
                local targetName = targets[category][j]
                if Unit.getByName(targetName) then
                    targetList[#targetList + 1] = targets[category][j]
                end
            end
        end
    end
    return targetList
end
function jtac.laseAvailableTarget(jtacUnitName, code, targetList)
    local jtacUnit = Unit.getByName(jtacUnitName)
    local laserSourceRelativeToUnit = {x = 0, y = 1.8, z = 0}
    if jtacUnit then
        if not lasing[jtacUnit] then
            if targetList then
                for i = 1, #targetList do
                    local target = Unit.getByName(targetList[i])
                    if target then
                        local targetLife = target:getLife()
                        if targetLife > 0 then
                            local targetPoint = target:getPoint()
                            if targetPoint then
                                local jtacPoint = jtacUnit:getPoint()
                                local distance = Utils.PointDistance(jtacPoint, targetPoint)
                                if distance <= jtac.distanceLimit then
                                    env.info("jtac " .. jtacUnitName .. " lasing target " .. targetList[i], debug or lightDebug)
                                    lasing[jtacUnitName] = {
                                        laser = Spot.createLaser(jtacUnit, laserSourceRelativeToUnit, targetPoint, code),
                                        targetName = target:getName(),
                                        startTime = timer:getTime()
                                    }
                                    timer.scheduleFunction(jtac.trackLaser, {jtacName = jtacUnitName, targetList = targetList}, timer.getTime() + jtac.trackingInterval)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        env.error("JTAC unit not found: " .. jtacUnitName, debug)
    end
end
-- jtacName
function jtac.trackLaser(param)
    local jtacUnit = Unit.getByName(param.jtacName)
    if jtacUnit then
        local lasingInfo = lasing[param.jtacName]
        if lasingInfo then
            local target = Unit.getByName(lasingInfo.targetName)
            if target then
                local tp = target:getPoint()
                local laser = lasingInfo.laser
                if tp and laser then
                    env.info("laser exists", debug)
                    laser:setPoint(tp)
                    timer.scheduleFunction(jtac.trackLaser, {jtacName = param.jtacName}, timer.getTime() + jtac.trackingInterval)
                    return
                end
            end
        end
    end
    -- if anything fails here either the jtac, target, or laser are dead so we start over
    if lasing[param.jtacName] and lasing[param.jtacName].laser then
        env.info("Destroying laser", debug or lightDebug)
        lasing[param.jtacName].laser:destroy()
    end
    -- if still have targets to lase, get at em
    if lasing[param.jtacName].startTime + jtac.missionLength > timer:getTime() then
        lasing[param.jtacName] = nil
        jtac.laseAvailableTarget(param.jtacName, param.code, param.targetList)
    else
        env.info("nilling lase", debug or lightDebug)
        lasing[param.jtacName] = nil
    end
end
function JTAC.registerJtac(name)
    local jtacUnit = Unit.getByName(name)
    if jtacUnit then
        jtac.jtacs[name] = {spawnTime = timer:getTime(), code = 1688}
    end
end
function JTAC.deRegisterJtac(name)
    local jtacUnit = Unit.getByName(name)
    if jtacUnit then
        local jtacGroup = jtacUnit:getGroup()
        if jtacGroup then
            jtacGroup:destroy()
        end
    end
    jtac.jtacs[name] = nil
end
function JTAC.spawnJtacAtPoint(point)
    local groupName
    if point then
        groupName = mist.teleportToPoint({groupName = jtac.CLONEGROUP, point = point, action = 'clone'})
    else
        groupName = mist.cloneGroup(jtac.CLONEGROUP, true).name
    end
    if groupName then
        local jtacGroup = Group.getByName(groupName)
        if jtacGroup then
            local jtacUnit = jtacGroup.getUnit(1)
            if jtacUnit then
                JTAC.registerJtac(jtacUnit:getName())
            end
        end
    end
end
function jtac.detectUnits(jtacUnitName)
    local unit = Unit.getByName(jtacUnitName)
    if unit then
        local group = unit:getGroup()
        if group then
            local controller = unit:getController()
            if controller then
                env.info("detecting targets...", debug)
                local detectedTargets = controller:getDetectedTargets()
                if detectedTargets then
                    return detectedTargets
                end
            end
        end
    end
end
function jtac.jtacLoop()
    for jtacUnitName, _ in pairs(jtac.jtacs) do
        local jtacUnit = Unit.getByName(jtacUnitName)
        env.info("jtac unit " .. jtacUnitName, debug)
        if jtacUnit then
            if not lasing[jtacUnitName] then
                local targets = jtac.detectUnits(jtacUnitName)
                env.info("jtac unit " .. jtacUnitName .. " found: \n" .. Utils.dump(targets), debug)
                if targets then
                    local targetTypes = JTAC.targetTypeList(targets)
                    env.info("jtac unit " .. jtacUnitName .. " target types: \n" .. Utils.dump(targetTypes), debug)
                    if targetTypes then
                        local priorityList = jtac.getPriorityList(targetTypes)
                        env.info("jtac unit ".. jtacUnitName .. " priorityTable: \n" .. Utils.dump(priorityList), debug)
                        if priorityList then
                            -- in future just store the priorityTable and use it for syntax?
                            jtac.laseAvailableTarget(jtacUnitName, jtac.jtacs[jtacUnitName].code, priorityList)
                        end
                    end
                end
            end
        else
            JTAC.deRegisterJtac(jtacUnitName)
        end
    end
    timer.scheduleFunction(jtac.jtacLoop, nil, timer:getTime() + jtac.updateInterval)
end
if spawnDebug then
    local groupName = mist.cloneGroup("JtacTemplate", true).name
    local group = Group.getByName(groupName)
    local unit = group:getUnit(1)
    local unitName = unit:getName()
    JTAC.registerJtac(unitName)
end
jtac.jtacLoop()

