local viggenDTC = {}
function viggenDTC:onEvent(event)
    -- on mark change
    if (event.id == 26) then
        if event.text ~= nil and string.len(event.text) == 2 then
            local firstChr = string.sub(event.text,1,1)
            local secondChr = string.sub(event.text,2,2)
            local firstMatch = false
            local secondMatch = false
            if string.find(firstChr, "[LBMUlbmu]") then
                firstMatch = true
            end
            if string.find(secondChr, "[Ss%d]") then
                secondMatch = true
            end
            if firstMatch and secondMatch then
                trigger.action.removeMark(event.idx)
				if event.initiator ~= nil then
					local playerId = event.initiator:getID()
					if playerId then
						trigger.action.outTextForUnit(playerId, "Viggen DTC operations are not supported on this server.\nThe ability to use a DTC was added to the Viggen with the AJS upgrade in 1991.", 15)
					end
				end
            end
        end
    end
end
world.addEventHandler(viggenDTC)