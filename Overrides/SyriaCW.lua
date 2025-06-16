trigger.action.setUserFlag("MISSION_ID", 5)
-- enabled features
SUBS = true
CAP = false
PIRACY = false
BOMBERS = false
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
SHIPPING = true
CAPTURE = false
-- counts
FDCount = 2
AACount = 6
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 225
REDCASFREQ = 139
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
            [1] = "Dry-cargo ship-2"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M-60",
            [2] = "M-60",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "M-2 Bradley",
            [3] = "M-2 Bradley",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "M-113",
            [2] = "M-113",
            [3] = "M 818"
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
            [1] = "Dry-cargo ship-2"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["Marder"] = "IFV",
    ["BMP-1"] = "IFV",
    ["TPZ"] = "APC",
    ["BTR-80"] = "APC",
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
        composition = {3,1,1,7},
    },
    [2] = {
        --tank, ifv, apc, AD
        composition = {2,1,3,7},
    },
    [3] = {
        --ifv, ifv, apc, AD
        composition = {2,2,3,7},
    },
    [4] = {
        --ifv, apc, apc, AD
        composition = {2,3,3,7},
    },
    [5] = {
        --tank, tank, apc
        composition = {3,1,3,7},
    },
    [6] = {
        --tank, ifv, apc
        composition = {3,1,2},
    },
    [7] = {
        -- ifv, ifv, apc
        composition = {2,2,3},
    },
    [8] = {
        -- ifv, apc, apc
        composition = {2,3,3},
    },
    [9] = {
        -- apc, apc, apc
        composition = {3,3,3},
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
RandomNames = {}
RandomNames.firstNames = {
    [1] = {
        [1] = {"Ahmed","Mohamed","Mahmoud","Omar","Amr","Muhammad","Mohammed","Youssef","Ahmad","Mostafa","Abdelrahman","Mido","Mustafa","Karim","Abdo","Eslam","Michael","Tarek","Aly","Nour","Medo","Yahya","Daniel","Kareem","Sherif","Miro","Hamada","Abdallah","Khaled","Osama"}
    },
    [2] = {
        [1] = {"Abram","Chaim","Jankel","David","Moshe","Leib","Aron","Yosef","Abraham","Israel","Jacob","Hersch","Moses","Mendel","Wolf","Samuel","Leiser","Jossel","Benjamin","Schmul","Daniel","Ariel","Levi","Noam","Ori"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Mohamed","Ahmed","Hassan","Ali","Mahmoud","Ibrahim","Gamal","Abdel","Mostafa","Salah","Adel","Hussein","Samir","Saad","Soliman","Kamal","Hamdy","Saleh","Salem","Nabil","Youssef","Samy","Said","Fathy","Sayed","Elsayed","Khalil","Aly","Mohammed","Kamel"}
    },
    [2] = {
        [1] = {"Cohen","Levi","Rosenberg","Goldstein","Friedman","Schwartz","Katz","Stein","Weiss","Adler","Rosen","Klein","Shapiro","Berman","Levy","Kaplan","Hirsch","Ben-David","Bernstein","Singer","Rubin","Steinberg","Shulman","Mandel","Mandelbaum"}
    }
}