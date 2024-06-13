// !center 92 | frame 92 -f '/=/ ' | sed 's|^/.|//|g;s|./$|//|g'
//============================================================================================//
//                               Biblical / Indexing Constants                                //
//============================================================================================//

// !center 92 | frame 92 -f '/-/ ' | sed 's|^/.|//|g;s|./$|//|g'
//--------------------------------------------------------------------------------------------//
//                              Biblical Literature Unique ID's                               //
//--------------------------------------------------------------------------------------------//

// Book's unique ID - Full English Name to an Integer arbitrary (unique) ID dictionary
// List of Deuterocanonical / Apocripha
// From: https://www.logos.com/bible-book-abbreviations
#let bUID = (
  // 10.00 - Pentateuch
  "Genesis":                    1001,
  "Exodus":                     1002,
  "Leviticus":                  1003,
  "Numbers":                    1004,
  "Deuteronomy":                1005,
  // 11.00 - Historical
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
  // 13.00 - Prophetic
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
  // 14.00 - Gospel
  "Matthew":                    1401,
  "Mark":                       1402,
  "Luke":                       1403,
  "John":                       1404,
  // 15.00 - NT Historical
  "Acts":                       1501,
  // 16.00 - Paul's
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
  // 17.00 - Universal
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
  // **.00 - Canonic LXX Aliases
  "Regnorum I":                 1104, // = 1 Samuel
  "Regnorum II":                1105, // = 2 Samuel
  "Regnorum III":               1106, // = 1 Kings
  "Regnorum IV":                1107, // = 2 Kings
  "2 Esdras":                   1110, // = Ezra + Nehemiah
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
  // 51.00 - Other OT Apocripha
  "Prayer of Manasseh":         5101,
)

//--------------------------------------------------------------------------------------------//
//                                   Book Sorting Resources                                   //
//--------------------------------------------------------------------------------------------//

// Following the available information in the TOB - Traduction OEcuménique - Five (5) OT cannons
// are supported, i.e., the Hebrew, the Protestant, the Catholic, the Orthodox, and the TOB. The
// NT cannon is the same in all of these traditions.

// Book partial orderings
#let pOrd = (
  "Law": // The ordering of the law books is the same in all 5 canons
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
  "OT-Catholic-Historical":
    (1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 3103, 3102, 1112, 3108,
    3104, 3105,),
  "OT-Catholic-Poetic":
    (1201, 1202, 1203, 1204, 1205, 3203, 3204,),
  "OT-Catholic-Major-Prophets":
    (1301, 1302, 1303, 3206, 1304, 1305, 3208, 3209,),
  // THE NEW TESTAMENT - same for all 5 considered traditions
  "Gospels":
    (1401, 1402, 1403, 1404,),
  "Acts":
    (1405,),
  "Paul":
    (1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613,),
  "Universal":
    (1701, 1702, 1703, 1704, 1705, 1706, 1707,),
  "Revelation":
    (1801,),
)

#pOrd.insert("Neviim",
  (1101, 1102, 1104, 1105, 1106, 1107, 1301, 1302, 1304) +
  pOrd.at("Min-Prophets"))

#pOrd.insert("Ketuvim",
  (1202, 1201, 1203, 1103, 1205, 1204, 1303, 1112, 1305, 1110, 1111, 1108, 1109,))


// Book sorting schemes
#let bSrt = (
  "code": (
    // Pentateuch
    1001, 1002, 1003, 1004, 1005,
    // Historical
    1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112,
    // Sapiential
    1201, 1202, 1203, 1204, 1205,
    // Prophetic
    1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308, 1309, 1310, 1311, 1312, 1313, 1314, 1315,
    1316, 1317,
    // Gospel
    1401, 1402, 1403, 1404,
    // NT Historical
    1501,
    // Paul's
    1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613,
    // Universal
    1701, 1702, 1703, 1704, 1705, 1706, 1707,
    // NT Prophetic
    1801,
    // LXX Deutero (vol.1)
    3101, 3102, 3103, 3104, 3105, 3106, 3107, 3108,
    // LXX Deutero (vol.2)
    3201, 3202, 3203, 3204, 3205, 3206, 3207, 3208, 3209, 3210,
    // Other OT Apocripha
    5101,
  ),
  // From: https://mereorthodoxy.com/the-case-for-rearranging-the-old-testament-books
  "jewish-tanakh": (
    // Ta
    1001, 1002, 1003, 1004, 1005,
    // Na
    1101, 1102, 1104, 1105, 1106, 1107, 1301, 1302, 1304, 1306, 1307, 1308, 1309, 1310, 1311,
    1312, 1313, 1314, 1315, 1316, 1317,
    // Kh
    1202, 1201, 1203, 1103, 1205, 1204, 1303, 1112, 1305, 1110, 1111, 1108, 1109,
  )
  "jewish-bible": (
    // Ta
    1001, 1002, 1003, 1004, 1005,
    // Na
    1101, 1102, 1104, 1105, 1106, 1107, 1301, 1302, 1304, 1306, 1307, 1308, 1309, 1310, 1311,
    1312, 1313, 1314, 1315, 1316, 1317,
    // Kh
    1202, 1201, 1203, 1103, 1205, 1204, 1303, 1112, 1305, 1110, 1111, 1108, 1109,
  )
)


// Biblical Constants
#let bBooks = (
  // Pentateuch - 100
  Gn:  (sort: 101, ch:  50, name: (en: "Genesis",          pt: "Gênesis"             ),),
  Ex:  (sort: 102, ch:  40, name: (en: "Exodus",           pt: "Êxodo"               ),),
  Lv:  (sort: 103, ch:  27, name: (en: "Leviticus",        pt: "Levítico"            ),),
  Nm:  (sort: 104, ch:  36, name: (en: "Numbers",          pt: "Números"             ),),
  Dt:  (sort: 105, ch:  34, name: (en: "Deuteronomy",      pt: "Deuteronômio"        ),),
  // Historical - 200
  Js:  (sort: 201, ch:  24, name: (en: "Joshua",           pt: "Josué"               ),),
  Jz:  (sort: 202, ch:  21, name: (en: "Judges",           pt: "Juízes"              ),),
  Rt:  (sort: 203, ch:   4, name: (en: "Ruth",             pt: "Rute"                ),),
  Sm1: (sort: 204, ch:  31, name: (en: "1 Samuel",         pt: "1 Samuel"            ),),
  Sm2: (sort: 205, ch:  24, name: (en: "2 Samuel",         pt: "2 Samuel"            ),),
  Rs1: (sort: 206, ch:  22, name: (en: "1 Kings",          pt: "1 Reis"              ),),
  Rs2: (sort: 207, ch:  25, name: (en: "2 Kings",          pt: "2 Reis"              ),),
  Cr1: (sort: 208, ch:  29, name: (en: "1 Chronicles",     pt: "1 Crônicas"          ),),
  Cr2: (sort: 209, ch:  36, name: (en: "2 Chronicles",     pt: "2 Crônicas"          ),),
  Ed:  (sort: 210, ch:  10, name: (en: "Ezra",             pt: "Esdras"              ),),
  Ne:  (sort: 211, ch:  13, name: (en: "Nehemiah",         pt: "Neemias"             ),),
  Et:  (sort: 212, ch:  10, name: (en: "Esther",           pt: "Ester"               ),),
  // Sapiential - 300
  Jó:  (sort: 301, ch:  42, name: (en: "Job",              pt: "Jó"                  ),),
  Sl:  (sort: 302, ch: 150, name: (en: "Psalms",           pt: "Salmos"              ),),
  Pv:  (sort: 303, ch:  31, name: (en: "Proverbs",         pt: "Provérbios"          ),),
  Ec:  (sort: 304, ch:  12, name: (en: "Ecclesiastes",     pt: "Eclesiastes"         ),),
  Ct:  (sort: 305, ch:   8, name: (en: "Song of Solomon",  pt: "Cântico"             ),),
  // Prophetical - 400
  Is:  (sort: 401, ch:  66, name: (en: "Isaiah",           pt: "Isaías"              ),),
  Jr:  (sort: 402, ch:  52, name: (en: "Jeremiah",         pt: "Jeremias"            ),),
  Lm:  (sort: 403, ch:   5, name: (en: "Lamentations",     pt: "Lamentações"         ),),
  Ez:  (sort: 404, ch:  48, name: (en: "Ezekiel",          pt: "Ezequiel"            ),),
  Dn:  (sort: 405, ch:  12, name: (en: "Daniel",           pt: "Daniel"              ),),
  Os:  (sort: 406, ch:  14, name: (en: "Hosea",            pt: "Oséias"              ),),
  Jl:  (sort: 407, ch:   3, name: (en: "Joel",             pt: "Joel"                ),),
  Am:  (sort: 408, ch:   9, name: (en: "Amos",             pt: "Amós"                ),),
  Ob:  (sort: 409, ch:   1, name: (en: "Obadiah",          pt: "Obadias"             ),),
  Jn:  (sort: 410, ch:   4, name: (en: "Jonah",            pt: "Jonas"               ),),
  Mq:  (sort: 411, ch:   7, name: (en: "Micah",            pt: "Miquéias"            ),),
  Na:  (sort: 412, ch:   3, name: (en: "Nahum",            pt: "Naum"                ),),
  Hc:  (sort: 413, ch:   3, name: (en: "Habakkuk",         pt: "Habacuque"           ),),
  Sf:  (sort: 414, ch:   3, name: (en: "Zephaniah",        pt: "Sofonias"            ),),
  Ag:  (sort: 415, ch:   2, name: (en: "Haggai",           pt: "Ageu"                ),),
  Zc:  (sort: 416, ch:  14, name: (en: "Zechariah",        pt: "Zacarias"            ),),
  Ml:  (sort: 417, ch:   4, name: (en: "Malachi",          pt: "Malaquias"           ),),
  // Gospels - 500
  Mt:  (sort: 501, ch:  28, name: (en: "Matthew",          pt: "Mateus"              ),),
  Mc:  (sort: 502, ch:  16, name: (en: "Mark",             pt: "Marcos"              ),),
  Lc:  (sort: 503, ch:  24, name: (en: "Luke",             pt: "Lucas"               ),),
  Jo:  (sort: 504, ch:  24, name: (en: "John",             pt: "João"                ),),
  // Historical - 600
  At:  (sort: 601, ch:  28, name: (en: "Acts",             pt: "Atos"                ),),
  // Paul's - 700
  Rm:  (sort: 701, ch:  16, name: (en: "Romans",           pt: "Romanos"             ),),
  Co1: (sort: 702, ch:  16, name: (en: "1 Corinthians",    pt: "1 Coríntios"         ),),
  Co2: (sort: 703, ch:  13, name: (en: "2 Corinthians",    pt: "2 Coríntios"         ),),
  Gl:  (sort: 704, ch:   6, name: (en: "Galatians",        pt: "Gálatas"             ),),
  Ef:  (sort: 705, ch:   6, name: (en: "Ephesians",        pt: "Efésios"             ),),
  Fp:  (sort: 706, ch:   4, name: (en: "Phillipians",      pt: "Filipenses"          ),),
  Cl:  (sort: 707, ch:   4, name: (en: "Colossians",       pt: "Colossenses"         ),),
  Ts1: (sort: 708, ch:   5, name: (en: "1 Thessalonians",  pt: "1 Tessalonicenses"   ),),
  Ts2: (sort: 709, ch:   3, name: (en: "2 Thessalonians",  pt: "2 Tessalonicenses"   ),),
  Tm1: (sort: 710, ch:   6, name: (en: "1 Timothy",        pt: "1 Timóteo"           ),),
  Tm2: (sort: 711, ch:   4, name: (en: "2 Timothy",        pt: "2 Timóteo"           ),),
  Tt:  (sort: 712, ch:   3, name: (en: "Titus",            pt: "Tito"                ),),
  Fm:  (sort: 712, ch:   1, name: (en: "Philemon",         pt: "Filemon"             ),),
  // Universals - 800
  Hb:  (sort: 801, ch:  13, name: (en: "Hebrews",          pt: "Hebreus"             ),),
  Tg:  (sort: 802, ch:   5, name: (en: "James",            pt: "Tiago"               ),),
  Pe1: (sort: 803, ch:   5, name: (en: "1 Peter",          pt: "1 Pedro"             ),),
  Pe2: (sort: 804, ch:   3, name: (en: "2 Peter",          pt: "2 Pedro"             ),),
  Jo1: (sort: 805, ch:   5, name: (en: "1 John",           pt: "1 João"              ),),
  Jo2: (sort: 806, ch:   1, name: (en: "2 John",           pt: "2 João"              ),),
  Jo3: (sort: 807, ch:   1, name: (en: "3 John",           pt: "3 João"              ),),
  Jd:  (sort: 808, ch:   1, name: (en: "Jude",             pt: "Judas"               ),),
  // Prophetic - 900
  Re:  (sort: 901, ch:  22, name: (en: "Revelation",       pt: "Apocalipse"          ),),
)



