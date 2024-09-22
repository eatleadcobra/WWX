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
        return string.format('%x', v)
    end)
end