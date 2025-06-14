trigger.action.setUserFlag("MISSION_ID", 2)
-- enabled features
SUBS = true
CAP = false
BOMBERS = true
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
            [2] = "M1045 HMMWV TOW",
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
            [1] = "Paratrooper RPG-16",
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
            [2] = "M1045 HMMWV TOW",
            [3] = "Blitz_36-6700A"
        },
        ["Mech"] = {
            [1] = "Sd_Kfz_251",
            [2] = "Blitz_36-6700A",
        },
        ["Inf"] = {
            [1] = "Blitz_36-6700A",
        },
        ["DeployedInf"] = {
            [1] = "Paratrooper RPG-16",
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
            [1] = "tt_DSHK",
            [3] = "GAZ-66"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply"
        }
    }
}

PlatoonUnitCarrierTypeNames = {
    ["Land_Rover_101_FC"] = "APC",
    ["Bedford_MWD"] = "APC",
    ["Blitz_36-6700A"] =  "APC",
}

PlatoonFlakCarrierTypeNames = {
    [""] = "FLAK"
}


PltStrengths = {
    [1] = 8,
    [2] = 3 + #Platoons[1]["DeployedInf"],
    [3] = 2 + #Platoons[1]["DeployedInf"],
    [7] = 1
}
PltCosts = {
    [1] = {
        [1] = 5, --fuel
        [2] = 9, --ammo
        [3] = 3, --equipment
    },
    [2] = {
        [1] = 3, --fuel
        [2] = 4, --ammo
        [3] = 2, --equipment
    },
    [3] = {
        [1] = 1, --fuel
        [2] = 2, --ammo
        [3] = 1, --equipment
    },
    [7] = {
        [1] = 4, --fuel
        [2] = 2, --ammo
        [3] = 1, --equipment
    },
}
CompanyCompTiers = {
    [0] = {composition = nil},
    [1] = {
        --tank, apc, AD
        composition = {3,1,3,7},
    },
    [2] = {
        --tank, ifv, AD
        composition = {2,1,3,7},
    },
    [3] = {
        --ifv, apc, AD
        composition = {2,3,3,7},
    },
    [4] = {
        --apc, apc, AD
        composition = {3,3,3,7},
    },
    [5] = {
        --tank, tank, apc
        composition = {1,2,3},
    },
    [6] = {
        --tank, ifv, apc
        composition = {3,1,3},
    },
    [7] = {
        -- ifv, ifv, apc
        composition = {2,3,3},
    },
    [8] = {
        -- ifv, apc, apc
        composition = {3,3,3},
    },
    [9] = {
        -- apc, apc, apc
        composition = {3,3},
    },
}
CSARFreqs = {
    [1] = {
        ["NDB"] = {20,69},
        ["TACAN"] = {10,59}
    },
    [2] = {
        ["NDB"] = {71,120},
        ["TACAN"] = {61,110}
    }
}
CSARBases = {
    [1] = {
        [1] = "Red Forward Field Hospital"
    },
    [2] = {
        [1] = "Blue Forward Field Hospital"
    }
}
CSARFreqCollisions = {
    [1] = {
        ["NDB"] = {
            26,27,29,30,31,32,33,34,35,36,37,39,40,41,42,43,44,45
        },
        ["TACAN"] = {
            21
        }
    },
    [2] = {
        ["NDB"] = {
        },
        ["TACAN"] = {
            79,84,85,106,107
        }
    }
}