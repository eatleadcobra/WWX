trigger.action.setUserFlag("MISSION_ID", 101)
-- enabled features
SUBS = true
ACTIVETORP = false
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
COALITIONSHIPPINGMETHODS = {
    [1] = {
        shipping = true,
        trains = false,
        aircargo = false,
    },
    [2] = {
        shipping = true,
        trains = false,
        aircargo = false,
    }
}
CAP = false
PIRACY = false
BOMBERS = true
ESCORT = false
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
STRIKES = true
REAPER = false
INTERCEPT = false
SHIPPING = true
TRAINS = true
AIRCARGO = true
AIRCARGOINTERVAL = 7200
CAPTURE = false
DOUBLEBOMBERS = true
COMPANIESIGNOREROADS = true
CAVICS = {
    [1] = {
    },
    [2] = {
    }
}
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 28800 -- 8 hours runtime
-- counts
FDCount = 2
RDSubcount = 2
AACount = 0
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false

BLUECASFREQ = 150
REDCASFREQ = 150
BLUECASMOD = 0
REDCASMOD = 0
Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-34-85",
            [2] = "GAZ-66"
        },
        ["Mech"] = {
            [1] = "BTR-60",
            [2] = "BTR-60",
            [3] = "GAZ-66"
        },
        ["Inf"] = {
            [1] = "M2A1_halftrack",
            [2] = "GAZ-66",
            [3] = "GAZ-66",
            [4] = "Land_Rover_101_FC"
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
            [1] = "BTR-60",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "BTR-60",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "BTR-60",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "BTR-60",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "BTR-60",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "KAMAZ Truck",
            [5] = "KAMAZ Truck",
            [6] = "KAMAZ Truck",
            [7] = "BTR-60",
            [8] = "KAMAZ Truck",
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "KAMAZ Truck"
        },
        ["EmbeddedADHigh"] = {
            [1] = "HL_ZU-23",
            [2] = "KAMAZ Truck"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "M4_Sherman",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "M-113",
            [2] = "M-113",
            [3] = "M1043 HMMWV Armament",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "M2A1_halftrack",
            [2] = "Bedford_MWD",
            [3] = "Bedford_MWD",
            [4] = "Land_Rover_101_FC",
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
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "KAMAZ Truck"
        },
        ["EmbeddedADHigh"] = {
            [1] = "HL_ZU-23",
            [2] = "KAMAZ Truck"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["TPZ"] = "APC",
    ["M-113"] = "IFV",
    ["Bedford_MWD"] = "APC",
    ["GAZ-66"] = "APC",
}
PlatoonGunCarrierTypeNames = {
    ["Land_Rover_101_FC"] = "GUN"
}
PlatoonGunTypeNames = {
    ["KS-19"] = "GUN"
}
RESPAWNGROUPS = {
    ["Red-Battleship"] = 2700, --45 minutes
    ["Blue-Battleship"] = 2700, --45 minutes
}
PltStrengths = {
    [1] = 10,
    [2] = 3,
    [3] = 2,
    [7] = 2,
    [9] = 2
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
        [1] = "Red Forward Field Hospital",
    },
    [2] = {
        [1] = "Blue Forward Field Hospital",
    }
}
CSARFreqCollisions = {
    [1] = {
        ["NDB"] = {
            21,22,24,25,28,29,30,31,32,33,34,35,40,41,43,44,49,52,53,58,59
        },
        ["TACAN"] = {
            16,22,25,31,44
        }
    },
    [2] = {
        ["NDB"] = {
            62,63,68,69,71,72,76,80,81,87,92,93,99,100,105,106,107
        },
        ["TACAN"] = {
            67
        }
    }
}
CSARHunterOptions = {
    [1] = {
        [1] = "Soldier M4 GRG",
        [2] = "Soldier M4 GRG",
        [3] = "Soldier M4 GRG",
        [4] = "Soldier M4 GRG",
        [5] = "Soldier M249",
    },
    [2] = {
        [1] = "Infantry AK ver2",
        [2] = "Infantry AK ver3",
        [3] = "Infantry AK ver2",
        [4] = "Infantry AK ver3",
        [5] = "Infantry AK ver2",
    }
}
CSARHunterEliteOptions = {
[1] = {
    [1] = "tt_DSHK",
    [2] = "HL_DSHK",
    [3] = "tt_DSHK",
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
        [2] = {"David","Michael","James","John","Robert","Mark","William","Richard","Thomas","Steven","Timothy","Joseph","Charles","Jeffrey","Kevin","Kenneth","Daniel","Paul","Donald","Brian","Ronald","Gary","Scott","Gregory","Anthony","Edward","Stephen","Larry","Christopher","Douglas","Dennis","Randy","George","Terry","Keith","Mike","Jerry","Ricky","Bruce","Frank","Peter","Craig","Steve","Eric","Patrick","Raymond","Roger","Danny","Jeff","Alan","Andrew"},
    },
    [2] = {
        [1] = {"Stefan","Michael","Andreas","Thomas","Frank","Markus","Christian","Oliver","Matthias","Torsten","Martin","Sven","Alexander","Dirk","Karsten","Ralf","Jörg","Jan","Marc","Peter","Jürgen","Klaus","Uwe","Sebastian","Daniel","Hans","Wolfgang","Bernd","Rainer","Joachim","Dieter","Manfred","Norbert","Axel","Rolf","Olaf","Lutz","Werner","Volker","Jens"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Ivanov","Kuznetsov","Petrov","Magomedov","Smirnov","Popov","Volkov","Shevchenko","Vasilev","Novikov","Morozov","Pavlov","Sokolov","Aliev","Mikhaylov","Romanov","Makarov","Egorov","Kozlov","Nikolaev","Stepanov","Andreev","Zakharov","Kovalenko","Sergeev","Bondarenko","Nikitin","Zaytsev","Medvedev","Orlov","Kravchenko","Frolov","Kuzmin","Yakovlev","Belov","Lebedev","Alekseev","Borisov","Antonov","Tkachenko","Tarasov","Sidorov","Mironov","Dmitriev","Isaev","Kotov","Matveev","Sorokin","Semenov","Fedorov","Zhukov"},
        [2] = {"Smith","Johnson","Williams","Jones","Brown","Davis","Miller","Wilson","Moore","Taylor","Anderson","Thomas","Jackson","White","Harris","Martin","Thompson","Robinson","Clark","Lewis","Simpson","Adams","Foster","Rogers","Hunt","Owen","Powell","Mason","Holmes","Barker","Lloyd","Barnes","Mills","Palmer","Matthews","Knight","Jenkins","Gray","Pearson","Fisher","Dixon","Butler","Fletcher","Stevens","Anderson","Harvey","Russell","Kelly","Howard","Pearce"},
    },
    [2] = {
        [1] = {"Müller","Schmidt","Schneider","Fischer","Weber","Meyer","Wagner","Becker","Schulz","Hoffmann","Schäfer","Koch","Bauer","Richter","Klein","Wolf","Schröder","Neumann","Schwarz","Zimmermann","Braun","Krüger","Hofmann","Hartmann","Lange","Schmitt","Werner","Schmitz","Krause","Meier","Lehmann","Schmid","Schulze","Maier","Köhler","Herrmann","König","Walter","Mayer","Huber","Kaiser","Fuchs","Peters","Lang","Scholz","Möller","Weiß","Jung","Hahn","Schubert"}
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
