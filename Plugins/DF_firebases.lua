Firebases = {
}
FirebaseIds = {
    [1] = {},
    [2] = {}
}
Firebases.fbTypes = {
    ["MORTAR"] = 1,
    ["HOWITZER"] = 2,
    ["SPG"] = 3,
}
local gunAssignments = {

}
local assignedGunKills = {

}
local suppressions = {

}
local fbId = 1
local markId = 3000
local resupDistance = 300
local firebaseCheckInterval = 20
local gracePeriod = 20
local fbFuncs = {}
local targetMarks = {}
local drawing = {
    markColor =  {
        [1] = {1,0,0,1},
        [2] = {0,0,1,1}
    },
    fillColor = {
        [1] = {1,0,0,0.3},
        [2] = {0,0,1,0.3}
    },
    boxHeight = 800,
    groupCountRadius = 50
}
local firebaseRanges = {
    ["MORTAR"] = 3500,
    ["HOWITZER"] = 7500,
    ["SPG"] = 12000,
}
local firebaseExpendQtys = {
    ["MORTAR"] = 9,
    ["HOWITZER"] = 12,
    ["SPG"] = 9,
}
local firebaseMaxAmmos = {
    ["MORTAR"] = 140,
    ["HOWITZER"] = 100,
    ["SPG"] = 120,
}
local supplyTypes = {
    ["MORTAR"] = "BOMBS",
    ["HOWITZER"] = "SHELLS",
    ["SPG"] = "SHELLS",
}
Firebases.firebaseSupplyAmts = {
    ["BOMBS"] = 50,
    ["SHELLS"] = 30,
}
local firemissionDelays = {
    ["MORTAR"] = {
        aiming = 5,
        perShot = 2,
    },
    ["HOWITZER"] = {
        aiming = 18,
        perShot = 6,
    },
    ["SPG"] = {
        aiming = 120,
        perShot = 17,
    }
}
function fbFuncs.removeRadioCommandsForGroup(groupID)
    missionCommands.removeItemForGroup(groupID, {})
end
local fbEvents = {}
function fbEvents:onEvent(event)
    --on mark change
    if (event.id == world.event.S_EVENT_MARK_CHANGE) then
        local playerName =  nil
        if event.idx then
            if event.initiator ~= nil then
                playerName = event.initiator:getPlayerName()
            end
        end
        if event.pos then
            local markPoint = event.pos
            local nfzNames = {
                [1] = "No Fly Zone Red",
                [2] = "No Fly Zone Blue"
            }
            for i = 1, #nfzNames do
               local nfz = trigger.misc.getZone(nfzNames[i])
                if nfz then
                    local nfzpoint = nfz.point
                    local nfzradius = nfz.radius
                    if nfzpoint and nfzradius then
                        if Utils.PointDistance(markPoint, nfzpoint) <= nfzradius then
                            env.info("Blocking fire mission mark from within NFZ-"..i, false)
                            trigger.action.removeMark(event.idx)
                            return
                        end
                    end
                end
            end
        end
        if (string.upper(event.text) == 'I') then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "STARSHELL", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
        if (string.upper(event.text) == 'X') then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "ANY", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
        if (string.upper(event.text) == 'H') then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "HOWITZER", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
        if (string.upper(event.text) == 'S') then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "SPG", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
        if (string.upper(event.text) == 'M') then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "MORTAR", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
        if (string.upper(event.text) == 'SUP') then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "SUPPRESS", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
        if (string.upper(event.text) == "B") then
            table.insert(targetMarks, {coalition = event.coalition, pos = event.pos, id=event.idx, fbType = "BATTLE", playerName = playerName})
            timer.scheduleFunction(Firebases.sendFireMission, event.coalition, timer.getTime() + 5)
        end
    end
    --on mark remove
    if (event.id == world.event.S_EVENT_MARK_REMOVED) then
        for i = 1, #targetMarks do
            if targetMarks[i].id == event.idx then
                table.remove(targetMarks, i)
                break
            end
        end
    end
    -- on kill
    if (event.id == world.event.S_EVENT_KILL) then
        if event and event.initiator and event.initiator.hasAttribute and event.initiator:hasAttribute("Artillery") then
            local facPlayer = gunAssignments[event.initiator:getName()]
            if facPlayer then
                env.info(facPlayer .. "  directed artillery scored a kill", false)
                local currentKills = assignedGunKills[facPlayer]
                if currentKills == nil then currentKills = 0 end
                assignedGunKills[facPlayer] = currentKills + 1
            end
        end
    end
end
world.addEventHandler(fbEvents)
function Firebases.deploy(group, type, ammo, guns)
    local droppingGroup = Group.getByName(group)
    if droppingGroup then
        if Firebases.getClosestFirebase(droppingGroup:getUnit(1):getPoint(), droppingGroup:getCoalition()) == -1 then
            local newbaseId = fbFuncs.createFirebase({group = group, type = type})
            fbFuncs.spawnTruck(Firebases[newbaseId])
            if ammo then
                Firebases[newbaseId].contents.ammo = ammo
            else
                Firebases[newbaseId].contents.ammo = Firebases.firebaseSupplyAmts[supplyTypes[type]]*2
            end
            fbFuncs.drawNewBase(Firebases[newbaseId])
            if guns then
                Firebases[newbaseId]:setGuns(guns, type)
            else
                fbFuncs.spawnGroup(Firebases[newbaseId], type)
            end
        else
            if droppingGroup then
                trigger.action.outTextForGroup(droppingGroup:getID(),"Cannot create new firebase, in range of an existing base", 5)
            end
        end
    end
end
function Firebases.deployStatic(group, type, ammo)
    local droppingGroup = StaticObject.getByName(group)
    if droppingGroup then
        if Firebases.getClosestFirebase(droppingGroup:getPoint(), droppingGroup:getCoalition()) == -1 then
            local newbaseId = fbFuncs.createFirebaseStatic({group = group, type = type})
            fbFuncs.spawnTruck(Firebases[newbaseId])
            if ammo then
                Firebases[newbaseId].contents.ammo = ammo
            else
                Firebases[newbaseId].contents.ammo = Firebases.firebaseSupplyAmts[supplyTypes[type]]*2
            end
            fbFuncs.drawNewBase(Firebases[newbaseId])
            fbFuncs.spawnGroup(Firebases[newbaseId], type)
        else
            if droppingGroup then
                trigger.action.outTextForGroup(droppingGroup:getID(), "Cannot create new firebase, in range of an existing base", 5)
            end
        end
    end
end
function fbFuncs.debugWrapperCreate(param)
    trigger.action.outText("debug create start", 5)
    local droppingGroup = Group.getByName(param.group)
    if Firebases.getClosestFirebase(droppingGroup:getUnit(1):getPoint(),droppingGroup:getCoalition()) == -1 then
        local newbaseId = fbFuncs.createFirebase(param)
        fbFuncs.spawnTruck(Firebases[newbaseId])
        Firebases[newbaseId].contents.ammo = Firebases.firebaseSupplyAmts[param.type]
        fbFuncs.drawNewBase(Firebases[newbaseId])
        fbFuncs.spawnGroup(Firebases[newbaseId], param.type)
    else
        trigger.action.outTextForGroup(Group:getByName(param.group):getID(),"Cannot create new firebase, in range of an existing base", 5)
    end
end
function fbFuncs.debugWrapperDelete(groupName)
    trigger.action.outText("debug delete start", 5)
    local droppingGroup = Group.getByName(groupName)
    local nearestFb = Firebases.getClosestFirebase(droppingGroup:getUnit(1):getPoint(),droppingGroup:getCoalition())
    if nearestFb ~= -1 then
        Firebases.destroyFirebase(Firebases[nearestFb])
    end
end
function fbFuncs.debugWrapperAdd(param)
    trigger.action.outText("debug add start", 5)
    local droppingGroup = Group.getByName(param.group)
    local nearestFb = Firebases.getClosestFirebase(droppingGroup:getUnit(1):getPoint(),droppingGroup:getCoalition())
    if nearestFb ~= -1 then
        fbFuncs.spawnGroup(Firebases[nearestFb], param.type)
    end
end
--this function is run assuming the conditions to create a firebase are already met
function fbFuncs.createFirebase(param)
    local baseGroup = Group.getByName(param.group)
    if  baseGroup ~= nil then
        local baseUnit = baseGroup:getUnit(1)
        if baseUnit ~= nil then
            local newBase = Firebase:new()
            local point = baseUnit:getPoint()
            local pos = baseUnit:getPosition()
            local basePoint = Utils.VectorAdd(point, Utils.ScalarMult(pos.x, 10))
            ---@diagnostic disable-next-line: deprecated
            local heading = math.atan2(pos.x.z, pos.x.x)
            if heading < 0 then heading = heading + (2 * math.pi) end
            newBase.fbType = param.type
            newBase.contents.maxAmmo = firebaseMaxAmmos[param.type]
            newBase.coalition = baseGroup:getCoalition()
            newBase.id = fbFuncs.newBaseID()
            newBase.positions.location = {x = basePoint.x, y = basePoint.y, z = basePoint.z}
            newBase.positions.heading = heading
            newBase.positions.spawnPoints = fbFuncs.getSpawnPoints(basePoint, pos, param.type)
            Firebases[newBase.id] = newBase
            table.insert(FirebaseIds[newBase.coalition], newBase.id)
            return newBase.id
        end
    end
end
function fbFuncs.createFirebaseStatic(param)
    local baseObj = StaticObject.getByName(param.group)
    if baseObj then
        local newBase = Firebase:new()
        local point = baseObj:getPoint()
        local pos = baseObj:getPosition()
        local basePoint = Utils.VectorAdd(point, Utils.ScalarMult(pos.x, 10))
        ---@diagnostic disable-next-line: deprecated
        local heading = math.atan2(pos.x.z, pos.x.x)
        if heading < 0 then heading = heading + (2 * math.pi) end
        newBase.fbType = param.type
        newBase.contents.maxAmmo = firebaseMaxAmmos[param.type]
        newBase.coalition = baseObj:getCoalition()
        newBase.id = fbFuncs.newBaseID()
        newBase.positions.location = {x = basePoint.x, y = basePoint.y, z = basePoint.z}
        newBase.positions.heading = heading
        newBase.positions.spawnPoints = fbFuncs.getSpawnPoints(basePoint, pos, param.type)
        Firebases[newBase.id] = newBase
        table.insert(FirebaseIds[newBase.coalition], newBase.id)
        return newBase.id
    end
end
function Firebases.destroyFirebase(firebase)
    -- destroy all groups + truck
    local truckGroupName = firebase.contents.truck
    if truckGroupName ~= nil then
        firebase.contents.truck = nil
        local truckGroup = Group.getByName(truckGroupName)
        if truckGroup ~= nil then truckGroup:destroy() end
    end
    for i = 1, #firebase.contents.groups do
        local removeGroupName = firebase.contents.groups[i]
        if removeGroupName ~= nil then
            local removeGroup = Group.getByName(removeGroupName)
            if removeGroup ~= nil then removeGroup:destroy() end
        end
    end
    -- remove all markup
    trigger.action.removeMark(firebase.markups.main)
    trigger.action.removeMark(firebase.markups.range)
    trigger.action.removeMark(firebase.markups.ammoCounter.background)
    trigger.action.removeMark(firebase.markups.ammoCounter.ammoAmt)
    trigger.action.removeMark(firebase.markups.firing.line)
    trigger.action.removeMark(firebase.markups.firing.circle)
    for i = 1, #firebase.markups.symbol do
        trigger.action.removeMark(firebase.markups.symbol[i])
    end
    for i = 1, #firebase.markups.groups.backgrounds do
        trigger.action.removeMark(firebase.markups.groups.backgrounds[i])
    end
    -- remove fb id from index
    for i = 1, #FirebaseIds[firebase.coalition] do
        if FirebaseIds[firebase.coalition][i] == firebase.id then
            table.remove(FirebaseIds[firebase.coalition], i)
            break
        end
    end
    -- remove fb from table 
    Firebases[firebase.id] = nil
    firebase = nil
end
--firebase, type
function Firebases.resupplyFirebase(firebase, ammount)
    firebase:addAmmo(ammount)
    Firebases.updateAmmoCounter(firebase)
end
--group, type
function Firebases.addGroupToFirebase(firebase, type)
    fbFuncs.spawnGroup(firebase, type)
    Firebases.updateGroupCounter(firebase)
end
--this function is run assuming the firebase has already been initialized by the creation function
function fbFuncs.drawNewBase(firebase)
    local location = firebase.positions.location
    local coalition = firebase.coalition
    local b1 = {x = location.x - drawing.boxHeight/2, y = location.y, z = location.z + drawing.boxHeight/2}
    local b2 = {x = location.x - drawing.boxHeight/2, y = location.y, z = location.z - drawing.boxHeight/2}
    local b3 = {x = location.x + drawing.boxHeight/2, y = location.y, z = location.z - drawing.boxHeight/2}
    local b4 = {x = location.x + drawing.boxHeight/2, y = location.y, z = location.z + drawing.boxHeight/2}
    local outlineId = DrawingTools.newMarkId()
    trigger.action.quadToAll(coalition, outlineId, b1, b2, b3, b4, drawing.markColor[coalition], drawing.fillColor[coalition], 1, true)
    firebase.markups.main = outlineId
    fbFuncs.drawSymbol(firebase.fbType, location, firebase, coalition)
    fbFuncs.createAmmoCounter(firebase)
    fbFuncs.createGroupCounter(firebase)
end
function fbFuncs.drawSymbol(type, location, firebase, coalition)
    local rangeId = DrawingTools.newMarkId()
    trigger.action.circleToAll(coalition, rangeId, location, firebaseRanges[type], {0,0,0,1}, {0,0,0,0}, 2, true)
    firebase.markups.range = rangeId
    if type == "MORTAR" then
        local circlePoint = { x = location.x - 75, y = location.y, z = location.z}
        local circleId = DrawingTools.newMarkId()
        trigger.action.circleToAll(coalition, circleId, circlePoint, drawing.groupCountRadius, {0,0,0,1}, {0,0,0,1}, 1, true)
        firebase.markups.symbol[#firebase.markups.symbol+1] = circleId
        local lineEnd = {x = location.x + 75, y = location.y, z = location.z}
        local lineId = DrawingTools.newMarkId()
        trigger.action.lineToAll(coalition, lineId, circlePoint, lineEnd, {0,0,0,1}, 1, true)
        firebase.markups.symbol[#firebase.markups.symbol+1] = lineId
        local triangleLeft = {x = lineEnd.x, y = lineEnd.y, z = lineEnd.z - 10}
        local triangleRight = {x = lineEnd.x, y = lineEnd.y, z = lineEnd.z + 10}
        local triangleTop = {x = lineEnd.x + 10, y = lineEnd.y, z = lineEnd.z}
        local triangleId = DrawingTools.newMarkId()
        trigger.action.quadToAll(coalition, triangleId, triangleLeft, triangleTop, triangleTop, triangleRight, {0,0,0,1}, {0,0,0,1}, 1, true) 
        firebase.markups.symbol[#firebase.markups.symbol+1] = triangleId
    elseif type == "HOWITZER" or type == "SPG" then
        local circlePoint = { x = location.x, y = location.y, z = location.z}
        local circleId = DrawingTools.newMarkId()
        trigger.action.circleToAll(coalition, circleId, circlePoint, drawing.groupCountRadius, {0,0,0,1}, {0,0,0,1}, 1, true)
        firebase.markups.symbol[#firebase.markups.symbol+1] = circleId
    elseif type == "MLRS" then
        
    end
end
function fbFuncs.createAmmoCounter(firebase)
    local location = firebase.positions.location
    local counterHeight = drawing.boxHeight
    local counterOrigin = { x = location.x - drawing.boxHeight/2, y = location.y, z = location.z - (drawing.boxHeight/2) - 10}
    local counterEnd = {x = counterOrigin.x + counterHeight, y = counterOrigin.y, z = counterOrigin.z - 50}
    local bgMarkId = DrawingTools.newMarkId()
    trigger.action.rectToAll(firebase.coalition, bgMarkId, counterOrigin, counterEnd, {0,0,0,1}, {0,0,0,0.2}, 1, true)
    firebase.markups.ammoCounter.background = bgMarkId
    Firebases.updateAmmoCounter(firebase)
end
function Firebases.updateAmmoCounter(firebase)
    --trigger.action.removeMark(firebase.markups.ammoCounter.ammoAmt)
    if firebase.markups.ammoCounter.ammoAmt > 0 then
        local location = firebase.positions.location
        local counterHeight = drawing.boxHeight
        local counterOrigin = { x = location.x - drawing.boxHeight/2, y = location.y, z = location.z - (drawing.boxHeight/2) - 10}
        local ammoPct = firebase.contents.ammo / firebase.contents.maxAmmo
        local ammoLineStart = {x = counterOrigin.x + ammoPct*counterHeight, y = counterOrigin.y, z = counterOrigin.z}
        local ammoLineEnd = {x = counterOrigin.x + ammoPct*counterHeight, y = counterOrigin.y, z = counterOrigin.z - 50}
        trigger.action.setMarkupPositionStart(firebase.markups.ammoCounter.ammoAmt, ammoLineStart)
        trigger.action.setMarkupPositionEnd(firebase.markups.ammoCounter.ammoAmt, ammoLineEnd)
    else
        local newMarkId = DrawingTools.newMarkId()
        local location = firebase.positions.location
        local counterHeight = drawing.boxHeight
        local counterOrigin = { x = location.x - drawing.boxHeight/2, y = location.y, z = location.z - (drawing.boxHeight/2) - 10}
        local ammoPct = firebase.contents.ammo / firebase.contents.maxAmmo
        local ammoLineStart = {x = counterOrigin.x + ammoPct*counterHeight, y = counterOrigin.y, z = counterOrigin.z}
        local ammoLineEnd = {x = counterOrigin.x + ammoPct*counterHeight, y = counterOrigin.y, z = counterOrigin.z - 50}
        trigger.action.lineToAll(firebase.coalition, newMarkId, ammoLineStart, ammoLineEnd, {1,0,0,1}, 1, true, nil)
        firebase.markups.ammoCounter.ammoAmt = newMarkId
    end
end
function fbFuncs.updateFireMissionMarker(firemarkId, targetMarkIndex, coalitionId, markerPos)
    table.remove(targetMarks, targetMarkIndex)
    trigger.action.removeMark(firemarkId)
    local newMarkId = DrawingTools.newMarkId()
    trigger.action.markToCoalition(newMarkId, 'Fire Mission in Progress', markerPos, coalitionId, true)
    local resetTime = 300
    timer.scheduleFunction(trigger.action.removeMark, newMarkId, timer.getTime() + resetTime)
end
function fbFuncs.createGroupCounter(firebase)
    local fbLoc = firebase.positions.location
    local baseCounterPos = {x = fbLoc.x - drawing.boxHeight/2 - drawing.groupCountRadius, y = fbLoc.y, z = fbLoc.z + drawing.boxHeight/2 + drawing.groupCountRadius}
    for i = 1, #firebase.positions.spawnPoints.groups do
        local currentCounterPos = {x = baseCounterPos.x + 2*drawing.groupCountRadius*i, y = baseCounterPos.y, z = baseCounterPos.z}
        local newMarkId = DrawingTools.newMarkId()
        trigger.action.circleToAll(firebase.coalition,newMarkId,currentCounterPos, drawing.groupCountRadius, {0,0,0,1}, {0,0,0,0.2},1, true, nil)
        firebase.markups.groups.backgrounds[i] = newMarkId
    end
    Firebases.updateGroupCounter(firebase)
end
--point, radius, duration
function fbFuncs.suppressArea(param)
    local groupsToSuppress = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = param.point,
            radius = param.radius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:isExist() and foundItem:isActive() then
            local foundGroup = foundItem:getGroup()
            if foundGroup then
                local foundGroupName = foundGroup:getName()
                if foundGroupName then
                    groupsToSuppress[foundGroupName] = true
                end
            end
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    for groupName, included in pairs(groupsToSuppress) do
        local group = Group.getByName(groupName)
        if group then
            local groupController = group:getController()
            if groupController then
                --ROE return only
                groupController:setOption(0,3)
                --Target ground only
                groupController:setOption(28, 2)
            end
        end
    end
    local suppressionId = Utils.uuid()
    suppressions[suppressionId] = groupsToSuppress
    timer.scheduleFunction(fbFuncs.unsuppress, suppressionId, timer:getTime() + param.duration)
end
function fbFuncs.unsuppress(suppressionId)
    local suppressedGroups = suppressions[suppressionId]
    for k,v in pairs(suppressedGroups) do
        local group = Group.getByName(k)
        if group then
            local groupController = group:getController()
            if groupController then
                --ROE free fire
                groupController:setOption(0,2)
                --ROE remove target restritions
                groupController:setOption(28, 0)
            end
        end
    end
end
function Firebases.updateGroupCounter(firebase)
    for i = 1, #firebase.markups.groups.backgrounds do
        trigger.action.setMarkupColorFill(firebase.markups.groups.backgrounds[i], {0,0,0,0.2})
    end
    for i = 1, #firebase.contents.groups do
        trigger.action.setMarkupColorFill(firebase.markups.groups.backgrounds[i], drawing.fillColor[firebase.coalition])
    end
end
function fbFuncs.getSpawnPoints(point, pos, type)
    local spawnPoints = {}
    local groups = {}
    local truck = point
    if type == "MORTAR" then
        groups[1] = Utils.VectorAdd(point, Utils.ScalarMult(pos.x, 10))
    elseif type == "SPG" then
        groups[1] = Utils.VectorAdd(point, Utils.ScalarMult(Utils.RotateVector(pos.x, -0.9), 15))
        groups[2] = Utils.VectorAdd(point, Utils.ScalarMult(pos.x, 15))
        groups[3] = Utils.VectorAdd(point, Utils.ScalarMult(Utils.RotateVector(pos.x, 0.9), 15))
    elseif type == "HOWITZER" then
        groups[1] = Utils.VectorAdd(point, Utils.ScalarMult(Utils.RotateVector(pos.x, -0.7), 15))
        groups[2] = Utils.VectorAdd(point, Utils.ScalarMult(Utils.RotateVector(pos.x, 0.7), 15))
    end
    spawnPoints.groups = groups
    spawnPoints.truck = truck
    return spawnPoints
end
function fbFuncs.spawnTruck(firebase)
    firebase.contents.truck = nil
    local newTruck = FirebaseGroups.spawn("TRUCK", firebase.positions.spawnPoints.truck, firebase.coalition, firebase.positions.heading)
    firebase.contents.truck = newTruck
end
function fbFuncs.spawnGroup(firebase, type)
    local maxSpawns = #firebase.positions.spawnPoints.groups
    local currentGroups = #firebase.contents.groups
    for i = 1, maxSpawns do
        if i > currentGroups then
            local newGroup = FirebaseGroups.spawn(type, firebase.positions.spawnPoints.groups[i], firebase.coalition, firebase.positions.heading)
            local newGroupObj = Group.getByName(newGroup)
            if newGroupObj then
                local newGroupObjController = newGroupObj:getController()
                if newGroupObjController then
                    newGroupObjController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                end
            end
            table.insert(firebase.contents.groups, newGroup)
            Firebases.updateGroupCounter(firebase)
            break
        end
    end
end
function Firebases.getClosestFirebase(point, coalition)
    local distanceToFirebase = 100000
    local returnBaseIndex = 0
    --trigger.action.outText(dump(FirebaseIds[coalition]), 30, false)
    for i = 1, #FirebaseIds[coalition] do
        local distance = Utils.PointDistance(point, Firebases[FirebaseIds[coalition][i]].positions.location)
        if distance < distanceToFirebase then
            distanceToFirebase = distance
            returnBaseIndex = FirebaseIds[coalition][i]
        end
    end
    if returnBaseIndex ~= 0 and distanceToFirebase < resupDistance then
        return returnBaseIndex
    else
        return -1
    end
end
function Firebases.getClosestUnassignedFirebaseInRangeByType(point, coalition, fbType)
    local distanceToFirebase = 100000
    local returnBaseIndex = 0
    for i = 1, #FirebaseIds[coalition] do
        if fbType == "ANY" or fbType == "STARSHELL" or fbType == "SUPPRESS" or (Firebases[FirebaseIds[coalition][i]].fbType and Firebases[FirebaseIds[coalition][i]].fbType == fbType) then
            local distance = Utils.PointDistance(point, Firebases[FirebaseIds[coalition][i]].positions.location)
            if fbFuncs.inRange(Firebases[FirebaseIds[coalition][i]], point) and distance < distanceToFirebase and not Firebases[FirebaseIds[coalition][i]]:isAssigned() and Firebases[FirebaseIds[coalition][i]].contents.ammo > 0 then
                distanceToFirebase = distance
                returnBaseIndex = FirebaseIds[coalition][i]
            end
        end
    end
    if returnBaseIndex ~= 0 then
        return returnBaseIndex
    else
        return -1
    end
end
function fbFuncs.inRange(firebase, tgtPoint)
    local inRange = Utils.PointDistance(firebase.positions.location, tgtPoint) <= firebaseRanges[firebase.fbType]
    return inRange
end
function Firebases.rocketFire(point, coalitionId, playerName)
    local inAnyRange = false
    for j = 1, #FirebaseIds[coalitionId] do
        local firebase = Firebases[FirebaseIds[coalitionId][j]]
        if not firebase:isAssigned() and fbFuncs.inRange(firebase, point) then
            if firebase.contents.ammo > 0 then
                firebase:assign()
                local fakePoint = {}
                fakePoint.pos = {x = 0, z = 0}
                fakePoint.pos.x = point.x
                fakePoint.pos.z = point.z
                fakePoint.playerName = playerName
                fbFuncs.firebaseFire(firebase, fakePoint)
                return true
            end
        elseif fbFuncs.inRange(firebase, point) then
            inAnyRange = true
        end
    end
    if inAnyRange == false then
        return true
    end
    return false
end
function Firebases.sendFireMission(coalitionId)
    for i = 1, #targetMarks do
        if targetMarks[i].coalition == coalitionId then
            local closestIndex = Firebases.getClosestUnassignedFirebaseInRangeByType(targetMarks[i].pos, coalitionId, targetMarks[i].fbType)
            if closestIndex ~= -1 then
                local firebase = Firebases[closestIndex]
                if firebase.contents.ammo > 0 then
                    if targetMarks[i].fbType == "STARSHELL" then
                        firebase:expendAmmo(1)
                        timer.scheduleFunction(fbFuncs.firebaseIllum, targetMarks[i].pos, timer:getTime() + (5 + math.random(4)))
                        trigger.action.removeMark(targetMarks[i].id)
                        table.remove(targetMarks, i)
                        return
                    else
                        firebase:assign()
                        fbFuncs.firebaseFire(firebase, targetMarks[i])
                        table.remove(targetMarks, i)
                        return
                    end
                end
            end
            if targetMarks[i].fbType == "BATTLE" then
                local shipGroups = coalition.getGroups(coalitionId, 3)
                for j=1, #shipGroups do
                    if shipGroups[j]:getUnit(1):hasAttribute('Armed ships') and (shipGroups[j]:getUnit(1):getTypeName() == "leander-gun-andromeda" or shipGroups[i]:getUnit(1):getTypeName() == "leander-gun-condell") then
                        local thawkShipGroup = shipGroups[j]
                        if thawkShipGroup ~= nil then
                            local thawkShipUnit = thawkShipGroup:getUnit(1)
                            if thawkShipUnit then
                                local thawkShipPoint = thawkShipUnit:getPoint()
                                if thawkShipPoint then
                                    local mission = {}
                                    mission.x = targetMarks[i].pos.x
                                    mission.y = targetMarks[i].pos.z
                                    mission.radius = 20
                                    mission.expendQty = 10
                                    mission.expendQtyEnabled = true
                                    local fire = {id = 'FireAtPoint', params = mission}
                                    thawkShipGroup:getController():pushTask(fire)
                                    trigger.action.removeMark(targetMarks[i].id)
                                    table.remove(targetMarks, i)
                                    local lineId = DrawingTools.newMarkId()
                                    trigger.action.lineToAll(coalitionId, lineId, thawkShipPoint, {x = mission.x, y = 0, z = mission.y}, {0,0,0,1}, 1, true, nil)
                                    timer.scheduleFunction(trigger.action.removeMark, lineId, timer:getTime() + 180)
                                    return 1
                                end
                            end
                        end
                        return 0
                    end
                end
            end
        end
    end
end
function fbFuncs.firebaseIllum(point)
    if point then
        trigger.action.illuminationBomb({x=point.x, y = land.getHeight({x = point.x, y = point.z})+700, z = point.z}, 8000)
    end
end
function fbFuncs.firebaseFire(firebase, targetmark)
    local mission = {}
    local fbGroups = firebase.contents.groups
    mission.x = targetmark.pos.x
    mission.y = targetmark.pos.z
    mission.radius = 50
    mission.expendQty = firebaseExpendQtys[firebase.fbType]/#fbGroups
    if targetmark.fbType == "SUPPRESS" then
        mission.expendQty = mission.expendQty * 4
    end
    if firebase.contents.ammo < mission.expendQty then mission.expendQty = firebase.contents.ammo end
    mission.expendQtyEnabled = true
    local fire = {id = 'FireAtPoint', params = mission}
    --Group.getByName(firebase:getGroupName()):getController():pushTask(fire)
    local assignedArtyNames = {}
    for i = 1, #fbGroups do
        local artGroup = Group.getByName(fbGroups[i])
        if artGroup ~= nil then
            artGroup:getController():pushTask(fire)
            for j = 1, artGroup:getSize() do
                local artUnit = artGroup:getUnit(j)
                if artUnit then
                    table.insert(assignedArtyNames, artUnit:getName())
                end
            end
        end
    end
    if targetmark.playerName and assignedArtyNames then
        for i = 1, #assignedArtyNames do
            gunAssignments[assignedArtyNames[i]] = targetmark.playerName
        end
    end
    local missionTime = firemissionDelays[firebase.fbType].aiming + ((mission.expendQty-1)*firemissionDelays[firebase.fbType].perShot)
    timer.scheduleFunction(fbFuncs.suppressArea, {point = targetmark.pos, radius = 500, duration = ((mission.expendQty)*firemissionDelays[firebase.fbType].perShot) + 15}, timer:getTime() + firemissionDelays[firebase.fbType].aiming + 15)
    firebase:expendAmmo(mission.expendQty)
    Firebases.updateAmmoCounter(firebase)
    if targetmark.id then
        --trigger.action.removeMark(targetmark.id)
        fbFuncs.firingMarkUpdate(targetmark.id, targetmark.pos, targetmark.coalition, firebase.fbType, mission.expendQty)
    end
    fbFuncs.firingDraw(firebase, {x = mission.x, y = mission.y})
    timer.scheduleFunction(fbFuncs.cleanFireMission, {firebase = firebase, assignedArtyNames = assignedArtyNames}, timer:getTime() + missionTime + gracePeriod)
end
function fbFuncs.firingMarkUpdate(targetmarkId, point, coalitionId, fbType, shots)
    trigger.action.removeMark(targetmarkId)
    local aimingMarkId = DrawingTools.newMarkId()
    local textPoint = {x = point.x + 30, y = point.y, z = point.z +  30}
    trigger.action.textToAll(coalitionId, aimingMarkId, textPoint, {0,0,0,1}, {1,1,1,1}, 10, true, "Aiming")
    timer.scheduleFunction(fbFuncs.addFiringMark, {markId = aimingMarkId, text = "Firing", duration = firemissionDelays[fbType].perShot * (shots-1)}, timer:getTime() + firemissionDelays[fbType].aiming)
end
--markId, text, duration, coalitionId
function fbFuncs.addFiringMark(param)
    trigger.action.setMarkupText(param.markId, "Firing")
    timer.scheduleFunction(trigger.action.removeMark, param.markId, timer:getTime() + param.duration)
end
function fbFuncs.firingDraw(firebase, missionLoc)
    if firebase.markups.firing.circle == 0 then
        local circleId = DrawingTools.newMarkId()
        trigger.action.circleToAll(firebase.coalition, circleId, firebase.positions.location, 25, {0,0,0,1}, {1,0,0,0.8}, 3, true, nil)
        firebase.markups.firing.circle = circleId
    else
        trigger.action.setMarkupColorFill(firebase.markups.firing.circle, {1,0,0,0.8})
    end
    if firebase.markups.firing.line == 0 then
        local lineId = DrawingTools.newMarkId()
        trigger.action.lineToAll(firebase.coalition, lineId, firebase.positions.location, {x = missionLoc.x, y = 0, z = missionLoc.y}, {0,0,0,1}, 1, true, nil)
        firebase.markups.firing.line = lineId
    else
        trigger.action.setMarkupPositionEnd(firebase.markups.firing.line, {x = missionLoc.x, y = 0, z = missionLoc.y})
    end
end
--firebase
function fbFuncs.cleanFireMission(param)
    --trigger.action.removeMark(param.circleId)
    trigger.action.setMarkupColorFill(param.firebase.markups.firing.circle, {0,0,0,0.1})
    trigger.action.setMarkupPositionEnd(param.firebase.markups.firing.line, param.firebase.positions.location)
    if param.assignedArtyNames then
        local missionPlayer = gunAssignments[param.assignedArtyNames[1]]
        for i = 1, #param.assignedArtyNames do
            gunAssignments[param.assignedArtyNames[i]] = nil
        end
        if assignedGunKills[missionPlayer] then
            trigger.action.outTextForCoalition(param.firebase.coalition, missionPlayer .. "'s fire mission scored " .. assignedGunKills[missionPlayer] .. " kills.", 10, false)
            if WWEvents then
                WWEvents.fireMissionCompleted(param.firebase.coalition, missionPlayer, assignedGunKills[missionPlayer])
            end
            assignedGunKills[missionPlayer] = nil
        end
    end
    for i = 1, #param.firebase.contents.groups do
        local fbGroup = param.firebase.contents.groups[i]
        if fbGroup then
            local fbGroupObj = Group.getByName(fbGroup)
            if fbGroupObj then
                local fbGroupObjController = fbGroupObj:getController()
                if fbGroupObjController then
                    fbGroupObjController:setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                end
            end
        end
    end
    param.firebase:unassign()
end
function fbFuncs.checkFirebases()
    for c = 1, 2 do
        for i = 1, #FirebaseIds[c] do
            local removeIndices = {}
            local checkingBase = Firebases[FirebaseIds[c][i]]
            if checkingBase ~= nil then
                local checkingGroups = checkingBase.contents.groups
                if checkingGroups ~= nil then
                    if #checkingGroups > 0 then
                        for j = 1, #checkingGroups do
                            if checkingGroups[j] ~= nil then
                                local checkGroup = Group.getByName(checkingGroups[j])
                                if checkGroup == nil or checkGroup:isExist() == false or checkGroup:getSize() == 0 then
                                    if checkGroup ~= nil then checkGroup:destroy() end
                                    fbFuncs.cleanJunk(Firebases[FirebaseIds[c][i]].positions.location)
                                    table.insert(removeIndices, j)
                                end
                            end
                        end
                    else
                        if checkingBase.fbType == "MORTAR" or checkingBase.fbType == "HOWITZER" then
                            Firebases.destroyFirebase(checkingBase)
                        end
                    end
                end
                if #removeIndices > 0 then
                    for k = 1, #removeIndices do
                        table.remove(checkingBase.contents.groups, removeIndices[k])
                    end
                    Firebases.updateGroupCounter(checkingBase)
                end
                if checkingBase.contents.truck then
                    local truck = Group.getByName(checkingBase.contents.truck)
                    if truck == nil or truck:isExist() == false or truck:getSize() == 0 then
                        fbFuncs.spawnTruck(Firebases[FirebaseIds[c][i]])
                    end
                end
            end
        end
    end
    timer.scheduleFunction(fbFuncs.checkFirebases, nil, timer:getTime() + firebaseCheckInterval)
end
fbFuncs.checkFirebases()
function fbFuncs.newBaseID()
    local newId = fbId
    fbId = fbId + 1
    return newId
end
function Firebases.newMarkId()
    markId = markId+1
    return markId
end
function fbFuncs.cleanJunk(location)
    local volS = {
      id = world.VolumeType.SPHERE,
      params = {
        point = location,
        radius = 100
      }
    }
    world.removeJunk(volS)
end
function fbFuncs.fireCheckLoop()
    if #targetMarks > 0 then
        Firebases.sendFireMission(1)
        Firebases.sendFireMission(2)
    end
    timer.scheduleFunction(fbFuncs.fireCheckLoop, nil, timer:getTime() + 15)
end
fbFuncs.fireCheckLoop()
function dump(o)
    if o == nil then
        return "~nil~"
    elseif type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
