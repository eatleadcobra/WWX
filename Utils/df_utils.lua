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
function DF_UTILS.spawnGroupExact(groupName, spawnPoint, action)
    local vars = {}
        vars.gpName = groupName
        vars.action = action
        vars.point = spawnPoint
        vars.radius = 5
		vars.anyTerrain = true
        return mist.teleportToPoint(vars).name
end
function DF_UTILS.spawnGroupWide(groupName, spawnPoint, action, radius, anywhere, safeZones, fName)
    local vars = {}
        vars.gpName = groupName
		if fName ~= "" then
			vars.name = fName
		end
        vars.action = action
        vars.point = spawnPoint
        vars.radius = radius
        vars.anyTerrain = anywhere
        if (not anywhere) and safeZones then
			vars.validTerrain = safeZones
		end
        return mist.teleportToPoint(vars).name
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
    local targetGroup = Group.getByName(param.to)
	local playerGroup = Group.getByName(param.from)

	if targetGroup ~= nil and playerGroup ~= nil then
        local targetPos = targetGroup:getUnit(1):getPoint()
        local playerPos = playerGroup:getUnit(1):getPoint()

		local vector = {x = targetPos.x - playerPos.x, y = targetPos.y - playerPos.y, z = targetPos.z - playerPos.z}
		---@diagnostic disable-next-line: deprecated
		local bearing = math.atan2(vector.z, vector.x)
		if bearing < 0 then bearing = bearing + (2 * math.pi) end
		local bearingInDeg = bearing * (180/math.pi)
        env.info(tostring(bearingInDeg))
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
        local distanceToTargetString = string.format("%.0f",distanceToTarget/1000)

		local targetAltInFt = targetPos.y * 3.28084
		local targetAltAngels = math.floor(targetAltInFt/1000)
        local altString = string.format("%.0f", targetPos.y) .. 'm'
        if param.units == 2 then
            altString = " Angels " .. string.format("%.0f", targetAltAngels)
            distanceToTargetString = string.format("%.0f",distanceToTargetNM)
        end

		local braString = "BRAA: " .. string.format("%.0f", bearingInDeg) .. "° for " .. distanceToTargetString .. altString .. " " .. aspectString
		trigger.action.outTextForGroup(playerGroup:getID(), braString, 5)
	end
end