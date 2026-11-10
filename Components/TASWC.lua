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

function TASWC.addContact(coalitionId, contactName)
    if not taswc.contactIds[coalitionId][contactName] then
        taswc.contactIds[coalitionId][contactName] = taswc.contactIdCounters[coalitionId]
        taswc.contactIdCounters[coalitionId] = taswc.contactIdCounters[coalitionId] + 1
    end
    taswc.contacts[coalitionId][contactName] = {contactName = contactName, markups = {chevronLeft = 0, chevronRight = 0, dot = 0}, point = nil, heading = 0, speed = 0}
    trigger.action.outText("Added contact: " .. contactName .. " | " .. taswc.contactIds[coalitionId][contactName], 10, false)
end

function taswc.updateContacts()
    for c = 1, 2 do
        taswc.messages[c] = ""
        for contactName, contactInfo in pairs(taswc.contacts[c]) do
            local contactLost = false
            local contactGroup = Group.getByName(contactName)
            if contactGroup then
                trigger.action.outText("updating contact: " .. contactName, 10, false)
                local contactLeadUnit = contactGroup:getUnit(1)
                if contactLeadUnit then
                    local contactPoint = contactLeadUnit:getPoint()
                    local contactPosition = contactLeadUnit:getPosition()
                    local contactVelocity = contactLeadUnit:getVelocity()
                    if contactPoint and contactPosition then
                        trigger.action.removeMark(contactInfo.markups.chevronLeft)
                        trigger.action.removeMark(contactInfo.markups.chevronRight)
                        trigger.action.removeMark(contactInfo.markups.dot)
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
                        taswc.drawContact(c, contactName)
                    end
                else
                    contactLost = true
                end
            else
                contactLost = true
            end
            if contactLost then
                taswc.contacts[c][contactName] = nil
            end
        end
        taswc.updateNotice(c)
    end
end

function taswc.drawContact(coalitionId, contactName)
    trigger.action.outText("Drawing contact " .. contactName, 10, false)
    local contactInfo = taswc.contacts[coalitionId][contactName]
    if contactInfo then
        local contactPoint = contactInfo.point
        if contactPoint then
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

            contactInfo.markups.dot = dotId
            contactInfo.markups.chevronLeft = chevronLeftId
            contactInfo.markups.chevronRight = chevronRightId

            trigger.action.circleToAll(-1, dotId, contactPoint, 40, {0,0,0,1}, {1,0,0,1}, 1, true, nil)
            trigger.action.quadToAll(-1, chevronLeftId, chevronStartPoint, chevronLeftBox1, chevronLeftBox2, chevronLeftBox3, {0,0,0,1}, {1,0,0,1}, 1, true, nil)
            trigger.action.quadToAll(-1, chevronRightId, chevronRightBox1, chevronStartPoint, chevronRightBox2, chevronRightBox3, {0,0,0,1}, {1,0,0,1}, 1, true, nil)
        end
    end
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
TASWC.addContact(2, "testsub")
taswc.mainloop()