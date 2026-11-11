-- This script functions as a centralized command and control for theater anti submarine operations
-- Phase 1
-- 1. Gather intel from escort ships: subs in active sonar range and periscopes in radar range and sonobuoys
-- 2. Generate a list of reports from all ships.
  -- start with just sonobuoys
-- 3. Broadcast these reports over a list of radio frequencies
-- 4. Update a map drawing area with the reports for planes that can't tune / don't want to tune. 
-- 5. Draw report locations on the map
-- Phase 2

-- 1. Allow nearby ships to guide players to contacts like GCI

-- Phase 3
-- 1. Send depth charge bombers after tracked contacts 

TASWC = {}
local taswc = {}

taswc.contactIdCounters = {
    [1] = 1,
    [2] = 1
}

taswc.prosecutorGroups = {
    [1] = {

    },
    [2] = {

    }
}

taswc.contactIds = {
    [1] = {},
    [2] = {}
}

taswc.contacts = {
    [1] = {},
    [2] = {}
}

taswc.messages = {
    [1] = "",
    [2] = ""
}
taswc.messageBoxIds = {
    [1] = 0,
    [2] = 0
}

taswc.markups = {
    [1]  = {},
    [2] = {}
}

taswc.frequences = {
    [1] = {
        freq = 100,
        range = "MHz"
    },
    [2] = {
        freq = 2.8,
        range = "MHz"
    }
}

taswc.colors = {
    [0] = {.5,.5,.5,1},
    [1] = {1,0,0,1},
    [2] = {0,0,1,1},
}
local taswcEvents = {}
function taswcEvents:onEvent(event)
    --on mark change
    if (event.id == world.event.S_EVENT_MARK_CHANGE) then
        if event.text then
            local vidMatch = false
            local identString = string.sub(event.text,1,3)
            if string.find(string.upper(identString), "VID") then
                vidMatch = true
            end
            if vidMatch then
                local playerName = nil
                local playerCoalition = nil
                local debug = false
                if event.initiator ~= nil then
                    playerName = event.initiator:getPlayerName()
                    playerCoalition = event.initiator:getCoalition()
                else
                    debug = true
                end
                if playerName and playerCoalition and event.pos or debug then
                    local coId = tonumber( string.sub(event.text,4,4))
                    if coId and coId >= 0 and coId < 3 then
                        if not debug then
                            local contactToId = taswc.findNearbyContact(playerCoalition, event.pos)
                            if contactToId then
                                TASWC.idContact(playerCoalition, contactToId, coId)
                            end
                        else
                            local contactToId = taswc.findNearbyContact(2, event.pos)
                            if contactToId then
                                TASWC.idContact(2, contactToId, coId)
                            end
                        end
                    end
                    trigger.action.removeMark(event.idx)
                end
            else
                identString = string.sub(event.text,1,4)
                if string.find(string.upper(identString), "SPOT") then
                    local contactToAdd, contactType = taswc.findNearbyGroup(2, event.pos)
                    if contactToAdd and contactType then
                        TASWC.addContact(2, contactToAdd, contactType)
                        taswc.updateContacts()
                        trigger.action.removeMark(event.idx)
                    end
                end
            end
        end
    end
end
world.addEventHandler(taswcEvents)

function TASWC.addProsecutor(coalitionId, prosecutorGroupName, targetTypes)
    local prosecutorGroup = Group.getByName(prosecutorGroupName)
    if prosecutorGroup then
       local prosecutorLeadUnit = prosecutorGroup:getUnit(1)
       if prosecutorLeadUnit then
            local prosecutorPoint = prosecutorLeadUnit:getPoint()
            if prosecutorPoint then
                taswc.prosecutorGroups[coalitionId][prosecutorGroupName] = {groupName = prosecutorGroupName, point = prosecutorPoint, targetTypes = targetTypes, assigned = false}
                trigger.action.outText("Added prosecutor group: " .. prosecutorGroupName, 10, false)
            end
       end
    end
end

function TASWC.addContact(coalitionId, contactName, contactType)
    if not taswc.contactIds[coalitionId][contactName] then
        taswc.contactIds[coalitionId][contactName] = taswc.contactIdCounters[coalitionId]
        taswc.contactIdCounters[coalitionId] = taswc.contactIdCounters[coalitionId] + 1
    end
    taswc.contacts[coalitionId][contactName] = {contactName = contactName, markups = {[1] = 0, [2] = 0,[3] = 0}, point = nil, heading = 0, speed = 0, vid = 0, contactType = contactType, engaged = false, engagedBy = ""}
    trigger.action.outText("Added contact: " .. contactName .. " | " .. taswc.contactIds[coalitionId][contactName], 10, false)
end

function TASWC.idContact(coalitionId, contactName, vid)
    if taswc.contacts[coalitionId][contactName] then
        taswc.contacts[coalitionId][contactName].vid = vid
        taswc.updateContacts()
    end
end

function taswc.updateContacts()
    for c = 1, 2 do
        taswc.messages[c] = ""
        for contactName, contactInfo in pairs(taswc.contacts[c]) do
            local contactLost = false
            local contactGroup = Group.getByName(contactName)
            if contactGroup then
                local contactLeadUnit = contactGroup:getUnit(1)
                if contactLeadUnit then
                    local contactPoint = contactLeadUnit:getPoint()
                    local contactPosition = contactLeadUnit:getPosition()
                    local contactVelocity = contactLeadUnit:getVelocity()
                    local contactTrueCoalition = contactGroup:getCoalition()
                    if contactTrueCoalition == c then
                        TASWC.idContact(c, contactName, contactTrueCoalition)
                    end
                    if contactPoint and contactPosition then
                        for i = 1, #contactInfo.markups do
                            trigger.action.removeMark(contactInfo.markups[i])
                        end
                        contactInfo.point = contactPoint
                        contactInfo.heading = math.floor(Utils.getDegBearingFromPosition(contactPosition))
                        contactInfo.speed = (contactVelocity.x^2 + contactVelocity.y^2 + contactVelocity.z^2)^0.5

                        local groupLat, groupLong, groupAlt = coord.LOtoLL(contactInfo.point)
                        local groupMGRS = coord.LLtoMGRS(groupLat, groupLong)
                        local eastingString = tostring(groupMGRS.Easting)
                        local northingString = tostring(groupMGRS.Northing)
                        for i = 1, 5 - #eastingString do
                            eastingString = tostring(0)..eastingString
                        end
                        for i = 1, 5 - #northingString do
                            northingString = tostring(0)..northingString
                        end
                        local locationMGRSString = groupMGRS.MGRSDigraph .." " .. eastingString:sub(1,2).. " " .. northingString:sub(1,2)

                        local contactMessage = "Contact " .. taswc.contactIds[c][contactName] .. " | " .. locationMGRSString .." | BRG: ".. contactInfo.heading .."\n"
                        taswc.messages[c] = taswc.messages[c] .. contactMessage
                        taswc.drawContact(c, contactName, contactInfo.contactType)
                        if contactInfo.vid ~= 0 and contactInfo.vid ~= c then
                            if not contactInfo.engaged then
                                taswc.prosecuteTarget(c, contactInfo)
                            end
                        end
                    end
                else
                    contactLost = true
                end
            else
                contactLost = true
            end
            if contactLost then
                for i = 1, #contactInfo.markups do
                    trigger.action.removeMark(contactInfo.markups[i])
                end
                taswc.contacts[c][contactName] = nil
            end
        end
        taswc.updateNotice(c)
    end
end

function taswc.prosecuteTarget(coalitionId, contactInfo)
    local targetGroup = Group.getByName(contactInfo.contactName)
    if targetGroup then
        local targetGroupId = targetGroup:getID()
        if targetGroupId then
            local proesecutorGroupName = taswc.getProsecutorGroupName(coalitionId, contactInfo.contactType, contactInfo.point)
            if proesecutorGroupName then
                local proesecutorGroup = Group.getByName(proesecutorGroupName)
                if proesecutorGroup then
                    local proesecutorGroupController = proesecutorGroup:getController()
                    if proesecutorGroupController then
                        local prosecuteTask = {
                            id = 'AttackGroup',
                            params = {
                                groupId = targetGroupId
                            }
                        }
                        proesecutorGroupController:setTask(prosecuteTask)
                        taswc.contacts[coalitionId][contactInfo.contactName].engaged = true
                        taswc.prosecutorGroups[coalitionId][proesecutorGroupName].assigned = true
                    end
                end
            end
        end
    end
end

function taswc.getProsecutorGroupName(coalitionId, contactType, contactPoint)
    local pGroupname = ""
    local closestCapablePGroupDist = -1
    for prosecutorGroupName, info in pairs(taswc.prosecutorGroups[coalitionId]) do
        if not info.assigned and info.targetTypes[contactType] then
            local pPoint = info.point
            if pPoint and contactPoint then
                local pDistance = Utils.PointDistance(pPoint, contactPoint)
                if closestCapablePGroupDist == -1 or pDistance < closestCapablePGroupDist then
                    closestCapablePGroupDist = pDistance
                    pGroupname = prosecutorGroupName
                end
            end
        end
    end
    if closestCapablePGroupDist > -1 then
        return pGroupname
    end
end

function taswc.findNearbyContact(coalitionId, searchPoint)
    local closestDistance = -1
    local closestContactName = nil
    for contactName, contactInfo in pairs(taswc.contacts[coalitionId]) do
        local contactPoint = contactInfo.point
        if contactPoint then
            local distanceToContact = Utils.PointDistance(searchPoint, contactPoint)
            if distanceToContact < 3000 then
                if closestDistance == -1 or distanceToContact < closestDistance then
                    closestDistance = distanceToContact
                    closestContactName = contactName
                end
            end
        end
    end
    if closestContactName then
        return closestContactName
    end
end

function taswc.findNearbyGroup(coalitionId, searchPoint)
    trigger.action.outText("searching for nearby groups", 5, false)
    local closestDistance = -1
    local closestContactName = nil
    local closestContactType = "surface"
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = searchPoint,
            radius = 2000
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getDesc().category == 3 and foundItem:isExist() and foundItem:isActive() then
            trigger.action.outText("Found: " .. foundItem:getName(), 5, false)
            local foundPoint = foundItem:getPoint()
            if foundPoint ~= nil then
                local distance = Utils.PointDistance(searchPoint, foundPoint)
                if distance ~= nil then
                    if closestDistance == -1 or distance < closestDistance then
                        closestDistance = distance
                        closestContactName = foundItem:getGroup():getName()
                        if SUBTYPE and (foundItem:getTypeName() == SUBTYPE[1] or foundItem:getTypeName() == SUBTYPE[2]) then
                            closestContactType = "sub"
                        end
                    end
                end
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)

    if closestContactName then
        trigger.action.outText("Returning " .. closestContactName, 5, false)
        return closestContactName, closestContactType
    end
end


function taswc.drawContact(coalitionId, contactName, contactType)
    local contactInfo = taswc.contacts[coalitionId][contactName]
    if contactInfo then
        local contactPoint = contactInfo.point
        if contactPoint then
            if contactInfo.vid ~= 0 and contactInfo.vid ~= coalitionId  then
                if contactType == "sub" then
                    taswc.drawSubsurfaceEnemy(coalitionId, contactInfo)
                else
                    taswc.drawSurfaceEnemy(coalitionId, contactInfo)
                end
            elseif contactInfo.vid == 0 or contactInfo.vid == coalitionId then
                if contactType == "sub" then
                    taswc.drawSubsurfaceContact(coalitionId, contactInfo)
                else
                    taswc.drawSurfaceContact(coalitionId, contactInfo)
                end
            end
        end
    end
end

function taswc.drawSubsurfaceEnemy(coalitionId, contactInfo) -- half diamond
    local contactPoint = contactInfo.point
    local chevronLeftId = DrawingTools.newMarkId()
    local chevronRightId = DrawingTools.newMarkId()
    local dotId = DrawingTools.newMarkId()
    local chevronStartPoint = { x = contactPoint.x - 200, y = 0, z = contactPoint.z} -- rightBottom
    local chevronLeftBox1 = { x = chevronStartPoint.x - 40, y = 0, z = contactPoint.z} -- left bottom
    local chevronLeftBox2 = { x = contactPoint.x - 20, y = 0, z = contactPoint.z - 220} -- left upper
    local chevronLeftBox3 = { x = contactPoint.x, y = 0, z = contactPoint.z - 200} -- right upper
    local chevronRightBox1 = { x = chevronStartPoint.x - 40, y = 0, z = contactPoint.z}
    local chevronRightBox2 = { x = contactPoint.x, y = 0, z = contactPoint.z + 200}
    local chevronRightBox3 = { x = contactPoint.x - 20 , y = 0, z = contactPoint.z + 220}

    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, chevronLeftId)
    table.insert(contactInfo.markups, chevronRightId)

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.quadToAll(coalitionId, chevronLeftId, chevronStartPoint, chevronLeftBox1, chevronLeftBox2, chevronLeftBox3, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.quadToAll(coalitionId, chevronRightId, chevronRightBox1, chevronStartPoint, chevronRightBox2, chevronRightBox3, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
end
function taswc.drawSubsurfaceContact(coalitionId, contactInfo) -- half square
    local contactPoint = contactInfo.point
    local lowerBarId = DrawingTools.newMarkId()
    local leftBarId = DrawingTools.newMarkId()
    local rightBarId = DrawingTools.newMarkId()
    local dotId = DrawingTools.newMarkId()
    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, lowerBarId)
    table.insert(contactInfo.markups, leftBarId)
    table.insert(contactInfo.markups, rightBarId)

    local lowerBarLowerLeft = {x = contactPoint.x - 240, y = 0, z = contactPoint.z - 200}
    local lowerBarUpperRight = {x = contactPoint.x - 200, y = 0, z = contactPoint.z + 200}

    local leftBarLowerLeft = { x = lowerBarLowerLeft.x, y = 0, z = lowerBarLowerLeft.z - 40}
    local leftBarUpperRight = { x = contactPoint.x + 60, y = 0, z = lowerBarLowerLeft.z}

    local rightBarLowerLeft = { x = lowerBarLowerLeft.x, y = 0, z = lowerBarUpperRight.z}
    local rightBarUpperRight = {x = contactPoint.x + 60, y = 0, z = lowerBarUpperRight.z + 40}

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)

    trigger.action.rectToAll(coalitionId, lowerBarId, lowerBarLowerLeft, lowerBarUpperRight, {0,0,0,1}, taswc.colors[contactInfo.vid], 1,true, nil)

    trigger.action.rectToAll(coalitionId, leftBarId, leftBarLowerLeft, leftBarUpperRight, {0,0,0,1}, taswc.colors[contactInfo.vid], 1,true, nil)

    trigger.action.rectToAll(coalitionId, rightBarId, rightBarLowerLeft, rightBarUpperRight, {0,0,0,1}, taswc.colors[contactInfo.vid], 1,true, nil)
end
function taswc.drawSurfaceEnemy(coalitionId, contactInfo) -- diamond
    local contactPoint = contactInfo.point
    local chevronLeftId = DrawingTools.newMarkId()
    local chevronRightId = DrawingTools.newMarkId()
    local dotId = DrawingTools.newMarkId()
    local chevronStartPoint = { x = contactPoint.x - 200, y = 0, z = contactPoint.z} -- rightBottom
    local chevronLeftBox1 = { x = chevronStartPoint.x - 40, y = 0, z = contactPoint.z} -- left bottom
    local chevronLeftBox2 = { x = contactPoint.x - 20, y = 0, z = contactPoint.z - 220} -- left upper
    local chevronLeftBox3 = { x = contactPoint.x, y = 0, z = contactPoint.z - 200} -- right upper
    local chevronRightBox1 = { x = chevronStartPoint.x - 40, y = 0, z = contactPoint.z}
    local chevronRightBox2 = { x = contactPoint.x, y = 0, z = contactPoint.z + 200}
    local chevronRightBox3 = { x = contactPoint.x - 20 , y = 0, z = contactPoint.z + 220}

    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, chevronLeftId)
    table.insert(contactInfo.markups, chevronRightId)

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.quadToAll(coalitionId, chevronLeftId, chevronStartPoint, chevronLeftBox1, chevronLeftBox2, chevronLeftBox3, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.quadToAll(coalitionId, chevronRightId, chevronRightBox1, chevronStartPoint, chevronRightBox2, chevronRightBox3, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)

end
function taswc.drawSurfaceContact(coalitionId, contactInfo) -- square
    local contactPoint = contactInfo.point
    local lowerBarId = DrawingTools.newMarkId()
    local leftBarId = DrawingTools.newMarkId()
    local rightBarId = DrawingTools.newMarkId()
    local dotId = DrawingTools.newMarkId()
    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, lowerBarId)
    table.insert(contactInfo.markups, leftBarId)
    table.insert(contactInfo.markups, rightBarId)

    local lowerBarLowerLeft = {x = contactPoint.x - 240, y = 0, z = contactPoint.z - 200}
    local lowerBarUpperRight = {x = contactPoint.x - 200, y = 0, z = contactPoint.z + 200}

    local leftBarLowerLeft = { x = lowerBarLowerLeft.x, y = 0, z = lowerBarLowerLeft.z - 40}
    local leftBarUpperRight = { x = contactPoint.x + 60, y = 0, z = lowerBarLowerLeft.z}

    local rightBarLowerLeft = { x = lowerBarLowerLeft.x, y = 0, z = lowerBarUpperRight.z}
    local rightBarUpperRight = {x = contactPoint.x + 60, y = 0, z = lowerBarUpperRight.z + 40}

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)

    trigger.action.rectToAll(coalitionId, lowerBarId, lowerBarLowerLeft, lowerBarUpperRight, {0,0,0,1}, taswc.colors[contactInfo.vid], 1,true, nil)

    trigger.action.rectToAll(coalitionId, leftBarId, leftBarLowerLeft, leftBarUpperRight, {0,0,0,1}, taswc.colors[contactInfo.vid], 1,true, nil)

    trigger.action.rectToAll(coalitionId, rightBarId, rightBarLowerLeft, rightBarUpperRight, {0,0,0,1}, taswc.colors[contactInfo.vid], 1,true, nil)
end

function taswc.updateNotice(coalitionId)
    local noticeMarkId = taswc.markups[coalitionId].notice.markId
    trigger.action.setMarkupText(noticeMarkId, taswc.messages[coalitionId])
end
function taswc.init()
    for c = 1,2 do
        local noticeZone = trigger.misc.getZone(c.."-taswc-notice")
        if noticeZone then
            taswc.markups[c].notice = {}
            taswc.markups[c].notice.point = noticeZone.point
            taswc.markups[c].notice.markId = DrawingTools.newMarkId()
            trigger.action.textToAll(c, taswc.markups[c].notice.markId, taswc.markups[c].notice.point, {0,0,0,1}, {1,1,1,0.5}, 10, true, "Init")
        end
    end
end
function taswc.mainloop()
    taswc.updateContacts()
    timer.scheduleFunction(taswc.mainloop, nil, timer:getTime() + 10)
end
taswc.init()
taswc.mainloop()
TASWC.addProsecutor(2, "killer", {["surface"] = true})
