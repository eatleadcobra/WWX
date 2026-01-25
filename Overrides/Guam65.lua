trigger.action.setUserFlag("MISSION_ID", 8)
-- enabled features
SUBS = false
ACTIVETORP = false
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
CAP = true
PIRACY = false
BOMBERS = true
ESCORT = true
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
STRIKES = true
REAPER = false
INTERCEPT = true
SHIPPING = true
CAPTURE = false
CAVICS = {
    [1] = {
        --[1] = {text = "AT - BRDM", typename = "BRDM-2_malyutka"},
        --[2] = {text = "IFV - BMD-1", typename = "BMD"},
        [1] = {text = "FireSupport - Grad MLRS", typename = "Grad"},--3
        --[4] = {text = "Scout - BRDM", typename = "BRDM"},
        [2] = {text = "Ammo Truck", typename = "Bedford"},--5

    },
    [2] = {
        --[1] = {text = "AT - HMMWV", typename = "TOW"},
        --[2] = {text = "IFV - Scorpion", typename = "Scorpion"},
        [1] = {text = "FireSupport - M270", typename = "M270"},--3
        --[4] = {text = "Scout - Scimitar", typename = "Scimitar"},
        [2] = {text = "Ammo Truck", typename = "Bedford"},--5
    }
}
CAPTUREBASES = {
    --["Agana"] = true,
}
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 43200 -- 12 hours runtime
-- counts
FDCount = 2
AACount = 6
RDSubcount = 2
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 280
REDCASFREQ = 130
BLUECASMOD = 0
REDCASMOD = 0

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-55",
            [2] = "T-55",
            [3] = "Blitz_36-6700A"
        },
        ["Mech"] = {
            [1] = "PT_76",
            [2] = "MTLB",
			[3] = "MTLB",
            [4] = "Blitz_36-6700A"
        },
        ["Inf"] = {
            [1] = "BTR-60",
            [2] = "BTR-60",
            [3] = "Blitz_36-6700A"
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK Ins",
            [2] = "Infantry AK Ins",
            [3] = "Soldier M249",
            [4] = "Infantry AK Ins",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK Ins",
            [7] = "Infantry AK Ins"
        },
        ["FuelConvoy"] = {
            [1] = "UAZ-469",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "UAZ-469",
            [8] = "ATZ-5"
        },
        ["AmmoConvoy"] = {
            [1] = "UAZ-469",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "UAZ-469",
            [8] = "Ural-375"
        },
        ["EquipmentConvoy"] = {
            [1] = "UAZ-469",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "UAZ-469",
            [8] = "Ural-375"
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Blitz_36-6700A"
        },
        ["EmbeddedADHigh"] = {
            [1] = "ZSU-23-4 Shilka",
            [2] = "Blitz_36-6700A"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
            [2] = "leander-gun-ariadne"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M-60",
            [2] = "M-60",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "CHAP_FV101",
            [2] = "M-113",
			[3] = "M-113",
            [4] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "M-113",
            [2] = "M-113",
            [3] = "Bedford_MWD"
        },
        ["DeployedInf"] = {
            [1] = "Soldier M4",
            [2] = "Soldier M4",
            [3] = "Soldier M249",
            [4] = "Soldier M4",
            [5] = "Paratrooper RPG-16",
            [6] = "Soldier M4",
            [7] = "Soldier M4"
        },
        ["FuelConvoy"] = {
            [1] = "Land_Rover_109_S3",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "Land_Rover_109_S3",
            [8] = "M978 HEMTT Tanker"
        },
        ["AmmoConvoy"] = {
            [1] = "Land_Rover_109_S3",
            [2] = "Land_Rover_101_FC",
            [3] = "Land_Rover_101_FC",
            [4] = "Land_Rover_101_FC",
            [5] = "Land_Rover_101_FC",
            [6] = "Land_Rover_101_FC",
            [7] = "Land_Rover_109_S3",
            [8] = "Land_Rover_101_FC"
        },
        ["EquipmentConvoy"] = {
            [1] = "Land_Rover_109_S3",
            [2] = "Land_Rover_101_FC",
            [3] = "Land_Rover_101_FC",
            [4] = "Land_Rover_101_FC",
            [5] = "Land_Rover_101_FC",
            [6] = "Land_Rover_101_FC",
            [7] = "Land_Rover_109_S3",
            [8] = "Land_Rover_101_FC"
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Vulcan",
            [2] = "Bedford_MWD"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            [2] = "leander-gun-ariadne"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["MTLB"] = "IFV",
    --["AAV7"] = "IFV",
    ["BTR-60"] = "APC",
    ["M-113"] = "APC"
}


PltStrengths = {
    [1] = 15,
    [2] = 4 + #Platoons[1]["DeployedInf"],
    [3] = 3 + #Platoons[1]["DeployedInf"],
    [7] = 2,
    [9] = 2
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
    [9] = {
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
        ["NDB"] = {20,59},
        ["TACAN"] = {10,59}
    },
    [2] = {
        ["NDB"] = {60,99},
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
        },
        ["TACAN"] = {
            10
        }
    },
    [2] = {
        ["NDB"] = {
        },
        ["TACAN"] = {
            10
        }
    }
}
RandomNames = {}
RandomNames.firstNames = {
    [1] = {
        [1] = {"Nguyễn","Mai","Nguyễn","Phạm","Đặng","Nguyễn","Lê","Lê","Lưu","Nguyễn","Nguyễn","Nguyễn","Nguyễn","Nguyễn","Vũ","Le","Nguyễn","Nguyễn","Võ"}
    },
    [2] = {
        [1] = {"David","Paul","Andrew","Mark","John","Michael","Stephen","Ian","Robert","Richard","Christopher","Peter","Simon","Anthony","Kevin","Gary","Steven","Martin","James","Philip","Alan","Neil","Nigel","Timothy","Colin","Graham","Jonathan","Nicholas","William","Adrian","Brian","Stuart","Keith","Thomas","Patrick","Sean","Carl","Trevor","Wayne","Shaun","Kenneth","Barry","Derek","Dean","Raymond","Antony","Jeremy","Joseph","Edward","Lee"},
        --[2] = {"Abram","Chaim","Jankel","David","Moshe","Leib","Aron","Yosef","Abraham","Israel","Jacob","Hersch","Moses","Mendel","Wolf","Samuel","Leiser","Jossel","Benjamin","Schmul","Daniel","Ariel","Levi","Noam","Ori"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Văn Cốc","Văn Cường","Hồng Nhị","Thanh Ngâ","Ngọc Ngự","Văn Bảy","Hải","Thanh Đạo","Huy Chao","Đức Soát","Đăng Kính","Ngọc Độ","Nhật Chiêu","Tiến Sâm","Ngọc Đỉnh","Quang Trung","Văn Nghĩa","Phi Hung","Văn Mẫn"}
    },
    [2] = {
        [1] = {"Smith","Jones","Williams","Taylor","Davies","Brown","Evans","Thomas","Roberts","Wilson","Johnson","Robinson","Wright","Thompson","White","Walker","Wood","Hall","Edwards","Green","Hughes","Lewis","Jackson","Harris","Turner","Drew","Hill","Clarke","Cooper","Morris","Martin","Baker","Ward","Harrison","Clark","Moore","King","Morgan","Phillips","Allen","James","Parker","Watson","Scott","Davis","Bennett","Griffiths","Price","Cook","Carter","Lee","Richardson","Bailey","Shaw","Young","Bell","Cox","Mitchell","Richards","Wilkinson","Collins","Marshall","Ellis","Chapman","Miller","Webb","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce","Elliott","Payne","Andrews","Atkinson"},
        --[2] = {"Cohen","Levi","Rosenberg","Goldstein","Friedman","Schwartz","Katz","Stein","Weiss","Adler","Rosen","Klein","Shapiro","Berman","Levy","Kaplan","Hirsch","Ben-David","Bernstein","Singer","Rubin","Steinberg","Shulman","Mandel","Mandelbaum"}
    }
}

CASCALLSIGNS = {
    alphanumerics = {
        [1] = {
            [1] = "Anh-dung",
            [2] = "Bac-binh",
            [3] = "Cai-cach",
            [4] = "Dong-da",
            [5] = "E-de",
            [6] = "Gay-go",
        },
        [2] = {
            [1] = "ALPHA",
            [2] = "BRAVO",
            [3] = "CHARLIE",
            [4] = "DELTA",
            [5] = "ECHO",
            [6] = "FOXTROT"
        }
    },
    numberLimit = 5,
    counts = {
        [1] = {
            alpha = 1,
            number = 1,
        },
        [2] = {
            alpha = 1,
            number = 1,
        },
    }
}