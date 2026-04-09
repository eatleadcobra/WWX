TimeManager = {}
local timeManager = {}
MissionEndTimeString = ""
local missionStartTime = 0
local missionEndTime = 0
local timeMgmtInterval = 60
local lastMessageTime = 0
local timerMarkId = nil
function TimeManager.startUp()
    if RUNTIME then
        missionStartTime = timer:getTime0()
        missionEndTime = missionStartTime + RUNTIME
        local endTime = timer:getTime0() + RUNTIME
        local endTimeHours = tostring(math.floor(endTime/3600))
        local endTimeMinutes = tostring(math.floor((endTime-(endTimeHours*3600))/60))
        if string.len(endTimeMinutes) == 1 then
            endTimeMinutes = "0"..endTimeMinutes
        end
        if string.len(endTimeHours) == 1 then
            endTimeHours = "0"..endTimeHours
        end
        MissionEndTimeString = endTimeHours..":"..endTimeMinutes
        local timeDrawingPoint = {}
        if trigger.misc.getZone("TimeMarker") then
            timeDrawingPoint = trigger.misc.getZone("TimeMarker").point
        else
            local refPoint = trigger.misc.getZone(DFS.spawnNames[1].rearSupplyDrawing).point
            timeDrawingPoint = {x = refPoint.x + 500, y = refPoint.y, z = refPoint.z + 300}
        end
        timerMarkId = DrawingTools.newMarkId()
        trigger.action.textToAll(-1, timerMarkId, timeDrawingPoint, {0,0,0,1},{1,1,1,1}, 20, true, "  Mission ends at " .. MissionEndTimeString .. " local time.  ")
        timeManager.loop()
    else
        trigger.action.outText("ERROR: Attempted to run TimeManager.lua with no RUNTIME in overrides file.", 60, false)
    end
end
function timeManager.loop()
    local timeToGo = missionEndTime - timer:getAbsTime()
    env.info("Mission ends in " .. timeToGo .. " seconds.", false)
    local ttgHoursString = tostring(math.floor(timeToGo/3600))
    local ttgMinString = tostring(math.floor((timeToGo-(ttgHoursString*3600))/60))
    if string.len(ttgHoursString) == 1 then
            ttgHoursString = "0"..ttgHoursString
        end
        if string.len(ttgMinString) == 1 then
            ttgMinString = "0"..ttgMinString
        end
    local ttgString = " Mission ends in " .. ttgHoursString .. ":" .. ttgMinString .. ":00 \n At " .. MissionEndTimeString .. " local time. "
    if lastMessageTime == 0 or (timer:getTime() - lastMessageTime > (600 - timeMgmtInterval)) then
        trigger.action.outText(ttgString, 30, false)
        lastMessageTime = timer:getTime()
    end
    if timerMarkId then
        trigger.action.setMarkupText(timerMarkId, ttgString)
    end
    timer.scheduleFunction(timeManager.loop, nil, timer:getTime() + timeMgmtInterval)
end