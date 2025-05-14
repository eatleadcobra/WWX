SUBS = false
AMBUSHES = false
CAP = false
BOMBERS = true
FDCount = 2
AACount = 6

-- template definitions
PlatoonTypes = {
    [1] = "Armor",
    [2] = "Mech",
    [3] = "Inf",
    [4] = "FuelConvoy",
    [5] = "AmmoConvoy",
    [6] = "EquipmentConvoy"
}
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
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "M2A1_halftrack",
            [8] = "M978 HEMTT Tanker",
        }
    },
    [2] = {
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
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "M2A1_halftrack",
            [8] = "M978 HEMTT Tanker",
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["M-113"] = "IFV",
    ["M2A1_halftrack"] = "APC",
}