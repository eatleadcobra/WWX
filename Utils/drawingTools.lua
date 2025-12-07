DrawingTools = {}
local newMarkId = 100
function DrawingTools.newMarkId()
    local returnId = newMarkId
    newMarkId = newMarkId + 1
    return returnId
end
local package = {
    [1] = {
        size = 200
    },
    [2] = {
        size = 300
    },
    [3] = {
        size = 2500
    }
}
local ammo = {
    width = 400,
    height = 600,
}
local fuel = {
    height = 1000,
    width = 800,
}
local health = {
    height = 500,
    width = 4000,
}
local xMark = {
    size = 12
}
local triangleMark = {
    size = 12
}
function DrawingTools.drawPackage(origin, size, pickup, coalition, noArrow)
    if coalition == nil then coalition = -1 end
    local leftQuad = DrawingTools.newMarkId()
    local centerPoint = {x = origin.x, y = origin.y, z = origin.z}
    --trigger.action.markToAll(leftQuad+1, "centerPoint", centerPoint, false, nil)
    local lul = {x = centerPoint.x + package[size].size/8 , y = centerPoint.y, z = centerPoint.z - package[size].size/4}
    --trigger.action.markToAll(leftQuad+2, "left up-left", lul, false, nil)
    local lbr = {x = centerPoint.x - package[size].size/3, y = centerPoint.y, z = centerPoint.z}
    --trigger.action.markToAll(leftQuad+3, "left bottom-right", lbr, false, nil)
    local lbl = {x = centerPoint.x - package[size].size/3 + package[size].size/8, y = centerPoint.y, z = centerPoint.z - package[size].size/4}
    --trigger.action.markToAll(leftQuad+4, "left bottom-left", lbl, false, nil)
    trigger.action.quadToAll(coalition, leftQuad, lbr, lbl, lul, centerPoint, {0,0,0,1}, {1,1,1,1}, 1, true)
    local rightQuad = DrawingTools.newMarkId()
    local rul = centerPoint
    local rur = {x = centerPoint.x + package[size].size/8 , y = centerPoint.y, z = centerPoint.z + package[size].size/4}
    local rbl = lbr
    local rbr = {x = centerPoint.x - package[size].size/3 + package[size].size/8, y = centerPoint.y, z = centerPoint.z + package[size].size/4}
    trigger.action.quadToAll(coalition, rightQuad, rbr, rbl, rul, rur, {0,0,0,1}, {1,1,1,1}, 1, true)
    local topQuad = DrawingTools.newMarkId()
    local tb = centerPoint
    local tl = lul
    local tr = rur
    local tt = {x = centerPoint.x + package[size].size/4.5, y = centerPoint.y, z = centerPoint.z }
    trigger.action.quadToAll(coalition, topQuad, tb, tl, tt, tr, {0,0,0,1}, {1,1,1,1}, 1, true)
    local arrowId = DrawingTools.newMarkId()
    local bottomArrowPoint = {x = centerPoint.x, y = centerPoint.y, z = centerPoint.z}
    local upperArrowPoint = {x = centerPoint.x + package[size].size/5, y = centerPoint.y, z = centerPoint.z}
    if pickup and noArrow == nil then
        local b1 = {x = bottomArrowPoint.x, y = bottomArrowPoint.y, z = bottomArrowPoint.z - package[size].size/12}
        local b2 = {x = bottomArrowPoint.x, y = bottomArrowPoint.y, z = bottomArrowPoint.z + package[size].size/12}
        local b3 = {x = upperArrowPoint.x, y = upperArrowPoint.y, z = upperArrowPoint.z - package[size].size/12}
        local b4 = {x = upperArrowPoint.x, y = upperArrowPoint.y, z = upperArrowPoint.z + package[size].size/12}
        local u1 = {x = upperArrowPoint.x, y = upperArrowPoint.y, z = upperArrowPoint.z - package[size].size/6}
        local u2 = {x = upperArrowPoint.x, y = upperArrowPoint.y, z = upperArrowPoint.z + package[size].size/6}
        local tip = {x = upperArrowPoint.x + package[size].size/8, y = upperArrowPoint.y, z = upperArrowPoint.z}
        trigger.action.markupToAll(7, coalition, arrowId,b4, b2, b1,b3, u1, tip, u2, {0,0,0,1}, {0,0,0,1}, 1, true)
    elseif noArrow == nil then
        bottomArrowPoint.x = bottomArrowPoint.x + package[size].size/8
        upperArrowPoint.x = upperArrowPoint.x + package[size].size/8
        local b1 = {x = upperArrowPoint.x, y = upperArrowPoint.y, z = upperArrowPoint.z - package[size].size/12}
        local b2 = {x = upperArrowPoint.x, y = upperArrowPoint.y, z = upperArrowPoint.z + package[size].size/12}
        local b3 = {x = bottomArrowPoint.x, y = bottomArrowPoint.y, z = bottomArrowPoint.z - package[size].size/12}
        local b4 = {x = bottomArrowPoint.x, y = bottomArrowPoint.y, z = bottomArrowPoint.z + package[size].size/12}
        local u1 = {x = bottomArrowPoint.x, y = bottomArrowPoint.y, z = bottomArrowPoint.z - package[size].size/6}
        local u2 = {x = bottomArrowPoint.x, y = bottomArrowPoint.y, z = bottomArrowPoint.z + package[size].size/6}
        local tip = {x = bottomArrowPoint.x - package[size].size/8, y = bottomArrowPoint.y, z = bottomArrowPoint.z}
        trigger.action.markupToAll(7, coalition, arrowId, b4, b2, b1, b3, u1, tip, u2,{0,0,0,1}, {0,0,0,1}, 1, true)
    end
end
function DrawingTools.drawAmmo(origin, coalitionId, small)
    local drawingWidth = ammo.width
    local drawingHeight = ammo.height
    if small then
        drawingWidth = ammo.width/2
        drawingHeight = ammo.height/2
    end
    origin.x = origin.x + drawingWidth/2
    origin.z = origin.z - drawingWidth - drawingWidth/4
    local rectTop = {x = origin.x + drawingWidth/2 + drawingWidth/4, y = origin.y, z = origin.z - drawingWidth/2 - drawingWidth/4}
    local rectBottom = { x = origin.x - drawingWidth/2 - drawingHeight - drawingWidth/4, y = origin.y, z = origin.z + 3*(drawingWidth) + drawingWidth/4}
    local ammoId = DrawingTools.newMarkId()
    trigger.action.rectToAll(coalitionId, ammoId, rectTop, rectBottom, {0,0,0,1}, {0,0,0,0.9}, 1, true, nil)
    for i = 1, 3 do
        local locOrg = {x = origin.x, y = origin.y, z = origin.z + ((i-1)*(drawingWidth + drawingWidth/4))}
        local boxTop = {x = locOrg.x, y = locOrg.y, z = locOrg.z - drawingWidth/2 }
        local boxBottom = { x = locOrg.x - drawingWidth/2 - drawingHeight, y = locOrg.y, z = locOrg.z + drawingWidth/2}
        local bulletRecId = DrawingTools.newMarkId()
        local bulletCircleId = DrawingTools.newMarkId()
        local bulletLineId = DrawingTools.newMarkId()
        trigger.action.rectToAll(coalitionId, bulletRecId, boxBottom, boxTop, {1,1,1,1}, {1,1,1,1}, 1, true, nil)
        trigger.action.circleToAll(coalitionId, bulletCircleId, locOrg, drawingWidth/2, {1,1,1,0}, {1,1,1,1}, 1, true, nil)
        trigger.action.lineToAll(coalitionId, bulletLineId, {x = boxBottom.x + drawingHeight/5, y = boxBottom.y, z = boxBottom.z }, {x = boxBottom.x + drawingHeight/5, y = boxBottom.y, z = boxBottom.z - drawingWidth}, {0,0,0,1}, 1, true, nil)
    end
end
function DrawingTools.drawFuel(origin, coalitionId, small)
    local fuelWidth = fuel.width
    local fuelHeight = fuel.height
    if small then
        fuelWidth = fuel.width/2
        fuelHeight = fuel.height/2
    end
    local canOrigin = {x = origin.x + fuelHeight/2.5 , y = origin.y, z = origin.z - fuelWidth/4}
    local p1 = {x = canOrigin.x, y = canOrigin.y, z = canOrigin.z}
    local p2 = {x = p1.x, y = p1.y, z = p1.z + (2*fuelWidth)/3}
    local p3 = {x = p2.x - fuelHeight, y = p2.y, z = p2.z}
    local p4 = {x = p3.x, y = p3.y, z = p3.z - fuelWidth}
    local p5 = {x = p4.x + (4*fuelHeight)/5, y = p4.y, z = p4.z}
    local handleTop = {x = p1.x - fuelHeight/12, y = p1.y, z = p1.z + fuelWidth/6 }
    local handleBottom = {x = p1.x - (1.5*fuelHeight/10), y = p2.y, z = p2.z - fuelWidth/10}
    local borderTop =  {x = p1.x + fuelHeight/12, y = p1.y, z = p1.z - fuelWidth/3 - fuelWidth/6}
    local borderBottom = {x = p3.x - fuelHeight/12, y = p3.y, z = p3.z + fuelWidth/6}
    local gasBorderId = DrawingTools.newMarkId()
    local gasOutlineId = DrawingTools.newMarkId()
    trigger.action.rectToAll(coalitionId, gasBorderId, borderTop, borderBottom, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
    trigger.action.markupToAll(7, coalitionId, gasOutlineId, p1, p2, p3, p4, p5, {1,1,1,1}, {1,1,1,1}, 1, true)
    local innerRecTopLeft = {x = p1.x - fuelHeight/2.5, y = p1.y, z = p1.z }
    local innerRecLineTopLeft = {x = innerRecTopLeft.x + fuelHeight/6, y = innerRecTopLeft.y, z = innerRecTopLeft.z - fuelHeight/6}
    local innerRecTopRight = {x = innerRecTopLeft.x, y = innerRecTopLeft.y, z = innerRecTopLeft.z + fuelWidth/3}
    local innerRecLineTopRight = {x = innerRecTopRight.x + fuelHeight/6, y = innerRecTopRight.y, z = innerRecTopRight.z + fuelHeight/6}
    local innerRecBottomRight = {x = innerRecTopRight.x - fuelHeight/3, y = innerRecTopRight.y, z = innerRecTopRight.z}
    local innerRecLineBottomRight = {x = innerRecBottomRight.x - fuelHeight/6, y = innerRecBottomRight.y, z = innerRecBottomRight.z + fuelHeight/6}
    local innerRecBottomLeft = {x = innerRecBottomRight.x, y = innerRecBottomRight.y, z = innerRecTopLeft.z}
    local innerRecLineBottomLeft = {x = innerRecBottomLeft.x - fuelHeight/6, y = innerRecBottomLeft.y, z = innerRecBottomLeft.z - fuelHeight/6}
    local nub1 = {x = p5.x + fuelHeight/15, y = p5.y, z = p5.z + fuelHeight/11}
    local nub2 = {x = nub1.x + fuelHeight/15, y = nub1.y, z = nub1.z + fuelHeight/11}
    local nub3 = {x = nub2.x + fuelHeight/22, y = nub2.y, z = nub2.z - fuelHeight/28}
    local nub4 = {x = nub1.x + fuelHeight/22, y = nub2.y, z = nub1.z - fuelHeight/28}
    local nubId = DrawingTools.newMarkId()
    local innerRecQuadId = DrawingTools.newMarkId()
    local line1Id = DrawingTools.newMarkId()
    local line2Id = DrawingTools.newMarkId()
    local line3Id = DrawingTools.newMarkId()
    local line4Id = DrawingTools.newMarkId()
    trigger.action.quadToAll(coalitionId, nubId, nub3, nub2, nub1, nub4, {1,1,1,1}, {1,1,1,1}, 1, true, nil)
    trigger.action.quadToAll(coalitionId, innerRecQuadId, innerRecTopLeft, innerRecTopRight, innerRecBottomRight, innerRecBottomLeft, {0,0,0,1}, {0,0,0,0}, 1, true, nil)
    trigger.action.lineToAll(coalitionId, line1Id, innerRecTopLeft, innerRecLineTopLeft, {0,0,0,1}, 1, true)
    trigger.action.lineToAll(coalitionId, line2Id, innerRecTopRight, innerRecLineTopRight, {0,0,0,1}, 1, true)
    trigger.action.lineToAll(coalitionId, line3Id, innerRecBottomRight, innerRecLineBottomRight, {0,0,0,1}, 1, true)
    trigger.action.lineToAll(coalitionId, line4Id, innerRecBottomLeft, innerRecLineBottomLeft, {0,0,0,1}, 1, true)
    local gashandleId = DrawingTools.newMarkId()
    trigger.action.rectToAll(coalitionId, gashandleId, handleTop, handleBottom, {0,0,0,1}, {0,0,0,1}, 1, true)
end
function DrawingTools.drawHealth(origin, coalitionId, boxSize, background)
    local topLeft = origin
    local bottomRight = {x = origin.x - boxSize, y = origin.y, z = origin.z + boxSize}
    local healthBoxId = DrawingTools.newMarkId()
    if background then
        trigger.action.rectToAll(coalitionId, healthBoxId, topLeft, bottomRight, {0,0,0,1}, {1,1,1,1}, 1, true, nil) 
    end
    local crossOffset = boxSize/3
    local c1 = { x = origin.x, y = origin.y, z = origin.z + crossOffset}
    local c2 = { x = c1.x, y = c1.y, z = c1.z + crossOffset}
    local c3 = { x = c2.x - crossOffset, y = c2.y, z = c2.z}
    local c4 = { x = c3.x, y = c3.y, z = c3.z + crossOffset}
    local c5 = { x = c4.x - crossOffset, y = c4.y, z = c4.z}
    local c6 = { x = c5.x, y = c5.y, z = c5.z - crossOffset}
    local c7 = { x = c6.x - crossOffset, y = c6.y, z = c6.z }
    local c8 = { x = c7.x, y = c7.y, z = c7.z - crossOffset}
    local c9 = { x = c8.x + crossOffset, y = c8.y, z = c8.z}
    local c10 = { x = c9.x, y = c9.y, z = c9.z - crossOffset}
    local c11 = { x = c10.x + crossOffset, y = c9.y, z = c10.z}
    local c12 = { x = c11.x, y = c9.y, z = c11.z + crossOffset}
    local crossId = DrawingTools.newMarkId()
    trigger.action.markupToAll(7, coalitionId, crossId, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, {0,0,0,1}, {1,0,0,1}, 1, true, nil)
end
function DrawingTools.drawX(coalitionId, point)
    local origin = point
    local v1 = {x = origin.x + xMark.size, y = 0, z = origin.z }
    local v2 = {x = origin.x - xMark.size, y = 0, z = origin.z }
    local h1 = {x = origin.x, y = 0, z = origin.z + xMark.size }
    local h2 = {x = origin.x, y = 0, z = origin.z - xMark.size }
    local vId = DrawingTools.newMarkId()
    local hId = DrawingTools.newMarkId()
    trigger.action.lineToAll(coalitionId, vId, v1, v2, {0,0,0,1}, 1, true, nil)
    trigger.action.lineToAll(coalitionId, hId, h1, h2, {0,0,0,1}, 1, true, nil)
    return vId, hId
end
function DrawingTools.drawCircle(coalitionId, point, radius)
    local drawingRadius = 50
    if radius then drawingRadius = radius end
    local circleId = DrawingTools.newMarkId()
    trigger.action.circleToAll(coalitionId, circleId, point, drawingRadius, {0,0,0,1}, {0,0,0,0}, 1, true, nil)
    return circleId
end
function DrawingTools.drawCamera(coalitionId, point)
    --draw rectangle with bottom left corner on point
    --draw a circle in the middle of the rectangle
    --draw the reflex sight lens hole thing
    --return the circle midpoint for fill location
    local rectangleId = DrawingTools.newMarkId()
    local rectEndPoint = {x = point.x + 250, y= 0, z = point.z + 400}
    trigger.action.rectToAll(coalitionId, rectangleId, point, rectEndPoint, {0,0,0,1}, {1,1,1,0.8}, 1, true, nil)
    local rectMidPoint = {x = point.x + 125, y=0, z = point.z + 200}
    trigger.action.circleToAll(coalitionId, DrawingTools.newMarkId(), rectMidPoint, 80, {0,0,0,1}, {0,0,0,0.8}, 1, true, nil)
    local shutterButtonStartPoint = {x = point.x + 250, y = 0, z = point.z + 25}
    local shutterButtonEndPoint = {x = shutterButtonStartPoint.x + 25, y = 0, z = shutterButtonStartPoint.z + 40}
    trigger.action.rectToAll(coalitionId, DrawingTools.newMarkId(), shutterButtonStartPoint, shutterButtonEndPoint, {0,0,0,1}, {0,0,0,0.8}, 1, true, nil)
    local viewFinderBottomLeft = {x = shutterButtonStartPoint.x, y=0, z = rectMidPoint.z - 60}
    local viewFinderTopLeft = {x = viewFinderBottomLeft.x + 40, y=0, z = rectMidPoint.z - 40}
    local viewFinderTopRight = {x = viewFinderBottomLeft.x + 40, y=0, z = rectMidPoint.z + 40}
    local viewFinderBottomRight = {x = shutterButtonStartPoint.x, y=0, z = rectMidPoint.z + 60}
    trigger.action.quadToAll(coalitionId, DrawingTools.newMarkId(), viewFinderBottomLeft, viewFinderTopLeft, viewFinderTopRight, viewFinderBottomRight, {0,0,0,1}, {0,0,0,0.8}, 1, true, nil)
    return rectMidPoint
end
function DrawingTools.drawTriangle(coalitionId, centerPoint, length)
    local sideLength = triangleMark.size
    if length then sideLength = length end
    local perimeter = 3 * sideLength
    local height = (2 * perimeter)/(2*(math.sqrt(3)))
    local topPoint = {x = centerPoint.x + (height/3), y = 0, z = centerPoint.z}
    local bottomLeftPoint = {x = topPoint.x - (sideLength * math.cos(math.rad(30))), y = 0, z = topPoint.z - (sideLength * math.sin(math.rad(30)))}
    local bottomRightPoint = {x = topPoint.x - (sideLength * math.cos(math.rad(30))), y = 0, z = topPoint.z + (sideLength * math.sin(math.rad(30)))}
    local triangleId = DrawingTools.newMarkId()
    trigger.action.markupToAll(7, coalitionId, triangleId, bottomLeftPoint, topPoint, bottomRightPoint, {0,0,0,1}, {0,0,0,0}, 1, true, nil)
    return triangleId
end
function DrawingTools.drawChevron(coalitionId, centerPoint, length)
    local sideLength = 10
    if length then sideLength = length end
    local topPoint = centerPoint
    local bottomLeftPoint = {x = topPoint.x - (sideLength * math.cos(math.rad(60))), y = 0, z = topPoint.z - (sideLength * math.sin(math.rad(60)))}
    local bottomRightPoint = {x = topPoint.x - (sideLength * math.cos(math.rad(60))), y = 0, z = topPoint.z + (sideLength * math.sin(math.rad(60)))}
    local line1Id = DrawingTools.newMarkId()
    local line2Id = DrawingTools.newMarkId()
    trigger.action.lineToAll(coalitionId, line1Id, topPoint, bottomLeftPoint, {0,0,0,1}, 1, true, nil)
    trigger.action.lineToAll(coalitionId, line2Id, topPoint, bottomRightPoint, {0,0,0,1}, 1, true, nil)
    return line1Id, line2Id
end
function DrawingTools.drawPriorityMarker(coalitionId, markPoint, priorityType)
    local markIds = {}
    if priorityType == "CAPTURE" then
        markIds = DrawingTools.drawSwords(coalitionId, markPoint)
    elseif "REINFORCE" then
        markIds = DrawingTools.drawShield(coalitionId, markPoint)
    end
    return markIds
end

function DrawingTools.drawSwords(coalitionId, markPoint)
    local markIds = {}
    local gripLength = 100
    local pommelRadius = 60
    local crossGuardWidth = 200
    local bladeLength = 500
    --- pommel
    local pommelPoint = markPoint
    local pommelMarkId = DrawingTools.newMarkId()
    table.insert(markIds, pommelMarkId)
    trigger.action.circleToAll(coalitionId, pommelMarkId, pommelPoint, pommelRadius, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
    --- grip
    local gripLowerRight = {x = pommelPoint.x + (pommelRadius - pommelRadius/4), y = 0, z = pommelPoint.z + (pommelRadius - pommelRadius/3)}
    local gripLowerLeft = {x = pommelPoint.x + (pommelRadius - pommelRadius/4), y = 0, z = pommelPoint.z - (pommelRadius - pommelRadius/3)}
    local gripUpperRight = {x = gripLowerRight.x + gripLength, y = 0, z = gripLowerRight.z}
    local gripUpperLeft = {x = gripLowerLeft.x + gripLength, y = 0, z = gripLowerLeft.z}
    local gripMarkId = DrawingTools.newMarkId()
    table.insert(markIds, gripMarkId)
    trigger.action.quadToAll(coalitionId, gripMarkId, gripLowerLeft, gripUpperLeft, gripUpperRight, gripLowerRight, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
    ---crossguard
    local crossGuardLowerLeft = {x = gripUpperLeft.x, y = 0, z = gripUpperLeft.z - ((crossGuardWidth-(pommelRadius - pommelRadius/4))/2)}
    local crossGuardUpperLeft = {x = crossGuardLowerLeft.x + crossGuardWidth/5, y = 0, z = crossGuardLowerLeft.z }
    local crossGuardLowerRight = {x = gripUpperRight.x, y = 0, z = gripUpperRight.z + ((crossGuardWidth-(pommelRadius - pommelRadius/4))/2)}
    local crossGuardUpperRight = {x = crossGuardLowerRight.x + crossGuardWidth/5, y = 0, z = crossGuardLowerRight.z}
    local crossGuardMarkId = DrawingTools.newMarkId()
    table.insert(markIds, crossGuardMarkId)
    trigger.action.quadToAll(coalitionId, crossGuardMarkId, crossGuardLowerLeft, crossGuardUpperLeft, crossGuardUpperRight, crossGuardLowerRight, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
    ---
    local bladeLowerLeft = {x = gripUpperLeft.x + crossGuardWidth/5, y=0, z = gripUpperLeft.z - pommelRadius/6}
    local bladeUpperLeft = {x = bladeLowerLeft.x + bladeLength, y=0, z = bladeLowerLeft.z}
    local bladeLowerRight = {x = gripUpperRight.x + crossGuardWidth/5, y=0, z = gripUpperRight.z + pommelRadius/6}
    local bladeUpperRight = {x = bladeLowerRight.x + bladeLength, y=0, z = bladeLowerRight.z}
    local bladeMarkId = DrawingTools.newMarkId()
    table.insert(markIds, bladeMarkId)
    trigger.action.quadToAll(coalitionId, bladeMarkId, bladeLowerLeft, bladeUpperLeft, bladeUpperRight, bladeLowerRight, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
    ---
    local bladeTipLowerLeft = {x = bladeUpperLeft.x, y = 0, z = bladeUpperLeft.z}
    local bladeTipLowerRight = {x = bladeUpperRight.x, y =0, z = bladeUpperRight.z}
    local bladeTipPoint = {x = bladeUpperLeft.x + gripLength/2, y = 0, z = pommelPoint.z}
    local bladeTipId = DrawingTools.newMarkId()
    table.insert(markIds, bladeTipId)
    trigger.action.markupToAll(7, coalitionId, bladeTipId, bladeTipLowerLeft, bladeTipPoint, bladeTipLowerRight, {0,0,0,1}, {0,0,0,1}, true, nil)
    ---
    return markIds
end
function DrawingTools.drawShield(coalitionId, markPoint)
    local markIds = {}
    local shieldSideSize = 400
    ---
    local shieldLowerLeft = { x = markPoint.x + shieldSideSize/1.5, y=0, z = markPoint.z - shieldSideSize/2 }
    local shieldUpperLeft = { x = shieldLowerLeft.x + shieldSideSize, y=0, z = shieldLowerLeft.z}
    local shieldLowerRight = { x = shieldLowerLeft.x, y=0, z = shieldLowerLeft.z + shieldSideSize }
    local shieldUpperRight = { x = shieldUpperLeft.x, y=0, z = shieldLowerRight.z}
    local shieldIntermediate1LowerLeft = {x = shieldLowerLeft.x - shieldSideSize/4, y = 0, z = shieldLowerLeft.z + shieldSideSize/8}
    local shieldIntermediate1LowerRight = {x = shieldLowerRight.x - shieldSideSize/4, y = 0, z = shieldLowerRight.z - shieldSideSize/8}
    local shieldIntermediate2LowerLeft = {x = shieldIntermediate1LowerLeft.x - shieldSideSize/4, y = 0, z = shieldIntermediate1LowerLeft.z + shieldSideSize/6}
    local shieldIntermediate2LowerRight = {x = shieldIntermediate1LowerRight.x - shieldSideSize/4, y = 0, z = shieldIntermediate1LowerRight.z - shieldSideSize/6}
    local shieldMarkId = DrawingTools.newMarkId()
    trigger.action.markupToAll(7, coalitionId, shieldMarkId, markPoint, shieldIntermediate2LowerLeft, shieldIntermediate1LowerLeft, shieldLowerLeft, shieldUpperLeft, shieldUpperRight, shieldLowerRight, shieldIntermediate1LowerRight, shieldIntermediate2LowerRight, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
    table.insert(markIds, shieldMarkId)
    ---
    return markIds
end
local screenColors = {
    [-1] = {1,1,1,0.3},
    [0] = {0.3,1,0.6,1},
    [2] = {1,1,1,1},
    [3] = {1,0.65,0,1}
}
local radioRectangleHeight = 500
function DrawingTools.drawRadio(coalitionId, markPoint, color)
    local markIds = {}
    local rectangleMarkId = DrawingTools.newMarkId()
    table.insert(markIds, rectangleMarkId)
    local rectLowerLeft = markPoint
    local rectUpperRight = {x = rectLowerLeft.x + radioRectangleHeight, y = 0, z = rectLowerLeft.z + (radioRectangleHeight*(2/3))}
    trigger.action.rectToAll(coalitionId, rectangleMarkId, rectLowerLeft, rectUpperRight, {0,0,0,1}, {0,0,0,0.7}, 1, true, nil)
    ---
    local antennaLowerLeft = {x = rectUpperRight.x, y = 0, z = rectLowerLeft.z + (radioRectangleHeight/16)}
    local antennaUpperRight = {x = antennaLowerLeft.x + (radioRectangleHeight/2), y = 0, z = antennaLowerLeft.z + (radioRectangleHeight/8)}
    local antennaMarkId = DrawingTools.newMarkId()
    table.insert(markIds, antennaMarkId)
    trigger.action.rectToAll(coalitionId, antennaMarkId, antennaLowerLeft, antennaUpperRight, {0,0,0,1}, {0,0,0,0.7}, 1, true, nil)
    ---
    local screenLowerLeft = {x = rectLowerLeft.x + ((3/5)*radioRectangleHeight), y = 0, z = rectLowerLeft.z + (radioRectangleHeight/12)}
    local screenUpperRight = {x = screenLowerLeft.x + ((1/5)*radioRectangleHeight), y = 0, z = screenLowerLeft.z + ((1/2)*radioRectangleHeight) }
    local screenMarkId = DrawingTools.newMarkId()
    table.insert(markIds, screenMarkId)

    trigger.action.rectToAll(coalitionId, screenMarkId, screenLowerLeft, screenUpperRight, {0,0,0,0.6}, screenColors[color], 1, true, nil)
    ---
    return markIds
end
function DrawingTools.moveRadio(point, bodyId, antennaId, screenId, screenColor)
    local bodyStart = point
    local bodyEnd = { x = point.x + radioRectangleHeight, y = 0, z = point.z + (radioRectangleHeight*(2/3)) }
    local antennaStart = {x = point.x + radioRectangleHeight, y = 0, z = point.z + (radioRectangleHeight/16)}
    local antennaEnd = {x = antennaStart.x + (radioRectangleHeight/2), y = 0, z = antennaStart.z + (radioRectangleHeight/8)}
    local screenStart = {x = point.x + ((3/5)*radioRectangleHeight), y = 0, z = point.z + (radioRectangleHeight/12)}
    local screenEnd = {x = screenStart.x + ((1/5)*radioRectangleHeight), y = 0, z = screenStart.z + ((1/2)*radioRectangleHeight) }
    trigger.action.setMarkupPositionStart(bodyId, bodyStart)
    trigger.action.setMarkupPositionEnd(bodyId, bodyEnd)
    trigger.action.setMarkupPositionStart(antennaId, antennaStart)
    trigger.action.setMarkupPositionEnd(antennaId, antennaEnd)
    trigger.action.setMarkupPositionStart(screenId, screenStart)
    trigger.action.setMarkupPositionEnd(screenId, screenEnd)
    DrawingTools.updateRadioColor(screenId, screenColor)
end
function DrawingTools.updateRadioColor(screenId, screenColor)
    trigger.action.setMarkupColorFill(screenId, screenColors[screenColor])
end
function DrawingTools.numberBP(point, radius, number, max)
    local radsToRotate = (1/max) * (2*math.pi)
    local tickLength = radius/4
    local northVec = {x = 1, y = 0, z = 0}
    for i = 1, number do
        local tickVec = Utils.RotateVector(northVec, radsToRotate*(i-1))
        local tickStart = Utils.VectorAdd(point, Utils.ScalarMult(tickVec, radius))
        local tickEnd = Utils.VectorAdd(point, Utils.ScalarMult(tickVec, radius+tickLength))
        local tickId = DrawingTools.newMarkId()
        trigger.action.lineToAll(-1, tickId, tickStart, tickEnd, {0,0,0,1}, 1, true, nil)
    end
end