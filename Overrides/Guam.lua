trigger.action.setUserFlag("MISSION_ID", 6)
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
MISSILEBOATS = true
CARGO = true
CSAR = true
CAS = true
STRIKES = false
REAPER = false
SHIPPING = true
CAPTURE = false
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
BLUECASFREQ = 225
REDCASFREQ = 265
BLUECASMOD = 0
REDCASMOD = 0

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-72B",
            [2] = "T-72B",
			[3] = "T-72B",
            [4] = "KAMAZ Truck"
        },
        ["Mech"] = {
            [1] = "CHAP_FV101",
            [2] = "BMP-3",
            [3] = "BMP-3",
            [4] = "KAMAZ Truck"
        },
        ["Inf"] = {
            [1] = "BTR-82A",
            [2] = "BTR-82A",
            [3] = "KAMAZ Truck",
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK",
            [2] = "Infantry AK",
            [3] = "Soldier M249",
            [4] = "Infantry AK",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK",
            [7] = "Infantry AK",
        },
        ["FuelConvoy"] = {
            [1] = "Cobra",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "Cobra",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "Cobra",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "Cobra",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "Cobra",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "KAMAZ Truck",
            [5] = "KAMAZ Truck",
            [6] = "KAMAZ Truck",
            [7] = "Cobra",
            [8] = "KAMAZ Truck",
        },
        ["EmbeddedAD"] = {
            --[1] = "Strela-1 9P31",
            [1] = "ZSU-23-4 Shilka",
            [2] = "KAMAZ Truck"
        },
        ["EmbeddedADHigh"] = {
            [1] = "SA-18 Igla-S manpad",
            [2] = "ZSU-23-4 Shilka",
            [3] = "KAMAZ Truck"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
            --[2] = "leander-gun-condell"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M1A2C_SEP_V3",
            [2] = "M1A2C_SEP_V3",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "M-2 Bradley",
            [3] = "M-2 Bradley",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "LAV-25",
            [2] = "LAV-25",
            [3] = "M 818"
        },
        ["DeployedInf"] = {
            [1] = "Soldier M4",
            [2] = "Soldier M4",
            [3] = "Soldier M249",
            [4] = "Soldier M4",
            [5] = "Paratrooper RPG-16",
            [6] = "Soldier M4",
            [7] = "Soldier M4",
        },
        ["FuelConvoy"] = {
            [1] = "CHAP_MATV",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "CHAP_MATV",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "CHAP_MATV",
            [2] = "CHAP_M1083",
            [3] = "CHAP_M1083",
            [4] = "CHAP_M1083",
            [5] = "CHAP_M1083",
            [6] = "CHAP_M1083",
            [7] = "CHAP_MATV",
            [8] = "CHAP_M1083",
        },
        ["EquipmentConvoy"] = {
            [1] = "CHAP_MATV",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "CHAP_MATV",
            [8] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "Vulcan",
            [2] = "M 818"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Soldier stinger",
            [2] = "Vulcan",
            [3] = "M 818"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            --[2] = "leander-gun-condell"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["M-2 Bradley"] = "IFV",
    ["BMP-3"] = "IFV",
    ["LAV-25"] = "APC",
	["CHAP_MATV"] = "APC",
    ["BTR-82A"] = "APC",
	["Cobra"] = "APC",
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
        [2] = {"Abram","Chaim","Jankel","David","Moshe","Leib","Aron","Yosef","Abraham","Israel","Jacob","Hersch","Moses","Mendel","Wolf","Samuel","Leiser","Jossel","Benjamin","Schmul","Daniel","Ariel","Levi","Noam","Ori"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Mohamed","Ahmed","Hassan","Ali","Mahmoud","Ibrahim","Gamal","Abdel","Mostafa","Salah","Adel","Hussein","Samir","Saad","Soliman","Kamal","Hamdy","Saleh","Salem","Nabil","Youssef","Samy","Said","Fathy","Sayed","Elsayed","Khalil","Aly","Mohammed","Kamel"}
    },
    [2] = {
        [1] = {"Smith","Jones","Williams","Taylor","Davies","Brown","Evans","Thomas","Roberts","Wilson","Johnson","Robinson","Wright","Thompson","White","Walker","Wood","Hall","Edwards","Green","Hughes","Lewis","Jackson","Harris","Turner","Drew","Hill","Clarke","Cooper","Morris","Martin","Baker","Ward","Harrison","Clark","Moore","King","Morgan","Phillips","Allen","James","Parker","Watson","Scott","Davis","Bennett","Griffiths","Price","Cook","Carter","Lee","Richardson","Bailey","Shaw","Young","Bell","Cox","Mitchell","Richards","Wilkinson","Collins","Marshall","Ellis","Chapman","Miller","Webb","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce","Elliott","Payne","Andrews","Atkinson"},
        [2] = {"Cohen","Levi","Rosenberg","Goldstein","Friedman","Schwartz","Katz","Stein","Weiss","Adler","Rosen","Klein","Shapiro","Berman","Levy","Kaplan","Hirsch","Ben-David","Bernstein","Singer","Rubin","Steinberg","Shulman","Mandel","Mandelbaum"}
    }
}

CASCALLSIGNS = {
    alphanumerics = {
        [1] = {
            [1] = "Granit",
            [2] = "Akatsia",
            [3] = "Aurora",
            [4] = "Shapka",
            [5] = "Empire",
            [6] = "Sirena",
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