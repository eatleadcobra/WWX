DrawingTools = {}
local newMarkId = 100
function DrawingTools.newMarkId()
    local returnId = newMarkId
    newMarkId = newMarkId + 1
    return returnId
end
local package = {
    [1] = {
        size = 800
    },
    [2] = {
        size = 2400
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
    env.info("Drawing package left quad: " .. leftQuad, false)
    trigger.action.quadToAll(coalition, leftQuad, lbr, lbl, lul, centerPoint, {0,0,0,1}, {1,1,1,1}, 1, true)
    local rightQuad = DrawingTools.newMarkId()
    local rul = centerPoint
    local rur = {x = centerPoint.x + package[size].size/8 , y = centerPoint.y, z = centerPoint.z + package[size].size/4}
    local rbl = lbr
    local rbr = {x = centerPoint.x - package[size].size/3 + package[size].size/8, y = centerPoint.y, z = centerPoint.z + package[size].size/4}
    env.info("Drawing package right quad: " .. rightQuad, false)
    trigger.action.quadToAll(coalition, rightQuad, rbr, rbl, rul, rur, {0,0,0,1}, {1,1,1,1}, 1, true)
    local topQuad = DrawingTools.newMarkId()
    local tb = centerPoint
    local tl = lul
    local tr = rur
    local tt = {x = centerPoint.x + package[size].size/4.5, y = centerPoint.y, z = centerPoint.z }
    env.info("Drawing package top quad: " .. topQuad, false)
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
    env.info("Drawing ammo background: " .. ammoId, false)
    trigger.action.rectToAll(coalitionId, ammoId, rectTop, rectBottom, {0,0,0,1}, {0,0,0,0.9}, 1, true, nil)
    for i = 1, 3 do
        local locOrg = {x = origin.x, y = origin.y, z = origin.z + ((i-1)*(drawingWidth + drawingWidth/4))}
        local boxTop = {x = locOrg.x, y = locOrg.y, z = locOrg.z - drawingWidth/2 }
        local boxBottom = { x = locOrg.x - drawingWidth/2 - drawingHeight, y = locOrg.y, z = locOrg.z + drawingWidth/2}
        local bulletRecId = DrawingTools.newMarkId()
        local bulletCircleId = DrawingTools.newMarkId()
        local bulletLineId = DrawingTools.newMarkId()
        env.info("Drawing ammo ".. i .." rec: " .. bulletRecId, false)
        env.info("Drawing ammo ".. i .." circle: " .. bulletCircleId, false)
        env.info("Drawing ammo ".. i .." line: " .. bulletLineId, false)
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
    env.info("Drawing gas border: " .. gasBorderId, false)
    env.info("Drawing gas outline: " .. gasOutlineId, false)
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
    env.info("Drawing gas nub: " .. nubId, false)
    local innerRecQuadId = DrawingTools.newMarkId()
    env.info("Drawing gas inner quad: " .. innerRecQuadId, false)
    local line1Id = DrawingTools.newMarkId()
    local line2Id = DrawingTools.newMarkId()
    local line3Id = DrawingTools.newMarkId()
    local line4Id = DrawingTools.newMarkId()
    env.info("Drawing gas line 1: " .. line1Id, false)
    env.info("Drawing gas line 2: " .. line2Id, false)
    env.info("Drawing gas line 3: " .. line3Id, false)
    env.info("Drawing gas line 4: " .. line4Id, false)
    trigger.action.quadToAll(coalitionId, nubId, nub3, nub2, nub1, nub4, {1,1,1,1}, {1,1,1,1}, 1, true, nil)
    trigger.action.quadToAll(coalitionId, innerRecQuadId, innerRecTopLeft, innerRecTopRight, innerRecBottomRight, innerRecBottomLeft, {0,0,0,1}, {0,0,0,0}, 1, true, nil)
    trigger.action.lineToAll(coalitionId, line1Id, innerRecTopLeft, innerRecLineTopLeft, {0,0,0,1}, 1, true)
    trigger.action.lineToAll(coalitionId, line2Id, innerRecTopRight, innerRecLineTopRight, {0,0,0,1}, 1, true)
    trigger.action.lineToAll(coalitionId, line3Id, innerRecBottomRight, innerRecLineBottomRight, {0,0,0,1}, 1, true)
    trigger.action.lineToAll(coalitionId, line4Id, innerRecBottomLeft, innerRecLineBottomLeft, {0,0,0,1}, 1, true)
    local gashandleId = DrawingTools.newMarkId()
    env.info("Drawing gas handle: " .. gashandleId, false)
    trigger.action.rectToAll(coalitionId, gashandleId, handleTop, handleBottom, {0,0,0,1}, {0,0,0,1}, 1, true)
end
function DrawingTools.drawHealth(origin, coalitionId, boxSize, background)
    local topLeft = origin
    local bottomRight = {x = origin.x - boxSize, y = origin.y, z = origin.z + boxSize}
    local healthBoxId = DrawingTools.newMarkId()
    if background then
        env.info("Drawing health icon box: " .. healthBoxId, false)
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
    env.info("Drawing health cross: " .. crossId, false)
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