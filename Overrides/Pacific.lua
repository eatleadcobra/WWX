trigger.action.setUserFlag("MISSION_ID", 1)
-- enabled features
SUBS = true
CAP = false
BOMBERS = false
PIRACY = false
MISSILEBOATS = false
CARGO = false
CSAR = true
CAS = true
SHIPPING = true
CAPTURE = false
NAVALCONVOY = {
    [1] = false,
    [2] = true,
}
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
            [1] = "Type_89_I_Go",
            [2] = "Type_98_So_Da",
            [3] = "Type_94_Truck"
        },
        ["Mech"] = {
            [1] = "Type_98_Ke_Ni",
            [2] = "Type_98_So_Da",
            [3] = "Type_94_Truck"
        },
        ["Inf"] = {
            [1] = "Type_98_So_Da",
            [2] = "Type_94_Truck"
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
            [1] = "ATZ-5",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "Type_94_25mm_AA_Truck",
            [5] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "Type_94_Truck",
            [2] = "Type_94_25mm_AA_Truck",
            [3] = "Type_94_Truck",
            [4] = "Type_94_Truck",
            [5] = "Type_94_Truck"
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Type_94_Truck"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply"
        }
    },
    [2] = {
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
            [1] = "CastleClass_01",
        },
        ["AmmoConvoy"] = {
            [1] = "CastleClass_01",
        },
        ["EquipmentConvoy"] = {
            [1] = "CastleClass_01",
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
    ["M2A1_halftrack"] = "APC",
    ["Bedford_MWD"] = "APC",
    ["Type_98_So_Da"] =  "APC",
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
        [1] = "Red Field Hospital"
    },
    [2] = {
        [1] = "Blue Field Hospital"
    }
}
CSARFreqCollisions = {
    [1] = {
        ["NDB"] = {},
        ["TACAN"] = {}
    },
    [2] = {
        ["NDB"] = {},
        ["TACAN"] = {}
    }
}
RandomNames = {}
RandomNames.firstNames = {
    [1] = {
        [1] = {"Shōichi","Kiyoshi","Masao","Tadashi","Shigeru","Takeo","Masaharu","Saburō","Ichirō","Shōji","Shōzou","Mamoru","Akitoshi","Takaharu","Masayuki","Taisei","Nobuchika","Haruki","Tatsuki","Genki","Kenta","Kunihiko","Tsubasa","Nao","Ryunosuke"}
    },
    [2] = {
        [1] = {"David","Michael","James","John","Robert","Mark","William","Richard","Thomas","Steven","Timothy","Joseph","Charles","Jeffrey","Kevin","Kenneth","Daniel","Paul","Donald","Brian","Ronald","Gary","Scott","Gregory","Anthony","Edward","Stephen","Larry","Christopher","Douglas","Dennis","Randy","George","Terry","Keith","Mike","Jerry","Ricky","Bruce","Frank","Peter","Craig","Steve","Eric","Patrick","Raymond","Roger","Danny","Jeff","Alan","Andrew"},
        [2] = {"John","William","Ronald","Robert","James","Kenneth","George","Keith","Thomas","Raymond","Arthur","Edward","Frederick","Norman","Jack","Donald","Kevin","Harold","Allan","Charles","Eric","Albert","Reginald","Stanley","Gordon","Henry","Colin","Douglas","Noel","Neville","Bruce","Walter","David","Roy","Ernest","Alfred","Richard","Alan","Leonard","Cecil","Peter","Joseph","Frank","Mervyn","Maxwell","Geoffrey","Patrick","Herbert","Alexander","Brian"},
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Satou","Suzuki","Takahashi","Tanaka","Yamamoto","Nakamura","Watanabe","Itou","Kobayashi","Katou","Yoshida","Yamada","Sasaki","Yamaguchi","Matsumoto","Inoue","Kimura","Hayashi","Shimizu","Yamazaki","Ikeda","Abe","Hashimoto","Yamashita","Mori"}
    },
    [2] = {
        [1] = {"Smith","Johnson","Williams","Jones","Brown","Davis","Miller","Wilson","Moore","Taylor","Anderson","Thomas","Jackson","White","Harris","Martin","Thompson","Robinson","Clark","Lewis","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce"},
        [2] = {"Smith","Williams","Brown","Jones","Wilson","Taylor","Martin","White","King","Johnson","Campbell","Thompson","Anderson","Davis","Mcdonald","Thomas","Kelly","Walker","Ryan","Baker","Green","Mitchell","Moore","Robinson","Harris","Roberts","Hall","Evans","Wright","Edwards","Clarke","Young","Scott","Turner","Cooper","Miller","Cook","Bell","Bailey","Collins","Watson","Cox","Stewart","Hill","Clark","Bennett","Ward","Allen","Wood","Parker"},
    }
}