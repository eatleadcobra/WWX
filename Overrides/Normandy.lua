trigger.action.setUserFlag("MISSION_ID", 221)
-- //enabled features//
-- //runtime//
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 57600 -- 16 hours runtime
-- //depots//
FDCount = 4
AACount = 6 --dont touch
RDSubcount = 1
-- //radios//
BLUECASFREQ = 145
REDCASFREQ = 42
BLUECASMOD = 0 --0 = AM, 1 = FM
REDCASMOD = 0
--//Bullsbot//
INTERCEPT = true
-- //AI Cargo//
COALITIONSHIPPINGMETHODS = {
    [1] = {
        shipping = false,
        trains = true,
        aircargo = false,
    },
    [2] = {
        shipping = true,
        trains = false,
        aircargo = true,
    }
}
TRAINS = true
TRAIN_TYPES = {
    [1] = "DRG_Class_86", -- Red
    [2] = "DRG_Class_86", -- Blue
    ["wagons"] = "German_covered_wagon_G10"
}
CUSTOM_ARTY = {
    [1] = "LeFH_18-40-105", -- Red
    [2] = "M2A1-105" -- Blue
}
NO_HELIPAD = true
AIRCARGOINTERVAL = 3600
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
-- // AI Ground
EXTRACOMPANYROADS = true --cant both be true
COMPANIESIGNOREROADS = false --cant both be true
CONTROLLABLE_COMPANIES = true
-- //Subs//
SUBS = true
ACTIVETORP = false
SUBTYPE =
{
    [1] = "Uboat_VIIC",
    [2] = "Uboat_VIIC",
}
-- //Pirates//
PIRACY = false
-- //Bombers//
BOMBERS = true
DOUBLEBOMBERS = true
-- //CAP//
CAP = true
-- //Missile Boats//
MISSILEBOATS = true
-- //Interceptors//
INTERCEPTORS= {
    interval = 1800, --3600
    interceptLimit = 4,
    multipleZones = true,
    independantZones = true,
    linkedAirframes = {
        [1] = {[1] = 1, [2] = 2, [3] = 3, [4] = 4},
        [2] = {[1] = 1, [2] = 2, [3] = 3, [4] = 4},
        },
}
-- //Player Recon//
STRIKES = true
REAPER = false --doesnt work
-- //Player CAS//
CAS = true
CASAUTOENROLL = true
JTACS = {
    spawnOnBpCapture = false,
    spawnOnMissionStart = false,
    avoidFrequencies = {},
    callsignOverride = {}
}
CASCALLSIGNS = {
    --TODO move these to overrides
    alphanumerics = {
        [1] = {
            [1] = "ANTON",
            [2] = "BERTHA",
            [3] = "CASAR",
            [4] = "DORA",
            [5] = "EMIL",
            [6] = "FRIEDRICH",
        },
        [2] = {
            [1] = "ABLE",
            [2] = "BAKER",
            [3] = "CHARLIE",
            [4] = "DOG",
            [5] = "EASY",
            [6] = "FOX"
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
-- //Player CSAR
CSAR = false
NAMED_CSAR_DROPZONES = false
CSARAUTOENROLL = false
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
-- //Player Cargo//
CARGO = false
DISABLEF10CARGOSTATUS = false
CAVICS = {
    [1] = {
        --[1] = {text = "AT - BRDM", typename = "BRDM-2_malyutka"},
        --[2] = {text = "FireSupport - Grad MLRS", typename = "Grad"},
        --[3] = {text = "Ammo Truck", typename = "Bedford"},

    },
    [2] = {
        --[1] = {text = "AT - HMMWV", typename = "TOW"},
        --[2] = {text = "FireSupport - M270", typename = "M270"},
        --[3] = {text = "Ammo Truck", typename = "Bedford"},
    }
}
-- //Airbase Capture//
CAPTURE = false
CAPTUREBASES = {
}
-- //Respawn Groups//
RESPAWNGROUPS = {
    ["Red-Depot-AAA-1"] = 1800, --0.5hr
	["Red-Depot-AAA-2"] = 1800, --0.5hr
	["Red-Depot-AAA-3"] = 1800, --0.5hr
	["Red-Depot-AAA-4"] = 1800, --0.5hr
	["Red-RearDepot-AAA-1"] = 1800, --0.5hr
	["Red-RearDepot-AAA-2"] = 1800, --0.5hr
	["AirfieldDefenceRed-1"] = 1800, --0.5hr
	["AirfieldDefenceRed-2"] = 1800, --0.5hr
	["AirfieldDefenceRed-3"] = 1800, --0.5hr
	["AirfieldDefenceRed-4"] = 1800, --0.5hr
	["Blue-Depot-AAA-1"] = 1800, --0.5hr
	["Blue-Depot-AAA-2"] = 1800, --0.5hr
	["Blue-Depot-AAA-3"] = 1800, --0.5hr
	["Blue-Depot-AAA-4"] = 1800, --0.5hr
	["AirfieldDefenceBlue-1"] = 1800, --0.5hr
	["AirfieldDefenceBlue-2"] = 1800, --0.5hr
	["AirfieldDefenceBlue-3"] = 1800, --0.5hr
	["AirfieldDefenceBlue-4"] = 1800, --0.5hr
	["AirfieldDefenceBlue-5"] = 1800, --0.5hr
	["AirfieldDefenceBlue-6"] = 1800, --0.5hr
	["AirfieldDefenceBlue-7"] = 1800, --0.5hr
	["AirfieldDefenceBlue-7"] = 1800, --0.5hr
}
-- //Misc//
PROTECT_HELICOPTERS = false
PAIDTHEPRICE = true
-- //Unit Definitions//
Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "Pz_IV_H",
            [2] = "Pz_IV_H",
            [3] = "Pz_V_Panther_G",
			[4] = "Pz_V_Panther_G",
			[5] = "Blitz_36-6700A"
        },
        ["Mech"] = {
            [1] = "SturmPzIV",
            [2] = "Sd_Kfz_251",
            [3] = "Sd_Kfz_251",
			[4] = "Sd_Kfz_251",
            [5] = "Blitz_36-6700A"
        },
        ["Inf"] = {
            [1] = "Stug_IV",
            [2] = "Sd_Kfz_7",
            [3] = "Sd_Kfz_7",
			[4] = "Sd_Kfz_7",
            [5] = "Blitz_36-6700A"
        },
        ["DeployedInf"] = {
            [1] = "soldier_mauser98",
            [2] = "soldier_mauser98",
            [3] = "soldier_mauser98",
            [4] = "soldier_mauser98",
            [5] = "soldier_mauser98",
            [6] = "soldier_mauser98",
            [7] = "soldier_mauser98"
        },
		["DeployedGun"] = {
            [1] = "soldier_mauser98",
            [2] = "Pak40",
            [3] = "soldier_mauser98",
        },
        ["FuelConvoy"] = {
            [1] = "Sd_Kfz_234_2_Puma",
            [2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
            [5] = "Blitz_36-6700A",
            [6] = "Blitz_36-6700A",
            [7] = "Blitz_36-6700A",
            [8] = "Kubelwagen_82",
        },
        ["AmmoConvoy"] = {
            [1] = "Sd_Kfz_234_2_Puma",
            [2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
            [5] = "Blitz_36-6700A",
            [6] = "Blitz_36-6700A",
            [7] = "Blitz_36-6700A",
            [8] = "Kubelwagen_82",
        },
        ["EquipmentConvoy"] = {
            [1] = "Sd_Kfz_234_2_Puma",
            [2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
            [5] = "Blitz_36-6700A",
            [6] = "Blitz_36-6700A",
            [7] = "Blitz_36-6700A",
            [8] = "Kubelwagen_82",
        },
        ["EmbeddedAD"] = {
            [1] = "Tiger_I",
            [2] = "Blitz_36-6700A"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Tiger_II_H",
            [2] = "Blitz_36-6700A"
        },
        ["Shipping"] = {
            [1] = "USS_Samuel_Chase",
            --[2] = "leander-gun-ariadne"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "M4_Sherman",
			[3] = "M4_Sherman",
            [4] = "M4A4_Sherman_FF",
            [5] = "CCKW_353"
        },
        ["Mech"] = {
            [1] = "Centaur_IV",
            [2] = "M2A1_halftrack",
            [3] = "M2A1_halftrack",
			[4] = "M2A1_halftrack",
            [5] = "CCKW_353"
        },
        ["Inf"] = {
            [1] = "Churchill_VII",
			[2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Bedford_MWD",
            [5] = "CCKW_353"
        },
        ["DeployedInf"] = {
            [1] = "soldier_wwii_br_01",
            [2] = "soldier_wwii_br_01",
            [3] = "soldier_wwii_br_01",
            [4] = "soldier_wwii_br_01",
            [5] = "soldier_wwii_br_01",
            [6] = "soldier_wwii_br_01",
            [7] = "soldier_wwii_br_01"
        },
        ["FuelConvoy"] = {
            [1] = "M8_Greyhound",
            [2] = "CCKW_353",
            [3] = "CCKW_353",
            [4] = "CCKW_353",
            [5] = "CCKW_353",
            [6] = "CCKW_353",
            [7] = "CCKW_353",
            [8] = "Willys_MB",
        },
        ["AmmoConvoy"] = {
            [1] = "M8_Greyhound",
            [2] = "CCKW_353",
            [3] = "CCKW_353",
            [4] = "CCKW_353",
            [5] = "CCKW_353",
            [6] = "CCKW_353",
            [7] = "CCKW_353",
            [8] = "Willys_MB",
        },
        ["EquipmentConvoy"] = {
            [1] = "M8_Greyhound",
            [2] = "CCKW_353",
            [3] = "CCKW_353",
            [4] = "CCKW_353",
            [5] = "CCKW_353",
            [6] = "CCKW_353",
            [7] = "CCKW_353",
            [8] = "Willys_MB",
        },
        ["EmbeddedAD"] = {
            [1] = "Cromwell_IV",
			[2] = "Cromwell_IV",
            [3] = "CCKW_353"
        },
        ["EmbeddedADHigh"] = {
            [1] = "M10_GMC",
			[2] = "M10_GMC",
            [3] = "CCKW_353"
        },
        ["Shipping"] = {
            [1] = "USS_Samuel_Chase",
            --[2] = "leander-gun-ariadne"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["Sd_Kfz_251"] = "IFV",
    ["M2A1_halftrack"] = "IFV",
	["Sd_Kfz_7"] = "APC",
    ["Bedford_MWD"] = "APC",
}
PlatoonGunCarrierTypeNames = {
    ["Sd_Kfz_2"] = "GUN"
}
PlatoonGunTypeNames = {
    ["Pak40"] = "GUN"
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