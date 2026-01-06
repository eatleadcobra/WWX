Sonobuoys = {}
local sb = {}
local buoyId = 1

local khzFreqTable = {
    [1] = 150,
    [2] = 125
}
local khZAvailableTable = {
    [1] = 22,
    [2] = 21
}
local khzIntervalTable = {
    [1] = 50,
    [2] = 50,
}
local maxKHzTable = {
    [1] = 1250,
    [2] = 1225
}
local startKHzTable = {
    [1] = 150,
    [2] = 200
}
local buoyCreatedCount = {
    [1] = {
        det = 0,
        khz = 0,
        mhz = 0,
        yak = 0
    },
    [2] = {
        det = 0,
        khz = 0,
        mhz = 0,
        yak = 0
    }
}
local yakfreqs = {
    [1] = 212,
    [2] = 222,
    [3] = 312,
    [4] = 322,
    [5] = 412,
    [6] = 422,
    [7] = 512,
    [8] = 522
}
local yakfreqnames = {
    [1] = "ARK-15M: Ch 1 O",
    [2] = "ARK-15M: Ch 1 I",
    [3] = "ARK-15M: Ch 2 O",
    [4] = "ARK-15M: Ch 2 I",
    [5] = "ARK-15M: Ch 3 O",
    [6] = "ARK-15M: Ch 3 I",
    [7] = "ARK-15M: Ch 4 O",
    [8] = "ARK-15M: Ch 4 I"
}
local startMhzFreq = 3.0
local mhzFreq = 3.0
local maxMhz = 18.0
local mhzInterval = 0.1
local mhzAvailable = 150
local detFreq = 1
local sbCount = 20
local buoyLifetime = 5400
local planeRadioTypes = {
    det = {
        ["P-51D"] = 1,
        ["TF-51D"] = 2,
        ["P-47D-30bl1"] = 3,
        ["P-47D-40"] = 4,
    },
    khz = {
        ["MiG-19P"] = 1,
        ["Mi-8MT"] = 2,
        ["Mi-24P"] = 3,
        ["C-101CC"] = 4,
        ["SA342L"] = 5,
        ["SA342Minigun"] = 6,
        ["UH-1H"] = 7,
    },
    mhz = {
        ["MosquitoFBMkVI"] = 1,
        ["C-130J-30"] = 2,
    },
    yak = {
        ["Yak-52"] = 1
    }
}
local mpra = {
    ["C-130J-30"] = 1,
    ["MosquitoFBMkVI"] = 1,
    ["C-101CC"] = 1,
    ["Mi-8MT"] = 1,
    ["UH-1H"] = 1,
    ["P-47D-30bl1"] = 1,
    ["P-47D-40"] = 1,
}
local coalitions = {1, 2}
local playerCount = {

}
local detrolaFreqs = {
    [1] = {det = 200, mhz = 100},
    [2] = {det = 210, mhz = 112},
    [3] = {det = 220, mhz = 122},
    [4] = {det = 230, mhz = 131},
    [5] = {det = 240, mhz = 139},
    [6] = {det = 260, mhz = 152},
    [7] = {det = 280, mhz = 163},
    [8] = {det = 300, mhz = 171},
    [9] = {det = 320, mhz = 178},
    [10] = {det = 360, mhz = 190},
    [11] = {det = 400, mhz = 200},
}
local coalitionSmokeColors = {
    [1] = 1,
    [2] = 4
}
local sbEvents = {}
function sbEvents:onEvent(event)
    --on takeoff 
    if event.id == world.event.S_EVENT_TAKEOFF then
        if event.initiator ~= nil and event.initiator.getGroup then
            if event.initiator:getGroup() ~= nil then
                playerCount[event.initiator:getGroup():getName()] = sbCount
                local initUnit = event.initiator:getGroup():getUnit(1)
                if initUnit then
                    if mpra[initUnit:getTypeName()] then
                        playerCount[event.initiator:getGroup():getName()] = sbCount*2
                    else
                        playerCount[event.initiator:getGroup():getName()] = sbCount
                    end
                end
            end
        end
    end
end
-- id, location, markId, startTime, freqs{}, message, ownerGroupName
local buoys = {
    [1] = {},
    [2] = {}
}
local beaconSounds = {
    ["1000m"] = "l10n/DEFAULT/WWXSub_Submarine Heavy Rumble.ogg",
    ["2000m"] = "l10n/DEFAULT/WWXSub_Submarine Medium Rumble.ogg",
    ["4000m"] = "l10n/DEFAULT/WWXSub_Submarine Light Rumble.ogg",
    ["none detected"] = "l10n/DEFAULT/WWXSub_No Contact.ogg"
}
--groupName, coalition
function sb.createBuoy(param)
    local group = Group.getByName(param.groupName)
    if group ~= nil then
        local buoyCount = playerCount[param.groupName]
        if buoyCount and buoyCount > 0 then
            local unit = group:getUnit(1)
            if unit ~= nil then
                local location = unit:getPoint()
                local isWater = land.getSurfaceType({x = location.x, y = location.z})
                if isWater == 2 or isWater == 3 then
                    local buoyMarkId = DrawingTools.newMarkId()
                    local khzGpName = "None"
                    local buoyKhzFreq = "None"
                    local buoyKhzMsg = 0
                    local mhzGpName = "None"
                    local buoyDetFreq = "None"
                    local buoyMhzFreq = "None"
                    if buoyCreatedCount[param.coalition].khz < khZAvailableTable[param.coalition] and planeRadioTypes.khz[unit:getTypeName()] ~= nil then
                        buoyKhzFreq = tostring(khzFreqTable[param.coalition])
                        khzFreqTable[param.coalition] = khzFreqTable[param.coalition] + khzIntervalTable[param.coalition]
                        if khzFreqTable[param.coalition] > 500 and khzFreqTable[param.coalition] < 600 then khzFreqTable[param.coalition] = 600 end
                        if khzFreqTable[param.coalition] > maxKHzTable[param.coalition] then khzFreqTable[param.coalition] = startKHzTable[param.coalition] end
                        buoyCreatedCount[param.coalition].khz = buoyCreatedCount[param.coalition].khz + 1
                        timer.scheduleFunction(sb.reduceCreatedCount, {coalition = param.coalition, freqType = "khz"}, timer:getTime() + buoyLifetime)
                    end
                    if buoyCreatedCount[param.coalition].det < #detrolaFreqs and planeRadioTypes.det[unit:getTypeName()] ~= nil then
                        buoyDetFreq = tostring(detrolaFreqs[detFreq].det)
                        detFreq = detFreq + 1
                        if detFreq > 11 then detFreq = 1 end
                        buoyCreatedCount[param.coalition].det = buoyCreatedCount[param.coalition].det + 1
                        timer.scheduleFunction(sb.reduceCreatedCount, {coalition = param.coalition, freqType = "det"}, timer:getTime() + buoyLifetime)
                    end
                    if buoyCreatedCount[param.coalition].mhz < mhzAvailable and planeRadioTypes.mhz[unit:getTypeName()] ~= nil then
                        buoyMhzFreq = tostring(mhzFreq)
                        mhzFreq = mhzFreq + mhzInterval
                        if mhzFreq > maxMhz then mhzFreq = startMhzFreq end
                        buoyCreatedCount[param.coalition].mhz = buoyCreatedCount[param.coalition].mhz + 1
                        timer.scheduleFunction(sb.reduceCreatedCount, {coalition = param.coalition, freqType = "mhz"}, timer:getTime() + buoyLifetime)
                    end
                    if buoyCreatedCount[param.coalition].yak < #yakfreqs and planeRadioTypes.yak[unit:getTypeName()] ~= nil then
                        buoyCreatedCount[param.coalition].yak = buoyCreatedCount[param.coalition].yak + 1
                        buoyKhzFreq = tostring(yakfreqs[buoyCreatedCount[param.coalition].yak])
                        buoyKhzMsg = yakfreqnames[buoyCreatedCount[param.coalition].yak]
                        timer.scheduleFunction(sb.reduceCreatedCount, {coalition = param.coalition, freqType = "yak"}, timer:getTime() + buoyLifetime)
                    end
                    buoys[param.coalition][#buoys[param.coalition]+1] = {
                        id = buoyId,
                        location = location,
                        markId = buoyMarkId,
                        flag = VB.createBuoy(location, param.coalition),
                        startTime = timer:getTime(),
                        freqs = {
                            ["KHz"] = {freq = buoyKhzFreq, beaconGroupName = khzGpName},
                            ["MHz"] = {freq = buoyDetFreq, beaconGroupName = mhzGpName},
                            ["MCs"] = {freq = buoyMhzFreq, beaconGroupName = "none"}
                        },
                        message = "Starting",
                        ownerGroupName = param.groupName
                    }
                    if unit:getTypeName() == "Yak-52" and buoyKhzMsg ~= 0 then
                        buoyKhzFreq = tostring(buoyKhzMsg)
                    end
                    local markMsg = "Buoy: " .. buoyId .. "\nFrequency KHz: " .. buoyKhzFreq .."\nDetrola: " .. buoyDetFreq .. "\nMCs(MHz): " .. buoyMhzFreq
                    if CODAR then
                        CODAR.newBuoy(param.coalition, location, buoyId)
                    end
                    trigger.action.markToCoalition(buoyMarkId, markMsg, location, tonumber(param.coalition), true)
                    buoyCount = buoyCount - 1
                    playerCount[param.groupName] = buoyCount
                    buoyId = buoyId + 1
                end
            end
        else
            trigger.action.outTextForGroup(group:getID(), "You are out of sonobuoys!", 15)
        end
    end
end
--coalition, buoyType
function sb.reduceCreatedCount(param)
    buoyCreatedCount[param.coalition][param.freqType] = buoyCreatedCount[param.coalition][param.freqType] - 1
    if buoyCreatedCount[param.coalition][param.freqType] < 0 then buoyCreatedCount[param.coalition][param.freqType] = 0 end
end
--coalition, index
function sb.destroyBuoy(param)
    --remove mark
    trigger.action.removeMark(buoys[param.coalition][param.index].markId)
    --destroy flag
    VB.destroyStatic(buoys[param.coalition][param.index].flag)
    --remove buoy
    if CODAR then
        CODAR.removeBuoy(param.coalition, buoys[param.coalition][param.index].id)
    end
    table.remove(buoys[param.coalition], param.index)
end
--coalition, index
function sb.checkBuoy(param)
    local buoy = buoys[param.coalition][param.index]
    if buoy.message ~= nil and buoy.message ~= "Starting" then
        trigger.action.stopRadioTransmission(buoy.message)
    end
    local currentTime = timer:getTime()
    if currentTime - buoy.startTime <= buoyLifetime then
        local range = sb.searchForSubs(buoy.location)
        local rangeMsg = "Submarine detected within " .. range
        if range == "none detected" then
            rangeMsg = "No submarines detected"
        elseif WWEvents and range ~= "none detected" then
            local buoyType = nil
            if buoy.freqs["MHz"].freq == "None" and buoy.freqs["MCs"].freq == "None" and buoy.freqs["KHz"].freq ~= "None" then
                buoyType = "KHz"
            elseif buoy.freqs["MHz"].freq == "None" and buoy.freqs["MCs"].freq ~= "None" and buoy.freqs["KHz"].freq == "None" then
                buoyType = "MCs"
            elseif buoy.freqs["MHz"].freq ~= "None" and buoy.freqs["MCs"].freq == "None" and buoy.freqs["KHz"].freq == "None" then
                buoyType = "MHz"
            else
                buoyType = "No Freq"
            end
            if (buoy.eventRange == nil or buoy.eventRange ~= range) then
                local frequency = 0
                if buoy.freqs[buoyType] then
                    frequency = buoy.freqs[buoyType].freq
                end
                if buoyType == "MHz" then buoyType = " Detrola" end
                WWEvents.sonobuoyContact(param.coalition, buoy.id, range, tostring(frequency), buoyType)
                buoy.eventRange = range
            end
        end
        buoys[param.coalition][param.index].message = rangeMsg
        local messageMHz = buoy.id
        local messageKHz = buoy.id
        local messageMCs =  buoy.id
        sb.transmitBeacon(buoy.freqs["MHz"].freq, messageMHz, range, buoys[param.coalition][param.index].location, "Det")
        sb.transmitBeacon(buoy.freqs["MCs"].freq, messageMCs, range, buoys[param.coalition][param.index].location, "MHz")
        sb.transmitBeacon(buoy.freqs["KHz"].freq, messageKHz, range, buoys[param.coalition][param.index].location, "KHz")
    else
        sb.destroyBuoy(param)
    end
end
function sb.checkBuoyLoop()
    if #buoys > 0 then
        for j = 1, 2 do
            local startingSize = #buoys[j]
            for i=1, #buoys[j] do
                sb.checkBuoy({coalition = j, index = i})
                if #buoys[j] < startingSize then break end
            end
        end
    end
    timer.scheduleFunction(sb.checkBuoyLoop, nil, timer:getTime() + 15)
end
function sb.searchForSubs(location)
    local closestSub = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = location,
            radius = 4000
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 and foundItem:isExist() and foundItem:isActive() and (SUBTYPE and (foundItem:getTypeName() == SUBTYPE[1] or foundItem:getTypeName() == SUBTYPE[2])) then
            local subPoint = foundItem:getPoint()
            if subPoint ~= nil then
                env.info("Found sub at point X: " .. subPoint.x .. " Y: " .. subPoint.z, false)
                local xDistance = math.abs(location.x - subPoint.x)
                local yDistance = math.abs(location.z - subPoint.z)
                local distance = math.sqrt(xDistance*xDistance + yDistance*yDistance)
                if distance ~= nil then
                    if closestSub.distance == nil or distance < closestSub.distance then
                        closestSub.distance = distance
                        closestSub.point = subPoint
                    end
                end
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    local distanceString = "none detected"
    if closestSub ~= nil and closestSub.distance ~= nil then
        if closestSub.distance <= 1000 then
           distanceString = "1000m"
        elseif closestSub.distance <= 2000 then
            distanceString = "2000m"
        elseif closestSub.distance <= 4000 then
            distanceString = "4000m"
        end
    end
    return distanceString
end
function sb.transmitBeacon(freq, msg, range, point, txType)
    if freq ~= nil and freq ~= "None" then
        if txType == "MHz" then
            freq = tonumber(freq) * 1000000
        elseif txType == "KHz" then
            freq = (tonumber(freq) - 4 ) * 1000
        elseif txType == "Det" then
            local txFreq = 0
            for i = 1, #detrolaFreqs do
                if detrolaFreqs[i].det == tonumber(freq) then
                    txFreq = detrolaFreqs[i].mhz
                end
            end
            if txFreq ~= 0 then
                freq = tonumber(txFreq) * 1000000
            end
        end
        trigger.action.radioTransmission(beaconSounds[range], point, 0, true, freq, 300, msg)
    end
end
function sb.checkBuoys(groupName)
    local msgGroup = Group.getByName(groupName)
    local groupCoalition = msgGroup:getCoalition()
    if msgGroup ~= nil then
        local chkMsg = ""
        local msgUnit = msgGroup:getUnit(1)
        if msgUnit ~= nil then
            local msgType = msgUnit:getTypeName()
            for i=1, #buoys[groupCoalition] do
                local buoyNoFreq = buoys[groupCoalition][i].freqs["KHz"].freq == "None" and buoys[groupCoalition][i].freqs["MHz"].freq == "None" and buoys[groupCoalition][i].freqs["MCs"].freq == "None"
                local buoyKhzOnly = buoys[groupCoalition][i].freqs["KHz"].freq ~= "None" and buoys[groupCoalition][i].freqs["MHz"].freq == "None" and buoys[groupCoalition][i].freqs["MCs"].freq == "None"
                local buoyDetOnly = buoys[groupCoalition][i].freqs["KHz"].freq == "None" and buoys[groupCoalition][i].freqs["MHz"].freq ~= "None" and buoys[groupCoalition][i].freqs["MCs"].freq == "None"
                local buoyMhzOnly = buoys[groupCoalition][i].freqs["KHz"].freq == "None" and buoys[groupCoalition][i].freqs["MHz"].freq ~= "None" and buoys[groupCoalition][i].freqs["MCs"].freq ~= "None"

                if buoyNoFreq == true or (buoyKhzOnly and planeRadioTypes.khz[msgType] == nil) or (buoyDetOnly and planeRadioTypes.det[msgType] == nil) or (buoyMhzOnly and planeRadioTypes.mhz[msgType] == nil) then
                    chkMsg = chkMsg .. "Buoy " .. buoys[groupCoalition][i].id .. ": " .. buoys[groupCoalition][i].message .."\n"
                end
            end
        end
        trigger.action.outTextForGroup(msgGroup:getID(),chkMsg, 30, false)
    end
end
function sb.dropFlare(groupName)
    local flareGroup = Group.getByName(groupName)
    if flareGroup ~= nil then
        local flareUnit = flareGroup:getUnit(1)
        if flareUnit ~= nil then
            local flarePoint = flareUnit:getPoint()
            if flarePoint ~= nil then
                trigger.action.illuminationBomb(flarePoint, 5000)
            end
        end
    end
end
function sb.dropMarker(groupName)
    local flareGroup = Group.getByName(groupName)
    if flareGroup ~= nil then
        local flareUnit = flareGroup:getUnit(1)
        if flareUnit ~= nil then
            local flarePoint = flareUnit:getPoint()
            if flarePoint ~= nil then
                local flarePointTerrainType = land.getSurfaceType({x = flarePoint.x, y = flarePoint.z})
                if (flarePointTerrainType == 2 or flarePointTerrainType == 3) then
                    flarePoint.y = 0
                    trigger.action.smoke(flarePoint, coalitionSmokeColors[flareGroup:getCoalition()])
                else
                    trigger.action.outTextForGroup(flareGroup:getID(), "These markers can only be dropped over water", 10, false)
                end
            end
        end
    end
end
-- groupId, sound
function sb.testSound(param)
    trigger.action.outSoundForGroup(param.groupId, beaconSounds[param.sound])
end
function sb.faq(groupId)
    local msg = "Drop sonobuoys using this radio menu.\nWhen dropped a markpoint will appear on the F10 map.\nThis mark displays the radio frequency of the buoy.\nTune to this frequency to listen to the buoy.\nThe training functions will play the sounds corresponding to different detection states.\nEach buoy has a range of 4km and lasts for 1 hour.\nIt is useful to learn how to use the radio navigation functions to find your way back to your beacons."
    trigger.action.outTextForGroup(groupId, msg, 45, false)
end
function Sonobuoys.addDevBuoy(coalition, location)
    local buoyMarkId = DrawingTools.newMarkId()
    buoys[coalition][#buoys[coalition]+1] = {
        id = buoyId,
        location = location,
        markId = buoyMarkId,
        startTime = timer:getTime(),
        freqs = {
            ["KHz"] = {freq = "None", beaconGroupName = "NA"},
            ["MHz"] = {freq = "None", beaconGroupName = "NA"},
            ["MCs"] = {freq = "None", beaconGroupName = "NA"}
        },
        message = "Starting",
        ownerGroupName = "Dev Buoy"
    }
    trigger.action.markToCoalition(buoyMarkId, "Buoy: " .. buoyId, location, tonumber(coalition), true)
    buoyId = buoyId + 1
end
function Sonobuoys.addRadioCommandsForFixedWingGroup(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup ~= nil then
        local addID = addGroup:getID()
        if coalitions[addGroup:getCoalition()] ~= nil then
            --if enabledTypeNames[addGroup:getUnit(1):getTypeName()] ~= nil then
                local sbMenu = missionCommands.addSubMenuForGroup(addID, "Sonobuoys", nil)
                missionCommands.addCommandForGroup(addID, "Drop Sonobuoy", sbMenu, sb.createBuoy, {groupName = groupName, coalition = addGroup:getCoalition()})
                missionCommands.addCommandForGroup(addID, "Drop Illumination Flare", sbMenu, sb.dropFlare, groupName)
                missionCommands.addCommandForGroup(addID, "Drop Smoke Marker", sbMenu, sb.dropMarker, groupName)
                missionCommands.addCommandForGroup(addID, "Check Buoys", sbMenu, sb.checkBuoys, groupName)
                local sbTestSubMenu = missionCommands.addSubMenuForGroup(addID, "Training Sounds and Instructions", sbMenu)
                missionCommands.addCommandForGroup(addID, "How to use", sbTestSubMenu, sb.faq, addID)
                missionCommands.addCommandForGroup(addID, "Training - No Sub Detected", sbTestSubMenu, sb.testSound, {groupId = addID, sound = "none detected"})
                missionCommands.addCommandForGroup(addID, "Training - 1km or less", sbTestSubMenu, sb.testSound, {groupId = addID, sound = "1000m"})
                missionCommands.addCommandForGroup(addID, "Training - 2km or less", sbTestSubMenu, sb.testSound, {groupId = addID, sound = "2000m"})
                missionCommands.addCommandForGroup(addID, "Training - 4km or less", sbTestSubMenu, sb.testSound, {groupId = addID, sound = "4000m"})
            --end
        end
    end
end
function Sonobuoys.removeRadioCommandsForGroup(groupID)
    missionCommands.removeItemForGroup(groupID, {[1] = "Sonobuoys"})
end
world.addEventHandler(sbEvents)
sb.checkBuoyLoop()