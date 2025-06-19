trigger.action.setUserFlag("MISSION_ID", 3)
-- enabled features
SUBS = false
CAP = true
PIRACY = false
BOMBERS = true
MISSILEBOATS = true
CARGO = true
CSAR = true
CAS = true
SHIPPING = true
CAPTURE = false
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
-- counts
FDCount = 2
AACount = 6
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 225
REDCASFREQ = 45
BLUECASMOD = 0
REDCASMOD = 1

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T-72B",
            [2] = "T-72B",
            [3] = "GAZ-66"
        },
        ["Mech"] = {
            [1] = "BTR_D",
            [2] = "BTR_D",
            [3] = "BMP-1",
            [4] = "GAZ-66"
        },
        ["Inf"] = {
            [1] = "BTR_D",
            [2] = "BTR-80",
            [3] = "BTR-80",
            [4] = "GAZ-66",
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
            [1] = "BTR-80",
            [2] = "ATZ-5",
            [3] = "ATZ-5",
            [4] = "ATZ-5",
            [5] = "ATZ-5",
            [6] = "ATZ-5",
            [7] = "BTR-80",
            [8] = "ATZ-5",
        },
        ["AmmoConvoy"] = {
            [1] = "BTR-80",
            [2] = "Ural-375",
            [3] = "Ural-375",
            [4] = "Ural-375",
            [5] = "Ural-375",
            [6] = "Ural-375",
            [7] = "BTR-80",
            [8] = "Ural-375",
        },
        ["EquipmentConvoy"] = {
            [1] = "BTR-80",
            [2] = "KAMAZ Truck",
            [3] = "KAMAZ Truck",
            [4] = "KAMAZ Truck",
            [5] = "KAMAZ Truck",
            [6] = "KAMAZ Truck",
            [7] = "BTR-80",
            [8] = "KAMAZ Truck",
        },
        ["EmbeddedAD"] = {
            --[1] = "Strela-1 9P31",
            [1] = "ZSU-23-4 Shilka",
            [2] = "GAZ-66"
        },
        ["Shipping"] = {
            [1] = "Dry-cargo ship-2"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Leopard1A3",
            [2] = "Leopard1A3",
            [3] = "M 818"
        },
        ["Mech"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "Marder",
            [3] = "Marder",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "TPZ",
            [3] = "TPZ",
            [4] = "M 818"
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
            [1] = "Vulcan",
            [2] = "M 818"
        },
        ["Shipping"] = {
            [1] = "Dry-cargo ship-2"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["Marder"] = "IFV",
    ["BMP-1"] = "IFV",
    ["TPZ"] = "APC",
    ["BTR-80"] = "APC",
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
        ["NDB"] = {20,69},
        ["TACAN"] = {10,59}
    },
    [2] = {
        ["NDB"] = {71,120},
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
            20,21,22,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,62,66,67,68
        },
        ["TACAN"] = {
            24,28,32,47,48,56
        }
    },
    [2] = {
        ["NDB"] = {
            76,77,84,85,86,87,89,90,95,96,97,98
        },
        ["TACAN"] = {
            77,81,84,88,89,108
        }
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