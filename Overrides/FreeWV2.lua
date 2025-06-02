trigger.misc.setUserFlag("MISSION_ID", 1)
-- enabled features
SUBS = false
CAP = true
PIRACY = false
BOMBERS = true
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = false
-- counts
FDCount = 2
AACount = 0
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "M2A1_halftrack",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "M2A1_halftrack",
            [3] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "Bedford_MWD",
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver2",
            [2] = "Infantry AK ver2",
            [3] = "Infantry AK ver2",
            [4] = "Paratrooper RPG-16",
            [5] = "Infantry AK ver2",
            [6] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "M2A1_halftrack",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "M2A1_halftrack",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "KAMAZ Truck",
            [5] = "KAMAZ Truck",
            [6] = "KAMAZ Truck",
            [7] = "M2A1_halftrack",
            [8] = "KAMAZ Truck",
        },
        ["EmbeddedAD"] = {
            [1] = "Ural-375 ZU-23",
            [2] = "KAMAZ Truck"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Pz_IV_H",
            [2] = "Sd_Kfz_251",
            [3] = "Blitz_36-6700A"
        },
        ["Mech"] = {
            [1] = "Sd_Kfz_251",
            [2] = "GAZ-66",
        },
        ["Inf"] = {
            [1] = "GAZ-66",
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver2",
            [2] = "Infantry AK ver2",
            [3] = "Infantry AK ver2",
            [4] = "Paratrooper RPG-16",
            [5] = "Infantry AK ver2",
            [6] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "Sd_Kfz_251",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "Sd_Kfz_251",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "Sd_Kfz_251",
            [2] = "GAZ-66",
            [3] = "GAZ-66",
            [4] = "GAZ-66",
            [5] = "GAZ-66",
            [6] = "GAZ-66",
            [7] = "Sd_Kfz_251",
            [8] = "GAZ-66",
        },
        ["EquipmentConvoy"] = {
            [1] = "Sd_Kfz_251",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "Sd_Kfz_251",
            [8] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "Ural-375 ZU-23",
            [2] = "GAZ-66"
        }
    }
}

PlatoonUnitCarrierTypeNames = {
    ["Land_Rover_101_FC"] = "APC",
    ["Bedford_MWD"] = "APC",
    ["Blitz_36-6700A"] =  "APC",
}