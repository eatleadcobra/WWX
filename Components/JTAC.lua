JTAC = {}
local jtac = {
    distanceLimit = 10000, -- Set the distance limit for lasing targets (in meters) using 10 kilometers cause google said 5-20
    trackingInterval = 10,
    missionLength = 30,
    jtacs = {},
    updateInterval = 30,
    CLONEGROUP = "JTAC_TEMPLATE",
    jtacHeight = 1.8,
    vehicleHeight = 2.5,
    jtacMenu = nil
}
local lasing = {}
-- use events to handle death of target better. if player kills, good kill and exit loop, if not player kill immediatly lase new target.
local jtacEvents = {}
local debug = true
local lightDebug = false
local spawnDebug = true
if debug then lightDebug = true end


-- ===========================
function jtacEvents:onEvent(event)
    if event.id == world.event.S_EVENT_TAKEOFF then
        if event.initiator and event .initiator.getGroup then
            local group = event.initiator:getGroup()
            local playerName = event.initiator:getPlayerName()
            if group and playerName then
                jtac.populateMenus({group = group:getName()})
            end
        end
    end
    if event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_EJECTION  or event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT or event.id == world.event.S_EVENT_LAND then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                jtac.removeMenus({group = group:getName()})
            end
        end
    end
end
world.addEventHandler(jtacEvents)
-- ============================

function jtac.populateMenus(params)
    local groupName = params.group
    local group = Group.getByName(params.group)
    if group then
        if not jtac.jtacMenu then
            jtac.jtacMenu = {}
        end
        if not jtac.jtacMenu["root"] then
            jtac.jtacMenu["root"] = {}
            jtac.jtacMenu["root"][groupName] = missionCommands.addSubMenuForGroup(group:getID(), "JTAC")
        end
        for j, _ in pairs(jtac.jtacs) do
            if not jtac.jtacMenu[j] then
                jtac.jtacMenu[groupName][j] = missionCommands.addSubMenuForGroup(group:getID(), _.frequency .. " " .. _.modulation .. " - " .. _.callsign, jtac.jtacMenu["root"])
                -- add check in logic eventually, for now just laser on and laser off
                missionCommands.addCommandForGroup(group:getID(), "Laser on", jtac.jtacMenu[groupName][j], jtac.startMission, j)
                missionCommands.addCommandForGroup(group:getID(), "Laser off", jtac.jtacMenu[groupName][j], jtac.stopMission, j)
            end
        end
    end
end
function jtac.removeMenus(params)
    local groupName = params.group
    local group = Group.getByName(params.group)
    if group then
        missionCommands.removeItemForGroup(group:getID(), jtac.jtacMenu["root"][groupName])
    end
end
function jtac.checkIn(params)
    local group = Group.getByName(params.group)
    if group then
        local unit = Group:getUnit(1)
        if unit then
            local flight = jtac.jtacs[params.jtac].callsign .. ", this is " .. unit:getPlayerName() .. ", 1 x " .. unit:getDesc().typeName
            local location = coord.LLtoMGRS(coord.LOtoLL(unit:getPoint()))
            -- Loadout
            local loadout = unit:getAmmo()
            local loadoutStr = "Ordinance: "
            for i = 1, #loadout do
                loadoutStr = loadoutStr .. loadout[i].count .. "x" .. loadout[i].desc.displayName .. ", "
            end
            loadoutStr:sub(1, -2)
            local timeOnStation = "Play time is 0 + 30"
            local remark = "Available for tasking. What do you have for me?"
            local checkInStr = flight .. "\n" .. location .. "\n" .. loadoutStr .. "\n" .. timeOnStation .. "\n" .. remark
            jtac.transmit({message = checkInStr})
            return {{loadout = loadout, location = location, callsign = unit:getPlayerName(), text = checkInStr, jtac = params.jtac, groupName = params.group}}
        end
    end
end
function jtac.transmit(params)
    local radioGroup = Group.getByName(params.jtac)
        if radioGroup then
            local msg = {
                id = 'TransmitMessage',
                params = {
                duration = 10,
                subtitle = params.message,
                loop = false,
                file ="l10n/DEFAULT/Alert.ogg",
                }
            }
            radioGroup:getController():setCommand(msg)
    end
end
function jtac.confirmCheckIn(params)
    if jtac.jtacs[params.jtac].controlling then
        if jtac.jtacs[params.jtac].controlling ~= params.callsign then
            jtac.transmit({message="Already Controlling another Unit, please hold"})
            return
        end
    end
    local group = Group.getByName(params.groupName)
    if group then
        jtac.transmit({"check in confirmed proceed to hold near BP and report established when ready"})
        missionCommands.addCommandForGroup(group:getID(), "established", jtac.jtacMenu[params.group][params.jtac], jtac.established, {{loadout = params.loadout, location = params.location, callsign = params, jtac = params.jtac, groupName = params.groupName}})
    end
end
function JTAC.targetTypeList(targets) -- Used with detectedTargets not just a unit list
    local targetTable = {
        ["SAM"] = {},
        ["AAA"] = {},
        ["HeavyArmoredUnits"] = {},
        ["LightArmoredUnits"] = {},
        ["Armed vehicles"] = {}
    }
    for i = 1, #targets do
        local targetObject = Unit.getByName(targets[i])
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
                                    trigger.action.outTextForCoalition(2, "LASER HOT", 15, false)
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
function jtac.getUnitsInRadius(coalitionId, point, radius)
    local findCoalition = 2
    if coalitionId == 2 then
        findCoalition = 1
    end
    local jtacPoint = point
    jtacPoint.y = jtacPoint.y + jtac.jtacHeight
    local units = {}
    local rejectedUnits = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = point,
            radius = radius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getCoalition() == findCoalition then
            if foundItem:getDesc().category == 2 and foundItem:hasAttribute("Ground vehicles") then
                local targetPoint = foundItem:getPoint()
                targetPoint.y = targetPoint.y + jtac.vehicleHeight
                if land.isVisible(jtacPoint, targetPoint) then
                    units[#units+1] = foundItem:getName()
                end
            end
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    return units
end
-- jtacName
function jtac.trackLaser(param)
    local jtacUnit = Unit.getByName(param.jtacName)
    if jtac.jtacs[param.jtacName].stopLasing then
        if lasing[param.jtacName] and lasing[param.jtacName].laser and jtacUnit then -- remove and jtacUnit if we have trouble
        env.info("Destroying laser", (debug or lightDebug))
        lasing[param.jtacName].laser:destroy()
        trigger.action.outTextForCoalition(2, "Laser destoyed", 15, false)
        end
        env.info("nilling lase", (debug or lightDebug))
        lasing[param.jtacName] = nil
        jtac.jtacs[param.jtacName].stopLasing = false
        trigger.action.outTextForCoalition(2, "JTAC mission ended", 15, false)
    end
    if jtacUnit then
        local lasingInfo = lasing[param.jtacName]
        if lasingInfo then
            local target = Unit.getByName(lasingInfo.targetName)
            if target then
                local tp = target:getPoint()
                local laser = lasingInfo.laser
                if tp and laser then
                    --env.info("laser exists", debug)
                    laser:setPoint(tp)
                    timer.scheduleFunction(jtac.trackLaser, {jtacName = param.jtacName}, timer.getTime() + jtac.trackingInterval)
                    return
                end
            end
        end
    end
    if lasing[param.jtacName] then
        -- if anything fails here either the jtac, target, or laser are dead so we start over
        if lasing[param.jtacName] and lasing[param.jtacName].laser and jtacUnit then -- remove and jtacUnit if we have trouble
            env.info("Destroying laser", (debug or lightDebug))
            lasing[param.jtacName].laser:destroy()
        end
        -- if no new targets for length of mission start relasing, I am going to replace this with having to get a 9l for every new mission but this is a 'for now' thing
        if lasing[param.jtacName].startTime + jtac.missionLength > timer:getTime() then
            lasing[param.jtacName] = nil
            jtac.laseAvailableTarget(param.jtacName, param.code, param.targetList)
        else
            env.info("nilling lase", (debug or lightDebug))
            lasing[param.jtacName] = nil
        end
    end
end
function jtac.stopMission(jtacName)
    jtac.jtacs[jtacName].stopLasing = true
end
function JTAC.registerJtac(name)
    local jtacUnit = Unit.getByName(name)
    if jtacUnit then
        -- placeholders, will be generated eventually
        local callsign = "PLAYBOY"
        local frequency = "97.5"
        local modulation = "FM"
        jtac.jtacs[name] = {spawnTime = timer:getTime(), code = 1688, callsign = callsign, frequency = frequency, modulation = modulation}
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
        groupName = mist.teleportToPoint({groupName = jtac.CLONEGROUP, point = point, action = 'clone'}).name
    else
        groupName = mist.cloneGroup(jtac.CLONEGROUP, true).name
    end
    if groupName then
        local jtacGroup = Group.getByName(groupName)
        if jtacGroup then
            local jtacUnit = jtacGroup:getUnit(1)
            if jtacUnit then
                JTAC.registerJtac(jtacUnit:getName())
            end
        end
    end
end
function jtac.detectUnits(jtacUnitName)
    local unit = Unit.getByName(jtacUnitName)
    if unit then
        local coalition = unit:getCoalition()
        if coalition then
            local point = unit:getPoint()
            if point then
                env.info("detecting targets...", debug)
                local detectedTargets = jtac.getUnitsInRadius(coalition, point, jtac.distanceLimit)
                if detectedTargets then
                    return detectedTargets
                end
            end
        end
    end
end
function jtac.startMission(jtacUnitName)
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
        trigger.action.outTextForCoalition(2, jtac.jtacs[jtacUnitName].callsign .. "is out of action!", 15, false)
    end
end
if spawnDebug then
    local point = trigger.misc.getZone("JTAC_DEBUG_POINT").point
    JTAC.spawnJtacAtPoint(point)
end
jtac.populateMenus()



