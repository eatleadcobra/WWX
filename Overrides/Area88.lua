trigger.action.setUserFlag("MISSION_ID", 211)
-- enabled features
SUBS = false
ACTIVETORP = false
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
CAP = true
COMPANIESIGNOREROADS = true
PROTECT_HELICOPTERS = true
PIRACY = false
BOMBERS = true
DOUBLEBOMBERS = false
MISSILEBOATS = false
CARGO = true
CSAR = true
JTACS = {
    spawnOnBpCapture = true,
    spawnOnMissionStart = false,
--    avoidFrequencies = {},
--    callsignOverride = {}
}
CAS = true
STRIKES = false
REAPER = false
INTERCEPT = true
SHIPPING = true
TRAINS = false
DISABLEF10CARGOSTATUS = true
AIRCARGO = false
AIRCARGOINTERVAL = 3600
CAPTURE = false
CONTROLLABLE_COMPANIES = false
NAMED_CSAR_DROPZONES = true
INTERCEPTORS= {
    interval = 1800, --3600
    interceptLimit = 3,
    multipleZones = true,
    independantZones = true,
    linkedAirframes = {
        [1] = {[1] = 1, [2] = 2, [3] = 3},
        [2] = {[1] = 1, [2] = 2, [3] = 3},
        },
}
CAVICS = {
    [1] = {
        [1] = {text = "AT - BRDM", typename = "BRDM-2_malyutka"},
        [2] = {text = "FireSupport - Grad MLRS", typename = "Grad"},
        [3] = {text = "Ammo Truck", typename = "Bedford"},

    },
    [2] = {
        [1] = {text = "AT - HMMWV", typename = "TOW"},
        [2] = {text = "FireSupport - M270", typename = "M270"},
        [3] = {text = "Ammo Truck", typename = "Bedford"},
    }
}
CAPTUREBASES = {
    ["Eyn Shemer"] = true,
	["Herzliya"] = true,
	["HI24"] = true,
	["HI22"] = true,
	["Ben-Gurion"] = true,
	["Palmachim"] = true,
	["Tel Nof"] = true,
	["HI23"] = true,
	["Hatzor"] = true,
}
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
RESPAWNGROUPS = {
    ["BlueTankerDrogue"] = 1800, --0.5hr
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 43200 -- 12 hours runtime
-- counts
FDCount = 1
AACount = 6
RDSubcount = 1
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
            [3] = "Ural-375"
        },
        ["Mech"] = {
            [1] = "BMP-1",
            [2] = "BMP-1",
            [3] = "BMP-1",
			[4] = "BMP-1",
            [5] = "Ural-375"
        },
        ["Inf"] = {
            [1] = "BTR-60",
            [2] = "BTR-60",
            [3] = "BTR-60",
			[4] = "BTR-60",
            [5] = "Ural-375"
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
            [1] = "tt_DSHK",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "tt_DSHK",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "tt_DSHK",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "tt_DSHK",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "tt_DSHK",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "tt_DSHK",
            [8] = "Ural-375",
        },
        ["EmbeddedAD"] = {
            [1] = "ZSU-23-4 Shilka",
            [2] = "Ural-375"
        },
        ["EmbeddedADHigh"] = {
            [1] = "ZSU_57_2",
            [2] = "Ural-375"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
            [2] = "leander-gun-ariadne"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Chieftain_mk3",
            [2] = "Chieftain_mk3",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "MCV-80",
            [2] = "MCV-80",
            [3] = "MCV-80",
			[4] = "MCV-80",
            [5] = "M 818"
        },
        ["Inf"] = {
            [1] = "M-113",
			[2] = "M-113",
            [3] = "M-113",
            [4] = "M-113",
            [5] = "M 818"
        },
        ["DeployedInf"] = {
            [1] = "Infantry AK ver3",
            [2] = "Infantry AK ver3",
            [3] = "Soldier M249",
            [4] = "Infantry AK ver3",
            [5] = "Paratrooper RPG-16",
            [6] = "Infantry AK ver3",
            [7] = "Infantry AK ver3"
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
            [1] = "ZSU_57_2",
            [2] = "M 818"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            --[2] = "leander-gun-ariadne"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["BMP-1"] = "IFV",
    ["MCV-80"] = "IFV",
	["BTR-60"] = "APC",
    ["M-113"] = "APC",
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
        [1] = "Blue Forward Field Hospital 1",
		[2] = "Blue Forward Field Hospital 2"
    }
}
CSARFreqCollisions = {
    [1] = {
        ["NDB"] = {
            20,21,22,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,60
        },
        ["TACAN"] = {
            107,21,85,79,106,84,96,106,88,26,37,87,86,78,77,76,75,74
        }
    },
    [2] = {
        ["NDB"] = {
            62,66,67,68,70,76,77,84,85,86,87,89,90,95,96,97,98
        },
        ["TACAN"] = {
            107,21,85,79,106,84,96,106,88,26,37,87,86,78,77,76,75,74
        }
    }
}
CSARHunterOptions = {
    [1] = {
        [1] = "Infantry AK Ins",
        [2] = "Infantry AK Ins",
        [3] = "Infantry AK Ins",
        [4] = "Infantry AK Ins",
        [5] = "Infantry AK Ins",
    },
    [2] = {
        [1] = "Infantry AK ver3",
        [2] = "Infantry AK ver3",
        [3] = "Infantry AK ver3",
        [4] = "Infantry AK ver3",
        [5] = "Infantry AK ver3",
    }
}
CSARHunterEliteOptions = {
    [1] = {
        [1] = "BRDM-2",
    },
    [2] = {
        [1] = "M1043 HMMWV Armament",
    }
}
CSARStackZones = {
    [1] = {
        [1] = "RedCsarStack",
    },
    [2] = {
        [1] = "BlueCsarStack",
    }
}
CSARCoverageZones = {
    [1] = {
        [1] = "RedCsarZone",
    },
    [2] = {
        [1] = "BlueCsarZone",
    }
}
RandomNames = {}
RandomNames.firstNames = {
    [1] = {
        [1] = {"Dmitriy","Lev","Yuri","Ilya","Mikhail","Sacha","Vitaliy","Igor","Aleksey","Oleg","Ruslan","Misha","Andrian","Yaroslav","Anatoly","Boris","Viktor","Sergey","Pavel","Nikolay","Vasily","Andrey","Evgeny","Leonid","Artem","Vladislav","Konstantin","Grigory","Piotr","Timur"},
        [2] = {"Stefan","Michael","Andreas","Thomas","Frank","Markus","Christian","Oliver","Matthias","Torsten","Martin","Sven","Alexander","Dirk","Karsten","Ralf","Jörg","Jan","Marc","Peter","Jürgen","Klaus","Uwe","Sebastian","Daniel","Hans","Wolfgang","Bernd","Rainer","Joachim","Dieter","Manfred","Norbert","Axel","Rolf","Olaf","Lutz","Werner","Volker","Jens"}
    },
    [2] = {
        [1] = {"David","Michael","James","John","Robert","Mark","William","Richard","Thomas","Steven","Timothy","Joseph","Charles","Jeffrey","Kevin","Kenneth","Daniel","Paul","Donald","Brian","Ronald","Gary","Scott","Gregory","Anthony","Edward","Stephen","Larry","Christopher","Douglas","Dennis","Randy","George","Terry","Keith","Mike","Jerry","Ricky","Bruce","Frank","Peter","Craig","Steve","Eric","Patrick","Raymond","Roger","Danny","Jeff","Alan","Andrew"},
        [2] = {"David","Paul","Andrew","Mark","John","Michael","Stephen","Ian","Robert","Richard","Christopher","Peter","Simon","Anthony","Kevin","Gary","Steven","Martin","James","Philip","Alan","Neil","Nigel","Timothy","Colin","Graham","Jonathan","Nicholas","William","Adrian","Brian","Stuart","Keith","Thomas","Patrick","Sean","Carl","Trevor","Wayne","Shaun","Kenneth","Barry","Derek","Dean","Raymond","Antony","Jeremy","Joseph","Edward","Lee"},
        [3] = {"Philippe","Patrick","Jean","Pascal","Alain","Michel","Eric","Thierry","Christian","Didier","Dominique","Bruno","Daniel","Bernard","Gilles","Pierre","Serge","Jean-Pierre","Marc","Gérard","Jean-Luc","François","Jacques","Claude","Patrice","Joël","Denis","Yves","Hervé","Frédéric","Laurent","André","Jean-Claude","Jean-Marc","Jean-Michel","Francis","Olivier","Guy","Christophe","Jean-François","Jean-Louis","Jean-Paul","Stéphane","Jean-Marie","Robert","Gilbert","René","Joseph","Vincent","Georges","Jean-Jacques"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Ivanov","Kuznetsov","Petrov","Magomedov","Smirnov","Popov","Volkov","Shevchenko","Vasilev","Novikov","Morozov","Pavlov","Sokolov","Aliev","Mikhaylov","Romanov","Makarov","Egorov","Kozlov","Nikolaev","Stepanov","Andreev","Zakharov","Kovalenko","Sergeev","Bondarenko","Nikitin","Zaytsev","Medvedev","Orlov","Kravchenko","Frolov","Kuzmin","Yakovlev","Belov","Lebedev","Alekseev","Borisov","Antonov","Tkachenko","Tarasov","Sidorov","Mironov","Dmitriev","Isaev","Kotov","Matveev","Sorokin","Semenov","Fedorov","Zhukov"},
        [2] = {"Müller","Schmidt","Schneider","Fischer","Weber","Meyer","Wagner","Becker","Schulz","Hoffmann","Schäfer","Koch","Bauer","Richter","Klein","Wolf","Schröder","Neumann","Schwarz","Zimmermann","Braun","Krüger","Hofmann","Hartmann","Lange","Schmitt","Werner","Schmitz","Krause","Meier","Lehmann","Schmid","Schulze","Maier","Köhler","Herrmann","König","Walter","Mayer","Huber","Kaiser","Fuchs","Peters","Lang","Scholz","Möller","Weiß","Jung","Hahn","Schubert"}
    },
    [2] = {
        [1] = {"Smith","Johnson","Williams","Jones","Brown","Davis","Miller","Wilson","Moore","Taylor","Anderson","Thomas","Jackson","White","Harris","Martin","Thompson","Robinson","Clark","Lewis","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce"},
        [2] = {"Smith","Jones","Williams","Taylor","Davies","Brown","Evans","Thomas","Roberts","Wilson","Johnson","Robinson","Wright","Thompson","White","Walker","Wood","Hall","Edwards","Green","Hughes","Lewis","Jackson","Harris","Turner","Drew","Hill","Clarke","Cooper","Morris","Martin","Baker","Ward","Harrison","Clark","Moore","King","Morgan","Phillips","Allen","James","Parker","Watson","Scott","Davis","Bennett","Griffiths","Price","Cook","Carter","Lee","Richardson","Bailey","Shaw","Young","Bell","Cox","Mitchell","Richards","Wilkinson","Collins","Marshall","Ellis","Chapman","Miller","Webb","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce","Elliott","Payne","Andrews","Atkinson"},
        [3] = {"Martin","Bernard","Robert","Richard","Durand","Dubois","Moreau","Simon","Laurent","Michel","Garcia","Thomas","Leroy","David","Morel","Roux","Girard","Fournier","Lambert","Lefebvre","Mercier","Blanc","Dupont","Faure","Bertrand","Morin","Garnier","Nicolas","Marie","Rousseau","Bonnet","Vincent","Henry","Masson","Robin","Martinez","Boyer","Muller","Chevalier","Denis","Meyer","Blanchard","Lemaire","Dufour","Gauthier","Vidal","Perez","Perrin","Fontaine","Joly"}
    }
}

CASCALLSIGNS = {
    --TODO move these to overrides
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