RandomNames = {}
RandomNames.used = {}
RandomNames.firstNames = {}
RandomNames.lastNames = {}
function RandomNames.randomFirstName(side, country)
	return RandomNames.firstNames[side][country][math.random(#RandomNames.firstNames[side][country])]
end
function RandomNames.randomLastName(side, country)
	return RandomNames.lastNames[side][country][math.random(#RandomNames.lastNames[side][country])]
end
function RandomNames.getNewName(side)
	local name
	local country
	country = math.random(#RandomNames.firstNames[side])
	repeat
		name = RandomNames.randomFirstName(side, country) .. " " .. RandomNames.randomLastName(side, country)
	until not RandomNames.used[name]
	RandomNames.used[name] = true
	return name
end