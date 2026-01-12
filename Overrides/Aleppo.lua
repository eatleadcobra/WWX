trigger.action.setUserFlag("MISSION_ID", 7)
-- enabled features
SUBS = false
ACTIVETORP = false
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
CAP = true
PIRACY = true
BOMBERS = true
ESCORT = false
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
STRIKES = true
REAPER = false
INTERCEPT = true
SHIPPING = true
CAPTURE = false
CAPTUREBASES = {
    ["Aleppo"] = true,
}
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 46800 -- 13 hours runtime
-- counts
FDCount = 2
AACount = 6
RDSubcount = 2
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 285
REDCASFREQ = 280
BLUECASMOD = 0
REDCASMOD = 0

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-55",
			[2] = "T-72B",
			[3] = "T62M",
            [4] = "KAMAZ Truck"
        },
        ["Mech"] = {
            [1] = "BMP-2",
            [2] = "BMP-1",
            [3] = "BMP-1",
            [4] = "KAMAZ Truck"
        },
        ["Inf"] = {
            [1] = "HL_DSHK",
			[2] = "tt_DSHK",
			[3] = "BTR-60",
            [4] = "KAMAZ Truck",
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK Ins",
            [2] = "Infantry AK Ins",
            [3] = "Soldier RPG",
            [4] = "Infantry AK Ins",
            [5] = "Soldier RPG",
            [6] = "Infantry AK Ins",
            [7] = "Infantry AK Ins",
        },
        ["FuelConvoy"] = {
            [1] = "BRDM-2",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "BRDM-2",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "BRDM-2",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "BRDM-2",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "BRDM-2",
            [2] = "GAZ-66",
            [3] = "GAZ-66",
            [4] = "GAZ-66",
            [5] = "GAZ-66",
            [6] = "GAZ-66",
            [7] = "BRDM-2",
            [8] = "GAZ-66",
        },
        ["EmbeddedAD"] = {
            --[1] = "Strela-1 9P31",
            [1] = "ZSU-23-4 Shilka",
            [2] = "KAMAZ Truck"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Strela-1 9P31",
            [2] = "ZSU-23-4 Shilka",
            [3] = "KAMAZ Truck"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
            --[2] = "leander-gun-ariadne"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M-1 Abrams",
            [2] = "M-1 Abrams",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "M-2 Bradley",
            [3] = "M-2 Bradley",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "CHAP_M1130",
            [2] = "CHAP_M1130",
            [3] = "M 818"
        },
        ["DeployedInf"] = {
            [1] = "Soldier M4",
            [2] = "Soldier M4",
            [3] = "Soldier M249",
            [4] = "Soldier M4",
            [5] = "Soldier M249",
            [6] = "Soldier M4",
            [7] = "Soldier M4",
        },
        ["FuelConvoy"] = {
            [1] = "M1043 HMMWV Armament",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "M1043 HMMWV Armament",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "M1043 HMMWV Armament",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "M1043 HMMWV Armament",
            [8] = "M 818",
        },
        ["EquipmentConvoy"] = {
            [1] = "M1043 HMMWV Armament",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "M1043 HMMWV Armament",
            [8] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "Vulcan",
            [2] = "M 818"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Strela-1 9P31",
            [2] = "Vulcan",
            [3] = "M 818"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            --[2] = "leander-gun-ariadne"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["BMP-2"] = "IFV",
    ["BMP-1"] = "IFV",
	["M-2 Bradley"] = "IFV",
    ["HL_DSHK"] = "APC",
    ["tt_DSHK"] = "APC",
	["BTR-60"] = "APC",
	["CHAP_M1130"] = "APC",
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
        [1] = {"David","Paul","Andrew","Mark","John","Michael","Stephen","Ian","Robert","Richard","Christopher","Peter","Simon","Anthony","Kevin","Gary","Steven","Martin","James","Philip","Alan","Neil","Nigel","Timothy","Colin","Graham","Jonathan","Nicholas","William","Adrian","Brian","Stuart","Keith","Thomas","Patrick","Sean","Carl","Trevor","Wayne","Shaun","Kenneth","Barry","Derek","Dean","Raymond","Antony","Jeremy","Joseph","Edward","Lee"},
        --[2] = {"Abram","Chaim","Jankel","David","Moshe","Leib","Aron","Yosef","Abraham","Israel","Jacob","Hersch","Moses","Mendel","Wolf","Samuel","Leiser","Jossel","Benjamin","Schmul","Daniel","Ariel","Levi","Noam","Ori"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Mohamed","Ahmed","Hassan","Ali","Mahmoud","Ibrahim","Gamal","Abdel","Mostafa","Salah","Adel","Hussein","Samir","Saad","Soliman","Kamal","Hamdy","Saleh","Salem","Nabil","Youssef","Samy","Said","Fathy","Sayed","Elsayed","Khalil","Aly","Mohammed","Kamel"}
    },
    [2] = {
        [1] = {"Smith","Jones","Williams","Taylor","Davies","Brown","Evans","Thomas","Roberts","Wilson","Johnson","Robinson","Wright","Thompson","White","Walker","Wood","Hall","Edwards","Green","Hughes","Lewis","Jackson","Harris","Turner","Drew","Hill","Clarke","Cooper","Morris","Martin","Baker","Ward","Harrison","Clark","Moore","King","Morgan","Phillips","Allen","James","Parker","Watson","Scott","Davis","Bennett","Griffiths","Price","Cook","Carter","Lee","Richardson","Bailey","Shaw","Young","Bell","Cox","Mitchell","Richards","Wilkinson","Collins","Marshall","Ellis","Chapman","Miller","Webb","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce","Elliott","Payne","Andrews","Atkinson"},
        --[2] = {"Cohen","Levi","Rosenberg","Goldstein","Friedman","Schwartz","Katz","Stein","Weiss","Adler","Rosen","Klein","Shapiro","Berman","Levy","Kaplan","Hirsch","Ben-David","Bernstein","Singer","Rubin","Steinberg","Shulman","Mandel","Mandelbaum"}
    }
}

CASCALLSIGNS = {
    alphanumerics = {
        [1] = {
            [1] = "Muharib",
            [2] = "Murafiq",
            [3] = "Khalid",
            [4] = "Batal",
            [5] = "Rami",
            [6] = "Khaiyal",
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