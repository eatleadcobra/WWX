trigger.action.setUserFlag("MISSION_ID", 102)
-- enabled features
SUBS = true
ACTIVETORP = true
SUBTYPE =
{
    [1] = "santafe",
    [2] = "santafe",
}
CAP = false
PIRACY = true
BOMBERS = true
ESCORT = true
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = true
STRIKES = true
REAPER = true
INTERCEPT = true
SHIPPING = true
CAPTURE = false
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
    ["Hatay"] = true
}
NAVALCONVOY = {
    [1] = false,
    [2] = false,
}
RESPAWNGROUPS = {
    ["Red-RD-SA2"] = 7200, -- 2 hours
}
SUNSET = 65130 -- 18:05:30 local time
RUNTIME = 43200 -- 12 hours runtime
-- counts
FDCount = 2
AACount = 6
RDSubcount = 4
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false
BLUECASFREQ = 225
REDCASFREQ = 140
BLUECASMOD = 0
REDCASMOD = 1
DISABLEF10CARGOSTATUS = true
Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "T62M",
            [2] = "T62M",
            [3] = "GAZ-66"
        },
        ["Mech"] = {
            [1] = "BRDM-2_malyutka",
            [2] = "BMP-1",
            [3] = "BMP-1",
            [4] = "GAZ-66"
        },
        ["Inf"] = {
            [1] = "BTR-60",
            [2] = "BTR-60",
            [3] = "GAZ-66",
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
        ["DeployedGun"] = {
            [1] = "Infantry AK ver2",
            [2] = "KS-19",
            [3] = "Infantry AK ver2",
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
            [2] = "GAZ-66"
        },
        ["EmbeddedADHigh"] = {
            [1] = "HL_ZU-23",
            [2] = "GAZ-66"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
            [2] = "CastleClass_01"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "M-60",
            [2] = "M-60",
            [4] = "M1045 HMMWV TOW",
            [5] = "M 818"
        },
        ["Mech"] = {
            [1] = "M1045 HMMWV TOW",
            [2] = "M-113",
            [3] = "M-113",
            [4] = "M 818"
        },
        ["Inf"] = {
            [1] = "M-113",
            [2] = "M-113",
            [3] = "M 818"
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
        ["DeployedGun"] = {
            [1] = "Infantry AK ver2",
            [2] = "KS-19",
            [3] = "Infantry AK ver2",
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
            [2] = "M 818"
        },
        ["EmbeddedADHigh"] = {
            [1] = "HL_ZU-23",
            [2] = "M 818"
        },
        ["Shipping"] = {
            [1] = "HandyWind",
            [2] = "CastleClass_01"
        }
    }
}
PlatoonUnitCarrierTypeNames = {
    ["BMP-1"] = "IFV",
    ["BTR-60"] = "APC",
    ["M-113"] = "APC",
}
PlatoonUnitCarrierTypeNames = {
    ["Bedford_MWD"] = "APC",
    ["Blitz_36-6700A"] =  "APC",
}
PlatoonGunCarrierTypeNames = {
    ["Land_Rover_101_FC"] = "GUN"
}

PltStrengths = {
    [1] = 15,
    [2] = 4 + #Platoons[1]["DeployedInf"],
    [3] = 3 + #Platoons[1]["DeployedInf"],
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
        [1] = {"Ahmed","Mohamed","Mahmoud","Omar","Amr","Muhammad","Mohammed","Youssef","Ahmad","Mostafa","Abdelrahman","Mido","Mustafa","Karim","Abdo","Eslam","Michael","Tarek","Aly","Nour","Medo","Yahya","Daniel","Kareem","Sherif","Miro","Hamada","Abdallah","Khaled","Osama"}
    },
    [2] = {
        [1] = {"Mehmet","Fatma","Mustafa","Ayşe","Ahmet","Ali","Emine","Hatice","Hasan","Hüseyin","Ibrahim","Murat","Ismail","Zeynep","Ömer","Osman","Ramazan","Halil","Yusuf","Elif","Meryem","Abdullah","Süleyman","Fatih","Sultan","Özlem","Mahmut","Hülya","Recep","Yasemin","Hakan","Sevim","Yaşar","Şerife","Dilek","Adem","Aysel","Fadime","Metin","Leyla","Zehra","Kemal","Hacer","Hanife","Havva","Songül","Kadir","Salih","Esra","Orhan","Aynur","Zeliha","Merve","Serkan","Filiz","Melek","Gökhan","Bayram","Cemile","Sevgi","Sibel","Kadriye","Selma","Uğur","Ayten","Derya","Yunus","Ayhan","Muhammet","Emre","Semra","Tuğba","Halime","Yılmaz","Bekir","Arzu","Musa","Türkan","Erkan","Ebru","Şükran","Gülsüm","Hayriye","Serpil","Mesut","Yüksel","Haci","Bülent","Gülşen","Nurcan","Ercan","Nuray","Sinan","Erol","Cemal","Asiye","Pınar","Ayşegül","Ismet","Cengiz","Çiğdem","Kübra","Gülay","Emrah","Yasin","Döndü","Ümit","Kenan","Nurten","Rukiye","Rabia","Büşra","Dursun","Aydın","Deniz","Erdal","Yakup","Arif","Muhammed","Keziban","Gönül","Seher","Sedat","Serdar","Muzaffer","Burak","Güler","Meral","Remziye","Esma","Şaban","Şükrü","Hava","Yıldız","Hanım","Sevda","Sema","Engin","Saniye","Gülten","Nuriye","Abdurrahman","Celal","Neslihan","Canan","Serap","Bilal","Zeki","Selahattin","Isa","Necla","Zekiye","Ferhat","Naciye","Harun","Nihat","Perihan","Tülay","Yeter","Emel","Hikmet","Onur","Özgür","Muharrem","Makbule","Emin","Ekrem","Erhan","Huriye","Burcu","Safiye","Gamze","Ilknur","Nuran","Medine","Adnan","Mevlüt","Seda","Ayfer","Saliha","Abdulkadir","Gülcan","Nazmiye","Feride","Nurettin","Zübeyde","Rahime","Münevver","Şengül","Nermin","Faruk","Cemil","Meliha","Ilhan","Ihsan","Güllü","Irfan","Saadet","Hamide","Bahar","Nuri","Zafer","Kazım","Neriman","Bariş","Necati","Kamil","Hediye","Veli","Şahin","Tuba","Aysun","Selim","Veysel","Müzeyyen","Nazli","Sabri","Burhan","Arife","Vedat","Halit","Betül","Ilyas","Duygu","Gülseren","Zahide","Levent","Yavuz","Erdoğan","Özcan","Cihan","Aziz","Selçuk","Hilal","Cennet","Şadiye","Tuncay","Nesrin","Nimet","Fikret","Muammer","Melahat","Volkan","Birgül","Durmuş","Özge","Reyhan","Asli","Nazife","Nurgül","Sadık","Memet","Nevzat","Ersin","Elmas","Habibe","Doğan","Fikriye","Nihal","Eyüp","Hamza","Dudu","Remzi","Özkan","Suna","Eda","Kezban","Turan","Bedriye","Nevin","Suat","Mehtap","Raziye","Sami","Cuma","Sati","Sebahat","Hafize","Servet","Mine","Serhat","Lütfiye","Çetin","Şükriye","Melike","Enver","Nebahat","Selda","Idris","Semiha","Hatun","Kıymet","Davut","Neşe","Ridvan","Şenay","Hakki","Öznur","Haydar","Soner"}
    },
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Mohamed","Ahmed","Hassan","Ali","Mahmoud","Ibrahim","Gamal","Abdel","Mostafa","Salah","Adel","Hussein","Samir","Saad","Soliman","Kamal","Hamdy","Saleh","Salem","Nabil","Youssef","Samy","Said","Fathy","Sayed","Elsayed","Khalil","Aly","Mohammed","Kamel"}
    },
    [2] = {
        [1] = {"Yılmaz","Kaya","Demir","Çelik","Şahin","Yıldız","Yıldırım","Öztürk","Aydın","Özdemir","Arslan","Doğan","Kılıç","Aslan","Çetin","Kara","Koç","Kurt","Özkan","Acar","Polat","Şimşek","Korkmaz","Özcan","Erdoğan","Çakir","Yavuz","Can","Şen","Yalçın","Güler","Aktaş","Güneş","Bozkurt","Bulut","Işık","Turan","Keskin","Avci","Ünal","Gül","Coşkun","Özer","Kaplan","Sari","Tekin","Taş","Yüksel","Köse","Ateş","Aksoy","Yiğit","Karataş","Uzun","Ceylan","Karaca","Çiftçi","Çiçek","Çoban","Çalişkan","Yaşar","Demirci","Bayram","Deniz","Çakmak","Güngör","Uçar","Erdem","Kahraman","Uysal","Genç","Çinar","Duman","Akın","Sönmez","Demirel","Ay","Kilinç","Koçak","Mutlu","Küçük","Çetinkaya","Yaman","Altun","Gündüz","Gümüş","Öz","Eren","Aydemir","Çolak","Tunç","Karakaya","Güven","Kartal","Gök","Karaman","Dönmez","Erol","Aksu","Alkan","Tosun","Özen","Türk","Balci","Sağlam","Karakuş","Cengiz","Çevik","Güzel","Karabulut","Akbaş","Keleş","Duran","Durmuş","Ince","Baş","Eroğlu","Akkaya","Akbulut","Demirtaş","Durmaz","Akgün","Yücel","Uslu","Dursun","Aydoğan","Yazici","Özçelik","Er","Çelebi","Koca","Karagöz","Ünlü","Ekinci","Karakaş","Gürbüz","Toprak","Akgül","Türkmen","Topal","Dinç","Gültekin","Dağ","Topçu","Sarıkaya","Şentürk","Vural","Zengin","Özmen","Ergün","Şeker","Gündoğdu","Bilgin","Ilhan","Bal","Gökçe","Fidan","Sezer","Güney","Albayrak","Güner","Bektaş","Akyol","Oğuz","Inan","Karadağ","Bayrak","Turgut","Orhan","Akar","Aydoğdu","Taşkın","Kalkan","Özel","Ak","Ercan","Akyüz","Ipek","Uğur","Esen","Akkuş","Günay","Bayraktar","Taşdemir","Budak","Akpınar","Açıkgöz","Aygün","Özbek","Öner","Temel","Ersoy","Ayhan","Efe","Çam","Ari","Şener","Sevinç","Çağlar","Ergin","Tuncer","Ertürk","Baran","Sert","Akdemir","Ayaz","Gür","Koyuncu","Akçay","Kaçar","Aras","Altıntaş","Akça","Başaran","Karakoç","Tan","Şengül","Gezer","Akdağ","Karadeniz","Atalay","Bakir","Altin","Çimen","Biçer","Karahan","Akman","Akdeniz","Turhan","Dündar","Gün","Oruç","Sezgin","Mert","Kandemir","Kuş","Bingöl","Usta","Bolat","Bülbül","Taşçi","Yüce","Pehlivan","Fırat","Tuna","Önal","Çakar","Metin","Dinçer","Yeşil","Savaş","Uyar","Altuntaş","Ekici","Arıkan","Atmaca","Akdoğan","Altay","Sevim","Erkan","Kutlu","Doğru","Yalçınkaya","Özkaya","Önder","Demirbaş","Öksüz","Ataş","Boz","Durak","Eser","Eker","Kuru","Oral","Varol","Demircan","Parlak","Ölmez","Gedik","Güçlü","Köksal","Akay","Adıgüzel","Türkoğlu","Göktaş","Soylu","Ertaş","Özden","Şenol","Şanli","Güleç","Ünsal","Uğurlu","Torun","Gürsoy","Bilgiç","Akinci","Ergül","Şahan","Köroğlu"}
    },
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