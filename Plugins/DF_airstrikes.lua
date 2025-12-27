Airstrike = {}
local airstrikes = {}
local strikeIntervalBaseTime = 1500
local strikeIntervalRandomLimit = 420
local strikeIntervalRandomLimitNeg = -420
local strikeGroupNames = {
    [1] = "Red-Strike",
    [2] = "Blue-Strike"
}
function airstrikes.airstrike(coaltionId, point)
    local bombParams = {
        ["attackType"] = "Dive",
        ["direction"] = 0,
        ["attackQtyLimit"] = false,
        ["attackQty"] = 1,
        ["expend"] = "All",
        ["y"] = point.z,
        ["directionEnabled"] = false,
        ["groupAttack"] = true,
        ["altitude"] = 2000,
        ["altitudeEnabled"] = false,
        ["weaponType"] = 2147485694,
        ["x"] = point.x,
    }
    local bombing = {id = 'Bombing', params = bombParams}
    local groupName = mist.cloneGroup(strikeGroupNames[coaltionId], false).name
    timer.scheduleFunction(airstrikes.tasking, {groupName = groupName, bombingMission = bombing}, timer:getTime() + 5)
end
--groupName, bombingMission
function airstrikes.tasking(param)
    local strikeGroup = Group.getByName(param.groupName)
    if strikeGroup then
        local strikeController = strikeGroup:getController()
        if strikeController then
            strikeController:setTask(param.bombingMission)
        end
    end
end
function airstrikes.loop(c)
    local strikePoint = airstrikes.getTargetPoint(c)
    if strikePoint then
        airstrikes.airstrike(c, strikePoint)
    else
        env.info("No company found for strike mission", false)
    end
    local strikeInterval = strikeIntervalBaseTime + math.random(-strikeIntervalRandomLimitNeg, strikeIntervalRandomLimit)
    timer.scheduleFunction(airstrikes.loop, c, timer:getTime() + strikeInterval)
end
function airstrikes.getTargetPoint(coalitionId)
    local enemyCoalition = 1
    if coalitionId == 1 then
        enemyCoalition = 2
    end
    local missionCompany = CpyControl.getUnarmoredFrontlineCpy(enemyCoalition)
    if missionCompany then
        local missionGroupName = missionCompany.groupName
        if missionGroupName then
            local missionGroup = Group.getByName(missionGroupName)
            if missionGroup then
                local missionUnit = missionGroup:getUnit(1)
                if missionUnit then
                    local missionPoint = missionUnit:getPoint()
                    if missionPoint then
                        return missionPoint
                    end
                end
            end
        end
    end
end
function airstrikes.start()
    airstrikes.loop(1)
    airstrikes.loop(2)
end
function Airstrike.strike(coaltionId, point)
    airstrikes.airstrike(coaltionId, point)
end
--airstrikes.start()