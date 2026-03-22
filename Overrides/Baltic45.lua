trigger.action.setUserFlag("MISSION_ID", 12)
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
DOUBLEBOMBERS = true
MISSILEBOATS = true
CARGO = false
CSAR = false
CAS = true
STRIKES = true
REAPER = false
INTERCEPT = false
SHIPPING = true
TRAINS = true
AIRCARGO = false
--AIRCARGOINTERVAL = 3600
CAPTURE = false
INTERCEPTORS= {
interval = 3600, --1hr
interceptLimit = 4,
multipleZones = true,
independantZones = true,
linkedAirframes = {
	[1] = {[1] = 1, [2] = 2},
	[2] = {[1] = 1, [2] = 2, [3] = 3},
	},
}
CAVICS = {
    [1] = {
        --[1] = {text = "AT - BRDM", typename = "BRDM-2_malyutka"},
        [2] = {text = "FireSupport - Grad MLRS", typename = "Grad"},
        [3] = {text = "Ammo Truck", typename = "Bedford"},

    },
    [2] = {
        --[1] = {text = "AT - HMMWV", typename = "TOW"},
        [2] = {text = "FireSupport - M270", typename = "M270"},
        [3] = {text = "Ammo Truck", typename = "Bedford"},
    }
}
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
RESPAWNGROUPS = {
	["BlueRearDepotAAA"] = 3600, --1hr
	["RedRearDepotAAA"] = 3600, --1hr
	["Red-FreeHunt"] = 3600, --1hr
	["Blue-FreeHunt"] = 3600, --1hr
	["RedFrontBomber-1"] = 7200, --2hr
	["BlueFrontBomber-2"] = 7200, --2hr
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 36000 -- 10 hours runtime
-- counts
FDCount = 3
AACount = 6
RDSubcount = 1
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 41
REDCASFREQ = 140
BLUECASMOD = 0
REDCASMOD = 0

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-34-85",
            [2] = "T-34-85",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "M2A1_halftrack",
            [2] = "M2A1_halftrack",
            [3] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "Type_94_Truck",
            [2] = "Type_94_Truck",
            [3] = "Type_94_Truck",
			[4] = "Type_94_Truck",
			[5] = "Bedford_MWD",
            [6] = "S_75_ZIL"
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
		["DeployedGun"] = {
            [1] = "Infantry AK Ins",
            [2] = "KS-19",
            [3] = "Infantry AK Ins",
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
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["Shipping"] = {
            [1] = "Dry-cargo ship-2"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Pz_IV_H",
            [2] = "Pz_IV_H",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "Sd_Kfz_251",
            [2] = "Sd_Kfz_251",
            [3] = "Bedford_MWD"
        },
        ["Inf"] = {
            [1] = "Blitz_36-6700A",
			[2] = "Blitz_36-6700A",
            [3] = "Blitz_36-6700A",
            [4] = "Blitz_36-6700A",
			[5] = "Bedford_MWD",
			[6] = "S_75_ZIL"
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
		["DeployedGun"] = {
            [1] = "Infantry AK ver3",
            [2] = "KS-19",
            [3] = "Infantry AK ver3",
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
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "Bedford_MWD"
        },
        ["Shipping"] = {
            [1] = "Dry-cargo ship-2"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["M2A1_halftrack"] = "IFV",
    ["Sd_Kfz_251"] = "IFV",
	["Type_94_Truck"] = "APC",
    ["Blitz_36-6700A"] = "APC",
}

PlatoonGunCarrierTypeNames = {
    ["S_75_ZIL"] = "GUN"
}
PlatoonGunTypeNames = {
    ["KS-19"] = "GUN"
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
        [1] = "M2A1_halftrack",
    },
    [2] = {
        [1] = "Sd_Kfz_251",
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
        --[2] = {"David","Michael","James","John","Robert","Mark","William","Richard","Thomas","Steven","Timothy","Joseph","Charles","Jeffrey","Kevin","Kenneth","Daniel","Paul","Donald","Brian","Ronald","Gary","Scott","Gregory","Anthony","Edward","Stephen","Larry","Christopher","Douglas","Dennis","Randy","George","Terry","Keith","Mike","Jerry","Ricky","Bruce","Frank","Peter","Craig","Steve","Eric","Patrick","Raymond","Roger","Danny","Jeff","Alan","Andrew"},
    },
    [2] = {
        [1] = {"Stefan","Michael","Andreas","Thomas","Frank","Markus","Christian","Oliver","Matthias","Torsten","Martin","Sven","Alexander","Dirk","Karsten","Ralf","Jörg","Jan","Marc","Peter","Jürgen","Klaus","Uwe","Sebastian","Daniel","Hans","Wolfgang","Bernd","Rainer","Joachim","Dieter","Manfred","Norbert","Axel","Rolf","Olaf","Lutz","Werner","Volker","Jens"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Ivanov","Kuznetsov","Petrov","Magomedov","Smirnov","Popov","Volkov","Shevchenko","Vasilev","Novikov","Morozov","Pavlov","Sokolov","Aliev","Mikhaylov","Romanov","Makarov","Egorov","Kozlov","Nikolaev","Stepanov","Andreev","Zakharov","Kovalenko","Sergeev","Bondarenko","Nikitin","Zaytsev","Medvedev","Orlov","Kravchenko","Frolov","Kuzmin","Yakovlev","Belov","Lebedev","Alekseev","Borisov","Antonov","Tkachenko","Tarasov","Sidorov","Mironov","Dmitriev","Isaev","Kotov","Matveev","Sorokin","Semenov","Fedorov","Zhukov"},
        --[2] = {"Smith","Johnson","Williams","Jones","Brown","Davis","Miller","Wilson","Moore","Taylor","Anderson","Thomas","Jackson","White","Harris","Martin","Thompson","Robinson","Clark","Lewis","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce"},
    },
    [2] = {
        [1] = {"Müller","Schmidt","Schneider","Fischer","Weber","Meyer","Wagner","Becker","Schulz","Hoffmann","Schäfer","Koch","Bauer","Richter","Klein","Wolf","Schröder","Neumann","Schwarz","Zimmermann","Braun","Krüger","Hofmann","Hartmann","Lange","Schmitt","Werner","Schmitz","Krause","Meier","Lehmann","Schmid","Schulze","Maier","Köhler","Herrmann","König","Walter","Mayer","Huber","Kaiser","Fuchs","Peters","Lang","Scholz","Möller","Weiß","Jung","Hahn","Schubert"}
    }
}

CASCALLSIGNS = {
    --TODO move these to overrides
    alphanumerics = {
        [1] = {
            [1] = "Able",
            [2] = "Baker",
            [3] = "Charlie",
            [4] = "Dog",
            [5] = "Easy",
            [6] = "Fox",
        },
        [2] = {
            [1] = "Anton",
            [2] = "Bertha",
            [3] = "Casar",
            [4] = "Dora",
            [5] = "Emil",
            [6] = "Friedrich"
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