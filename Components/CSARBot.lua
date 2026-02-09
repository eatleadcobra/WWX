-- Created by combining CasBot.lua from WWXOS (https://github.com/eatleadcobra/WWX) by EatLeadCobra with
-- autoCSAR.lua and csarManager2.lua from the DML package (https://github.com/csofranz/DML) by cfrag
CSB = {}
local csb = {}
local autoCsarEnroll = {}
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
local csarMaxDisplayed = 4
local csarTroopMass = 130
local csarTroopVol = 4
local csarAutoProcRadius = 3000
local csarEjectedRadius = 1000
local csarSignalPower = 5
local csarOnBoardDefaultEndurance = 900
local csarRescueDecayRate = 1.0
local csarCheckThreshold = 20
local csarSoundFile = "l10n/DEFAULT/dah2.ogg"
local trackCasEvacInterval = 20
local casEvacRadius = 25
local casEvacInnerRadius = 6
local casEvacAlertRange = 1500
local casEvacTimePer = 480
local casEvacSignalPower = 10
local casEvacSoundFile = "l10n/DEFAULT/dah2.ogg"
local genCsarCounter = 25
local genCasEvacCounter = 420
local hotLZdist = 4

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
local casEvacMissions = {
    [1] = {},
    [2] = {}
}

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
                    local params = {}
                    params.coalitionId = playerCoalition
                    params.playerName = foundPlayerName
                    params.playerGroupID = playerGroupID
                    params.playerGroupName = playerGroupName
                    params.typeName = playerTypeName
                    params.unitName = playerUnitName
                    csb.csarAutoCheckIn(params)
                end
            end
        end
    end
end
function csb.load()
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
    csb.buildMissionAirbaseList()
    csb.main()
    for c = 1, 2 do
        for z = 1, #CSARBases[c] do
            DrawingTools.drawHealth(trigger.misc.getZone(CSARBases[c][z]).point, c, 500)
        end
    end
end
function csb.main()
    if CSARAUTOENROLL then
        world.addEventHandler(autoCsarEnroll)
    end
    csb.searchCsarStacks()
    csb.trackCsar()
    csb.trackCasEvac()
    csb.refreshCsarTransmissions()
    csb.refreshCasEvacTransmissions()
    --timer.scheduleFunction(csb.debugCsarGeneration,nil,timer.getTime()+20)
    --timer.scheduleFunction(csb.debugCasEvacGeneration,nil,timer.getTime()+22)
end
function csb.searchCsarStacks()
    timer.scheduleFunction(csb.searchCsarStacks, nil, timer:getTime() + searchStackInterval)
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
        if genCsarFlag and genCsarCoalition ~= 0 then
            local csarParams = {}
            csarParams.coalitionId = genCsarCoalition
            csarParams.radioSilence = false
            csarParams.hotLZ = false
            csarParams.source = "csarStack"
            CSB.generateCsar(csarParams)
        end
        for k,v in pairs(currentLists[c]) do
            if previousLists[c][k] then
                local params = {}
                params.coalitionId = v.coalition
                params.playerName = v.name
                params.playerGroupID = v.groupID
                params.playerGroupName = v.groupName
                params.typeName = v.typeName
                params.unitName = v.unitName
                CSB.csarCheckIn(params)
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
function CSB.csarCheckIn(params)
    local coalitionId = params.coalitionId
    local playerName = params.playerName
    local playerGroupID = params.playerGroupID
    local playerGroupName = params.playerGroupName
    local typeName = params.typeName
    local unitName = params.unitName
    local prev = params.prev
    if not prev then prev = false end
    if not csarCheckIns[coalitionId][playerName] then
        csarCheckIns[coalitionId][playerName] = {groupID = playerGroupID, groupName = playerGroupName, typeName = typeName, unitName = unitName, onBoard = {}}
    end
    if #csarMissions[coalitionId] < 1 then
        local csarParams = {}
        csarParams.coalitionId = coalitionId
        csarParams.radioSilence = false
        csarParams.hotLZ = false
        csarParams.source = "csarStack"
        CSB.generateCsar(csarParams)
    end
    if not prev then
        CSB.addCsarRadioMenuToGroup(playerGroupID, playerGroupName, coalitionId)
    end
    trigger.action.outTextForGroup(playerGroupID,"Checked-in. Check CSAR menu for active rescues.",30,false)
end
function csb.csarAutoCheckIn(params)
    local coalitionId = params.coalitionId
    local playerName = params.playerName
    local playerGroupID = params.playerGroupID
    local playerGroupName = params.playerGroupName
    local typeName = params.typeName
    local unitName = params.unitName
    if not csarCheckIns[coalitionId][playerName] then
        csarCheckIns[coalitionId][playerName] = {groupID = playerGroupID, groupName = playerGroupName, typeName = typeName, unitName = unitName, onBoard = {}}
        CSB.addCsarRadioMenuToGroup(playerGroupID, playerGroupName, coalitionId)
        trigger.action.outTextForGroup(playerGroupID,"Checked-in. Check CSAR menu for active rescues.",30,false)
    end
end
function csb.isCloseToAirbase(p1,opposition)
    for abName,abInfo in pairs(activeAirbases) do
        local p2 = {x = abInfo.pos.x, y = 0, z = abInfo.pos.z}
        local dist = Utils.PointDistance(p1,p2)
        local enemyBase = false
        if dist < csarAutoProcRadius then
            if abInfo.side == opposition then enemyBase = true end
            return true,abName,abInfo.side,enemyBase
        end
    end
    return false,nil,0,false
end
function csb.wrappedGenerateCsar(params)
    -- check for ejection onto base for auto collection
    local coalitionId = params.coalitionId
    local inUnit = params.inUnit
    local overWater = params.overWater
    local playerName = params.playerName
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
    isCloseToBase,airbaseName,airbaseSide,enemyBase = csb.isCloseToAirbase(p1,opposition)
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
                    if #locmsns > 0 then
                        local msnId = locmsns[math.random(#locmsns)]
                        if msnId then
                            local nearestBase, dist, dir = csb.closestBaseTo(msns[msnId].point)
                            Recon.processCompletedMission(opposition,msnId,nil,"enemy interrogation")
                            trigger.action.outTextForCoalition(opposition,"Interrogation of enemy pilot has revealed enemy positions " .. dist .. "km " .. dir .. " of " .. nearestBase, 10, false)
                        end
                    end
                end
            elseif DFS and math.random() < 0.33 then
                DFS.IncreaseFrontSupply({coalitionId = opposition, amount = 1, type = DFS.supplyType.EQUIPMENT})
                trigger.action.outTextForCoalition(coalitionId,"Intel reports that parts of a lost friendly aircraft have been recovered by the enemy.", 10, false)
            end
        else
            trigger.action.outTextForCoalition(coalitionId, "Pilot" .. pilotStr .. " bailed out and landed close to friendly airbase at " .. airbaseName .. " and was picked up.",20,false)
        end
        return
    end
    local hotLZ = csb.checkLZ(pos,coalitionId)
    local anyTerrain = nil
    pos = {x = pos.x, y = pos.y-agl, z = pos.z}
    if overWater then
        anyTerrain = true
    end
    local csarParams = {}
    csarParams.csarPoint = pos
    csarParams.coalitionId = coalitionId
    csarParams.csarRadius = csarEjectedRadius
    csarParams.anyTerrain = anyTerrain
    csarParams.playerName = playerName
    csarParams.radioSilence = false
    csarParams.hotLZ = hotLZ
    csarParams.source = "ejected"
    timer.scheduleFunction(CSB.generateCsar,csarParams,timer.getTime()+math.random(8,15))
end
function CSB.generateCsar(params)
    local csarPoint = params.csarPoint
    local coalitionId = params.coalitionId
    local freq = params.freq
    local channel = params.channel
    local csarRadius = params.csarRadius
    local csarMinRadius = params.csarMinRadius
    local anyTerrain = params.anyTerrain
    local timeLimit = params.timeLimit
    local playerName = params.playerName
    local radioSilence = params.radioSilence
    local hotLZ = params.hotLZ
    local source = params.source
    local sourceId = params.sourceId
    local fName = ""
    local smokeNum = math.random(0,4)
    local generatedCsar = {}
    local genPoint = nil
    local checkLZ = false
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
    if not csarPoint then
        checkLZ = true
        csarPoint = csarPoints[coalitionId]
    end
    env.info("in generateCsar with args :--- coalitionId: " .. coalitionId .. " csarPoint: x=" .. csarPoint.x .. ", y=" .. csarPoint.y .. ", z=" .. csarPoint.z .. " csarRadius: " .. csarRadius .. " anyTerrain: " .. tostring(anyTerrain), false)
    if not anyTerrain then
        generatedCsar.terrainLimit = {"LAND", "ROAD"}
        for i=1,100 do
            genPoint = Utils.MakeVec3(mist.getRandPointInCircle(csarPoint, csarRadius, csarMinRadius, nil, nil))
            if mist.isTerrainValid(genPoint,generatedCsar.terrainLimit) then break end
        end
    else
        genPoint = Utils.MakeVec3(mist.getRandPointInCircle(csarPoint, csarRadius, csarMinRadius, nil, nil))
    end
    if checkLZ then
        hotLZ = csb.checkLZ(genPoint,coalitionId)
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
    generatedCsar.signalPower = csarSignalPower
    generatedCsar.soundFile = csarSoundFile
    generatedCsar.modulation = 0
    generatedCsar.contacts = {}
    generatedCsar.winchers = {}
    generatedCsar.warned = {}
    generatedCsar.radioSilence = radioSilence
    generatedCsar.hotLZ = hotLZ
    generatedCsar.source = source
    generatedCsar.sourceId = sourceId
    local cloneSourceGroup = Group.getByName("SOS-"..coalitionId)
    if not cloneSourceGroup then
        env.info("Could not find source group for clone", false)
        return
    end
    env.info("about to create new CSAR unit for " .. fName, false)
    local isCreated = csb.createCsarUnit(generatedCsar)
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
        local hotLZStr = ""
        if hotLZ == true then hotLZStr = "\n - !!! HOT LZ !!!" end
        trigger.action.outTextForCoalition(coalitionId, "- " .. generatedCsar.displayName .. " is requesting immediate extraction...\n - holding position for next " .. math.floor(generatedCsar.expires/60) .. " minutes...\n - broadcasting on " .. generatedCsar.freq * 10 .. "kHz/" .. generatedCsar.channel .. "X" .. hotLZStr, 30, false)
    end
end
function csb.createCsarUnit(csarMissionTable)
    local anyTerrain = false
    if not csarMissionTable.terrainLimit then anyTerrain = true end
    env.info("SOS - coalition: " .. csarMissionTable.coalition .. "| point: x=" .. csarMissionTable.point.x .. ", y=" .. csarMissionTable.point.y .. ", z=" .. csarMissionTable.point.z .. "| name: " .. csarMissionTable.name, false)
    local csarGroupName = DF_UTILS.spawnGroupWide("SOS-".. csarMissionTable.coalition, csarMissionTable.point,"clone",2, anyTerrain, csarMissionTable.terrainLimit , csarMissionTable.name)
    if not csarGroupName then return false end
    csarMissionTable.groupName = csarGroupName
    env.info("csarGroupName = " .. csarGroupName,false)
    if csarMissionTable.hotLZ == true then csb.makeRescueInvisible(csarMissionTable.groupName) end
    if not csarMissionTable.radioSilence then
        env.info("TCN - coalition: " .. csarMissionTable.coalition .. "| point: x=" .. csarMissionTable.gearPoint.x .. ", y=" .. csarMissionTable.gearPoint.y .. ", z=" .. csarMissionTable.gearPoint.z .. "| name: " .. csarMissionTable.name, false)
        local csarGearGroupName = DF_UTILS.spawnGroupWide("TCN-".. csarMissionTable.coalition, csarMissionTable.gearPoint,"clone",2, anyTerrain, csarMissionTable.terrainLimit , csarMissionTable.name .. "-TCN")
        if not csarGearGroupName then return false end
        csarMissionTable.equipment = csarGearGroupName
        env.info("csarGearGroupName = " .. csarGearGroupName,false)
        if not csarMissionTable.freq then
            local ndbFreq = csb.getClearFreq(csarMissionTable.coalition, "NDB", CSARFreqs[csarMissionTable.coalition]["NDB"][1], CSARFreqs[csarMissionTable.coalition]["NDB"][2])
            csarMissionTable.freq = ndbFreq
        end
        if not csarMissionTable.channel then
            csarMissionTable.channel = csb.getClearFreq(csarMissionTable.coalition, "TACAN", CSARFreqs[csarMissionTable.coalition]["TACAN"][1],CSARFreqs[csarMissionTable.coalition]["TACAN"][2])
        end
        if csarMissionTable.freq == 0 or csarMissionTable.channel == 0 then return false end
        local args = {}
        args.groupName = csarGroupName
        args.freq = csarMissionTable.freq
        args.channel = csarMissionTable.channel
        args.amfm = csarMissionTable.modulation
        args.soundFile = csarMissionTable.soundFile
        args.equipment = csarGearGroupName
        args.signalPower = csarMissionTable.signalPower
        timer.scheduleFunction(csb.startTransmission, args, timer.getTime() + math.random(10,20))
        if csarMissionTable.hotLZ == true then csb.makeRescueInvisible(csarMissionTable.equipment) end
    end
    return true
end
function csb.getClearFreq(coalitionId,freqType,min,max)
    local freq = 0
    local breakVar = true
    for j=1,100 do
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
        if breakVar then
            for _,v in pairs(casEvacMissions[coalitionId]) do
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
        if j==100 then
            env.info("Could not find a clear frequency for new CSAR",false)
            return 0
        end
    end
    return freq
end
function CSB.addCsarRadioMenuToGroup(groupID, groupName, coalitionId)
    local csarSubMenu = missionCommands.addSubMenuForGroup(groupID, "CSAR", {})
    missionCommands.addCommandForGroup(groupID,"Show Active Rescues", csarSubMenu, CSB.showRescueList, {groupID = groupID, groupName = groupName, coalitionId = coalitionId})
    missionCommands.addSubMenuForGroup(groupID,"Show On-Board List", csarSubMenu)
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
    local outString = " --- Open Evac Requests --- "
    if #rescueList == 0 then
        outString = outString .. "\n\n\t-> All personnel accounted for.\n"
        outString = outString .. "\n\nCheck-in at the CSAR stack(s) for new tasking.\n"
    else
        local rescueCount = #rescueList
        local rescueOverflow = 0
        local checkTime = timer.getTime()
        local currentState = "GRN [====]"
        table.sort(rescueList, function (r1,r2) return r1.range < r2.range end)
        if rescueCount > csarMaxDisplayed then
            rescueOverflow = rescueCount - csarMaxDisplayed
            rescueCount = csarMaxDisplayed
        end
        for j=1,rescueCount do
            local rescue = rescueList[j]
            if rescue.expires then
                local rescueEndTime = rescue.startTime + rescue.expires
                local rescueMaxTime = rescueEndTime - rescue.startTime
                local timeLeft =  rescueEndTime - checkTime
                local t = timeLeft/rescueMaxTime
                if t < 0.25 then
                    currentState = "RED [=<<<]"
                elseif t < 0.5 then
                    currentState = "ORG [==<<]"
                elseif t < 0.75 then
                    currentState = "YLW [===<]"
                end
            end
            local nearestBase, dist, dir = csb.closestBaseTo(rescue.point)
            local nearestBp
            if rescue.source == "casevac" then
                nearestBp, dist, dir = csb.closestBpTo(rescue.point)
            end
            if rescue.hotLZ == true then
                outString = outString .. "\n\n > NAME: (!) "
            else
                outString = outString .. "\n\n > NAME: "
            end
            outString = outString .. rescue.displayName .. "\n STATUS: " .. currentState .. "\n POSTN : apprx " .. dist .. "km " .. dir .. " of "
            if rescue.radioSilence then
                if rescue.source == "casevac" then
                    local ceFreq = 0
                    local ceTcnChn = 0
                    for _,m in pairs(casEvacMissions[args.coalitionId]) do
                        if m.missionId == rescue.sourceId then
                            ceFreq = m.freq
                            ceTcnChn = m.channel
                        end
                    end
                    outString = outString .. "BP-" .. nearestBp .. "\n SOURCE: CASEVAC (#" .. rescue.sourceId ..")"
                    if ceFreq ~= 0 then
                        outString = outString .. "\n SIGNAL: " .. ceFreq * 10 .. "kHz/" .. ceTcnChn .. "X"
                    else
                        outString = outString .. "\n SIGNAL: N/A"
                    end
                else
                    outString = outString .. nearestBase .. "\n SOURCE: " .. string.upper(rescue.source).. "\n SIGNAL: N/A"
                end
            else
                outString = outString .. nearestBase .. "\n SOURCE: " .. string.upper(rescue.source) .. "\n SIGNAL: " .. rescue.freq * 10 .. "kHz/" .. rescue.channel .. "X"
            end
        end
        if rescueOverflow > 0 then
            outString = outString .. "\n\n Plus " .. rescueOverflow .. " distant signals..."
        end
        outString = outString .. "\n\n(!) = Hazardous LZ"
    end
    trigger.action.outTextForGroup(args.groupID, outString, 30, false)
end
function CSB.showOnBoardList(args)
    local playerGroup = Group.getByName(args.groupName)
    if not (playerGroup and playerGroup:isExist()) then return end
    local playerUnit = playerGroup:getUnit(1)
    if not (playerUnit and playerUnit:isExist()) then return end
    local playerName = playerUnit:getPlayerName()
    if not playerName then return end
    local transporterTable = nil
    if DFS and DFS.helos then
        transporterTable = DFS.helos[args.groupName]
    end
    if not transporterTable then return end
    local playerTypeName = playerUnit:getTypeName()
    local rescueCount = #csarCheckIns[args.coalitionId][playerName].onBoard
    local outString = " --- On Board List --- "
    if not (csarCheckIns[args.coalitionId][playerName] and (rescueCount > 0)) then
        outString = outString .. "\n\n\t-> No casualties on board.\n"
        outString = outString .. "\n\nCheck the rescue list for CSAR tasks.\n"
    else
        if DFS.heloCapacities[playerTypeName] then
            local acMaxVol = DFS.heloCapacities[playerTypeName].volume
            local acVolUsed = transporterTable.cargo.volumeUsed
            local csarTroopVolPct = math.floor(((csarTroopVol/acMaxVol) * 100)+0.5)
            outString = outString .. "\n\nCurrent rescue capacity: " .. math.floor((acMaxVol - acVolUsed)/csarTroopVol)
            outString = outString .. "\nCurrent volume remaining: " .. 100 - math.floor(((acVolUsed/acMaxVol)*100)+0.5) .. "%"
            outString = outString .. "\nEach rescue uses " .. csarTroopVolPct .. "% of volume"
        end
        for _,m in pairs(csarCheckIns[args.coalitionId][playerName].onBoard) do
            local statusString = csb.makeOnBoardStatusString(m.pickupTime,m.onBoardTimeRemaining,m.deliveryCutoff)
            outString = outString .. "\n\n > NAME: " .. m.displayName .. "\n\tSTATUS: " .. statusString
        end
    end
    trigger.action.outTextForGroup(args.groupID, outString, 30, false)
end
function csb.makeOnBoardStatusString(pickupTime,onBoardTimeRemaining,deliveryCutoff)
    local remainingPct = math.floor((onBoardTimeRemaining/(deliveryCutoff-pickupTime)*100)+0.5)
    if remainingPct <= 25 then return "RED [=<<<]" end
    if remainingPct <= 50 then return "ORG [==<<]" end
    if remainingPct <= 75 then return "YLW [===<]" end
    return "GRN [====]"
end
function csb.closestBaseTo(p)
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
function csb.closestEnemyBaseTo(p, coalitionId)
    local closestBaseObj = nil
    local closestBaseName = nil
    local closestBaseDist = math.huge
    local csarX = p.x
    local csarZ = p.z
    local opposition = 1
    if coalitionId == 1 then opposition = 2 end
    for n,o in pairs(activeAirbases) do
        if o.side == opposition then
            local xDiff = csarX - o.pos.x
            local zDiff = csarZ - o.pos.z
            local dist = (xDiff^2 + zDiff^2)^0.5
            if dist < closestBaseDist then
                closestBaseDist = dist
                closestBaseName = n
                closestBaseObj = o.pos
            end
        end
    end
    local direction = Utils.relativeCompassBearing(p,closestBaseObj)
    closestBaseDist = math.floor((closestBaseDist/1000)+0.5)
    return closestBaseName, closestBaseDist, direction
end
function csb.wellnessCheck(coalitionId)
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
                if not m.radioSilence then
                    trigger.action.outTextForCoalition(coalitionId, "(!!!)" .. m.displayName .. "'s transponder is no longer active...",20,false)
                end
                if Recon and math.random() < 0.02 then
                    local msns = Recon.getCurrentMissionsByCoalition(opposition)
                    local locmsns = {}
                    if msns then
                        for k,v in pairs(msns) do
                            if v.type == 2 then table.insert(locmsns,k) end
                        end
                        if #locmsns > 0 then
                            local msnId = locmsns[math.random(#locmsns)]
                            if msnId then
                                local nearestBase, dist, dir = csb.closestBaseTo(msns[msnId].point)
                                Recon.processCompletedMission(opposition,msnId,nil,"enemy interrogation")
                                trigger.action.outTextForCoalition(opposition,"Interrogation of enemy pilot has revealed enemy positions " .. dist .. "km " .. dir .. " of " .. nearestBase, 10, false)
                            end
                        end
                    end
                elseif DFS and math.random() < 0.33 then
                    DFS.IncreaseFrontSupply({coalitionId = opposition, amount = 1, type = DFS.supplyType.EQUIPMENT})
                    trigger.action.outTextForCoalition(coalitionId,"Intel reports that parts of a lost friendly aircraft have been recovered by the enemy.", 10, false)
                end
                csb.cleanupCsarGroup(m)
            end
        else
            m.skipWellness = nil
            table.insert(safeAsHouses,m)
        end
    end
    csarMissions[coalitionId] = safeAsHouses
end
function csb.trackCsar()
    timer.scheduleFunction(csb.trackCsar, nil, timer:getTime() + trackCsarInterval)
    for c = 1, 2 do
        local currentPlayers = coalition.getPlayers(c)
        local didYouEvenLift = false
        csb.wellnessCheck(c)
        for k,v in pairs(csarCheckIns[c]) do
            local playerActive = false
            local playerUnit = nil
            for j = 1, #currentPlayers do
                if k == Unit.getPlayerName(currentPlayers[j]) then
                    playerActive = true
                    playerUnit = currentPlayers[j]
                    break
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
                local inSafeVeloParams = csb.checkVelocity(pVelo,1.5)
                v.typeName = playerTypeName -- keep it current in case relevant for weight/volume
                local noRoomAtInn = false
                local transporterTable = DFS.helos[v.groupName]
                local skipRest = false
                if not (playerUnit:inAir() or v.checking) then
                    -- unit may be on ground but was travelling too fast at landing event
                    csb.checkCsarLanding(playerUnit)
                end
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
                                local pWarned = false
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
                                    if CB and CB.flareGroup then CB.flareGroup(m.groupName) end
                                    m.smokeTime = timer.getTime()
                                else
                                    -- too long
                                    if (timer.getTime() - m.smokeTime > 300) and not m.radioSilence then
                                        local smokeColor = smokeColors[m.smokeNum]
                                        trigger.action.outTextForGroup(v.groupID, "This is " .. m.displayName .. ", popping fresh " .. smokeColor .. " smoke to your " .. clockBearing .. " o'clock.", 30, false)
                                        if DFS and DFS.smokeGroup then DFS.smokeGroup(m.groupName, m.smokeNum) end
                                        if CB and CB.flareGroup then CB.flareGroup(m.groupName) end
                                        m.smokeTime = timer.getTime()
                                    end
                                    if dist < csarBreakCoverRange * 0.5 then
                                        local nicedist = math.floor(math.floor((dist*10^-1+0.5))/10^-1)
                                        if nicedist <= 0 then nicedist = 3 end
                                        local outText = nil
                                        local checkTime = timer.getTime()
                                        for i,w in pairs(m.warned) do
                                            if w.name == pUnitName then
                                                pWarned = true
                                                if checkTime - w.warntime > 60 then
                                                    pWarned = false
                                                    m.warned[i] = nil
                                                end
                                            end
                                        end
                                        if noRoomAtInn and (pWarned == false) then
                                            outText = "The airframe is at it's volume limit. Extraction not possible."
                                            table.insert(m.warned, {name = pUnitName, warntime = timer.getTime()})
                                        else
                                            if not noRoomAtInn then
                                                if playerTypeName ~= "AV8BNA" and playerTypeName ~= "Yak-52" then
                                                    if playerUnit:inAir() == true then
                                                        outText = "Winch Op: " .. m.displayName .. " approx. " .. nicedist .. "m to your " .. clockBearing .. " o'clock."
                                                    end
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
                                                                    local pickupTime = timer.getTime()
                                                                    local pickupCutoff = m.startTime + m.expires
                                                                    local pickupStateModifier = -60
                                                                    local pickupState = (pickupCutoff - pickupTime)/m.expires
                                                                    if pickupState <= 0.25 then
                                                                        pickupStateModifier = 180
                                                                    elseif pickupState <= 0.5 then
                                                                        pickupStateModifier = 60
                                                                    elseif pickupState > 0.75 then
                                                                        pickupStateModifier = -180
                                                                    end
                                                                    m.pickupTime = pickupTime
                                                                    m.pickedUpByGroupID = v.groupID
                                                                    m.pickupSeed = (math.random(5000,8000)/10000) - (math.floor(math.fmod(pickupTime,60))/1000)
                                                                    m.onBoardTimeRemaining = csarOnBoardDefaultEndurance - pickupStateModifier
                                                                    m.deliveryCutoff = pickupTime + m.onBoardTimeRemaining
                                                                    m.treatments = {}
                                                                    m.treatments.applied = {}
                                                                    m.treatments.needed = {}
                                                                    m.treatments.needed.lastIssue = pickupTime
                                                                    m.treatments.lastCheck = pickupTime
                                                                    local rescueMenu = missionCommands.addSubMenuForGroup(v.groupID,m.displayName,{[1] = "CSAR",[2] = "Show On-Board List",})
                                                                    local args = {}
                                                                    args.groupID = v.groupID
                                                                    args.displayName = m.displayName
                                                                    args.treatments = m.treatments
                                                                    args.onBoardTimeRemaining = m.onBoardTimeRemaining
                                                                    args.source = m.source
                                                                    args.pickupState = pickupState
                                                                    args.rescueMenu = rescueMenu
                                                                    csb.setInitialMedicalState(args)
                                                                    table.insert(v.onBoard,m)
                                                                    csb.updateMedicalMenuCommands(v.groupID,m.displayName,rescueMenu,m.treatments, m.onBoardTimeRemaining)
                                                                    csb.cleanupCsarGroup(m)
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
                                                                csb.checkCsarLanding(playerUnit)
                                                            end
                                                            m.winchers[pUnitName] = nil
                                                        end
                                                    else
                                                        m.winchers[pUnitName] = nil
                                                    end
                                                    if outText then trigger.action.outTextForGroup(v.groupID, outText, trackCsarInterval , false) end
                                                    outText = nil
                                                end
                                            end
                                        end
                                        if outText then trigger.action.outTextForGroup(v.groupID, outText, 15 , false) end
                                    else
                                        m.winchers[pUnitName] = nil
                                    end
                                end
                            end
                        end
                    end -- end of csar rescues for loop
                    for _,rescue in pairs(v.onBoard) do
                        if rescue.onBoardTimeRemaining > 0 then
                            local dT = csb.getRescueDecayRate(rescue)
                            rescue.onBoardTimeRemaining = rescue.onBoardTimeRemaining - (trackCsarInterval * dT)
                            csb.makePeriodicOBTRMessage(v.groupID,rescue)
                            if rescue.onBoardTimeRemaining <=0 then
                                rescue.onBoardTimeRemaining = 0
                                trigger.action.outTextForGroup(v.groupID,"I'm sorry to inform you that " .. rescue.displayName .. " has succumbed to their injuries...",15,false)
                                if #rescue.treatments.needed > 0 then
                                    rescue.treatments.needed = {}
                                end
                            end
                            csb.updateMedicalState(v.groupID,rescue)
                        end
                    end
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
    trigger.action.setUserFlag("RED_CSAR_COUNT", #csarMissions[1])
    trigger.action.setUserFlag("BLUE_CSAR_COUNT", #csarMissions[2])
end
function csb.getRescueDecayRate(rescue)
    local finalDecayRate = csarRescueDecayRate
    local checkTime = timer.getTime()
    local reason = "other"
    local sendMsg = false
    if rescue.treatments.applied.ketamine then finalDecayRate = finalDecayRate + 0.5 + (math.random(-1,3)/10) end
    if rescue.treatments.applied.opioid then finalDecayRate = finalDecayRate - 0.5 + (math.random(-3,1)/10) end
    if rescue.treatments.applied.tourniquet then finalDecayRate = finalDecayRate - 0.25 + (math.random(-1,1)/10) end
    if rescue.treatments.applied.cpr then finalDecayRate = csarRescueDecayRate end
    if rescue.treatments.needed.ketamine and (checkTime - rescue.treatments.needed.ketamine.since) > 30 then
        finalDecayRate = finalDecayRate + 1.0 + (math.random(-2,2)/10)
        if math.fmod((checkTime - rescue.treatments.needed.ketamine.since),60) == 0 then sendMsg = true end
    end
    if rescue.treatments.needed.opioid and (checkTime - rescue.treatments.needed.opioid.since) > 30 then
        finalDecayRate = finalDecayRate + 0.4 + (math.random(-1,1)/10)
        if math.fmod((checkTime - rescue.treatments.needed.opioid.since),60) == 0 then sendMsg = true end
    end
    if rescue.treatments.needed.tourniquet and (checkTime - rescue.treatments.needed.tourniquet.since) > 30 then
        finalDecayRate = finalDecayRate + 0.6 + (math.random(-1,1)/10)
        if math.fmod((checkTime - rescue.treatments.needed.tourniquet.since),60) == 0 then sendMsg = true end
    end
    if rescue.treatments.needed.cpr and (checkTime - rescue.treatments.needed.cpr.since) > 10 then
        finalDecayRate = finalDecayRate + 4.0 + (math.random(-5,5)/10)
        if math.fmod((checkTime - rescue.treatments.needed.cpr.since),60) == 0 then
            reason = "cpr"
            sendMsg = true
        end
    end
    if sendMsg then
        csb.makeMedicalActionNeededMessage(rescue.pickedUpByGroupID, reason, rescue.displayName)
    end
    if finalDecayRate < 0.2 then finalDecayRate = 0.2 end
    return finalDecayRate
end
function csb.makeMedicalActionNeededMessage(groupID, action, rescueName)
    local outString = ""
    local seed = math.random()
    if action == "cpr" then
        if seed < 0.33 then outString = "(!!!) " .. rescueName .. " is circling the drain. It's now or never!"
        elseif seed < 0.67 then outString = "(!!!) " .. rescueName .. " has no pulse. Make something happen!"
        else outString = "(!!!) " .. rescueName .. " completely unresponsive. Land now or start compressions!"
        end
    else
        if seed < 0.33 then outString = "(!) " .. rescueName .. " doesn't look so good. Maybe something was missed..."
        elseif seed < 0.67 then outString = "(!) " .. rescueName .. " is fading. Better re-check their vitals..."
        else outString = "(!) " .. rescueName .. " is struggling. There's gotta be more to be done..."
        end
    end
    trigger.action.outTextForGroup(groupID,outString,15,false)
end
function csb.makePeriodicOBTRMessage(groupID,rescue)
    local outString = nil
    local obtr = rescue.onBoardTimeRemaining
    local rescueName = rescue.displayName
    local mins = math.floor((obtr/60)+0.5)
    local seed = math.random()
    if not rescue.warningFifteen and (obtr <= 900 and obtr > 600) then
        if seed < 0.33 then outString = "(!) Let's bring " .. rescueName .. " somewhere better than here...(~" .. mins .. "mins)"
        elseif seed < 0.67 then outString = "(!) " .. rescueName .. " could do with a comfier rack than this crate...(~" .. mins .. "mins)"
        else outString = "(!) " .. rescueName .. " is really looking forward to that hospital chow...(~" .. mins .. "mins)"
        end
        rescue.warningFifteen = true
    elseif not rescue.warningTen and (obtr <= 600 and obtr > 300) then
        if seed < 0.33 then outString = "(!) " .. rescueName .. " needs us to hustle...(~" .. mins .. "mins)"
        elseif seed < 0.67 then outString = "(!) " .. rescueName .. " hasn't got all day...(~" .. mins .. "mins)"
        else outString = "(!) " .. rescueName .. " wants off this bucket...(~" .. mins .. "mins)"
        end
        rescue.warningTen = true
    elseif not rescue.warningFive and (obtr <= 300 and obtr > 0) then
        if seed < 0.33 then outString = "(!) " .. rescueName .. " hasn't got long left...(~" .. mins .. "mins)"
        elseif seed < 0.67 then outString = "(!) " .. rescueName .. " needs you to do some of that pilot sh-tuff...(~" .. mins .. "mins)"
        else outString = "(!) " .. rescueName .. " is tapping out...(~" .. mins .. "mins)"
        end
        rescue.warningFive = true
    end
    if outString then
        trigger.action.outTextForGroup(groupID,outString,15,false)
    end
end
function csb.setInitialMedicalState(params)
    local pickupState = params.pickupState
    local rescueSource = params.source
    local removePath = Utils.deepcopy(params.rescueMenu)
    local applyKetamine = false
    local applyTourniquet = false
    local applyOpioid = false
    local args = {}
    args.treatments = params.treatments
    args.onBoardTimeRemaining = params.onBoardTimeRemaining
    args.displayName = params.displayName
    args.groupID = params.groupID
    if rescueSource == "casevac" then
        if pickupState <= 0.25 then
            if math.random() < 0.16 then applyKetamine = true end
            if math.random() < 0.5 then applyTourniquet = true end
            if math.random() < 0.66 then applyOpioid = true end
        elseif pickupState <= 0.5 then
            if math.random() < 0.08 then applyKetamine = true end
            if math.random() < 0.33 then applyTourniquet = true end
            if math.random() < 0.5 then applyOpioid = true end
        elseif pickupState <= 0.75 then
            if math.random() < 0.04 then applyKetamine = true end
            if math.random() < 0.2 then applyTourniquet = true end
            if math.random() < 0.33 then applyOpioid = true end
        else
            if math.random() < 0.02 then applyKetamine = true end
            if math.random() < 0.1 then applyTourniquet = true end
            if math.random() < 0.16 then applyOpioid = true end
        end
    else
        if pickupState <= 0.25 then
            if math.random() < 0.5 then applyTourniquet = true end
        elseif pickupState <= 0.5 then
            if math.random() < 0.33 then applyTourniquet = true end
        elseif pickupState <= 0.75 then
            if math.random() < 0.1 then applyTourniquet = true end
        else
            if math.random() < 0.05 then applyTourniquet = true end
        end
    end
    if applyKetamine then
        local cmdName = "Apply Treatment: KETAMINE"
        table.insert(removePath,cmdName)
        args.treatment = "ketamine"
        args.removePath = removePath
        csb.applyTreatment(args)
    end
    if applyTourniquet then
        local cmdName = "Apply Treatment: TOURNIQUET"
        table.insert(removePath,cmdName)
        args.treatment = "tourniquet"
        args.removePath = removePath
        csb.applyTreatment(args)
    end
    if applyOpioid then
        local cmdName = "Apply Treatment: OPIOID"
        table.insert(removePath,cmdName)
        args.treatment = "opioid"
        args.removePath = removePath
        csb.applyTreatment(args)
    end
end
function csb.updateMedicalState(groupID, rescue)
    local checkTime = timer.getTime()
    local pickupSeed = rescue.pickupSeed
    local dT = checkTime - rescue.treatments.lastCheck
    local dI = checkTime - rescue.treatments.needed.lastIssue
    if rescue.onBoardTimeRemaining > 0 then
        if dT > csarCheckThreshold then
            --trigger.action.outTextForGroup(groupID,"checking " .. rescue.displayName .. " | dT = " .. dT .. " | dI = " .. dI .. " | pickupSeed = " .. pickupSeed,15,false)
            if rescue.onBoardTimeRemaining < 180 and dI > 90 and not (rescue.treatments.applied.cpr or rescue.treatments.needed.cpr) and math.random() < 0.04 and math.random() < pickupSeed then
                rescue.treatments.needed.cpr = {}
                rescue.treatments.needed.cpr.since = checkTime
                rescue.treatments.needed.lastIssue = checkTime
                dI = 0
                trigger.action.outTextForGroup(groupID, "(!!!) " .. rescue.displayName .. " is going into cardiac arrest...need to start CPR.",15,false)
            end
            if rescue.onBoardTimeRemaining >= 180 and dI > 120 and not (rescue.treatments.applied.opioid or rescue.treatments.needed.opioid) and math.random() < 0.1 and math.random() < pickupSeed then
                rescue.treatments.needed.opioid = {}
                rescue.treatments.needed.opioid.since = checkTime
                rescue.treatments.needed.lastIssue = checkTime
                dI = 0
                trigger.action.outTextForGroup(groupID, "(!) " .. rescue.displayName .. " looks to be in severe pain. Opioid analgesia recommended.",15,false)
            end
            if rescue.onBoardTimeRemaining >= 180 and dI > 120 and not (rescue.treatments.applied.tourniquet or rescue.treatments.needed.tourniquet) and math.random() < 0.1 and math.random() < pickupSeed then
                rescue.treatments.needed.tourniquet = {}
                rescue.treatments.needed.tourniquet.since = checkTime
                rescue.treatments.needed.lastIssue = checkTime
                dI = 0
                trigger.action.outTextForGroup(groupID, "(!) " .. rescue.displayName .. "'s BP is dipping, possibly an artery was nicked. A limb tourniquet might buy some more time.",15,false)
            end
            if rescue.onBoardTimeRemaining >= 180 and dI > 120 and not (rescue.treatments.applied.ketamine or rescue.treatments.needed.ketamine) and rescue.treatments.applied.opioid and math.random() < 0.08 and math.random() < pickupSeed then
                rescue.treatments.needed.ketamine = {}
                rescue.treatments.needed.ketamine.since = checkTime
                rescue.treatments.needed.lastIssue = checkTime
                dI = 0
                trigger.action.outTextForGroup(groupID, "(!) " .. rescue.displayName .. " is experiencing respiratory distress. Time for ketamine.",15,false)
            end
            rescue.treatments.lastCheck = checkTime
        end
    end
    csb.updateMedicalMenuCommands(groupID,rescue.displayName,{[1] = "CSAR",[2] = "Show On-Board List",[3] = rescue.displayName},rescue.treatments, rescue.onBoardTimeRemaining)
end
function csb.updateMedicalMenuCommands(groupID,displayName,rescueMenu,treatments,obtr)
    if obtr > 0 then
        if csb.checkTableLength(treatments.needed) <= 1 then
            local removePath = Utils.deepcopy(rescueMenu)
            table.insert(removePath,"No urgent medical needs")
            missionCommands.removeItemForGroup(groupID,removePath)
            missionCommands.addSubMenuForGroup(groupID,"No urgent medical needs",rescueMenu)
        else
            local prevEmpty = Utils.deepcopy(rescueMenu)
            table.insert(prevEmpty,"No urgent medical needs")
            missionCommands.removeItemForGroup(groupID,prevEmpty)
            for trtmnt, _ in pairs(treatments.needed) do
                if trtmnt ~= "lastIssue" then
                    local cmdName = "Apply Treatment: " .. string.upper(trtmnt)
                    local removePath = Utils.deepcopy(rescueMenu)
                    table.insert(removePath,cmdName)
                    local args = {}
                    args.groupID = groupID
                    args.displayName = displayName
                    args.treatment = trtmnt
                    args.treatments = treatments
                    args.onBoardTimeRemaining = obtr
                    args.removePath = removePath
                    missionCommands.removeItemForGroup(groupID,removePath)
                    missionCommands.addCommandForGroup(groupID,cmdName,rescueMenu,csb.applyTreatment,args)
                end
            end
        end
        if csb.checkTableLength(treatments.applied) > 0 then
            for trtmnt,_ in pairs(treatments.applied) do
                local removePath = Utils.deepcopy(rescueMenu)
                table.insert(removePath, "Previously applied: " .. string.upper(trtmnt))
                missionCommands.removeItemForGroup(groupID,removePath)
                missionCommands.addSubMenuForGroup(groupID,"Previously applied: " .. string.upper(trtmnt),rescueMenu)
            end
        end
    else
        missionCommands.removeItemForGroup(groupID,rescueMenu)
        missionCommands.addSubMenuForGroup(groupID,displayName .. " (deceased)",{[1]="CSAR",[2]="Show On-Board List",})
    end
end
function csb.checkTableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end
function csb.applyTreatment(params)
    if params.treatment == "ketamine" then
        params.treatments.applied.ketamine = true
        params.treatments.needed.ketamine = nil
        if params.onBoardTimeRemaining < 180 then
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + (180-params.onBoardTimeRemaining)
        else
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + 120
        end
    end
    if params.treatment == "tourniquet" then
        params.treatments.applied.tourniquet = true
        params.treatments.needed.tourniquet = nil
        if params.onBoardTimeRemaining < 180 then
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + (180-params.onBoardTimeRemaining)
        else
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + 180
        end
    end
    if params.treatment == "opioid" then
        params.treatments.applied.opioid = true
        params.treatments.needed.opioid = nil
        if params.onBoardTimeRemaining < 180 then
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + (180-params.onBoardTimeRemaining)
        else
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + 120
        end
    end
    if params.treatment == "cpr" then
        params.treatments.applied.cpr = true
        params.treatments.needed.cpr = nil
        if params.onBoardTimeRemaining + 60 > 180 then
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + (180-params.onBoardTimeRemaining)
        else
            params.onBoardTimeRemaining = params.onBoardTimeRemaining + 120
        end
    end
    missionCommands.removeItemForGroup(params.groupID,params.removePath)
    trigger.action.outTextForGroup(params.groupID,"(+) Administering " .. params.treatment .. " to " .. params.displayName,10,false)
end
function csb.refreshCsarTransmissions()
    timer.scheduleFunction(csb.refreshCsarTransmissions,nil,timer.getTime()+300)
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
                    args.soundfile = m.soundFile
                    args.equipment = m.equipment
                    args.signalPower = m.signalPower
                    local aiCtrllr = targetGroup:getController()
                    if aiCtrllr and aiCtrllr.setCommand then
                        cmd.params = {}
                        cmd.id = "StopTransmission"
                        aiCtrllr:setCommand(cmd)
                        env.info("[csb.refreshCsarTransmissions] - Stopping ".. m.freq*10000 .."kHz transmission by ".. args.groupName, false)
                    end
                    targetGroup = Group.getByName(args.equipment)
                    if targetGroup and targetGroup:isExist() then
                        local eqCtrllr = targetGroup:getController()
                        if eqCtrllr and eqCtrllr.setCommand then
                            cmd = {}
                            cmd.params = {}
                            cmd.id = "DeactivateBeacon"
                            eqCtrllr:setCommand(cmd)
                            env.info("[csb.refreshCsarTransmissions] - Stopping ".. m.channel .."X TACAN beacon of ".. args.equipment, false)
                        end
                    end
                    timer.scheduleFunction(csb.startTransmission,args,timer.getTime()+math.random(5))
                end
            end
        end
    end
end
function csb.startTransmission(args)
    local targetGroup = Group.getByName(args.groupName)
    local ndbFreq = args.freq
    local tcnChn = args.channel
    local modulation = args.amfm
    local soundFile = args.soundFile
    local eq = args.equipment
    local signalPower = args.signalPower
    env.info("[csb.startTransmission] - about to test group: " .. args.groupName .. "...",false)
    if targetGroup == nil or targetGroup:getSize() == 0 then return end
    local u = targetGroup:getUnit(1)
    env.info("[csb.startTransmission] - about to test for unit...",false)
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
        env.info("[csb.startTransmission] - about to set frequency to: " .. tostring(ndbFreq*10000) .. "...",false)
        cmd.id = "SetFrequency"
        cmd.params = {}
        cmd.params.frequency = ndbFreq * 10000
        cmd.params.modulation = modulation
        cmd.params.power = signalPower
        aiCtrllr:setCommand(cmd)
        cmd = {}
        cmd.id = "TransmitMessage"
        cmd.params = {}
        cmd.params.loop = true
        cmd.params.file = soundFile
        aiCtrllr:setCommand(cmd)
        env.info("[csb.startTransmission] - TransmitMessage command sent...",false)
    else
        env.info("[csb.startTransmission] - controller for CSAR unit is not functional.",false)
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
        env.info("[csb.startTransmission] - controller for CSAR TACAN unit is not functional.",false)
    end
end
function csb:onEvent(e)
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
            local wCsarParams = {}
            wCsarParams.inUnit = evtInitr
            wCsarParams.coalitionId = c
            wCsarParams.overWater = isOverWater
            wCsarParams.playerName = playerName
            csb.wrappedGenerateCsar(wCsarParams)
        end
    end
    if evtId == 33 then -- discard chair
        local args = {inUnit = e.target}
        timer.scheduleFunction(csb.cleanUpPilot,args,timer.getTime()+5)
    end
    if evtId == 31 then -- pilot landed without being cleaned up somehow
        if evtInitr.Desc then mist.utils.oneLineSerialize(evtInitr.Desc) end
        local args = {inUnit = evtInitr}
        timer.scheduleFunction(csb.cleanUpPilot,args,timer.getTime()+5)
    end
    --//CSAR-CAPABLE INITIATOR EVENTS
    isCsarUnit = evtInitr and Unit.isExist(evtInitr) and evtInitr.getPlayerName and evtInitr:getPlayerName() and DFS.heloCapacities[evtInitr:getTypeName()]
    if isCsarUnit then
        if evtId == 4 then -- Landing
            csb.checkCsarLanding(evtInitr)
        end
        if evtId == 5 then --crash
            csb.checkCsarCrash(evtInitr)
        end
    end
end
function csb.checkCsarCrash(eUnit)
    if eUnit and eUnit:isExist() and eUnit.getPlayerName then
        -- unit probably doesn't have a group any more
        local pName = eUnit:getPlayerName()
        local pSide = eUnit:getCoalition()
        local pType = eUnit:getTypeName()
        local outString = ""
        local csci = csarCheckIns[pSide][pName]
        if csci then
            if (#csci.onBoard > 0) then
                outString = outString .. pName .. "'s " .. pType .. " has gone down with "
                for _,m in (csci.onBoard) do
                    outString = outString .. m.displayName .. ", "
                end
                outString = string.sub(outString,1,-3)
                outString = outString .. " on board."
            end
            csci = nil
        end
        if string.len(outString) > 0 then
            trigger.action.outTextForCoalition(pSide,outString,15,false)
        end
    end
end
function csb.checkCsarLanding(eUnit)
    if eUnit and eUnit:isExist() and eUnit.getPlayerName then
        local pName = eUnit:getPlayerName()
        local pSide = eUnit:getCoalition()
        local pPosn = eUnit:getPoint()
        local pVelo = eUnit:getVelocity()
        local pType = eUnit:getTypeName()
        local pUnit = eUnit:getName()
        local inSafeVeloParams = csb.checkVelocity(pVelo)
        local inCorrectConfig = csb.checkCorrectConfig(eUnit,pType)
        local bInCsarBase = false
        local sBaseName = "Nowhere"
        if csarCheckIns[pSide][pName] then
            local zonePoint = nil
            local csci = csarCheckIns[pSide][pName]
            if csci.checking then return end
            csci.checking = true
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
            local checkTime = timer.getTime()
                if not inSafeVeloParams then
                    trigger.action.outTextForGroup(csci.groupID, "Travelling too fast for safe drop-off.", 5, false)
                elseif not inCorrectConfig then
                    if not csci.lastConfigWarning or (csci.lastConfigWarning and (checkTime - csci.lastConfigWarning > 15)) then
                        trigger.action.outTextForGroup(csci.groupID, "Need to open the side/rear doors for safe drop-off", 10, false)
                        csci.lastConfigWarning = checkTime
                    end
                else
                    local kiaString = ""
                    for _,m in pairs(csci.onBoard) do
                        if m.onBoardTimeRemaining > 0 then
                            trigger.action.outTextForCoalition(pSide, pName .. " safely delivered " .. m.displayName .. " to " .. sBaseName .. ".", 15, false)
                            if DFS then DFS.IncreaseFrontSupply({coalitionId = pSide, amount = 1, type = DFS.supplyType.EQUIPMENT}) end
                            if WWEvents then WWEvents.playerCsarMissionCompleted(pName, pSide, sBaseName," rescued ".. m.displayName .. " from the battlefield.") end
                        else
                            trigger.action.outTextForCoalition(pSide, "Unfortunately, " .. m.displayName .. " has been declared DOA at " .. sBaseName .. ", and will be recorded as KIA.", 15, false)
                            kiaString = " (deceased)"
                        end
                        missionCommands.removeItemForGroup(csci.groupID,{[1] = "CSAR",[2] = "Show On-Board List", [3] = m.displayName .. kiaString})
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
                    if not m.extracting then
                        if Utils.PointDistance(pPosn, m.point) < csarPickupRadius then
                            if inSafeVeloParams then
                                local checkTime = timer.getTime()
                                if transporterTable and transporterTable.cargo.volumeUsed + csarTroopVol > DFS.heloCapacities[pType].volume then
                                    local warned = false
                                    for i,w in pairs(m.warned) do
                                        if w.name == pUnit then
                                            warned = true
                                            if checkTime - w.warntime > 60 then
                                                warned = false
                                                m.warned[i] = nil
                                            end
                                        end
                                    end
                                    if not warned then
                                        trigger.action.outTextForGroup(csci.groupID, "The airframe is at it's volume limit. Extraction of " .. m.displayName .. " not possible.", 30, false)
                                        table.insert(m.warned, {name = pUnit, warntime = timer.getTime()})
                                    end
                                    break
                                else
                                    if inCorrectConfig then
                                        trigger.action.outTextForCoalition(pSide, pName .. " is attempting to extract " .. m.displayName .. "...", 10, false)
                                        m.extracting = true
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
                                        timer.scheduleFunction(csb.fakeExtractionTime, args, timer.getTime() + math.random(3,6))
                                    else
                                        if not csci.lastConfigWarning or (csci.lastConfigWarning and (checkTime - csci.lastConfigWarning > 15)) then
                                            trigger.action.outTextForGroup(csci.groupID, "Need to open the side/rear doors for pick-up", 10, false)
                                            csci.lastConfigWarning = checkTime
                                        end
                                    end
                                end
                            else
                                trigger.action.outTextForGroup(csci.groupID, "Travelling too fast for safe pickup.", 5, false)
                            end
                        end
                    end
                end
            end
            csci.checking = nil
        end
    end
end
function csb.checkCorrectConfig(inUnit,inType)
    local returnVal = true
    if inType == "UH-1H" then
        if inUnit:getDrawArgumentValue(43) ~= 1 and inUnit:getDrawArgumentValue(44) ~= 1 then returnVal = false end
    elseif inType =="Mi-8MT" or inType == "Mi-24P" then
        if inUnit:getDrawArgumentValue(38) ~= 1 and inUnit:getDrawArgumentValue(86) ~= 1 then returnVal = false end
    elseif inType == "CH-47Fbl1" then
        if inUnit:getDrawArgumentValue(348) ~= 1 and inUnit:getDrawArgumentValue(86) ~= 1 and inUnit:getDrawArgumentValue(85) ~= 1 then returnVal = false end
    end
    return returnVal
end
function csb.fakeExtractionTime(args)
    local playerGroupID = args.pGrId
    local playerUnit = args.pUnit
    local transporterTable = DFS.helos[args.pGrNm]
    local pickupTime = timer.getTime()
    local csci = csarCheckIns[args.pSide][args.pName]
    if playerUnit and playerUnit:isExist() and playerUnit.getPlayerName then
        local pVelo = playerUnit:getVelocity()
        local pUnitName = playerUnit:getName()
        local inSafeVeloParams = csb.checkVelocity(pVelo)
        if inSafeVeloParams then
            local pickupCutoff = args.mission.startTime + args.mission.expires
            local pickupStateModifier = -60
            local pickupState = (pickupCutoff - pickupTime)/args.mission.expires
            if pickupState <= 0.25 then
                pickupStateModifier = 180
            elseif pickupState <= 0.5 then
                pickupStateModifier = 60
            elseif pickupState > 0.75 then
                pickupStateModifier = -180
            end
            args.mission.pickupTime = pickupTime
            args.mission.pickedUpByGroupID = csci.groupID
            args.mission.pickupSeed = (math.random(5000,8000)/10000) - (math.floor(math.fmod(pickupTime,60))/1000)
            args.mission.onBoardTimeRemaining = csarOnBoardDefaultEndurance - pickupStateModifier
            args.mission.deliveryCutoff = pickupTime + args.mission.onBoardTimeRemaining
            args.mission.treatments = {}
            args.mission.treatments.applied = {}
            args.mission.treatments.needed = {}
            args.mission.treatments.lastCheck = pickupTime
            args.mission.treatments.needed.lastIssue = pickupTime
            local rescueMenu = missionCommands.addSubMenuForGroup(csci.groupID,args.mission.displayName,{[1] = "CSAR",[2] = "Show On-Board List",})
            local params = {}
            params.groupID = csci.groupID
            params.displayName = args.mission.displayName
            params.treatments = args.mission.treatments
            params.onBoardTimeRemaining = args.mission.onBoardTimeRemaining
            params.source = args.mission.source
            params.pickupState = pickupState
            params.rescueMenu = rescueMenu
            csb.setInitialMedicalState(params)
            table.insert(csci.onBoard, args.mission)
            csb.updateMedicalMenuCommands(csci.groupID,args.mission.displayName,rescueMenu,args.mission.treatments, args.mission.onBoardTimeRemaining)
            if transporterTable then
                transporterTable.addedMass = transporterTable.addedMass + csarTroopMass
                transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed + csarTroopVol
                trigger.action.setUnitInternalCargo(pUnitName, transporterTable.addedMass)
            end
            csb.cleanupCsarGroup(args)
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
            for _,m in pairs(csarMissions[args.pSide]) do
                if m == args.mission then
                    m.extracting = nil
                end
            end
        end
    end
end
function csb.cleanupCsarGroup(csarData)
    local targetGroup = Group.getByName(csarData.groupName)
    if targetGroup and targetGroup:isExist() then Group.destroy(targetGroup) end
    if csarData.equipment ~= nil then
        local eq = Group.getByName(csarData.equipment)
        if eq and eq:isExist() then Group.destroy(eq) end
    end
end
function csb.checkVelocity(pVelo,limit)
    local vLimit = limit or 0.5
    if vLimit <= 0 then vLimit = 0.5 end
    local xInParam = math.abs(pVelo.x) < vLimit
    local yInParam = math.abs(pVelo.y) < vLimit
    local zInParam = math.abs(pVelo.z) < vLimit
    return xInParam and yInParam and zInParam
end
function csb.buildMissionAirbaseList()
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
function csb.cleanUpPilot(args)
    local pilot = args.inUnit
    if pilot and pilot:isExist() then Object.destroy(pilot) end
end
function csb.debugCsarGeneration()
    timer.scheduleFunction(csb.debugCsarGeneration,nil,timer.getTime()+10)
    for i=1,2 do
        if #csarMissions[i] < 2 then
            local csarParams = {}
            csarParams.coalitionId = i
            csarParams.timeLimit = {480,720}
            csarParams.radioSilence = false
            csarParams.hotLZ = false
            csarParams.source = "debug"
            CSB.generateCsar(csarParams)
        end
    end
end
function csb.extendExistingCasEvac(coalitionId, bpId)
    for _,m in pairs(casEvacMissions[coalitionId]) do
        if m.bpId == bpId then
            local newCas = math.random(2,4)
            m.numCas = m.numCas + newCas
            m.endTime = m.endTime + (casEvacTimePer * newCas)
            local remainingTime = m.endTime - timer.getTime()
            m.nextCsar = m.lastCsar + math.floor((remainingTime / (m.numCas+1))+0.5)
            return true
        end
    end
    return false
end
function CSB.createCasEvac(coalitionId, bpId, newCoalitionId)
    if #casEvacMissions[coalitionId] > 0 then
        local extendExisting = csb.extendExistingCasEvac(coalitionId,bpId)
        if extendExisting == true then return end
    end
    local ceMission = {}
    local createTime = timer.getTime()
    local freq = csb.getClearFreq(coalitionId,"NDB",CSARFreqs[coalitionId]["NDB"][1], CSARFreqs[coalitionId]["NDB"][2])
    local channel = csb.getClearFreq(coalitionId, "TACAN", CSARFreqs[coalitionId]["TACAN"][1],CSARFreqs[coalitionId]["TACAN"][2])
    local modulation = 0
    local coalitionName = "Red"
    if coalitionId == 2 then coalitionName = "Blue" end
    local casEvacZoneName = coalitionName .. "CasEvac_BP-" .. bpId
    local casEvacZone = trigger.misc.getZone(casEvacZoneName)
    if not casEvacZone then
        env.info("CSB.createCasEvac: could not find zone: " .. casEvacZoneName, false)
        return
    end
    local spawnPoint = casEvacZone.point
    if not spawnPoint then
        env.info("CSB.createCasEvac: could not find spawn point for zone: " .. casEvacZoneName, false)
        return
    end
    ceMission.hotLZ = csb.checkLZ(spawnPoint,coalitionId)
    ceMission.coalition = coalitionId
    ceMission.bpId = bpId
    ceMission.groupName = DF_UTILS.spawnGroupExact("CASEVAC-" .. coalitionId,spawnPoint,"clone",nil,nil,nil,"CASEVAC-" .. genCasEvacCounter)
    ceMission.equipment = DF_UTILS.spawnGroupExact("TCN-" .. coalitionId,spawnPoint,"clone",nil,nil,nil,"CASEVAC-TCN-" .. genCasEvacCounter)
    if not (ceMission.groupName and ceMission.equipment) then
        env.info("CSB.createCasEvac: could not spawn CasEvac group",false)
        return
    end
    csb.makeRescueInvisible(ceMission.groupName)
    csb.makeRescueInvisible(ceMission.equipment)
    if CB and CB.flareGroup then CB.flareGroup(ceMission.groupName) end
    local numCas = math.random(3,6)
    if newCoalitionId == 0 then numCas = math.random(2,4) end
    local casEvacDuration = numCas * casEvacTimePer
    ceMission.startTime = createTime
    ceMission.endTime = ceMission.startTime + casEvacDuration
    ceMission.numCas = numCas - 1
    ceMission.lastCsar = ceMission.startTime
    ceMission.nextCsar = ceMission.lastCsar + math.floor((casEvacDuration / (ceMission.numCas+1))+0.5)
    ceMission.point = spawnPoint
    ceMission.zoneName = casEvacZoneName
    ceMission.contacts = {}
    ceMission.smokeTime = timer.getTime() - 300
    ceMission.radius = casEvacRadius
    ceMission.innerRadius = casEvacInnerRadius
    ceMission.freq = freq
    ceMission.channel = channel
    ceMission.modulation = modulation
    ceMission.soundfile = casEvacSoundFile
    ceMission.missionId = genCasEvacCounter
    ceMission.signalPower = casEvacSignalPower
    local csarParams = {}
    csarParams.csarPoint = ceMission.point
    csarParams.coalitionId = ceMission.coalition
    csarParams.csarRadius = ceMission.radius
    csarParams.csarMinRadius = ceMission.innerRadius
    csarParams.radioSilence = true
    csarParams.hotLZ = ceMission.hotLZ
    csarParams.source = "casevac"
    csarParams.sourceId = ceMission.missionId
    CSB.generateCsar(csarParams)
    table.insert(casEvacMissions[coalitionId], ceMission)
    genCasEvacCounter = genCasEvacCounter + 1
    local nearestBp, dist, dir = csb.closestBpTo(spawnPoint)
    local args = {}
    args.groupName = ceMission.groupName
    args.freq = ceMission.freq
    args.channel = ceMission.channel
    args.amfm = ceMission.modulation
    args.soundFile = ceMission.soundfile
    args.signalPower = ceMission.signalPower
    timer.scheduleFunction(csb.startTransmission, args, timer.getTime() + math.random(10,20))
    trigger.action.outTextForCoalition(coalitionId,"CASEVAC point set up approx " .. dist .. "km " .. dir .. " of BP-" .. nearestBp .. " | NDB on " .. freq * 10 .. "kHz | TCN on " .. channel .. "X\n" .. ceMission.numCas+1 .. " casualties being stabilized and prepped for evac over the next " .. math.floor((casEvacDuration/60)+0.5) .. " minutes approx.",20,false)
    env.info("CASEVAC point set up approx " .. dist .. "km " .. dir .. " of BP-" .. nearestBp .. " | NDB on " .. freq * 10 .. "kHz | TCN on " .. channel .. "X\n" .. ceMission.numCas+1 .. " casualties being stabilized and prepped for evac over the next " .. math.floor((casEvacDuration/60)+0.5) .. " minutes approx.",false)
end
function csb.trackCasEvac()
    timer.scheduleFunction(csb.trackCasEvac, nil, timer:getTime() + trackCasEvacInterval)
    local ongoingMissions = {}
    local remainingTime = 0
    local checkTime = timer.getTime()
    for c = 1, 2 do
        ongoingMissions = {}
        for _,m in pairs(casEvacMissions[c]) do
            if m.endTime < checkTime then
                csb.cleanupCasEvacGroup(m)
            else
                remainingTime = m.endTime - checkTime
                if m.numCas > 0 then
                    if m.nextCsar < checkTime then
                        local csarParams = {}
                        csarParams.csarPoint = m.point
                        csarParams.coalitionId = c
                        csarParams.csarRadius = m.radius
                        csarParams.csarMinRadius = m.innerRadius
                        csarParams.radioSilence = true
                        csarParams.hotLZ = m.hotLZ
                        csarParams.source = "casevac"
                        csarParams.sourceId = m.missionId
                        CSB.generateCsar(csarParams)
                        for _,r in pairs(csarMissions[c]) do
                            if r.sourceId == m.missionId then
                                if r.expires then
                                    local rEndTime = r.startTime + r.expires
                                    if m.endTime < rEndTime then
                                        -- extend casevac mission to cover last rescue expiry time
                                        m.endTime = m.endTime + (math.random(6,8) * 60)
                                        r.expires = m.endTime - r.startTime
                                        env.info("[csb.trackCasEvac]: extending CASEVAC #" .. m.missionId .. " from " .. remainingTime .. " seconds to " .. m.endTime - checkTime .. " seconds", false)
                                        remainingTime = m.endTime - checkTime
                                    end
                                end
                            end
                        end
                        m.lastCsar = checkTime
                        m.numCas = m.numCas - 1
                        m.nextCsar = m.lastCsar + math.floor((remainingTime / (m.numCas+1))+0.5)
                    end
                end
                local currentPlayers = coalition.getPlayers(c)
                for k,v in pairs(csarCheckIns[c]) do
                    local playerActive = false
                    local playerUnit = nil
                    for j = 1, #currentPlayers do
                        if k == Unit.getPlayerName(currentPlayers[j]) then
                            playerActive = true
                            playerUnit = currentPlayers[j]
                            break
                        end
                    end
                    if playerActive and playerUnit and DFS.heloCapacities[playerUnit:getTypeName()] then
                        local playerPos = playerUnit:getPoint()
                        local playerHdg = Utils.getHdgFromPosition(playerUnit:getPosition())
                        local pUnitName = playerUnit:getName()
                        local dist = Utils.PointDistance(m.point,playerPos)
                        local clockBearing = Utils.relativeClockBearing(playerPos, m.point, playerHdg)
                        if dist < casEvacAlertRange then
                            local pContacted = false
                            local smokeName = "CASEVAC-" .. m.missionId .. "-SMOKE"
                            local ceZP = trigger.misc.getZone(m.zoneName).point
                            ceZP.y = land.getHeight({x = ceZP.x, y= ceZP.z})
                            for _,h in pairs(m.contacts) do
                                if h == pUnitName then
                                    pContacted = true
                                    break
                                end
                            end
                            if not pContacted then
                                trigger.action.effectSmokeStop(smokeName)
                                trigger.action.effectSmokeBig(ceZP,5,0.001,smokeName)
                                timer.scheduleFunction(trigger.action.effectSmokeStop, smokeName, timer:getTime()+180)
                                table.insert(m.contacts, pUnitName)
                                if CB and CB.flareGroup then CB.flareGroup(m.groupName) end
                                m.smokeTime = checkTime
                                trigger.action.outTextForGroup(v.groupID, "Winch Op: CASEVAC #" .. m.missionId .. " to our " .. clockBearing .. " o'clock.", 15, false)
                            else
                                if checkTime - m.smokeTime > 300 then
                                    -- refresh the smoke effect
                                    trigger.action.effectSmokeStop(smokeName)
                                    trigger.action.effectSmokeBig(ceZP,5,0.001,smokeName)
                                    timer.scheduleFunction(trigger.action.effectSmokeStop, smokeName, timer:getTime()+180)
                                    trigger.action.outTextForGroup(v.groupID, "Winch Op: CASEVAC #" .. m.missionId .. " to our " .. clockBearing .. " o'clock.", 15, false)
                                    m.smokeTime = checkTime
                                end
                            end
                        end
                    end
                end
                table.insert(ongoingMissions,m)
            end
        end
        casEvacMissions[c] = ongoingMissions
    end
end
function csb.cleanupCasEvacGroup(ceMission)
    local targetGroup = Group.getByName(ceMission.groupName)
    if targetGroup and targetGroup:isExist() then Group.destroy(targetGroup) end
    if ceMission.equipment ~= nil then
        local eq = Group.getByName(ceMission.equipment)
        if eq and eq:isExist() then Group.destroy(eq) end
    end
end
function csb.debugCasEvacGeneration()
    timer.scheduleFunction(csb.debugCasEvacGeneration,nil,timer.getTime()+10)
    local bpCount = trigger.misc.getUserFlag("TOTAL_BPS")
    for i=1,2 do
        if #casEvacMissions[i] < 1 then
            CSB.createCasEvac(i,math.random(1,bpCount))
        end
    end
end
function csb.closestBpTo(pos)
    local bpCount = trigger.misc.getUserFlag("TOTAL_BPS")
    bpCount = bpCount or 20
    local closestBPDist = math.huge
    local closestBPId = nil
    local direction = ""
    for i = 1,bpCount do
        local bpPoint = BattleControl.getBPPoint(i)
        if bpPoint then
            local dist = Utils.PointDistance(bpPoint,pos)
            if dist < closestBPDist then
                closestBPDist = dist
                closestBPId = i
            end
        end
    end
    if closestBPId then
        direction = Utils.relativeCompassBearing(pos,BattleControl.getBPPoint(closestBPId))
    end
    closestBPDist = math.floor((closestBPDist/1000)+0.5)
    return closestBPId, closestBPDist, direction
end
function csb.closestEnemyBpTo(pos, coalitionId)
    local bpCount = trigger.misc.getUserFlag("TOTAL_BPS")
    bpCount = bpCount or 20
    local direction = nil
    local opposition = 1
    if coalitionId == 1 then opposition = 2 end
    local closestEnemyBPDist = math.huge
    local closestEnemyBPId = nil
    for i = 1,bpCount do
        local bpOwner = BattleControl.getBPOwner(i)
        if bpOwner == opposition then
            local bpPoint = BattleControl.getBPPoint(i)
            if bpPoint then
                local dist = Utils.PointDistance(bpPoint,pos)
                if dist < closestEnemyBPDist then
                    closestEnemyBPDist = dist
                    closestEnemyBPId = i
                end
            end
        end
    end
    if closestEnemyBPId then
        direction = Utils.relativeCompassBearing(pos,BattleControl.getBPPoint(closestEnemyBPId))
    end
    closestEnemyBPDist = math.floor((closestEnemyBPDist/1000)+0.5)
    return closestEnemyBPId, closestEnemyBPDist, direction
end
function csb.refreshCasEvacTransmissions()
    timer.scheduleFunction(csb.refreshCasEvacTransmissions,nil,timer.getTime()+300)
    for n=1,2 do
        for _,m in pairs(casEvacMissions[n]) do
            if not m.radioSilence then
                local args = {}
                local cmd = {}
                local targetGroup = Group.getByName(m.groupName)
                if targetGroup and targetGroup:isExist() then
                    args.groupName = m.groupName
                    args.equipment = m.equipment
                    args.freq = m.freq
                    args.channel = m.channel
                    args.amfm = m.modulation
                    args.soundfile = m.soundFile
                    args.signalPower = m.signalPower
                    local aiCtrllr = targetGroup:getController()
                    if aiCtrllr and aiCtrllr.setCommand then
                        cmd.params = {}
                        cmd.id = "StopTransmission"
                        aiCtrllr:setCommand(cmd)
                        env.info("[csb.refreshCasEvacTransmissions] - Stopping ".. m.freq*10000 .."kHz transmission by ".. args.groupName, false)
                    end
                    targetGroup = Group.getByName(args.equipment)
                    if targetGroup and targetGroup:isExist() then
                        local eqCtrllr = targetGroup:getController()
                        if eqCtrllr and eqCtrllr.setCommand then
                            cmd = {}
                            cmd.params = {}
                            cmd.id = "DeactivateBeacon"
                            eqCtrllr:setCommand(cmd)
                            env.info("[csb.refreshCsarTransmissions] - Stopping ".. m.channel .."X TACAN beacon of ".. args.equipment, false)
                        end
                    end
                    timer.scheduleFunction(csb.startTransmission,args,timer.getTime()+math.random(5))
                end
            end
        end
    end
end
function csb.checkLZ(point,coalitionId)
    local placeDist = math.huge
    local placeId = nil
    local placeName = nil
    local dir = nil
    placeId, placeDist, dir = csb.closestEnemyBpTo(point,coalitionId)
    if placeId and (placeDist < hotLZdist) then
        return true
    end
    placeName, placeDist, dir = csb.closestEnemyBaseTo(point, coalitionId)
    if placeName and (placeDist < hotLZdist) then
        return true
    end
    return false
end
function csb.makeRescueInvisible(groupName)
    local rescueGroup = Group.getByName(groupName)
    if rescueGroup then
        local cmd = {
            id = 'SetInvisible',
            params = {
                value = true
            }
        }
        rescueGroup:getController():setCommand(cmd)
        env.info("[csb.makeRescueInvisible]: setting " .. groupName .. " to invisible",false)
    end
end
world.addEventHandler(csb)
csb.load()