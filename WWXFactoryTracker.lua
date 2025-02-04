local ft = {}
local objectives = {
    [1] = {

    },
    [2] = {

    },
}
local destructionCounters = {
    [1] = 0,
    [2] = 0
}
function ft.getStatics()
    for i = 1, 50 do
        local j = 1
        local group = StaticObject.getByName("Industrial-"..i.."-"..j)
        if group == nil then group = StaticObject.getByName("Industrial-"..i.."-"..j.."-1") end
        if group ~= nil then
            local groupPoint = group:getPoint()
            local objCoalition = group:getCoalition()
            local groupList = {}
            while group ~= nil do
                groupList[j] = group:getName()
                j = j + 1
                group = StaticObject.getByName("Industrial-"..i.."-"..j)
                if group == nil then group = StaticObject.getByName("Industrial-"..i.."-"..j.."-1") end
            end
            if #groupList > 0 then
                local statusMarkId = DrawingTools.newMarkId()
                trigger.action.textToAll(-1, statusMarkId, {x = groupPoint.x, y = groupPoint.y, z = groupPoint.z + 30000}, {0,0,0,1}, {1,1,1,1}, 12, true, "Initializing")
                objectives[objCoalition][#objectives[objCoalition]+1] = {groups = groupList, type = 2, markId = statusMarkId}
            end
        end
    end
end
function ft.trackObjs()
    for cltn = 1, 2 do
        for i = 1, #objectives[cltn] do
            local objectiveGroupsCount = #objectives[cltn][i].groups
            local objectiveType = objectives[cltn][i].type
            if objectiveType == 2 then
                local deadCount = 0
                for j = 1, objectiveGroupsCount do
                    local objectiveName = objectives[cltn][i].groups[j]
                    local group = StaticObject.getByName(objectiveName)
                    if group ~= nil then
                        local objCurrentHealth = group:getLife()
                        if objCurrentHealth <= 3 then deadCount = deadCount+1 end
                    else
                        deadCount = deadCount+1
                    end
                end
                if deadCount > destructionCounters[cltn] then
                    DFS.status[cltn].health = DFS.status[cltn].health - (2*(deadCount - destructionCounters[cltn]))
                    destructionCounters[cltn] = deadCount
                end
                local indrCoef = deadCount/objectiveGroupsCount
                DFS.status[cltn].industrialModifier = 1 + indrCoef
                local indrCapacity = 100 - math.floor((indrCoef*100))
                trigger.action.setMarkupText(objectives[cltn][i].markId, "Industrial Capacity: " .. indrCapacity .. "%")
            end
        end
    end
    timer.scheduleFunction(ft.trackObjs, nil, timer:getTime() + 30)
end
ft.getStatics()
ft.trackObjs()