-- enabled features
SUBS = true
CAP = true
BOMBERS = true
PIRACY = true
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
-- counts
FDCount = 2
AACount = 8
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "M4_Sherman",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "M-113",
            [2] = "M-113",
            [3] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "M2A1_halftrack",
            [2] = "M2A1_halftrack",
            [3] = "Bedford_MWD"
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver2",
            [2] = "Infantry AK ver2",
            [3] = "Soldier M249",
            [4] = "Infantry AK ver2",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK ver2",
            [7] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "M2A1_halftrack",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "M2A1_halftrack",
            [8] = "M978 HEMTT Tanker",
        },
        ["EquipmentConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "FuelTruck",
            [3] = "FuelTruck",
            [4] = "FuelTruck",
            [5] = "FuelTruck",
            [6] = "FuelTruck",
            [7] = "M2A1_halftrack",
            [8] = "FuelTruck",
        }
    },
    [2] = {

    }
}
Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "M4_Sherman",
            [3] = "GAZ-66"
        },
        ["Mech"] = {
            [1] = "M113",
            [2] = "Land_Rover_101_FC",
            [4] = "GAZ-66"
        },
        ["Inf"] = {
            [1] = "M2A1_halftrack",
            [2] = "Land_Rover_101_FC",
            [3] = "GAZ-66",
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver2",
            [2] = "Infantry AK ver2",
            [3] = "Soldier M249",
            [4] = "Infantry AK ver2",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "BTR-80",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "BTR-80",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "BTR-80",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "BTR-80",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "BTR-80",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "KAMAZ Truck",
            [5] = "KAMAZ Truck",
            [6] = "KAMAZ Truck",
            [7] = "BTR-80",
            [8] = "KAMAZ Truck",
        },
        ["EmbeddedAD"] = {
            [1] = "Strela-1 9P31",
            [2] = "ZSU-23-4 Shilka",
            [3] = "GAZ-66"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Leopard1A3",
            [2] = "Leopard1A3",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "Marder",
            [2] = "Marder",
            [3] = "M1045 HMMWV TOW",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "TPZ",
            [2] = "Land_Rover_101_FC",
            [3] = "M 818"
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver2",
            [2] = "Soldier M249",
            [4] = "Infantry AK ver2",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "M2A1_halftrack",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Bedford_MWD",
            [5] = "Bedford_MWD",
            [6] = "Bedford_MWD",
            [7] = "M2A1_halftrack",
            [8] = "Bedford_MWD",
        },
        ["EquipmentConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "M2A1_halftrack",
            [8] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "M-113",
            [2] = "Vulcan",
            [3] = "Land_Rover_101_FC"
        }
    }
}

PlatoonUnitCarrierTypeNames = {
    ["M-113"] = "IFV",
    ["M2A1_halftrack"] = "APC",
    ["Land_Rover_101_FC"] = "APC"
}