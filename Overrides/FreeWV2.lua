trigger.action.setUserFlag("MISSION_ID", 4)
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
        shipping = false,
        trains = true,
        aircargo = true,
    },
    [2] = {
        shipping = true,
        trains = true,
        aircargo = false,
    }
}
CAP = true
PIRACY = true
BOMBERS = true
ESCORT = false
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
STRIKES = false
REAPER = false
INTERCEPT = false
SHIPPING = true
TRAINS = true
AIRCARGO = true
AIRCARGOINTERVAL = 1600
CAPTURE = false
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
            [1] = "M2A1_halftrack",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "M2A1_halftrack",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "M2A1_halftrack",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "M2A1_halftrack",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "KAMAZ Truck",
            [5] = "KAMAZ Truck",
            [6] = "KAMAZ Truck",
            [7] = "M2A1_halftrack",
            [8] = "KAMAZ Truck",
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "KAMAZ Truck"
        },
        ["EmbeddedADhigh"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "KAMAZ Truck"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            [2] = "CastleClass_01"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Pz_IV_H",
            [2] = "Pz_IV_H",
            [3] = "Blitz_36-6700A"
        },
        ["Mech"] = {
            [1] = "Sd_Kfz_251",
            [2] = "Sd_Kfz_251",
            [3] = "Blitz_36-6700A",
        },
        ["Inf"] = {
            [1] = "Blitz_36-6700A",
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
            [1] = "Sd_Kfz_251",
            [2] = "M978 HEMTT Tanker",
            [3] = "M978 HEMTT Tanker",
            [4] = "M978 HEMTT Tanker",
            [5] = "M978 HEMTT Tanker",
            [6] = "M978 HEMTT Tanker",
            [7] = "Sd_Kfz_251",
            [8] = "M978 HEMTT Tanker",
        },
        ["AmmoConvoy"] = {
            [1] = "Sd_Kfz_251",
            [2] = "GAZ-66",
            [3] = "GAZ-66",
            [4] = "GAZ-66",
            [5] = "GAZ-66",
            [6] = "GAZ-66",
            [7] = "Sd_Kfz_251",
            [8] = "GAZ-66",
        },
        ["EquipmentConvoy"] = {
            [1] = "Sd_Kfz_251",
            [2] = "M 818",
            [3] = "M 818",
            [4] = "M 818",
            [5] = "M 818",
            [6] = "M 818",
            [7] = "Sd_Kfz_251",
            [8] = "M 818",
        },
        ["EmbeddedAD"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "GAZ-66"
        },
        ["EmbeddedADHigh"] = {
            [1] = "Type_94_25mm_AA_Truck",
            [2] = "GAZ-66"
        },
        ["Shipping"] = {
            [1] = "Ship_Tilde_Supply",
            [2] = "CastleClass_01"
        }
    }
}

PlatoonUnitCarrierTypeNames = {
    ["Land_Rover_101_FC"] = "APC",
    ["Bedford_MWD"] = "APC",
    ["Blitz_36-6700A"] =  "APC",
}
PltStrengths = {
    [1] = 10,
    [2] = 3,
    [3] = 2,
    [7] = 2,
    [9] = 2
}
PltCosts = {
    [1] = {
        [1] = 5, --fuel
        [2] = 9, --ammo
        [3] = 4, --equipment
    },
    [2] = {
        [1] = 3, --fuel
        [2] = 4, --ammo
        [3] = 2, --equipment
    },
    [3] = {
        [1] = 1, --fuel
        [2] = 2, --ammo
        [3] = 0, --equipment
    },
    [7] = {
        [1] = 4, --fuel
        [2] = 2, --ammo
        [3] = 1, --equipment
    },
    [9] = {
        [1] = 4, --fuel
        [2] = 2, --ammo
        [3] = 1, --equipment
    },
}
CompanyCompTiers = {
    [0] = {composition = nil},
    [1] = {
        --tank
        composition = {1,2,7},
    },
    [2] = {
        composition = {1,3,7},
    },
    [3] = {
        composition = {1,7},
    },
    [4] = {
        composition = {2,7},
    },
    [5] = {
        composition = {2,2},
    },
    [6] = {
        composition = {2,3},
    },
    [7] = {
        composition = {2},
    },
    [8] = {
        composition = {3,3},
    },
    [9] = {
        composition = {3},
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
        [1] = "Infantry AK",
        [2] = "Infantry AK Ins",
        [3] = "Infantry AK Ins",
        [4] = "Infantry AK ver2",
        [5] = "Infantry AK ver3"
    },
    [2] = {
        [1] = "Soldier M4",
        [2] = "Soldier M4 GRG",
        [3] = "Soldier M4 GRG",
        [4] = "Infantry AK ver2",
        [5] = "Soldier M4 GRG",
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