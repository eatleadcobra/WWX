local wwxRacing = {}
local racingClasses = {
    ["Helicopter"] = 1,
    ["Props"] = 2,
    ["VTOL"] = 3,
    ["Fast Jets"] = 4,
    ["Trainers/Korea"] = 5,
}
local racingClassNames = {
    [1] = "Helicopter Class",
    [2] = "Propeller Class",
    [3] = "VTOL Class",
    [4] = "Fast Jet Class",
    [5] = "Subsonic Jet Class",
}
local classAGLPenaltyEnabled = {
    [1] = true,
    [2] = false,
    [3] = true,
    [4] = false,
    [5] = false,
}
function wwxRacing.newLeague(division)
    --requires Utils.lua
    local wwxrl = {}
    local gateLimit = 50
    local gateTimeLimit = 65
    local AGLlimit = 45
    local lastPingTime = 0
    local timeBetweenPings = 1799
    local countdownDuration = 60
    local numberofreminders = 4
    local finalCountdown = 5
    local raceCooldownTime = 30
    local minimumRacers = 1 -- for testing, should be 2 
    local messageDuration = 8
    local newRaceID = 1
    local raceUpdateRate = 0.2
    local currentRace = {}
    local racerQueue = {}
    local createdRacers = {}
    local racingStatus = {
        ["Pre-Race"] = 1,
        ["In Progress"] = 2,
        ["Completed"] = 3
    }
    local racingTypes = {
        [1] = {
            ["Mi-8MT"] = 1,
            ["Mi-24P"] = 1,
            ["UH-1H"] = 1,
            ["SA342L"] = 1,
            ["CH-47Fbl1"] = 1,
            ["OH-6A"] = 1
        },
        [2] = {
            ["P-51D"] = 2,
            ["P-51D-30-NA"] = 2,
            ["TF-51D"] = 2,
            ["P-47D-30bl1"] = 2,
            ["P-47D-40"] = 2,
            ["MosquitoFBMkVI"] = 2,
            ["Bf-109K-4"] = 2,
            ["Yak-52"] = 2,
            ["FW-190A8"] = 2,
            ["FW-190D9"] = 2,
            ["SpitfireLFMkIX"] = 2,
            ["SpitfireLFMkIXCW"] = 2,
        },
        [3] = {
            ["AV8BNA"] = 3,
        },
        [4] = {
            ["F-4E-45MC"] = 4,
            ["F-5E-3"] = 4,
            ["Mirage-F1CE"] = 4,
            ["MiG-21Bis"] = 4,
        }
    }
    local raceTemplate = {
        raceID = 0,
        racers = {},
        status = 1,
        gates = {},
        finalGate = 0,
        winner = "",
        winningTime = 0,
        lastGateTime = 0,
        countdownStarted = false,
        cooldownStarted = false
    }
    function raceTemplate:addRacer(racer)
        --self.racers[#self.racers+1] = racer
        local matchFound = false
        for i = 1, #self.racers do
            if self.racers.groupID == racer.groupID then
                matchFound = true
                self.racers[i] = racer
            end
        end
        if not matchFound then
            self.racers[#self.racers+1] = racer
        end
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
            local gateZone = trigger.misc.getZone("Gate-"..division.."-"..i)
            if gateZone then
                raceTemplate.gates[#raceTemplate.gates+1] = gateZone
            else
                break
            end
        end
        raceTemplate.finalGate = #raceTemplate.gates
    end
    function wwxrl.addRacerToQueue(racer)
        local matchFound = false
        for i = 1, #racerQueue do
            if racerQueue[i].groupID == racer.groupID then
                matchFound = true
                racerQueue[i] = racer
            end
        end
        if not matchFound then
            racerQueue[#racerQueue+1] = racer
        end
    end
    function wwxrl.createNewRace()
        env.info("creating new race table", false)
        currentRace = {}
        if WWEvents then
            if lastPingTime == 0 or ((timer.getTime() - lastPingTime) > timeBetweenPings) then
                WWEvents.raceNotfication(racingClassNames[division])
                lastPingTime = timer.getTime()
            end
        end
        local newRaceTable = Utils.deepcopy(raceTemplate)
        newRaceTable.raceID = wwxrl.newRaceID()
        currentRace = newRaceTable
        currentRace.status = racingStatus["Pre-Race"]
        env.info("created race " .. newRaceTable.raceID, false)
        wwxrl.trackRace(newRaceTable.raceID)
    end
    function wwxrl.trackRace(raceID)
        local raceTable = currentRace
        if raceTable then
            local raceStatus = raceTable.status
            if raceStatus == racingStatus["In Progress"] then
                local raceCompleted = false
                local deadordqcount = 0
                for i = 1, #raceTable.racers do
                    local racer = raceTable.racers[i]
                    if racer and racer.unitName then
                        local raceUnit = Unit.getByName(racer.unitName)
                        if raceUnit then
                            local racerPoint = raceUnit:getPoint()
                            if racerPoint and racer.currentGate then
                                if racer.currentGate == 0 then
                                    racer.currentGate = 1
                                    if Utils.PointDistance(racerPoint, trigger.misc.getZone(division.."-Race Start Zone").point) > trigger.misc.getZone(division.."-Race Start Zone").radius then
                                        trigger.action.outTextForGroup(racer.groupID, "You are disqualified because you were not within the starting zone at race start.", 20, false)
                                        racer.disqualified = true
                                    end
                                end
                                local gate = currentRace.gates[racer.currentGate]
                                if gate then
                                    local gatePoint = gate.point
                                    local gateRadius = gate.radius
                                    if gatePoint and not racer.disqualified then
                                        local elapsedTime = timer.getTime() - racer.startTime
                                        local elapsedSeconds = tostring(math.floor(math.fmod(elapsedTime, 60)*10)/10)
                                        local elapsedMinutes = tostring(math.floor(elapsedTime/60))
                                        if tonumber(elapsedSeconds) < 10 then elapsedSeconds = "0"..elapsedSeconds end
                                        if tonumber(elapsedMinutes) < 10 then elapsedMinutes = "0"..elapsedMinutes end
                                        trigger.action.outTextForGroup(racer.groupID, "00:"..elapsedMinutes..":"..elapsedSeconds.." + " .. racer.penaltyTime, 0.2, false)
                                        local distanceToGate = Utils.PointDistance(racerPoint, gatePoint)
                                        if distanceToGate < gateRadius and Utils.getAGL(racerPoint) <= AGLlimit then
                                            trigger.action.outTextForGroup(racer.groupID, "Gate " .. racer.currentGate .. " completed!", 5, false)
                                            currentRace.lastGateTime = timer.getTime()
                                            racer.currentGate = racer.currentGate + 1
                                            if racer.currentGate <= currentRace.finalGate then
                                                local playerHdg = Utils.getHdgFromPosition(raceUnit:getPosition())
                                                local clockBearing = Utils.relativeClockBearing(racerPoint, currentRace.gates[racer.currentGate].point, playerHdg)
                                                trigger.action.outTextForGroup(racer.groupID, "Next gate at " .. clockBearing .. " o'clock", 10, false)
                                            end
                                            if (racer.currentGate > currentRace.finalGate) and not racer.completed then
                                                racer.endTime = timer.getTime()
                                                raceCompleted = true
                                                racer.completed = true
                                            end
                                        elseif classAGLPenaltyEnabled[division] and (Utils.getAGL(racerPoint) > AGLlimit) then
                                            trigger.action.outTextForGroup(racer.groupID, "You are too high! Penalized!", 1, false)
                                            racer.penaltyTime = racer.penaltyTime + raceUpdateRate
                                            if racer.penaltyTime > raceCooldownTime then
                                                trigger.action.outTextForGroup(racer.groupID, "Maximum penalty time exceeded, time to die.", 1, false)
                                                trigger.action.explosion(racerPoint, 300)
                                            end
                                        end
                                    else
                                        env.info("DQ'd or no gate point", false)
                                        --deadordqcount = deadordqcount+1
                                    end
                                end
                            else
                                --this might be a bad idea
                                --deadordqcount = deadordqcount+1
                            end
                        else
                            --deadordqcount = deadordqcount+1
                        end
                    else
                        --deadordqcount = deadordqcount+1
                    end
                end
                if raceCompleted and not currentRace.cooldownStarted then
                    currentRace.cooldownStarted = true
                    wwxrl.messageToRacers("Race ending in " .. raceCooldownTime .. " seconds")
                    timer.scheduleFunction(wwxrl.endRace, nil, timer.getTime() + raceCooldownTime)
                end
                if ((timer.getTime() - currentRace.lastGateTime) > gateTimeLimit) then
                    env.info("Gate time limit reached, race ended", false)
                    wwxrl.messageToRacers("Race ended because everyone is either dead or disqualified. To start another race, please return to the starting area.")
                    wwxrl.endRace()
                end
                --for each contestant, check distance to next gate and advance gates if in range and in limits
            elseif raceStatus == racingStatus["Pre-Race"] then
                for i = 1, #racerQueue do
                    local racer = racerQueue[i]
                    if racer then
                        currentRace:addRacer(racer)
                        env.info("Added racer " .. racer.playerName .. " to race " .. raceID, false)
                        trigger.action.outTextForGroup(racer.groupID, "You have been added to entrant list for the upcoming " .. racingClassNames[division] .. " race.", 5, false)
                    end
                end
                racerQueue = {}
                if #raceTable.racers >= minimumRacers and not raceTable.countdownStarted then
                    wwxrl.countdown(raceID)
                    raceTable.countdownStarted = true
                end
            elseif raceStatus == racingStatus["Completed"] then
                env.info("Race " .. raceID .. " completed. Winner is " .. raceTable.winner, false)
                local elapsedSeconds = tostring(math.floor(math.fmod(raceTable.winningTime, 60)*10)/10)
                local elapsedMinutes = tostring(math.floor(raceTable.winningTime/60))
                if tonumber(elapsedSeconds) < 10 then elapsedSeconds = "0"..elapsedSeconds end
                if tonumber(elapsedMinutes) < 10 then elapsedMinutes = "0"..elapsedMinutes end
                local winningTimeString = "00:"..elapsedMinutes..":"..elapsedSeconds
                wwxrl.messageToRacers("Race is completed, the winner is " .. raceTable.winner .. " with a time of " .. winningTimeString)
                if WWEvents and raceTable.winner and raceTable.winner ~= "" and raceTable.winningTime > 0 then
                    WWEvents.raceCompleted(raceTable.winner, math.floor(raceTable.winningTime), " has won a " .. racingClassNames[division] .. " race with a time of " .. winningTimeString)
                end
                wwxrl.messageToRacers("To join another race, please re-slot into a racing aircraft.")
                --handle completed race and then break loop
                return
            end
        end
        timer.scheduleFunction(wwxrl.trackRace, raceID, timer.getTime() + raceUpdateRate)
    end
    function wwxrl.cleanupRacer(groupID)
        if currentRace and currentRace.racers and #currentRace.racers > 0 then
            for i = 1, #currentRace.racers do
                local racer = currentRace.racers[i]
                if racer and racer.groupID == groupID then
                    currentRace.racers[i] = nil
                    env.info("Nil'd racer", false)
                    break
                end
            end
            for i = 1, #racerQueue do
                local racer = racerQueue[i]
                if racer and racer.groupID == groupID then
                    racerQueue[i] = nil
                    env.info("Nil'd racer from queue", false)
                    break
                end
            end
            createdRacers[groupID] = nil
        end
    end
    function wwxrl.createNewRacer(groupName)
        local racerGroup = Group.getByName(groupName)
        if racerGroup then
            local racerUnit = racerGroup:getUnit(1)
            if racerUnit and racerUnit:getPlayerName() then
                env.info("creating new racer", false)
                --trigger.action.outText("creating new racer", 5, false)
                local newRacerTable = Utils.deepcopy(racerTemplate)
                newRacerTable.groupID = racerGroup:getID()
                newRacerTable.unitName = racerUnit:getName()
                newRacerTable.playerName = racerUnit:getPlayerName()
                wwxrl.addRacerToQueue(newRacerTable)
                createdRacers[newRacerTable.groupID] = newRacerTable
                --trigger.action.outText("Racer added to queue", 5, false)
            end
        end
    end
    function wwxrl.countdown(raceID)
        env.info("Begin countdown for race " .. raceID, false)
        local finalCountdownDelay = countdownDuration - finalCountdown
        local reminderInterval = math.floor(countdownDuration/numberofreminders)
        for i = 1, numberofreminders do
            timer.scheduleFunction(wwxrl.messageToRacers,"The race will begin in " .. countdownDuration - (reminderInterval*(i-1)) .. " seconds", timer.getTime() + reminderInterval*(i-1))
        end
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
                local racer = race.racers[i]
                if racer and racer.groupID then
                    trigger.action.outTextForGroup(racer.groupID, message, messageDuration, false)
                end
            end
        end
    end
    function wwxrl.startRace()
        local race = currentRace
        if race and race.status == racingStatus["Pre-Race"] then
            local raceStartTime = timer.getTime()
            currentRace.lastGateTime = raceStartTime
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
            if racer then createdRacers[racer.groupID] = nil end
            if racer and racer.completed then
                local completionTime = (racer.endTime + racer.penaltyTime) - racer.startTime
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
            if currentRace.status == nil or currentRace.status == racingStatus["Completed"] then
                wwxrl.createNewRace()
            elseif currentRace.status == racingStatus["In Progress"] then
                for i = 1, #racerQueue do
                    local racer = racerQueue[i]
                    if racer and racer.groupID then
                        trigger.action.outTextForGroup(racer.groupID, "Race is currently in progress, please stand by.", 5, false)
                    end
                end
            end
        end
        timer.scheduleFunction(wwxrl.queueLoop, nil, timer.getTime() + 5)
    end
    function wwxrl.racerCreationLoop()
        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
                point = trigger.misc.getZone(division.."-Race Start Zone").point,
                radius = trigger.misc.getZone(division.."-Race Start Zone").radius
            }
        }
        local ifFound = function(foundItem, val)
            env.info("Racer Start Zone Search", false)
            if (foundItem:getDesc().category == 0 or foundItem:getDesc().category == 1) and foundItem:isExist() and foundItem:isActive() and racingTypes[division][foundItem:getTypeName()] then
                local foundPlayerName = foundItem:getPlayerName()
                local playerGroup = foundItem:getGroup()
                if playerGroup then
                    local playerGroupID = playerGroup:getID()
                    if foundPlayerName and playerGroupID and createdRacers[playerGroupID] == nil then
                        wwxrl.createNewRacer(playerGroup:getName())
                        trigger.action.outTextForGroup(playerGroupID, "You have been added to the " ..racingClassNames[division] .. " racer queue", 5, false)
                    end
                end
            end
        end
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        timer.scheduleFunction(wwxrl.racerCreationLoop, nil, timer.getTime() + 10)
    end
    wwxrl.getGates()
    wwxrl.queueLoop()
    wwxrl.racerCreationLoop()
end
wwxRacing.newLeague(racingClasses["Helicopter"])
wwxRacing.newLeague(racingClasses["Props"])
wwxRacing.newLeague(racingClasses["VTOL"])