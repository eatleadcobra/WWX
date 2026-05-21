DF_UTILS={}
function DF_UTILS.spawnGroup(groupName, spawnPoint, action)
    local vars = {}
        vars.gpName = groupName
        vars.action = action
        vars.point = spawnPoint
        vars.radius = 200
        vars.anyTerrain = true
        return mist.teleportToPoint(vars).name
end
function DF_UTILS.spawnGroupExact(groupName, spawnPoint, action, radius, anywhere, safeZones, fName)
    local vars = {}
    vars.gpName = groupName
    if fName and fName ~= "" then
        vars.newGroupName = fName
    end
    vars.action = action
    vars.point = spawnPoint
    vars.radius = radius or 1
    if anywhere ~= false then
        anywhere = true
    else
        vars.validTerrain = safeZones
    end
    vars.anyTerrain = anywhere
    local newGroup = mist.teleportToPoint(vars)
    if type(newGroup) == 'table' and newGroup.name then
        return newGroup.name
    else
        env.info("DF_UTILS.spawnGroupExact.newGroup = " .. DF_UTILS.dump(newGroup),false)
        return nil
    end
end
function DF_UTILS.spawnGroupWide(groupName, spawnPoint, action, radius, anywhere, safeZones, fName)
    local vars = {}
    vars.gpName = groupName
    if fName and fName ~= "" then
        vars.newGroupName = fName
    end
    vars.action = action
    vars.point = spawnPoint
    vars.radius = radius
    vars.offsetWP1 = true
    vars.anyTerrain = anywhere
    if (not anywhere) and safeZones then
        vars.validTerrain = safeZones
    end
    local newGroup = mist.teleportToPoint(vars)
    if type(newGroup) == 'table' and newGroup.name then
        return newGroup.name
    else
        env.info("DF_UTILS.spawnGroupWide.newGroup = " .. DF_UTILS.dump(newGroup),false)
        return nil
    end
end
function DF_UTILS.fileExists(file)
    local f = io.open(file, 'rb')
    if f then f:close() end
    return f ~= nil
end
function DF_UTILS.dump(o)
    if type(o) == 'table' then
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
--param.from, param.to
function DF_UTILS.vector(param)
	local braaData = DF_UTILS.calculateBRAA(param)
	if braaData then
		local bearingInDeg = braaData.bearingInDeg
		local distanceToTargetStringM = braaData.distanceToTargetStringM
		local altStringM = braaData.altStringM
		local aspectString = braaData.aspectString
		local distanceToTargetStringI = braaData.distanceToTargetStringI
		local altStringI = braaData.altStringI
		local playerGroup = braaData.playerGroup
		local targetGroup = braaData.targetGroup

		local braString = "BRAA: " .. string.format("%.0f", bearingInDeg) .. "° for " .. distanceToTargetStringM .. "km | " .. altStringM .. " " .. aspectString
		braString = braString .. "\n                      " .. distanceToTargetStringI .. "nmi |" .. altStringI
		if param.targetCallsign then
			braString = param.targetCallsign.."\n"..braString
		end
		trigger.action.outTextForGroup(playerGroup:getID(), braString, 5, false)
	end
end
--param.from, param.to
function DF_UTILS.calculateBRAA(param)
    local targetGroup = Group.getByName(param.to)
	local playerGroup = Group.getByName(param.from)

	if targetGroup ~= nil and playerGroup ~= nil then
		local targetUnit = targetGroup:getUnit(1)
		local playerUnit = playerGroup:getUnit(1)
		if targetUnit and playerUnit then
			local targetPos = targetUnit:getPoint()
			local playerPos = playerUnit:getPoint()
			if targetPos and playerPos then
				local vector = {x = targetPos.x - playerPos.x, y = targetPos.y - playerPos.y, z = targetPos.z - playerPos.z}
				---@diagnostic disable-next-line: deprecated
				local bearing = math.atan2(vector.z, vector.x)
				if bearing < 0 then bearing = bearing + (2 * math.pi) end
				local bearingInDeg = bearing * (180/math.pi)
				local reverseBearingInDeg = bearingInDeg + 180
				if reverseBearingInDeg > 360 then reverseBearingInDeg = reverseBearingInDeg - 360 end
				--trigger.action.outText("Bearing from Tgt to Interceptor: " .. reverseBearingInDeg, 1)
				local targetPosition = targetGroup:getUnit(1):getPosition()
				---@diagnostic disable-next-line: deprecated
				local targetHeadingRad = math.atan2(targetPosition.x.z, targetPosition.x.x)
				if targetHeadingRad < 0 then targetHeadingRad = targetHeadingRad + (2 * math.pi) end
				local targetHeadingDeg = targetHeadingRad * (180/math.pi)
				--trigger.action.outText("Target Heading: " .. targetHeadingDeg, 1)
				local aspectDegrees = math.abs(reverseBearingInDeg - targetHeadingDeg)
				if aspectDegrees > 180 then aspectDegrees = 360 - aspectDegrees end
				--trigger.action.outText("Degrees off: " .. aspectDegrees, 1)
				local targetHeadingCardinal = "North"
				if targetHeadingDeg >= 22.5 and targetHeadingDeg < 67.5 then
					targetHeadingCardinal = "Northeast"
				elseif targetHeadingDeg >= 67.5 and targetHeadingDeg < 112.5 then
					targetHeadingCardinal = "East"
				elseif targetHeadingDeg >= 112.5 and targetHeadingDeg < 157.5 then
					targetHeadingCardinal = "Southeast"
				elseif targetHeadingDeg >= 157.5 and targetHeadingDeg < 202.5 then
					targetHeadingCardinal = "South"
				elseif targetHeadingDeg >= 202.5 and targetHeadingDeg < 247.5 then
					targetHeadingCardinal = "Southwest"
				elseif targetHeadingDeg >= 247.5 and targetHeadingDeg < 292.5 then
					targetHeadingCardinal = "West"
				elseif targetHeadingDeg >= 292.5 and targetHeadingDeg < 337.5 then
					targetHeadingCardinal = "Northwest"
				end
				local aspectString = ""
				if aspectDegrees < 30 then
					aspectString = "Hot"
				elseif aspectDegrees < 75 then
					aspectString = "Flanking " .. targetHeadingCardinal
				elseif aspectDegrees < 110 then
					aspectString = "Beam " .. targetHeadingCardinal
				else
					aspectString = "Drag " .. targetHeadingCardinal
				end
				local xDistance = playerPos.x - targetPos.x
				local yDistance = playerPos.z - targetPos.z
				local distanceToTarget = tonumber(math.sqrt(xDistance*xDistance + yDistance*yDistance))
				local distanceToTargetNM = tonumber(string.format("%.0f", distanceToTarget * 0.000539957))
				local distanceToTargetStringM = string.format("%.0f",distanceToTarget/1000)

				local targetAltInFt = targetPos.y * 3.28084
				local targetAltAngels = math.floor(targetAltInFt/1000)
				local altStringM = string.format("%.0f", math.floor(targetPos.y/100)*100) .. 'm'
				local altStringI = " Angels " .. string.format("%.0f", targetAltAngels)
				local distanceToTargetStringI = string.format("%.0f",distanceToTargetNM)
				return {
					bearingInDeg = bearingInDeg,
					distanceToTargetStringM = distanceToTargetStringM,
					altStringM = altStringM,
					aspectString = aspectString,
					distanceToTargetStringI = distanceToTargetStringI,
					altStringI = altStringI,
					playerGroup = playerGroup,
					targetGroup = targetGroup
				}
			end
		end
	end
end
function DF_UTILS.randomThanks(param)
	local playerName = param.playerName
	local thanksMessages = {
		"Thank you " .. playerName .. " for your passion and support!",
		"Thank you " .. playerName .. ", this delivery will save us many man hours!",
		"Cracking open those crates took some leverage...",
		"Delivery complete; sustainment operations continue.",
		"Cargo secured; the war continues one crate at a time",
		"Logistics win wars",
	}
	local randomIndex = math.random(1, #thanksMessages)
	-- Override with extremely rare messages, I think these will get pretty dry if they're too common.
	local randomVal = math.random(1000)
	if randomVal == 1 then
		return "Based CargoPilledLogisticsmaxxer"
	end
	local selectedMessage = thanksMessages[randomIndex]
	return selectedMessage
end

DF_UTILS.avionicsUnits = {
    -- Metric avionics
    ["An-26B"] = "Metric",
    ["An-30M"] = "Metric",
    ["il-76md"] = "Metric",
    ["il-78m"] = "Metric",
    ["Bf-109K-4"] = "Metric",
    ["FW-190A8"] = "Metric",
    ["FW-190D9"] = "Metric",    
    ["MiG-15Bis"] = "Metric",
    ["MiG-19P"] = "Metric",
    ["MiG-21Bis"] = "Metric",
    ["MiG-29 Fulcrum"] = "Metric",
    ["AJS37"] = "Metric",
    ["JF-17"] = "Metric",
    ["Su-25"] = "Metric",
    ["Su-25T"] = "Metric",
    ["Yak-52"] = "Metric",
    ["I-16"] = "Metric",
    ["L-39C"] = "Metric",
    ["L-39ZA"] = "Metric",
    ["Tu-22M3"] = "Metric",
    ["Su-24M"] = "Metric",
    -- Imperial avionics
    ["c-17A"] = "Imperial",
    ["C-130J-30"] = "Imperial",
    ["MB-339A"] = "Imperial",
    ["M-2000C"] = "Imperial", 
    ["Mirage-F1CE"] = "Imperial",
    ["Mirage-F1BE"] = "Imperial",
    ["Mirage-F1EE"] = "Imperial",
    ["A-10A"] = "Imperial",
    ["A-10C"] = "Imperial",
    ["A-10C_2"] = "Imperial",
    ["AV8BNA"] = "Imperial",
    ["C-101CC"] = "Imperial",
    ["C-101EB"] = "Imperial",
    ["F-4E-45MC"] = "Imperial",
    ["F-5E-3"] = "Imperial",
    ["F-5E-3_FC"] = "Imperial",
    ["F-15ESE"] = "Imperial",
    ["F-15C"] = "Imperial",
    ["F-16C_50"] = "Imperial",
    ["FA-18C_hornet"] = "Imperial",
    ["F4U-1D"] = "Imperial",
    ["P-47D-30bl1"] = "Imperial",
    ["P-47D-30"] = "Imperial",
    ["P-47D-40"] = "Imperial",
    ["P-51D"] = "Imperial",
    ["P-51D-30-NA"] = "Imperial",
    ["MosquitoFBMkVI"] = "Imperial",
    ["F-86F Sabre"] = "Imperial",
    ["F-86F_FC"] = "Imperial",
    ["F-14A-135-GR-Early"] = "Imperial",
    ["F-14A-135-GR"] = "Imperial",
    ["F-14B"] = "Imperial",
    ["B-1B"] = "Imperial",
    ["b-52H"] = "Imperial",
    ["Tornado IDS"] = "Imperial",
    ["Tornado GR4"] = "Imperial",
    ["A-20G"] = "Imperial",
    ["A6E"] = "Imperial",
    ["SpitfireLFMkIX"] = "Imperial",
    ["SpitfireLFMkIXCW"] = "Imperial",
}