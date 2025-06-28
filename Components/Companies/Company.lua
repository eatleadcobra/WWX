local cm = {}
cm.status = {
    [0] = "Inactive",
    [1] = "Moving",
    [2] = "Defending",
    [3] = "Under Attack",
    [4] = "Defeated"
}


cm.casFreqs = {
    [1] = 45,
    [2] = 155,
}
cm.casModulation = {
    [1] = 1,
    [2] = 0,
}
if CAS then
    cm.casFreqs[1] = REDCASFREQ
    cm.casModulation[1] = REDCASMOD
    cm.casFreqs[2] = BLUECASFREQ
    cm.casModulation[2] = BLUECASMOD
end
Company = {
    id = 0,
    coalitionId = 0,
    status = nil,
    statusChangedTime = 0,
    point = {},
    heading = 0,
    units = {},
    waypoints = {},
    groupName = "",
    markUps = {
        marker = 0,
        destination = 0
    },
    deployedGroupNames = {},
    deployableGroups = {},
    arrived = false,
    onRoad = false,
    speed = nil,
    isDeployed = false,
    bp = 0,
    isConvoy = false,
    isShip = false,
    casTracked = false,
    convoyParam = {},
    groupType = 2,
    spawnTime = 0,
}
function Company.new(coalitionId, persistent, platoons, onRoad, convoy, ship, convoyParam, navalUnit)
    local newCpy = Company:deepcopy()
    newCpy.id = Utils.uuid()
    newCpy.coalitionId = coalitionId
    if navalUnit then
        newCpy.groupType = 3
    end
    if convoy then
        newCpy.isConvoy = true
        newCpy.convoyParam = convoyParam
    elseif ship then
        newCpy.isShip = true
        newCpy.convoyParam = convoyParam
    end
    if onRoad == nil or onRoad == false then
        newCpy.onRoad = false
    else
        newCpy.onRoad = true
    end
    for i = 1, #platoons do
        local pltUnits = Company.deepcopy(Platoons[coalitionId][PlatoonTypes[platoons[i]]])
        for j = 1, #pltUnits do
            table.insert(newCpy.units, pltUnits[j])
            if PlatoonUnitCarrierTypeNames[pltUnits[j]] then
                table.insert(newCpy.deployableGroups, Platoons[coalitionId]["DeployedInf"])
            end
        end
    end
    newCpy.initUnits = newCpy.units
    if persistent then
        Companies[newCpy.id] = newCpy
        table.insert(CompanyIDs[newCpy.coalitionId], newCpy.id)
    end
    return newCpy
end
function Company.newFromTable(cpyData)
    local newCpy = Company:deepcopy()
    newCpy.id = cpyData.id
    newCpy.coalitionId = cpyData.coalitionId
    newCpy.status = cpyData.status
    newCpy.statusChangedTime = cpyData.statusChangedTime
    newCpy.point = cpyData.point
    newCpy.heading = cpyData.heading
    newCpy.initUnits = cpyData.initUnits
    newCpy.units = cpyData.units
    newCpy.waypoints = cpyData.waypoints
    newCpy.groupName = cpyData.groupName
    newCpy.deployedGroupNames = {}
    newCpy.deployableGroups = cpyData.deployableGroups
    newCpy.arrived = cpyData.arrived
    newCpy.onRoad = cpyData.onRoad
    newCpy.speed = cpyData.speed
    newCpy.bp = cpyData.bp
    newCpy.isConvoy = cpyData.isConvoy
    newCpy.isShip = cpyData.isShip
    newCpy.convoyParam = cpyData.convoyParam
    newCpy.groupType = cpyData.groupType
    newCpy.spawnTime = 0
    return newCpy
end
function Company.setWaypoints(self, waypoints, bp, speed)
    self.point = waypoints[1]
    self.waypoints = waypoints
    self.bp = bp
    local vector = Utils.VecNormalize({x = self.waypoints[2].x - self.waypoints[1].x, y = self.waypoints[2].y - self.waypoints[1].y, z = self.waypoints[2].z - self.waypoints[1].z})
    ---@diagnostic disable-next-line: deprecated
    local bearing = math.atan2(vector.z, vector.x)
    if bearing < 0 then bearing = bearing + (2 * math.pi) end
    self.heading = bearing
    if speed then self.speed = speed end
end
function Company.spawn(self)
    self.spawnTime = timer.getTime()+1
    local points = {[1] = self.waypoints[1], [2] = self.waypoints[2]}
    if self.isShip then
        points = self.waypoints
    end
    if self.onRoad == false and self.arrived == false and self.isShip == false then
        local vector = Utils.VecNormalize({x = self.waypoints[1].x - self.waypoints[2].x, y = self.waypoints[1].y - self.waypoints[2].y, z = self.waypoints[1].z - self.waypoints[2].z})
        local formPoint = Utils.VectorAdd(self.waypoints[2], Utils.ScalarMult(vector, 300))
        local roadPointx, roadPointy = land.getClosestPointOnRoads("roads", formPoint.x, formPoint.z)
        local roadPoint = {x = roadPointx, y = 0, z = roadPointy}
        --create waypoint table from waypoints list
        points = {[1] = self.waypoints[1], [2] = roadPoint, [3] = formPoint, [4] = self.waypoints[2]}
    end
    local groupWaypoints = SpawnFuncs.createWPListFromPoints(points, self.speed)
    local cpyGroupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(Company.coalitionId, 2, self.units, groupWaypoints)
    if self.onRoad == false and self.isShip == false then
        for j = 1, #cpyGroupTable["units"] do
            local deployPoint = self.waypoints[1]
            cpyGroupTable["units"][j].x = deployPoint.x + (12*(j-1))
            cpyGroupTable["units"][j].y = deployPoint.z + (12*(j-1))
            cpyGroupTable["units"][j].heading = self.heading
        end
        --cpyGroupTable["route"]["points"][1].action = "On Road"
        cpyGroupTable["route"]["points"][2].action = "On Road"
        cpyGroupTable["route"]["points"][#cpyGroupTable["route"]["points"]].action = "Rank"
    elseif self.isShip == false and self.groupType == 2 then
        cpyGroupTable["route"]["points"][1].action = "On Road"
        cpyGroupTable["route"]["points"][#cpyGroupTable["route"]["points"]].action = "On Road"
    end
    self.groupName = cpyGroupTable["name"]
    --spawn group
    coalition.addGroup(80+(2-self.coalitionId), self.groupType, cpyGroupTable)
    if self.isConvoy then
        self.convoyParam.convoyName = self.groupName
        DFS.checkConvoy(self.convoyParam)
    elseif self.isShip then
        self.convoyParam.convoyName = self.groupName
        DFS.checkShip(self.convoyParam)
    else
        if CAS then
            CAS.followGroup(self.coalitionId, self.groupName, cm.newCallsign(self.coalitionId), math.random(1,3), cm.casFreqs[self.coalitionId], cm.casModulation[self.coalitionId])
            self.casTracked = true
        end
    end
end
function Company.updateMission(self, listOfPoints, bp)
    local cpyGroup = Group.getByName(self.groupName)
    if cpyGroup then
        self.bp = bp
        local cpyController = cpyGroup:getController()
        if cpyController then
            self.waypoints = listOfPoints
            local pointsLength = #listOfPoints
            local vector = Utils.VecNormalize({x = listOfPoints[pointsLength-1].x - listOfPoints[pointsLength].x, y = listOfPoints[pointsLength-1].y - listOfPoints[pointsLength].y, z = listOfPoints[pointsLength-1].z - listOfPoints[pointsLength].z})
            local formPoint = Utils.VectorAdd(listOfPoints[pointsLength], Utils.ScalarMult(vector, 200))
            local points = {}
            for i = 1, pointsLength do
                if i == pointsLength then
                    points[pointsLength] = formPoint
                    points[pointsLength+1] = listOfPoints[pointsLength]
                else
                    points[i] = listOfPoints[i]
                end
            end
            local newWaypoints = SpawnFuncs.createWPListFromPoints(points)
            local newMission = SpawnFuncs.createMission(newWaypoints)
            cpyController:setTask(newMission)
            self.spawnTime = timer.getTime()
        end
    end
end
function Company.deploy(self)
    self:undeploy()
    local cpyGroup = Group.getByName(self.groupName)
    local deployers = {}
    local anyDeployed = false
    for i = 1, #self.deployableGroups do
        local thisGroupDeployed = false
        for u = 1, cpyGroup:getSize() do
            if thisGroupDeployed == false then
                local unit = cpyGroup:getUnit(u)
                if unit then
                    if (PlatoonUnitCarrierTypeNames[unit:getTypeName()] == "APC" or PlatoonUnitCarrierTypeNames[unit:getTypeName()] == "IFV") then
                        if (deployers[unit:getName()] == nil) then
                            deployers[unit:getName()] = true
                            local pltUnits = {}
                            for p = 1, #self.deployableGroups[i] do
                                table.insert(pltUnits, self.deployableGroups[i][p])
                            end
                            local groupWaypoints = SpawnFuncs.createWPListFromPoints({[1] = unit:getPoint()})
                            local deployedGroupTable = SpawnFuncs.createGroupTableFromListofUnitTypes(Company.coalitionId, 2, pltUnits, groupWaypoints)
                            for j = 1, #deployedGroupTable["units"] do
                                local deployPoint = Utils.VectorAdd(unit:getPoint(), Utils.ScalarMult(Utils.RotateVector(unit:getPosition().x, 0.52 + (0.14 * (j-1))), 8+(((j-1)/2))))
                                deployedGroupTable["units"][j].x = deployPoint.x
                                deployedGroupTable["units"][j].y = deployPoint.z
                            end
                            table.insert(self.deployedGroupNames, deployedGroupTable["name"])
                            --spawn group
                            coalition.addGroup(80+(2-self.coalitionId), 2, deployedGroupTable)
                            anyDeployed = true
                            thisGroupDeployed = true
                        end
                    end
                end
            end
        end
    end
    self.isDeployed = anyDeployed
end
function Company.undeploy(self)
    if self.isDeployed then
        self.deployableGroups = {}
        for i = 1, #self.deployedGroupNames do
            local deployedGroup = Group.getByName(self.deployedGroupNames[i])
            if deployedGroup then
                local listOfUnits = {}
                for j = 1, deployedGroup:getSize() do
                    local unit = deployedGroup:getUnit(j)
                    if unit then
                        table.insert(listOfUnits, unit:getTypeName())
                    end
                end
                table.insert(self.deployableGroups, listOfUnits)
                deployedGroup:destroy()
                self.deployedGroupName = nil
                self.isDeployed = false
            end
        end
        self.deployedGroupNames = {}
    end
end
function Company.updateUnits(self, listOfUnits)
    self.units = {}
    for i = 1, #listOfUnits do
        table.insert(self.units, listOfUnits[i]:getTypeName())
    end
end
function Company.getRemainingStrength(self)
    if self.units and self.initUnits then
        return math.floor((#self.units/#self.initUnits)*100)
    else
        return 100
    end
end
function Company.despawn(self)
    local cpyGroup = Group.getByName(self.groupName)
    if cpyGroup then
        self:savePosition()
        cpyGroup:destroy()
    end
end
function Company.savePosition(self)
    local cpyGroup = Group.getByName(self.groupName)
    if cpyGroup then
        local cpyLead = cpyGroup:getUnit(1)
        if cpyLead then
            local cpyPoint = cpyLead:getPoint()
            if cpyPoint then
                self.point = cpyPoint
                self.waypoints[1] = cpyPoint
            end
        end
    end
end
function Company.updateMarks(self)
    if DrawingTools then
        if self.markUps.destination ~= 0 then
            trigger.action.setMarkupPositionStart(self.markUps.destination, self.point)
            trigger.action.setMarkupPositionEnd(self.markUps.destination, self.waypoints[#self.waypoints])
        else
            self.markUps.destination = DrawingTools.newMarkId()
            trigger.action.lineToAll(self.coalitionId, self.markUps.destination, self.point, self.waypoints[#self.waypoints], {0,0,0,0}, 1, true, nil)
        end
        if self.markUps.marker ~= 0 then
            trigger.action.setMarkupPositionStart(self.markUps.marker, self.point)
        else
            self.markUps.marker = DrawingTools.newMarkId()
            if self.isShip == false then
                trigger.action.circleToAll(self.coalitionId, self.markUps.marker, self.point, 75, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
            else
                trigger.action.circleToAll(self.coalitionId, self.markUps.marker, self.point, 200, {0,0,0,1}, {0,0,0,0}, 1, true, nil)
            end
        end
    end
end

function Company.setStatus(self, status)
    self.status = status
end
function Company.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Company.deepcopy(orig_key)] = Company.deepcopy(orig_value)
        end
        setmetatable(copy, Company.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
function cm.newCallsign(coalitionId)
    local callsign = CASCALLSIGNS.alphanumerics[coalitionId][CASCALLSIGNS.counts[coalitionId].alpha] .. "-" .. CASCALLSIGNS.counts[coalitionId].number
    CASCALLSIGNS.counts[coalitionId].number = CASCALLSIGNS.counts[coalitionId].number + 1
    if CASCALLSIGNS.counts[coalitionId].number > CASCALLSIGNS.numberLimit then
        CASCALLSIGNS.counts[coalitionId].alpha = CASCALLSIGNS.counts[coalitionId].alpha + 1
        CASCALLSIGNS.counts[coalitionId].number = 1
        if CASCALLSIGNS.counts[coalitionId].alpha > #CASCALLSIGNS.alphanumerics[coalitionId] then
            CASCALLSIGNS.counts[coalitionId].alpha = 1
        end
    end
    return callsign
end