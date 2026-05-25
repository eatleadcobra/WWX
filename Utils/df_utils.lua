DF_UTILS={}
DF_UTILS.unitTypes = {
    -- Planes
    ["A-10A"] = "Attack",
    ["A-10C"] = "Attack",
    ["A-10C_2"] = "Attack",
    ["A-20G"] = "Bomber",
    ["A-50"] = "Transport",
    ["A6E"] = "Attack",
    ["AJS37"] = "Strike",
    ["An-26B"] = "Transport",
    ["An-30M"] = "Transport",
    ["AV8BNA"] = "Attack",
    ["B-17G"] = "Bomber",
    ["B-1B"] = "Bomber",
    ["B-52H"] = "Large Bomber",
    ["Bf-109K-4"] = "Single-engine prop",
    ["C-101CC"] = "Attack",
    ["C-101EB"] = "Attack",
    ["C-130"] = "Transport",
    ["C-130J-30"] = "Transport",
    ["C-17A"] = "Transport",
    ["C-47"] = "Transport",
    ["Christen Eagle II"] = "Single-engine prop",
    ["E-2C"] = "Transport",
    ["E-3A"] = "Transport",
    ["F-117A"] = "Strike",
    ["F-14A"] = "Fighter",
    ["F-14A-135-GR"] = "Fighter",
    ["F-14A-135-GR-Early"] = "Fighter",
    ["F-14B"] = "Fighter",
    ["F-15C"] = "Fighter",
    ["F-15E"] = "Strike Fighter",
    ["F-15ESE"] = "Strike Fighter",
    ["F-16A"] = "Fighter",
    ["F-16A MLU"] = "Fighter",
    ["F-16C bl.50"] = "Fighter",
    ["F-16C bl.52d"] = "Fighter",
    ["F-16C_50"] = "Fighter",
    ["F-4E"] = "Fighter",
    ["F-4E-45MC"] = "Fighter",
    ["F-5E"] = "Fighter",
    ["F-5E-3"] = "Fighter",
    ["F-5E-3_FC"] = "Fighter",
    ["F-86F Sabre"] = "Fighter",
    ["F-86F_FC"] = "Fighter",
    ["F4U-1D"] = "Single-engine prop",
    ["F4U-1D_CW"] = "Single-engine prop",
    ["FA-18A"] = "Fighter",
    ["FA-18C"] = "Fighter",
    ["FA-18C_hornet"] = "Fighter",
    ["Falcon_Gyrocopter"] = "Gyro",
    ["FW-190A8"] = "Single-engine prop",
    ["FW-190D9"] = "Single-engine prop",
    ["H-6J"] = "Bomber",
    ["Hawk"] = "Trainer",
    ["I-16"] = "Single-engine prop",
    ["IL-76MD"] = "Transport",
    ["IL-78M"] = "Transport",
    ["J-11A"] = "Fighter",
    ["JF-17"] = "Fighter",
    ["Ju-88A4"] = "Bomber",
    ["KC-135"] = "Tanker",
    ["KC130"] = "Tanker",
    ["KC135MPRS"] = "Tanker",
    ["KJ-2000"] = "Transport",
    ["L-39C"] = "Attack",
    ["L-39ZA"] = "Attack",
    ["La-7"] = "Single-engine prop",
    ["M-2000C"] = "Fighter",
    ["MB-339A"] = "Attack",
    ["MB-339APAN"] = "Attack",
    ["MiG-15bis"] = "Fighter",
    ["MiG-15bis_FC"] = "Fighter",
    ["MiG-19P"] = "Fighter",
    ["MiG-21Bis"] = "Fighter",
    ["MiG-23MLD"] = "Fighter",
    ["MiG-25PD"] = "Interceptor",
    ["MiG-25RBT"] = "Recon",
    ["MiG-27K"] = "Strike",
    ["MiG-29 Fulcrum"] = "Fighter",
    ["MiG-29A"] = "Fighter",
    ["MiG-29G"] = "Fighter",
    ["MiG-29S"] = "Fighter",
    ["MiG-31"] = "Interceptor",
    ["Mirage 2000-5"] = "Fighter",
    ["Mirage-F1AD"] = "Fighter",
    ["Mirage-F1AZ"] = "Fighter",
    ["Mirage-F1B"] = "Fighter",
    ["Mirage-F1BD"] = "Fighter",
    ["Mirage-F1BE"] = "Fighter",
    ["Mirage-F1BQ"] = "Fighter",
    ["Mirage-F1C"] = "Fighter",
    ["Mirage-F1C-200"] = "Fighter",
    ["Mirage-F1CE"] = "Fighter",
    ["Mirage-F1CG"] = "Fighter",
    ["Mirage-F1CH"] = "Fighter",
    ["Mirage-F1CJ"] = "Fighter",
    ["Mirage-F1CK"] = "Fighter",
    ["Mirage-F1CR"] = "Recon",
    ["Mirage-F1CT"] = "Fighter",
    ["Mirage-F1CZ"] = "Fighter",
    ["Mirage-F1DDA"] = "Fighter",
    ["Mirage-F1ED"] = "Fighter",
    ["Mirage-F1EDA"] = "Fighter",
    ["Mirage-F1EE"] = "Fighter",
    ["Mirage-F1EH"] = "Fighter",
    ["Mirage-F1EQ"] = "Fighter",
    ["Mirage-F1JA"] = "Fighter",
    ["Mirage-F1M-CE"] = "Fighter",
    ["Mirage-F1M-EE"] = "Fighter",
    ["MosquitoFBMkVI"] = "Multi-engine prop",
    ["MQ-9 Reaper"] = "Recon",
    ["P-47D-30"] = "Single-engine prop",
    ["P-47D-30bl1"] = "Single-engine prop",
    ["P-47D-40"] = "Single-engine prop",
    ["P-51D"] = "Single-engine prop",
    ["P-51D-30-NA"] = "Single-engine prop",
    ["QF-4E"] = "Fighter",
    ["RQ-1A Predator"] = "Recon",
    ["S-3B"] = "Anti-sub",
    ["S-3B Tanker"] = "Tanker",
    ["SpitfireLFMkIX"] = "Single-engine prop",
    ["SpitfireLFMkIXCW"] = "Single-engine prop",
    ["Su-17M4"] = "Strike",
    ["Su-24M"] = "Strike",
    ["Su-24MR"] = "Recon",
    ["Su-25"] = "Attack",
    ["Su-25T"] = "Attack",
    ["Su-25TM"] = "Attack",
    ["Su-27"] = "Fighter",
    ["Su-30"] = "Strike Fighter",
    ["Su-33"] = "Fighter",
    ["Su-34"] = "Strike",
    ["TF-51D"] = "Single-engine prop",
    ["Tornado GR4"] = "Strike",
    ["Tornado IDS"] = "Strike",
    ["Tu-142"] = "Anti-sub",
    ["Tu-160"] = "Bomber",
    ["Tu-22M3"] = "Bomber",
    ["Tu-95MS"] = "Bomber",
    ["WingLoong-I"] = "Recon",
    ["Yak-40"] = "Transport",
    ["Yak-52"] = "Single-engine prop",
    -- Helicopters
    ["AH-1W"] = "Attack",
    ["AH-64A"] = "Attack",
    ["AH-64D"] = "Attack",
    ["AH-64D_BLK_II"] = "Attack",
    ["CH-47D"] = "Transport",
    ["CH-47Fbl1"] = "Transport",
    ["CH-53E"] = "Transport",
    ["CHAP_TigerUHT"] = "Attack",
    ["Ka-27"] = "Transport",
    ["Ka-50"] = "Attack",
    ["Ka-50_3"] = "Attack",
    ["Mi-24P"] = "Attack",
    ["Mi-24V"] = "Attack",
    ["Mi-26"] = "Transport",
    ["Mi-28N"] = "Attack",
    ["Mi-8MT"] = "Transport",
    ["OH-58D"] = "Recon",
    ["OH58D"] = "Recon",
    ["SA342L"] = "Attack",
    ["SA342M"] = "Attack",
    ["SA342Minigun"] = "Attack",
    ["SA342Mistral"] = "Attack",
    ["SH-3W"] = "Transport",
    ["SH-60B"] = "Transport",
    ["UH-1H"] = "Transport",
    ["UH-60A"] = "Transport",
}
DF_UTILS.avionicsUnits = {
    -- Metric
    ["An-26B"] = "Metric",
    ["An-30M"] = "Metric",
    ["AJS37"] = "Metric",
    ["A-50"] = "Metric",
    ["Bf-109K-4"] = "Metric",
    ["FW-190A8"] = "Metric",
    ["FW-190D9"] = "Metric",
    ["H-6J"] = "Metric",
    ["I-16"] = "Metric",
    ["IL-76MD"] = "Metric",
    ["IL-78M"] = "Metric",
    ["J-11A"] = "Metric",
    ["JF-17"] = "Metric",
    ["Ka-27"] = "Metric",
    ["Ka-50"] = "Metric",
    ["Ka-50_3"] = "Metric",
    ["KJ-2000"] = "Metric",
    ["L-39C"] = "Metric",
    ["L-39ZA"] = "Metric",
    ["La-7"] = "Metric",
    ["MiG-15bis"] = "Metric",
    ["MiG-15bis_FC"] = "Metric",
    ["MiG-19P"] = "Metric",
    ["MiG-21Bis"] = "Metric",
    ["MiG-23MLD"] = "Metric",
    ["MiG-25PD"] = "Metric",
    ["MiG-25RBT"] = "Metric",
    ["MiG-27K"] = "Metric",
    ["MiG-29 Fulcrum"] = "Metric",
    ["MiG-29A"] = "Metric",
    ["MiG-29G"] = "Metric",
    ["MiG-29S"] = "Metric",
    ["MiG-31"] = "Metric",
    ["Mi-24P"] = "Metric",
    ["Mi-24V"] = "Metric",
    ["Mi-26"] = "Metric",
    ["Mi-28N"] = "Metric",
    ["Mi-8MT"] = "Metric",
    ["Su-17M4"] = "Metric",
    ["Su-24M"] = "Metric",
    ["Su-24MR"] = "Metric",
    ["Su-25"] = "Metric",
    ["Su-25T"] = "Metric",
    ["Su-25TM"] = "Metric",
    ["Su-27"] = "Metric",
    ["Su-30"] = "Metric",
    ["Su-33"] = "Metric",
    ["Su-34"] = "Metric",
    ["Tu-142"] = "Metric",
    ["Tu-160"] = "Metric",
    ["Tu-22M3"] = "Metric",
    ["Tu-95MS"] = "Metric",
    ["WingLoong-I"] = "Metric",
    ["Yak-40"] = "Metric",
    ["Yak-52"] = "Metric",
    -- Imperial
    ["A-10A"] = "Imperial",
    ["A-10C"] = "Imperial",
    ["A-10C_2"] = "Imperial",
    ["A-20G"] = "Imperial",
    ["A6E"] = "Imperial",
    ["AH-1W"] = "Imperial",
    ["AH-64A"] = "Imperial",
    ["AH-64D"] = "Imperial",
    ["AH-64D_BLK_II"] = "Imperial",
    ["AV8BNA"] = "Imperial",
    ["B-17G"] = "Imperial",
    ["B-1B"] = "Imperial",
    ["B-52H"] = "Imperial",
    ["C-101CC"] = "Imperial",
    ["C-101EB"] = "Imperial",
    ["C-130"] = "Imperial",
    ["C-130J-30"] = "Imperial",
    ["C-17A"] = "Imperial",
    ["C-47"] = "Imperial",
    ["CH-47D"] = "Imperial",
    ["CH-47Fbl1"] = "Imperial",
    ["CH-53E"] = "Imperial",
    ["CHAP_TigerUHT"] = "Imperial",
    ["Christen Eagle II"] = "Imperial",
    ["E-2C"] = "Imperial",
    ["E-3A"] = "Imperial",
    ["F-117A"] = "Imperial",
    ["F-14A"] = "Imperial",
    ["F-14A-135-GR"] = "Imperial",
    ["F-14A-135-GR-Early"] = "Imperial",
    ["F-14B"] = "Imperial",
    ["F-15C"] = "Imperial",
    ["F-15E"] = "Imperial",
    ["F-15ESE"] = "Imperial",
    ["F-16A"] = "Imperial",
    ["F-16A MLU"] = "Imperial",
    ["F-16C bl.50"] = "Imperial",
    ["F-16C bl.52d"] = "Imperial",
    ["F-16C_50"] = "Imperial",
    ["F-4E"] = "Imperial",
    ["F-4E-45MC"] = "Imperial",
    ["F-5E"] = "Imperial",
    ["F-5E-3"] = "Imperial",
    ["F-5E-3_FC"] = "Imperial",
    ["F-86F Sabre"] = "Imperial",
    ["F-86F_FC"] = "Imperial",
    ["F4U-1D"] = "Imperial",
    ["F4U-1D_CW"] = "Imperial",
    ["FA-18A"] = "Imperial",
    ["FA-18C"] = "Imperial",
    ["FA-18C_hornet"] = "Imperial",
    ["Falcon_Gyrocopter"] = "Imperial",
    ["Hawk"] = "Imperial",
    ["Ju-88A4"] = "Imperial",
    ["KC-135"] = "Imperial",
    ["KC130"] = "Imperial",
    ["KC135MPRS"] = "Imperial",
    ["M-2000C"] = "Imperial",
    ["MB-339A"] = "Imperial",
    ["MB-339APAN"] = "Imperial",
    ["Mirage 2000-5"] = "Imperial",
    ["Mirage-F1AD"] = "Imperial",
    ["Mirage-F1AZ"] = "Imperial",
    ["Mirage-F1B"] = "Imperial",
    ["Mirage-F1BD"] = "Imperial",
    ["Mirage-F1BE"] = "Imperial",
    ["Mirage-F1BQ"] = "Imperial",
    ["Mirage-F1C"] = "Imperial",
    ["Mirage-F1C-200"] = "Imperial",
    ["Mirage-F1CE"] = "Imperial",
    ["Mirage-F1CG"] = "Imperial",
    ["Mirage-F1CH"] = "Imperial",
    ["Mirage-F1CJ"] = "Imperial",
    ["Mirage-F1CK"] = "Imperial",
    ["Mirage-F1CR"] = "Imperial",
    ["Mirage-F1CT"] = "Imperial",
    ["Mirage-F1CZ"] = "Imperial",
    ["Mirage-F1DDA"] = "Imperial",
    ["Mirage-F1ED"] = "Imperial",
    ["Mirage-F1EDA"] = "Imperial",
    ["Mirage-F1EE"] = "Imperial",
    ["Mirage-F1EH"] = "Imperial",
    ["Mirage-F1EQ"] = "Imperial",
    ["Mirage-F1JA"] = "Imperial",
    ["Mirage-F1M-CE"] = "Imperial",
    ["Mirage-F1M-EE"] = "Imperial",
    ["MosquitoFBMkVI"] = "Imperial",
    ["MQ-9 Reaper"] = "Imperial",
    ["OH-58D"] = "Imperial",
    ["OH58D"] = "Imperial",
    ["P-47D-30"] = "Imperial",
    ["P-47D-30bl1"] = "Imperial",
    ["P-47D-40"] = "Imperial",
    ["P-51D"] = "Imperial",
    ["P-51D-30-NA"] = "Imperial",
    ["QF-4E"] = "Imperial",
    ["RQ-1A Predator"] = "Imperial",
    ["S-3B"] = "Imperial",
    ["S-3B Tanker"] = "Imperial",
    ["SA342L"] = "Imperial",
    ["SA342M"] = "Imperial",
    ["SA342Minigun"] = "Imperial",
    ["SA342Mistral"] = "Imperial",
    ["SH-3W"] = "Imperial",
    ["SH-60B"] = "Imperial",
    ["SpitfireLFMkIX"] = "Imperial",
    ["SpitfireLFMkIXCW"] = "Imperial",
    ["Tornado GR4"] = "Imperial",
    ["Tornado IDS"] = "Imperial",
    ["TF-51D"] = "Imperial",
    ["UH-1H"] = "Imperial",
    ["UH-60A"] = "Imperial",
}

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
