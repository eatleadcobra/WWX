trigger.action.setUserFlag("MISSION_ID", 4)
-- enabled features
SUBS = false
CAP = false
BOMBERS = false
PIRACY = false
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
SHIPPING = true
CAPTURE = false
-- counts
FDCount = 2
AACount = 8
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 139
REDCASFREQ = 139
BLUECASMOD = 0
REDCASMOD = 0

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "MTLB",
            [2] = "GAZ-66"
        },
        ["Mech"] = {
            [1] = "M2A1_halftrack",
            [2] = "GAZ-66"
        },
        ["Inf"] = {
            [1] = "GAZ-66",
        },
        ["DeployedInf"] = {
            [1] = "Paratrooper RPG-16",
            [2] = "Infantry AK ver2",
            [3] = "Igla manpad INS",
            [4] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "HL_DSHK",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "Ural-375",
            [2] = "Ural-375",
            [3] = "HL_DSHK",
            [4] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "KAMAZ Truck",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "HL_DSHK",
        },
        ["EmbeddedAD"] = {
            [1] = "HL_DSHK",
            [2] = "KAMAZ Truck"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M-113",
            [2] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "tt_DSHK",
            [2] = "Bedford_MWD",
        },
        ["Inf"] = {
            [1] = "Bedford_MWD",
        },
        ["DeployedInf"] = {
            [1] = "Paratrooper RPG-16",
            [2] = "Infantry AK ver2",
            [3] = "Igla manpad INS",
            [4] = "Infantry AK ver2",
        },
        ["FuelConvoy"] = {
            [1] = "M978 HEMTT Tanker",
            [2] = "M978 HEMTT Tanker",
            [3] = "tt_DSHK",
            [4] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "tt_DSHK",
            [2] = "Land_Rover_101_FC",
            [3] = "Land_Rover_101_FC",
            [4] = "Land_Rover_101_FC",
        },
        ["EquipmentConvoy"] = {
            [1] = "M 818",
            [2] = "M 818",
            [3] = "tt_DSHK",
            [4] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "tt_DSHK",
            [2] = "GAZ-66"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply"
        }
    }
}

PlatoonUnitCarrierTypeNames = {
    ["GAZ-66"] = "APC",
    ["Bedford_MWD"] = "APC",
    ["tt_DSHK"] =  "IFV",
    ["HL_DSHK"] = "IFV",
}

PltStrengths = {
    [1] = 15,
    [2] = 4 + #Platoons[1]["DeployedInf"],
    [3] = 3 + #Platoons[1]["DeployedInf"],
    [7] = 2
}
PltCosts = {
    [1] = {
        [1] = 8, --fuel
        [2] = 15, --ammo
        [3] = 4, --equipment
    },
    [2] = {
        [1] = 4, --fuel
        [2] = 4, --ammo
        [3] = 2, --equipment
    },
    [3] = {
        [1] = 3, --fuel
        [2] = 2, --ammo
        [3] = 1, --equipment
    },
    [7] = {
        [1] = 4, --fuel
        [2] = 2, --ammo
        [3] = 2, --equipment
    },
}
CompanyCompTiers = {
    [0] = {composition = nil},
    [1] = {
        --tank, tank, apc, AD
        composition = {1,1},
    },
    [2] = {
        --tank, ifv, apc, AD
        composition = {1,2},
    },
    [3] = {
        --ifv, ifv, apc, AD
        composition = {2,2},
    },
    [4] = {
        --ifv, apc, apc, AD
        composition = {2,3},
    },
    [5] = {
        --tank, tank, apc
        composition = {3,3},
    },
    [6] = {
        --tank, ifv, apc
        composition = {1},
    },
    [7] = {
        -- ifv, ifv, apc
        composition = {2},
    },
    [8] = {
        -- ifv, apc, apc
        composition = {3},
    },
    [9] = {
        -- apc, apc, apc
        composition = {3},
    },
}