Utils = {}
function Utils.MakeVec3(vec, y)
    if not vec.z then
        if vec.alt and not y then
            y = vec.alt
        elseif not y then
            y = 0
        end
        return {x = vec.x, y = y, z = vec.y}
    else
        return {x = vec.x, y = vec.y, z = vec.z}
    end
end
function Utils.VecNormalize(vec3)
    local mag =  Utils.VectorMagnitude(vec3)
    if mag ~= 0 then
        return Utils.ScalarMult(vec3, 1.0 / mag)
    end
end
function Utils.VectorMagnitude(vec)
    return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end
function Utils.getSpeed(velocity)
    return (velocity.x^2 + velocity.y^2 + velocity.z^2)^0.5
end
function Utils.getMidpoint(point1, point2)
    point1 = Utils.MakeVec3(point1)
    point2 = Utils.MakeVec3(point2)
    return {x = (point1.x+point2.x)/2, y = point1.y, z = (point1.z+point2.z)/2}
end
function Utils.PointDistance(point1, point2)
    point1 = Utils.MakeVec3(point1)
    point2 = Utils.MakeVec3(point2)
    return Utils.VectorMagnitude({x = point1.x - point2.x, y = 0, z = point1.z - point2.z})
end
function Utils.ScalarMult(vec, mult)
    return {x = vec.x*mult, y = vec.y*mult, z = vec.z*mult}
end
function Utils.VectorAdd(vec1, vec2)
    return {x = vec1.x + vec2.x, y = vec1.y + vec2.y, z = vec1.z + vec2.z}
end
function Utils.VectorSub(vec1, vec2)
    return {x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z}
end
function Utils.RotateVector(vector, radians)
    local newVector = {}
    newVector.x = vector.x*math.cos(radians) - vector.z*math.sin(radians)
    newVector.z = vector.x*math.sin(radians) + vector.z*math.cos(radians)
    newVector.y = vector.y
    return newVector
end
function Utils.GetBearingDeg(fromPoint, toPoint)
    local vector = {x = toPoint.x - fromPoint.x, y = toPoint.y - fromPoint.y, z = toPoint.z - fromPoint.z}
    ---@diagnostic disable-next-line: deprecated
    local bearing = math.atan2(vector.z, vector.x)
    if bearing < 0 then bearing = bearing + (2 * math.pi) end
    local bearingInDeg = bearing * (180/math.pi)
    return bearingInDeg
end
function Utils.GetBearingRad(fromPoint, toPoint)
    local vector = {x = toPoint.x - fromPoint.x, y = toPoint.y - fromPoint.y, z = toPoint.z - fromPoint.z}
    ---@diagnostic disable-next-line: deprecated
    local bearing = math.atan2(vector.z, vector.x)
    if bearing < 0 then bearing = bearing + (2 * math.pi) end
    return bearing
end
function Utils.MidPoint(point1, point2)
    return
end
function Utils.getAGL(point)
    local alt = point.y
    local land = land.getHeight({x = point.x, y = point.z}) or 0
    if land < 0 then land = 0 end
    alt = alt - land
    return alt
end
function Utils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.deepcopy(orig_key)] = Utils.deepcopy(orig_value)
        end
        setmetatable(copy, Utils.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function Utils.saveToString(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. Utils.saveToString(v) .. ','
       end
       return s .. '} '
    elseif type(o) == "string" then
       return "\""..tostring(o).."\"\n"
    else
        return tostring(o)
    end
end
function Utils.dump(o)
    if o == nil then
        return "~nil~"
    elseif type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. Utils.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
function Utils.uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v) end)
end
function Utils.relativeClockBearing(p1,p2,hdg)
    local xdiff = p2.x - p1.x
    local zdiff = p2.z - p1.z
    local bearing = math.atan2(zdiff,xdiff)
    bearing = math.floor(bearing / math.pi * 180)
    bearing = bearing - hdg
    local clockBearing = math.fmod(bearing, 360)
    if clockBearing < 0 then clockBearing = clockBearing + 360 end
    if clockBearing < 15 then
        return 12
    end
    clockBearing = clockBearing + 15
    return math.floor(clockBearing/30)
end
function Utils.relativeCompassBearing(p1,p2)
    -- you are standing at p2 looking towards p1
    local xdiff = p1.x - p2.x
    local zdiff = p1.z - p2.z
    local bearing = math.atan2(zdiff, xdiff)
    bearing = math.floor(bearing / math.pi * 180)
    if bearing > 360 then bearing = bearing - 360 end
    if bearing < 0 then bearing = bearing + 360 end
    if bearing < 23 then return "North" end
    if bearing < 68 then return "NE" end
    if bearing < 112 then return "East" end
    if bearing < 158 then return "SE" end
    if bearing < 202 then return "South" end
    if bearing < 248 then return "SW" end
    if bearing < 292 then return "West" end
    if bearing < 338 then return "NW" end
    return "North"
end
function Utils.getDegBearingFromPosition(position)
    ---@diagnostic disable-next-line: deprecated
    local headingRad = math.atan2(position.x.z, position.x.x)
    if headingRad < 0 then headingRad = headingRad + (2 * math.pi) end
    local headingDeg = headingRad * (180/math.pi)
    return headingDeg
end
function Utils.degToCompass(bearing)
    if bearing > 360 then bearing = bearing - 360 end
    if bearing < 0 then bearing = bearing + 360 end
    if bearing < 23 then return "North" end
    if bearing < 68 then return "NE" end
    if bearing < 112 then return "East" end
    if bearing < 158 then return "SE" end
    if bearing < 202 then return "South" end
    if bearing < 248 then return "SW" end
    if bearing < 292 then return "West" end
    if bearing < 338 then return "NW" end
    return "North"
end
function Utils.pointInCircleTriggerZone(pp,zp)
    local pZeroAlt = {x = pp.x, y = 0, z = pp.z}
    local zZeroAlt = {x = zp.point.x, y = 0, z = zp.point.z}
    local dist = Utils.PointDistance(zZeroAlt,pZeroAlt)
    if dist < zp.radius then
        return true
    end
    return false
end
function Utils.getHdgFromPosition(pos)
    if not pos then return 0 end
    local hdg = math.atan2(pos.x.z, pos.x.x)
    if hdg < 0 then
        hdg = hdg + 2 * math.pi
    end
    return hdg * (180/math.pi)
end
function Utils.getGroupPoint(groupName)
    local returnPoint = nil
    local group = Group.getByName(groupName)
    if group then
        local unit = group:getUnit(1)
        if unit then
            local point = unit:getPoint()
            if point then returnPoint = point end
        end
    end
    return returnPoint
end