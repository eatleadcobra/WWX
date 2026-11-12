-- This script functions as a centralized command and control for theater anti submarine operations
-- Phase 1 : functions for this are here but contact finding and reporting should be handled from the ship handler loops
-- 1. Gather intel from escort ships: subs in active sonar range and periscopes in radar range and sonobuoys
-- 2. Generate a list of reports from all ships.

-- 3. Update a map drawing area with the reports for planes that can't tune / don't want to tune. DONE
-- 4. Draw report locations on the map DONE
-- Phase 2

-- 1. Do this with script in general from one place, not per ship. Must be in range of a guiding unit though to be on "datalink"

-- Phase 3
-- 1. Send depth charge bombers after tracked sub contacts 
-- 2. Send ships after surface contacts

-- mist respawn group keeps dynamic spawns working. Do this for off shore surface prosecutorGroups so players can spawn a helo and blow up subs they find 
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

taswc.ashGroupNames = ANTISHIPGROUPS

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
                        elseif DEBUG then -- only failover to debug when running locally
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
                        if not debug then
                            local contactToAdd, contactType = taswc.findNearbyGroup(playerCoalition, event.pos)
                            if contactToAdd and contactType then
                                TASWC.addContact(playerCoalition, contactToAdd, contactType)
                                taswc.updateContacts()
                                trigger.action.removeMark(event.idx)
                            end
                        elseif DEBUG then  -- only failover to debug when running locally
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
end

function TASWC.idContact(coalitionId, contactName, vid)
    if taswc.contacts[coalitionId][contactName] then
        taswc.contacts[coalitionId][contactName].vid = vid
        taswc.updateContacts()
    end
end

function taswc.updateContacts()
    for c = 1, 2 do
        taswc.messages[c] = "  TASWC NOTICE  \n  Known Contacts:  \n"
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
                    if contactTrueCoalition == c and contactInfo.vid ~= c then
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
                        local vidString = "Unknown"
                        if contactInfo.vid == c then
                            vidString = "Friendly "
                        elseif contactInfo.vid ~= 0 and contactInfo.vid ~= c then
                            vidString = "Hostile  "
                        end
                        local contactMessage = "  Contact " .. taswc.contactIds[c][contactName] .. " | " .. vidString .. " | " .. locationMGRSString .." | BRG: ".. contactInfo.heading .."  \n"
                        taswc.messages[c] = taswc.messages[c] .. contactMessage
                        taswc.drawContact(c, contactName, contactInfo.contactType)
                        if contactInfo.vid ~= 0 and contactInfo.vid ~= c then
                            if not contactInfo.engaged then
                                local strat = taswc.determineProsecutionStrategy(coalition, contactInfo)
                                if strat == "surf" then
                                    taswc.prosecuteTargetSurface(c, contactInfo)
                                elseif strat == "air" then
                                    taswc.prosecuteTargetAir(c, contactInfo)
                                end
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

function taswc.determineProsecutionStrategy(coalitionId, contactInfo)
    return "air"
end

function taswc.prosecuteTargetSurface(coalitionId, contactInfo)
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
                        taswc.prosecutorGroups[coalitionId][proesecutorGroupName].target = contactInfo.contactName
                        trigger.action.outTextForCoalition(coalitionId, "Surface group " .. proesecutorGroupName .. " is engaging hostile target track " .. taswc.contactIds[coalitionId][contactInfo.contactName], 30, false)
                    end
                end
            end
        end
    end
end

function taswc.prosecuteTargetAir(coalitionId, contactInfo)
    local targetGroup = Group.getByName(contactInfo.contactName)
    if targetGroup then
        local targetGroupId = targetGroup:getID()
        if targetGroupId then
            local attackPlaneGroupName = mist.cloneGroup(taswc.ashGroupNames[coalitionId], true).name
            timer.scheduleFunction(taswc.assignAttackPlane, {attackGroupName = attackPlaneGroupName, targetId = targetGroupId, coalitionId = coalitionId, contactName = contactInfo.contactName}, timer:getTime() + 180)
            taswc.contacts[coalitionId][contactInfo.contactName].engaged = true
            trigger.action.outTextForCoalition(coalitionId, "Our anti-ship aircraft are engaging hostile target track " .. taswc.contactIds[coalitionId][contactInfo.contactName], 30, false)
        end
    end
end

function taswc.checkProsecutors()
    for c = 1,2 do
        for pGroupName, pGroupInfo in pairs(taswc.prosecutorGroups[c]) do
            local pGroup = Group.getByName(pGroupName)
            if pGroup then
                if pGroupInfo.assigned then
                    if pGroupInfo.target then
                        local targetGroup = Group.getByName(pGroupInfo.target)
                        if not targetGroup then
                            taswc.prosecutorGroups[c][pGroupName].assigned = false
                            taswc.prosecutorGroups[c][pGroupName].target = nil
                        end
                    else
                        taswc.prosecutorGroups[c][pGroupName].assigned = false
                    end
                end
            else
                if pGroupInfo.assigned and pGroupInfo.target then
                    if taswc.contacts[c][pGroupInfo.target] then
                        taswc.contacts[c][pGroupInfo.target].engaged = false
                    end
                end
                taswc.prosecutorGroups[c][pGroupName] = nil
            end
        end
    end
end
-- attackGroupName, targetId
function taswc.assignAttackPlane(param)
    local attackPlaneGroup = Group.getByName(param.attackGroupName)
    if attackPlaneGroup then
        local attackPlaneGroupController = attackPlaneGroup:getController()
        if attackPlaneGroupController then
            local prosecuteTask = {
                id = 'AttackGroup',
                params = {
                    groupId = param.targetId,
                    groupAttack = true,
                }
            }
            attackPlaneGroupController:setTask(prosecuteTask)
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
    local dotId = DrawingTools.newMarkId()
    local chevronId = DrawingTools.newMarkId()
    local lowerI = {x = contactPoint.x - 200, y = 0, z = contactPoint.z}
    local lowerO = {x = contactPoint.x - 240, y = 0, z = contactPoint.z}
    local leftI = {x = contactPoint.x, y = 0, z = contactPoint.z - 200}
    local leftO = {x = contactPoint.x, y = 0, z = contactPoint.z - 240}
    local rightI = {x = contactPoint.x, y = 0, z = contactPoint.z + 200}
    local rightO = {x = contactPoint.x, y = 0, z = contactPoint.z + 240}

    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, chevronId)

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.markupToAll(7, coalitionId, chevronId, leftI, lowerI, rightI, rightO, lowerO, leftO, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
end
function taswc.drawSubsurfaceContact(coalitionId, contactInfo) -- half square
    local contactPoint = contactInfo.point
    local dotId = DrawingTools.newMarkId()
    local bracketId = DrawingTools.newMarkId()

    local topLO = {x = contactPoint.x, y = 0, z = contactPoint.z - 240}
    local topLI = {x = contactPoint.x, y = 0, z = contactPoint.z - 200}
    local centerL = {x = contactPoint.x - 200, y = 0, z = contactPoint.z - 200}
    local centerR = {x = contactPoint.x - 200, y = 0, z = contactPoint.z + 200}
    local topRO = {x = contactPoint.x, y = 0, z = contactPoint.z + 240}
    local topRI = {x = contactPoint.x, y = 0, z = contactPoint.z + 200}
    local bottomR = {x = contactPoint.x - 240, y = 0, z = contactPoint.z + 240}
    local bottomL = {x = contactPoint.x - 240, y = 0, z = contactPoint.z - 240}

    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, bracketId)

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.markupToAll(7, coalitionId, bracketId, topLI, centerL, centerR, topRI, topRO, bottomR, bottomL, topLO, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
end
function taswc.drawSurfaceEnemy(coalitionId, contactInfo) -- diamond
    local contactPoint = contactInfo.point
    local dotId = DrawingTools.newMarkId()
    local diamondId = DrawingTools.newMarkId()
    local lowerI = {x = contactPoint.x - 200, y = 0, z = contactPoint.z}
    local lowerO = {x = contactPoint.x - 240, y = 0, z = contactPoint.z}
    local leftI = {x = contactPoint.x, y = 0, z = contactPoint.z - 200}
    local leftO = {x = contactPoint.x, y = 0, z = contactPoint.z - 240}
    local upperI1 = {x = contactPoint.x + 200, y = 0, z = contactPoint.z+0.1}
    local upperO1 = {x = contactPoint.x + 240, y = 0, z = contactPoint.z+0.1}
    local upperI2 = {x = contactPoint.x + 200, y = 0, z = contactPoint.z-0.1}
    local upperO2 = {x = contactPoint.x + 240, y = 0, z = contactPoint.z-0.1}
    local rightI = {x = contactPoint.x, y = 0, z = contactPoint.z + 200}
    local rightO = {x = contactPoint.x, y = 0, z = contactPoint.z + 240}

    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, diamondId)

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.markupToAll(7, coalitionId, diamondId, upperO1, rightO, lowerO, leftO, upperO2, upperI2, leftI, lowerI, rightI, upperI1, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)

end
function taswc.drawSurfaceContact(coalitionId, contactInfo) -- square
    local contactPoint = contactInfo.point
    local dotId = DrawingTools.newMarkId()
    local squareId = DrawingTools.newMarkId()
    local centerI1 = {x = contactPoint.x + 200, y = 0, z = contactPoint.z+0.1}
    local centerO1 = {x = contactPoint.x + 240, y = 0, z = contactPoint.z+0.1}
    local centerI2 = {x = contactPoint.x + 200, y = 0, z = contactPoint.z-0.1}
    local centerO2 = {x = contactPoint.x + 240, y = 0, z = contactPoint.z-0.1}
    local topRO = {x = contactPoint.x + 240, y = 0, z = contactPoint.z + 240}
    local topRI = {x = contactPoint.x + 200, y = 0, z = contactPoint.z + 200}
    local bottomRO = {x = contactPoint.x - 240, y = 0, z = contactPoint.z + 240}
    local bottomRI = {x = contactPoint.x - 200, y = 0, z = contactPoint.z + 200}
    local bottomLO = {x = contactPoint.x - 240, y = 0, z = contactPoint.z - 240}
    local bottomLI = {x = contactPoint.x - 200, y = 0, z = contactPoint.z - 200}
    local topLO = {x = contactPoint.x + 240, y = 0, z = contactPoint.z - 240}
    local topLI = {x = contactPoint.x + 200, y = 0, z = contactPoint.z - 200}

    table.insert(contactInfo.markups, dotId)
    table.insert(contactInfo.markups, squareId)

    trigger.action.circleToAll(coalitionId, dotId, contactPoint, 50, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
    trigger.action.markupToAll(7, coalitionId, squareId, centerO1, topRO, bottomRO, bottomLO, topLO, centerO2, centerI2, topLI, bottomLI, bottomRI, topRI, centerI1, {0,0,0,1}, taswc.colors[contactInfo.vid], 1, true, nil)
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
            trigger.action.textToAll(c, taswc.markups[c].notice.markId, taswc.markups[c].notice.point, {0,0,0,1}, {0.8235, 0.7059, 0.5490,0.8}, 14, true, "Init")
        end
    end
end
function taswc.mainloop()
    taswc.updateContacts()
    taswc.checkProsecutors()
    timer.scheduleFunction(taswc.mainloop, nil, timer:getTime() + 10)
end
taswc.init()
taswc.mainloop()
TASWC.addProsecutor(2, "killer",  {["surface"] = true})
