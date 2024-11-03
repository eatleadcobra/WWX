local sunsetNotified = false
DFS = {}
DFS.supplyType = {
    FUEL = 1,
    AMMO = 2,
    EQUIPMENT = 3,
    GUN = 4,
    MORTAR_SQUAD = 5,
    SF = 6,
    CE = 7,
}
DFS.resupplyTypes = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 3,
    [5] = 3,
    [6] = 3,
    [7] = 3,
}
DFS.troopSupplyTypes = {
    [5] = true,
    [6] = true,
    [7] = true,
}
DFS.slungResupModifier = 2
DFS.supplyNames = {
    [1] = "Fuel",
    [2] = "Ammo",
    [3] = "Equipment",
    [4] = "Equipment",
    [5] = "Mortar Squad",
    [6] = "Special Forces",
    [7] = "Combat Engineers (Landmines)"
}
DFS.cargoMasses = {
    [1] = 900,
    [2] = 500,
    [3] = 600,
    [5] = 1000,
    [6] = 500,
    [7] = 400,
}
DFS.cargoVolumes = {
    [1] = 5,
    [2] = 5,
    [3] = 5,
    [5] = 10,
    [6] = 5,
    [7] = 2,
}
DFS.internalCargo = {

}
DFS.heloCapacities = {
    ["AV8BNA"] = {
        types = {
            ["Fuel"] = 1,
            ["Ammo"] = 2,
            ["Equipment"] = 3,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 5,
    },
    ["Mi-8MT"] = {
        types = {
            ["Fuel"] = 1,
            ["Ammo"] = 2,
            ["Equipment"] = 3,
            ["Mortar Squad"] = 5,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 20,
        seats = 24
    },
    ["Mi-24P"] = {
        types = {
            ["Fuel"] = 1,
            ["Ammo"] = 2,
            ["Equipment"] = 3,
            ["Mortar Squad"] = 5,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 10,
        seats = 8
    },
    ["UH-1H"] = {
        types = {
            ["Fuel"] = 1,
            ["Ammo"] = 2,
            ["Equipment"] = 3,
            ["Mortar Squad"] = 5,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 15,
        seats = 14
    },
    ["SA342L"] = {
        types = {
            ["Fuel"] = 1,
            ["Ammo"] = 2,
            ["Equipment"] = 3,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 5,
        seats = 2
    },
    ["SA342Minigun"] = {
        types = {
            ["Fuel"] = 1,
            ["Ammo"] = 2,
            ["Equipment"] = 3,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 5,
        seats = 2
    },
    ["CH-47Fbl1"] = {
        types = {
            -- ["Fuel"] = 1,
            -- ["Ammo"] = 2,
            -- ["Equipment"] = 3,
            ["Mortar Squad"] = 5,
            ["Special Forces"] = 6,
            ["Combat Engineers (Landmines)"] = 7,
        },
        volume = 30,
        seats = 30
    },
}
DFS.helos = {
    ["example"] = {
        id = 1,
        typeName = nil,
        addedMass = 0,
        cargo = {
            carrying = false,
            volumeUsed = 0,
            manifest = {},
        }
    }
}
DFS.raidedShips = {

}
DFS.supplyDrawing = {
    counterWidth = 1800,
    counterHeight = 7200,
    counterOffeset = 2400,
    colors = {
        fill = {
            [1] = {1,0,0,1},
            [2] = {0,0,1,1},
        }
    },
    fillIds = {
        front = {
            [1] = {},
            [2] = {},
        },
        rear = {
            [1] = {},
            [2] = {},
        },
        pirate = {
            [1] = {},
            [2] = {},
        },
        healthbars = {
            [1] = -1,
            [2] = -1,
        }
    }
}
DFS.templates = {
    [1] = {
        ["big"] = {
            ["mass"] = 1800,
            ["heading"] = 0,
            ["shape_name"] = "fueltank_cargo",
            ["canCargo"] = true,
            ["type"] = "fueltank_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
        ["small"] = {
            ["mass"] = 900,
            ["heading"] = 0,
            ["shape_name"] = "barrels_cargo",
            ["canCargo"] = true,
            ["type"] = "barrels_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        }
    },
    [2] = {
        ["big"] = {
            ["mass"] = 1000,
            ["heading"] = 0,
            ["shape_name"] = "ammo_box_cargo",
            ["canCargo"] = true,
            ["type"] = "ammo_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
        ["small"] = {
            ["mass"] = 500,
            ["heading"] = 0,
            ["shape_name"] = "m117_cargo",
            ["canCargo"] = true,
            ["type"] = "m117_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
    },
    [3] = {
        ["big"] = {
            ["mass"] = 1200,
            ["heading"] = 0,
            ["shape_name"] = "iso_container_small_cargo",
            ["canCargo"] = true,
            ["type"] = "iso_container_small",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
        ["small"] = {
            ["mass"] = 600,
            ["heading"] = 0,
            ["shape_name"] = "ab-212_cargo",
            ["canCargo"] = true,
            ["type"] = "uh1h_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
    },
    [4] = {
        ["big"] = {
            ["mass"] = 1800,
            ["heading"] = 0,
            ["shape_name"] = "bw_container_cargo",
            ["canCargo"] = true,
            ["type"] = "container_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
        ["small"] = {
            ["mass"] = 1800,
            ["heading"] = 0,
            ["shape_name"] = "bw_container_cargo",
            ["canCargo"] = true,
            ["type"] = "container_cargo",
            ["name"] = "",
            ["category"] = "Cargos",
            ["y"] = 0,
            ["x"] = 0,
        },
    },
}
DFS.groupNames = {
    [1] = {
        frontline = {
            [1] = 'Red-Frontline-1',
            [2] = 'Red-Frontline-2',
            [3] = 'Red-Frontline-3',
            [4] = 'Red-Frontline-4',
        },
        artillery = "Red-Art",
        battleship = "Red-Battleship",
        depot = "Red-Depot",
        aa = "Red-AA",
        strike = "Red-Strike",
        ambush = "Red-Ambush",
        convoy = {
            [1] = "Red-Fuel-Convoy-",
            [2] = "Red-Ammo-Convoy-",
            [3] = "Red-Equipment-Convoy-",
        },
    },
    [2] = {
        frontline = {
            [1] = 'Blue-Frontline-1',
            [2] = 'Blue-Frontline-2',
            [3] = 'Blue-Frontline-3',
            [4] = 'Blue-Frontline-4',
        },
        artillery = "Blue-Art",
        battleship = "Blue-Battleship",
        depot = "Blue-Depot",
        aa = "Blue-AA",
        strike = "Blue-Strike",
        ambush = "Blue-Ambush",
        convoy = {
            [1] = "Blue-Fuel-Convoy-",
            [2] = "Blue-Ammo-Convoy-",
            [3] = "Blue-Equipment-Convoy-",
        },
    }
}
DFS.spawnNames = {
    [1] = {
        frontline = "RedSpawn-Front-",
        artillery = "RedSpawn-Art-",
        depot = "Red-FrontDepot-",
        reardepot = "Red-RearDepot-",
        aa = "Red-AA-",
        convoy = "Red-Convoy-",
        pirate = "RedPirateShip",
        deliver = 'Red-Front-Deliver-',
        frontSupplyDrawing = "Red-FrontCounter",
        rearSupplyDrawing = "Red-RearCounter",
        pirateSupplyDrawing = "Red-PirateCounter",
        healthbar = "Red-Healthbar",
    },
    [2] = {
        frontline = "BlueSpawn-Front-",
        artillery = "BlueSpawn-Art-",
        depot = "Blue-FrontDepot-",
        reardepot = "Blue-RearDepot-",
        aa = "Blue-AA-",
        convoy = "Blue-Convoy-",
        pirate = "BluePirateShip",
        deliver = 'Blue-Front-Deliver-',
        frontSupplyDrawing = "Blue-FrontCounter",
        rearSupplyDrawing = "Blue-RearCounter",
        pirateSupplyDrawing = "Blue-PirateCounter",
        healthbar = "Blue-Healthbar",
    }
}
DFS.pickUpZones = {
    [1] = {
        [1] = "Red-Pickup-RD",
        [2] = "Red-Pickup-Sea",
        [3] = "RedPiratePickup",
        [4] = "Red-FrontDepot-1",
        [5] = "Red-FrontDepot-2",
        [6] = "Red-FrontDepot-3",
        [7] = "Red-FrontDepot-4",
    },
    [2] = {
        [1] = "Blue-Pickup-RD",
        [2] = "Blue-Pickup-Sea",
        [3] = "BluePiratePickup",
        [4] = "Blue-FrontDepot-1",
        [5] = "Blue-FrontDepot-2",
        [6] = "Blue-FrontDepot-3",
        [7] = "Blue-FrontDepot-4",
    }
}
DFS.status = {
    maxHealth = 250,
    --bombers
    bomberInterval = 1800,
    fighterInterval = 599,
    bomberCoalition = 1,
    bomberTarget = 1,
    --nfs
    noFlyRadius = 4000,
    --artillery
    artilleryRadius = 350,
    artilleryQty = 10,
    validArtRange = 25000,
    validBombardmentRange = 70000,
    --delays and intervals
    upgradeInterval = 900,
    gunInterval = 10799,
    shellsInterval = 2699,
    frontSpawnDelay = 180,
    aaSpawnDelay = 2700,
    artSpawnDelay = 1200,
    battleshipSpawnDelay = 2399,
    fdSpawnDelay = 5399,
    rdSpawnDelay = 5399,
    convoyBaseTime = 3299,
    convoySeparationTime = 89,
    newConvoySeparationTime = 359,
    shipConvoyInterval = 1799,
    submarineInterval = 2399,
    submarineMaxDelayLim = 900,
    submarinePlayerCountReduction = 540,
    submarineMinTime = 600,
    subLifeTime = 7199,
    --resupply amts
    convoyResupplyAmts = {
        [1] = 30,
        [2] = 80,
        [3] = 12,
    },
    shippingResupplyAmts = {
        [1] = 90,
        [2] = 240,
        [3] = 36,
    },
    playerResupplyAmts = {
        [1] = {
            big = 20,
            small = 4
        },
        [2] = {
            big = 80,
            small = 20
        },
        [3] = {
            big = 6,
            small = 2
        },
        [4] = {
            big = 3,
            small = 3
        },
        [5] = {
            big = 5,
            small = 5
        },
        [6] = {
            big = 2,
            small = 2
        },
        [7] = {
            big = 0,
            small = 0
        }
    },
    --totals
    maxSuppliesFront = {
        [1] = 60,
        [2] = 160,
        [3] = 24,
    },
    maxSuppliesRear = {
        [1] = 180,
        [2] = 480,
        [3] = 72,
    },
    maxSuppliesPirate = {
        [1] = 80,
        [2] = 180,
        [3] = 36,
    },
    frontSpawnTotal = 12,
    artSpawnTotal = 4,
    fdSpawnTotal = 4,
    rdSpawnTotal = 1,
    rdSpawnSubDepots = 2,
    aaSpawnTotal = 8,
    pickupDistance = 1000,
    cargoId = 1020,
    cargoExpireTime = 7200,
    playerDeliverRadius = 499,
    --costs
    frontBaseCost = 5,
    artCost = 10,
    aaCost = 10,
    depotCost = 20,
    assignedArtGroups = {},
    targetMarks = {},
    bombardmentMarks = {},
    bombingMarks = {},
    [1] = {
        health = 0,
        front = {},
        anyConvoyTime = 0,
        lastGunTime = 0,
        lastShellsTime = 0,
        lastFighterTime = 0,
        lastConvoyTimes = {
            [1] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            [2] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            [3] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            [4] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
        },
        industrialModifier = 1,
        lastShipTime = 0,
        supply = {
            -- 0 - 100
            front = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            rear = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            pirate = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
        },
        spawns = {
            -- groupname + zone number 
            front = {},
            artillery = {},
            battleships = {},
            fd = {},
            rd = {},
            aa = {},
        },
        casCounter = 0,
    },
    [2] = {
        health = 0,
        front = {},
        anyConvoyTime = 0,
        lastGunTime = 0,
        lastShellsTime = 0,
        lastConvoyTimes = {
            [1] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            [2] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            [3] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            [4] = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
        },
        lastShipTime = 0,
        industrialModifier = 1,
        supply = {
            -- 0 - 100
            front = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            rear = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
            pirate = {
                [1] = 0,
                [2] = 0,
                [3] = 0
            },
        },
        spawns = {
            -- groupname + zone number 
            front = {},
            artillery = {},
            battleships = {},
            fd = {},
            rd = {},
            aa = {},
        },
        casCounter = 0,
    }
}
DfcMissionEnd = false
local dfc = {}
local debug = false
local missionOver = false
local blueState = lfs.writedir() .. [[Logs/]] .. 'blueState.txt'
local redState = lfs.writedir() .. [[Logs/]] ..'redState.txt'
local redFront = lfs.writedir() .. [[Logs/]] .. 'redFront.txt'
local blueFront = lfs.writedir() .. [[Logs/]] .. 'blueFront.txt'
local redFbs = lfs.writedir() .. [[Logs/Firebases/]] .. 'redFbs.txt'
local blueFbs = lfs.writedir() .. [[Logs/Firebases/]] .. 'blueFbs.txt'
local mapState = lfs.writedir() .. [[Logs/]] ..'mapState.txt'
--Global event listener
local dfcEvents = {}
function dfcEvents:onEvent(event)
    --on kill
    if (event.id == world.event.S_EVENT_KILL) then
        if event and event.initiator and event.target then
            if event.target:getTypeName() == "santafe" and event.initiator.getPlayerName then
                local playerName = event.initiator:getPlayerName()
                if playerName and WWEvents then
                    env.info("sub kill event fired", false)
                    WWEvents.playerDestroyedSubmarine(playerName, event.initiator:getCoalition(), "killed a submarine!")
                end
            end
        end
    end
    --on birth
    if (event.id == world.event.S_EVENT_BIRTH) then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group then
                dfc.addRadioCommandsForGroup(event.initiator:getGroup():getName())
                if DFS.heloCapacities[event.initiator:getTypeName()] then
                    local dropMenu, troopsMenu = dfc.addRadioCommandsForCargoGroup(event.initiator:getGroup():getName())
                    dfc.addGroupToCargoList(event.initiator:getGroup():getName(), dropMenu, troopsMenu)
                end
            end
        end
    end
    --on slot out
    if (event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT) then
        if event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local ID = group:getID()
                if ID ~= nil then
                    missionCommands.removeItemForGroup(ID, nil)
                    if Sonobuoys then Sonobuoys.removeRadioCommandsForGroup(ID) end
                    if MAD then MAD.removeRadioCommandsForGroup(ID) end
                    if CSB then CSB.removeCsarRadioCommandsForGroup(ID) end
                end
            end
        end
    end
    --on death
    if event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_EJECTION then
        if  event.initiator and event.initiator.getGroup then
            local group = event.initiator:getGroup()
            if group ~= nil then
                local ID = group:getID()
                if ID ~= nil then
                    missionCommands.removeItemForGroup(ID, nil)
                    if Sonobuoys then Sonobuoys.removeRadioCommandsForGroup(ID) end
                    if MAD then MAD.removeRadioCommandsForGroup(ID) end
                    if CSB then CSB.removeCsarRadioCommandsForGroup(ID) end
                end
            end
        end
    end
end
function dfc.getMission()
    local missionName = env.mission["date"]["Year"]
    if missionName ~= nil then
        blueState = lfs.writedir() .. [[Logs/]] .. 'blueState'..missionName..'.txt'
        redState = lfs.writedir() .. [[Logs/]] ..'redState'..missionName..'.txt'
        redFront = lfs.writedir() .. [[Logs/]] .. 'redFront'..missionName..'.txt'
        blueFront = lfs.writedir() .. [[Logs/]] .. 'blueFront'..missionName..'.txt'
        redFbs = lfs.writedir() .. [[Logs/Firebases/]] .. 'redFbs'..missionName..'.lua'
        blueFbs = lfs.writedir() .. [[Logs/Firebases/]] .. 'blueFbs'..missionName..'.lua'
    end
end
function dfc.fileExists(file)
    local f = io.open(file, 'rb')
    if f then f:close() end
    return f ~= nil
end
function dfc.getData()
    if dfc.fileExists(blueFbs) == false or dfc.fileExists(redFbs) == false then
        lfs.mkdir(lfs.writedir() .. [[Logs/Firebases/]])
    end
    if dfc.fileExists(redState) and dfc.fileExists(blueState) then
        local f = io.open(redState, 'r')
        if f ~= nil then
            local lines = {}
            for line in io.lines(f) do
                lines[#lines+1] = line
            end
            DFS.status[1].health = tonumber(lines[1])
            DFS.status[1].supply.front[DFS.supplyType.FUEL] = tonumber(lines[2])
            DFS.status[1].supply.front[DFS.supplyType.AMMO] = tonumber(lines[3])
            DFS.status[1].supply.front[DFS.supplyType.EQUIPMENT] = tonumber(lines[4])
            DFS.status[1].supply.rear[DFS.supplyType.FUEL] = tonumber(lines[5])
            DFS.status[1].supply.rear[DFS.supplyType.AMMO] = tonumber(lines[6])
            DFS.status[1].supply.rear[DFS.supplyType.EQUIPMENT] = tonumber(lines[7])
            DFS.status[1].supply.pirate[DFS.supplyType.FUEL] = tonumber(lines[8])
            DFS.status[1].supply.pirate[DFS.supplyType.AMMO] = tonumber(lines[9])
            DFS.status[1].supply.pirate[DFS.supplyType.EQUIPMENT] = tonumber(lines[10])
            f:close()
        end
        f = io.open(blueState, 'r')
        if f ~= nil then
            local lines = {}
            for line in io.lines(f) do
                lines[#lines+1] = line
            end
            DFS.status[2].health = tonumber(lines[1])
            DFS.status[2].supply.front[DFS.supplyType.FUEL] = tonumber(lines[2])
            DFS.status[2].supply.front[DFS.supplyType.AMMO] = tonumber(lines[3])
            DFS.status[2].supply.front[DFS.supplyType.EQUIPMENT] = tonumber(lines[4])
            DFS.status[2].supply.rear[DFS.supplyType.FUEL] = tonumber(lines[5])
            DFS.status[2].supply.rear[DFS.supplyType.AMMO] = tonumber(lines[6])
            DFS.status[2].supply.rear[DFS.supplyType.EQUIPMENT] = tonumber(lines[7])
            DFS.status[2].supply.pirate[DFS.supplyType.FUEL] = tonumber(lines[8])
            DFS.status[2].supply.pirate[DFS.supplyType.AMMO] = tonumber(lines[9])
            DFS.status[2].supply.pirate[DFS.supplyType.EQUIPMENT] = tonumber(lines[10])
            f:close()
        end
    else
        dfc.initHealth()
        dfc.initSupply()
    end
    if dfc.fileExists(redFront) and dfc.fileExists(blueFront) then
        local f = io.open(redFront, 'w')
        if f ~= nil then
            local lines = {}
            for line in io.lines(f) do
                lines[#lines+1] = line
            end
            f:close()
            for i = 1, DFS.status.frontSpawnTotal do
                DFS.status[1].front[i] = tonumber(lines[i])
            end
        end
        f = io.open(blueFront, 'w')
        if f ~= nil then
            local lines = {}
            for line in io.lines(f) do
                lines[#lines+1] = line
            end
            f:close()
            for i = 1, DFS.status.frontSpawnTotal do
                DFS.status[2].front[i] = tonumber(lines[i])
            end
        end
    end
end
function dfc.saveLoop()
    dfc.saveData()
    timer.scheduleFunction(dfc.saveLoop, nil, timer.getTime() + 20)
end
function dfc.saveData()
    trigger.action.setUserFlag("RED_HEALTH", DFS.status[1].health)
    trigger.action.setUserFlag("RED_FRONT_FUEL", DFS.status[1].supply.front[DFS.supplyType.FUEL])
    trigger.action.setUserFlag("RED_FRONT_AMMO", DFS.status[1].supply.front[DFS.supplyType.AMMO])
    trigger.action.setUserFlag("RED_FRONT_EQUIPMENT", DFS.status[1].supply.front[DFS.supplyType.EQUIPMENT])
    trigger.action.setUserFlag("RED_REAR_FUEL", DFS.status[1].supply.rear[DFS.supplyType.FUEL])
    trigger.action.setUserFlag("RED_REAR_AMMO", DFS.status[1].supply.rear[DFS.supplyType.AMMO])
    trigger.action.setUserFlag("RED_REAR_EQUIPMENT", DFS.status[1].supply.rear[DFS.supplyType.EQUIPMENT])
    trigger.action.setUserFlag("RED_STOLEN_FUEL", DFS.status[1].supply.pirate[DFS.supplyType.FUEL])
    trigger.action.setUserFlag("RED_STOLEN_AMMO", DFS.status[1].supply.pirate[DFS.supplyType.AMMO])
    trigger.action.setUserFlag("RED_STOLEN_EQUIPMENT", DFS.status[1].supply.pirate[DFS.supplyType.EQUIPMENT])
    trigger.action.setUserFlag("BLUE_HEALTH", DFS.status[2].health)
    trigger.action.setUserFlag("BLUE_FRONT_FUEL", DFS.status[2].supply.front[DFS.supplyType.FUEL])
    trigger.action.setUserFlag("BLUE_FRONT_AMMO", DFS.status[2].supply.front[DFS.supplyType.AMMO])
    trigger.action.setUserFlag("BLUE_FRONT_EQUIPMENT", DFS.status[2].supply.front[DFS.supplyType.EQUIPMENT])
    trigger.action.setUserFlag("BLUE_REAR_FUEL", DFS.status[2].supply.rear[DFS.supplyType.FUEL])
    trigger.action.setUserFlag("BLUE_REAR_AMMO", DFS.status[2].supply.rear[DFS.supplyType.AMMO])
    trigger.action.setUserFlag("BLUE_REAR_EQUIPMENT", DFS.status[2].supply.rear[DFS.supplyType.EQUIPMENT])
    trigger.action.setUserFlag("BLUE_STOLEN_FUEL", DFS.status[2].supply.pirate[DFS.supplyType.FUEL])
    trigger.action.setUserFlag("BLUE_STOLEN_AMMO", DFS.status[2].supply.pirate[DFS.supplyType.AMMO])
    trigger.action.setUserFlag("BLUE_STOLEN_EQUIPMENT", DFS.status[2].supply.pirate[DFS.supplyType.EQUIPMENT])

    local f = io.open(redState, 'w')
    f:write(DFS.status[1].health..'\n'..
            DFS.status[1].supply.front[DFS.supplyType.FUEL]..'\n'..
            DFS.status[1].supply.front[DFS.supplyType.AMMO]..'\n'..
            DFS.status[1].supply.front[DFS.supplyType.EQUIPMENT]..'\n'..
            DFS.status[1].supply.rear[DFS.supplyType.FUEL]..'\n'..
            DFS.status[1].supply.rear[DFS.supplyType.AMMO]..'\n'..
            DFS.status[1].supply.rear[DFS.supplyType.EQUIPMENT]..'\n'..
            DFS.status[1].supply.pirate[DFS.supplyType.FUEL]..'\n'..
            DFS.status[1].supply.pirate[DFS.supplyType.AMMO]..'\n'..
            DFS.status[1].supply.pirate[DFS.supplyType.EQUIPMENT]..'\n'
    )
    f:close()
    f = io.open(blueState, 'w')
    f:write(DFS.status[2].health..'\n'..
            DFS.status[2].supply.front[DFS.supplyType.FUEL]..'\n'..
            DFS.status[2].supply.front[DFS.supplyType.AMMO]..'\n'..
            DFS.status[2].supply.front[DFS.supplyType.EQUIPMENT]..'\n'..
            DFS.status[2].supply.rear[DFS.supplyType.FUEL]..'\n'..
            DFS.status[2].supply.rear[DFS.supplyType.AMMO]..'\n'..
            DFS.status[2].supply.rear[DFS.supplyType.EQUIPMENT]..'\n'..
            DFS.status[2].supply.pirate[DFS.supplyType.FUEL]..'\n'..
            DFS.status[2].supply.pirate[DFS.supplyType.AMMO]..'\n'..
            DFS.status[2].supply.pirate[DFS.supplyType.EQUIPMENT]..'\n'
    )
    f:close()
    f = io.open(redFront, 'w')
    for i = 1, #DFS.status[1].spawns.front do
        if DFS.status[1].spawns.front[i].unitLevel ~= nil then
            f:write(DFS.status[1].spawns.front[i].unitLevel..'\n')
        end
    end
    f:close()
    f = io.open(blueFront, 'w')
    for i = 1, #DFS.status[2].spawns.front do
        if DFS.status[2].spawns.front[i].unitLevel ~= nil then
            f:write(DFS.status[2].spawns.front[i].unitLevel..'\n')
        end
    end
    f:close()
    for c = 1,2 do
        local fbFile = redFbs
        if c == 2 then fbFile = blueFbs end
        f = io.open(fbFile, 'w')
        local fbData = {}
        for i = 1, #FirebaseIds[c] do
            local saveFb = {
                location = Firebases[FirebaseIds[c][i]].positions.location,
                guns = #Firebases[FirebaseIds[c][i]].contents.groups,
                ammo = Firebases[FirebaseIds[c][i]].contents.ammo,
                fbType = Firebases[FirebaseIds[c][i]].fbType
            }
            table.insert(fbData, saveFb)
        end
        f:write("return " .. Utils.saveToString(fbData))
        f:close()
    end
end
function dfc.blankData()
    dfc.initHealth()
    dfc.initSupply()
    DFS.status[1].spawns.front = {}
    DFS.status[2].spawns.front = {}
    dfc.initSpawns()
    dfc.saveData()
    dfc.emptyFirebases()
end
function dfc.endMission(coalitionId)
    missionOver = true
    DfcMissionEnd = true
    local winningTeam = 'Red Team'
    if coalitionId == 2 then winningTeam = 'Blue Team' end
    if WWEvents then WWEvents.campaignCompleted(coalitionId) end
    trigger.action.outText(winningTeam..' has won the campaign! Mission will restart in 2 minutes.', 120)
    dfc.blankData()
end
--INIT FUNCS
function dfc.initHealth()
    DFS.status[1].health = DFS.status.maxHealth
    DFS.status[2].health = DFS.status.maxHealth
end
function dfc.emptyFirebases()
    if dfc.fileExists(redFbs) and dfc.fileExists(blueFbs) then
        for c = 1,2 do
            local fbFile = redFbs
            if c == 2 then fbFile = blueFbs end
            f = io.open(fbFile, 'w')
            f:write("return nil")
            f:close()
        end
    end
end
function dfc.initSupply()
    DFS.status[2].supply.front[DFS.supplyType.FUEL] = DFS.status.convoyResupplyAmts[DFS.supplyType.FUEL]
    DFS.status[2].supply.front[DFS.supplyType.AMMO] = DFS.status.convoyResupplyAmts[DFS.supplyType.AMMO]
    DFS.status[2].supply.front[DFS.supplyType.EQUIPMENT] = DFS.status.convoyResupplyAmts[DFS.supplyType.EQUIPMENT]

    DFS.status[2].supply.rear[DFS.supplyType.FUEL] = DFS.status.shippingResupplyAmts[DFS.supplyType.FUEL]
    DFS.status[2].supply.rear[DFS.supplyType.AMMO] = DFS.status.shippingResupplyAmts[DFS.supplyType.AMMO]
    DFS.status[2].supply.rear[DFS.supplyType.EQUIPMENT] = DFS.status.shippingResupplyAmts[DFS.supplyType.EQUIPMENT]

    DFS.status[2].supply.pirate[DFS.supplyType.FUEL] = 0
    DFS.status[2].supply.pirate[DFS.supplyType.AMMO] = 0
    DFS.status[2].supply.pirate[DFS.supplyType.EQUIPMENT] = 0

    DFS.status[1].supply.front[DFS.supplyType.FUEL] = DFS.status.convoyResupplyAmts[DFS.supplyType.FUEL]
    DFS.status[1].supply.front[DFS.supplyType.AMMO] = DFS.status.convoyResupplyAmts[DFS.supplyType.AMMO]
    DFS.status[1].supply.front[DFS.supplyType.EQUIPMENT] = DFS.status.convoyResupplyAmts[DFS.supplyType.EQUIPMENT]
    
    DFS.status[1].supply.rear[DFS.supplyType.FUEL] = DFS.status.shippingResupplyAmts[DFS.supplyType.FUEL]
    DFS.status[1].supply.rear[DFS.supplyType.AMMO] = DFS.status.shippingResupplyAmts[DFS.supplyType.AMMO]
    DFS.status[1].supply.rear[DFS.supplyType.EQUIPMENT] = DFS.status.shippingResupplyAmts[DFS.supplyType.EQUIPMENT]

    DFS.status[1].supply.pirate[DFS.supplyType.FUEL] = 0
    DFS.status[1].supply.pirate[DFS.supplyType.AMMO] = 0
    DFS.status[1].supply.pirate[DFS.supplyType.EQUIPMENT] = 0
end
function dfc.initSpawns()
    DFSubs.initSub({coalitionId = 1, subType = "santafe"})
    DFSubs.initSub({coalitionId = 2, subType = "santafe"})
    local blueRigAA = trigger.misc.getZone("blue-rig-aaa")
    local redRigAA = trigger.misc.getZone("red-rig-aaa")
    if blueRigAA and redRigAA then
        DF_UTILS.spawnGroupExact("blue-rig-aaa", blueRigAA.point, "clone")
        DF_UTILS.spawnGroupExact("red-rig-aaa", redRigAA.point, "clone")
    end
    for i = 1, DFS.status.frontSpawnTotal do
        local randomSpawnLevel = 2
        local redSpawnLevel = randomSpawnLevel
        local blueSpawnLevel = randomSpawnLevel
        if DFS.status[1].front[i] ~= nil then
            redSpawnLevel = DFS.status[1].front[i]
        end
        if DFS.status[2].front[i] ~= nil then
            blueSpawnLevel = DFS.status[2].front[i]
        end
        dfc.respawnFrontGroup({coalitionId = 1, spawnZone = i, unitLevel = redSpawnLevel})
        dfc.respawnFrontGroup({coalitionId = 2, spawnZone = i, unitLevel = blueSpawnLevel})
    end
    if dfc.fileExists(redFbs) and dfc.fileExists(blueFbs) then
        for c = 1,2 do
            local fbFile = redFbs
            if c == 2 then fbFile = blueFbs end
            local fbData = dofile(fbFile)
            if fbData then
                for i = 1, #fbData do
                    local firebaseData = fbData[i]
                    dfc.respawnArtilleryGroup({coalitionId = c, spawnPoint = firebaseData.location, type = firebaseData.fbType, guns = firebaseData.guns, ammo = firebaseData.ammo})
                end
            else
                for i = 1, DFS.status.artSpawnTotal do
                    dfc.respawnArtilleryGroup({coalitionId = 1, spawnPoint = trigger.misc.getZone(DFS.spawnNames[1].artillery..i).point, type = "SPG", spawnZone = i})
                    dfc.respawnArtilleryGroup({coalitionId = 2, spawnPoint = trigger.misc.getZone(DFS.spawnNames[2].artillery..i).point, type = "SPG", spawnZone = i})
                end
            end
        end
    else
        for i = 1, DFS.status.artSpawnTotal do
            dfc.respawnArtilleryGroup({coalitionId = 1, spawnPoint = trigger.misc.getZone(DFS.spawnNames[1].artillery..i).point, type = "SPG", spawnZone = i})
            dfc.respawnArtilleryGroup({coalitionId = 2, spawnPoint = trigger.misc.getZone(DFS.spawnNames[2].artillery..i).point, type = "SPG", spawnZone = i})
        end
    end
    table.insert(DFS.status[1].spawns.battleships, {groupName = DFS.groupNames[1].battleship})
    table.insert(DFS.status[2].spawns.battleships, {groupName = DFS.groupNames[2].battleship})
    for i = 1, DFS.status.fdSpawnTotal do
        dfc.respawnFrontDepot({coalitionId = 1, spawnZone = i})
        dfc.respawnFrontDepot({coalitionId = 2, spawnZone = i})
    end
    for i = 1, DFS.status.rdSpawnTotal do
        for j = 1, DFS.status.rdSpawnSubDepots do
            dfc.respawnRearDepot({coalitionId = 1, spawnZone = i, subDepot = j})
            dfc.respawnRearDepot({coalitionId = 2, spawnZone = i, subDepot = j})
        end
    end
    for i = 1, DFS.status.aaSpawnTotal do
        dfc.respawnAA({coalitionId = 1, spawnZone = i})
        dfc.respawnAA({coalitionId = 2, spawnZone = i})
    end
    dfc.spawnFighter(1)
    dfc.spawnFighter(2)
end
function dfc.initConvoys()
    for a = 1, 2 do
        DFS.status[a].anyConvoyTime = timer.getTime() - DFS.status.newConvoySeparationTime
        for i = 1, DFS.status.fdSpawnTotal do
            DFS.status[a].lastConvoyTimes[i][DFS.supplyType.FUEL] = timer.getTime() - DFS.status.convoyBaseTime
            DFS.status[a].lastConvoyTimes[i][DFS.supplyType.AMMO] = timer.getTime() - DFS.status.convoyBaseTime
            DFS.status[a].lastConvoyTimes[i][DFS.supplyType.EQUIPMENT] = timer.getTime() - DFS.status.convoyBaseTime
        end
    end
end
-- RESPAWN FUNCS
function dfc.respawnFrontGroup(param)
    env.info("respawning frount group")
    --oneInZone(DFS.groupNames[param.coalitionId].frontline[param.unitLevel], DFS.spawnNames[param.coalitionId].frontline.. param.spawnZone).name
    local spawnPoint = trigger.misc.getZone(DFS.spawnNames[param.coalitionId].frontline.. param.spawnZone).point
    table.insert(DFS.status[param.coalitionId].spawns.front, {groupName = DF_UTILS.spawnGroup(DFS.groupNames[param.coalitionId].frontline[param.unitLevel], spawnPoint, 'clone'), spawnZone = param.spawnZone, unitLevel = param.unitLevel} )
end
function dfc.replaceFrontGroup(param)
    local groupname = DFS.status[param.coalitionId].spawns.front[param.index].groupName
    local removeGroup = Group.getByName(groupname)
    if removeGroup ~= nil then removeGroup:destroy() end
    table.remove(DFS.status[param.coalitionId].spawns.front, param.index)
    local spawnPoint = trigger.misc.getZone(DFS.spawnNames[param.coalitionId].frontline.. param.spawnZone).point
    table.insert(DFS.status[param.coalitionId].spawns.front, {groupName = DF_UTILS.spawnGroup(DFS.groupNames[param.coalitionId].frontline[param.unitLevel], spawnPoint, 'clone'), spawnZone = param.spawnZone, unitLevel = param.unitLevel} )
end
function dfc.respawnArtilleryGroup(param)
    local groupName = DF_UTILS.spawnGroupExact(DFS.groupNames[param.coalitionId].artillery, param.spawnPoint, 'clone')
    if param.spawnZone then
        table.insert(DFS.status[param.coalitionId].spawns.artillery, {groupName = groupName, spawnZone = param.spawnZone} )
    end
    Firebases.deploy(groupName, param.type, param.ammo, param.guns)
    Group.getByName(groupName):destroy()
end
function dfc.respawnBattleshipGroup(param)
    table.insert(DFS.status[param.coalitionId].spawns.battleships, {groupName = mist.cloneGroup(DFS.groupNames[param.coalitionId].battleship, true).name} )
end
function dfc.respawnFrontDepot(param)
    local spawnPoint = trigger.misc.getZone(DFS.spawnNames[param.coalitionId].depot..param.spawnZone).point
    table.insert(DFS.status[param.coalitionId].spawns.fd, {groupName = DF_UTILS.spawnGroup(DFS.groupNames[param.coalitionId].depot,spawnPoint,'clone'), spawnZone = param.spawnZone})
end
function dfc.respawnRearDepot(param)
    local spawnPoint = trigger.misc.getZone(DFS.spawnNames[param.coalitionId].reardepot..param.spawnZone .. '-' .. param.subDepot).point
    table.insert(DFS.status[param.coalitionId].spawns.rd, {groupName = DF_UTILS.spawnGroupExact(DFS.groupNames[param.coalitionId].depot, spawnPoint, 'clone'), spawnZone = param.spawnZone, subDepot = param.subDepot})
end
function dfc.respawnAA(param)
    local spawnPoint = trigger.misc.getZone(DFS.spawnNames[param.coalitionId].aa..param.spawnZone).point
    table.insert(DFS.status[param.coalitionId].spawns.aa, {groupName = DF_UTILS.spawnGroup(DFS.groupNames[param.coalitionId].aa, spawnPoint, 'clone'), spawnZone = param.spawnZone})
end
function dfc.calcUnitLevel(coalitionId)
    local frontEquipPct = (DFS.status[coalitionId].supply.front[DFS.supplyType.EQUIPMENT] / DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]) * 100
    local fuelPct = (DFS.status[coalitionId].supply.front[DFS.supplyType.FUEL] / DFS.status.maxSuppliesFront[DFS.supplyType.FUEL] ) * 100
    if frontEquipPct > 74 and fuelPct > 49 then
        return 4
    elseif frontEquipPct > 49 then
        return 3
    elseif frontEquipPct > 29 then
        return 2
    else
        return 1
    end
end
-- HEALTH CHECK FUNCS
function dfc.checkFrontHealth()
    env.info("checking front health", false)
    for a = 1, 2 do
        env.info(a .. " team spawns: " .. #DFS.status[a].spawns.front, false)
        for i = 1, #DFS.status[a].spawns.front do
            local group = DFS.status[a].spawns.front[i]
            if group == nil then break end
            local groupName = group.groupName
            local groupDead = false
            local checkingGroup = Group.getByName(groupName)
            if checkingGroup == nil then
                groupDead = true
            elseif (checkingGroup:getSize()/checkingGroup:getInitialSize() < 0.05) or (DFS.status[a].spawns.front[i].unitLevel == 4 and DFS.status[a].supply.front[DFS.supplyType.FUEL] < 1) then
                groupDead = true
            end
            if groupDead then
                env.info("Group dead: coalition:"..a.." spawn: " ..i, false)
                if checkingGroup then checkingGroup:destroy() end
                local spawnZone = DFS.status[a].spawns.front[i].spawnZone
                table.remove(DFS.status[a].spawns.front, i)
                local unitLevel = dfc.calcUnitLevel(a)
                timer.scheduleFunction(dfc.respawnFrontGroup, {coalitionId = a, spawnZone = spawnZone, unitLevel = unitLevel}, timer.getTime() + DFS.status.frontSpawnDelay)
                dfc.decreaseFrontSupply({coalitionId = a, amount = unitLevel, type = DFS.supplyType.EQUIPMENT})
                DFS.status[a].health = DFS.status[a].health - 1
                DFS.updateHealthbar(a)
            elseif checkingGroup and (checkingGroup:getSize() < checkingGroup:getInitialSize()) then
                env.info("Group under attack: coalition:"..a.." spawn: " ..i .. "size: " .. checkingGroup:getSize(), false)
                local groupPosition = checkingGroup:getUnit(1):getPoint()
                --local newMarkId = DrawingTools.newMarkId()
                --trigger.action.markToCoalition(newMarkId, 'Group under attack!', groupPosition, a)
                --timer.scheduleFunction(trigger.action.removeMark, newMarkId, timer.getTime() + 30)
            end
        end
    end
end
function dfc.checkArtHealth()
    for c = 1, 2 do
        local gunBase = nil
        local ammoBase = nil
        for i = 1, DFS.status.artSpawnTotal do
            local checkingBase = Firebases[FirebaseIds[c][i]]
            if checkingBase ~= nil then
                if gunBase == nil then
                    gunBase = checkingBase
                elseif #checkingBase.contents.groups < #gunBase.contents.groups then
                    gunBase = checkingBase
                end
                if ammoBase == nil then
                    ammoBase = checkingBase
                elseif checkingBase.contents.ammo <= ammoBase.contents.ammo then
                    ammoBase = checkingBase
                end
            end
        end
        if gunBase then
            local maxSpawns = #gunBase.positions.spawnPoints.groups
            local currentGroups = #gunBase.contents.groups
            if currentGroups < maxSpawns and (timer:getTime() - DFS.status[c].lastGunTime > DFS.status.gunInterval) then
                if DFS.status[c].supply.front[DFS.supplyType.EQUIPMENT] > 3 then
                    dfc.decreaseFrontSupply({coalitionId = c, amount = 3, type = DFS.supplyType.EQUIPMENT})
                    Firebases.addGroupToFirebase(gunBase, gunBase.fbType)
                    DFS.status[c].lastGunTime = timer:getTime()
                end
            end
        end
        if ammoBase then
            if ammoBase.contents.ammo < ammoBase.contents.maxAmmo and (timer:getTime() - DFS.status[c].lastShellsTime > DFS.status.shellsInterval) then
                if DFS.status[c].supply.front[DFS.supplyType.AMMO] > Firebases.firebaseSupplyAmts["SHELLS"] then
                    dfc.decreaseFrontSupply({coalitionId = c, amount = Firebases.firebaseSupplyAmts["SHELLS"], type = DFS.supplyType.AMMO})
                    Firebases.resupplyFirebase(ammoBase, Firebases.firebaseSupplyAmts["SHELLS"])
                    DFS.status[c].lastShellsTime = timer:getTime()
                end
            end
        end
    end
end
function dfc.checkBattleshipHealth()
    for a = 1, 2 do
        for i = 1, #DFS.status[a].spawns.battleships do
            local group = DFS.status[a].spawns.battleships[i]
            if group == nil then break end
            local checkingGroup = Group.getByName(group.groupName)
            local groupDead = false
            if checkingGroup == nil then
                groupDead = true
            elseif checkingGroup:getSize() == 0 then
                groupDead = true
            end
            if groupDead and DFS.status[a].supply.front[DFS.supplyType.EQUIPMENT] > 2 then
                if checkingGroup then
                    Group.getByName(DFS.status[a].spawns.battleships[i].groupName):destroy()
                end
                table.remove(DFS.status[a].spawns.battleships, i)
                DFS.status[a].health = DFS.status[a].health - 7
                DFS.updateHealthbar(a)
                timer.scheduleFunction(dfc.respawnBattleshipGroup, {coalitionId = a}, timer.getTime() + DFS.status.battleshipSpawnDelay)
                dfc.decreaseFrontSupply({coalitionId = a, amount = 6, type = DFS.supplyType.EQUIPMENT})
            end
        end
    end
end
function dfc.checkAAHealth()
    for a = 1, 2 do
        for i=1, #DFS.status[a].spawns.aa do
            local group = DFS.status[a].spawns.aa[i]
            if group == nil then break end
            local aaGroup = Group.getByName(group.groupName)
            local groupDead = false
            if aaGroup == nil then
                groupDead = true
            elseif aaGroup:getSize() < 2 then
                groupDead = true
            end
            if aaGroup then
                if groupDead and DFS.status[a].supply.front[DFS.supplyType.EQUIPMENT] > 2 then
                    if aaGroup then
                        aaGroup:destroy()
                    end
                    local spawnZone = DFS.status[a].spawns.aa[i].spawnZone
                    table.remove(DFS.status[a].spawns.aa, i)
                    DFS.status[a].health = DFS.status[a].health - 3
                    DFS.updateHealthbar(a)
                    timer.scheduleFunction(dfc.respawnAA, {coalitionId = a, spawnZone = spawnZone}, timer.getTime() + DFS.status.aaSpawnDelay)
                    dfc.decreaseFrontSupply({coalitionId = a, amount = 3, type = DFS.supplyType.EQUIPMENT})
                end
            else
                table.remove(DFS.status[a].spawns.aa, i)
                break
            end
        end
    end
end
function dfc.checkFDHealth()
    for a = 1, 2 do
        for i = 1, #DFS.status[a].spawns.fd do
            local group = DFS.status[a].spawns.fd[i]
            if group == nil then break end
            local depotGroup = Group.getByName(group.groupName)
            local groupDead = false
            if depotGroup == nil then
                groupDead = true
            elseif depotGroup:getSize()/depotGroup:getInitialSize() <= 0.2 then
                groupDead = true
            end
            if groupDead then
                if depotGroup then
                    depotGroup:destroy()
                end
                local spawnZone = DFS.status[a].spawns.fd[i].spawnZone
                table.remove(DFS.status[a].spawns.fd, i)
                timer.scheduleFunction(dfc.respawnFrontDepot, {coalitionId = a, spawnZone = spawnZone}, timer.getTime() + DFS.status.fdSpawnDelay)
                DFS.status[a].health = DFS.status[a].health - 5
                DFS.updateHealthbar(a)
                local decreaseFuelAmt = math.floor(DFS.status[a].supply.front[DFS.supplyType.FUEL] / #DFS.status[a].spawns.fd)
                local decreaseEquipmentAmt = math.floor(DFS.status[a].supply.front[DFS.supplyType.EQUIPMENT] / #DFS.status[a].spawns.fd)
                local decreaseAmmoAmt = math.floor(DFS.status[a].supply.front[DFS.supplyType.AMMO] / #DFS.status[a].spawns.fd)
                dfc.decreaseFrontSupply({coalitionId = a, amount = decreaseFuelAmt, type = DFS.supplyType.FUEL})
                dfc.decreaseFrontSupply({coalitionId = a, amount = decreaseEquipmentAmt, type = DFS.supplyType.EQUIPMENT})
                dfc.decreaseFrontSupply({coalitionId = a, amount = decreaseAmmoAmt, type = DFS.supplyType.AMMO})
            end
        end
    end
end
function dfc.checkRDHealth()
    for a = 1, 2 do
        for i = 1, #DFS.status[a].spawns.rd do
            local group = DFS.status[a].spawns.rd[i]
            if group == nil then break end
            local depotGroup = Group.getByName(group.groupName)
            local groupDead = false
            if depotGroup == nil then
                groupDead = true
            elseif depotGroup:getSize()/depotGroup:getInitialSize() < 0.2 then
                groupDead = true
            end
            if groupDead then
                if depotGroup then
                    depotGroup:destroy()
                end
                local spawnZone = DFS.status[a].spawns.rd[i].spawnZone
                local subDepot = DFS.status[a].spawns.rd[i].subDepot
                table.remove(DFS.status[a].spawns.rd, i)
                timer.scheduleFunction(dfc.respawnRearDepot, {coalitionId = a, spawnZone = spawnZone, subDepot = subDepot}, timer.getTime() + DFS.status.rdSpawnDelay)
                DFS.status[a].health = DFS.status[a].health - 5
                DFS.updateHealthbar(a)
                local decreaseFuelAmt = math.floor((DFS.status[a].supply.rear[DFS.supplyType.FUEL]/2)/ (DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))
                local decreaseEquipmentAmt = math.floor((DFS.status[a].supply.rear[DFS.supplyType.EQUIPMENT]/2)/ (DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))
                local decreaseAmmoAmt = math.floor((DFS.status[a].supply.rear[DFS.supplyType.AMMO]/2)/ (DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))
                dfc.decreaseRearSupply({coalitionId = a, amount = decreaseFuelAmt, type = DFS.supplyType.FUEL})
                dfc.decreaseRearSupply({coalitionId = a, amount = decreaseEquipmentAmt, type = DFS.supplyType.EQUIPMENT})
                dfc.decreaseRearSupply({coalitionId = a, amount = decreaseAmmoAmt, type = DFS.supplyType.AMMO})
            end
        end
    end
end
function dfc.supplyConsumptionLoop()
    local elapsedTime = timer:getAbsTime() - timer:getTime0()
    if elapsedTime > 2399 then
        for a = 1, 2 do
            for i = 1, #DFS.status[a].spawns.front do
                if DFS.status[a].spawns.front[i].unitLevel == 4 then
                    dfc.decreaseFrontSupply({coalitionId = a, amount = 2, type = DFS.supplyType.FUEL})
                elseif DFS.status[a].spawns.front[i].unitLevel > 1 then
                    dfc.decreaseFrontSupply({coalitionId = a, amount = 1, type = DFS.supplyType.FUEL})
                end
            end
        end
    end
    timer.scheduleFunction(dfc.supplyConsumptionLoop, nil, timer.getTime() + 2400)
end
function dfc.upgradeLoop()
    for a = 1, 2 do
        local upgradeIndex = 1
        for i = 2, #DFS.status[a].spawns.front do
            if DFS.status[a].spawns.front[i].unitLevel < DFS.status[a].spawns.front[i-1].unitLevel then
                upgradeIndex = i
            end
        end
        if DFS.status[a].spawns.front[upgradeIndex].unitLevel < 4 then
            local newLevel = dfc.calcUnitLevel(a)
            if newLevel > DFS.status[a].spawns.front[upgradeIndex].unitLevel then
                dfc.replaceFrontGroup({coalitionId = a, spawnZone = DFS.status[a].spawns.front[upgradeIndex].spawnZone, unitLevel = newLevel, index = upgradeIndex})
                dfc.decreaseFrontSupply({coalitionId = a, amount = newLevel, type = DFS.supplyType.EQUIPMENT})
            end
        end
    end
    timer.scheduleFunction(dfc.upgradeLoop, nil, timer.getTime() + DFS.status.upgradeInterval)
end
function dfc.downgradeLoop()
    for a = 1, 2 do
        local upgradeIndex = 1
        for i = 2, #DFS.status[a].spawns.front do
            if DFS.status[a].spawns.front[i].unitLevel > DFS.status[a].spawns.front[i-1].unitLevel then
                upgradeIndex = i
            end
        end
        if DFS.status[a].spawns.front[upgradeIndex].unitLevel < 4 and DFS.status[a].spawns.front[upgradeIndex].unitLevel < DFS.status[a].supply.front[DFS.supplyType.EQUIPMENT] then
            local newLevel = dfc.calcUnitLevel(a)
            if newLevel < DFS.status[a].spawns.front[upgradeIndex].unitLevel then
                dfc.replaceFrontGroup({coalitionId = a, spawnZone = DFS.status[a].spawns.front[upgradeIndex].spawnZone, unitLevel = newLevel, index = upgradeIndex})
                dfc.decreaseFrontSupply({coalitionId = a, amount = newLevel, type = DFS.supplyType.EQUIPMENT})
            end
        end
    end
    timer.scheduleFunction(dfc.upgradeLoop, nil, timer.getTime() + DFS.status.upgradeInterval)
end
function dfc.checkTeamHealth()
    if DFS.status[1].health < 1 then
        dfc.endMission(2)
    elseif DFS.status[2].health < 1 then
        dfc.endMission(1)
    end
end
function dfc.isItSunset()
    local elapsedTime = timer:getAbsTime()
    if sunsetNotified == false and elapsedTime >= 65700 then
        WWEvents.sunsetDetected()
        sunsetNotified = true
    else
        timer.scheduleFunction(dfc.isItSunset, nil, timer:getTime() + 30)
    end
end
function dfc.increaseFrontSupply(param)
    --params coalitionId, amount
    DFS.status[param.coalitionId].supply.front[param.type] = DFS.status[param.coalitionId].supply.front[param.type] + param.amount
    env.info(param.coalitionId .. "-FrontSupply-"..DFS.supplyNames[param.type].." increased by " .. param.amount .. "to " .. DFS.status[param.coalitionId].supply.front[param.type], false)
    env.info("Current Supply modifier: " .. (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal) .. " Current supply cap = " .. DFS.status.maxSuppliesFront[param.type] * (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal), false)
    if DFS.status[param.coalitionId].supply.front[param.type] > math.floor(DFS.status.maxSuppliesFront[param.type] * (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal)) then
        DFS.status[param.coalitionId].supply.front[param.type] = math.floor(DFS.status.maxSuppliesFront[param.type] * (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal))
    end
    if DFS.status[param.coalitionId].supply.front[param.type] > (DFS.status.maxSuppliesFront[param.type] * 0.15) then
        WWEvents.latches[param.coalitionId].front[param.type] = false
    end
    dfc.updateSupplyDrawings("FRONT", param.coalitionId)
    --trigger.action.outTextForCoalition(param.coalitionId, 'Front ' ..supplyString..': ' .. DFS.status[param.coalitionId].supply.front[param.type], 5)
end
function dfc.decreaseFrontSupply(param)
    --params coalitionId, amount
    DFS.status[param.coalitionId].supply.front[param.type] = DFS.status[param.coalitionId].supply.front[param.type] - param.amount
    env.info(param.coalitionId .. "-FrontSupply-"..DFS.supplyNames[param.type].." decreased by " .. param.amount .. "to " .. DFS.status[param.coalitionId].supply.front[param.type], false)
    env.info("Current Supply modifier: " .. (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal) .. " Current supply cap = " .. DFS.status.maxSuppliesFront[param.type] * (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal), false)
    if DFS.status[param.coalitionId].supply.front[param.type] < 0 then
        DFS.status[param.coalitionId].supply.front[param.type] = 0
    end
    if DFS.status[param.coalitionId].supply.front[param.type] > math.floor(DFS.status.maxSuppliesFront[param.type] * (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal)) then
        DFS.status[param.coalitionId].supply.front[param.type] = math.floor(DFS.status.maxSuppliesFront[param.type] * (#DFS.status[param.coalitionId].spawns.fd / DFS.status.fdSpawnTotal))
    end
    if WWEvents and WWEvents.latches[param.coalitionId].front[param.type] == false and DFS.status[param.coalitionId].supply.front[param.type] < (DFS.status.maxSuppliesFront[param.type] * 0.1) then
        WWEvents.criticalSupplyLevel(param.coalitionId, param.type, DFS.supplyNames[param.type], "front depots")
        WWEvents.latches[param.coalitionId].front[param.type] = true
    end
    dfc.updateSupplyDrawings("FRONT", param.coalitionId)
end
function dfc.increaseRearSupply(param)
    --params coalitionId, amount
    DFS.status[param.coalitionId].supply.rear[param.type] = DFS.status[param.coalitionId].supply.rear[param.type] + param.amount
    env.info(param.coalitionId .. "-RearSupply-"..DFS.supplyNames[param.type].." increased by " .. param.amount ..  "to " .. DFS.status[param.coalitionId].supply.rear[param.type], false)
    env.info("Current Supply modifier: " .. (#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal)) .. " Current supply cap = " .. ((DFS.status.maxSuppliesRear[param.type])*(#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))) , false)
    if DFS.status[param.coalitionId].supply.rear[param.type] > math.floor((DFS.status.maxSuppliesRear[param.type])*(#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))) then
        DFS.status[param.coalitionId].supply.rear[param.type] = math.floor(((DFS.status.maxSuppliesRear[param.type])*(#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))))
    end
    if DFS.status[param.coalitionId].supply.rear[param.type] > (DFS.status.convoyResupplyAmts[param.type]*1.05) then
        WWEvents.latches[param.coalitionId].rear[param.type] = false
    end
    dfc.updateSupplyDrawings("REAR", param.coalitionId)
end
function dfc.decreaseRearSupply(param)
    --params coalitionId, amount
    DFS.status[param.coalitionId].supply.rear[param.type] = DFS.status[param.coalitionId].supply.rear[param.type] - param.amount
    env.info(param.coalitionId .. "-RearSupply-"..DFS.supplyNames[param.type].." decreased by " .. param.amount..  "to " .. DFS.status[param.coalitionId].supply.rear[param.type], false)
    env.info("Current Supply modifier: " .. (#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal)) .. " Current supply cap = " .. ((DFS.status.maxSuppliesRear[param.type])*(#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))), false)
    if DFS.status[param.coalitionId].supply.rear[param.type] < 0 then
        DFS.status[param.coalitionId].supply.rear[param.type] = 0
    end
    if DFS.status[param.coalitionId].supply.rear[param.type] > math.floor((DFS.status.maxSuppliesRear[param.type])*(#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))) then
        DFS.status[param.coalitionId].supply.rear[param.type] = math.floor(((DFS.status.maxSuppliesRear[param.type])*(#DFS.status[param.coalitionId].spawns.rd/(DFS.status.rdSpawnSubDepots*DFS.status.rdSpawnTotal))))
    end
    if WWEvents and WWEvents.latches[param.coalitionId].rear[param.type] == false and DFS.status[param.coalitionId].supply.rear[param.type] <= (DFS.status.convoyResupplyAmts[param.type]) then
        WWEvents.criticalSupplyLevel(param.coalitionId, param.type, DFS.supplyNames[param.type], "rear depot")
        WWEvents.latches[param.coalitionId].rear[param.type] = true
    end
    dfc.updateSupplyDrawings("REAR", param.coalitionId)
end
function dfc.increasePirateSupply(param)
    --params coalitionId, amount
    DFS.status[param.coalitionId].supply.pirate[param.type] = DFS.status[param.coalitionId].supply.pirate[param.type] + param.amount
    env.info(param.coalitionId .. "-PirateSupply-"..DFS.supplyNames[param.type].." increased by " .. param.amount ..  "to " .. DFS.status[param.coalitionId].supply.pirate[param.type], false)
    if DFS.status[param.coalitionId].supply.pirate[param.type] > DFS.status.maxSuppliesPirate[param.type] then
        DFS.status[param.coalitionId].supply.pirate[param.type] = DFS.status.maxSuppliesPirate[param.type]
    end
    dfc.updateSupplyDrawings("PIRATE", param.coalitionId)
end
function dfc.decreasePirateSupply(param)
    --params coalitionId, amount
    DFS.status[param.coalitionId].supply.pirate[param.type] = DFS.status[param.coalitionId].supply.pirate[param.type] - param.amount
    env.info(param.coalitionId .. "-PirateSupply-"..DFS.supplyNames[param.type].." decreased by " .. param.amount..  "to " .. DFS.status[param.coalitionId].supply.pirate[param.type], false)
    if DFS.status[param.coalitionId].supply.pirate[param.type] < 0 then
        DFS.status[param.coalitionId].supply.pirate[param.type] = 0
    end
    if DFS.status[param.coalitionId].supply.pirate[param.type] > DFS.status.maxSuppliesPirate[param.type] then
        DFS.status[param.coalitionId].supply.pirate[param.type] = DFS.status.maxSuppliesPirate[param.type]
    end
    dfc.updateSupplyDrawings("PIRATE", param.coalitionId)
end
function dfc.createSupplyDrawings()
    for c = 1,2 do
        local drawingOriginFrontZone = trigger.misc.getZone(DFS.spawnNames[c].frontSupplyDrawing)
        if drawingOriginFrontZone then
            local drawingOriginFront = drawingOriginFrontZone.point
            for i = 1, 3 do
                local boxOrigin = {x = drawingOriginFront.x, y = drawingOriginFront.y, z = drawingOriginFront.z - (DFS.supplyDrawing.counterOffeset*i)}
                local boxTop = {x = boxOrigin.x + DFS.supplyDrawing.counterHeight, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                local supplyBoxId = DrawingTools.newMarkId()
                env.info("drawing supply meter outline ".. c .. "-" .. i ..": " .. supplyBoxId, false)
                trigger.action.rectToAll(-1, supplyBoxId, boxTop, boxOrigin, {0,0,0,1}, {0,0,0,0.3}, 1, true, nil)
                for j = 1, 3 do
                    local xOffset = (j*(DFS.supplyDrawing.counterHeight/4))/DFS.supplyDrawing.counterHeight * DFS.supplyDrawing.counterHeight
                    local lineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxTop.z}
                    local dashLength = DFS.supplyDrawing.counterWidth/3
                    if (j*(DFS.supplyDrawing.counterHeight/4))/DFS.supplyDrawing.counterHeight == 0.5 then
                        dashLength = DFS.supplyDrawing.counterWidth/2
                    end
                    local lineEnd = {x = lineStart.x, y = lineStart.y, z = lineStart.z + dashLength}
                    trigger.action.lineToAll(-1, DrawingTools.newMarkId(), lineStart, lineEnd, {1,1,1,1}, 1, true, nil)
                end
                local iconOrigin = {x = boxOrigin.x - DFS.supplyDrawing.counterWidth/3, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth/2}
                if i == DFS.supplyType.EQUIPMENT then
                    DrawingTools.drawPackage(iconOrigin, 3, false, -1, true)
                elseif i == DFS.supplyType.AMMO then
                    DrawingTools.drawAmmo(iconOrigin, -1)
                elseif i == DFS.supplyType.FUEL then
                    DrawingTools.drawFuel(iconOrigin, -1)
                end
            end
        end
        local drawingOriginRearZone = trigger.misc.getZone(DFS.spawnNames[c].rearSupplyDrawing)
        if drawingOriginRearZone then
            local drawingOriginRear = drawingOriginRearZone.point
            for i = 1, 3 do
                local boxOrigin = {x = drawingOriginRear.x, y = drawingOriginRear.y, z = drawingOriginRear.z - (DFS.supplyDrawing.counterOffeset*i)}
                local boxTop = {x = boxOrigin.x + DFS.supplyDrawing.counterHeight, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                local supplyBoxId = DrawingTools.newMarkId()
                env.info("drawing supply meter outline ".. c .. "-" .. i ..": " .. supplyBoxId, false)
                trigger.action.rectToAll(-1, supplyBoxId, boxTop, boxOrigin, {0,0,0,1}, {0,0,0,0.3}, 1, true, nil)
                for j = 1, 3 do
                    local xOffset = (j*(DFS.supplyDrawing.counterHeight/4))/DFS.supplyDrawing.counterHeight * DFS.supplyDrawing.counterHeight
                    local lineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxTop.z}
                    local dashLength = DFS.supplyDrawing.counterWidth/3
                    if (j*(DFS.supplyDrawing.counterHeight/4))/DFS.supplyDrawing.counterHeight == 0.5 then
                        dashLength = DFS.supplyDrawing.counterWidth/2
                    end
                    local lineEnd = {x = lineStart.x, y = lineStart.y, z = lineStart.z + dashLength}
                    trigger.action.lineToAll(-1, DrawingTools.newMarkId(), lineStart, lineEnd, {1,1,1,1}, 1, true, nil)
                end
                local iconOrigin = {x = boxOrigin.x - DFS.supplyDrawing.counterWidth/3, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth/2}
                if i == DFS.supplyType.EQUIPMENT then
                    DrawingTools.drawPackage(iconOrigin, 3, false, -1, true)
                elseif i == DFS.supplyType.AMMO then
                    DrawingTools.drawAmmo(iconOrigin, -1)
                elseif i == DFS.supplyType.FUEL then
                    DrawingTools.drawFuel(iconOrigin, -1)
                end
            end
        end
        local drawingOriginPirateZone = trigger.misc.getZone(DFS.spawnNames[c].pirateSupplyDrawing)
        if drawingOriginPirateZone then
            local drawingOriginPirate = drawingOriginPirateZone.point
            local pirateWidth = DFS.supplyDrawing.counterWidth/2
            local pirateOffset = DFS.supplyDrawing.counterOffeset/2
            local pirateHeight = DFS.supplyDrawing.counterHeight/2
            for i = 1, 3 do
                local boxOrigin = {x = drawingOriginPirate.x, y = drawingOriginPirate.y, z = drawingOriginPirate.z - (pirateOffset*i)}
                local boxTop = {x = boxOrigin.x + pirateHeight, y = boxOrigin.y, z = boxOrigin.z - pirateWidth}
                local supplyBoxId = DrawingTools.newMarkId()
                env.info("drawing supply meter outline ".. c .. "-" .. i ..": " .. supplyBoxId, false)
                trigger.action.rectToAll(-1, supplyBoxId, boxTop, boxOrigin, {0,0,0,1}, {0,0,0,0.3}, 1, true, nil)
                for j = 1, 3 do
                    local xOffset = (j*(pirateHeight/4))/pirateHeight * pirateHeight
                    local lineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxTop.z}
                    local dashLength = pirateWidth/3
                    if (j*(pirateHeight/4))/pirateHeight == 0.5 then
                        dashLength = pirateWidth/2
                    end
                    local lineEnd = {x = lineStart.x, y = lineStart.y, z = lineStart.z + dashLength}
                    trigger.action.lineToAll(-1, DrawingTools.newMarkId(), lineStart, lineEnd, {1,1,1,1}, 1, true, nil)
                end
                local iconOrigin = {x = boxOrigin.x - pirateWidth/3, y = boxOrigin.y, z = boxOrigin.z - pirateWidth/2}
                if i == DFS.supplyType.EQUIPMENT then
                    DrawingTools.drawPackage(iconOrigin, 1, false, -1, true)
                elseif i == DFS.supplyType.AMMO then
                    DrawingTools.drawAmmo(iconOrigin, -1, true)
                elseif i == DFS.supplyType.FUEL then
                    DrawingTools.drawFuel(iconOrigin, -1, true)
                end
            end
        end
        dfc.updateSupplyDrawings("FRONT", c)
        dfc.updateSupplyDrawings("REAR", c)
        dfc.updateSupplyDrawings("PIRATE", c)
    end
end
function dfc.updateSupplyDrawings(depot, coalitionId)
    if depot == "REAR" then
        local drawingOriginRearZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].rearSupplyDrawing)
        if drawingOriginRearZone then
            local drawingOriginRear = drawingOriginRearZone.point
            for i = 1, 3 do
                local boxOrigin = {x = drawingOriginRear.x, y = drawingOriginRear.y, z = drawingOriginRear.z - (DFS.supplyDrawing.counterOffeset*i)}
                if DFS.supplyDrawing.fillIds.rear[coalitionId][i] and DFS.supplyDrawing.fillIds.rear[coalitionId][i] > 0 then
                    trigger.action.setMarkupPositionStart(DFS.supplyDrawing.fillIds.rear[coalitionId][i], {x = boxOrigin.x + (DFS.supplyDrawing.counterHeight * (DFS.status[coalitionId].supply.rear[i]/DFS.status.maxSuppliesRear[i])), y = boxOrigin.y, z = boxOrigin.z})
                    trigger.action.setMarkupPositionEnd(DFS.supplyDrawing.fillIds.rear[coalitionId][i], {x = boxOrigin.x + (DFS.supplyDrawing.counterHeight * (DFS.status[coalitionId].supply.rear[i]/DFS.status.maxSuppliesRear[i])), y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth})
                else
                    --local boxTop = {x = boxOrigin.x + DFS.supplyDrawing.counterWidth/4, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                    local xOffset = (DFS.supplyDrawing.counterHeight * (DFS.status[coalitionId].supply.rear[i]/DFS.status.maxSuppliesRear[i]))
                    local supplyCounterLineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z}
                    local supplyCounterLineEnd = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                    local fillId = DrawingTools.newMarkId()
                    --trigger.action.rectToAll(-1, fillId, boxTop, boxOrigin, {0,0,0,1}, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
                    trigger.action.lineToAll(-1, fillId, supplyCounterLineStart, supplyCounterLineEnd, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
                    table.insert(DFS.supplyDrawing.fillIds.rear[coalitionId], fillId)
                end
            end
        end
    elseif depot == "PIRATE" then
        local drawingOriginPirateZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].pirateSupplyDrawing)
        if drawingOriginPirateZone then
            local pirateWidth = DFS.supplyDrawing.counterWidth/2
            local pirateHeight = DFS.supplyDrawing.counterHeight/2
            local pirateOffset = DFS.supplyDrawing.counterOffeset/2
            local drawingOriginPirate = drawingOriginPirateZone.point
            for i = 1, 3 do
                local boxOrigin = {x = drawingOriginPirate.x, y = drawingOriginPirate.y, z = drawingOriginPirate.z - (pirateOffset*i)}
                if DFS.supplyDrawing.fillIds.pirate[coalitionId][i] and DFS.supplyDrawing.fillIds.pirate[coalitionId][i] > 0 then
                    trigger.action.setMarkupPositionStart(DFS.supplyDrawing.fillIds.pirate[coalitionId][i], {x = boxOrigin.x + (pirateHeight * (DFS.status[coalitionId].supply.rear[i]/DFS.status.maxSuppliesPirate[i])), y = boxOrigin.y, z = boxOrigin.z})
                    trigger.action.setMarkupPositionEnd(DFS.supplyDrawing.fillIds.pirate[coalitionId][i], {x = boxOrigin.x + (pirateHeight * (DFS.status[coalitionId].supply.rear[i]/DFS.status.maxSuppliesPirate[i])), y = boxOrigin.y, z = boxOrigin.z - pirateWidth})
                else
                    --local boxTop = {x = boxOrigin.x + DFS.supplyDrawing.counterWidth/4, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                    local xOffset = (pirateHeight * (DFS.status[coalitionId].supply.pirate[i]/DFS.status.maxSuppliesPirate[i]))
                    local supplyCounterLineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z}
                    local supplyCounterLineEnd = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z - pirateWidth}
                    local fillId = DrawingTools.newMarkId()
                    --trigger.action.rectToAll(-1, fillId, boxTop, boxOrigin, {0,0,0,1}, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
                    trigger.action.lineToAll(-1, fillId, supplyCounterLineStart, supplyCounterLineEnd, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
                    table.insert(DFS.supplyDrawing.fillIds.pirate[coalitionId], fillId)
                end
            end
        end
    else
        local drawingOriginFrontZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].frontSupplyDrawing)
        if drawingOriginFrontZone then
            local drawingOriginFront = drawingOriginFrontZone.point
            for i = 1, 3 do
                local boxOrigin = {x = drawingOriginFront.x, y = drawingOriginFront.y, z = drawingOriginFront.z - (DFS.supplyDrawing.counterOffeset*i)}
                if DFS.supplyDrawing.fillIds.front[coalitionId][i] and DFS.supplyDrawing.fillIds.front[coalitionId][i] > 0 then
                    trigger.action.setMarkupPositionStart(DFS.supplyDrawing.fillIds.front[coalitionId][i], {x = boxOrigin.x + (DFS.supplyDrawing.counterHeight * (DFS.status[coalitionId].supply.front[i]/DFS.status.maxSuppliesFront[i])), y = boxOrigin.y, z = boxOrigin.z})
                    trigger.action.setMarkupPositionEnd(DFS.supplyDrawing.fillIds.front[coalitionId][i], {x = boxOrigin.x + (DFS.supplyDrawing.counterHeight * (DFS.status[coalitionId].supply.front[i]/DFS.status.maxSuppliesFront[i])), y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth})
                else
                    --local boxTop = {x = boxOrigin.x + DFS.supplyDrawing.counterWidth/4, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                    local xOffset = (DFS.supplyDrawing.counterHeight * (DFS.status[coalitionId].supply.front[i]/DFS.status.maxSuppliesFront[i]))
                    local supplyCounterLineStart = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z}
                    local supplyCounterLineEnd = {x = boxOrigin.x + xOffset, y = boxOrigin.y, z = boxOrigin.z - DFS.supplyDrawing.counterWidth}
                    local fillId = DrawingTools.newMarkId()
                    --trigger.action.rectToAll(-1, fillId, boxTop, boxOrigin, {0,0,0,1}, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
                    trigger.action.lineToAll(-1, fillId, supplyCounterLineStart, supplyCounterLineEnd, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
                    table.insert(DFS.supplyDrawing.fillIds.front[coalitionId], fillId)
                end
            end
        end
    end
end
function dfc.supplyDrawingRefreshLoop()
    dfc.updateSupplyDrawings("FRONT", 1)
    dfc.updateSupplyDrawings("FRONT", 2)
    dfc.updateSupplyDrawings("REAR", 1)
    dfc.updateSupplyDrawings("REAR", 2)
    dfc.updateSupplyDrawings("PIRATE", 1)
    dfc.updateSupplyDrawings("PIRATE", 2)
    timer.scheduleFunction(dfc.supplyDrawingRefreshLoop, nil, timer:getTime() + 300)
end
--CONVOY AND SHIPPING FUNCS
function dfc.newConvoyLoop()
    env.info("Convoy dispatch loop", false)
    for ctln = 1, 2 do
        env.info("checking coaltion: " .. ctln, false)
        local depotPct = 0
        local i = 1
        for j = 1, DFS.status.rdSpawnSubDepots do
            for k = 1, #DFS.status[ctln].spawns.rd do
                local currentGroup = DFS.status[ctln].spawns.rd[k]
                if currentGroup == nil then break end
                if currentGroup.spawnZone == i and currentGroup.subDepot == j then
                    local subDepotGroup = Group.getByName(currentGroup.groupName)
                    if subDepotGroup then
                        depotPct = depotPct + ((subDepotGroup:getSize() / subDepotGroup:getInitialSize())*100 / DFS.status.rdSpawnSubDepots)
                    end
                end
            end
        end
        if depotPct > 1 then
            env.info("Depot Pct: " .. depotPct, false)
            local activeFDs = {
                [1] = 1,
                [2] = 2,
                [3] = 3,
                [4] = 4,
            }
            for fd = 1, #activeFDs do
                if not dfc.depotActive(({coalitionId = ctln, zone = activeFDs[fd]})) then
                    for afd = 1, #activeFDs do
                        if activeFDs[afd] == activeFDs[fd] then
                            table.remove(activeFDs, afd)
                            break
                        end
                    end
                end
            end
            local fueltime = timer.getTime() - DFS.status[ctln].lastConvoyTimes[1][DFS.supplyType.FUEL] > DFS.status.convoyBaseTime
            local ammotime = timer.getTime() - DFS.status[ctln].lastConvoyTimes[1][DFS.supplyType.AMMO] > DFS.status.convoyBaseTime
            local equiptime = timer.getTime() - DFS.status[ctln].lastConvoyTimes[1][DFS.supplyType.EQUIPMENT] > DFS.status.convoyBaseTime
            local hasConvoyFuel = DFS.status[ctln].supply.rear[DFS.supplyType.FUEL] > 1
            local needsAmmo = DFS.status[ctln].supply.front[DFS.supplyType.AMMO] < DFS.status.maxSuppliesFront[DFS.supplyType.AMMO]
            local hasAmmoAmt = DFS.status[ctln].supply.rear[DFS.supplyType.AMMO] > DFS.status.convoyResupplyAmts[DFS.supplyType.AMMO]
            local needsFuel = DFS.status[ctln].supply.front[DFS.supplyType.FUEL] < DFS.status.maxSuppliesFront[DFS.supplyType.FUEL]
            local hasFuelAmt = DFS.status[ctln].supply.rear[DFS.supplyType.FUEL] > (DFS.status.convoyResupplyAmts[DFS.supplyType.FUEL]+2)
            local needsEquipment = DFS.status[ctln].supply.front[DFS.supplyType.EQUIPMENT] < DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]
            local hasEquipmentAmt = DFS.status[ctln].supply.rear[DFS.supplyType.EQUIPMENT] > DFS.status.convoyResupplyAmts[DFS.supplyType.EQUIPMENT]
            local anytime = timer.getTime() - DFS.status[ctln].anyConvoyTime > DFS.status.newConvoySeparationTime
            --fuel check
            if anytime and fueltime and hasConvoyFuel and needsFuel and hasFuelAmt then
                local deliverZone = activeFDs[math.random(#activeFDs)]
                dfc.decreaseRearSupply({coalitionId = ctln,  amount = (DFS.status.convoyResupplyAmts[DFS.supplyType.FUEL]+2), type = DFS.supplyType.FUEL})
                dfc.startConvoy({coalitionId = ctln, startFrom = i, deliverZone = deliverZone, type = DFS.supplyType.FUEL})
                anytime = timer.getTime() - DFS.status[ctln].anyConvoyTime > DFS.status.newConvoySeparationTime
                env.info("Start Fuel convoy to front depot: " .. deliverZone, debug)
                dfc.rollAmbush(ctln, deliverZone, 1)
            end
            --ammo check
            if anytime and ammotime and hasConvoyFuel and needsAmmo and hasAmmoAmt then
                local deliverZone = activeFDs[math.random(#activeFDs)]
                dfc.decreaseRearSupply({coalitionId = ctln,  amount = (DFS.status.convoyResupplyAmts[DFS.supplyType.AMMO]), type = DFS.supplyType.AMMO})
                dfc.decreaseRearSupply({coalitionId = ctln,  amount = 2, type = DFS.supplyType.FUEL})
                dfc.startConvoy({coalitionId = ctln, startFrom = i, deliverZone = deliverZone, type = DFS.supplyType.AMMO})
                anytime = timer.getTime() - DFS.status[ctln].anyConvoyTime > DFS.status.newConvoySeparationTime
                env.info("Start Ammo convoy to front depot: " .. deliverZone, debug)
                dfc.rollAmbush(ctln, deliverZone, 1)
            end
            --equipment check 
            if anytime and equiptime and hasConvoyFuel and needsEquipment and hasEquipmentAmt then
                local deliverZone = activeFDs[math.random(#activeFDs)]
                dfc.decreaseRearSupply({coalitionId = ctln,  amount = (DFS.status.convoyResupplyAmts[DFS.supplyType.EQUIPMENT]), type = DFS.supplyType.EQUIPMENT})
                dfc.decreaseRearSupply({coalitionId = ctln,  amount = 2, type = DFS.supplyType.FUEL})
                dfc.startConvoy({coalitionId = ctln, startFrom = i, deliverZone = deliverZone, type = DFS.supplyType.EQUIPMENT})
                anytime = timer.getTime() - DFS.status[ctln].anyConvoyTime > DFS.status.newConvoySeparationTime
                env.info("Start Equipment convoy to front depot: " .. deliverZone, debug)
                dfc.rollAmbush(ctln, deliverZone, 1)
            end
        end
    end
end
function dfc.rollAmbush(convoyCoalition, destination, rdNum)
    local setAmbush = false
    env.info("checking ambush", false)
    local roll100 = math.random(100)
    if roll100 < 25 then
        env.info("ambush true", false)
        setAmbush = true
    end
    if setAmbush then
        local ambushPoint = math.random(8)
        env.info("ambushing at: " .. convoyCoalition.."-"..rdNum.."-"..destination.."-ambush-"..ambushPoint, false)
        local ambushZone = trigger.misc.getZone(convoyCoalition.."-"..rdNum.."-"..destination.."-ambush-"..ambushPoint)
        if ambushZone and ambushZone.point and WWEvents then
            local spawnPoint = ambushZone.point
            local ambushcoal = 2
            if convoyCoalition == 2 then ambushcoal = 1 end
            local ambushGroup = DF_UTILS.spawnGroup(DFS.groupNames[ambushcoal].ambush, spawnPoint, "clone")
            WWEvents.convoyAmbushDetected(convoyCoalition, destination)
            timer.scheduleFunction(dfc.destroyGroup, ambushGroup, timer:getTime() + 2100)
        end
    end
end
function dfc.sendConvoyLoop()
    env.info('Convoy Check Loop', debug)
    for a = 1, 2 do
        local i = 1
        env.info('RD: ' .. i, debug)
        local depotPct = 0
        for j = 1, DFS.status.rdSpawnSubDepots do
            --if debug then trigger.action.outText('Sub Depot Health, RD: ' .. i .. ' SD: ' .. j, 1) end
            for k = 1, #DFS.status[a].spawns.rd do
                local currentGroup = DFS.status[a].spawns.rd[k]
                if currentGroup == nil then break end
                if currentGroup.spawnZone == i and currentGroup.subDepot == j then
                    local subDepotGroup = Group.getByName(currentGroup.groupName)
                    if subDepotGroup then
                        depotPct = depotPct + ((subDepotGroup:getSize() / subDepotGroup:getInitialSize())*100 / DFS.status.rdSpawnSubDepots)
                    end
                end
            end
        end
        for j = 1, DFS.status.fdSpawnTotal do
            local deliverZone = j

            env.info('Delivery check from RD: ' .. i .. ' to FD: ' .. deliverZone, debug)
            if depotPct > 1 and dfc.depotActive({coalitionId = a, zone = deliverZone}) then
                local fueltime = timer.getTime() - DFS.status[a].lastConvoyTimes[deliverZone][DFS.supplyType.FUEL] > DFS.status.convoyBaseTime
                local ammotime = timer.getTime() - DFS.status[a].lastConvoyTimes[deliverZone][DFS.supplyType.AMMO] > DFS.status.convoyBaseTime
                local equiptime = timer.getTime() - DFS.status[a].lastConvoyTimes[deliverZone][DFS.supplyType.EQUIPMENT] > DFS.status.convoyBaseTime
                local hasConvoyFuel = DFS.status[a].supply.rear[DFS.supplyType.FUEL] > 1
                local needsAmmo = DFS.status[a].supply.front[DFS.supplyType.AMMO] < DFS.status.maxSuppliesFront[DFS.supplyType.AMMO]
                local needsFuel = DFS.status[a].supply.front[DFS.supplyType.FUEL] < DFS.status.maxSuppliesFront[DFS.supplyType.FUEL]
                local needsEquipment = DFS.status[a].supply.front[DFS.supplyType.EQUIPMENT] < DFS.status.maxSuppliesFront[DFS.supplyType.EQUIPMENT]
                local anySent = false
                local anytime = timer.getTime() - DFS.status[a].anyConvoyTime > DFS.status.convoySeparationTime
                if anytime then
                    if needsFuel and fueltime and DFS.status[a].supply.rear[DFS.supplyType.FUEL] > (DFS.status.convoyResupplyAmts[DFS.supplyType.FUEL]+2) then
                        dfc.decreaseRearSupply({coalitionId = a,  amount = (DFS.status.convoyResupplyAmts[DFS.supplyType.FUEL]+2), type = DFS.supplyType.FUEL})
                        dfc.startConvoy({coalitionId = a, startFrom = i, deliverZone = deliverZone, type = DFS.supplyType.FUEL})
                        anySent = true
                        env.info("Start Fuel convoy", debug)
                    end

                    if needsAmmo and ammotime and DFS.status[a].supply.rear[DFS.supplyType.AMMO] > DFS.status.convoyResupplyAmts[DFS.supplyType.AMMO] and hasConvoyFuel then
                        dfc.decreaseRearSupply({coalitionId = a,  amount = 2, type = DFS.supplyType.FUEL})
                        dfc.decreaseRearSupply({coalitionId = a,  amount = DFS.status.convoyResupplyAmts[DFS.supplyType.AMMO], type = DFS.supplyType.AMMO})
                        dfc.startConvoy({coalitionId = a, startFrom = i, deliverZone = deliverZone, type = DFS.supplyType.AMMO})
                        anySent = true
                        env.info("Start ammo convoy", debug)
                    end

                    if needsEquipment and equiptime and DFS.status[a].supply.rear[DFS.supplyType.EQUIPMENT] > 10 and hasConvoyFuel then
                        dfc.decreaseRearSupply({coalitionId = a,  amount = 2, type = DFS.supplyType.FUEL})
                        dfc.decreaseRearSupply({coalitionId = a,  amount = DFS.status.convoyResupplyAmts[DFS.supplyType.EQUIPMENT], type = DFS.supplyType.EQUIPMENT})
                        dfc.startConvoy({coalitionId = a, startFrom = i, deliverZone = deliverZone, type = DFS.supplyType.EQUIPMENT})
                        anySent = true
                        env.info("Start Equipment convoy", debug)
                    end
                    if anySent then
                        local setAmbush = false
                        env.info("checking ambush", false)
                        local roll100 = math.random(100)
                        if roll100 < 25 then
                            env.info("ambush true", false)
                            setAmbush = true
                        end
                        if setAmbush then
                            local ambushPoint = math.random(8)
                            env.info("ambushing at: " .. a.."-"..i.."-"..deliverZone.."-ambush-"..ambushPoint, false)
                            local ambushZone = trigger.misc.getZone(a.."-"..i.."-"..deliverZone.."-ambush-"..ambushPoint)
                            if ambushZone and ambushZone.point and WWEvents then
                                local spawnPoint = ambushZone.point
                                local ambushcoal = 2
                                if a == 2 then ambushcoal = 1 end
                                local ambushGroup = DF_UTILS.spawnGroup(DFS.groupNames[ambushcoal].ambush, spawnPoint, "clone")
                                WWEvents.convoyAmbushDetected(a, deliverZone)
                                timer.scheduleFunction(dfc.destroyGroup, ambushGroup, timer:getTime() + 2100)
                            end
                        end
                    end
                end
            end
        end
    end
end
function dfc.destroyGroup(name)
    local destroyGroup = Group.getByName(name)
    if destroyGroup and destroyGroup.destroy then
        destroyGroup:destroy()
    end
end
function dfc.startConvoy(param)
    local convoyGroupName = mist.cloneGroup(DFS.groupNames[param.coalitionId].convoy[param.type]..param.startFrom .. '-' .. param.deliverZone, true).name
    DFS.status[param.coalitionId].lastConvoyTimes[1][param.type] = timer.getTime()
    DFS.status[param.coalitionId].anyConvoyTime = timer.getTime()
    dfc.checkConvoy({convoyName = convoyGroupName, deliverZone = param.deliverZone, type = param.type})
end
function dfc.checkConvoy(param)
    env.info('Checking Convoy: ' .. param.convoyName, debug)
    local convoyGroup = Group.getByName(param.convoyName)
    if convoyGroup ~= nil then
        local convoyLead = convoyGroup:getUnit(1)
        if convoyLead ~= nil  then
            local convoyLeadPos = convoyGroup:getUnit(1):getPoint()
            if convoyLeadPos ~= nil then
                local coalitionId = convoyGroup:getCoalition()
                local convoyDestinationZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].deliver..param.deliverZone)
                local distanceToDestination = Utils.PointDistance(convoyLeadPos, convoyDestinationZone.point)
                if distanceToDestination < convoyDestinationZone.radius and dfc.depotActive({coalitionId = coalitionId, zone = param.deliverZone}) then
                    dfc.increaseFrontSupply({coalitionId = coalitionId, amount = math.floor(DFS.status.convoyResupplyAmts[param.type] * (convoyGroup:getSize() / convoyGroup:getInitialSize())), type = param.type})
                    trigger.action.outTextForCoalition(coalitionId, "Convoy Supplies Delivered!", 10, false)
                    convoyGroup:destroy()
                    return
                end
            end
        else
            return
        end
        timer.scheduleFunction(dfc.checkConvoy, param, timer.getTime() + 10)
    end
end
function dfc.checkShipping(param)
    local convoyGroup = Group.getByName(param.convoyName)
    if convoyGroup ~= nil then
        local convoyLead = convoyGroup:getUnit(1)
        if convoyLead ~= nil  then
            local convoyLeadPos = convoyGroup:getUnit(1):getPoint()
            if convoyLeadPos ~= nil then
                local healthPct = math.floor((convoyLead:getLife()/convoyLead:getLife0()) * 100)
                if healthPct < 30 then
                    trigger.action.explosion(convoyLeadPos, 600)
                    return
                elseif healthPct < 70 then
                    convoyGroup:getController():setOnOff(false)
                end
                local convoyCoalition = convoyGroup:getCoalition()
                local destinationZoneString = "Red-Rear-Deliver"
                if convoyCoalition == 2 then destinationZoneString = "Blue-Rear-Deliver" end
                env.info("Checking Shipping: " .. param.convoyName .. " deliver zone: " .. destinationZoneString, false)
                local convoyDestinationZone = trigger.misc.getZone(destinationZoneString)
                local distanceToDestination = Utils.PointDistance(convoyLeadPos, convoyDestinationZone.point)
                if distanceToDestination < convoyDestinationZone.radius then
                    dfc.increaseRearSupply({coalitionId = convoyCoalition, amount = math.floor(DFS.status.shippingResupplyAmts[DFS.supplyType.FUEL] * (convoyGroup:getSize() / convoyGroup:getInitialSize())), type = DFS.supplyType.FUEL})
                    dfc.increaseRearSupply({coalitionId = convoyCoalition, amount = math.floor(DFS.status.shippingResupplyAmts[DFS.supplyType.AMMO] * (convoyGroup:getSize() / convoyGroup:getInitialSize())), type = DFS.supplyType.AMMO})
                    dfc.increaseRearSupply({coalitionId = convoyCoalition, amount = math.floor(DFS.status.shippingResupplyAmts[DFS.supplyType.EQUIPMENT] * (convoyGroup:getSize() / convoyGroup:getInitialSize())), type = DFS.supplyType.EQUIPMENT})
                    env.info(param.convoyName .. " deliver zone: " .. destinationZoneString .. " delivered!", false)
                    trigger.action.outTextForCoalition(convoyCoalition, "Ship Cargo Delivered!", 10, false)
                    convoyGroup:destroy()
                    local escortGroup = Group.getByName(param.escortName)
                    if escortGroup then
                        env.info("destroying escort: " .. param.escortName, false)
                        escortGroup:destroy()
                    end
                    return
                end
            end
        else
            if param.escortName then
                env.info("convoy group dead, killing escort: " .. param.escortName, false)
                local escortGroup = Group.getByName(param.escortName)
                if escortGroup then escortGroup:destroy() end
            end
            convoyGroup:destroy()
            return
        end
        timer.scheduleFunction(dfc.checkShipping, param, timer.getTime() + 60)
    else
        if param.escortName then
            env.info("convoy group dead, killing escort: " .. param.escortName, false)
            local escortGroup = Group.getByName(param.escortName)
            if escortGroup then escortGroup:destroy() end
        end
    end
end
--shipName
function dfc.checkPirate(param)
    env.info("Tracking pirate boat: " .. param.convoyName, false)
    local convoyGroup = Group.getByName(param.convoyName)
    if convoyGroup ~= nil then
        local convoyLead = convoyGroup:getUnit(1)
        if convoyLead ~= nil  then
            local convoyLeadPos = convoyGroup:getUnit(1):getPoint()
            if convoyLeadPos ~= nil then
                local convoyCoalition = convoyGroup:getCoalition()
                local destinationZoneString = "RedPirateDeliver"
                if convoyCoalition == 2 then destinationZoneString = "BluePirateDeliver" end
                local convoyDestinationZone = trigger.misc.getZone(destinationZoneString)
                local distanceToDestination = Utils.PointDistance(convoyLeadPos, convoyDestinationZone.point)
                if distanceToDestination < convoyDestinationZone.radius then
                    dfc.increasePirateSupply({coalitionId = convoyCoalition, amount = math.floor(DFS.status.shippingResupplyAmts[DFS.supplyType.FUEL]/4), type = DFS.supplyType.FUEL})
                    dfc.increasePirateSupply({coalitionId = convoyCoalition, amount = math.floor(DFS.status.shippingResupplyAmts[DFS.supplyType.AMMO]/4), type = DFS.supplyType.AMMO})
                    dfc.increasePirateSupply({coalitionId = convoyCoalition, amount = math.floor(DFS.status.shippingResupplyAmts[DFS.supplyType.EQUIPMENT]/4), type = DFS.supplyType.EQUIPMENT})
                    trigger.action.outTextForCoalition(convoyCoalition, "Stolen Cargo Delivered to hidden base!", 10, false)
                    if WWEvents then
                        WWEvents.playerStoleCargo(param.playerName, param.boardingCoalition, param.playerName .. "'s stolen cargo was delivered!")
                    end
                    convoyGroup:destroy()
                end
            end
        else
            convoyGroup:destroy()
            return
        end
        timer.scheduleFunction(dfc.checkPirate, param, timer.getTime() + 60)
    end
end
function dfc.startShipping()
    local redConvoyName = mist.cloneGroup('Red-ShipConvoy-Init').name
    local redConvoyGroup = Group.getByName(redConvoyName)
    if redConvoyGroup then
       local redConvoyUnit = redConvoyGroup:getUnit(1)
       if redConvoyUnit then
        local convoyPoint = redConvoyUnit:getPoint()
        local convoyPos = redConvoyUnit:getPosition()
        if convoyPoint and convoyPos then
            local heading = math.atan2(convoyPos.x.z, convoyPos.x.x)
            if heading < 0 then heading = heading + (2 * math.pi) end
            local spawnPoints = {}
            spawnPoints[1] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(convoyPos.x, 40))
            spawnPoints[2] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(convoyPos.x, 58))
            spawnPoints[3] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(Utils.RotateVector(convoyPos.x, 0.26), -30))
            spawnPoints[4] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(Utils.RotateVector(convoyPos.x, -0.26), -30))
            local groups = {
                [1] = {type = "shipaa", point = spawnPoints[1]},
                [2] = {type = "TRUCK", point = spawnPoints[2]},
                [3] = {type = "m249", point = spawnPoints[3]},
                [4] = {type = "m249", point = spawnPoints[4]},
            }
           -- FirebaseGroups.spawnCustomGroup(convoyPoint, groups, 1, heading)
        end
       end
    end
    local redEscortName = mist.cloneGroup('Red-ShipEscort-Init').name
    dfc.checkShipping({convoyName = redConvoyName, escortName = redEscortName})
    local blueConvoyName = mist.cloneGroup('Blue-ShipConvoy-Init').name
    local blueConvoyGroup = Group.getByName(blueConvoyName)
    if blueConvoyGroup then
       local blueConvoyUnit = blueConvoyGroup:getUnit(1)
       if blueConvoyUnit then
        local convoyPoint = blueConvoyUnit:getPoint()
        local convoyPos = blueConvoyUnit:getPosition()
        if convoyPoint and convoyPos then
            local heading = math.atan2(convoyPos.x.z, convoyPos.x.x)
            if heading < 0 then heading = heading + (2 * math.pi) end
            local spawnPoints = {}
            spawnPoints[1] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(convoyPos.x, 40))
            spawnPoints[2] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(convoyPos.x, 58))
            spawnPoints[3] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(Utils.RotateVector(convoyPos.x, 0.26), -30))
            spawnPoints[4] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(Utils.RotateVector(convoyPos.x, -0.26), -30))
            local groups = {
                [1] = {type = "shipaa", point = spawnPoints[1]},
                [2] = {type = "TRUCK", point = spawnPoints[2]},
                [3] = {type = "m249", point = spawnPoints[3]},
                [4] = {type = "m249", point = spawnPoints[4]},
            }
            --FirebaseGroups.spawnCustomGroup(convoyPoint, groups, 2, heading)
        end
       end
    end
    local blueEscortName = mist.cloneGroup('Blue-ShipEscort-Init').name
    dfc.checkShipping({convoyName = blueConvoyName, escortName = blueEscortName})
    dfc.shippingLoop()
end
function dfc.shippingLoop()
    for c = 1,2 do
        if timer:getTime() - DFS.status[c].lastShipTime > (DFS.status[c].industrialModifier * DFS.status.shipConvoyInterval) or DFS.status[c].lastShipTime == 0 then
            local ctlnString = "Red"
            if c == 2 then ctlnString = "Blue" end
            local spawnNum = math.random(3)
            local convoyName = mist.cloneGroup(ctlnString..'-ShipConvoy-'..spawnNum).name
            local convoyGroup = Group.getByName(convoyName)
            if convoyGroup then
                local convoyUnit = convoyGroup:getUnit(1)
                if convoyUnit then
                    local convoyPoint = convoyUnit:getPoint()
                    local convoyPos = convoyUnit:getPosition()
                    if convoyPoint and convoyPos then
                        local heading = math.atan2(convoyPos.x.z, convoyPos.x.x)
                        if heading < 0 then heading = heading + (2 * math.pi) end
                        local spawnPoints = {}
                        spawnPoints[1] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(convoyPos.x, 40))
                        spawnPoints[2] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(convoyPos.x, 58))
                        spawnPoints[3] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(Utils.RotateVector(convoyPos.x, 0.26), -30))
                        spawnPoints[4] = Utils.VectorAdd(convoyPoint, Utils.ScalarMult(Utils.RotateVector(convoyPos.x, -0.26), -30))
                        local groups = {
                            [1] = {type = "shipaa", point = spawnPoints[1]},
                            [2] = {type = "TRUCK", point = spawnPoints[2]},
                            [3] = {type = "m249", point = spawnPoints[3]},
                            [4] = {type = "m249", point = spawnPoints[4]},
                        }
                        --FirebaseGroups.spawnCustomGroup(convoyPoint, groups, c, heading)
                    end
                end
            end
            local escortName = mist.cloneGroup(ctlnString..'-ShipEscort-'..spawnNum).name
            dfc.checkShipping({convoyName = convoyName, escortName = escortName})
            DFS.status[c].lastShipTime = timer:getTime()
            if DFS.status[c].lastShipTime == 0 then DFS.status[c].lastShipTime = 1 end
        end
    end
    timer.scheduleFunction(dfc.shippingLoop, nil, timer.getTime() + 60)
end
function dfc.depotActive(param)
    local depotActive = false
    for i=1, #DFS.status[param.coalitionId].spawns.fd do
        local depot = DFS.status[param.coalitionId].spawns.fd[i]
        if depot ~= nil then
            if depot.spawnZone == param.zone then depotActive = true end
        end
    end
    return depotActive
end
--BOMBERS AND CAP FUNCS
function dfc.bomberLoop()
    local coalitionId = DFS.status.bomberCoalition
    local targetNum = DFS.status.bomberTarget
    env.info('Bomber Loop: ' .. coalitionId .. targetNum, debug)
    dfc.spawnBomber({coalitionId = coalitionId, targetNum = targetNum})
    DFS.status.bomberCoalition = DFS.status.bomberCoalition + 1
    if DFS.status.bomberCoalition > 2 then
        DFS.status.bomberCoalition = 1
        DFS.status.bomberTarget = DFS.status.bomberTarget + 1
        if DFS.status.bomberTarget > 2 then
            DFS.status.bomberTarget = 1
        end
    end
    timer.scheduleFunction(dfc.bomberLoop, nil, timer.getTime() + DFS.status.bomberInterval)
end
--coalitionId, targetNum
function dfc.spawnBomber(param)
    local groupName = ''
    local enemyCoalition = 2
    if param.coalitionId == 2 then
        enemyCoalition = 1
    end
    if param.coalitionId == 1 then
        groupName = mist.cloneGroup('Red Bombers-' .. param.targetNum, true).name
    elseif param.coalitionId == 2 then
        groupName = mist.cloneGroup('Blue Bombers-' .. param.targetNum, true).name
    end
    trigger.action.outTextForCoalition(param.coalitionId, 'Friendly bomber flight enroute! Requesting escort!', 15)
    trigger.action.outTextForCoalition(enemyCoalition, 'Enemy bomber flight spotted! En route to our rear depots', 15)
    timer.scheduleFunction(dfc.despawnBomber, groupName, timer.getTime() + DFS.status.bomberInterval-20)
end
function dfc.despawnBomber(groupName)
    local bomberGroup = Group.getByName(groupName)
    if bomberGroup ~= nil then bomberGroup:destroy() end
end
function dfc.spawnFighter(coalitionId)
    local cloneGroupName = 'Red-CAP'
    if coalitionId == 2 then cloneGroupName = 'Blue-CAP' end
    local groupName = mist.cloneGroup(cloneGroupName, true).name
    DFS.status[coalitionId].lastFighterTime = timer:getTime()
    dfc.checkFighter({groupName = groupName, coalitionId = coalitionId})
end
function dfc.checkFighter(param)
    local group = Group.getByName(param.groupName)
    if group ~= nil then
        if group:getSize() == 0 or group:getUnit(1) == nil or group:getUnit(1):inAir() == false then
            group:destroy()
            timer.scheduleFunction(dfc.spawnFighter, param.coalitionId, timer:getTime() + DFS.status.fighterInterval)
        else
            timer.scheduleFunction(dfc.checkFighter, param, timer.getTime() + 30)
        end
    else
        timer.scheduleFunction(dfc.spawnFighter, param.coalitionId, timer:getTime() + DFS.status.fighterInterval)
    end
end
--ARTILLERY AND CAS FUNCS
function dfc.illuminate(point)
    if point then
        trigger.action.illuminationBomb({x=point.x, y = land.getHeight({x = point.x, y = point.z})+700, z = point.z}, 8000)
    end
end
function DFS.smokeGroup(groupName, smokeColor)
    local missionGroup = Group.getByName(groupName)
    if missionGroup then
        local missionUnit = missionGroup:getUnit(1)
        if missionUnit then
            local missionPos = missionUnit:getPoint()
            if missionPos then
                trigger.action.smoke(Utils.VectorAdd(missionPos, Utils.ScalarMult(atmosphere.getWind(missionPos), 10 + math.random(5))), smokeColor)
                env.info("Created CAS smoke marker for:" .. groupName, false)
            end
        end
    end
end
function dfc.casLoop()
    dfc.createCasMissions(1)
    dfc.createCasMissions(2)
    timer.scheduleFunction(dfc.casLoop, nil, timer.getTime() + 330)
end
function dfc.createCasMissions(coalitionId)
    local smoke = 4
    local enemyCoalition = 2
    if coalitionId == 2 then
        enemyCoalition = 1
        smoke = 1
    end
    dfc.checkFrontHealth()
    local numberOfGroups = #DFS.status[enemyCoalition].spawns.front
    local midPoint = math.floor(numberOfGroups/2)
    local missionGroup1 = Group.getByName(DFS.status[enemyCoalition].spawns.front[math.random(1,midPoint)].groupName)
    local missionGroup2 = Group.getByName(DFS.status[enemyCoalition].spawns.front[math.random(midPoint+1, numberOfGroups)].groupName)
    if missionGroup1 and missionGroup2 then
        local missionUnit1 = missionGroup1:getUnit(1)
        local missionUnit2 = missionGroup2:getUnit(1)
        if missionUnit1 and missionUnit2 then
            local missionPos1 = missionUnit1:getPoint()
            local missionPos2 = missionUnit2:getPoint()
            if missionPos1 and missionPos2 then
                if missionPos1 and missionPos2 then
                    trigger.action.smoke(Utils.VectorAdd(missionPos1, Utils.ScalarMult(atmosphere.getWind(missionPos1), 5 + math.random(5))), smoke)
                    trigger.action.smoke(Utils.VectorAdd(missionPos2, Utils.ScalarMult(atmosphere.getWind(missionPos2), 5 + math.random(5))), smoke)
                    env.info("Created CAS smoke markers for:" .. coalitionId, false)
                end
            end
        end
    end
end


function dfc.mainLoop()
    --check front health
    if missionOver then
        return
    else
        dfc.checkFrontHealth()
        dfc.checkAAHealth()
        dfc.checkArtHealth()
        dfc.checkBattleshipHealth()
        dfc.checkFDHealth()
        dfc.checkRDHealth()
        --dfc.sendConvoyLoop()
        dfc.newConvoyLoop()
        dfc.checkNoFlyZones()
        dfc.checkTeamHealth()
        timer.scheduleFunction(dfc.mainLoop, nil, timer.getTime() + 10)
    end
end
function dfc.checkNoFlyZones()
    dfc.checkNoFlyZone(1)
    dfc.checkNoFlyZone(2)
end
function dfc.checkNoFlyZone(coalitionId)
    local zone = trigger.misc.getZone('No Fly Zone Red')
    local findCoalition = 2
    if coalitionId == 2 then
        zone = trigger.misc.getZone('No Fly Zone Blue')
        findCoalition = 1
    end
    local units = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = zone.point,
            radius = zone.radius
        }
    }
    local ifFound = function(foundItem, val)
        if foundItem:getCoalition() == findCoalition then
            units[#units + 1] = foundItem:getName()
        end
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    for i = 1, #units do
        local unit = Unit.getByName(units[i])
        if unit ~= nil then
            local unitPoint = unit:getPoint()
            if unitPoint ~= nil then
                trigger.action.explosion(unitPoint, 50)
            end
        end
    end
end
function dfc.drawHealthBars()
    if DrawingTools then
        for c = 1,2 do
            local healthbarZone = trigger.misc.getZone(DFS.spawnNames[c].healthbar)
            if healthbarZone then
                local healthbarOrigin = healthbarZone.point
                if healthbarOrigin then
                    local barTopLeft = healthbarOrigin
                    local barBottomRight = {x = healthbarOrigin.x - DFS.supplyDrawing.counterWidth, y = healthbarOrigin.y, z = healthbarOrigin.z + DFS.supplyDrawing.counterHeight}
                    trigger.action.rectToAll(-1, DrawingTools.newMarkId(), barTopLeft, barBottomRight, {0,0,0,1}, {0,0,0,1}, 1, true, nil)
                    for j = 1, 3 do
                        local zOffset = (j*(DFS.supplyDrawing.counterHeight/4))/DFS.supplyDrawing.counterHeight * DFS.supplyDrawing.counterHeight
                        local lineStart = {x = healthbarOrigin.x, y = healthbarOrigin.y, z = healthbarOrigin.z + zOffset}
                        local dashLength = DFS.supplyDrawing.counterWidth/3
                        if (j*(DFS.supplyDrawing.counterHeight/4))/DFS.supplyDrawing.counterHeight == 0.5 then
                            dashLength = DFS.supplyDrawing.counterWidth/2
                        end
                        local lineEnd = {x = lineStart.x - dashLength, y = lineStart.y, z = lineStart.z}
                        trigger.action.lineToAll(-1, DrawingTools.newMarkId(), lineStart, lineEnd, {1,1,1,1}, 1, true, nil)
                    end
                    local boxSize = DFS.supplyDrawing.counterWidth
                    local healthIconOrigin = {x = healthbarOrigin.x, y = healthbarOrigin.y, z = healthbarOrigin.z - boxSize}
                    DrawingTools.drawHealth(healthIconOrigin, -1, boxSize, true)
                    DFS.updateHealthbar(c)
                end
            end
        end
    end
end
function DFS.updateHealthbar(coalitionId)
    local healthbarZone = trigger.misc.getZone(DFS.spawnNames[coalitionId].healthbar)
    if healthbarZone then
        local healthbarOrigin = healthbarZone.point
        if DFS.supplyDrawing.fillIds.healthbars[coalitionId] == nil or DFS.supplyDrawing.fillIds.healthbars[coalitionId] < 1 then
            local healthIndicatorZOffset = (DFS.status[coalitionId].health/DFS.status.maxHealth)*DFS.supplyDrawing.counterHeight
            local healthIndicatorLineStart = {x = healthbarOrigin.x, y = healthbarOrigin.y, z = healthbarOrigin.z + healthIndicatorZOffset}
            local healthIndicatorLineEnd = {x = healthbarOrigin.x - DFS.supplyDrawing.counterWidth, y = healthbarOrigin.y, z = healthbarOrigin.z + healthIndicatorZOffset}
            local healthFillId = DrawingTools.newMarkId()
            trigger.action.lineToAll(-1, healthFillId, healthIndicatorLineStart, healthIndicatorLineEnd, DFS.supplyDrawing.colors.fill[coalitionId], 1, true, nil)
            DFS.supplyDrawing.fillIds.healthbars[coalitionId] = healthFillId
        else
            trigger.action.setMarkupPositionStart(DFS.supplyDrawing.fillIds.healthbars[coalitionId], {x = healthbarOrigin.x, y = healthbarOrigin.y, z = healthbarOrigin.z + (DFS.status[coalitionId].health/DFS.status.maxHealth)*DFS.supplyDrawing.counterHeight})
            trigger.action.setMarkupPositionEnd(DFS.supplyDrawing.fillIds.healthbars[coalitionId], {x = healthbarOrigin.x - DFS.supplyDrawing.counterWidth, y = healthbarOrigin.y, z = healthbarOrigin.z + (DFS.status[coalitionId].health/DFS.status.maxHealth)*DFS.supplyDrawing.counterHeight})
        end
    end
end
function dfc.drawSupplyMarks()
    if DrawingTools then
       for a = 1,2 do
            for i = 1, 3 do
                local pickupZone = trigger.misc.getZone(DFS.pickUpZones[a][i])
                if pickupZone then
                    local pickupPoint = pickupZone.point
                    DrawingTools.drawPackage(pickupPoint, i, true, a)
                end
            end
            for i = 1, DFS.status.fdSpawnTotal do
                local fdZone = trigger.misc.getZone(DFS.spawnNames[a].depot..i)
                if fdZone then
                    local fdPoint = fdZone.point
                    DrawingTools.drawPackage(fdPoint, 1, false, a)
                end
            end
            for i = 1, DFS.status.rdSpawnTotal do
                local rdZone = trigger.misc.getZone(DFS.spawnNames[a].reardepot .. "1-" ..i)
                if rdZone then
                    local rdPoint = rdZone.point
                    DrawingTools.drawPackage(rdPoint, 1, false, a)
                end
            end
       end
    end
end
--type, groupName
function dfc.spawnSupply(param)
    local transporterGroup = Group.getByName(param.groupName)
    if transporterGroup then
        local transporterUnit = transporterGroup:getUnit(1)
        local transporterCoalition = transporterUnit:getCoalition()
        if transporterUnit then
            local pickupLocation = transporterUnit:getPoint()
            local pickUpZone = dfc.findPickupZone(pickupLocation, transporterCoalition)
            if pickUpZone then
                local frontPickup = string.find(pickUpZone, "FrontDepot")
                local piratePickup = string.find(pickUpZone, 'Pirate')
                local canSpawnCargo = dfc.canSpawnCargo(param.type, transporterCoalition, frontPickup, param.modifier, piratePickup)
                local seaPickup = string.find(pickUpZone, 'Sea')
                if seaPickup or canSpawnCargo then
                    local cargo = dfc.spawnStatic(param.type, trigger.misc.getZone(pickUpZone).point, transporterUnit:getCountry(), param.modifier)
                    if piratePickup then
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        dfc.decreasePirateSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                    elseif not seaPickup and not frontPickup then
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        dfc.decreaseRearSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                    elseif frontPickup then
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        dfc.decreaseFrontSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                    end
                    --env.info("Tracking cargo: " .. cargo:getName(), false)
                    dfc.trackCargo({coalition = transporterCoalition, cargo = cargo, supplyType = param.type, spawnTime = timer:getTime(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), isSlung = true, modifier = param.modifier, groupName = param.groupName})
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
function dfc.loadInternalCargo(param)
    local transporterGroup = Group.getByName(param.groupName)
    if transporterGroup then
        local transporterUnit = transporterGroup:getUnit(1)
        local transporterCoalition = transporterUnit:getCoalition()
        local transporterTable = DFS.helos[param.groupName]
        if transporterUnit and transporterTable then
            if transporterTable.cargo.volumeUsed + DFS.cargoVolumes[param.type] <= DFS.heloCapacities[transporterUnit:getTypeName()].volume and DFS.heloCapacities[transporterUnit:getTypeName()].types[DFS.supplyNames[param.type]] and dfc.canLoad(transporterCoalition, transporterUnit, param.type == DFS.supplyType.MORTAR_SQUAD) then
                local pickupLocation = transporterUnit:getPoint()
                local pickUpZone = dfc.findPickupZone(pickupLocation, transporterCoalition)
                if pickUpZone then
                    local frontPickup = string.find(pickUpZone, "FrontDepot")
                    local piratePickup = string.find(pickUpZone, 'Pirate')
                    local canSpawnCargo = dfc.canSpawnCargo(param.type, transporterCoalition, frontPickup, param.modifier, piratePickup)
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
                        if dfc.isTroops(param.type) then menuForDrop = transporterTable.troopsMenu end
                        if param.type == DFS.supplyType.SF then
                            missionCommands.addCommandForGroup(transporterGroup:getID(), "Begin Fast Rope (60s)", {}, FR.ropeLoop, {groupName = param.groupName, startTime = 0})
                        end
                        missionCommands.addCommandForGroup(transporterGroup:getID(), "Drop " .. DFS.supplyNames[param.type], menuForDrop, dfc.unloadInternalCargo, {point = {x = pickupLocation.x + 6, y = pickupLocation.y, z = pickupLocation.z + 6}, groupName = param.groupName, type = param.type, country = transporterUnit:getCountry(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), coalition = transporterCoalition, removeCommand = "Drop " .. DFS.supplyNames[param.type]})
                        if transporterTable.cargo.carrying == false then
                            missionCommands.addCommandForGroup(transporterGroup:getID(), "Unload All", transporterTable.dropMenu, dfc.unloadInternalCargo, {point = {x = pickupLocation.x + 6, y = pickupLocation.y, z = pickupLocation.z + 6}, groupName = param.groupName, type = "ALL", country = transporterUnit:getCountry(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), coalition = transporterCoalition, removeCommand = "Unload All"})
                        else
                            missionCommands.removeItemForGroup(transporterGroup:getID(), {[1] = "Cargo/Troop Transport", [2] = "Internal Cargo", [3] = "Unload All"})
                            missionCommands.addCommandForGroup(transporterGroup:getID(), "Unload All", transporterTable.dropMenu, dfc.unloadInternalCargo, {point = {x = pickupLocation.x + 6, y = pickupLocation.y, z = pickupLocation.z + 6}, groupName = param.groupName, type = "ALL", country = transporterUnit:getCountry(), seaPickup = seaPickup, frontPickup = frontPickup, groupId = transporterGroup:getID(), coalition = transporterCoalition, removeCommand = "Unload All"})
                        end
                        transporterTable.cargo.carrying = true
                        local decreaseType = param.type
                        if param.type == DFS.supplyType.GUN then decreaseType = DFS.supplyType.EQUIPMENT end
                        if dfc.isTroops(param.type) then decreaseType = DFS.supplyType.EQUIPMENT end
                        if piratePickup then
                            dfc.decreasePirateSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                        elseif not seaPickup and not frontPickup then
                            dfc.decreaseRearSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
                        elseif frontPickup then
                            dfc.decreaseFrontSupply({coalitionId = transporterCoalition,  amount = (DFS.status.playerResupplyAmts[param.type][param.modifier]), type = decreaseType})
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
                                    dfc.reloadMortarBase(transporterGroup:getName(), closestFbIdx, transporterCoalition)
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
function dfc.unloadInternalCargo(param)
    local transporterGroup = Group.getByName(param.groupName)
    if transporterGroup then
        local transporterUnit = transporterGroup:getUnit(1)
        if dfc.landed(param.groupName) and transporterUnit and transporterUnit:getPoint() then
            local unloadPoint = transporterUnit:getPoint()
            unloadPoint.x = unloadPoint.x + 8
            unloadPoint.z = unloadPoint.z + 9
            local transporterTable = DFS.helos[param.groupName]
            if param.type == "ALL" then
                local manifestCopy = Utils.deepcopy(transporterTable.cargo.manifest)
                for i = 1, #manifestCopy do
                    if not dfc.isTroops(manifestCopy[i]) then
                        dfc.unloadInternalCargo({groupName = param.groupName, type = manifestCopy[i], country = transporterUnit:getCountry(), seaPickup = param.seaPickup, frontPickup = param.frontPickup, groupId = transporterGroup:getID(), coalition = param.coalition, removeCommand = "Drop " ..  DFS.supplyNames[manifestCopy[i]]})
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
                if dfc.isTroops(param.type) then
                    dfc.troopUnload(param.groupName, param.type, param.ammo)
                else
                    local cargo = dfc.spawnStatic(param.type, unloadPoint, param.country, "small")
                    dfc.trackCargo({coalition = param.coalition, cargo = cargo, supplyType = param.type, spawnTime = timer:getTime(), seaPickup = param.seaPickup, frontPickup = param.frontPickup, groupId = param.groupId, isSlung = nil, modifier = "small", groupName = param.groupName})
                end
                local secondLevel = "Internal Cargo"
                if dfc.isTroops(param.type) then
                    secondLevel = "Troop Transportation"
                end
                missionCommands.removeItemForGroup(param.groupId, {[1] = "Cargo/Troop Transport", [2] = secondLevel, [3] = param.removeCommand})
            end
        end
    end
end
function dfc.isTroops(supplyType)
    return DFS.troopSupplyTypes[supplyType]
end
function dfc.internalCargoStatus(groupName)
    local statusGroup = Group.getByName(groupName)
    if statusGroup then
        local groupId = statusGroup:getID()
        local cargoTable = DFS.helos[groupName]
        if cargoTable then
            trigger.action.outTextForGroup(groupId, "Carrying " .. cargoTable.addedMass .. " kg\nUsing " .. math.floor((cargoTable.cargo.volumeUsed/DFS.heloCapacities[cargoTable.typeName].volume)*100) .."% capacity", 15)
        else
            --trigger.action.outTextForGroup(groupId, "This should not happen. Ping EatLeadCobra on the WWX discord please", 30)
        end
    end
end
function DFS.troopUnloadExternal(droppingGroupName, troopType, ammo)
    dfc.troopUnload(droppingGroupName, troopType, ammo)
end
function dfc.troopUnload(droppingGroupName, troopType, ammo)
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
                local closestDepot = dfc.findClosestDepot(droppingPoint, droppingGroup:getCoalition())
                local pickupZone = dfc.findPickupZone(droppingPoint, droppingGroup:getCoalition())
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
                    dfc.deliverToDepot(deliverRearDepot, droppingGroup:getCoalition(), DFS.supplyType.SF, "small", piratePickup)
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
                            dfc.hvbss(sfGroup, droppingPoint, droppingGroup:getCoalition(), droppingGroup:getID(), droppingPlayerName)
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
                        timer.scheduleFunction(dfc.destroyGroup, truckGroup, timer:getTime() + 135)
                    elseif troopType ==  DFS.supplyType.CE then
                        local minePoint = Utils.VectorAdd(droppingPoint, Utils.ScalarMult(droppingPos.x, 15))
                        Mine.spawnPublic(minePoint, droppingPos)
                    end
                end
            end
        end
    end
end
function dfc.canLoad(coalition, unit, isMortar)
    local canLoad = false
    local unitPoint = unit:getPoint()
    local unitVelo = unit:getVelocity()
    if unitPoint and unitVelo then
        local pickUpZone = dfc.findPickupZone(unitPoint, coalition)
        if (pickUpZone and dfc.landed(unit:getGroup():getName())) or (isMortar and dfc.landed(unit:getGroup():getName())) then
            canLoad = true
        elseif pickUpZone == nil and isMortar == false then
            trigger.action.outTextForGroup(unit:getGroup():getID(), "You are not close enough to a pick up zone to load cargo!", 5)
        end
    end
    return canLoad
end
function dfc.landed(groupName)
    local landed = false
    local loadingGroup = Group.getByName(groupName)
    if loadingGroup then
        local loadingUnit = loadingGroup:getUnit(1)
        if loadingUnit then
            local velocity = loadingUnit:getVelocity()
            if velocity.x < 0.5 and velocity.z < 0.5 and velocity.y < 0.5 and dfc.getAGL(loadingUnit:getPoint()) <= 5  or not loadingUnit:inAir() then
                landed = true
            else
                trigger.action.outTextForGroup(loadingGroup:getID(), "Cannot load/unload cargo while moving!", 10)
            end
        end
    end
    return landed
end
function dfc.hvbss(boardingGroupName, dropPoint, boardingCoalition, droppingGroupID, droppingPlayerName)
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
                    timer.scheduleFunction(dfc.startBoat, closestShip.groupName, timer:getTime()+305)
                    trigger.action.outTextForGroup(droppingGroupID, "Marines are securing ship and cargo!\nShip will be rigged to explode in 5 minutes", 30, false)
                    timer.scheduleFunction(dfc.destroyGroup, boardingGroupName, timer:getTime()+125)
                    timer.scheduleFunction(dfc.cargoBoat, {shipName = closestShip.groupName, boardingCoalition = boardingCoalition, boardingGroupName = boardingGroupName, boardingPlayerName = droppingPlayerName}, timer:getTime()+120)
                end
            end
        end
    end
end
function dfc.destroyShip(shipName)
    local shipGroup = Group.getByName(shipName)
    if shipGroup then
        local shipUnit = shipGroup:getUnit(1)
        if shipUnit then
            local shipPoint = shipUnit:getPoint()
            if shipPoint then
                trigger.action.explosion(shipPoint, 550)
            end
        end
    end
end
-- shipName, boatSpawnPoint, explFuncId
function dfc.cargoBoat(param)
    if param.boardingPlayerName == nil then param.boardingPlayerName = "Name not found" end
    if Group.getByName(param.boardingGroupName) then
        local shipGroup = Group.getByName(param.shipName)
        if shipGroup then
            local shipUnit = shipGroup:getUnit(1)
            if shipUnit then
                local shipPoint = shipUnit:getPoint()
                local shipPos = shipUnit:getPosition()
                if shipPoint and shipPos then
                    local boatSpawnPoint = Utils.VectorAdd(shipPoint, Utils.ScalarMult(Utils.RotateVector(shipPos.x, -0.26), -100))
                    local pirateBoatName = FirebaseGroups.spawnPirateBoat(boatSpawnPoint, param.boardingCoalition)
                    if WWEvents then
                        WWEvents.playerCapturedShip(param.boardingPlayerName, param.boardingCoalition, " captured a cargo ship!")
                    end
                    timer.scheduleFunction(dfc.destroyShip, param.shipName, timer:getTime() + 180)
                    dfc.checkPirate({convoyName = pirateBoatName, playerName = param.boardingPlayerName, boardingCoalition = param.boardingCoalition })
                end
            end
        end
    end
end
function dfc.startBoat(boatName)
    local pirateGroup = Group.getByName(boatName)
    if pirateGroup then
        pirateGroup:getController():setOnOff(true)
    end
end

function dfc.findPickupZone(location, coalition)
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
function dfc.canSpawnCargo(type, transporterCoalition, isFront, modifier, piratePickup)
    if type == DFS.supplyType["GUN"] or dfc.isTroops(type) then
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
function dfc.getAGL(point)
    local alt = point.y
    local land = land.getHeight({x = point.x, y = point.z}) or 0
    if land < 0 then land = 0 end
    alt = alt - land
    return alt
end
--coalition, cargo, spawnTime
function dfc.trackCargo(param)
    env.info("Tracking cargo: " .. param.cargo, false)
    local cargo = StaticObject.getByName(param.cargo)
    local pickupZone = DFS.pickUpZones[param.coalition][1]
    if param.seaPickup then pickupZone = DFS.pickUpZones[param.coalition][2] end
    if cargo and cargo.getPoint and cargo:getPoint() then
        local closestDepotToCargo = dfc.findClosestDepot(cargo:getPoint(), param.coalition)
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
                    dfc.deliverToDepot(closestDepotToCargo, param.coalition, param.supplyType, param.modifier)
                end
                if cargo and cargo:isExist() then cargo:destroy() end
            elseif timer:getTime() - param.spawnTime > 1800 and Utils.PointDistance(cargo:getPoint(),trigger.misc.getZone(pickupZone).point) < 30 then
                env.info("cargo never left pickup area: " .. param.cargo, false)
                if not param.seaPickup then
                    env.info("un-picked up cargo reclaimed: " .. param.cargo, false)
                    local reclaimType = param.supplyType
                    if reclaimType == 4 then reclaimType = 3 end
                    dfc.increaseRearSupply({coalitionId = param.coalition, amount = DFS.status.playerResupplyAmts[param.supplyType][param.modifier], type = reclaimType})
                end
                if cargo and cargo:isExist() then cargo:destroy() end
            else
                local velocity = cargo:getVelocity()
                local altitude = dfc.getAGL(cargo:getPoint())
                local chinookCargo = false
                local deliverGroup = Group.getByName(param.groupName)
                if deliverGroup then
                    local deliverUnit = deliverGroup:getUnit(1)
                    if deliverUnit then
                        chinookCargo = deliverUnit:getTypeName() == "CH-47Fbl1"
                    end
                end
                env.info("cargo alt AGL: " .. altitude, false)
                env.info("cargo " .. param.cargo .. " velocity x: " .. velocity.x .. " y: " .. velocity.y .. " z: " .. velocity.z, false)
                env.info("chinook cargo: " .. tostring(chinookCargo), false)
                if (chinookCargo == false and velocity.x < 0.01 and velocity.z < 0.01 and velocity.y < 0.01 and (altitude < 1)) or ( chinookCargo == true and velocity.x < 0.01 and velocity.z < 0.01 and velocity.y < 0.01 and (altitude < 0.2)) then
                    env.info("cargo not moving", false)
                    env.info(param.cargo .. ": closest depot distance: " .. closestDepotToCargo.distance, false)
                    env.info(param.cargo .. ": closest depot is rear: " .. tostring(closestDepotToCargo.isRear), false)
                    env.info(param.cargo .. ": sea pickup: " .. tostring(param.seaPickup), false)
                    env.info(param.cargo .. ": front Pickup: " .. tostring(param.frontPickup), false)
                    if distanceToClosestFb then
                        env.info(param.cargo .. ": closest firebase distance: " .. distanceToClosestFb, false)
                    end
                    if (param.frontPickup == nil or param.frontPickup == false) and (closestDepotToCargo.distance <= DFS.status.playerDeliverRadius or (closestDepotToCargo.isRear and param.seaPickup and closestDepotToCargo.distance <= 2000)) then
                        env.info("Group: " .. param.groupId .. "-" .. param.groupName .. " delivered " .. param.cargo .. " to " .. closestDepotToCargo.depotName, false)
                        local deliverType = "FRONT"
                        if closestDepotToCargo.isRear then deliverType = "REAR" end
                        dfc.supplyEvent(param.groupName, param.supplyType, deliverType)
                        trigger.action.outTextForGroup(param.groupId, DFS.supplyNames[param.supplyType] .. " delivered!", 15, false)
                        dfc.deliverToDepot(closestDepotToCargo.isRear, param.coalition, param.supplyType, param.modifier)
                        --if cargo and cargo:isExist() then cargo:destroy() end
                        return
                    elseif distanceToClosestFb and distanceToClosestFb <= DFS.status.playerDeliverRadius and closestFirebaseToCargo and param.supplyType == DFS.supplyType["AMMO"] then
                        Firebases.resupplyFirebase(Firebases[closestFirebaseToCargo], DFS.status.playerResupplyAmts[param.supplyType][param.modifier])
                        dfc.supplyEvent(param.groupName, param.supplyType, "FIREBASE")
                        env.info("Group: " .. param.groupId .. " delivered " .. param.cargo .. " to firebase", false)
                        trigger.action.outTextForGroup(param.groupId,"Ammo delivered to firebase!", 10, false)
                        --if cargo and cargo:isExist() then cargo:destroy() end
                        return
                    elseif distanceToClosestFb and distanceToClosestFb <= DFS.status.playerDeliverRadius and closestFirebaseToCargo and param.supplyType == DFS.supplyType["GUN"] then
                        Firebases.addGroupToFirebase(Firebases[closestFirebaseToCargo], Firebases[closestFirebaseToCargo].fbType)
                        dfc.supplyEvent(param.groupName, param.supplyType, "FIREBASE")
                        env.info("Group: " .. param.groupId .. " delivered " .. param.cargo .. " to firebase", false)
                        trigger.action.outTextForGroup(param.groupId, "Gun delivered to firebase!", 10, false)
                        --if cargo and cargo:isExist() then cargo:destroy() end
                        return
                    elseif timer:getTime() - param.spawnTime > 29 and closestFirebaseToCargo == -1 and dfc.findPickupZone(cargo:getPoint(), param.coalition) == nil and param.supplyType == DFS.supplyType["GUN"] then
                        env.info("Group: " .. param.groupId .. " deployed howitzer firebase", false)
                        Firebases.deployStatic(cargo:getName(), "HOWITZER")
                        --if cargo and cargo:isExist() then cargo:destroy() end
                    else
                        timer.scheduleFunction(dfc.trackCargo, param, timer:getTime() + 10)
                    end
                else
                    timer.scheduleFunction(dfc.trackCargo, param, timer:getTime() + 10)
                end
            end
        end
    end
end
function dfc.deliverToDepot(isRear, coalition, supplyType, modifier, piratePickup)
    if coalition and supplyType and modifier then
        local resupType = supplyType
        if supplyType == DFS.supplyType.GUN or dfc.isTroops(supplyType) then
            resupType = DFS.supplyType.EQUIPMENT
        end
        if isRear then
            dfc.increaseRearSupply({coalitionId = coalition, amount = math.floor(DFS.status.playerResupplyAmts[supplyType][modifier]), type = resupType})
        elseif piratePickup then
            dfc.increasePirateSupply({coalitionId = coalition, amount = math.floor(DFS.status.playerResupplyAmts[supplyType][modifier]), type = resupType})
        else
            dfc.increaseFrontSupply({coalitionId = coalition, amount = math.floor(DFS.status.playerResupplyAmts[supplyType][modifier]), type = resupType})
        end
    else
        env.info("Error delivering to depot. coalition nil: "..tostring(coalition==nil).." supplyType nil: "..tostring(supplyType==nil)" modifier nil: "..tostring(modifier==nil), false)
    end
end
function dfc.supplyEvent(deliverGroupName, supplyType, deliveryLocation)
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
function dfc.findClosestDepot(location, coalition)
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
function dfc.spawnStatic(type, point, country, modifier)
    local staticName = nil
    local id = DFS.status.cargoId
    DFS.status.cargoId = DFS.status.cargoId + 1
    local cargoPoint = point
    local staticTemplate = dfc.copyTemplate(DFS.templates[type][modifier])
    staticTemplate["name"] = DFS.supplyNames[type].."-"..country.."-"..id
    staticName = staticTemplate["name"]
    staticTemplate["y"] = cargoPoint.z + math.random(-5,5)
    staticTemplate["x"] = cargoPoint.x + math.random(-5,5)
    coalition.addStaticObject(country, staticTemplate)
    return staticName
end
function dfc.spawnStaticPrecise(type, point, country, modifier)
    local staticName = nil
    local id = DFS.status.cargoId
    DFS.status.cargoId = DFS.status.cargoId + 1
    local cargoPoint = point
    local staticTemplate = dfc.copyTemplate(DFS.templates[type][modifier])
    staticTemplate["name"] = DFS.supplyNames[type].."-"..country.."-"..id
    staticName = staticTemplate["name"]
    staticTemplate["y"] = cargoPoint.z
    staticTemplate["x"] = cargoPoint.x
    coalition.addStaticObject(country, staticTemplate)
    return staticName
end
function dfc.reloadMortarBase(groupName, baseIndex, coalitionId)
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
                missionCommands.addCommandForGroup(pickupGroup:getID(), "Drop " .. DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD], transporterTable.troopsMenu, dfc.unloadInternalCargo, {groupName = groupName, type = DFS.supplyType.MORTAR_SQUAD, country = pickupUnit:getCountry(), seaPickup = false, frontPickup = false, groupId = pickupGroup:getID(), coalition = coalitionId, removeCommand = "Drop " .. DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD], ammo = closestBase.contents.ammo})
                trigger.action.outTextForGroup(pickupGroup:getID(), "Loaded " .. DFS.supplyNames[DFS.supplyType.MORTAR_SQUAD],5, false)
                Firebases.destroyFirebase(closestBase)
            else
                trigger.action.outTextForGroup(pickupGroup:getID(), "You do not have enough space to load a mortar squad!", 5, false)
            end
        end
    end
end
function dfc.copyTemplate(templateTable)
    local newTable = {}
    for k,v in pairs(templateTable) do
        if type(v) == "table" then
            newTable[k] = dfc.copyTemplate(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end
function dfc.addRadioCommandsForGroup(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup then
        if Sonobuoys then
            Sonobuoys.addRadioCommandsForFixedWingGroup(groupName)
        end
        if MAD then
            MAD.addCommand(groupName)
        end
    end
end
function dfc.addRadioCommandsForCargoGroup(groupName)
    local addGroup = Group.getByName(groupName)
    if addGroup then
        local cargoMenu = missionCommands.addSubMenuForGroup(addGroup:getID(), "Cargo/Troop Transport", nil)
        local slingMenu = missionCommands.addSubMenuForGroup(addGroup:getID(), "Sling Loading", cargoMenu)
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Fuel - Large " .. DFS.status.playerResupplyAmts[DFS.supplyType.FUEL].big, slingMenu, dfc.spawnSupply, {type = DFS.supplyType.FUEL, groupName = groupName, modifier = "big"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Fuel - Small " .. math.floor(DFS.status.playerResupplyAmts[DFS.supplyType.FUEL].small), slingMenu, dfc.spawnSupply, {type = DFS.supplyType.FUEL, groupName = groupName, modifier = "small"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Ammo - Large " .. DFS.status.playerResupplyAmts[DFS.supplyType.AMMO].big, slingMenu, dfc.spawnSupply, {type = DFS.supplyType.AMMO, groupName = groupName, modifier = "big"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Ammo - Small " .. math.floor(DFS.status.playerResupplyAmts[DFS.supplyType.AMMO].small), slingMenu, dfc.spawnSupply, {type = DFS.supplyType.AMMO, groupName = groupName, modifier = "small"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Equipment - Large " .. DFS.status.playerResupplyAmts[DFS.supplyType.EQUIPMENT].big, slingMenu, dfc.spawnSupply, {type = DFS.supplyType.EQUIPMENT, groupName = groupName, modifier = "big"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Equipment - Small " .. math.floor(DFS.status.playerResupplyAmts[DFS.supplyType.EQUIPMENT].small), slingMenu, dfc.spawnSupply, {type = DFS.supplyType.EQUIPMENT, groupName = groupName, modifier = "small"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Transport Gun - 3 Equipment", slingMenu, dfc.spawnSupply, {type = DFS.supplyType.GUN, groupName = groupName, modifier = "big"})
        local internalCargoMenu = missionCommands.addSubMenuForGroup(addGroup:getID(), "Internal Cargo", cargoMenu)
        if addGroup:getUnit(1):getTypeName() ~= "CH-47Fbl1" then
            missionCommands.addCommandForGroup(addGroup:getID(), "Internal Cargo Status", internalCargoMenu, dfc.internalCargoStatus, groupName)
            missionCommands.addCommandForGroup(addGroup:getID(), "Transport Fuel " .. DFS.status.playerResupplyAmts[DFS.supplyType.FUEL].small, internalCargoMenu, dfc.loadInternalCargo, {type = DFS.supplyType.FUEL, groupName = groupName, modifier = "small"})
            missionCommands.addCommandForGroup(addGroup:getID(), "Transport Ammo " .. DFS.status.playerResupplyAmts[DFS.supplyType.AMMO].small, internalCargoMenu, dfc.loadInternalCargo, {type = DFS.supplyType.AMMO, groupName = groupName, modifier = "small"})
            missionCommands.addCommandForGroup(addGroup:getID(), "Transport Equipment " .. DFS.status.playerResupplyAmts[DFS.supplyType.EQUIPMENT].small, internalCargoMenu, dfc.loadInternalCargo, {type = DFS.supplyType.EQUIPMENT, groupName = groupName, modifier = "small"})
        else
            missionCommands.addCommandForGroup(addGroup:getID(), "Chinooks Load Slinging Cargo Through Re-arm Menu", internalCargoMenu, dfc.doNothing, nil)
        end
        local troopsMenu = missionCommands.addSubMenuForGroup(addGroup:getID(), "Troop Transportation", cargoMenu)
        missionCommands.addCommandForGroup(addGroup:getID(), "Internal Troop Status", troopsMenu, dfc.internalCargoStatus, groupName)
        missionCommands.addCommandForGroup(addGroup:getID(), "Carry Mortar Squad - 5 Equipment", troopsMenu, dfc.loadInternalCargo, {type = DFS.supplyType.MORTAR_SQUAD, groupName = groupName, modifier = "small"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Carry Special Forces Squad - 2 Equipment", troopsMenu, dfc.loadInternalCargo, {type = DFS.supplyType.SF, groupName = groupName, modifier = "small"})
        missionCommands.addCommandForGroup(addGroup:getID(), "Carry Combat Eng. Squad (Landmine) - 0 Equipment", troopsMenu, dfc.loadInternalCargo, {type = DFS.supplyType.CE, groupName = groupName, modifier = "small"})
        return internalCargoMenu, troopsMenu
    end
end
function dfc.doNothing()
    return
end
function dfc.addGroupToCargoList(groupName, dropMenu, troopsMenu)
    local addGroup = Group.getByName(groupName)
    if addGroup then
        local addUnit = addGroup:getUnit(1)
        if addUnit then
            local heloTypeName = addUnit:getTypeName()
            if DFS.heloCapacities[heloTypeName] then
                local heloTable = {
                    id = #DFS.helos+1,
                    dropMenu = dropMenu,
                    troopsMenu = troopsMenu,
                    typeName = heloTypeName,
                    addedMass = 0,
                    cargo = {
                        carrying = false,
                        cargoType = DFS.supplyType.AMMO,
                        volumeUsed = 0
                    }
                }
                DFS.helos[groupName] = heloTable
            end
        end
    end
end
function dfc.makeAirfieldsNonCapturable()
    local airbases = world.getAirbases()
    for i = 1, #airbases do
        airbases[i]:autoCapture(false)
    end
end
if debug then missionCommands.addCommand('End Mission', nil, dfc.endMission, 1) end

world.addEventHandler(dfcEvents)
dfc.makeAirfieldsNonCapturable()
dfc.getMission()
dfc.getData()
dfc.createSupplyDrawings()
dfc.initSpawns()
dfc.initConvoys()
dfc.startShipping()
timer.scheduleFunction(dfc.bomberLoop, nil, timer.getTime()+DFS.status.bomberInterval)
dfc.mainLoop()
dfc.supplyConsumptionLoop()
dfc.upgradeLoop()
--dfc.downgradeLoop()
dfc.saveLoop()
dfc.drawSupplyMarks()
dfc.drawHealthBars()
--dfc.supplyDrawingRefreshLoop()
dfc.isItSunset()
--dfc.casLoop()