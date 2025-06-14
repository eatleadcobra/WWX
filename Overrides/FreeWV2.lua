trigger.action.setUserFlag("MISSION_ID", 1)
-- enabled features
SUBS = false
CAP = true
PIRACY = false
BOMBERS = true
MISSILEBOATS = false
CARGO = true
CSAR = true
CAS = false
-- counts
FDCount = 2
AACount = 0
-- settings
CSARAUTOENROLL = true
CASAUTOENROLL = false

Platoons = {
    [1] = {
        ["Armor"] = {
            [1] = "M4_Sherman",
            [2] = "M2A1_halftrack",
            [3] = "Bedford_MWD"
        },
        ["Mech"] = {
            [1] = "M2A1_halftrack",
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
            [1] = "Ural-375 ZU-23",
            [2] = "KAMAZ Truck"
        }
    },
    [2] = {
        ["Armor"] = {
            [1] = "Pz_IV_H",
            [2] = "Sd_Kfz_251",
            [3] = "Blitz_36-6700A"
        },
        ["Mech"] = {
            [1] = "Sd_Kfz_251",
            [2] = "GAZ-66",
        },
        ["Inf"] = {
            [1] = "GAZ-66",
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
            [1] = "Ural-375 ZU-23",
            [2] = "GAZ-66"
        }
    }
}

PlatoonUnitCarrierTypeNames = {
    ["Land_Rover_101_FC"] = "APC",
    ["Bedford_MWD"] = "APC",
    ["Blitz_36-6700A"] =  "APC",
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
            21,22,24,25,28,29,30,31,32,33,34,35,40,41,43,44,49,52,53,58,59,62,63,68,69
        },
        ["TACAN"] = {
            16,22,25,31,44
        }
    },
    [2] = {
        ["NDB"] = {
            71,72,76,80,81,87,92,93,99,100,105,106,107
        },
        ["TACAN"] = {
            67
        }
    }
}
RandomNames.firstNames = {
    [1] = {
        [1] = {"Mehmet","Fatma","Mustafa","Ayşe","Ahmet","Ali","Emine","Hatice","Hasan","Hüseyin","Ibrahim","Murat","Ismail","Zeynep","Ömer","Osman","Ramazan","Halil","Yusuf","Elif","Meryem","Abdullah","Süleyman","Fatih","Sultan","Özlem","Mahmut","Hülya","Recep","Yasemin","Hakan","Sevim","Yaşar","Şerife","Dilek","Adem","Aysel","Fadime","Metin","Leyla","Zehra","Kemal","Hacer","Hanife","Havva","Songül","Kadir","Salih","Esra","Orhan","Aynur","Zeliha","Merve","Serkan","Filiz","Melek","Gökhan","Bayram","Cemile","Sevgi","Sibel","Kadriye","Selma","Uğur","Ayten","Derya","Yunus","Ayhan","Muhammet","Emre","Semra","Tuğba","Halime","Yılmaz","Bekir","Arzu","Musa","Türkan","Erkan","Ebru","Şükran","Gülsüm","Hayriye","Serpil","Mesut","Yüksel","Haci","Bülent","Gülşen","Nurcan","Ercan","Nuray","Sinan","Erol","Cemal","Asiye","Pınar","Ayşegül","Ismet","Cengiz","Çiğdem","Kübra","Gülay","Emrah","Yasin","Döndü","Ümit","Kenan","Nurten","Rukiye","Rabia","Büşra","Dursun","Aydın","Deniz","Erdal","Yakup","Arif","Muhammed","Keziban","Gönül","Seher","Sedat","Serdar","Muzaffer","Burak","Güler","Meral","Remziye","Esma","Şaban","Şükrü","Hava","Yıldız","Hanım","Sevda","Sema","Engin","Saniye","Gülten","Nuriye","Abdurrahman","Celal","Neslihan","Canan","Serap","Bilal","Zeki","Selahattin","Isa","Necla","Zekiye","Ferhat","Naciye","Harun","Nihat","Perihan","Tülay","Yeter","Emel","Hikmet","Onur","Özgür","Muharrem","Makbule","Emin","Ekrem","Erhan","Huriye","Burcu","Safiye","Gamze","Ilknur","Nuran","Medine","Adnan","Mevlüt","Seda","Ayfer","Saliha","Abdulkadir","Gülcan","Nazmiye","Feride","Nurettin","Zübeyde","Rahime","Münevver","Şengül","Nermin","Faruk","Cemil","Meliha","Ilhan","Ihsan","Güllü","Irfan","Saadet","Hamide","Bahar","Nuri","Zafer","Kazım","Neriman","Bariş","Necati","Kamil","Hediye","Veli","Şahin","Tuba","Aysun","Selim","Veysel","Müzeyyen","Nazli","Sabri","Burhan","Arife","Vedat","Halit","Betül","Ilyas","Duygu","Gülseren","Zahide","Levent","Yavuz","Erdoğan","Özcan","Cihan","Aziz","Selçuk","Hilal","Cennet","Şadiye","Tuncay","Nesrin","Nimet","Fikret","Muammer","Melahat","Volkan","Birgül","Durmuş","Özge","Reyhan","Asli","Nazife","Nurgül","Sadık","Memet","Nevzat","Ersin","Elmas","Habibe","Doğan","Fikriye","Nihal","Eyüp","Hamza","Dudu","Remzi","Özkan","Suna","Eda","Kezban","Turan","Bedriye","Nevin","Suat","Mehtap","Raziye","Sami","Cuma","Sati","Sebahat","Hafize","Servet","Mine","Serhat","Lütfiye","Çetin","Şükriye","Melike","Enver","Nebahat","Selda","Idris","Semiha","Hatun","Kıymet","Davut","Neşe","Ridvan","Şenay","Hakki","Öznur","Haydar","Soner"}
    },
    [2] = {
        [1] = {"Andreas","Maria","Georgios","Eleni","Costas","Nicos","Panayiotis","Kyriacos","Christos","Charalambos","Anna","Christakis","Georgia","Panayiota","Androulla","Marios","Ioannis","Michalis","Christina","Savvas","Chrystalla","Antonis","Demetris","Elena","Michael","Stelios","Maroulla","Niki","Michalakis","Stella","Androula","Constantinos","Petros","Stavros","Yiannakis","Katerina","Irene","Christodoulos","Marina","Soteris","Despina","Kyriaki","George","Andri","Demetra","Ioanna","Elli","Panicos","Maroula","Pavlos","Anastasia","Demetrios","Andriani","Loizos","Theodora","Theodoros","Pantelis","Nicolas","Panagiota","Loucas","Elias","Costakis","Neophytos","Christoforos","Anastassia","Spyros","Yiannis","Takis","Vassos","Dora","Despo","Mary","Angeliki","Margarita","Sophia","Stavroulla","Eleftheria","Sofia","Giorgos","Kypros","Maro","Christiana","Paraskevi","Constantia","Yiannoula","Alexandros","Antonios","Charis","Philippos","Loukia","Olga","Stavroula","Antonia","Nitsa","Kyriakos","Antonakis","Iacovos","Chrysostomos","Eleftherios","Xenia","Katina","Evangelos","Alexandra","Athina","Panagiotis","Pantelitsa","Myrofora","Antigoni","Andriana","Evangelia","Marianna","Eftychia","Kalliopi","Koulla","Kyriacou","Angela","Leonidas","Lambros","John","Demetrakis","Elisavet","Evanthia","Artemis","Angelos","Nicolaos","Nikos","Gregoris","Evdokia","Adamos","Achilleas","Agathi","Elpida","David","Vasiliki","Zacharias","Chrysoulla","Evgenia","Ioulia","Yiannoulla","Vassiliki","Anastassis","Aristos","Lenia","Eva","Marinos","Stylianos","Kyriakou","Christofis","Elenitsa","Chryso","Athena","Thekla","Thomas","Paris","Soteroulla","Zoe","Varvara","Sophocles","Koula","Demos","Ourania","Androniki","Maritsa","Socrates","Anthoula","Froso","Vassilis","Chloe","Polyxeni","Phanos","Tassos","Anthoulla","Popi","Pambos","Photini","Aliki","Constantina","Paraskevas","Tasoula","Despoina","Myrianthi","Chrysanthos","Paraskevou","Nina","Militsa","Chariklia","Themis","Avgi","Evripides","Menelaos","Loucia","Yiannos","Martha","Chrysanthi","Efstathios","Charalambia","Nikolas","Louiza","Marcos","Emilia","Evi","Gavriel","Chrysoula","Soteroula","Anastassios","Stephanos","Tatiana","Emilios","Renos","Anthi","Doros","Aphrodite","Evridiki","Solon","Mikis","Tasos","Kostas","Alexia","Skevi","Evagoras","Yiangos","Ellada","Alexis","Flora","Susan","Miltiades","Konstantinos","Kallistheni","Victoria","Mamas","Peter","Elpiniki","Sotera","Theodoulos","Cleanthis","Zenon","Rena","Phivos","Margaret","Akis","Alecos","Efthymios","Frixos","Avraam","Kika","Amalia","Theophanis","Athanasia","Theognosia","Sylvia","Ntinos","Georgoula","Myria","Theocharis","Marilena","Photis","Apostolos","Pieris","Efthymia","Prodromos","Minas","Theodossis","Charoula","Katia","Eirini","Dimitris","Vassilios","Lefteris","Varnavas","Louis","Christothea","Tasoulla","Thalia","Lakis","Georgoulla","Loulla","Lazaros","Milia","Yianna","Natalia","Vera","Panikos","Annita","Vasilis","Heracles","Meropi","Patricia","Symeon","Charilaos","Irini","Herodotos","Vasos","Odysseas","Polycarpos","Natasa","Ekaterini","Iosif","Areti","Afroditi","Anastasios"}
    }
}
RandomNames.lastNames = {
    [1] = {
        [1] = {"Yılmaz","Kaya","Demir","Çelik","Şahin","Yıldız","Yıldırım","Öztürk","Aydın","Özdemir","Arslan","Doğan","Kılıç","Aslan","Çetin","Kara","Koç","Kurt","Özkan","Acar","Polat","Şimşek","Korkmaz","Özcan","Erdoğan","Çakir","Yavuz","Can","Şen","Yalçın","Güler","Aktaş","Güneş","Bozkurt","Bulut","Işık","Turan","Keskin","Avci","Ünal","Gül","Coşkun","Özer","Kaplan","Sari","Tekin","Taş","Yüksel","Köse","Ateş","Aksoy","Yiğit","Karataş","Uzun","Ceylan","Karaca","Çiftçi","Çiçek","Çoban","Çalişkan","Yaşar","Demirci","Bayram","Deniz","Çakmak","Güngör","Uçar","Erdem","Kahraman","Uysal","Genç","Çinar","Duman","Akın","Sönmez","Demirel","Ay","Kilinç","Koçak","Mutlu","Küçük","Çetinkaya","Yaman","Altun","Gündüz","Gümüş","Öz","Eren","Aydemir","Çolak","Tunç","Karakaya","Güven","Kartal","Gök","Karaman","Dönmez","Erol","Aksu","Alkan","Tosun","Özen","Türk","Balci","Sağlam","Karakuş","Cengiz","Çevik","Güzel","Karabulut","Akbaş","Keleş","Duran","Durmuş","Ince","Baş","Eroğlu","Akkaya","Akbulut","Demirtaş","Durmaz","Akgün","Yücel","Uslu","Dursun","Aydoğan","Yazici","Özçelik","Er","Çelebi","Koca","Karagöz","Ünlü","Ekinci","Karakaş","Gürbüz","Toprak","Akgül","Türkmen","Topal","Dinç","Gültekin","Dağ","Topçu","Sarıkaya","Şentürk","Vural","Zengin","Özmen","Ergün","Şeker","Gündoğdu","Bilgin","Ilhan","Bal","Gökçe","Fidan","Sezer","Güney","Albayrak","Güner","Bektaş","Akyol","Oğuz","Inan","Karadağ","Bayrak","Turgut","Orhan","Akar","Aydoğdu","Taşkın","Kalkan","Özel","Ak","Ercan","Akyüz","Ipek","Uğur","Esen","Akkuş","Günay","Bayraktar","Taşdemir","Budak","Akpınar","Açıkgöz","Aygün","Özbek","Öner","Temel","Ersoy","Ayhan","Efe","Çam","Ari","Şener","Sevinç","Çağlar","Ergin","Tuncer","Ertürk","Baran","Sert","Akdemir","Ayaz","Gür","Koyuncu","Akçay","Kaçar","Aras","Altıntaş","Akça","Başaran","Karakoç","Tan","Şengül","Gezer","Akdağ","Karadeniz","Atalay","Bakir","Altin","Çimen","Biçer","Karahan","Akman","Akdeniz","Turhan","Dündar","Gün","Oruç","Sezgin","Mert","Kandemir","Kuş","Bingöl","Usta","Bolat","Bülbül","Taşçi","Yüce","Pehlivan","Fırat","Tuna","Önal","Çakar","Metin","Dinçer","Yeşil","Savaş","Uyar","Altuntaş","Ekici","Arıkan","Atmaca","Akdoğan","Altay","Sevim","Erkan","Kutlu","Doğru","Yalçınkaya","Özkaya","Önder","Demirbaş","Öksüz","Ataş","Boz","Durak","Eser","Eker","Kuru","Oral","Varol","Demircan","Parlak","Ölmez","Gedik","Güçlü","Köksal","Akay","Adıgüzel","Türkoğlu","Göktaş","Soylu","Ertaş","Özden","Şenol","Şanli","Güleç","Ünsal","Uğurlu","Torun","Gürsoy","Bilgiç","Akinci","Ergül","Şahan","Köroğlu"}
    },
    [2] = {
        [1] = {"Georgiou","Charalambous","Ioannou","Constantinou","Christodoulou","Demetriou","Michael","Nicolaou","Andreou","Antoniou","Kyriacou","Savva","Stylianou","Christou","Panayiotou","Petrou","Christoforou","Christofi","Vassiliou","Theodorou","Loizou","Stavrou","Neophytou","Panayi","Philippou","Michaelides","Pavlou","Chrysostomou","Alexandrou","Kyprianou","Louca","Papadopoulos","Panteli","Elia","Eleftheriou","Georgiades","Constantinides","Spyrou","Efstathiou","Ioannides","Demosthenous","Anastassiou","Chrysanthou","Soteriou","Gregoriou","Savvides","Socratous","Achilleos","Kyriakides","Sophocleous","Lambrou","Evangelou","Iacovou","Costa","Aristidou","Papageorgiou","Kyriakou","Nicolaides","Xenophontos","Theocharous","Solomou","Adamou","Nikolaou","Polycarpou","Evripidou","Theophanous","Paraskeva","Efthymiou","Antoniades","Hadjigeorgiou","Avraam","Theodoulou","Cleanthous","Neocleous","Argyrou","Christodoulides","Christofides","Heracleous","Themistocleous","Lazarou","Yiangou","Athanassiou","Sofroniou","Leonidou","Gavriel","Prodromou","Michaelidou","Papadopoulou","Menelaou","Theodossiou","Demetriades","Photiou","Symeou","Aristodemou","Marcou","Herodotou","Pericleous","Loizides","Agathocleous","Mina","Zenonos","Procopiou","Polydorou","Pieri","Economou","Charalambides","Papaioannou","Varnava","Economides","Konstantinou","Petrides","Stephanou","Thoma","Anastasiou","Tryfonos","Apostolou","Papamichael","Kokkinos","Panayides","Aristotelous","Mattheou","Constantinidou","Charalampous","Zachariou","Nicola","Eliades","Aresti","Avgousti","Damianou","Charilaou","Erotokritou","Yiannakou","Georgiadou","Miltiadous","Nearchou","Ioannidou","Panagiotou","Mylonas","Pavlides","Ellinas","Stavrinou","Vasiliou","Agapiou","Agathangelou","Hadjimichael","Odysseos","Evagorou","Stylianides","Zacharia","Savvidou","Paphitis","Iacovides","Papanicolaou","Yianni","Panagi","Polyviou","Kallis","Hadjioannou","Kyriakidou","Costi","Nicolaidou","Manoli","Andronicou","Hadjikyriacou","Violaris","Vassiliades","Orphanides","Kalli","Hadjicharalambous","Mavrommatis","Pittas","Timotheou","Angeli","Neofytou","Patsalides","Iosif","Papademetriou","Tsangarides","Papakyriacou","Kalogirou","Onissiforou","Athanasiou","Dionyssiou","Protopapas","Thrassyvoulou","Papacharalambous","Koumi","Loucaides","Papapetrou","Anastassi","Afxentiou","Dimitriou","Pitsillides","Papachristoforou","Pantelides","Karaolis","Theodotou","Louka","Papaconstantinou","Antoniadou","Constanti","Pierides","Phylactou","Serghiou","Gavrielides","Onoufriou","Markou","Tsangaris","Markides","Papantoniou","Argyrides","Theodosiou","Christodoulidou","Charitou","Filippou","Frangou","Ioackim","Christofidou","Gerolemou","Hadjiyiannis","Toumazou","Demetri","Karayiannis","Poyiadjis","Psaras","Philippides","Papachristodoulou","Xenofontos","Hadjidemetriou","Droussiotis","Stavrinides","Artemiou","Loizidou","Eftychiou","Evgeniou","Sergiou","Vasileiou","Flourentzou","Kleanthous","Sofocleous","Avraamides","Komodromos","Petsas","Zachariades","Angelides","Michail","Paschali","Kakoullis","Iordanou","Papandreou","Orphanou","Theophilou","Demetriadou","Konnaris","Spanos","Anastassiades","Marinou","Ignatiou","Symeonides","Polykarpou","Hadjiloizou","Apostolides","Mylona","Andronikou","Kokkinou","Petridou","Miltiadou","Nicodemou","Theofanous","Hadjinicolaou","Hadjichristodoulou","Nikiforou","Omirou","Economidou","Macris","Payt","Nicou","Roussos","Makrides","Zavros","Sofokleous","Stylianidou","Demou","Solomonides","Kountouris","Chari","Yiannaki","Papa","Theocharides","Yiallouros","Zeniou","Leonida","Steliou","Athinodorou","Epiphaniou","Leontiou","Maratheftis","Shiakallis","Pavlidou","Andrea"}
    }
}