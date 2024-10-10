local csb = {}
-- Created by combining CasBot.lua from WWXOS (url) by EatLeadCobra with ideas from
-- autoCSAR.lua and csarManager2.lua from the DML package (url) by cfrag
local searchStackInterval = 30
local trackCsarInterval = 2
local csarStackRadius = 1000
local csarStackHeight = 1000
local csarZoneRadius = 10000
local csarTimeLimit = 3599
local csarReassignTime = 299
local csarPickupRadius = 70
local csarHoverRadius = 20
local csarHoverAgl = 30
local csarHoverTime = 20
local csarBreakCoverRange = 1500

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
local assignments = {
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
local csarFreqs = {
    [1] = {
        ["VHF_FM"] = {
            [0] = 41000000,
            [1] = 42000000,
            [2] = 43000000,
            [3] = 44000000,
            [4] = 45000000,
            [5] = 46000000,
            [6] = 47000000,
            [7] = 48000000,
            [8] = 49000000,
        },
        ["NDB"] = {
            [0] = 410000,
            [1] = 440000,
            [2] = 470000,
            [3] = 500000,
            [4] = 530000,
            [5] = 560000,
            [6] = 590000,
            [7] = 620000,
            [8] = 650000,
        },
        ["TACAN"] = {
            [0] = 41,
            [1] = 42,
            [2] = 43,
            [3] = 44,
            [4] = 45,
            [5] = 46,
            [6] = 47,
            [7] = 48,
            [8] = 49,
        }
    },
    [2] = {
        ["VHF_FM"] = {
            [0] = 51000000,
            [1] = 52000000,
            [2] = 53000000,
            [3] = 54000000,
            [4] = 55000000,
            [5] = 56000000,
            [6] = 57000000,
            [7] = 58000000,
            [8] = 59000000,
        },
        ["NDB"] = {
            [0] = 710000,
            [1] = 740000,
            [2] = 770000,
            [3] = 800000,
            [4] = 830000,
            [5] = 860000,
            [6] = 890000,
            [7] = 920000,
            [8] = 950000,
        },
        ["TACAN"] = {
            [0] = 51,
            [1] = 52,
            [2] = 53,
            [3] = 54,
            [4] = 55,
            [5] = 56,
            [6] = 57,
            [7] = 58,
            [8] = 59,
        }
    }
}
local csarCounter = {
    [1] = {
        ["VHF_FM"] = 0,
        ["NDB"] = 0,
        ["TACAN"] = 0
    },
    [2] = {
        ["VHF_FM"] = 0,
        ["NDB"] = 0,
        ["TACAN"] = 0
    }
}
local csarBases = {
    [1] = {
        [1] = "Red Forward Field Hospital"
    },
    [2] = {
        [1] = "Blue Forward Field Hospital"
    }
}
local vhfFmHomingCapable = {
    ["Mi-24P"] = true,
    ["Mi-8MT"] = true,
    ["UH-1H"] = true
}
local tacanOnly = {
    ["AV8BNA"] = true
}
function csb.load()
    local redZone = trigger.misc.getZone(stackZones[1])
    local blueZone = trigger.misc.getZone(stackZones[2])
    local redCsarZone = trigger.misc.getZone(csarZones[1])
    local blueCsarZone = trigger.misc.getZone(csarZones[2])
    if redZone and blueZone then
        stackPoints[1] = {x=redZone.point.x, y = land.getHeight({x = redZone.point.x, y = redZone.point.z})+csarStackHeight, z = redZone.point.z}
        trigger.action.circleToAll(1, DrawingTools.newMarkId(), stackPoints[1], csarStackRadius, {1,0,0,0.6}, {0,0,0,0}, 4, true, nil)
        trigger.action.textToAll(1, DrawingTools.newMarkId(), stackPoints[1], {1,0,0,0.6}, {1,1,1,0.9}, 10, true, "CSAR Stack")
        stackPoints[2] = {x=blueZone.point.x, y = land.getHeight({x = blueZone.point.x, y = blueZone.point.z})+csarStackHeight, z = blueZone.point.z}
        trigger.action.circleToAll(2, DrawingTools.newMarkId(), stackPoints[2], csarStackRadius, {0,0,1,0.6}, {0,0,0,0}, 4, true, nil)
        trigger.action.textToAll(2, DrawingTools.newMarkId(), stackPoints[2], {0,0,1,0.6}, {1,1,1,0.9}, 10, true, "CSAR Stack")
    end
    if redCsarZone and blueCsarZone then
        csarPoints[1] = {x=redCsarZone.point.x, y = land.getHeight({x = redCsarZone.point.x, y = redCsarZone.point.z})+3, z = redCsarZone.point.z}
        trigger.action.circleToAll(1,DrawingTools.newMarkId(),csarPoints[1],csarZoneRadius,{1,0,0,0.6},{0,0,0,0}, 4, true, nil)
        trigger.action.textToAll(1, DrawingTools.newMarkId(), csarPoints[1], {1,0,0,0.6}, {1,1,1,0.9}, 10, true, "CSAR Coverage")
        csarPoints[2] = {x=blueCsarZone.point.x, y = land.getHeight({x = blueCsarZone.point.x, y = blueCsarZone.point.z})+3, z = blueCsarZone.point.z}
        trigger.action.circleToAll(2,DrawingTools.newMarkId(),csarPoints[2],csarZoneRadius,{0,0,1,0.6},{0,0,0,0}, 4, true, nil)
        trigger.action.textToAll(2, DrawingTools.newMarkId(), csarPoints[2], {0,0,1,0.6}, {1,1,1,0.9}, 10, true, "CSAR Coverage")
        csb.main()
    end
end
function csb.main()
    csb.searchCsarStacks()
    csb.trackCsar()
end
function csb.searchCsarStacks()
    timer.scheduleFunction(csb.searchCsarStacks, nil, timer:getTime() + searchStackInterval)
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
                if playerGroup then
                    local playerGroupID = playerGroup:getID()
                    if foundPlayerName and playerCoalition and playerGroupID then
                        env.info("Found player: "..foundPlayerName, false)
                        if assignments[c][foundPlayerName] == nil then
                            env.info("player added to list: "..foundPlayerName, false)
                            currentLists[c][foundPlayerName] = {name = foundPlayerName, coalition = playerCoalition, groupID = playerGroupID, typeName = playerTypeName}
                        end
                    end
                end
            end
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        for k,v in pairs(currentLists[c]) do
            if previousLists[c][k] and assignments[c][k] == nil or previousLists[c][k] and (assignments[c][k].startTime > csarReassignTime) then
                if assignments[c][k] ~= nil then
                    local g = Group.getByName(assignments[c][k].target)
                    if g and g:isExist() then
                        Group.destroy(g)
                        if assignments[c][k].equipment ~= nil then
                            local eq = Group.getByName(assignments[c][k].equipment)
                            if eq and eq:isExist() then Group.destroy(eq) end
                        end
                    end
                    trigger.action.outTextForGroup(assignments[c][k].groupID, assignments[c][k].fName.."'s locator Beacon no longer transmitting...", 30, false)
                    assignments[c][k] = nil
                end
                csb.assignCsar(v.name, v.coalition, v.groupID, v.typeName)
                env.info("player assigned: ".. v.name, false)
            else
                trigger.action.outTextForGroup(v.groupID, "You are on station for CSAR. Stand by for assignment.", 20, false)
            end
        end
        previousLists[c] = {}
        previousLists[c] = Utils.deepcopy(currentLists[c])
        currentLists[c] = {}
    end
end
function csb.assignCsar(playerName, coalitionId, playerGroupID, typeName)
    local smokeNum = math.random(0,4)
    local fName = ""
    local freqType = "VHF_FM"
    local modulation = 1
    local csarGearGroupName = nil
    if randomNames and randomNames.getNewName then
        fName = randomNames.getNewName(coalitionId)
    end
    local csarGroupName = DF_UTILS.spawnGroupWide("SOS-".. coalitionId,csarPoints[coalitionId],"clone",csarZoneRadius, false, {"LAND","ROAD"}, fName)
    if csarGroupName then
        local csarGroup = Group.getByName(csarGroupName)
        if csarGroup then
            local csarPoint = csarGroup:getUnit(1):getPoint()
            if fName == "" then fName = csarGroupName end
            if vhfFmHomingCapable[typeName] == nil then
                if tacanOnly[typeName] then
                    freqType = "TACAN"
                    modulation = 0
                    csarGearGroupName = DF_UTILS.spawnGroupWide("TCN-".. coalitionId,csarPoint,"clone",2, false, {"LAND","ROAD"}, fName .. "_TCN")
                else
                    freqType = "NDB"
                    modulation = 0
                end
            end
            local freq = csarFreqs[coalitionId][freqType][csarCounter[coalitionId][freqType]]
            local channel = csarCounter[coalitionId][freqType] + 1
            local freqStr = "Use homing function of VHF radio - FM band - ".. freq / 1000000 .." MHz (Ch" .. channel .. ")"
            if freqType == "NDB" then freqStr = "Use NDB/ADF homing function - AM band - ".. freq / 1000 .." kHz" end
            if freqType == "TACAN" then freqStr = "Use TACAN homing function - ".. freq .."X" end
            local args = {}
            args.groupName = csarGroupName
            args.freqType = freqType
            args.freq = freq
            args.amfm = modulation
            args.soundFile = "l10n/DEFAULT/dah2.ogg"
            timer.scheduleFunction(csb.startTransmission, args, timer.getTime() + math.random(2,5))
            assignments[coalitionId][playerName] = {
                name = playerName,
                target = csarGroupName,
                groupID = playerGroupID,
                startTime = timer.getTime(),
                smokeTime = timer.getTime(),
                smokeNum = smokeNum,
                status = 0,
                freq = freq,
                coords = csarPoint,
                contact = false,
                hoverTime = 0,
                fName = fName,
                equipment = csarGearGroupName,
                freqType = freqType
            }
            trigger.action.outTextForGroup(playerGroupID, "- CSAR mission assigned.\n- Rescue ".. fName ..".\n- ".. freqStr .. ".", 20, false)
            if csarCounter[coalitionId][freqType] == 8 then csarCounter[coalitionId][freqType] = -1 end
            csarCounter[coalitionId][freqType] = csarCounter[coalitionId][freqType] + 1
        end
    end
end
function csb.trackCsar()
    timer.scheduleFunction(csb.trackCsar, nil, timer:getTime() + trackCsarInterval)
    for c = 1, 2 do
        local playerActive = false
        local playerUnit = nil
        for k,v in pairs(assignments[c]) do
            local currentPlayers = coalition.getPlayers(c)
            local targetGroup = nil
            for j = 1, #currentPlayers do
                if v.name == Unit.getPlayerName(currentPlayers[j]) then
                    playerActive = true
                    playerUnit = currentPlayers[j]
                end
            end
            if playerActive and playerUnit then
                if v.status == 0 then -- pre-pickup state
                    targetGroup = Group.getByName(v.target)
                    local isDead = false
                    if targetGroup == nil or targetGroup:getSize() == 0 then
                        isDead = true
                    end
                    if (isDead or (timer.getTime() - v.startTime > csarTimeLimit)) then
                        if targetGroup and targetGroup:isExist() then
                            Group.destroy(targetGroup)
                            if v.equipment ~= nil then
                                local eq = Group.getByName(v.equipment)
                                if eq and eq:isExist() then Group.destroy(eq) end
                            end
                        end
                        trigger.action.outTextForGroup(v.groupID, v.fName.."'s locator Beacon no longer transmitting...Return to CSAR stack for further assignment.", 30, false)
                        assignments[c][v.name] = nil
                    else
                        local playerPos = playerUnit:getPoint()
                        local dist = Utils.PointDistance(playerPos, v.coords)
                        local playerAgl = Utils.getAGL(playerPos)
                        local playerHdg = Utils.getHdgFromPosition(playerUnit:getPosition())
                        local clockBearing = Utils.relativeClockBearing(playerPos, v.coords, playerHdg)
                        local playerTypeName = playerUnit:getTypeName()
                        if dist < csarBreakCoverRange then
                            if not v.contact then
                                -- they do want this smoke
                                local smokeColor = smokeColors[v.smokeNum]
                                trigger.action.outTextForGroup(v.groupID, "This is " .. v.fName .. ", have eyes on - popping " .. smokeColor .. " smoke to your " .. clockBearing .. " o'clock.", 30, false)
                                v.contact = true
                                DFS.smokeGroup(v.target, v.smokeNum)
                                v.smokeTime = timer.getTime()
                            else
                                -- too long
                                if (timer.getTime() - v.smokeTime > 300) then
                                    local smokeColor = smokeColors[v.smokeNum]
                                    trigger.action.outTextForGroup(v.groupID, "This is " .. v.fName .. ", popping fresh " .. smokeColor .. " smoke to your " .. clockBearing .. " o'clock.", 30, false)
                                    DFS.smokeGroup(v.target, v.smokeNum)
                                    v.smokeTime = timer.getTime()
                                end
                                if dist < csarBreakCoverRange * 0.5 then
                                    local nicedist = math.floor(dist * 10)/10
                                    local outText = nil
                                    if playerTypeName ~= "AV8BNA" then
                                        outText = "Winch Op: " .. v.fName .. " approx. " .. nicedist .. "m to your " .. clockBearing .. " o'clock."
                                    end
                                    -- hover pick-up check
                                    if dist < csarHoverRadius and playerTypeName ~= "AV8BNA" then
                                        outText = "Winch Op: " .. v.fName .. " approx. " .. nicedist .. "m to your " .. clockBearing .. " o'clock."
                                        if playerAgl <= csarHoverAgl and playerAgl > 3 then
                                            local hoverTime = v.hoverTime
                                            if hoverTime == 0 then
                                                hoverTime = timer.getTime()
                                                v.hoverTime = timer.getTime()
                                            end
                                            hoverTime = timer.getTime() - hoverTime
                                            local countdown = math.floor(csarHoverTime - hoverTime)
                                            outText = "Winch Op: " .. nicedist .. "m to your " .. clockBearing .. " o'clock. Package inbound...(" .. countdown .. "s)"
                                            if hoverTime > csarHoverTime then
                                                outText = "Winch Op: Package secured. " .. v.fName .. " ready for RTB."
                                                if targetGroup and targetGroup:isExist() then
                                                    Group.destroy(targetGroup)
                                                    if v.equipment ~= nil then
                                                        local eq = Group.getByName(v.equipment)
                                                        if eq and eq:isExist() then Group.destroy(eq) end
                                                    end
                                                end
                                                v.status = 1
                                            end
                                        else
                                            outText = "Winch Op: " .. v.fName .. " approx. " .. nicedist .. "m to your " .. clockBearing .. " o'clock - land, or descend to below " .. csarHoverAgl .. "m AGL for winching."
                                            v.hoverTime = 0
                                        end
                                    else
                                        v.hoverTime = 0
                                    end
                                    if outText then trigger.action.outTextForGroup(v.groupID, outText, 30 , true) end
                                else
                                    v.hoverTime = 0
                                end
                            end
                        end
                    end
                elseif v.status == 1 then -- post-pickup state
                    -- no-op
                else -- unexpected status
                    targetGroup = Group.getByName(v.target)
                    if targetGroup and targetGroup:isExist() then
                        Group.destroy(targetGroup)
                        if v.equipment ~= nil then
                            local eq = Group.getByName(v.equipment)
                            if eq and eq:isExist() then Group.destroy(eq) end
                        end
                    end
                    trigger.action.outTextForGroup(v.groupID, v.fName.."'s locator Beacon no longer transmitting...Return to CSAR stack for further assignment.", 30, false)
                    assignments[c][v.name] = nil
                end
            else
                targetGroup = Group.getByName(v.target)
                if targetGroup and targetGroup:isExist() then
                    Group.destroy(targetGroup)
                    if v.equipment ~= nil then
                        local eq = Group.getByName(v.equipment)
                        if eq and eq:isExist() then Group.destroy(eq) end
                    end
                end
                assignments[c][v.name] = nil
            end
        end
    end
end
function csb.startTransmission(args)
    local targetGroup = Group.getByName(args.groupName)
    local radioFreq = args.freq
    local freqType = args.freqType
    local modulation = args.amfm
    local soundFile = args.soundFile
    if targetGroup == nil or targetGroup:getSize() == 0 then return end
    local u = targetGroup:getUnit(1)
    if u == nil or not u:isExist() then return end
    local aiCtrllr = targetGroup:getController()
    local cmd = {}
    if aiCtrllr then
        if freqType ~= "TACAN" then
            cmd.id = "SetFrequency"
            cmd.params = {}
            cmd.params.frequency = radioFreq
            cmd.params.modulation = modulation
            aiCtrllr:setCommand(cmd)
            cmd = {}
            cmd.id = "TransmitMessage"
            cmd.params = {}
            cmd.params.loop = true
            cmd.params.file = soundFile
            aiCtrllr:setCommand(cmd)
        else
            local chAdj = 64
            local baseFreq = 1151
            if radioFreq < 64 then
                chAdj = 1
                baseFreq = 962
            end
            cmd.id = "ActivateBeacon"
            cmd.params = {}
            cmd.params.type = 4
            cmd.params.system = 3
            cmd.params.bearing = true
            cmd.params.callsign = "SOS"
            cmd.params.frequency = (baseFreq + radioFreq - chAdj) * 1000000
        end
    end
end
function csb:onEvent(e)
    if not e.initiator then return end
    local evtInitr = e.initiator
    if not (evtInitr and Unit.isExist(evtInitr) and evtInitr.getPlayerName and evtInitr:getPlayerName() and DFS.heloCapacities[evtInitr:getTypeName()]) then return end
    -- we have a valid player initiated event from a CSAR-capable unit
    local evtId = e.id
    if evtId == 4 or evtId == 55 then -- Landing
        csb.checkCsarLanding(evtInitr)
    end
    --if evtId == 3 or evtId == 54 then -- takeoff
        --csb.checkCsarTakeoff(evtInitr)
    --end
    if evtId == 5 then --crash
        csb.checkCsarCrash(evtInitr)
    end
end
function csb.checkCsarCrash(eUnit)
    if eUnit and eUnit:isExist() and eUnit.getPlayerName then
        local pName = eUnit:getPlayerName()
        local pSide = eUnit:getCoalition()
        if assignments[pSide][pName] then
            local a = assignments[pSide][pName]
            if a.status == 0 then
                local csarGroup = Group.getByName(a.target)
                if csarGroup and csarGroup:isExist() then
                    Group.destroy(csarGroup)
                    if a.equipment ~= nil then
                        local eq = Group.getByName(a.equipment)
                        if eq and eq:isExist() then Group.destroy(eq) end
                    end
                end
            end
            assignments[pSide][pName] = nil
        end
    end
end
function csb.checkCsarLanding(eUnit)
    if eUnit and eUnit:isExist() and eUnit.getPlayerName then
        local pName = eUnit:getPlayerName()
        local pSide = eUnit:getCoalition()
        local pPosn = eUnit:getPoint()
        local bInCsarBase = false
        local sBaseName = "Nowhere"
        if assignments[pSide][pName] then
            local tgt = assignments[pSide][pName].target
            local fName = assignments[pSide][pName].fName
            local coords = assignments[pSide][pName].coords
            local eq = assignments[pSide][pName].equipment
            local zonePoint = nil
            if assignments[pSide][pName].status == 1 then -- check for drop off
                for j = 1, #csarBases[pSide] do
                    zonePoint = trigger.misc.getZone(csarBases[pSide][j])
                    if zonePoint then
                        if Utils.pointInCircleTriggerZone(pPosn, zonePoint) then
                            bInCsarBase = true
                            sBaseName = csarBases[pSide][j]
                        end
                    end
                end
                if bInCsarBase then
                    trigger.action.outTextForCoalition(pSide, pName .. " safely delivered " .. fName .. " to " .. sBaseName .. ".", 30, false)
                    if WWEvents then WWEvents.playerCsarMissionCompleted(pName, pSide, sBaseName," rescued ".. fName .. " from the battlefield.") end
                    assignments[pSide][pName] = nil
                end
            else -- check for pickup
                if Utils.PointDistance(pPosn, coords) < csarPickupRadius then
                    trigger.action.outTextForCoalition(pSide, pName .. " is extracting " .. fName .. "...", 30, false)
                    local args = {}
                    args.pName = pName
                    args.pSide = pSide
                    args.target = tgt
                    args.fName = fName
                    args.equipment = eq
                    timer.scheduleFunction(csb.fakeExtractionTime, args, timer.getTime() + math.random(3,6))
                end
            end
        end
    end
end
function csb.fakeExtractionTime(args)
    local csarGroupName = args.target
    local csarGroup = Group.getByName(csarGroupName)
    if csarGroup and csarGroup:isExist() then
        Group.destroy(csarGroup)
        if args.equipment ~= nil then
            local eq = Group.getByName(args.equipment)
            if eq and eq:isExist() then Group.destroy(eq) end
        end
    end
    trigger.action.outTextForCoalition(args.pSide, args.pName .. " has taken " .. args.fName .. " on board.", 30, true)
    assignments[args.pSide][args.pName].status = 1
end
world.addEventHandler(csb)
csb.load()