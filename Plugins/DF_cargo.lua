local cargo = {}
function cargo.findPickupZone(location, coalition)
    for i = 1, #DFS.pickUpZones[coalition] do
        local pickUpZone = trigger.misc.getZone(DFS.pickUpZones[coalition][i])
        if pickUpZone then
            local pickUpZoneLoc = pickUpZone.point
            if pickUpZoneLoc then
                local distanceToZone = Utils.PointDistance(pickUpZoneLoc, location)
                if distanceToZone <= DFS.status.pickupDistance then
                    return DFS.pickUpZones[coalition][i]
                end
            end
        end
    end
    return nil
end
function cargo.canSpawnCargo(type, transporterCoalition, isFront, modifier, piratePickup)
    if type == DFS.supplyType["GUN"] or cargo.isTroops(type) then
        if isFront then
            return DFS.status[transporterCoalition].supply.front[DFS.supplyType.EQUIPMENT] > DFS.status.playerResupplyAmts[type][modifier]
        elseif piratePickup then
            return DFS.status[transporterCoalition].supply.pirate[DFS.supplyType.EQUIPMENT] > DFS.status.playerResupplyAmts[type][modifier]
        else
            return DFS.status[transporterCoalition].supply.rear[DFS.supplyType.EQUIPMENT] > DFS.status.playerResupplyAmts[type][modifier]
        end
    else
        if isFront then
            if type == DFS.supplyType.AMMO then
                return DFS.status[transporterCoalition].supply.front[type] >= DFS.status.playerResupplyAmts[type][modifier]
            else
                return false
            end
        elseif piratePickup then
            return DFS.status[transporterCoalition].supply.pirate[DFS.supplyType.EQUIPMENT] > DFS.status.playerResupplyAmts[type][modifier]
        else
            return DFS.status[transporterCoalition].supply.rear[type] >= DFS.status.playerResupplyAmts[type][modifier]
        end
    end
end
function cargo.getAGL(point)
    local alt = point.y
    local land = land.getHeight({x = point.x, y = point.z}) or 0
    if land < 0 then land = 0 end
    alt = alt - land
    return alt
end
--coalition, cargo, spawnTime
function cargo.trackCargo(param)
    env.info("Tracking cargo: " .. param.cargo, false)
    local cargo = StaticObject.getByName(param.cargo)
    local pickupZone = DFS.pickUpZones[param.coalition][1]
    if param.seaPickup then pickupZone = DFS.pickUpZones[param.coalition][2] end
    if cargo and cargo.getPoint and cargo:getPoint() then
        local closestDepotToCargo = cargo.findClosestDepot(cargo:getPoint(), param.coalition)
        local closestFirebaseToCargo = nil
        local distanceToClosestFb =  nil
        if param.supplyType == DFS.supplyType.AMMO or param.supplyType == DFS.supplyType.GUN then
            closestFirebaseToCargo = Firebases.getClosestFirebase(cargo:getPoint(), param.coalition)
            if closestFirebaseToCargo > 0 then
                distanceToClosestFb = Utils.PointDistance(Firebases[closestFirebaseToCargo].positions.location, cargo:getPoint())
            end
        end
        if closestDepotToCargo then
            if timer:getTime() - param.spawnTime > DFS.status.cargoExpireTime then
                env.info("cargo expired: " .. param.cargo, false)
                if Utils.PointDistance(cargo:getPoint(),trigger.misc.getZone(pickupZone).point) <= DFS.status.playerDeliverRadius then
                    env.info("expired cargo recliamed: " ..param.cargo, false)
                    cargo.deliverToDepot(closestDepotToCargo, param.coalition, param.supplyType, param.modifier)
                end
                if cargo and cargo:isExist() then cargo:destroy() end
            elseif timer:getTime() - param.spawnTime > 1800 and Utils.PointDistance(cargo:getPoint(),trigger.misc.getZone(pickupZone).point) < 30 then
                env.info("cargo never left pickup area: " .. param.cargo, false)
                if not param.seaPickup then
                    env.info("un-picked up cargo reclaimed: " .. param.cargo, false)
                    local reclaimType = param.supplyType
                    if reclaimType == 4 then reclaimType = 3 end
                    DFS.increaseRearSupply({coalitionId = param.coalition, amount = DFS.status.playerResupplyAmts[param.supplyType][param.modifier], type = reclaimType})
                end
                if cargo and cargo:isExist() then cargo:destroy() end
            else
                local velocity = cargo:getVelocity()
                local altitude = cargo.getAGL(cargo:getPoint())
                local chinookCargo = false
                local deliverGroup = Group.getByName(param.groupName)
                if deliverGroup then
                    local deliverUnit = deliverGroup:getUnit(1)
                    if deliverUnit then
                        chinookCargo = deliverUnit:getTypeName() == "CH-47Fbl1"
                    end
                end
                env.info("cargo alt AGL: " .. altitude, false)
                local cargoPoint = cargo:getPoint()
                if cargoPoint then env.info("cargo location: " .. cargoPoint.x .. " y: " .. cargoPoint.y .. " z: " .. cargoPoint.z, false) end
                env.info("cargo " .. param.cargo .. " velocity x: " .. velocity.x .. " y: " .. velocity.y .. " z: " .. velocity.z, false)
                env.info("chinook cargo: " .. tostring(chinookCargo), false)
                if (chinookCargo == false and velocity.x < 0.01 and velocity.z < 0.01 and velocity.y < 0.01 and (altitude < 1)) or ( chinookCargo == true and velocity.x < 0.01 and velocity.z < 0.01 and velocity.y < 0.01 and (altitude < 0.2 and altitude > -0.1)) then
                    env.info("cargo not moving", false)
                    env.info(param.cargo .. ": closest depot distance: " .. closestDepotToCargo.distance, false)
                    env.info(param.cargo .. ": closest depot is rear: " .. tostring(closestDepotToCargo.isRear), false)
                    env.info(param.cargo .. ": sea pickup: " .. tostring(param.seaPickup), false)
                    env.info(param.cargo .. ": front Pickup: " .. tostring(param.frontPickup), false)
                    param.successfulDeployChecks = param.successfulDeployChecks + 1
                    env.info(param.cargo .. ": successful checks: " .. param.successfulDeployChecks, false)
                    if param.successfulDeployChecks > 3 then
                        if distanceToClosestFb then
                            env.info(param.cargo .. ": closest firebase distance: " .. distanceToClosestFb, false)
                        end
                        if (param.frontPickup == nil or param.frontPickup == false) and (closestDepotToCargo.distance <= DFS.status.playerDeliverRadius or (closestDepotToCargo.isRear and param.seaPickup and closestDepotToCargo.distance <= 2000)) then
                            env.info("Group: " .. param.groupId .. "-" .. param.groupName .. " delivered " .. param.cargo .. " to " .. closestDepotToCargo.depotName, false)
                            local deliverType = "FRONT"
                            if closestDepotToCargo.isRear then deliverType = "REAR" end
                            cargo.supplyEvent(param.groupName, param.supplyType, deliverType)
                            trigger.action.outTextForGroup(param.groupId, DFS.supplyNames[param.supplyType] .. " delivered!", 15, false)
                            cargo.deliverToDepot(closestDepotToCargo.isRear, param.coalition, param.supplyType, param.modifier)
                            --if cargo and cargo:isExist() then cargo:destroy() end
                            return
                        elseif distanceToClosestFb and distanceToClosestFb <= DFS.status.playerDeliverRadius and closestFirebaseToCargo and param.supplyType == DFS.supplyType["AMMO"] then
                            Firebases.resupplyFirebase(Firebases[closestFirebaseToCargo], DFS.status.playerResupplyAmts[param.supplyType][param.modifier])
                            cargo.supplyEvent(param.groupName, param.supplyType, "FIREBASE")
                            env.info("Group: " .. param.groupId .. " delivered " .. param.cargo .. " to firebase", false)
                            trigger.action.outTextForGroup(param.groupId,"Ammo delivered to firebase!", 10, false)
                            --if cargo and cargo:isExist() then cargo:destroy() end
                            return
                        elseif distanceToClosestFb and distanceToClosestFb <= DFS.status.playerDeliverRadius and closestFirebaseToCargo and param.supplyType == DFS.supplyType["GUN"] then
                            Firebases.addGroupToFirebase(Firebases[closestFirebaseToCargo], Firebases[closestFirebaseToCargo].fbType)
                            cargo.supplyEvent(param.groupName, param.supplyType, "FIREBASE")
                            env.info("Group: " .. param.groupId .. " delivered " .. param.cargo .. " to firebase", false)
                            trigger.action.outTextForGroup(param.groupId, "Gun delivered to firebase!", 10, false)
                            --if cargo and cargo:isExist() then cargo:destroy() end
                            return
                        elseif timer:getTime() - param.spawnTime > 29 and closestFirebaseToCargo == -1 and cargo.findPickupZone(cargo:getPoint(), param.coalition) == nil and param.supplyType == DFS.supplyType["GUN"] then
                            env.info("Group: " .. param.groupId .. " deployed howitzer firebase", false)
                            trigger.action.outTextForGroup(param.groupId, "You have deployed a firebase", 10, false)
                            Firebases.deployStatic(cargo:getName(), "HOWITZER")
                            --if cargo and cargo:isExist() then cargo:destroy() end
                        else
                            timer.scheduleFunction(cargo.trackCargo, param, timer:getTime() + 10)
                        end
                    else
                        timer.scheduleFunction(cargo.trackCargo, param, timer:getTime() + 10)
                    end
                else
                    param.successfulDeployChecks = 0
                    timer.scheduleFunction(cargo.trackCargo, param, timer:getTime() + 10)
                end
            end
        end
    end
end
function cargo.deliverToDepot(isRear, coalition, supplyType, modifier, piratePickup)
    if coalition and supplyType and modifier then
        local resupType = supplyType
        if supplyType == DFS.supplyType.GUN or cargo.isTroops(supplyType) then
            resupType = DFS.supplyType.EQUIPMENT
        end
        if isRear then
            DFS.increaseRearSupply({coalitionId = coalition, amount = math.floor(DFS.status.playerResupplyAmts[supplyType][modifier]), type = resupType})
        elseif piratePickup then
            DFS.increasePirateSupply({coalitionId = coalition, amount = math.floor(DFS.status.playerResupplyAmts[supplyType][modifier]), type = resupType})
        else
            DFS.increaseFrontSupply({coalitionId = coalition, amount = math.floor(DFS.status.playerResupplyAmts[supplyType][modifier]), type = resupType})
        end
    else
        env.info("Error delivering to depot. coalition nil: "..tostring(coalition==nil).." supplyType nil: "..tostring(supplyType==nil)" modifier nil: "..tostring(modifier==nil), false)
    end
end
function cargo.supplyEvent(deliverGroupName, supplyType, deliveryLocation)
    local deliverGroup = Group.getByName(deliverGroupName)
    if deliverGroup then
        local deliverUnit = deliverGroup:getUnit(1)
        if deliverUnit then
            local deliverPlayer = deliverUnit:getPlayerName()
            if deliverPlayer then
                local supplyTypeName = DFS.supplyNames[supplyType]
                if supplyType == DFS.supplyType.GUN then
                    supplyTypeName = "a gun"
                end
                local deliveryLocationMsg = "front depot"
                if deliveryLocation == "REAR" then
                    deliveryLocationMsg = "rear depot"
                elseif deliveryLocation == "FIREBASE" then
                    deliveryLocationMsg = "firebase"
                end
                local deliveryMessage = deliverPlayer .. " delivered " .. supplyTypeName .. " to a " .. deliveryLocationMsg
                WWEvents.playerCargoDelivered(deliverPlayer, deliverGroup:getCoalition(), supplyType, deliveryLocation, deliveryMessage)
            end
        end
    end
end
function cargo.findClosestDepot(location, coalition)
    local closestDepotZone = nil
    local closestDistance = nil
    local isRear = false
    for i = 1, #DFS.status[coalition].spawns.rd do
        local spawn = DFS.status[coalition].spawns.rd[i]
        if spawn then
            local depotGroup = Group.getByName(spawn.groupName)
            if depotGroup then
                local firstUnit = depotGroup:getUnit(1)
                if firstUnit then
                    local depotPoint = firstUnit:getPoint()
                    if depotPoint then
                        local distance = Utils.PointDistance(location, depotPoint)
                        if closestDistance == nil then
                            closestDistance = distance
                            closestDepotZone = spawn.spawnZone
                            isRear = true
                        end
                        if distance < closestDistance then
                            closestDistance = distance
                            closestDepotZone = spawn.spawnZone
                            isRear = true
                        end
                    end
                end
            end
        end
    end
    for i = 1, #DFS.status[coalition].spawns.fd do
        local spawn = DFS.status[coalition].spawns.fd[i]
        if spawn then
            local depotGroup = Group.getByName(spawn.groupName)
            if depotGroup then
                local firstUnit = depotGroup:getUnit(1)
                if firstUnit then
                    local depotPoint = firstUnit:getPoint()
                    if depotPoint then
                        local distance = Utils.PointDistance(location, depotPoint)
                        if closestDistance == nil then
                            closestDistance = distance
                            closestDepotZone = spawn.spawnZone
                            isRear = false
                        end
                        if distance < closestDistance then
                            closestDistance = distance
                            closestDepotZone = spawn.spawnZone
                            isRear = false
                        end
                    end
                end
            end
        end
    end
    if closestDistance == nil or closestDepotZone == nil then
        return nil
    else
        return {distance = closestDistance, depotName = closestDepotZone, isRear = isRear}
    end
end
function cargo.spawnStatic(type, point, country, modifier)
    local staticName = nil
    local id = DFS.status.cargoId
    DFS.status.cargoId = DFS.status.cargoId + 1
    local cargoPoint = point
    local staticTemplate = cargo.copyTemplate(DFS.templates[type][modifier])
    staticTemplate["name"] = DFS.supplyNames[type].."-"..country.."-"..id
    staticName = staticTemplate["name"]
    staticTemplate["y"] = cargoPoint.z + math.random(-5,5)
    staticTemplate["x"] = cargoPoint.x + math.random(-5,5)
    coalition.addStaticObject(country, staticTemplate)
    return staticName
end
function cargo.spawnStaticPrecise(type, point, country, modifier)
    local staticName = nil
    local id = DFS.status.cargoId
    DFS.status.cargoId = DFS.status.cargoId + 1
    local cargoPoint = point
    local staticTemplate = cargo.copyTemplate(DFS.templates[type][modifier])
    staticTemplate["name"] = DFS.supplyNames[type].."-"..country.."-"..id
    staticName = staticTemplate["name"]
    staticTemplate["y"] = cargoPoint.z
    staticTemplate["x"] = cargoPoint.x
    coalition.addStaticObject(country, staticTemplate)
    return staticName
end
function cargo.reloadMortarBase(groupName, baseIndex, coalitionId)
    local pickupGroup = Group.getByName(groupName)
    local closestBase = Firebases[baseIndex]
    if pickupGroup and closestBase then
        local transporterTable = DFS.helos[groupName]
        local pickupUnit = pickupGroup:getUnit(1)
        if pickupUnit then
            if transporterTable.cargo.volumeUsed + DFS.cargoVolumes[DFS.supplyType.MORTAR_SQUAD] <= DFS.heloCapacities[pickupUnit:getTypeName()].volume and DFS.heloCapacities[pickupUnit:getTypeName()].types[DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD]] then
                transporterTable.cargo.cargoType = DFS.supplyType.MORTAR_SQUAD
                transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed + DFS.cargoVolumes[DFS.supplyType.MORTAR_SQUAD] --todo: make table for volume lookup
                transporterTable.addedMass = transporterTable.addedMass + DFS.cargoMasses[DFS.supplyType.MORTAR_SQUAD]
                trigger.action.setUnitInternalCargo(pickupUnit:getName(), transporterTable.addedMass)
                if transporterTable.cargo.manifest == nil then
                    transporterTable.cargo.manifest = {}
                end
                table.insert(transporterTable.cargo.manifest, DFS.supplyType.MORTAR_SQUAD)
                missionCommands.addCommandForGroup(pickupGroup:getID(), "Drop " .. DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD], transporterTable.troopsMenu, cargo.unloadInternalCargo, {groupName = groupName, type = DFS.supplyType.MORTAR_SQUAD, country = pickupUnit:getCountry(), seaPickup = false, frontPickup = false, groupId = pickupGroup:getID(), coalition = coalitionId, removeCommand = "Drop " .. DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD], ammo = closestBase.contents.ammo})
                trigger.action.outTextForGroup(pickupGroup:getID(), "Loaded " .. DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD],5, false)
                Firebases.destroyFirebase(closestBase)
            else
                trigger.action.outTextForGroup(pickupGroup:getID(), "You do not have enough space to load a mortar squad!", 5, false)
            end
        end
    end
end
--type, groupName
function cargo.spawnSupply(param)
    local transporterGroup = Group.getByName(param.groupName)
    if transporterGroup then
        local transporterUnit = transporterGroup:getUnit(1)
        local transporterCoalition = transporterUnit:getCoalition()
        if transporterUnit then
            local pickupLocation = transporterUnit:getPoint()
            local pickUpZone = cargo.findPickupZone(pickupLocation, transporterCoalition)
            if pickUpZone then
                local frontPickup = string.find(pickUpZone, "FrontDepot")
                local piratePickup = string.find(pickUpZone, 'Pirate')
                local canSpawnCargo = cargo.canSpawnCargo(param.type, transporterCoalition, frontPickup, param.modifier, piratePickup)
                local seaPickup = string.find(pickUpZone, 'Sea')
                if seaPickup or canSpawnCargo then
                    local cargo = cargo.spawnStatic(param.type, trigger.misc.getZone(pickUpZone).point, transporterUnit:getCountry(), param.modifier)
                    if piratePickup then
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        DFS.decreasePirateSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                    elseif not seaPickup and not frontPickup then
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        DFS.decreaseRearSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                    elseif frontPickup then
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        DFS.decreaseFrontSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                    end
                    --env.info("Tracking cargo: " .. cargo:getName(), false)
                    cargo.trackCargo({coalition = transporterCoalition, cargo = cargo, supplyType = param.type, spawnTime = timer:getTime(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), isSlung = true, modifier = param.modifier, groupName = param.groupName, successfulDeployChecks = 0})
                else
                    trigger.action.outTextForGroup(transporterGroup:getID(), "This depot does not have enough " .. DFS.supplyNames[param.type].. " to create a crate!", 5, false)
                    if frontPickup  then
                        trigger.action.outTextForGroup(transporterGroup:getID(), "Front depots only allow pickup for ammo and artillery.", 10, false)
                    end
                end
            else
                trigger.action.outTextForGroup(transporterGroup:getID(), "You are not close enough to a supply pickup location!", 5, false)
            end
        end
    end
end
--type, groupName
function cargo.loadInternalCargo(param)
    local transporterGroup = Group.getByName(param.groupName)
    if transporterGroup then
        local transporterUnit = transporterGroup:getUnit(1)
        local transporterCoalition = transporterUnit:getCoalition()
        local transporterTable = DFS.helos[param.groupName]
        if transporterUnit and transporterTable then
            if transporterTable.cargo.volumeUsed + DFS.cargoVolumes[param.type] <= DFS.heloCapacities[transporterUnit:getTypeName()].volume and DFS.heloCapacities[transporterUnit:getTypeName()].types[DFS.supplyNames[param.type]] and cargo.canLoad(transporterCoalition, transporterUnit, param.type == DFS.supplyType.MORTAR_SQUAD) then
                local pickupLocation = transporterUnit:getPoint()
                local pickUpZone = cargo.findPickupZone(pickupLocation, transporterCoalition)
                if pickUpZone then
                    local frontPickup = string.find(pickUpZone, "FrontDepot")
                    local piratePickup = string.find(pickUpZone, 'Pirate')
                    local canSpawnCargo = cargo.canSpawnCargo(param.type, transporterCoalition, frontPickup, param.modifier, piratePickup)
                    local seaPickup = string.find(pickUpZone, 'Sea')
                    if seaPickup or canSpawnCargo then
                        transporterTable.cargo.cargoType = param.type
                        transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed + DFS.cargoVolumes[param.type] --todo: make table for volume lookup
                        transporterTable.addedMass = transporterTable.addedMass + DFS.cargoMasses[param.type]
                        trigger.action.setUnitInternalCargo(transporterUnit:getName(), transporterTable.addedMass)
                        if transporterTable.cargo.manifest == nil then
                            transporterTable.cargo.manifest = {}
                        end
                        table.insert(transporterTable.cargo.manifest, param.type)
                        local menuForDrop = transporterTable.dropMenu
                        if cargo.isTroops(param.type) then menuForDrop = transporterTable.troopsMenu end
                        if param.type == DFS.supplyType.SF then
                            missionCommands.addCommandForGroup(transporterGroup:getID(), "Begin Fast Rope (60s)", {}, FR.ropeLoop, {groupName = param.groupName, startTime = 0})
                        end
                        missionCommands.addCommandForGroup(transporterGroup:getID(), "Drop " .. DFS.supplyNames[param.type], menuForDrop, cargo.unloadInternalCargo, {point = {x = pickupLocation.x + 6, y = pickupLocation.y, z = pickupLocation.z + 6}, groupName = param.groupName, type = param.type, country = transporterUnit:getCountry(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), coalition = transporterCoalition, removeCommand = "Drop " .. DFS.supplyNames[param.type]})
                        if transporterTable.cargo.carrying == false then
                            missionCommands.addCommandForGroup(transporterGroup:getID(), "Unload All", transporterTable.dropMenu, cargo.unloadInternalCargo, {point = {x = pickupLocation.x + 6, y = pickupLocation.y, z = pickupLocation.z + 6}, groupName = param.groupName, type = "ALL", country = transporterUnit:getCountry(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), coalition = transporterCoalition, removeCommand = "Unload All"})
                        else
                            missionCommands.removeItemForGroup(transporterGroup:getID(), {[1] = "Cargo/Troop Transport", [2] = "Internal Cargo", [3] = "Unload All"})
                            missionCommands.addCommandForGroup(transporterGroup:getID(), "Unload All", transporterTable.dropMenu, cargo.unloadInternalCargo, {point = {x = pickupLocation.x + 6, y = pickupLocation.y, z = pickupLocation.z + 6}, groupName = param.groupName, type = "ALL", country = transporterUnit:getCountry(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), coalition = transporterCoalition, removeCommand = "Unload All"})
                        end
                        transporterTable.cargo.carrying = true
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        if cargo.isTroops(param.type) then decreaseType = DFS.supplyType.EQUIPMENT end
                        if piratePickup then
                            DFS.decreasePirateSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                        elseif not seaPickup and not frontPickup then
                            DFS.decreaseRearSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                        elseif frontPickup then
                            DFS.decreaseFrontSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                        end
                        trigger.action.outTextForGroup(transporterGroup:getID(), "Loaded " .. DFS.supplyNames[param.type],5, false)
                    else
                        trigger.action.outTextForGroup(transporterGroup:getID(), "This depot does not have enough " .. DFS.supplyNames[param.type].. " to create a crate!", 5, false)
                        if frontPickup  then
                            trigger.action.outTextForGroup(transporterGroup:getID(), "Front depots only allow pickup for ammo and artillery.", 10, false)
                        end
                    end
                else
                    if param.type == DFS.supplyType.MORTAR_SQUAD then
                        local closestFbIdx = Firebases.getClosestFirebase(pickupLocation, transporterCoalition)
                        if Firebases[closestFbIdx].fbType == "MORTAR" then
                            local closestFb = Firebases[closestFbIdx]
                            if Utils.PointDistance(pickupLocation, closestFb.positions.location) < 200 then
                                if #closestFb.contents.groups > 0 then
                                    cargo.reloadMortarBase(transporterGroup:getName(), closestFbIdx, transporterCoalition)
                                else
                                     trigger.action.outTextForGroup(transporterGroup:getID(), "This base has no units to load!", 5, false)
                                end
                            else
                                trigger.action.outTextForGroup(transporterGroup:getID(), "No mortar team in range to pick up!", 5, false)
                            end
                        end
                    else
                        trigger.action.outTextForGroup(transporterGroup:getID(), "You are not close enough to a pickup zone to load cargo!", 5, false)
                    end
                end
            elseif DFS.heloCapacities[transporterUnit:getTypeName()].types[DFS.supplyNames[param.type]] == nil then
                trigger.action.outTextForGroup(transporterGroup:getID(), "This helicopter cannot carry " .. DFS.supplyNames[param.type].." internally!", 5, false)
            elseif transporterTable.cargo.volumeUsed + DFS.cargoVolumes[param.type] > DFS.heloCapacities[transporterUnit:getTypeName()].volume then
                trigger.action.outTextForGroup(transporterGroup:getID(), "Cannot fit any more internal cargo!", 5, false)
            end
        end
    end
end
function cargo.unloadInternalCargo(param)
    local transporterGroup = Group.getByName(param.groupName)
    if transporterGroup then
        local transporterUnit = transporterGroup:getUnit(1)
        if cargo.landed(param.groupName) and transporterUnit and transporterUnit:getPoint() then
            local unloadPoint = transporterUnit:getPoint()
            unloadPoint.x = unloadPoint.x + 8
            unloadPoint.z = unloadPoint.z + 9
            local transporterTable = DFS.helos[param.groupName]
            if param.type == "ALL" then
                local manifestCopy = Utils.deepcopy(transporterTable.cargo.manifest)
                for i = 1, #manifestCopy do
                    if not cargo.isTroops(manifestCopy[i]) then
                        cargo.unloadInternalCargo({groupName = param.groupName, type = manifestCopy[i], country = transporterUnit:getCountry(), seaPickup = param.seaPickup, frontPickup = param.frontPickup, groupId = transporterGroup:getID(), coalition = param.coalition, removeCommand = "Drop " ..  DFS.supplyNames[manifestCopy[i]]})
                    end
                end
                missionCommands.removeItemForGroup(param.groupId, {[1] = "Cargo/Troop Transport", [2] = "Internal Cargo", [3] = param.removeCommand})
            else
                transporterTable.cargo.volumeUsed = transporterTable.cargo.volumeUsed - DFS.cargoVolumes[param.type]
                for i = 1, #transporterTable.cargo.manifest do
                    if transporterTable.cargo.manifest[i] == param.type then
                        table.remove(transporterTable.cargo.manifest, i)
                        break
                    end
                end
                if transporterTable.cargo.volumeUsed < 0 then transporterTable.cargo.volumeUsed = 0 end
                transporterTable.addedMass = transporterTable.addedMass - DFS.cargoMasses[param.type]
                if transporterTable.addedMass < 0 then transporterTable.addedMass = 0 end
                trigger.action.setUnitInternalCargo(transporterUnit:getName(), transporterTable.addedMass)
                if cargo.isTroops(param.type) then
                    cargo.troopUnload(param.groupName, param.type, param.ammo)
                else
                    local cargo = cargo.spawnStatic(param.type, unloadPoint, param.country, "small")
                    cargo.trackCargo({coalition = param.coalition, cargo = cargo, supplyType = param.type, spawnTime = timer:getTime(), seaPickup = param.seaPickup, frontPickup = param.frontPickup, groupId = param.groupId, isSlung = nil, modifier = "small", groupName = param.groupName, successfulDeployChecks = 0})
                end
                local secondLevel = "Internal Cargo"
                if cargo.isTroops(param.type) then
                    secondLevel = "Troop Transportation"
                end
                missionCommands.removeItemForGroup(param.groupId, {[1] = "Cargo/Troop Transport", [2] = secondLevel, [3] = param.removeCommand})
            end
        end
    end
end
function cargo.isTroops(supplyType)
    return DFS.troopSupplyTypes[supplyType]
end
function cargo.internalCargoStatus(groupName)
    local statusGroup = Group.getByName(groupName)
    if statusGroup then
        local groupId = statusGroup:getID()
        local cargoTable = DFS.helos[groupName]
        if cargoTable then
            trigger.action.outTextForGroup(groupId, "Carrying " .. cargoTable.addedMass .. " kg\nUsing " .. math.floor((cargoTable.cargo.volumeUsed/DFS.heloCapacities[cargoTable.typeName].volume)*100) .."% capacity", 15, false)
        else
            --trigger.action.outTextForGroup(groupId, "This should not happen. Ping EatLeadCobra on the WWX discord please", 30)
        end
    end
end
function DFS.troopUnloadExternal(droppingGroupName, troopType, ammo)
    cargo.troopUnload(droppingGroupName, troopType, ammo)
end
function cargo.troopUnload(droppingGroupName, troopType, ammo)
    local droppingGroup = Group.getByName(droppingGroupName)
    if droppingGroup then
        local droppingUnit = droppingGroup:getUnit(1)
        if droppingUnit then
            local droppingPos = droppingUnit:getPosition()
            local droppingPoint = droppingUnit:getPoint()
            if droppingPos and droppingPoint then
                local droppingPlayerName  = droppingUnit:getPlayerName()
                local heading = math.atan2(droppingPos.x.z, droppingPos.x.x)
                if heading < 0 then heading = heading + (2 * math.pi) end
                local closestDepot = cargo.findClosestDepot(droppingPoint, droppingGroup:getCoalition())
                local pickupZone = cargo.findPickupZone(droppingPoint, droppingGroup:getCoalition())
                if closestDepot and closestDepot.distance < 300 or pickupZone then
                    trigger.action.outTextForGroup(droppingGroup:getID(), "Troops returned.", 6, false)
                    local piratePickup = false
                    if pickupZone and string.find(pickupZone, 'Pirate') then
                        piratePickup = true
                    end
                    local deliverRearDepot = false
                    if closestDepot and closestDepot.isRear then
                        deliverRearDepot = true
                    end
                    cargo.deliverToDepot(deliverRearDepot, droppingGroup:getCoalition(), DFS.supplyType.SF, "small", piratePickup)
                else
                    if troopType == DFS.supplyType.MORTAR_SQUAD then
                        Firebases.deploy(droppingGroupName, "MORTAR", ammo)
                    elseif troopType == DFS.supplyType.SF then
                        local isWater = land.getSurfaceType({x = droppingPoint.x, y = droppingPoint.z})
                        if isWater == 2 or isWater == 3 then
                            local spawnPoints = {}
                            spawnPoints[1] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, -0.9), 11))
                            spawnPoints[2] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, -0.7), 10))
                            spawnPoints[3] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, 0.6), 10))
                            spawnPoints[4] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, 0.9), 11))
                            local groups = {
                                [1] = {type = "m249", point = spawnPoints[1]},
                                [2] = {type = "m249", point = spawnPoints[2]},
                                [3] = {type = "m249", point = spawnPoints[3]},
                                [4] = {type = "m249", point = spawnPoints[4]},
                                
                            }
                            local sfGroup = FirebaseGroups.spawnCustomGroup(droppingPoint, groups, droppingGroup:getCoalition(), heading)
                            cargo.hvbss(sfGroup, droppingPoint, droppingGroup:getCoalition(), droppingGroup:getID(), droppingPlayerName)
                        else
                            local spawnPoints = {}
                            spawnPoints[1] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, -0.9), 11))
                            spawnPoints[2] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, -0.7), 10))
                            spawnPoints[3] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, 0.6), 10))
                            local groups = {
                                [1] = {type = "m249", point = spawnPoints[1]},
                                [2] = {type = "m249", point = spawnPoints[2]},
                                [3] = {type = "rpg", point = spawnPoints[3]},
                            }
                            local sfGroup = FirebaseGroups.spawnCustomGroup(droppingPoint, groups, droppingGroup:getCoalition(), heading)
                            Group.getByName(sfGroup):getController():setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)
                        end
                    elseif troopType == "TRUCK" then
                        local spawnPoints = {}
                        spawnPoints[1] = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(Utils.RotateVector(droppingPos.x, -0.9), 11))
                        local groups = {
                            [1] = {type = "TRUCK", point = spawnPoints[1]},
                        }
                        local truckGroup = FirebaseGroups.spawnCustomGroup(droppingPoint, groups, droppingGroup:getCoalition(), heading)
                        timer.scheduleFunction(cargo.destroyGroup, truckGroup, timer:getTime() + 135)
                    elseif troopType ==  DFS.supplyType.CE then
                        local minePoint = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(droppingPos.x, 15))
                        Mine.spawnPublic(minePoint, droppingPos)
                    end
                end
            end
        end
    end
end
--type, groupName
function cargo.canLoad(coalition, unit, isMortar)
    local canLoad = false
    local unitPoint = unit:getPoint()
    local unitVelo = unit:getVelocity()
    if unitPoint and unitVelo then
        local pickUpZone = cargo.findPickupZone(unitPoint, coalition)
        if (pickUpZone and cargo.landed(unit:getGroup():getName())) or (isMortar and cargo.landed(unit:getGroup():getName())) then
            canLoad = true
        elseif pickUpZone == nil and isMortar == false then
            trigger.action.outTextForGroup(unit:getGroup():getID(), "You are not close enough to a pick up zone to load cargo!", 5, false)
        end
    end
    return canLoad
end
function cargo.landed(groupName)
    local landed = false
    local loadingGroup = Group.getByName(groupName)
    if loadingGroup then
        local loadingUnit = loadingGroup:getUnit(1)
        if loadingUnit then
            local velocity = loadingUnit:getVelocity()
            if velocity.x < 0.5 and velocity.z < 0.5 and velocity.y < 0.5 and cargo.getAGL(loadingUnit:getPoint()) <= 5  or not loadingUnit:inAir() then
                landed = true
            else
                trigger.action.outTextForGroup(loadingGroup:getID(), "Cannot load/unload cargo while moving!", 10, false)
            end
        end
    end
    return landed
end
function cargo.hvbss(boardingGroupName, dropPoint, boardingCoalition, droppingGroupID, droppingPlayerName)
    local boardingGroup = Group.getByName(boardingGroupName)
    if boardingGroup then
        local isOnShip = false
        for i = 1, boardingGroup:getSize() do
            local unit = boardingGroup:getUnit(i)
            if unit then
                if (unit:getPoint().y > 0) then
                    isOnShip = true
                end
            end
        end
        if isOnShip then
            local volS = {
                id = world.VolumeType.SPHERE,
                params = {
                    point = dropPoint,
                    radius = 200
                }
            }
            local closestShip = {}
            local ifFound = function(foundItem, val)
                if foundItem:isExist() and foundItem:isActive() and foundItem:getDesc().category == 3 and foundItem:getCoalition() ~= boardingCoalition and DFS.raidedShips[foundItem:getGroup():getName()] == nil then
                    local shipPoint = foundItem:getPoint()
                    local shipPos = foundItem:getPosition()
                    env.info("HVBSS Found: " .. foundItem:getName(), false)
                    if shipPoint and shipPos then
                        local xDistance = math.abs(dropPoint.x - shipPoint.x)
                        local yDistance = math.abs(dropPoint.z - shipPoint.z)
                        local distance = math.sqrt(xDistance*xDistance + yDistance*yDistance)
                        if distance ~= nil then
                            if closestShip.distance == nil or distance < closestShip.distance then
                                closestShip.distance = distance
                                closestShip.point = shipPoint
                                closestShip.coalition = foundItem:getCoalition()
                                closestShip.groupName = foundItem:getGroup():getName()
                            end
                        end
                    end
                end
            end
            world.searchObjects(Object.Category.UNIT, volS, ifFound)
            if closestShip.distance ~= nil and closestShip.point ~= nil then
                local foundShip = Group.getByName(closestShip.groupName)
                if foundShip then
                    DFS.raidedShips[closestShip.groupName] = 1
                    foundShip:getController():setOnOff(false)
                    timer.scheduleFunction(cargo.startBoat, closestShip.groupName, timer:getTime()+305)
                    trigger.action.outTextForGroup(droppingGroupID, "Marines are securing ship and cargo!\nShip will be rigged to explode in 5 minutes", 30, false)
                    timer.scheduleFunction(cargo.destroyGroup, boardingGroupName, timer:getTime()+125)
                    timer.scheduleFunction(DFS.cargoBoat, {shipName = closestShip.groupName, boardingCoalition = boardingCoalition, boardingGroupName = boardingGroupName, boardingPlayerName = droppingPlayerName}, timer:getTime()+120)
                end
            end
        end
    end
end