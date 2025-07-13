world.event.S_EVENT_WWX_CONVOY_AMBUSH_DETECTED = 8402
world.event.S_EVENT_WWX_CRITICAL_SUPPLY_LEVEL = 8403
world.event.S_EVENT_WWX_SUNSET = 8404
world.event.S_EVENT_WWX_SUB_DETECTED = 8405
world.event.S_EVENT_WWX_CARGO_DELIVERED = 8406
world.event.S_EVENT_WWX_CAS_MISSION_COMPLETED = 8407
world.event.S_EVENT_WWX_CAMPAIGN_COMPLETED = 8408
world.event.S_EVENT_WWX_SUBMARINE_KILL = 8409
world.event.S_EVENT_WWX_SHIP_CAPTURED = 8410
world.event.S_EVENT_WWX_CARGO_STOLEN = 8411
world.event.S_EVENT_WWX_SHIP_TORPEDOED = 8412
world.event.S_EVENT_WWX_CONVOY_KILLED = 8413
world.event.S_EVENT_WWX_CSAR_MISSION_COMPLETED = 8414
world.event.S_EVENT_WWX_FIREMISSION_COMPLETED = 8415
world.event.S_EVENT_WWX_FIREMISSION_KILL = 8416
world.event.S_EVENT_WWX_RACE_PING = 8417
world.event.S_EVENT_WWX_RACE_COMPLETED = 8418
world.event.S_EVENT_WWX_RACE_ENTRANT_RESULT = 8419
world.event.S_EVENT_WWX_BATTLE_POSITION_CAPTURE = 8420
world.event.S_EVENT_WWX_FRONT_DEPOT_DESTROYED = 8421
world.event.S_EVENT_WWX_REAR_DEPOT_DESTROYED = 8422
world.event.S_EVENT_WWX_TANKCPY_STALLED = 8423
world.event.S_EVENT_WWX_CONVOY_DESTROYED = 8424
world.event.S_EVENT_WWX_SHIP_SUNK = 8425

WWEvents = {}
WWEvents.latches = {
    [1] = {
        front = {
            [1] = false,
            [2] = false,
            [3] = false,
        },
        rear = {
            [1] = false,
            [2] = false,
            [3] = false,
        }
    },
    [2] = {
        front = {
            [1] = false,
            [2] = false,
            [3] = false,
        },
        rear = {
            [1] = false,
            [2] = false,
            [3] = false,
        }
    }
}
function WWEvents.convoyAmbushDetected(coalitionId, destination)
    trigger.action.outTextForCoalition(coalitionId, "Intelligence has discovered an ambush on the route to front depot " .. destination .. "!", 20, false)
    local Event = {
        id = world.event.S_EVENT_WWX_CONVOY_AMBUSH_DETECTED,
        time = timer:getTime(),
        coalition = coalitionId,
        destination = destination,
        text = "Intelligence has discovered an ambush on the route to front depot " .. destination .. "!"
    }
    world.onEvent(Event)
end
function WWEvents.criticalSupplyLevel(coalitionId, supplyType, supplyTypeString, depotString)
    env.info("criticalSupplyLevel event triggered: " .. coalitionId .. "-" ..supplyTypeString .. "-" .. depotString, false)
    trigger.action.outTextForCoalition(coalitionId, supplyTypeString .. " levels are critically low! Bring " .. supplyTypeString .. " to the " .. depotString .. ".", 20, false)
    local Event = {
        id = world.event.S_EVENT_WWX_CRITICAL_SUPPLY_LEVEL,
        time = timer:getTime(),
        coalition = coalitionId,
        supplyType = supplyType,
        text = supplyTypeString .. " levels are critically low! Bring " .. supplyTypeString .. " to the " .. depotString .. "."
    }
    world.onEvent(Event)
end
function WWEvents.sunsetDetected()
    env.info("It's G O L D E N H O U R!!", false)
    local Event = {
        id = world.event.S_EVENT_WWX_SUNSET,
        time = timer:getTime()
    }
    world.onEvent(Event)
end
function WWEvents.sonobuoyContact(coalitionId, buoyId, range, frequency, freqType)
    env.info("Sonobuoy detection event triggered: " .. coalitionId.."-"..buoyId.."-"..range, false)
    local teamString = "Red"
    if coalitionId == 2 then teamString = "Blue" end
    local Event = {
        id = world.event.S_EVENT_WWX_SUB_DETECTED,
        time = timer:getTime(),
        coalition = coalitionId,
        buoyId = buoyId,
        range = range,
        frequency = frequency,
        freqType = freqType,
        text = teamString.." sonobuoy has detected a submarine within " .. range .. "! Buoy: " .. buoyId .. " | " .. frequency..freqType
    }
    world.onEvent(Event)
end
function WWEvents.playerCargoDelivered(playerName, coalitionId, cargoType, deliveryLocation, deliveryMessage)
    env.info("Player cargo delivery notification triggered!", false)
    local Event = {
        id = world.event.S_EVENT_WWX_CARGO_DELIVERED,
        time = timer:getTime(),
        playerName = playerName,
        coalition = coalitionId,
        cargoType = cargoType,
        deliveryLocation = deliveryLocation,
        text = deliveryMessage
    }
    world.onEvent(Event)
end
function WWEvents.playerCasMissionCompleted(playerName, coalitionId, casMissionCompleteMessage)
    local Event = {
        id = world.event.S_EVENT_WWX_CAS_MISSION_COMPLETED,
        time = timer:getTime(),
        playerName = playerName,
        coalition = coalitionId,
        text = casMissionCompleteMessage
    }
    world.onEvent(Event)
end
function WWEvents.campaignCompleted(coalitionId)
    local Event = {
        id = world.event.S_EVENT_WWX_CAMPAIGN_COMPLETED,
        time = timer:getTime(),
        -- number. 1 = red, 2 = blue
        winningTeam = coalitionId
    }
    world.onEvent(Event)
end
function WWEvents.playerCapturedShip(playerName, coalitionId, message)
    env.info("player ship capture event fired", false)
    local Event = {
        id = world.event.S_EVENT_WWX_SHIP_CAPTURED,
        time = timer:getTime(),
        playerName = playerName,
        coalition = coalitionId,
        text = message
    }
    world.onEvent(Event)
end
function WWEvents.playerStoleCargo(playerName, coalitionId, message)
    env.info("player stolen cargo event fired", false)
    local Event = {
        id = world.event.S_EVENT_WWX_CARGO_STOLEN,
        time = timer:getTime(),
        playerName = playerName,
        coalition = coalitionId,
        text = message
    }
    world.onEvent(Event)
end
function WWEvents.playerDestroyedSubmarine(playerName, coalitionId, message)
    env.info("player sub kill event fired", false)
    local Event = {
        id = world.event.S_EVENT_WWX_SUBMARINE_KILL,
        time = timer:getTime(),
        playerName = playerName,
        coalition = coalitionId,
        text = message
    }
    world.onEvent(Event)
end
function WWEvents.playerTorpedoedShip(playerName, message, coalitionId)
    env.info("player torpedo hit event fired", false)
    local Event = {
        id = world.event.S_EVENT_WWX_SHIP_TORPEDOED,
        time = timer:getTime(),
        coalition = coalitionId,
        playerName = playerName,
        text = message
    }
    world.onEvent(Event)
end
function WWEvents.convoyKilled(coalitionId, message, listOfPlayers)
    env.info("convoy killed event fired", false)
    local Event = {
        id = world.event.S_EVENT_WWX_CONVOY_KILLED,
        time = timer:getTime(),
        coalition = coalitionId,
        text = message,
        listOfPlayers = listOfPlayers
    }
    world.onEvent(Event)
end
function WWEvents.playerCsarMissionCompleted(playerName, coalitionId, baseName, csarMissionCompleteMessage)
    local Event = {
        id = world.event.S_EVENT_WWX_CSAR_MISSION_COMPLETED,
        time = timer:getTime(),
        playerName = playerName,
        coalition = coalitionId,
        baseName = baseName,
        text = csarMissionCompleteMessage
    }
    world.onEvent(Event)
end
function WWEvents.fireMissionCompleted(coalitionId, playerName, kills)
    env.info("fire mission completed event fired", false)
    local Event = {
        id = world.event.S_EVENT_WWX_FIREMISSION_COMPLETED,
        time = timer:getTime(),
        coalition = coalitionId,
        playerName = playerName,
        kills = kills,
        text = "'s fire mission achieved " .. kills .. " kill(s)!"
    }
    world.onEvent(Event)
end
function WWEvents.raceNotification(categoryId)
    local Event = {
        id = world.event.S_EVENT_WWX_RACE_PING,
        time = timer.getTime(),
        category = categoryId,
        text = "races are happening NOW. Hop on!"
    }
    world.onEvent(Event)
end

function WWEvents.raceCompleted(raceId, winner, winningTime, message, courseId)
    local Event = {
        id = world.event.S_EVENT_WWX_RACE_COMPLETED,
        time = timer.getTime(),
        raceId = raceId,
        winner = winner, -- string
        winningTime = winningTime, -- number of seconds
        text = message, -- string
        courseId = courseId,
    }
    world.onEvent(Event)
end

function WWEvents.raceEntrantResult(raceId, categoryId, playerName, finishTime, totalTime, aircraft, courseId)
    local Event = {
    id = world.event.S_EVENT_WWX_RACE_ENTRANT_RESULT,
    time = timer.getTime(),
    raceId = raceId,
    category = categoryId,
    playerName = playerName,
    finishTime = finishTime,
    totalTime = totalTime,
    aircraft = aircraft,
    courseId = courseId,
    }
    world.onEvent(Event)
end

function WWEvents.battlePositionCapture(bpId, message, fromCoa, toCoa)
    local Event = {
        id = world.event.S_EVENT_WWX_BATTLE_POSITION_CAPTURE,
        time = timer:getTime(),
        bpId = bpId,
        text = "BP#"..bpId..message,
        fromCoa = fromCoa,
        toCoa = toCoa
    }
    world.onEvent(Event)
end

function WWEvents.frontDepotDestroyed(coalitionId)
    local Event = {
        id = world.event.S_EVENT_WWX_FRONT_DEPOT_DESTROYED,
        time = timer.getTime(),
        coalition = coalitionId
    }
    world.onEvent(Event)
end

function WWEvents.rearDepotDestroyed(coalitionId)
    local Event = {
        id = world.event.S_EVENT_WWX_REAR_DEPOT_DESTROYED,
        time = timer.getTime(),
        coalition = coalitionId
    }
    world.onEvent(Event)
end

function WWEvents.tankCpyStalled(coalitionId)
    local Event = {
        id = world.event.S_EVENT_WWX_TANKCPY_STALLED,
        time = timer.getTime(),
        coalition = coalitionId
    }
    world.onEvent(Event)
end

function WWEvents.convoyDestroyed(coalitionId)
    local Event = {
        id = world.event.S_EVENT_WWX_CONVOY_DESTROYED,
        time = timer.getTime(),
        coalition = coalitionId
    }
    world.onEvent(Event)
end

function WWEvents.shipSunk(coalitionId)
    local Event = {
        id = world.event.S_EVENT_WWX_SHIP_SUNK,
        time = timer.getTime(),
        coalition = coalitionId
    }
    world.onEvent(Event)
end
