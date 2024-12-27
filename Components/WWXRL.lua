--requires Utils.lua
local wwxrl = {}
local gateLimit = 10
local AGLlimit = 35
local countdownDuration = 20
local finalCountdown = 5
local raceCooldownTime = 30
local minimumRacers = 1 -- for testing, should be 2 
local messageDuration = 5
local newRaceID = 1
local raceUpdateRate = 0.2
local currentRace = {}
local racerQueue = {}
local racingGroupIdentifier = "RACER"
local racingStatus = {
    ["Pre-Race"] = 1,
    ["In Progress"] = 2,
    ["Completed"] = 3
}
local raceTemplate = {
    raceID = 0,
    racers = {},
    status = 1,
    gates = {},
    finalGate = 0,
    winner = "",
    winningTime = 0,
    countdownStarted = false,
    cooldownStarted = false
}
function raceTemplate:addRacer(racer)
    self.racers[#self.racers+1] = racer
end
local racerTemplate = {
    groupID = 0,
    unitName = "",
    playerName = "",
    startTime = 0,
    endTime = 0,
    currentGate = 0,
    penaltyTime = 0,
    completed = false,
    disqualified = false,
}
local raceEvents = {}
function raceEvents:onEvent(event)
    --on birth
    if (event.id == world.event.S_EVENT_BIRTH) then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group then
                local groupName = group:getName()
                if string.find(groupName, racingGroupIdentifier) then
                    env.info("Racer group spawned, creating racer", false)
                    trigger.action.outText("Racer group spawned, creating racer", 5, false)
                    wwxrl.createNewRacer(groupName)
                end
            end
        end
    end
end
world.addEventHandler(raceEvents)

function wwxrl.newRaceID()
    local newID = newRaceID
    newRaceID = newRaceID+1
    return newID
end
function wwxrl.newRacerID()
    local newID = newRaceID
    newRaceID = newRaceID+1
    return newID
end
function wwxrl.getGates()
    for i = 1, gateLimit do
        local gateZone = trigger.misc.getZone("Gate-"..i)
        if gateZone then
            raceTemplate.gates[#raceTemplate.gates+1] = gateZone.point
            trigger.action.outText("Added gate " .. i, 2, false)
        else
            break
        end
    end
    raceTemplate.finalGate = #raceTemplate.gates
end
function wwxrl.createNewRace()
    env.info("creating new race table", false)
    trigger.action.outText("creating new race table", 5, false)
    currentRace = {}
    local newRaceTable = Utils.deepcopy(raceTemplate)
    newRaceTable.raceID = wwxrl.newRaceID()
    currentRace = newRaceTable
    currentRace.status = racingStatus["Pre-Race"]
    env.info("created race " .. newRaceTable.raceID, false)
    trigger.action.outText("created race " .. newRaceTable.raceID, 5, false)
    trigger.action.outText("New Race: " .. Utils.dump(currentRace), 30, false)
    wwxrl.trackRace(newRaceTable.raceID)
end
function wwxrl.trackRace(raceID)
    local raceTable = currentRace
    if raceTable then
        local raceStatus = raceTable.status
        if raceStatus == racingStatus["In Progress"] then
            local raceCompleted = false
            for i = 1, #raceTable.racers do
                local racer = raceTable.racers[i]
                if racer then
                    local raceUnit = Unit.getByName(racer.unitName)
                    if raceUnit then
                        local racerPoint = raceUnit:getPoint()
                        if racerPoint then
                            if racer.currentGate == 0 then
                                racer.currentGate = 1
                                if Utils.PointDistance(racerPoint, trigger.misc.getZone("Race Start Zone").point) > trigger.misc.getZone("Race Start Zone").radius then
                                    trigger.action.outTextForGroup(racer.groupID, "You are disqualified because you were not within the starting zone and altitude limits at race start.", 20, false)
                                    racer.disqualified = true
                                end
                            end
                            local gatePoint = currentRace.gates[racer.currentGate]
                            if gatePoint and not racer.disqualified then
                                local elapsedTime = timer.getTime() - racer.startTime
                                local elapsedSeconds = tostring(math.fmod(elapsedTime, 60))
                                local elapsedMinutes = tostring(math.floor(elapsedTime/60))
                                if tonumber(elapsedSeconds) < 10 then elapsedSeconds = "0"..elapsedSeconds end
                                if tonumber(elapsedMinutes) < 10 then elapsedMinutes = "0"..elapsedMinutes end
                                trigger.action.outTextForGroup(racer.groupID, "00:"..elapsedMinutes..":"..elapsedSeconds.." + " .. racer.penaltyTime, 0.2, false)
                                local distanceToGate = Utils.PointDistance(racerPoint, gatePoint)
                                if distanceToGate < gateLimit and Utils.getAGL(racerPoint) <= AGLlimit then
                                    trigger.action.outTextForGroup(racer.groupID, "Gate " .. racer.currentGate .. " completed!", 1, false)
                                    racer.currentGate = racer.currentGate + 1
                                    if (racer.currentGate > currentRace.finalGate) and not racer.completed then
                                        racer.endTime = timer.getTime()
                                        raceCompleted = true
                                        racer.completed = true
                                    end
                                elseif Utils.getAGL(racerPoint) > AGLlimit then
                                    trigger.action.outTextForGroup(racer.groupID, "You are too high! Penalized!", 1, false)
                                    racer.penaltyTime = racer.penaltyTime + raceUpdateRate
                                    if racer.penaltyTime > raceCooldownTime then
                                        trigger.action.outTextForGroup(racer.groupID, "Maximum penalty time exceeded, time to die.", 1, false)
                                        trigger.action.explosion(racerPoint, 300)
                                    end
                                end
                            end
                        else
                            --this might be a bad idea
                            racer = {}
                        end
                    end
                end
                ::continue::
            end
            if raceCompleted and not currentRace.cooldownStarted then
                currentRace.cooldownStarted = true
                wwxrl.messageToRacers("Race ending in " .. raceCooldownTime .. " seconds")
                timer.scheduleFunction(wwxrl.endRace, nil, timer.getTime() + raceCooldownTime)
            end
            --for each contestant, check distance to next gate and advance gates if in range and in limits
        elseif raceStatus == racingStatus["Pre-Race"] then
            for i = 1, #racerQueue do
                local racer = racerQueue[i]
                if racer then
                    currentRace:addRacer(racer)
                    env.info("Added racer " .. racer.playerName .. " to race " .. raceID, false)
                end
            end
            racerQueue = {}
            if #raceTable.racers >= minimumRacers and not raceTable.countdownStarted then
                wwxrl.countdown(raceID)
                raceTable.countdownStarted = true
            end
        elseif raceStatus == racingStatus["Completed"] then
            env.info("Race " .. raceID .. " completed. Winner is " .. raceTable.winner, false)
            wwxrl.messageToRacers("Race is completed, the winner is " .. raceTable.winner .. " with a time of " .. raceTable.winningTime)
            --handle completed race and then break loop
            return
        end
    end
    timer.scheduleFunction(wwxrl.trackRace, raceID, timer.getTime() + raceUpdateRate)
end
function wwxrl.createNewRacer(groupName)
    local racerGroup = Group.getByName(groupName)
    if racerGroup then
        local racerUnit = racerGroup:getUnit(1)
        if racerUnit and racerUnit:getPlayerName() then
            env.info("creating new racer", false)
            trigger.action.outText("creating new racer", 5, false)
            local newRacerTable = Utils.deepcopy(racerTemplate)
            newRacerTable.groupID = racerGroup:getID()
            newRacerTable.unitName = racerUnit:getName()
            newRacerTable.playerName = racerUnit:getPlayerName()
            racerQueue[#racerQueue+1] = newRacerTable
            trigger.action.outText("Racer added to queue", 5, false)
        end
    end
end
function wwxrl.countdown(raceID)
    env.info("Begin countdown for race " .. raceID, false)
    wwxrl.messageToRacers("The race will begin in " .. countdownDuration .. " seconds")
    local finalCountdownDelay = countdownDuration - finalCountdown
    local finalCountdownStartTime = timer.getTime() + finalCountdownDelay
    for i = 1, finalCountdown do
       timer.scheduleFunction(wwxrl.messageToRacers, "Race starting in " .. finalCountdown - (i-1), finalCountdownStartTime + (i-1))
    end
    timer.scheduleFunction(wwxrl.startRace, nil, finalCountdownStartTime+finalCountdown)
end
--raceID, message
function wwxrl.messageToRacers(message)
    local race = currentRace
    if race and #race.racers > 0 then
        for i = 1, #race.racers do
            trigger.action.outTextForGroup(race.racers[i].groupID, message, messageDuration, false)
        end
    end
end
function wwxrl.startRace()
    local race = currentRace
    if race and race.status == racingStatus["Pre-Race"] then
        local raceStartTime = timer.getTime()
        for i = 1, #currentRace.racers do
            local racer = currentRace.racers[i]
            if racer then
                racer.startTime = raceStartTime
            end
        end
        wwxrl.messageToRacers("GO!")
        race.status = racingStatus["In Progress"]
    end
end
function wwxrl.endRace()
    local winningTime = 0
    local winner = ""
    for i = 1, #currentRace.racers do
        local racer = currentRace.racers[i]
        if racer and racer.completed then
            local completionTime = racer.endTime - racer.startTime + racer.penaltyTime
            if winningTime == 0 or completionTime < winningTime then
                winningTime = completionTime
                winner = racer.playerName
            end
        end
    end
    currentRace.winner = winner
    currentRace.winningTime = winningTime
    currentRace.status = racingStatus["Completed"]
end
function wwxrl.queueLoop()
    if #racerQueue > 0 then
        trigger.action.outText("queue loop with racers", 5, false)
        --check current race is in Pre-Race state. If yes, add players in queue to race
        if currentRace.status == nil or currentRace.status == racingStatus["Completed"] then
            trigger.action.outText("need new race", 5, false)
            wwxrl.createNewRace()
        elseif currentRace.status == racingStatus["In Progress"] then
            for i = 1, #racerQueue do
                local racer = racerQueue[i]
                if racer then
                    trigger.action.outTextForGroup(racer.groupID, "Race is currently in progress, please stand by.", 5, false)
                end
            end
        end
    end
    timer.scheduleFunction(wwxrl.queueLoop, nil, timer.getTime() + 5)
end
wwxrl.getGates()
wwxrl.queueLoop()