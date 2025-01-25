//============================================================================================//
//                               Biblical / Indexing Constants                                //
//============================================================================================//


//--------------------------------------------------------------------------------------------//
//                              Biblical Literature Unique ID's                               //
//--------------------------------------------------------------------------------------------//

// Book's unique ID dictionary:
// "full-english-name": unique integer ID
#let bUID = (
  // 10.00 - Pentateuch
  "Genesis":                    1001,
  "Exodus":                     1002,
  "Leviticus":                  1003,
  "Numbers":                    1004,
  "Deuteronomy":                1005,
  // 11.00 - OT Historical
  "Joshua":                     1101,
  "Judges":                     1102,
  "Ruth":                       1103,
  "1 Samuel":                   1104,
  "2 Samuel":                   1105,
  "1 Kings":                    1106,
  "2 Kings":                    1107,
  "1 Chronicles":               1108,
  "2 Chronicles":               1109,
  "Ezra":                       1110,
  "Nehemiah":                   1111,
  "Esther":                     1112,
  // 12.00 - Sapiential
  "Job":                        1201,
  "Psalms":                     1202,
  "Proverbs":                   1203,
  "Ecclesiastes":               1204,
  "Song of Solomon":            1205,
  // 13.00 - OT Prophetic
  "Isaiah":                     1301,
  "Jeremiah":                   1302,
  "Lamentations":               1303,
  "Ezekiel":                    1304,
  "Daniel":                     1305,
  "Hosea":                      1306,
  "Joel":                       1307,
  "Amos":                       1308,
  "Obadiah":                    1309,
  "Jonah":                      1310,
  "Micah":                      1311,
  "Nahum":                      1312,
  "Habakkuk":                   1313,
  "Zephaniah":                  1314,
  "Haggai":                     1315,
  "Zechariah":                  1316,
  "Malachi":                    1317,
  // 14.00 - NT Gospels
  "Matthew":                    1401,
  "Mark":                       1402,
  "Luke":                       1403,
  "John":                       1404,
  // 15.00 - NT Historical
  "Acts":                       1501,
  // 16.00 - NT Paul's letters
  "Romans":                     1601,
  "1 Corinthians":              1602,
  "2 Corinthians":              1603,
  "Galatians":                  1604,
  "Ephesians":                  1605,
  "Philippians":                1606,
  "Colossians":                 1607,
  "1 Thessalonians":            1608,
  "2 Thessalonians":            1609,
  "1 Timothy":                  1610,
  "2 Timothy":                  1611,
  "Titus":                      1612,
  "Philemon":                   1613,
  // 17.00 - NT Universal letters
  "Hebrews":                    1700,
  "James":                      1701,
  "1 Peter":                    1702,
  "2 Peter":                    1703,
  "1 John":                     1704,
  "2 John":                     1705,
  "3 John":                     1706,
  "Jude":                       1707,
  // 18.00 - NT Prophetic
  "Revelation":                 1801,
  // 31.00 - LXX (vol.1) Deutero
  "1 Esdras":                   3101,
  "Judith":                     3102,
  "Tobit":                      3103,
  "1 Maccabees":                3104,
  "2 Maccabees":                3105,
  "3 Maccabees":                3106,
  "4 Maccabees":                3107,
  "Additions to Esther":        3108,
  // 32.00 - LXX (vol.2) Deutero
  "Additional Psalm":           3201,
  "Ode":                        3202,
  "Wisdom of Solomon":          3203,
  "Sirach":                     3204,
  "Psalms of Solomon":          3205,
  "Baruch":                     3206,
  "Letter of Jeremiah":         3207,
  "Susanna":                    3208,
  "Bel and the Dragon":         3209,
  "Song of Three Youths":       3210,
  // 51.00 - Other OT Apocripha (not in the LXX)
  "3 Esdras":                   5101,
  "4 Esdras":                   5102,
  "Prayer of Manasseh":         5103,
)

// Create the reverse dictionary
#let iBoo = (:)
#for KV in bUID.pairs() {
  iBoo.insert(str(KV.at(1)), KV.at(0))
}


//--------------------------------------------------------------------------------------------//
//                                   Book Sorting Resources                                   //
//--------------------------------------------------------------------------------------------//

// Following the available information in the TOB - Traduction OEcuménique - Five (5) OT cannons
// are supported, i.e., the Hebrew, the Protestant, the Catholic, the Orthodox, and the TOB. The
// NT cannon is the same in all of these traditions.

// Book partial orderings
#let pOrd = (
  // The ordering of the Law (Torah/Pentateuc) books is the same in all 5 canons
  "Law":
    (1001, 1002, 1003, 1004, 1005,),
  // PROTESTANT OT CANON
  "OT-Protestant-Historical":
    (1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112,),
  "OT-Protestant-Sapiential":
    (1201, 1202, 1203, 1204, 1205,),
  "OT-Protestant-Major-Prophets":
    (1301, 1302, 1303, 1304, 1305,),
  "OT-Protestant-Minor-Prophets":
    (1306, 1307, 1308, 1309, 1310, 1311, 1312, 1313, 1314, 1315, 1316, 1317,),
  // CATHOLIC OT CANON
  "OT-Catholic-Historical":
    (1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 3103, 3102, 1112, 3108,
    3104, 3105,),
  "OT-Catholic-Poetic":
    (1201, 1202, 1203, 1204, 1205, 3203, 3204,),
  "OT-Catholic-Major-Prophets":
    (1301, 1302, 1303, 3206, 1304, 1305, 3208, 3209,),
  // ORTHODOX OT CANON
  "OT-Orthodox-Historical":
    (1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 5101, 1110, 1111, 3103, 3102, 1112, 3108,
    3104, 3105, 3106,),
  "OT-Orthodox-Poetic":
    (1202, 1201, 1203, 1204, 1205, 3203, 3204,),
  "OT-Orthodox-Major-Prophets":
    (1301, 1302, 3206, 1303, 3207, 1304, 1305, 3208, 3209,),
  "OT-Orthodox-Minor-Prophets":
    (1306, 1308, 1311, 1307, 1309, 1310, 1312, 1313, 1314, 1315, 1316, 1317, 5102, 3107, 5103,),
  // TOB OT CANON
  "OT-TOB-Deuterocanonical":
    (3210, 3208, 3209, 3108, 3102, 3103, 3104, 3105, 3203, 3204, 3206, 3207, 5101, 5102, 3106,
    3107, 5103, 3201,),
  // THE NEW TESTAMENT - same for all 5 considered traditions
  "Gospels":
    (1401, 1402, 1403, 1404,),
  "Acts":
    (1501,),
  "Paul-Letters":
    (1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613,),
  "Universal-Letters":
    (1701, 1702, 1703, 1704, 1705, 1706, 1707,),
  "Revelation":
    (1801,),
)

// HEBREW OT CANON
#pOrd.insert("Neviim",
  (1101, 1102, 1104, 1105, 1106, 1107, 1301, 1302, 1304) +
  pOrd.at("OT-Protestant-Minor-Prophets"))

#pOrd.insert("Ketuvim",
  (1202, 1201, 1203, 1103, 1205, 1204, 1303, 1112, 1305, 1110, 1111, 1108, 1109,))

// NEW TESTAMENT
#pOrd.insert("New-Testament",
  pOrd.at("Gospels") +
  pOrd.at("Acts") +
  pOrd.at("Paul-Letters") +
  pOrd.at("Universal-Letters") +
  pOrd.at("Revelation"))


//--------------------------------------------------------------------------------------------//
//                                    Book Sorting Schemes                                    //
//--------------------------------------------------------------------------------------------//

// Book sorting schemes
#let bSort = (:)


//····························································································//
//                                            code                                            //
//····························································································//

// "code" scheme
#bSort.insert("code", bUID.values().sorted())


//····························································································//
//                                            LXX                                             //
//····························································································//

// "LXX" scheme
#let tmpLXX = ()
#for val in bSort.at("code") {
  if (val < 1400) or ((val > 3000) and (val < 5000)) { tmpLXX.push(val) }
}
#bSort.insert("LXX", tmpLXX)


//····························································································//
//                                        Greek-Bible                                         //
//····························································································//

// "Greek-Bible"
#bSort.insert("Greek-Bible", (
  bSort.at("LXX") +
  pOrd.at("New-Testament")
).flatten())


//····························································································//
//                                Hebrew-Tanakh, Hebrew-Bible                                 //
//····························································································//

// "Hebrew-Tanakh"
#bSort.insert("Hebrew-Tanakh", (
  pOrd.at("Law") +
  pOrd.at("Neviim") +
  pOrd.at("Ketuvim")
).flatten())

// "Hebrew-Bible"
#bSort.insert("Hebrew-Bible", (
  bSort.at("Hebrew-Tanakh") +
  pOrd.at("New-Testament")
).flatten())


//····························································································//
//                                      Protestant-Bible                                      //
//····························································································//

// "Protestant-Bible"
#bSort.insert("Protestant-Bible", (
  pOrd.at("Law") +
  pOrd.at("OT-Protestant-Historical") +
  pOrd.at("OT-Protestant-Sapiential") +
  pOrd.at("OT-Protestant-Major-Prophets") +
  pOrd.at("OT-Protestant-Minor-Prophets") +
  pOrd.at("New-Testament")
).flatten())


//····························································································//
//                                       Catholic-Bible                                       //
//····························································································//

// "Catholic-Bible"
#bSort.insert("Catholic-Bible", (
  pOrd.at("Law") +
  pOrd.at("OT-Catholic-Historical") +
  pOrd.at("OT-Catholic-Poetic") +
  pOrd.at("OT-Catholic-Major-Prophets") +
  pOrd.at("OT-Protestant-Minor-Prophets") +
  pOrd.at("New-Testament")
).flatten())


//····························································································//
//                                       Orthodox-Bible                                       //
//····························································································//

// "Orthodox-Bible"
#bSort.insert("Orthodox-Bible", (
  pOrd.at("Law") +
  pOrd.at("OT-Orthodox-Historical") +
  pOrd.at("OT-Orthodox-Poetic") +
  pOrd.at("OT-Orthodox-Major-Prophets") +
  pOrd.at("OT-Orthodox-Minor-Prophets") +
  pOrd.at("New-Testament")
).flatten())


//····························································································//
//                                      Oecumenic-Bible                                       //
//····························································································//

// "Oecumenic-Bible"
#bSort.insert("Oecumenic-Bible", (
  bSort.at("Hebrew-Tanakh") +
  pOrd.at("OT-TOB-Deuterocanonical") +
  pOrd.at("New-Testament")
).flatten())


