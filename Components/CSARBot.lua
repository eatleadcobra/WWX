CSB = {}
-- Created by combining CasBot.lua from WWXOS (https://github.com/eatleadcobra/WWX) by EatLeadCobra with
-- autoCSAR.lua and csarManager2.lua from the DML package (https://github.com/csofranz/DML) by cfrag
local searchStackInterval = 20
local trackCsarInterval = 2
local csarStackRadius = 1000
local csarStackHeight = 1000
local csarZoneRadius = 10000
local csarTimeLimitMax = 2400
local csarTimeLimitMin = 1200
local csarPickupRadius = 30
local csarHoverRadius = 20
local csarHoverAgl = 42
local csarHoverTime = 20
local csarBreakCoverRange = 1500
local csarMaxDisplayed = 6
local csarTroopMass = 130
local csarTroopVol = 2
local csarAutoProcRadius = 3000
local genCsarCounter = 25

local csarCheckIns = {
    [1] = {},
    [2] = {}
}
local csarMissions = {
    [1] = {},
    [2] = {}
}
local activeAirbases = {}
local smokeColors = {
    [0] = "green",
    [1] = "red",
    [2] = "white",
    [3] = "orange",
    [4] = "blue"
}
local previousLists = {
    [1] = {},
    [2] = {}
}
local currentLists = {
    [1] = {},
    [2] = {}
}
local stackZones = {
    [1] = "RedCsarStack",
    [2] = "BlueCsarStack"
}
local stackPoints = {
    [1] = {},
    [2] = {}
}
local csarZones = {
    [1] = "RedCsarZone",
    [2] = "BlueCsarZone"
}
local csarPoints = {
    [1] = {},
    [2] = {}
}
local autoCsarEnroll = {}
function autoCsarEnroll:onEvent(event)
    if event.id == world.event.S_EVENT_TAKEOFF then
        if event and event.initiator and event.initiator.getDesc and event.initiator:getDesc().category == 1 and DFS.heloCapacities[event.initiator:getTypeName()] then
            local foundPlayerName = event.initiator:getPlayerName()
            local playerCoalition = event.initiator:getCoalition()
            local playerGroup = event.initiator:getGroup()
            local playerTypeName = event.initiator:getTypeName()
            local playerUnitName = event.initiator:getName()
            if playerGroup then
                local playerGroupID = playerGroup:getID()
                local playerGroupName = playerGroup:getName()
                if foundPlayerName and playerCoalition and playerGroupID then
                    env.info("Found player: "..foundPlayerName, false)
                    CSB.csarAutoCheckIn(foundPlayerName, playerCoalition, playerGroupID, playerGroupName, playerTypeName, playerUnitName)
                end
            end
        end
    end
end
function CSB.load()
    local redZone = trigger.misc.getZone(stackZones[1])
    local blueZone = trigger.misc.getZone(stackZones[2])
    local redCsarZone = trigger.misc.getZone(csarZones[1])
    local blueCsarZone = trigger.misc.getZone(csarZones[2])
    if redZone and blueZone then
        stackPoints[1] = {x=redZone.point.x, y = land.getHeight({x = redZone.point.x, y = redZone.point.z})+csarStackHeight, z = redZone.point.z}
        trigger.action.circleToAll(1, DrawingTools.newMarkId(), stackPoints[1], csarStackRadius, {1,0,0,0.6}, {0,0,0,0}, 4, true, "")
        trigger.action.textToAll(1, DrawingTools.newMarkId(), stackPoints[1], {1,0,0,0.6}, {1,1,1,0.9}, 10, true, "CSAR Stack")
        stackPoints[2] = {x=blueZone.point.x, y = land.getHeight({x = blueZone.point.x, y = blueZone.point.z})+csarStackHeight, z = blueZone.point.z}
        trigger.action.circleToAll(2, DrawingTools.newMarkId(), stackPoints[2], csarStackRadius, {0,0,1,0.6}, {0,0,0,0}, 4, true, "")
        trigger.action.textToAll(2, DrawingTools.newMarkId(), stackPoints[2], {0,0,1,0.6}, {1,1,1,0.9}, 10, true, "CSAR Stack")
    end
    if redCsarZone and blueCsarZone then
        csarZoneRadius = redCsarZone.radius
        csarPoints[1] = {x=redCsarZone.point.x, y = land.getHeight({x = redCsarZone.point.x, y = redCsarZone.point.z})+3, z = redCsarZone.point.z}
        trigger.action.circleToAll(1,DrawingTools.newMarkId(),csarPoints[1],csarZoneRadius,{1,0,0,0.6},{0,0,0,0}, 4, true, "")
        trigger.action.textToAll(1, DrawingTools.newMarkId(), csarPoints[1], {1,0,0,0.6}, {1,1,1,0.9}, 10, true, "CSAR Coverage")
        csarPoints[2] = {x=blueCsarZone.point.x, y = land.getHeight({x = blueCsarZone.point.x, y = blueCsarZone.point.z})+3, z = blueCsarZone.point.z}
        trigger.action.circleToAll(2,DrawingTools.newMarkId(),csarPoints[2],csarZoneRadius,{0,0,1,0.6},{0,0,0,0}, 4, true, "")
        trigger.action.textToAll(2, DrawingTools.newMarkId(), csarPoints[2], {0,0,1,0.6}, {1,1,1,0.9}, 10, true, "CSAR Coverage")
    end
    CSB.buildMissionAirbaseList()
    CSB.main()
    for c = 1, 2 do
        for z = 1, #CSARBases[c] do
            DrawingTools.drawHealth(trigger.misc.getZone(CSARBases[c][z]).point, c, 500)
        end
    end
end
function CSB.main()
    if CSARAUTOENROLL then
        world.addEventHandler(autoCsarEnroll)
    end
    CSB.searchCsarStacks()
    CSB.trackCsar()
    --timer.scheduleFunction(CSB.debugCsarGeneration,nil,timer.getTime()+10)
    CSB.refreshCsarTransmissions()
end

function CSB.searchCsarStacks()
    timer.scheduleFunction(CSB.searchCsarStacks, nil, timer:getTime() + searchStackInterval)
    local genCsarFlag = false
    local genCsarCoalition = 0
    for c = 1,2 do
        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
                point = stackPoints[c],
                radius = csarStackRadius
            }
        }
        local ifFound = function(foundItem, val)
            env.info("CSAR stack search", false)
            if (foundItem:getDesc().category == 0 or foundItem:getDesc().category == 1) and foundItem:isExist() and foundItem:isActive() and foundItem:getCoalition() == c and DFS.heloCapacities[foundItem:getTypeName()] then
                local foundPlayerName = foundItem:getPlayerName()
                local playerCoalition = foundItem:getCoalition()
                local playerGroup = foundItem:getGroup()
                local playerTypeName = foundItem:getTypeName()
                local playerUnitName = foundItem:getName()
                if playerGroup then
                    local playerGroupID = playerGroup:getID()
                    local playerGroupName = playerGroup:getName()
                    if foundPlayerName and playerCoalition and playerGroupID then
                        env.info("Found player: "..foundPlayerName, false)
                        if csarCheckIns[c][foundPlayerName] == nil then
                            env.info("player added to csar check-in list: "..foundPlayerName, false)
                            currentLists[c][foundPlayerName] = {name = foundPlayerName, coalition = playerCoalition, groupID = playerGroupID, groupName = playerGroupName, typeName = playerTypeName, unitName = playerUnitName}
                        else
                            env.info("player already checked-in for CSAR: "..foundPlayerName, false)
                            env.info("csarMission count for " .. c .. " is " .. #csarMissions[c], false)
                            if #csarMissions[c] < 1 then
                                trigger.action.outTextForGroup(playerGroupID, "You are on station for CSAR. Stand by for tasking.", 20, false)
                                env.info("setting genCsarFlag to true", false)
                                genCsarFlag = true
                                genCsarCoalition = playerCoalition
                            end
                        end
                    end
                end
            end
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        if genCsarFlag and genCsarCoalition ~= 0 then CSB.generateCsar(nil,genCsarCoalition,nil,nil,nil,nil,nil,nil,false) end
        for k,v in pairs(currentLists[c]) do
            if previousLists[c][k] then
                CSB.csarCheckIn(v.name, v.coalition, v.groupID, v.groupName, v.typeName, v.unitName)
                env.info("player checked-in for CSAR: ".. v.name, false)
            else
                trigger.action.outTextForGroup(v.groupID, "You are on station for CSAR. Stand by for tasking.", 20, false)
            end
        end
        previousLists[c] = {}
        previousLists[c] = Utils.deepcopy(currentLists[c])
        currentLists[c] = {}
    end
end
function CSB.csarCheckIn(playerName, coalitionId, playerGroupID, playerGroupName, typeName, unitName, prev)
    if not prev then prev = false end
    if not csarCheckIns[coalitionId][playerName] then
        csarCheckIns[coalitionId][playerName] = {groupID = playerGroupID, groupName = playerGroupName, typeName = typeName, unitName = unitName, onBoard = {}}
    end
    if #csarMissions[coalitionId] < 1 then
        CSB.generateCsar(nil, coalitionId, nil, nil, nil, nil, nil, nil, false)
    end
    if not prev then
        CSB.addCsarRadioMenuToGroup(playerGroupID, playerGroupName, coalitionId)
    end
    trigger.action.outTextForGroup(playerGroupID,"Checked-in. Check CSAR menu for active rescues.",30,false)
end
function CSB.csarAutoCheckIn(playerName, coalitionId, playerGroupID, playerGroupName, typeName, unitName)
    if not csarCheckIns[coalitionId][playerName] then
        csarCheckIns[coalitionId][playerName] = {groupID = playerGroupID, groupName = playerGroupName, typeName = typeName, unitName = unitName, onBoard = {}}
        CSB.addCsarRadioMenuToGroup(playerGroupID, playerGroupName, coalitionId)
        trigger.action.outTextForGroup(playerGroupID,"Checked-in. Check CSAR menu for active rescues.",30,false)
    end
end
function CSB.wrappedGenerateCsar(inUnit,coalitionId,overWater,playerName)
    -- check for ejection onto base for auto collection
    if not coalitionId or coalitionId == 0 then return end
    if not (inUnit and inUnit:isExist()) then return end
    local pos = inUnit:getPoint()
    local agl = Utils.getAGL(pos)
    local p1 = {x = pos.x, y = 0, z = pos.z}
    local isCloseToBase = false
    local airbaseName = nil
    local airbaseSide = 0
    local opposition = 2
    local enemyBase = false
    local pilotStr = " (AI)"
    if playerName then pilotStr = " (" .. playerName .. ")" end
    if coalitionId == 2 then opposition = 1 end
    for abName,abInfo in pairs(activeAirbases) do
        local p2 = {x = abInfo.pos.x, y = 0, z = abInfo.pos.z}
        local dist = Utils.PointDistance(p1,p2)
        if dist < csarAutoProcRadius then
            isCloseToBase = true
            airbaseName = abName
            airbaseSide = abInfo.side
            if abInfo.side == opposition then enemyBase = true end
            break
        end
    end
    if isCloseToBase and airbaseSide ~= 0 then
        if enemyBase then
            trigger.action.outTextForCoalition(coalitionId, "Pilot" .. pilotStr .. " bailed out and landed close to enemy airbase at " .. airbaseName .. " and was captured.",20,false)
            if Recon and math.random() < 0.02 then
                local msns = Recon.getCurrentMissionsByCoalition(opposition)
                local locmsns = {}
                if msns then
                    for k,v in pairs(msns) do
                        if v.type == 2 then table.insert(locmsns,k) end
                    end
                    if locmsns then
                        local msnId = locmsns[math.random(#locmsns)]
                        Recon.processCompletedMission(opposition,msnId,nil,"enemy interrogation")
                        local nearestBase, dist, dir = CSB.closestBaseTo(msns[msnId].point)
                        trigger.action.outTextForCoalition(opposition,"Interrogation of enemy pilot has revealed enemy positions " .. dist .. "km " .. dir .. " of " .. nearestBase, 10, false)
                    end
                end
            elseif DFS and math.random() < 0.33 then
                DFS.IncreaseFrontSupply({coalitionId = opposition, amount = 1, type = DFS.supplyType.EQUIPMENT})
            end
        else
            trigger.action.outTextForCoalition(coalitionId, "Pilot" .. pilotStr .. " bailed out and landed close to friendly airbase at " .. airbaseName .. " and was picked up.",20,false)
        end
        return
    end
    local anyTerrain = nil
    pos = {x = pos.x, y = pos.y-agl, z = pos.z}
    if overWater then
        anyTerrain = true
    end
    CSB.generateCsar(pos,coalitionId,nil,nil,1000,anyTerrain,nil,playerName,false)
end
function CSB.generateCsar(csarPoint, coalitionId, freq, channel, csarRadius, anyTerrain, timeLimit, playerName, radioSilence)
    local fName = ""
    local smokeNum = math.random(0,4)
    local generatedCsar = {}
    local genPoint = nil
    generatedCsar.coalition = coalitionId
    if playerName then
        fName = playerName.." (ejected) "..genCsarCounter
    elseif RandomNames and RandomNames.getNewName then
        fName = RandomNames.getNewName(coalitionId)
    else
        fName = "Chris Burnett "..genCsarCounter
    end
    generatedCsar.name = fName
    if not csarRadius then csarRadius = csarZoneRadius end
    if not csarPoint then csarPoint = csarPoints[coalitionId] end
    env.info("in generateCsar with args :--- coalitionId: " .. coalitionId .. " csarPoint: x=" .. csarPoint.x .. ", y=" .. csarPoint.y .. ", z=" .. csarPoint.z .. " csarRadius: " .. csarRadius .. " anyTerrain: " .. tostring(anyTerrain), false)
    if not anyTerrain then
        generatedCsar.terrainLimit = {"LAND", "ROAD"}
        for i=1,100 do
            genPoint = Utils.MakeVec3(mist.getRandPointInCircle(csarPoint, csarRadius, nil, nil, nil))
            if mist.isTerrainValid(genPoint,generatedCsar.terrainLimit) then break end
        end
    else
        genPoint = Utils.MakeVec3(mist.getRandPointInCircle(csarPoint, csarRadius, nil, nil, nil))
    end
    local terrainHght = land.getHeight({x=genPoint.x, y=genPoint.z}) or 0
    genPoint.y = terrainHght
    generatedCsar.point = genPoint
    generatedCsar.gearPoint = Utils.MakeVec3(mist.getRandPointInCircle(generatedCsar.point, 10, 5, nil, nil))
    env.info("finished generating point: x=" .. generatedCsar.point.x .. ", y=" .. generatedCsar.point.y ..", z=" .. generatedCsar.point.z, false)
    env.info("finished generating gearpoint: x=" .. generatedCsar.gearPoint.x .. ", y=" .. generatedCsar.gearPoint.y ..", z=" .. generatedCsar.gearPoint.z, false)
    generatedCsar.smokeTime = timer.getTime() - 300
    generatedCsar.smokeNum = smokeNum
    generatedCsar.status = 0
    generatedCsar.freq = freq
    generatedCsar.channel = channel
    generatedCsar.modulation = 0
    generatedCsar.contacts = {}
    generatedCsar.winchers = {}
    generatedCsar.radioSilence = radioSilence
    local cloneSourceGroup = Group.getByName("SOS-"..coalitionId)
    if not cloneSourceGroup then
        env.info("Could not find source group for clone", false)
        return
    end
    env.info("about to create new CSAR unit for " .. fName, false)
    local isCreated = CSB.createCsarUnit(generatedCsar)
    if not isCreated then
        env.info("Failed to create CSAR unit", false)
        return
    end
    genCsarCounter = genCsarCounter + 1
    if radioSilence then
        env.info("created new CSAR unit maintaining radio silence", false)
    else
        env.info("created new CSAR unit transmitting on " .. generatedCsar.freq * 10 .. "kHz/" .. generatedCsar.channel .. "X", false)
    end
    generatedCsar.startTime = timer.getTime()
    if not timeLimit or #timeLimit ~= 2 then timeLimit = {csarTimeLimitMin, csarTimeLimitMax} end
    local exp = math.random(math.floor(math.abs(timeLimit[2] - timeLimit[1]) / 60)) * 60
    if timeLimit[2] < timeLimit[1] then timeLimit[1] = timeLimit[2] end
    generatedCsar.expires = timeLimit[1] + exp
    generatedCsar.skipWellness = true
    if playerName then
        generatedCsar.displayName = playerName
    else
        generatedCsar.displayName = fName
    end
    table.insert(csarMissions[coalitionId], generatedCsar)
    if not radioSilence then
        trigger.action.outTextForCoalition(coalitionId, "- " .. generatedCsar.displayName .. " is requesting immediate extraction...\n - holding position for next " .. math.floor(generatedCsar.expires/60) .. " minutes...\n - broadcasting on " .. generatedCsar.freq * 10 .. "kHz/" .. generatedCsar.channel .. "X", 30, false)
    end
end
function CSB.createCsarUnit(csarMissionTable)
    local anyTerrain = false
    if not csarMissionTable.terrainLimit then anyTerrain = true end
    env.info("SOS - coalition: " .. csarMissionTable.coalition .. "| point: x=" .. csarMissionTable.point.x .. ", y=" .. csarMissionTable.point.y .. ", z=" .. csarMissionTable.point.z .. "| name: " .. csarMissionTable.name, false)
    local csarGroupName = DF_UTILS.spawnGroupWide("SOS-".. csarMissionTable.coalition, csarMissionTable.point,"clone",2, anyTerrain, csarMissionTable.terrainLimit , csarMissionTable.name)
    if not csarGroupName then return false end
    csarMissionTable.groupName = csarGroupName
    env.info("csarGroupName = " .. csarGroupName,false)
    if not csarMissionTable.radioSilence then
        env.info("TCN - coalition: " .. csarMissionTable.coalition .. "| point: x=" .. csarMissionTable.gearPoint.x .. ", y=" .. csarMissionTable.gearPoint.y .. ", z=" .. csarMissionTable.gearPoint.z .. "| name: " .. csarMissionTable.name, false)
        local csarGearGroupName = DF_UTILS.spawnGroupWide("TCN-".. csarMissionTable.coalition, csarMissionTable.gearPoint,"clone",2, anyTerrain, csarMissionTable.terrainLimit , csarMissionTable.name .. "-TCN")
        if not csarGearGroupName then return false end
        csarMissionTable.equipment = csarGearGroupName
        env.info("csarGearGroupName = " .. csarGearGroupName,false)
        if not csarMissionTable.freq then
            local ndbFreq = CSB.getClearFreq(csarMissionTable.coalition, "NDB", CSARFreqs[csarMissionTable.coalition]["NDB"][1], CSARFreqs[csarMissionTable.coalition]["NDB"][2])
            csarMissionTable.freq = ndbFreq
        end
        if not csarMissionTable.channel then
            csarMissionTable.channel = CSB.getClearFreq(csarMissionTable.coalition, "TACAN", CSARFreqs[csarMissionTable.coalition]["TACAN"][1],CSARFreqs[csarMissionTable.coalition]["TACAN"][2])
        end
        if csarMissionTable.freq == 0 or csarMissionTable.channel == 0 then return false end
        local args = {}
        args.groupName = csarGroupName
        args.freq = csarMissionTable.freq
        args.channel = csarMissionTable.channel
        args.amfm = csarMissionTable.modulation
        args.soundFile = "l10n/DEFAULT/dah2.ogg"
        args.equipment = csarGearGroupName
        timer.scheduleFunction(CSB.startTransmission, args, timer.getTime() + math.random(10,20))
    end
    return true
end
function CSB.getClearFreq(coalitionId,freqType,min,max)
    local freq = 0
    local breakVar = true
    for j=1,50 do
        freq = math.random(min,max)
        for _,v in pairs(CSARFreqCollisions[coalitionId][freqType]) do
            if freq == v then
                breakVar = false
                break
            end
            breakVar = true
        end
        if breakVar then
            for _,v in pairs(csarMissions[coalitionId]) do
                if freqType == "NDB" then
                    if freq == v.freq then
                        breakVar = false
                        break
                    end
                else
                    if freq == v.channel then
                        breakVar = false
                        break
                    end
                end
                breakVar = true
            end
        end
        if breakVar then break end
        if j==50 then
            env.info("Could not find a clear frequency for new CSAR",false)
            return 0
        end
    end
    return freq
end
function CSB.addCsarRadioMenuToGroup(groupID, groupName, coalitionId)
    local csarSubMenu = missionCommands.addSubMenuForGroup(groupID, "CSAR", {})
    missionCommands.addCommandForGroup(groupID,"Show Active Rescues", csarSubMenu, CSB.showRescueList, {groupID = groupID, groupName = groupName, coalitionId = coalitionId})
end
function CSB.removeCsarRadioCommandsForGroup(groupID)
    missionCommands.removeItemForGroup(groupID, {[1] = "CSAR"})
end
function CSB.showRescueList(args)
    local playerGroup = Group.getByName(args.groupName)
    if not (playerGroup and playerGroup:isExist()) then return end
    local playerUnit = playerGroup:getUnit(1)
    if not (playerUnit and playerUnit:isExist()) then return end
    local playerPos = playerUnit:getPoint()
    local rescueList = {}
    for _,m in pairs(csarMissions[args.coalitionId]) do
        table.insert(rescueList, m)
        local r = Utils.PointDistance(playerPos, rescueList[#rescueList].point)
        r = math.floor(r/10)/100
        rescueList[#rescueList].range = r
    end
    local outString = " --- Open Evac Requests --- \n"
    if #rescueList == 0 then
        outString = outString .. "\nAll personnel accounted for.\n"
        outString = outString .. "\n\nCheck-in at the CSAR stack(s) for new tasking.\n"
    else
        local rescueCount = #rescueList
        local rescueOverflow = 0
        local checkTime = timer.getTime()
        local currentState = "GREEN ++ Safe ++ "
        table.sort(rescueList, function (r1,r2) return r1.range < r2.range end)
        if rescueCount > csarMaxDisplayed then
            rescueOverflow = rescueCount - csarMaxDisplayed
            rescueCount = csarMaxDisplayed
        end
        for j=1,rescueCount do
            local rescue = rescueList[j]
            if rescue.expires then
                local t = (rescue.startTime + rescue.expires) - checkTime
                if t < csarTimeLimitMin * 0.25 then
                    currentState = "RED __ Dire __ "
                elseif t < csarTimeLimitMin * 0.5 then
                    currentState = "ORANGE -- Worsening -- "
                end
            end
            local nearestBase, dist, dir = CSB.closestBaseTo(rescue.point)
            outString = outString .. "\n -> " .. rescue.displayName .. " | NDB/TACAN: " .. rescue.freq * 10 .. "kHz/" .. rescue.channel .. "X | " .. currentState .. " | LastKnown: apprx " .. dist .. "km " .. dir .. " of " .. nearestBase
        end
        if rescueOverflow > 0 then
            outString = outString .. "\nPlus " .. rescueOverflow .. " distant signals..."
        end
    end
    trigger.action.outTextForGroup(args.groupID, outString, 30, false)
end
function CSB.closestBaseTo(p)
    local closestBaseObj = nil
    local closestBaseName = nil
    local closestBaseDist = math.huge
    local csarX = p.x
    local csarZ = p.z
    for n,o in pairs(activeAirbases) do
        local xDiff = csarX - o.pos.x
        local zDiff = csarZ - o.pos.z
        local dist = (xDiff^2 + zDiff^2)^0.5
        if dist < closestBaseDist then
            closestBaseDist = dist
            closestBaseName = n
            closestBaseObj = o.pos
        end
    end
    local direction = Utils.relativeCompassBearing(p,closestBaseObj)
    closestBaseDist = math.floor((closestBaseDist/1000)+0.5)
    return closestBaseName, closestBaseDist, direction
end
function CSB.wellnessCheck(coalitionId)
    local safeAsHouses = {}
    local checkTime = timer.getTime()
    local opposition = 2
    if coalitionId == 2 then opposition = 1 end
    for _,m in pairs(csarMissions[coalitionId]) do
        if not m.skipWellness then
            local timeLeft = true
            local isAlive = true
            if m.expires then timeLeft = (m.startTime + m.expires) > checkTime end
            local rescueGroup = Group.getByName(m.groupName)
            if not (rescueGroup and rescueGroup:isExist()) then isAlive = false end
            if isAlive and timeLeft then
                table.insert(safeAsHouses,m)
            else
                trigger.action.outTextForCoalition(coalitionId, "!!! " .. m.displayName .. "'s transponder is no longer active...",20,false)
                if Recon and math.random() < 0.02 then
                    local msns = Recon.getCurrentMissionsByCoalition(opposition)
                    local locmsns = {}
                    if msns then
                        for k,v in pairs(msns) do
                            if v.type == 2 then table.insert(locmsns,k) end
                        end
                        if #locmsns > 0 then
                            local msnId = locmsns[math.random(#locmsns)]
                            local nearestBase, dist, dir = CSB.closestBaseTo(msns[msnId].point)
                            Recon.processCompletedMission(opposition,msnId,nil,"enemy interrogation")
                            trigger.action.outTextForCoalition(opposition,"Interrogation of enemy pilot has revealed enemy positions " .. dist .. "km " .. dir .. " of " .. nearestBase, 10, false)
                        end
                    end
                elseif DFS and math.random() < 0.33 then
                    DFS.IncreaseFrontSupply({coalitionId = opposition, amount = 1, type = DFS.supplyType.EQUIPMENT})
                end
                CSB.cleanupCsarGroup(m)
            end
        else
            m.skipWellness = nil
            table.insert(safeAsHouses,m)
        end
    end
    csarMissions[coalitionId] = safeAsHouses
end
function CSB.trackCsar()
    timer.scheduleFunction(CSB.trackCsar, nil, timer:getTime() + trackCsarInterval)
    for c = 1, 2 do
        local playerActive = false
        local playerUnit = nil
        local didYouEvenLift = false
        CSB.wellnessCheck(c)
        for k,v in pairs(csarCheckIns[c]) do
            local currentPlayers = coalition.getPlayers(c)
            for j = 1, #currentPlayers do
                if k == Unit.getPlayerName(currentPlayers[j]) then
                    playerActive = true
                    playerUnit = currentPlayers[j]
                end
            end
            if playerActive and playerUnit and DFS.heloCapacities[playerUnit:getTypeName()] then
                local playerPos = playerUnit:getPoint()
                local playerAgl = Utils.getAGL(playerPos)
                local playerHdg = Utils.getHdgFromPosition(playerUnit:getPosition())
                local playerTypeName = playerUnit:getTypeName()
                local playerName = playerUnit:getPlayerName()
                local pUnitName = playerUnit:getName()
                local pVelo = playerUnit:getVelocity()
                local inSafeVeloParams = CSB.checkVelocity(pVelo,1.5)
                v.typeName = playerTypeName -- keep it current in case relevant for weight/volume
                local noRoomAtInn = false
                local transporterTable = DFS.helos[v.groupName]
                local skipRest = false
                if transporterTable then
                    if transporterTable.cargo.volumeUsed + csarTroopVol > DFS.heloCapacities[playerTypeName].volume then noRoomAtInn = true end
                else
                    env.info("[CSARBot] transporterTable was nil for " .. playerName, false)
                    skipRest = true
                end
                if not skipRest then
                    for _,m in pairs(csarMissions[c]) do
                        if not m.skipWellness then
                            local dist = Utils.PointDistance(playerPos, m.point)
                            local clockBearing = Utils.relativeClockBearing(playerPos, m.point, playerHdg)
                            if dist < csarBreakCoverRange then
                                local pContacted = false
                                for _,h in pairs(m.contacts) do
                                    if h == pUnitName then
                                        pContacted = true
                                        break
                                    end
                                end
                                if not pContacted and not m.radioSilence then
                                    -- they do want this smoke
                                    local smokeColor = smokeColors[m.smokeNum]
                                    trigger.action.outTextForGroup(v.groupID, "This is " .. m.displayName .. ", have eyes on - popping " .. smokeColor .. " smoke to your " .. clockBearing .. " o'clock.", 30, false)
                                    table.insert(m.contacts, pUnitName)
                                    if DFS and DFS.smokeGroup then DFS.smokeGroup(m.groupName, m.smokeNum) end
                                    if cb and cb.flareGroup then cb.flareGroup(m.groupName) end
                                    m.smokeTime = timer.getTime()
                                else
                                    -- too long
                                    if (timer.getTime() - m.smokeTime > 300) and not m.radioSilence then
                                        local smokeColor = smokeColors[m.smokeNum]
                                        trigger.action.outTextForGroup(v.groupID, "This is " .. m.displayName .. ", popping fresh " .. smokeColor .. " smoke to your " .. clockBearing .. " o'clock.", 30, false)
                                        if DFS and DFS.smokeGroup then DFS.smokeGroup(m.groupName, m.smokeNum) end
                                        if cb and cb.flareGroup then cb.flareGroup(m.groupName) end
                                        m.smokeTime = timer.getTime()
                                    end
                                    if dist < csarBreakCoverRange * 0.5 then
                                        local nicedist = math.floor(dist * 10)/10
                                        local outText = nil
                                        if noRoomAtInn then
                                            outText = "The airframe is at it's volume limit. Extraction not possible."
                                        else
                                            if playerTypeName ~= "AV8BNA" and playerTypeName ~= "Yak-52" then
                                                outText = "Winch Op: " .. m.displayName .. " approx. " .. nicedist .. "m to your " .. clockBearing .. " o'clock."
                                                -- hover pick-up check
                                                if dist < csarHoverRadius then
                                                    if playerAgl <= csarHoverAgl and playerAgl > 3 then
                                                        if inSafeVeloParams then
                                                            local hoverTime = m.winchers[pUnitName]
                                                            if not hoverTime then
                                                                hoverTime = timer.getTime()
                                                                m.winchers[pUnitName] = timer.getTime()
                                                            end
                                                            hoverTime = timer.getTime() - hoverTime
                                                            local countdown = math.floor(csarHoverTime - hoverTime)
                                                            outText = "Winch Op: " .. nicedist .. "m to your " .. clockBearing .. " o'clock. Package inbound...(" .. countdown .. "s)"
                                                            if hoverTime > csarHoverTime then
                                                                outText = "Winch Op: Package secured. " .. m.name .. " ready for RTB."
                                                                table.insert(v.onBoard,m)
                                                                CSB.cleanupCsarGroup(m)
                                                                m.status = 1
                                                                didYouEvenLift = true
                                                                transporterTable.addedMass = transporterTable.addedMass + csarTroopMass
                                                                transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed + csarTroopVol
                                                                trigger.action.setUnitInternalCargo(pUnitName, transporterTable.addedMass)
                                                            end
                                                        else
                                                            outText = "Winch Op: We're drifting, need to lock in...package is " .. nicedist .. "m to your " .. clockBearing .. " o'clock."
                                                        end
                                                    else
                                                        if playerAgl > csarHoverAgl then
                                                            outText = "Winch Op: " .. m.displayName .. " approx. " .. nicedist .. "m to your " .. clockBearing .. " o'clock - land, or descend to below " .. csarHoverAgl .. "m AGL for winching."
                                                        elseif playerUnit:inAir() == false then -- could be on ground but was too fast when landing event was processed
                                                            CSB.checkCsarLanding(playerUnit)
                                                        end
                                                        m.winchers[pUnitName] = nil
                                                    end
                                                else
                                                    m.winchers[pUnitName] = nil
                                                end
                                                trigger.action.outTextForGroup(v.groupID, outText, 30 , true)
                                                outText = nil
                                            end
                                        end
                                        if outText then trigger.action.outTextForGroup(v.groupID, outText, 30 , false) end
                                    else
                                        m.winchers[pUnitName] = nil
                                    end
                                end
                            end
                        end
                    end -- end of csar rescues for loop
                end
            else
                -- player no longer CSAR-viable, check-out
                csarCheckIns[c][k] = nil
            end
        end -- end of csar check-ins for loop
        if didYouEvenLift then
            local leanedOut = {}
            for _,m in pairs(csarMissions[c]) do
                if m.status == 0 then
                    table.insert(leanedOut,m)
                end
            end
            csarMissions[c] = leanedOut
        end
    end --end of coalition for loop
end
function CSB.refreshCsarTransmissions()
    timer.scheduleFunction(CSB.refreshCsarTransmissions,nil,timer.getTime()+300)
    for n=1,2 do
        for _,m in pairs(csarMissions[n]) do
            if not m.radioSilence then
                local args = {}
                local cmd = {}
                local targetGroup = Group.getByName(m.groupName)
                if targetGroup and targetGroup:isExist() then
                    args.groupName = m.groupName
                    args.freq = m.freq
                    args.channel = m.channel
                    args.amfm = m.modulation
                    args.soundfile = "l10n/DEFAULT/dah2.ogg"
                    args.equipment = m.equipment
                    local aiCtrllr = targetGroup:getController()
                    if aiCtrllr and aiCtrllr.setCommand then
                        cmd.params = {}
                        cmd.id = "StopTransmission"
                        aiCtrllr:setCommand(cmd)
                        env.info("[CSB.refreshCsarTransmissions] - Stopping ".. m.freq*10000 .."kHz transmission by ".. args.groupName, false)
                    end
                    targetGroup = Group.getByName(args.equipment)
                    if targetGroup and targetGroup:isExist() then
                        local eqCtrllr = targetGroup:getController()
                        if eqCtrllr and eqCtrllr.setCommand then
                            cmd = {}
                            cmd.params = {}
                            cmd.id = "DeactivateBeacon"
                            eqCtrllr:setCommand(cmd)
                            env.info("[CSB.refreshCsarTransmissions] - Stopping ".. m.channel .."X TACAN beacon of ".. args.equipment, false)
                        end
                    end
                    timer.scheduleFunction(CSB.startTransmission,args,timer.getTime()+math.random(5))
                end
            end
        end
    end
end
function CSB.startTransmission(args)
    local targetGroup = Group.getByName(args.groupName)
    local ndbFreq = args.freq
    local tcnChn = args.channel
    local modulation = args.amfm
    local soundFile = args.soundFile
    local eq = args.equipment
    env.info("[CSB.startTransmission] - about to test group: " .. args.groupName .. "...",false)
    if targetGroup == nil or targetGroup:getSize() == 0 then return end
    local u = targetGroup:getUnit(1)
    env.info("[CSB.startTransmission] - about to test for unit...",false)
    if u == nil or not u:isExist() then return end
    local aiCtrllr = targetGroup:getController()
    local eqCtrllr = nil
    if eq then
        targetGroup = Group.getByName(eq)
        if targetGroup and targetGroup:isExist() then
            eqCtrllr = targetGroup:getController()
        end
    end
    local cmd = {}
    if aiCtrllr and aiCtrllr.setCommand then
        env.info("[CSB.startTransmission] - about to set frequency to: " .. tostring(ndbFreq*10000) .. "...",false)
        cmd.id = "SetFrequency"
        cmd.params = {}
        cmd.params.frequency = ndbFreq * 10000
        cmd.params.modulation = modulation
        cmd.params.power = 50
        aiCtrllr:setCommand(cmd)
        cmd = {}
        cmd.id = "TransmitMessage"
        cmd.params = {}
        cmd.params.loop = true
        cmd.params.file = soundFile
        aiCtrllr:setCommand(cmd)
        env.info("[CSB.startTransmission] - TransmitMessage command sent...",false)
    else
        env.info("[CSB.startTransmission] - controller for CSAR unit is not functional.",false)
    end
    if eqCtrllr and eqCtrllr.setCommand then
        local chAdj = 64
        local baseFreq = 1151
        if tcnChn < 64 then
            chAdj = 1
            baseFreq = 962
        end
        cmd = {}
        cmd.id = "ActivateBeacon"
        cmd.params = {}
        cmd.params.type = 4
        cmd.params.system = 18
        cmd.params.bearing = true
        cmd.params.callsign = "SOS"
        cmd.params.frequency = (baseFreq + tcnChn - chAdj) * 1000000
        cmd.params.channel = tcnChn
        eqCtrllr:setCommand(cmd)
    else
        env.info("[CSB.startTransmission] - controller for CSAR TACAN unit is not functional.",false)
    end
end
function CSB:onEvent(e)
    if not e.initiator then return end
    local evtInitr = e.initiator
    local evtId = e.id
    local isCsarUnit = false
    local playerName = nil
    --//BIRTH EVENT
    if evtId == 15 and evtInitr and evtInitr.getPlayerName then
        local pName = evtInitr:getPlayerName()
        if pName then
            local pSide = evtInitr:getCoalition()
            if csarCheckIns[pSide][pName] then
                env.info("[CSAR] Checked-out " .. pName .. " on new spawn",false)
                csarCheckIns[pSide][pName] = nil
            end
        end
    end
    --//EJECTION EVENTS
    if evtId == 6 and evtInitr and evtInitr.getGroup then -- eject
        local group = evtInitr:getGroup()
        if group then
            local groupName = group:getName()
            if groupName and string.find(groupName, "RACER") then return end
        end
        local c = evtInitr:getCoalition()
        if evtInitr.getPlayerName and evtInitr:getPlayerName() then playerName = evtInitr:getPlayerName() end
        local isOverWater = false
        if e.target then evtInitr = e.target end
        if evtInitr.Desc then mist.utils.oneLineSerialize(evtInitr.Desc) end
        if evtInitr.getPoint then
            local p = evtInitr:getPoint()
            p.y = p.z
            local terrtype = land.getSurfaceType(p)
            if terrtype == 2 or terrtype == 3 then isOverWater = true end
            CSB.wrappedGenerateCsar(evtInitr,c,isOverWater,playerName)
        end
    end
    if evtId == 33 then -- discard chair
        local args = {inUnit = e.target}
        timer.scheduleFunction(CSB.cleanUpPilot,args,timer.getTime()+5)
    end
    if evtId == 31 then -- pilot landed without being cleaned up somehow
        if evtInitr.Desc then mist.utils.oneLineSerialize(evtInitr.Desc) end
        local args = {inUnit = evtInitr}
        timer.scheduleFunction(CSB.cleanUpPilot,args,timer.getTime()+5)
    end
    --//CSAR-CAPABLE INITIATOR EVENTS
    isCsarUnit = evtInitr and Unit.isExist(evtInitr) and evtInitr.getPlayerName and evtInitr:getPlayerName() and DFS.heloCapacities[evtInitr:getTypeName()]
    if isCsarUnit then
        if evtId == 4 then -- Landing
            CSB.checkCsarLanding(evtInitr)
        end
        if evtId == 5 then --crash
            CSB.checkCsarCrash(evtInitr)
        end
    end
end
function CSB.checkCsarCrash(eUnit)
    if eUnit and eUnit:isExist() and eUnit.getPlayerName then
        -- unit probably doesn't have a group any more
        local pName = eUnit:getPlayerName()
        local pSide = eUnit:getCoalition()
        if csarCheckIns[pSide][pName] then
            csarCheckIns[pSide][pName] = nil
        end
    end
end
function CSB.checkCsarLanding(eUnit)
    if eUnit and eUnit:isExist() and eUnit.getPlayerName then
        local pName = eUnit:getPlayerName()
        local pSide = eUnit:getCoalition()
        local pPosn = eUnit:getPoint()
        local pVelo = eUnit:getVelocity()
        local pType = eUnit:getTypeName()
        local inSafeVeloParams = CSB.checkVelocity(pVelo)
        local bInCsarBase = false
        local sBaseName = "Nowhere"
        if csarCheckIns[pSide][pName] then
            local zonePoint = nil
            local csci = csarCheckIns[pSide][pName]
            local transporterTable = DFS.helos[csci.groupName]
            for j = 1, #CSARBases[pSide] do
                zonePoint = trigger.misc.getZone(CSARBases[pSide][j])
                if zonePoint then
                    if Utils.pointInCircleTriggerZone(pPosn, zonePoint) then
                        bInCsarBase = true
                        sBaseName = CSARBases[pSide][j]
                        break
                    end
                end
            end
            if bInCsarBase and #csci.onBoard > 0 then -- check for drop off
                if not inSafeVeloParams then
                    trigger.action.outTextForGroup(csci.groupID, "Travelling too fast for safe drop-off.", 30, false)
                else
                    for _,m in pairs(csci.onBoard) do
                        trigger.action.outTextForCoalition(pSide, pName .. " safely delivered " .. m.displayName .. " to " .. sBaseName .. ".", 30, false)
                        if DFS then DFS.IncreaseFrontSupply({coalitionId = pSide, amount = 1, type = DFS.supplyType.EQUIPMENT}) end
                        if WWEvents then WWEvents.playerCsarMissionCompleted(pName, pSide, sBaseName," rescued ".. m.displayName .. " from the battlefield.") end
                    end
                    if transporterTable then
                        transporterTable.addedMass = transporterTable.addedMass - (#csci.onBoard * csarTroopMass)
                        transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed - (#csci.onBoard * csarTroopVol)
                        trigger.action.setUnitInternalCargo(csci.unitName, transporterTable.addedMass)
                    end
                    csci.onBoard = {}
                end
            else -- check for pickup
                for _,m in pairs(csarMissions[pSide]) do
                    if Utils.PointDistance(pPosn, m.point) < csarPickupRadius then
                        if inSafeVeloParams then
                            if transporterTable and transporterTable.cargo.volumeUsed + csarTroopVol > DFS.heloCapacities[pType].volume then
                                trigger.action.outTextForGroup(csci.groupID, "The airframe is at it's volume limit. Extraction of " .. m.displayName .. "not possible.", 30, false)
                                break
                            else
                                trigger.action.outTextForCoalition(pSide, pName .. " is attempting to extract " .. m.displayName .. "...", 30, false)
                                local args = {}
                                args.pName = pName
                                args.pSide = pSide
                                args.groupName = m.groupName
                                args.fName = m.name
                                args.equipment = m.equipment
                                args.pGrId = csci.groupID
                                args.pGrNm = csci.groupName
                                args.pUnit = eUnit
                                args.mission = m
                                args.displayName = m.displayName
                                timer.scheduleFunction(CSB.fakeExtractionTime, args, timer.getTime() + math.random(3,6))
                            end
                        else
                            trigger.action.outTextForGroup(csci.groupID, "Travelling too fast for safe pickup.", 30, false)
                        end
                    end
                end
            end
        end
    end
end
function CSB.fakeExtractionTime(args)
    local playerGroupID = args.pGrId
    local playerUnit = args.pUnit
    local transporterTable = DFS.helos[args.pGrNm]
    if playerUnit and playerUnit:isExist() and playerUnit.getPlayerName then
        local pVelo = playerUnit:getVelocity()
        local pUnitName = playerUnit:getName()
        local inSafeVeloParams = CSB.checkVelocity(pVelo)
        if inSafeVeloParams then
            table.insert(csarCheckIns[args.pSide][args.pName].onBoard, args.mission)
            if transporterTable then
                transporterTable.addedMass = transporterTable.addedMass + csarTroopMass
                transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed + csarTroopVol
                trigger.action.setUnitInternalCargo(pUnitName, transporterTable.addedMass)
            end
            CSB.cleanupCsarGroup(args)
            local filtered = {}
            for _,m in pairs(csarMissions[args.pSide]) do
                if m ~= args.mission then
                    table.insert(filtered, m)
                end
            end
            csarMissions[args.pSide] = filtered
            trigger.action.outTextForCoalition(args.pSide, args.pName .. " has taken " .. args.displayName .. " on board.", 30, true)
        else
            trigger.action.outTextForGroup(playerGroupID, "Travelling too fast for safe pickup.", 30, false)
        end
    end
end
function CSB.cleanupCsarGroup(csarData)
    local targetGroup = Group.getByName(csarData.groupName)
    if targetGroup and targetGroup:isExist() then Group.destroy(targetGroup) end
    if csarData.equipment ~= nil then
        local eq = Group.getByName(csarData.equipment)
        if eq and eq:isExist() then Group.destroy(eq) end
    end
end
function CSB.checkVelocity(pVelo,limit)
    local vLimit = limit or 0.5
    if vLimit <= 0 then vLimit = 0.5 end
    local xInParam = math.abs(pVelo.x) < vLimit
    local yInParam = math.abs(pVelo.y) < vLimit
    local zInParam = math.abs(pVelo.z) < vLimit
    return xInParam and yInParam and zInParam
end
function CSB.buildMissionAirbaseList()
    local missionAirbases = world.getAirbases()
    for _,base in pairs(missionAirbases) do
        local baseType = base:getDesc().category
        local baseName = base:getName()
        if baseType == 0 or baseType == 1 then
            activeAirbases[baseName] = {}
            activeAirbases[baseName].pos = base:getPoint()
            activeAirbases[baseName].side = base:getCoalition()
        end
    end
end
function CSB.cleanUpPilot(args)
    local pilot = args.inUnit
    if pilot and pilot:isExist() then Object.destroy(pilot) end
end
function CSB.debugCsarGeneration()
    timer.scheduleFunction(CSB.debugCsarGeneration,nil,timer.getTime()+10)
    for i=1,2 do
        if #csarMissions[i] < 2 then
            CSB.generateCsar(nil,i,nil,nil,nil,nil,{480,720},nil,false)
        end
    end
end
world.addEventHandler(CSB)
CSB.load()