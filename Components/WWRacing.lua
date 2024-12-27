--requires Utils.lua
local wwxrl = {}
local gateLimit = 30
local AGLlimit = 35
local AGLPenalty = 10
local newRaceID = 1
local newRacerID = 1
local raceUpdateRate = 0.2
local currentRace = {}
local racerQueue = {}
local racingStatusNames = {
    [1] = "Pre-Race",
    [2] = "In Progress",
    [3] = "Completed"
}
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
    winner = "",
}
function raceTemplate:addRacer(racer)
    self.racers[self.racers+1] = racer
end
local racerTemplate = {
    groupID = 0,
    unitName = "",
    playerName = "",
    startTime = 0,
    endTime = 0,
    currentGate = 0,
}
local raceEvents = {}
function raceEvents:onEvent(event)
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
        else
            break
        end
    end
end
function wwxrl.createNewRace()
    env.info("creating new race table", false)
    local newRaceTable = Utils.deepcopy(raceTemplate)
    newRaceTable.raceID = wwxrl.newRaceID()
    currentRace = newRaceTable
    env.info("created race " .. newRaceTable.raceID, false)
    wwxrl.trackRace(newRaceTable.raceID)
end
function wwxrl.trackRace(raceID)
    local raceTable = currentRace
    if raceTable then
        local raceStatus = raceTable.status
        if raceStatus == racingStatus["In Progress"] then
            env.info("Race " .. raceID .. " in progress", false)
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
        elseif raceStatus == racingStatus["Completed"] then
            env.info("Race " .. raceID .. " completed. Winner is " .. raceTable.winner, false)
            --handle completed race and then break loop
            return
        end
    end
    timer.scheduleFunction(wwxrl.trackRace, raceID, timer:getTime() + raceUpdateRate)
end
function wwxrl.createNewRacer(groupName)
    local racerGroup = Group.getByName(groupName)
    if racerGroup then
        local racerUnit = racerGroup:getUnit(1)
        if racerUnit and racerUnit:getPlayerName() then
            env.info("creating new racer", false)
            local newRacerTable = Utils.deepcopy(racerTemplate)
            newRacerTable.groupID = racerGroup:getID()
            newRacerTable.unitName = racerUnit:getName()
            newRacerTable.playerName = racerUnit:getPlayerName()
            racerQueue[#racerQueue+1] = newRacerTable
        end
    end
end
function wwxrl.queueLoop()
    if #racerQueue > 0 then
        --check current race is in Pre-Race state. If yes, add players in queue to race
        if currentRace.status == racingStatus["In Progress"] then
            for i = 1, #racerQueue do
                local racer = racerQueue[i]
                if racer then
                    trigger.action.outTextForGroup(racer.groupID, "Race is currently in progress, please stand by.", 5, false)
                end
            end
        end
    end
    timer.scheduleFunction(wwxrl.queueLoop, nil, timer:getTime() + 5)
end