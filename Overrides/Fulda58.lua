trigger.action.setUserFlag("MISSION_ID", 15)
-- enabled features
SUBS = false
ACTIVETORP = false
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
CAP = true
PROTECT_HELICOPTERS = true
PIRACY = false
BOMBERS = true
DOUBLEBOMBERS = true
MISSILEBOATS = false
CARGO = true
CSAR = true
JTACS = {
    spawnOnBpCapture = false,
    spawnOnMissionStart = true,
--    avoidFrequencies = {},
--    callsignOverride = {}
}
CAS = true
STRIKES = true
REAPER = false
INTERCEPT = true
SHIPPING = false
TRAINS = true
DISABLEF10CARGOSTATUS = true
AIRCARGO = true
AIRCARGOINTERVAL = 3600
CAPTURE = false
CONTROLLABLE_COMPANIES = true
NAMED_CSAR_DROPZONES = true
INTERCEPTORS= {
    interval = 1800, --3600
    interceptLimit = 4,
    multipleZones = true,
    independantZones = true,
    linkedAirframes = {
        [1] = {[1] = 1, [2] = 2},
        [2] = {[1] = 1, [2] = 2},
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
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
RESPAWNGROUPS = {
    ["Red-SA11-1"] = 7200, --2hr
	["RED-SHORAD-SA-11-1"] = 3600, --1hr
	["Red-SA2-1"] = 7200, --2hr
	["RED-SHORAD-SA-2-1"] = 3600, --1hr
	["Red-SA5-1"] = 7200, --2hr
	["RED-SHORAD-SA-5-1"] = 3600, --1hr
	["Red-KS19-1"] = 7200, --2hr
	["Blue-HAWK-1"] = 7200, --2hr
	["BLUE-SHORAD-HAWK-1"] = 3600, --1hr
	["Blue-HAWK-2"] = 7200, --2hr
	["BLUE-SHORAD-HAWK-2"] = 3600, --1hr
	["Blue-Patriot-1"] = 7200, --2hr
	["BLUE-SHORAD-PATRIOT-1"] = 3600, --1hr
	["RED-SHORAD-FARP-1"] = 3600, --1hr
	["BLUE-SHORAD-HFRG38"] = 3600, --1hr
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 36000 -- 10 hours runtime
-- counts
FDCount = 4
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
            [1] = "T-34-85",
            [2] = "T-34-85",
            [3] = "MTLB",
			[4] = "MTLB",
            [5] = "Blitz_36-6700A"
        },
        ["Inf"] = {
            [1] = "PT_76",
            [2] = "BTR-60",
            [3] = "BTR-60",
			[4] = "BTR-60",
            [5] = "Blitz_36-6700A"
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
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
            [5] = "Blitz_36-6700A",
            [6] = "Blitz_36-6700A",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Blitz_36-6700A",
        },
        ["AmmoConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
            [5] = "Blitz_36-6700A",
            [6] = "Blitz_36-6700A",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Blitz_36-6700A",
        },
        ["EquipmentConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
            [5] = "Blitz_36-6700A",
            [6] = "Blitz_36-6700A",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Blitz_36-6700A",
        },
        ["EmbeddedAD"] = {
            [1] = "ZSU-23-4 Shilka",
            [2] = "Blitz_36-6700A"
        },
        ["EmbeddedADHigh"] = {
            [1] = "ZSU_57_2",
            [2] = "ZSU_57_2",
            [3] = "Blitz_36-6700A"
        },
        ["Shipping"] = {
            [1] = "Dry-cargo ship-2"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M-60",
            [2] = "M-60",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "M4_Sherman",
            [2] = "M4_Sherman",
            [3] = "M-113",
			[4] = "M-113",
            [5] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "M4_Sherman",
			[2] = "M4_Sherman",
            [3] = "M2A1_halftrack",
            [4] = "M2A1_halftrack",
            [5] = "Bedford_MWD"
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
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Bedford_MWD",
            [5] = "Bedford_MWD",
            [6] = "Bedford_MWD",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Bedford_MWD",
        },
        ["AmmoConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Bedford_MWD",
            [5] = "Bedford_MWD",
            [6] = "Bedford_MWD",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Bedford_MWD",
        },
        ["EquipmentConvoy"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Bedford_MWD",
            [5] = "Bedford_MWD",
            [6] = "Bedford_MWD",
            [7] = "Type_94_25mm_AA_Truck",
            [8] = "Bedford_MWD",
        },
        ["EmbeddedAD"] = {
            [1] = "Vulcan",
            [2] = "Bedford_MWD"
        },
        ["EmbeddedADHigh"] = {
            [1] = "ZSU_57_2",
            [2] = "ZSU_57_2",
            [3] = "Bedford_MWD"
        },
        ["Shipping"] = {
            [1] = "Dry-cargo ship-2"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["MTLB"] = "IFV",
    ["M-113"] = "IFV",
	["BTR-60"] = "APC",
    ["M2A1_halftrack"] = "APC",
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
        [1] = "Blue Forward Field Hospital"
    }
}
CSARFreqCollisions = {
    [1] = {
        ["NDB"] = {
            20,21,22,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,60
        },
        ["TACAN"] = {
            24,28,32,47,48,56
        }
    },
    [2] = {
        ["NDB"] = {
            62,66,67,68,70,76,77,84,85,86,87,89,90,95,96,97,98
        },
        ["TACAN"] = {
            14,17,25,77,81,84,88,89,108
        }
    }
}
CSARHunterOptions = {
    [1] = {
        [1] = "Infantry AK ver3",
        [2] = "Infantry AK ver3",
        [3] = "Infantry AK ver3",
        [4] = "Infantry AK ver3",
        [5] = "Infantry AK ver3",
    },
    [2] = {
        [1] = "Soldier M4",
        [2] = "Soldier M4",
        [3] = "Soldier M4",
        [4] = "Soldier M4",
        [5] = "Soldier M4",
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
