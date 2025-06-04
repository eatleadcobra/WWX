trigger.action.setUserFlag("MISSION_ID", 3)
-- enabled features
SUBS = false
CAP = true
PIRACY = false
BOMBERS = true
MISSILEBOATS = true
CARGO = true
CSAR = true
CAS = true
-- counts
FDCount = 2
AACount = 6
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 225
REDCASFREQ = 45
BLUECASMOD = 0
REDCASMOD = 1

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-72B",
            [2] = "T-72B",
            [3] = "GAZ-66"
        },
        ["Mech"] = {
            [1] = "BTR_D",
            [2] = "BTR_D",
            [3] = "BMP-1",
            [4] = "GAZ-66"
        },
        ["Inf"] = {
            [1] = "BTR_D",
            [2] = "BTR-80",
            [3] = "BTR-80",
            [4] = "GAZ-66",
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
            --[1] = "Strela-1 9P31",
            [1] = "ZSU-23-4 Shilka",
            [2] = "GAZ-66"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Leopard1A3",
            [2] = "Leopard1A3",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "Marder",
            [3] = "Marder",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "TPZ",
            [3] = "TPZ",
            [4] = "M 818"
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
            [1] = "TPZ",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "TPZ",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "TPZ",
            [2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Bedford_MWD",
            [5] = "Bedford_MWD",
            [6] = "Bedford_MWD",
            [7] = "TPZ",
            [8] = "Bedford_MWD",
        },
        ["EquipmentConvoy"] = {
            [1] = "TPZ",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "TPZ",
            [8] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "Vulcan",
            [2] = "M 818"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["Marder"] = "IFV",
    ["BMP-1"] = "IFV",
    ["TPZ"] = "APC",
    ["BTR-80"] = "APC",
}