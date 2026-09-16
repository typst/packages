#let lang-dict = (
  // 10.00 - Pentateuch
  "1001": ("GEN", "Genesis"),
  "1002": ("EXO", "Exodus"),
  "1003": ("LEV", "Leviticus"),
  "1004": ("NUM", "Numbers"),
  "1005": ("DEU", "Deuteronomy"),

  // 11.00 - OT Historical
  "1101": ("JOS", "Joshua"),
  "1102": ("JDG", "Judges"),
  "1103": ("RUT", "Ruth"),
  "1104": ("1SA", "1 Samuel"),
  "1105": ("2SA", "2 Samuel"),
  "1106": ("1KI", "1 Kings"),
  "1107": ("2KI", "2 Kings"),
  "1108": ("1CH", "1 Chronicles"),
  "1109": ("2CH", "2 Chronicles"),
  "1110": ("EZR", "Ezra"),
  "1111": ("NEH", "Nehemiah"),
  "1112": ("EST", "Esther (Hebrew)"),

  // 12.00 - Sapiential
  "1201": ("JOB", "Job"),
  "1202": ("PSA", "Psalms"),
  "1203": ("PRO", "Proverbs"),
  "1204": ("ECC", "Ecclesiastes"),
  "1205": ("SNG", "Song of Songs"),

  // 13.00 - OT Prophetic
  "1301": ("ISA", "Isaiah"),
  "1302": ("JER", "Jeremiah"),
  "1303": ("LAM", "Lamentations"),
  "1304": ("EZK", "Ezekiel"),
  "1305": ("DAN", "Daniel (Hebrew)"),
  "1306": ("HOS", "Hosea"),
  "1307": ("JOL", "Joel"),
  "1308": ("AMO", "Amos"),
  "1309": ("OBA", "Obadiah"),
  "1310": ("JON", "Jonah"),
  "1311": ("MIC", "Micah"),
  "1312": ("NAM", "Nahum"),
  "1313": ("HAB", "Habakkuk"),
  "1314": ("ZEP", "Zephaniah"),
  "1315": ("HAG", "Haggai"),
  "1316": ("ZEC", "Zechariah"),
  "1317": ("MAL", "Malachi"),

  // 14.00 - NT Gospels
  "1401": ("MAT", "Matthew"),
  "1402": ("MRK", "Mark"),
  "1403": ("LUK", "Luke"),
  "1404": ("JHN", "John"),

  // 15.00 - NT Historical
  "1501": ("ACT", "Acts"),

  // 16.00 - NT Paul's letters
  "1601": ("ROM", "Romans"),
  "1602": ("1CO", "1 Corinthians"),
  "1603": ("2CO", "2 Corinthians"),
  "1604": ("GAL", "Galatians"),
  "1605": ("EPH", "Ephesians"),
  "1606": ("PHP", "Philippians"),
  "1607": ("COL", "Colossians"),
  "1608": ("1TH", "1 Thessalonians"),
  "1609": ("2TH", "2 Thessalonians"),
  "1610": ("1TI", "1 Timothy"),
  "1611": ("2TI", "2 Timothy"),
  "1612": ("TIT", "Titus"),
  "1613": ("PHM", "Philemon"),

  // 17.00 - NT Universal letters
  "1700": ("HEB", "Hebrews"),
  "1701": ("JAS", "James"),
  "1702": ("1PE", "1 Peter"),
  "1703": ("2PE", "2 Peter"),
  "1704": ("1JN", "1 John"),
  "1705": ("2JN", "2 John"),
  "1706": ("3JN", "3 John"),
  "1707": ("JUD", "Jude"),

  //18.00 - NT Prophetic
  "1801": ("REV", "Revelation"),

  // 31.00 - LXX (vol.1) Deutero
  "3101": ("1ES", "1 Esdras (Greek)"),
  "3102": ("JDT", "Judith"),
  "3103": ("TOB", "Tobit"),
  "3104": ("1MA", "1 Maccabees"),
  "3105": ("2MA", "2 Maccabees"),
  "3106": ("3MA", "3 Maccabees"),
  "3107": ("4MA", "4 Maccabees"),
  "3108": ("ESG", "Esther (Greek)"),

  // 32.00 - LXX (vol.2) Deutero
  "3201": ("PS2", "Psalm 151"),
  "3202": ("ODA", "Odes"),
  "3203": ("WIS", "Wisdom of Solomon"),
  "3204": ("SIR", "Sirach (Ecclesiasticus)"),
  "3205": ("PSS", "Psalms of Solomon"),
  "3206": ("BAR", "Baruch"),
  "3207": ("LJE", "Letter of Jeremiah"),
  "3208": ("SUS", "Susanna"),
  "3209": ("BEL", "Bel and the Dragon"),
  "3210": ("S3Y", "Song of 3 Young Men"),

  // 51.00 - Other OT Apocripha (not in the LXX)
  "5101": ("3ES", "3 Esdras"),
  "5102": ("4ES", "4 Esdras"),
  "5103": ("MAN", "Prayer of Manasseh"),

  // 71.00 - Deuterocanon (extended, from Unified Scripture XML)
  "7101": ("2ES", "2 Esdras (Latin)"),
  "7102": ("EZA", "Apocalypse of Ezra"),
  "7103": ("5EZ", "5 Ezra"),
  "7104": ("6EZ", "6 Ezra"),
  "7105": ("DAG", "Daniel (Greek)"),
  "7106": ("PS3", "Psalms 152–155"),
  "7107": ("2BA", "2 Baruch (Apocalypse)"),
  "7108": ("LBA", "Letter of Baruch"),
  "7109": ("JUB", "Jubilees"),
  "7110": ("ENO", "Enoch"),
  "7111": ("1MQ", "1 Meqabyan"),
  "7112": ("2MQ", "2 Meqabyan"),
  "7113": ("3MQ", "3 Meqabyan"),
  "7114": ("REP", "Reproof"),
  "7115": ("4BA", "4 Baruch"),
  "7116": ("LAO", "Laodiceans"),

  // 99.00 - Non scripture (Unified Scripture XML)
  "9901": ("XXA", "Extra A"),
  "9902": ("XXB", "Extra B"),
  "9903": ("XXC", "Extra C"),
  "9904": ("XXD", "Extra D"),
  "9905": ("XXE", "Extra E"),
  "9906": ("XXF", "Extra F"),
  "9907": ("XXG", "Extra G"),
  "9908": ("FRT", "Front Matter"),
  "9909": ("BAK", "Back Matter"),
  "9910": ("OTH", "Other Matter"),
  "9911": ("INT", "Introduction"),
  "9912": ("CNC", "Concordance"),
  "9913": ("GLO", "Glossary"),
  "9914": ("TDX", "Topical Index"),
  "9915": ("NDX", "Names Index"),
)

