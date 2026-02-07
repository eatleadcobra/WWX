trigger.action.setUserFlag("MISSION_ID", 9)
-- enabled features
SUBS = true
ACTIVETORP = false
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
CAP = false
PIRACY = false
BOMBERS = true
ESCORT = true
MISSILEBOATS = false
CARGO = false
CSAR = false
CAS = true
STRIKES = false
REAPER = false
INTERCEPT = false
SHIPPING = true
CAPTURE = false
CAVICS = {
    [1] = {
        --[1] = {text = "AT - BRDM", typename = "BRDM-2_malyutka"},
        --[2] = {text = "IFV - BMD-1", typename = "BMD"},
        --[1] = {text = "FireSupport - Grad MLRS", typename = "Grad"},--3
        --[4] = {text = "Scout - BRDM", typename = "BRDM"},
        --[2] = {text = "Ammo Truck", typename = "Bedford"},--5

    },
    [2] = {
        --[1] = {text = "AT - HMMWV", typename = "TOW"},
        --[2] = {text = "IFV - Scorpion", typename = "Scorpion"},
        --[1] = {text = "FireSupport - M270", typename = "M270"},--3
        --[4] = {text = "Scout - Scimitar", typename = "Scimitar"},
        --[2] = {text = "Ammo Truck", typename = "Bedford"},--5
    }
}
CAPTUREBASES = {
    ["Gurguan Point"] = true,
	["Isley"] = true,
}
NAVALCONVOY = {
    [1] = false,
    [2] = true,
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
BLUECASFREQ = 140
REDCASFREQ = 41
BLUECASMOD = 0
REDCASMOD = 0

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "Type_98_Ke_Ni",
            [2] = "Type_98_Ke_Ni",
			[3] = "Type_98_Ke_Ni",
            [4] = "Type_94_Truck"
        },
        ["Mech"] = {
            [1] = "Type_89_I_Go",
			[2] = "Type_89_I_Go",
			[3] = "Type_89_I_Go",
            [4] = "Type_94_Truck"
        },
        ["Inf"] = {
            [1] = "Type_98_So_Da",
            [2] = "Type_98_So_Da",
            [3] = "Type_94_Truck"
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK Ins",
            [2] = "Infantry AK Ins",
            [3] = "Paratrooper RPG-16",
            [4] = "Infantry AK Ins",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK Ins",
            [7] = "Infantry AK Ins"
        },
        ["FuelConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Type_94_Truck",
            [3] = "Type_94_Truck",
            [4] = "Type_94_Truck",
            [5] = "Type_94_Truck",
            [6] = "Type_94_Truck",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Type_94_Truck"
        },
        ["AmmoConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Type_94_Truck",
            [3] = "Type_94_Truck",
            [4] = "Type_94_Truck",
            [5] = "Type_94_Truck",
            [6] = "Type_94_Truck",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Type_94_Truck"
        },
        ["EquipmentConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Type_94_Truck",
            [3] = "Type_94_Truck",
            [4] = "Type_94_Truck",
            [5] = "Type_94_Truck",
            [6] = "Type_94_Truck",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Type_94_Truck"
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Type_94_Truck"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Type_94_Truck"
        },
        ["Shipping"] = {
            [1] = "ELNYA",
            [2] = "CastleClass_01"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "M2A1_halftrack",
            [2] = "M2A1_halftrack",
			[3] = "M2A1_halftrack",
            [4] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "Land_Rover_109_S3",
            [2] = "Land_Rover_109_S3",
			[3] = "Land_Rover_109_S3",
            [4] = "Bedford_MWD"
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver3",
            [2] = "Infantry AK ver3",
            [3] = "Paratrooper RPG-16",
            [4] = "Infantry AK ver3",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK ver3",
            [7] = "Infantry AK ver3"
        },
        ["FuelConvoy"] = {
            [1] = "CastleClass_01"
        },
        ["AmmoConvoy"] = {
            [1] = "CastleClass_01"
        },
        ["EquipmentConvoy"] = {
            [1] = "CastleClass_01"
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            [2] = "CastleClass_01"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["Type_89_I_Go"] = "IFV",
    ["M2A1_halftrack"] = "IFV",
    ["Type_98_So_Da"] = "APC",
    ["Land_Rover_109_S3"] = "APC"
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