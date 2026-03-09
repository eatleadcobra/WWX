JTAC = {}
jtac = {
    distanceLimit = 10000 -- Set the distance limit for lasing targets (in meters) using 10 kilometers cause thats what AI told me
    lasing = {}
    trackingInterval = 1
}

unitTables = {}
function JTAC.sortedTargetList(targets) -- Used with detectedTargets not just a unit list
    local targetTable = {
        ["SAM"] = {},
        ["AAA"] = {},
        ["HeavyArmoredUnits"] = {},
        ["LightArmoredUnits"] = {},
        ["Armed vehicles"] = {}
    }
    for i = 1, #targets do
        local targetObject = targets[i].object
        if targetObject then
            if targetObject:getDesc().category == 2 then
                local targetName = targetObject:getName()
                if targetObject:hasAttribute("SAM") then
                    targetTable["SAM"][#targetTable["SAM"] + 1] = targetName
                elseif targetObject:hasAttribute("AAA") then
                    targetTable["AAA"][#targetTable["AAA"] + 1] = targetName
                elseif targetObject:hasAttribute("HeavyArmoredUnits") then
                    targetTable["HeavyArmoredUnits"][#targetTable["HeavyArmoredUnits"] + 1] = targetName
                elseif targetObject:hasAttribute("LightArmoredUnits") then
                    targetTable["LightArmoredUnits"][#targetTable["LightArmoredUnits"] + 1] = targetName
                elseif targetObject:hasAttribute("Armed vehicles") then
                    targetTable["Armed vehicles"][#targetTable["Armed vehicles"] + 1] = targetName
                end
            end
        end
    end
    return targetTable
end
function jtac.getPriorityList(targets)
    local priorityTable = {
        [1] = "SAM",
        [2] = "HeavyArmoredUnits",
        [3] = "LightArmoredUnits",
        [4] = "Armed vehicles",
        [5] = "AAA"
    }
    local targetList = {}
    for i = 1, #priorityTable do
        local category = priorityTable[i]
        if targets[category] then
            for j = 1, #targets[category] do
                local targetName = targets[category][j]
                if Unit.getByName(targetName) then
                    targetList[#targetList + 1] = targets[category][j]
                end
            end
        end
    end
    return targetList
end
function jtac.laseAvailableTarget(jtacUnitName, code, targetList)
    local jtacUnit = Unit.getByName(jtacUnitName)
    local laserSourceRelativeToUnit = {x = 0, y = 1.8, z = 0}
    if jtacUnit then
        if not jtac.lasing[jtacUnit] then
            for i = 1, #targetList do
                local target = Unit.getByName(targetList[i])
                if target then
                    local targetLife = target:getLife()
                    if targetLife > 0 then
                        local targetPoint = target:getPoint()
                        if targetPoint then
                            local jtacPoint = jtacUnit:getPoint()
                            local distance = jtacPoint:getDistance(targetPoint)
                            if distance <= jtac.distanceLimit then
                                jtac.lasing[jtacUnit] = {
                                    laser = Spot.createLaser(jtacUnit, laserSourceRelativeToUnit, targetPoint, code),
                                    targetName = target:getName()
                                }
                                timer.scheduleFunction(jtac.trackLaser, {jtacName = jtacUnitName}, timer.getTime() + jtac.trackingInterval)
                                break
                            end
                        end
                    end
                end
            end    
        end
    else
        env.error("JTAC unit not found: " .. jtacUnitName)
    end
end
-- jtacName
function jtac.trackLaser(param)
    local jtacUnit = Unit.getByName(param.jtacName)
    if jtacUnit then
        local lasingInfo = jtac.lasing[param.jtacName]
        if lasingInfo then
            local target = Unit.getByName(lasingInfo.targetName)
            if target then
                local tp = target:getPoint()
                local laser = lasingInfo.laser
                if tp and laser then
                    laser:setPoint(tp)
                    timer.scheduleFunction(jtac.trackLaser, {jtacName = param.jtacName}, timer.getTime() + jtac.trackingInterval)
                    return
                end
            end
        end
    end
    -- if anything fails here either the jtac, target, or laser are dead so we start over
    if jtac.lasing[param.jtacName] and jtac.lasing[param.jtacName].laser then
        jtac.lasing[param.jtacName].laser:destroy()
    end
    jtac.lasing[param.jtacName] = nil
end



end


    