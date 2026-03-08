#let get-data(code) = {
  import "aliases.typ"
  if 0x0 <= code and code <= 0x7F {
    import "block-0000.typ"
    (("Basic Latin", 0x0000, 0x80), block-0000.data.at(code - 0x0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x80 <= code and code <= 0xFF {
    import "block-0080.typ"
    (("Latin-1 Supplement", 0x0080, 0x80), block-0080.data.at(code - 0x80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x100 <= code and code <= 0x17F {
    import "block-0100.typ"
    (("Latin Extended-A", 0x0100, 0x80), block-0100.data.at(code - 0x100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x180 <= code and code <= 0x24F {
    import "block-0180.typ"
    (("Latin Extended-B", 0x0180, 0xD0), block-0180.data.at(code - 0x180, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x250 <= code and code <= 0x2AF {
    import "block-0250.typ"
    (("IPA Extensions", 0x0250, 0x60), block-0250.data.at(code - 0x250, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2B0 <= code and code <= 0x2FF {
    import "block-02B0.typ"
    (("Spacing Modifier Letters", 0x02B0, 0x50), block-02B0.data.at(code - 0x2B0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x300 <= code and code <= 0x36F {
    import "block-0300.typ"
    (("Combining Diacritical Marks", 0x0300, 0x70), block-0300.data.at(code - 0x300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x370 <= code and code <= 0x3FF {
    import "block-0370.typ"
    (("Greek and Coptic", 0x0370, 0x90), block-0370.data.at(code - 0x370, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x400 <= code and code <= 0x4FF {
    import "block-0400.typ"
    (("Cyrillic", 0x0400, 0x100), block-0400.data.at(code - 0x400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x500 <= code and code <= 0x52F {
    import "block-0500.typ"
    (("Cyrillic Supplement", 0x0500, 0x30), block-0500.data.at(code - 0x500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x530 <= code and code <= 0x58F {
    import "block-0530.typ"
    (("Armenian", 0x0530, 0x60), block-0530.data.at(code - 0x530, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x590 <= code and code <= 0x5FF {
    import "block-0590.typ"
    (("Hebrew", 0x0590, 0x70), block-0590.data.at(code - 0x590, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x600 <= code and code <= 0x6FF {
    import "block-0600.typ"
    (("Arabic", 0x0600, 0x100), block-0600.data.at(code - 0x600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x700 <= code and code <= 0x74F {
    import "block-0700.typ"
    (("Syriac", 0x0700, 0x50), block-0700.data.at(code - 0x700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x750 <= code and code <= 0x77F {
    import "block-0750.typ"
    (("Arabic Supplement", 0x0750, 0x30), block-0750.data.at(code - 0x750, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x780 <= code and code <= 0x7BF {
    import "block-0780.typ"
    (("Thaana", 0x0780, 0x40), block-0780.data.at(code - 0x780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x7C0 <= code and code <= 0x7FF {
    import "block-07C0.typ"
    (("NKo", 0x07C0, 0x40), block-07C0.data.at(code - 0x7C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x800 <= code and code <= 0x83F {
    import "block-0800.typ"
    (("Samaritan", 0x0800, 0x40), block-0800.data.at(code - 0x800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x840 <= code and code <= 0x85F {
    import "block-0840.typ"
    (("Mandaic", 0x0840, 0x20), block-0840.data.at(code - 0x840, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x860 <= code and code <= 0x86F {
    import "block-0860.typ"
    (("Syriac Supplement", 0x0860, 0x10), block-0860.data.at(code - 0x860, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x870 <= code and code <= 0x89F {
    import "block-0870.typ"
    (("Arabic Extended-B", 0x0870, 0x30), block-0870.data.at(code - 0x870, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x8A0 <= code and code <= 0x8FF {
    import "block-08A0.typ"
    (("Arabic Extended-A", 0x08A0, 0x60), block-08A0.data.at(code - 0x8A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x900 <= code and code <= 0x97F {
    import "block-0900.typ"
    (("Devanagari", 0x0900, 0x80), block-0900.data.at(code - 0x900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x980 <= code and code <= 0x9FF {
    import "block-0980.typ"
    (("Bengali", 0x0980, 0x80), block-0980.data.at(code - 0x980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA00 <= code and code <= 0xA7F {
    import "block-0A00.typ"
    (("Gurmukhi", 0x0A00, 0x80), block-0A00.data.at(code - 0xA00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA80 <= code and code <= 0xAFF {
    import "block-0A80.typ"
    (("Gujarati", 0x0A80, 0x80), block-0A80.data.at(code - 0xA80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xB00 <= code and code <= 0xB7F {
    import "block-0B00.typ"
    (("Oriya", 0x0B00, 0x80), block-0B00.data.at(code - 0xB00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xB80 <= code and code <= 0xBFF {
    import "block-0B80.typ"
    (("Tamil", 0x0B80, 0x80), block-0B80.data.at(code - 0xB80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xC00 <= code and code <= 0xC7F {
    import "block-0C00.typ"
    (("Telugu", 0x0C00, 0x80), block-0C00.data.at(code - 0xC00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xC80 <= code and code <= 0xCFF {
    import "block-0C80.typ"
    (("Kannada", 0x0C80, 0x80), block-0C80.data.at(code - 0xC80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xD00 <= code and code <= 0xD7F {
    import "block-0D00.typ"
    (("Malayalam", 0x0D00, 0x80), block-0D00.data.at(code - 0xD00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xD80 <= code and code <= 0xDFF {
    import "block-0D80.typ"
    (("Sinhala", 0x0D80, 0x80), block-0D80.data.at(code - 0xD80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xE00 <= code and code <= 0xE7F {
    import "block-0E00.typ"
    (("Thai", 0x0E00, 0x80), block-0E00.data.at(code - 0xE00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xE80 <= code and code <= 0xEFF {
    import "block-0E80.typ"
    (("Lao", 0x0E80, 0x80), block-0E80.data.at(code - 0xE80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xF00 <= code and code <= 0xFFF {
    import "block-0F00.typ"
    (("Tibetan", 0x0F00, 0x100), block-0F00.data.at(code - 0xF00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1000 <= code and code <= 0x109F {
    import "block-1000.typ"
    (("Myanmar", 0x1000, 0xA0), block-1000.data.at(code - 0x1000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10A0 <= code and code <= 0x10FF {
    import "block-10A0.typ"
    (("Georgian", 0x10A0, 0x60), block-10A0.data.at(code - 0x10A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1100 <= code and code <= 0x11FF {
    import "block-1100.typ"
    (("Hangul Jamo", 0x1100, 0x100), block-1100.data.at(code - 0x1100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1200 <= code and code <= 0x137F {
    import "block-1200.typ"
    (("Ethiopic", 0x1200, 0x180), block-1200.data.at(code - 0x1200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1380 <= code and code <= 0x139F {
    import "block-1380.typ"
    (("Ethiopic Supplement", 0x1380, 0x20), block-1380.data.at(code - 0x1380, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13A0 <= code and code <= 0x13FF {
    import "block-13A0.typ"
    (("Cherokee", 0x13A0, 0x60), block-13A0.data.at(code - 0x13A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1400 <= code and code <= 0x167F {
    import "block-1400.typ"
    (("Unified Canadian Aboriginal Syllabics", 0x1400, 0x280), block-1400.data.at(code - 0x1400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1680 <= code and code <= 0x169F {
    import "block-1680.typ"
    (("Ogham", 0x1680, 0x20), block-1680.data.at(code - 0x1680, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16A0 <= code and code <= 0x16FF {
    import "block-16A0.typ"
    (("Runic", 0x16A0, 0x60), block-16A0.data.at(code - 0x16A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1700 <= code and code <= 0x171F {
    import "block-1700.typ"
    (("Tagalog", 0x1700, 0x20), block-1700.data.at(code - 0x1700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1720 <= code and code <= 0x173F {
    import "block-1720.typ"
    (("Hanunoo", 0x1720, 0x20), block-1720.data.at(code - 0x1720, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1740 <= code and code <= 0x175F {
    import "block-1740.typ"
    (("Buhid", 0x1740, 0x20), block-1740.data.at(code - 0x1740, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1760 <= code and code <= 0x177F {
    import "block-1760.typ"
    (("Tagbanwa", 0x1760, 0x20), block-1760.data.at(code - 0x1760, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1780 <= code and code <= 0x17FF {
    import "block-1780.typ"
    (("Khmer", 0x1780, 0x80), block-1780.data.at(code - 0x1780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1800 <= code and code <= 0x18AF {
    import "block-1800.typ"
    (("Mongolian", 0x1800, 0xB0), block-1800.data.at(code - 0x1800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18B0 <= code and code <= 0x18FF {
    import "block-18B0.typ"
    (("Unified Canadian Aboriginal Syllabics Extended", 0x18B0, 0x50), block-18B0.data.at(code - 0x18B0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1900 <= code and code <= 0x194F {
    import "block-1900.typ"
    (("Limbu", 0x1900, 0x50), block-1900.data.at(code - 0x1900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1950 <= code and code <= 0x197F {
    import "block-1950.typ"
    (("Tai Le", 0x1950, 0x30), block-1950.data.at(code - 0x1950, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1980 <= code and code <= 0x19DF {
    import "block-1980.typ"
    (("New Tai Lue", 0x1980, 0x60), block-1980.data.at(code - 0x1980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x19E0 <= code and code <= 0x19FF {
    import "block-19E0.typ"
    (("Khmer Symbols", 0x19E0, 0x20), block-19E0.data.at(code - 0x19E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1A00 <= code and code <= 0x1A1F {
    import "block-1A00.typ"
    (("Buginese", 0x1A00, 0x20), block-1A00.data.at(code - 0x1A00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1A20 <= code and code <= 0x1AAF {
    import "block-1A20.typ"
    (("Tai Tham", 0x1A20, 0x90), block-1A20.data.at(code - 0x1A20, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1AB0 <= code and code <= 0x1AFF {
    import "block-1AB0.typ"
    (("Combining Diacritical Marks Extended", 0x1AB0, 0x50), block-1AB0.data.at(code - 0x1AB0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1B00 <= code and code <= 0x1B7F {
    import "block-1B00.typ"
    (("Balinese", 0x1B00, 0x80), block-1B00.data.at(code - 0x1B00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1B80 <= code and code <= 0x1BBF {
    import "block-1B80.typ"
    (("Sundanese", 0x1B80, 0x40), block-1B80.data.at(code - 0x1B80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1BC0 <= code and code <= 0x1BFF {
    import "block-1BC0.typ"
    (("Batak", 0x1BC0, 0x40), block-1BC0.data.at(code - 0x1BC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1C00 <= code and code <= 0x1C4F {
    import "block-1C00.typ"
    (("Lepcha", 0x1C00, 0x50), block-1C00.data.at(code - 0x1C00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1C50 <= code and code <= 0x1C7F {
    import "block-1C50.typ"
    (("Ol Chiki", 0x1C50, 0x30), block-1C50.data.at(code - 0x1C50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1C80 <= code and code <= 0x1C8F {
    import "block-1C80.typ"
    (("Cyrillic Extended-C", 0x1C80, 0x10), block-1C80.data.at(code - 0x1C80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1C90 <= code and code <= 0x1CBF {
    import "block-1C90.typ"
    (("Georgian Extended", 0x1C90, 0x30), block-1C90.data.at(code - 0x1C90, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1CC0 <= code and code <= 0x1CCF {
    import "block-1CC0.typ"
    (("Sundanese Supplement", 0x1CC0, 0x10), block-1CC0.data.at(code - 0x1CC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1CD0 <= code and code <= 0x1CFF {
    import "block-1CD0.typ"
    (("Vedic Extensions", 0x1CD0, 0x30), block-1CD0.data.at(code - 0x1CD0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D00 <= code and code <= 0x1D7F {
    import "block-1D00.typ"
    (("Phonetic Extensions", 0x1D00, 0x80), block-1D00.data.at(code - 0x1D00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D80 <= code and code <= 0x1DBF {
    import "block-1D80.typ"
    (("Phonetic Extensions Supplement", 0x1D80, 0x40), block-1D80.data.at(code - 0x1D80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1DC0 <= code and code <= 0x1DFF {
    import "block-1DC0.typ"
    (("Combining Diacritical Marks Supplement", 0x1DC0, 0x40), block-1DC0.data.at(code - 0x1DC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E00 <= code and code <= 0x1EFF {
    import "block-1E00.typ"
    (("Latin Extended Additional", 0x1E00, 0x100), block-1E00.data.at(code - 0x1E00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F00 <= code and code <= 0x1FFF {
    import "block-1F00.typ"
    (("Greek Extended", 0x1F00, 0x100), block-1F00.data.at(code - 0x1F00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2000 <= code and code <= 0x206F {
    import "block-2000.typ"
    (("General Punctuation", 0x2000, 0x70), block-2000.data.at(code - 0x2000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2070 <= code and code <= 0x209F {
    import "block-2070.typ"
    (("Superscripts and Subscripts", 0x2070, 0x30), block-2070.data.at(code - 0x2070, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x20A0 <= code and code <= 0x20CF {
    import "block-20A0.typ"
    (("Currency Symbols", 0x20A0, 0x30), block-20A0.data.at(code - 0x20A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x20D0 <= code and code <= 0x20FF {
    import "block-20D0.typ"
    (("Combining Diacritical Marks for Symbols", 0x20D0, 0x30), block-20D0.data.at(code - 0x20D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2100 <= code and code <= 0x214F {
    import "block-2100.typ"
    (("Letterlike Symbols", 0x2100, 0x50), block-2100.data.at(code - 0x2100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2150 <= code and code <= 0x218F {
    import "block-2150.typ"
    (("Number Forms", 0x2150, 0x40), block-2150.data.at(code - 0x2150, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2190 <= code and code <= 0x21FF {
    import "block-2190.typ"
    (("Arrows", 0x2190, 0x70), block-2190.data.at(code - 0x2190, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2200 <= code and code <= 0x22FF {
    import "block-2200.typ"
    (("Mathematical Operators", 0x2200, 0x100), block-2200.data.at(code - 0x2200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2300 <= code and code <= 0x23FF {
    import "block-2300.typ"
    (("Miscellaneous Technical", 0x2300, 0x100), block-2300.data.at(code - 0x2300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2400 <= code and code <= 0x243F {
    import "block-2400.typ"
    (("Control Pictures", 0x2400, 0x40), block-2400.data.at(code - 0x2400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2440 <= code and code <= 0x245F {
    import "block-2440.typ"
    (("Optical Character Recognition", 0x2440, 0x20), block-2440.data.at(code - 0x2440, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2460 <= code and code <= 0x24FF {
    import "block-2460.typ"
    (("Enclosed Alphanumerics", 0x2460, 0xA0), block-2460.data.at(code - 0x2460, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2500 <= code and code <= 0x257F {
    import "block-2500.typ"
    (("Box Drawing", 0x2500, 0x80), block-2500.data.at(code - 0x2500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2580 <= code and code <= 0x259F {
    import "block-2580.typ"
    (("Block Elements", 0x2580, 0x20), block-2580.data.at(code - 0x2580, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x25A0 <= code and code <= 0x25FF {
    import "block-25A0.typ"
    (("Geometric Shapes", 0x25A0, 0x60), block-25A0.data.at(code - 0x25A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2600 <= code and code <= 0x26FF {
    import "block-2600.typ"
    (("Miscellaneous Symbols", 0x2600, 0x100), block-2600.data.at(code - 0x2600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2700 <= code and code <= 0x27BF {
    import "block-2700.typ"
    (("Dingbats", 0x2700, 0xC0), block-2700.data.at(code - 0x2700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x27C0 <= code and code <= 0x27EF {
    import "block-27C0.typ"
    (("Miscellaneous Mathematical Symbols-A", 0x27C0, 0x30), block-27C0.data.at(code - 0x27C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x27F0 <= code and code <= 0x27FF {
    import "block-27F0.typ"
    (("Supplemental Arrows-A", 0x27F0, 0x10), block-27F0.data.at(code - 0x27F0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2800 <= code and code <= 0x28FF {
    import "block-2800.typ"
    (("Braille Patterns", 0x2800, 0x100), block-2800.data.at(code - 0x2800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2900 <= code and code <= 0x297F {
    import "block-2900.typ"
    (("Supplemental Arrows-B", 0x2900, 0x80), block-2900.data.at(code - 0x2900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2980 <= code and code <= 0x29FF {
    import "block-2980.typ"
    (("Miscellaneous Mathematical Symbols-B", 0x2980, 0x80), block-2980.data.at(code - 0x2980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2A00 <= code and code <= 0x2AFF {
    import "block-2A00.typ"
    (("Supplemental Mathematical Operators", 0x2A00, 0x100), block-2A00.data.at(code - 0x2A00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2B00 <= code and code <= 0x2BFF {
    import "block-2B00.typ"
    (("Miscellaneous Symbols and Arrows", 0x2B00, 0x100), block-2B00.data.at(code - 0x2B00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2C00 <= code and code <= 0x2C5F {
    import "block-2C00.typ"
    (("Glagolitic", 0x2C00, 0x60), block-2C00.data.at(code - 0x2C00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2C60 <= code and code <= 0x2C7F {
    import "block-2C60.typ"
    (("Latin Extended-C", 0x2C60, 0x20), block-2C60.data.at(code - 0x2C60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2C80 <= code and code <= 0x2CFF {
    import "block-2C80.typ"
    (("Coptic", 0x2C80, 0x80), block-2C80.data.at(code - 0x2C80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2D00 <= code and code <= 0x2D2F {
    import "block-2D00.typ"
    (("Georgian Supplement", 0x2D00, 0x30), block-2D00.data.at(code - 0x2D00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2D30 <= code and code <= 0x2D7F {
    import "block-2D30.typ"
    (("Tifinagh", 0x2D30, 0x50), block-2D30.data.at(code - 0x2D30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2D80 <= code and code <= 0x2DDF {
    import "block-2D80.typ"
    (("Ethiopic Extended", 0x2D80, 0x60), block-2D80.data.at(code - 0x2D80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2DE0 <= code and code <= 0x2DFF {
    import "block-2DE0.typ"
    (("Cyrillic Extended-A", 0x2DE0, 0x20), block-2DE0.data.at(code - 0x2DE0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2E00 <= code and code <= 0x2E7F {
    import "block-2E00.typ"
    (("Supplemental Punctuation", 0x2E00, 0x80), block-2E00.data.at(code - 0x2E00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2E80 <= code and code <= 0x2EFF {
    import "block-2E80.typ"
    (("CJK Radicals Supplement", 0x2E80, 0x80), block-2E80.data.at(code - 0x2E80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2F00 <= code and code <= 0x2FDF {
    import "block-2F00.typ"
    (("Kangxi Radicals", 0x2F00, 0xE0), block-2F00.data.at(code - 0x2F00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2FF0 <= code and code <= 0x2FFF {
    import "block-2FF0.typ"
    (("Ideographic Description Characters", 0x2FF0, 0x10), block-2FF0.data.at(code - 0x2FF0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3000 <= code and code <= 0x303F {
    import "block-3000.typ"
    (("CJK Symbols and Punctuation", 0x3000, 0x40), block-3000.data.at(code - 0x3000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3040 <= code and code <= 0x309F {
    import "block-3040.typ"
    (("Hiragana", 0x3040, 0x60), block-3040.data.at(code - 0x3040, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x30A0 <= code and code <= 0x30FF {
    import "block-30A0.typ"
    (("Katakana", 0x30A0, 0x60), block-30A0.data.at(code - 0x30A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3100 <= code and code <= 0x312F {
    import "block-3100.typ"
    (("Bopomofo", 0x3100, 0x30), block-3100.data.at(code - 0x3100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3130 <= code and code <= 0x318F {
    import "block-3130.typ"
    (("Hangul Compatibility Jamo", 0x3130, 0x60), block-3130.data.at(code - 0x3130, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3190 <= code and code <= 0x319F {
    import "block-3190.typ"
    (("Kanbun", 0x3190, 0x10), block-3190.data.at(code - 0x3190, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31A0 <= code and code <= 0x31BF {
    import "block-31A0.typ"
    (("Bopomofo Extended", 0x31A0, 0x20), block-31A0.data.at(code - 0x31A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31C0 <= code and code <= 0x31EF {
    import "block-31C0.typ"
    (("CJK Strokes", 0x31C0, 0x30), block-31C0.data.at(code - 0x31C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31F0 <= code and code <= 0x31FF {
    import "block-31F0.typ"
    (("Katakana Phonetic Extensions", 0x31F0, 0x10), block-31F0.data.at(code - 0x31F0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3200 <= code and code <= 0x32FF {
    import "block-3200.typ"
    (("Enclosed CJK Letters and Months", 0x3200, 0x100), block-3200.data.at(code - 0x3200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3300 <= code and code <= 0x33FF {
    import "block-3300.typ"
    (("CJK Compatibility", 0x3300, 0x100), block-3300.data.at(code - 0x3300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3400 <= code and code <= 0x4DBF {
    import "block-3400.typ"
    (("CJK Unified Ideographs Extension A", 0x3400, 0x19C0), block-3400.data.at(upper(str(code - 0x3400, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x4DC0 <= code and code <= 0x4DFF {
    import "block-4DC0.typ"
    (("Yijing Hexagram Symbols", 0x4DC0, 0x40), block-4DC0.data.at(code - 0x4DC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x4E00 <= code and code <= 0x9FFF {
    import "block-4E00.typ"
    (("CJK Unified Ideographs", 0x4E00, 0x5200), block-4E00.data.at(upper(str(code - 0x4E00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA000 <= code and code <= 0xA48F {
    import "block-A000.typ"
    (("Yi Syllables", 0xA000, 0x490), block-A000.data.at(code - 0xA000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA490 <= code and code <= 0xA4CF {
    import "block-A490.typ"
    (("Yi Radicals", 0xA490, 0x40), block-A490.data.at(code - 0xA490, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA4D0 <= code and code <= 0xA4FF {
    import "block-A4D0.typ"
    (("Lisu", 0xA4D0, 0x30), block-A4D0.data.at(code - 0xA4D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA500 <= code and code <= 0xA63F {
    import "block-A500.typ"
    (("Vai", 0xA500, 0x140), block-A500.data.at(code - 0xA500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA640 <= code and code <= 0xA69F {
    import "block-A640.typ"
    (("Cyrillic Extended-B", 0xA640, 0x60), block-A640.data.at(code - 0xA640, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA6A0 <= code and code <= 0xA6FF {
    import "block-A6A0.typ"
    (("Bamum", 0xA6A0, 0x60), block-A6A0.data.at(code - 0xA6A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA700 <= code and code <= 0xA71F {
    import "block-A700.typ"
    (("Modifier Tone Letters", 0xA700, 0x20), block-A700.data.at(code - 0xA700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA720 <= code and code <= 0xA7FF {
    import "block-A720.typ"
    (("Latin Extended-D", 0xA720, 0xE0), block-A720.data.at(code - 0xA720, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA800 <= code and code <= 0xA82F {
    import "block-A800.typ"
    (("Syloti Nagri", 0xA800, 0x30), block-A800.data.at(code - 0xA800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA830 <= code and code <= 0xA83F {
    import "block-A830.typ"
    (("Common Indic Number Forms", 0xA830, 0x10), block-A830.data.at(code - 0xA830, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA840 <= code and code <= 0xA87F {
    import "block-A840.typ"
    (("Phags-pa", 0xA840, 0x40), block-A840.data.at(code - 0xA840, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA880 <= code and code <= 0xA8DF {
    import "block-A880.typ"
    (("Saurashtra", 0xA880, 0x60), block-A880.data.at(code - 0xA880, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA8E0 <= code and code <= 0xA8FF {
    import "block-A8E0.typ"
    (("Devanagari Extended", 0xA8E0, 0x20), block-A8E0.data.at(code - 0xA8E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA900 <= code and code <= 0xA92F {
    import "block-A900.typ"
    (("Kayah Li", 0xA900, 0x30), block-A900.data.at(code - 0xA900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA930 <= code and code <= 0xA95F {
    import "block-A930.typ"
    (("Rejang", 0xA930, 0x30), block-A930.data.at(code - 0xA930, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA960 <= code and code <= 0xA97F {
    import "block-A960.typ"
    (("Hangul Jamo Extended-A", 0xA960, 0x20), block-A960.data.at(code - 0xA960, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA980 <= code and code <= 0xA9DF {
    import "block-A980.typ"
    (("Javanese", 0xA980, 0x60), block-A980.data.at(code - 0xA980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xA9E0 <= code and code <= 0xA9FF {
    import "block-A9E0.typ"
    (("Myanmar Extended-B", 0xA9E0, 0x20), block-A9E0.data.at(code - 0xA9E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAA00 <= code and code <= 0xAA5F {
    import "block-AA00.typ"
    (("Cham", 0xAA00, 0x60), block-AA00.data.at(code - 0xAA00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAA60 <= code and code <= 0xAA7F {
    import "block-AA60.typ"
    (("Myanmar Extended-A", 0xAA60, 0x20), block-AA60.data.at(code - 0xAA60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAA80 <= code and code <= 0xAADF {
    import "block-AA80.typ"
    (("Tai Viet", 0xAA80, 0x60), block-AA80.data.at(code - 0xAA80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAAE0 <= code and code <= 0xAAFF {
    import "block-AAE0.typ"
    (("Meetei Mayek Extensions", 0xAAE0, 0x20), block-AAE0.data.at(code - 0xAAE0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAB00 <= code and code <= 0xAB2F {
    import "block-AB00.typ"
    (("Ethiopic Extended-A", 0xAB00, 0x30), block-AB00.data.at(code - 0xAB00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAB30 <= code and code <= 0xAB6F {
    import "block-AB30.typ"
    (("Latin Extended-E", 0xAB30, 0x40), block-AB30.data.at(code - 0xAB30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAB70 <= code and code <= 0xABBF {
    import "block-AB70.typ"
    (("Cherokee Supplement", 0xAB70, 0x50), block-AB70.data.at(code - 0xAB70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xABC0 <= code and code <= 0xABFF {
    import "block-ABC0.typ"
    (("Meetei Mayek", 0xABC0, 0x40), block-ABC0.data.at(code - 0xABC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xAC00 <= code and code <= 0xD7AF {
    import "block-AC00.typ"
    (("Hangul Syllables", 0xAC00, 0x2BB0), block-AC00.data.at(upper(str(code - 0xAC00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xD7B0 <= code and code <= 0xD7FF {
    import "block-D7B0.typ"
    (("Hangul Jamo Extended-B", 0xD7B0, 0x50), block-D7B0.data.at(code - 0xD7B0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xD800 <= code and code <= 0xDB7F {
    import "block-D800.typ"
    (("High Surrogates", 0xD800, 0x380), block-D800.data.at(upper(str(code - 0xD800, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xDB80 <= code and code <= 0xDBFF {
    import "block-DB80.typ"
    (("High Private Use Surrogates", 0xDB80, 0x80), block-DB80.data.at(upper(str(code - 0xDB80, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xDC00 <= code and code <= 0xDFFF {
    import "block-DC00.typ"
    (("Low Surrogates", 0xDC00, 0x400), block-DC00.data.at(upper(str(code - 0xDC00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xE000 <= code and code <= 0xF8FF {
    import "block-E000.typ"
    (("Private Use Area", 0xE000, 0x1900), block-E000.data.at(upper(str(code - 0xE000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xF900 <= code and code <= 0xFAFF {
    import "block-F900.typ"
    (("CJK Compatibility Ideographs", 0xF900, 0x200), block-F900.data.at(code - 0xF900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFB00 <= code and code <= 0xFB4F {
    import "block-FB00.typ"
    (("Alphabetic Presentation Forms", 0xFB00, 0x50), block-FB00.data.at(code - 0xFB00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFB50 <= code and code <= 0xFDFF {
    import "block-FB50.typ"
    (("Arabic Presentation Forms-A", 0xFB50, 0x2B0), block-FB50.data.at(code - 0xFB50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFE00 <= code and code <= 0xFE0F {
    import "block-FE00.typ"
    (("Variation Selectors", 0xFE00, 0x10), block-FE00.data.at(code - 0xFE00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFE10 <= code and code <= 0xFE1F {
    import "block-FE10.typ"
    (("Vertical Forms", 0xFE10, 0x10), block-FE10.data.at(code - 0xFE10, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFE20 <= code and code <= 0xFE2F {
    import "block-FE20.typ"
    (("Combining Half Marks", 0xFE20, 0x10), block-FE20.data.at(code - 0xFE20, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFE30 <= code and code <= 0xFE4F {
    import "block-FE30.typ"
    (("CJK Compatibility Forms", 0xFE30, 0x20), block-FE30.data.at(code - 0xFE30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFE50 <= code and code <= 0xFE6F {
    import "block-FE50.typ"
    (("Small Form Variants", 0xFE50, 0x20), block-FE50.data.at(code - 0xFE50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFE70 <= code and code <= 0xFEFF {
    import "block-FE70.typ"
    (("Arabic Presentation Forms-B", 0xFE70, 0x90), block-FE70.data.at(code - 0xFE70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFF00 <= code and code <= 0xFFEF {
    import "block-FF00.typ"
    (("Halfwidth and Fullwidth Forms", 0xFF00, 0xF0), block-FF00.data.at(code - 0xFF00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xFFF0 <= code and code <= 0xFFFF {
    import "block-FFF0.typ"
    (("Specials", 0xFFF0, 0x10), block-FFF0.data.at(upper(str(code - 0xFFF0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10000 <= code and code <= 0x1007F {
    import "block-10000.typ"
    (("Linear B Syllabary", 0x10000, 0x80), block-10000.data.at(code - 0x10000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10080 <= code and code <= 0x100FF {
    import "block-10080.typ"
    (("Linear B Ideograms", 0x10080, 0x80), block-10080.data.at(code - 0x10080, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10100 <= code and code <= 0x1013F {
    import "block-10100.typ"
    (("Aegean Numbers", 0x10100, 0x40), block-10100.data.at(code - 0x10100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10140 <= code and code <= 0x1018F {
    import "block-10140.typ"
    (("Ancient Greek Numbers", 0x10140, 0x50), block-10140.data.at(code - 0x10140, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10190 <= code and code <= 0x101CF {
    import "block-10190.typ"
    (("Ancient Symbols", 0x10190, 0x40), block-10190.data.at(code - 0x10190, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x101D0 <= code and code <= 0x101FF {
    import "block-101D0.typ"
    (("Phaistos Disc", 0x101D0, 0x30), block-101D0.data.at(code - 0x101D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10280 <= code and code <= 0x1029F {
    import "block-10280.typ"
    (("Lycian", 0x10280, 0x20), block-10280.data.at(code - 0x10280, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x102A0 <= code and code <= 0x102DF {
    import "block-102A0.typ"
    (("Carian", 0x102A0, 0x40), block-102A0.data.at(code - 0x102A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x102E0 <= code and code <= 0x102FF {
    import "block-102E0.typ"
    (("Coptic Epact Numbers", 0x102E0, 0x20), block-102E0.data.at(code - 0x102E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10300 <= code and code <= 0x1032F {
    import "block-10300.typ"
    (("Old Italic", 0x10300, 0x30), block-10300.data.at(code - 0x10300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10330 <= code and code <= 0x1034F {
    import "block-10330.typ"
    (("Gothic", 0x10330, 0x20), block-10330.data.at(code - 0x10330, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10350 <= code and code <= 0x1037F {
    import "block-10350.typ"
    (("Old Permic", 0x10350, 0x30), block-10350.data.at(code - 0x10350, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10380 <= code and code <= 0x1039F {
    import "block-10380.typ"
    (("Ugaritic", 0x10380, 0x20), block-10380.data.at(code - 0x10380, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x103A0 <= code and code <= 0x103DF {
    import "block-103A0.typ"
    (("Old Persian", 0x103A0, 0x40), block-103A0.data.at(code - 0x103A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10400 <= code and code <= 0x1044F {
    import "block-10400.typ"
    (("Deseret", 0x10400, 0x50), block-10400.data.at(code - 0x10400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10450 <= code and code <= 0x1047F {
    import "block-10450.typ"
    (("Shavian", 0x10450, 0x30), block-10450.data.at(code - 0x10450, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10480 <= code and code <= 0x104AF {
    import "block-10480.typ"
    (("Osmanya", 0x10480, 0x30), block-10480.data.at(code - 0x10480, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x104B0 <= code and code <= 0x104FF {
    import "block-104B0.typ"
    (("Osage", 0x104B0, 0x50), block-104B0.data.at(code - 0x104B0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10500 <= code and code <= 0x1052F {
    import "block-10500.typ"
    (("Elbasan", 0x10500, 0x30), block-10500.data.at(code - 0x10500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10530 <= code and code <= 0x1056F {
    import "block-10530.typ"
    (("Caucasian Albanian", 0x10530, 0x40), block-10530.data.at(code - 0x10530, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10570 <= code and code <= 0x105BF {
    import "block-10570.typ"
    (("Vithkuqi", 0x10570, 0x50), block-10570.data.at(code - 0x10570, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x105C0 <= code and code <= 0x105FF {
    import "block-105C0.typ"
    (("Todhri", 0x105C0, 0x40), block-105C0.data.at(code - 0x105C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10600 <= code and code <= 0x1077F {
    import "block-10600.typ"
    (("Linear A", 0x10600, 0x180), block-10600.data.at(code - 0x10600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10780 <= code and code <= 0x107BF {
    import "block-10780.typ"
    (("Latin Extended-F", 0x10780, 0x40), block-10780.data.at(code - 0x10780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10800 <= code and code <= 0x1083F {
    import "block-10800.typ"
    (("Cypriot Syllabary", 0x10800, 0x40), block-10800.data.at(code - 0x10800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10840 <= code and code <= 0x1085F {
    import "block-10840.typ"
    (("Imperial Aramaic", 0x10840, 0x20), block-10840.data.at(code - 0x10840, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10860 <= code and code <= 0x1087F {
    import "block-10860.typ"
    (("Palmyrene", 0x10860, 0x20), block-10860.data.at(code - 0x10860, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10880 <= code and code <= 0x108AF {
    import "block-10880.typ"
    (("Nabataean", 0x10880, 0x30), block-10880.data.at(code - 0x10880, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x108E0 <= code and code <= 0x108FF {
    import "block-108E0.typ"
    (("Hatran", 0x108E0, 0x20), block-108E0.data.at(code - 0x108E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10900 <= code and code <= 0x1091F {
    import "block-10900.typ"
    (("Phoenician", 0x10900, 0x20), block-10900.data.at(code - 0x10900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10920 <= code and code <= 0x1093F {
    import "block-10920.typ"
    (("Lydian", 0x10920, 0x20), block-10920.data.at(code - 0x10920, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10940 <= code and code <= 0x1095F {
    import "block-10940.typ"
    (("Sidetic", 0x10940, 0x20), block-10940.data.at(code - 0x10940, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10980 <= code and code <= 0x1099F {
    import "block-10980.typ"
    (("Meroitic Hieroglyphs", 0x10980, 0x20), block-10980.data.at(code - 0x10980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x109A0 <= code and code <= 0x109FF {
    import "block-109A0.typ"
    (("Meroitic Cursive", 0x109A0, 0x60), block-109A0.data.at(code - 0x109A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10A00 <= code and code <= 0x10A5F {
    import "block-10A00.typ"
    (("Kharoshthi", 0x10A00, 0x60), block-10A00.data.at(code - 0x10A00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10A60 <= code and code <= 0x10A7F {
    import "block-10A60.typ"
    (("Old South Arabian", 0x10A60, 0x20), block-10A60.data.at(code - 0x10A60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10A80 <= code and code <= 0x10A9F {
    import "block-10A80.typ"
    (("Old North Arabian", 0x10A80, 0x20), block-10A80.data.at(code - 0x10A80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10AC0 <= code and code <= 0x10AFF {
    import "block-10AC0.typ"
    (("Manichaean", 0x10AC0, 0x40), block-10AC0.data.at(code - 0x10AC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10B00 <= code and code <= 0x10B3F {
    import "block-10B00.typ"
    (("Avestan", 0x10B00, 0x40), block-10B00.data.at(code - 0x10B00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10B40 <= code and code <= 0x10B5F {
    import "block-10B40.typ"
    (("Inscriptional Parthian", 0x10B40, 0x20), block-10B40.data.at(code - 0x10B40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10B60 <= code and code <= 0x10B7F {
    import "block-10B60.typ"
    (("Inscriptional Pahlavi", 0x10B60, 0x20), block-10B60.data.at(code - 0x10B60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10B80 <= code and code <= 0x10BAF {
    import "block-10B80.typ"
    (("Psalter Pahlavi", 0x10B80, 0x30), block-10B80.data.at(code - 0x10B80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10C00 <= code and code <= 0x10C4F {
    import "block-10C00.typ"
    (("Old Turkic", 0x10C00, 0x50), block-10C00.data.at(code - 0x10C00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10C80 <= code and code <= 0x10CFF {
    import "block-10C80.typ"
    (("Old Hungarian", 0x10C80, 0x80), block-10C80.data.at(code - 0x10C80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10D00 <= code and code <= 0x10D3F {
    import "block-10D00.typ"
    (("Hanifi Rohingya", 0x10D00, 0x40), block-10D00.data.at(code - 0x10D00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10D40 <= code and code <= 0x10D8F {
    import "block-10D40.typ"
    (("Garay", 0x10D40, 0x50), block-10D40.data.at(code - 0x10D40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10E60 <= code and code <= 0x10E7F {
    import "block-10E60.typ"
    (("Rumi Numeral Symbols", 0x10E60, 0x20), block-10E60.data.at(code - 0x10E60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10E80 <= code and code <= 0x10EBF {
    import "block-10E80.typ"
    (("Yezidi", 0x10E80, 0x40), block-10E80.data.at(code - 0x10E80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10EC0 <= code and code <= 0x10EFF {
    import "block-10EC0.typ"
    (("Arabic Extended-C", 0x10EC0, 0x40), block-10EC0.data.at(upper(str(code - 0x10EC0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10F00 <= code and code <= 0x10F2F {
    import "block-10F00.typ"
    (("Old Sogdian", 0x10F00, 0x30), block-10F00.data.at(code - 0x10F00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10F30 <= code and code <= 0x10F6F {
    import "block-10F30.typ"
    (("Sogdian", 0x10F30, 0x40), block-10F30.data.at(code - 0x10F30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10F70 <= code and code <= 0x10FAF {
    import "block-10F70.typ"
    (("Old Uyghur", 0x10F70, 0x40), block-10F70.data.at(code - 0x10F70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10FB0 <= code and code <= 0x10FDF {
    import "block-10FB0.typ"
    (("Chorasmian", 0x10FB0, 0x30), block-10FB0.data.at(code - 0x10FB0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10FE0 <= code and code <= 0x10FFF {
    import "block-10FE0.typ"
    (("Elymaic", 0x10FE0, 0x20), block-10FE0.data.at(code - 0x10FE0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11000 <= code and code <= 0x1107F {
    import "block-11000.typ"
    (("Brahmi", 0x11000, 0x80), block-11000.data.at(code - 0x11000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11080 <= code and code <= 0x110CF {
    import "block-11080.typ"
    (("Kaithi", 0x11080, 0x50), block-11080.data.at(code - 0x11080, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x110D0 <= code and code <= 0x110FF {
    import "block-110D0.typ"
    (("Sora Sompeng", 0x110D0, 0x30), block-110D0.data.at(code - 0x110D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11100 <= code and code <= 0x1114F {
    import "block-11100.typ"
    (("Chakma", 0x11100, 0x50), block-11100.data.at(code - 0x11100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11150 <= code and code <= 0x1117F {
    import "block-11150.typ"
    (("Mahajani", 0x11150, 0x30), block-11150.data.at(code - 0x11150, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11180 <= code and code <= 0x111DF {
    import "block-11180.typ"
    (("Sharada", 0x11180, 0x60), block-11180.data.at(code - 0x11180, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x111E0 <= code and code <= 0x111FF {
    import "block-111E0.typ"
    (("Sinhala Archaic Numbers", 0x111E0, 0x20), block-111E0.data.at(code - 0x111E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11200 <= code and code <= 0x1124F {
    import "block-11200.typ"
    (("Khojki", 0x11200, 0x50), block-11200.data.at(code - 0x11200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11280 <= code and code <= 0x112AF {
    import "block-11280.typ"
    (("Multani", 0x11280, 0x30), block-11280.data.at(code - 0x11280, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x112B0 <= code and code <= 0x112FF {
    import "block-112B0.typ"
    (("Khudawadi", 0x112B0, 0x50), block-112B0.data.at(code - 0x112B0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11300 <= code and code <= 0x1137F {
    import "block-11300.typ"
    (("Grantha", 0x11300, 0x80), block-11300.data.at(code - 0x11300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11380 <= code and code <= 0x113FF {
    import "block-11380.typ"
    (("Tulu-Tigalari", 0x11380, 0x80), block-11380.data.at(code - 0x11380, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11400 <= code and code <= 0x1147F {
    import "block-11400.typ"
    (("Newa", 0x11400, 0x80), block-11400.data.at(code - 0x11400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11480 <= code and code <= 0x114DF {
    import "block-11480.typ"
    (("Tirhuta", 0x11480, 0x60), block-11480.data.at(code - 0x11480, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11580 <= code and code <= 0x115FF {
    import "block-11580.typ"
    (("Siddham", 0x11580, 0x80), block-11580.data.at(code - 0x11580, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11600 <= code and code <= 0x1165F {
    import "block-11600.typ"
    (("Modi", 0x11600, 0x60), block-11600.data.at(code - 0x11600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11660 <= code and code <= 0x1167F {
    import "block-11660.typ"
    (("Mongolian Supplement", 0x11660, 0x20), block-11660.data.at(code - 0x11660, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11680 <= code and code <= 0x116CF {
    import "block-11680.typ"
    (("Takri", 0x11680, 0x50), block-11680.data.at(code - 0x11680, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x116D0 <= code and code <= 0x116FF {
    import "block-116D0.typ"
    (("Myanmar Extended-C", 0x116D0, 0x30), block-116D0.data.at(code - 0x116D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11700 <= code and code <= 0x1174F {
    import "block-11700.typ"
    (("Ahom", 0x11700, 0x50), block-11700.data.at(code - 0x11700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11800 <= code and code <= 0x1184F {
    import "block-11800.typ"
    (("Dogra", 0x11800, 0x50), block-11800.data.at(code - 0x11800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x118A0 <= code and code <= 0x118FF {
    import "block-118A0.typ"
    (("Warang Citi", 0x118A0, 0x60), block-118A0.data.at(code - 0x118A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11900 <= code and code <= 0x1195F {
    import "block-11900.typ"
    (("Dives Akuru", 0x11900, 0x60), block-11900.data.at(code - 0x11900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x119A0 <= code and code <= 0x119FF {
    import "block-119A0.typ"
    (("Nandinagari", 0x119A0, 0x60), block-119A0.data.at(code - 0x119A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11A00 <= code and code <= 0x11A4F {
    import "block-11A00.typ"
    (("Zanabazar Square", 0x11A00, 0x50), block-11A00.data.at(code - 0x11A00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11A50 <= code and code <= 0x11AAF {
    import "block-11A50.typ"
    (("Soyombo", 0x11A50, 0x60), block-11A50.data.at(code - 0x11A50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11AB0 <= code and code <= 0x11ABF {
    import "block-11AB0.typ"
    (("Unified Canadian Aboriginal Syllabics Extended-A", 0x11AB0, 0x10), block-11AB0.data.at(code - 0x11AB0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11AC0 <= code and code <= 0x11AFF {
    import "block-11AC0.typ"
    (("Pau Cin Hau", 0x11AC0, 0x40), block-11AC0.data.at(code - 0x11AC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11B00 <= code and code <= 0x11B5F {
    import "block-11B00.typ"
    (("Devanagari Extended-A", 0x11B00, 0x60), block-11B00.data.at(code - 0x11B00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11B60 <= code and code <= 0x11B7F {
    import "block-11B60.typ"
    (("Sharada Supplement", 0x11B60, 0x20), block-11B60.data.at(code - 0x11B60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11BC0 <= code and code <= 0x11BFF {
    import "block-11BC0.typ"
    (("Sunuwar", 0x11BC0, 0x40), block-11BC0.data.at(code - 0x11BC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11C00 <= code and code <= 0x11C6F {
    import "block-11C00.typ"
    (("Bhaiksuki", 0x11C00, 0x70), block-11C00.data.at(code - 0x11C00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11C70 <= code and code <= 0x11CBF {
    import "block-11C70.typ"
    (("Marchen", 0x11C70, 0x50), block-11C70.data.at(code - 0x11C70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11D00 <= code and code <= 0x11D5F {
    import "block-11D00.typ"
    (("Masaram Gondi", 0x11D00, 0x60), block-11D00.data.at(code - 0x11D00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11D60 <= code and code <= 0x11DAF {
    import "block-11D60.typ"
    (("Gunjala Gondi", 0x11D60, 0x50), block-11D60.data.at(code - 0x11D60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11DB0 <= code and code <= 0x11DEF {
    import "block-11DB0.typ"
    (("Tolong Siki", 0x11DB0, 0x40), block-11DB0.data.at(code - 0x11DB0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11EE0 <= code and code <= 0x11EFF {
    import "block-11EE0.typ"
    (("Makasar", 0x11EE0, 0x20), block-11EE0.data.at(code - 0x11EE0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11F00 <= code and code <= 0x11F5F {
    import "block-11F00.typ"
    (("Kawi", 0x11F00, 0x60), block-11F00.data.at(code - 0x11F00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11FB0 <= code and code <= 0x11FBF {
    import "block-11FB0.typ"
    (("Lisu Supplement", 0x11FB0, 0x10), block-11FB0.data.at(code - 0x11FB0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11FC0 <= code and code <= 0x11FFF {
    import "block-11FC0.typ"
    (("Tamil Supplement", 0x11FC0, 0x40), block-11FC0.data.at(code - 0x11FC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12000 <= code and code <= 0x123FF {
    import "block-12000.typ"
    (("Cuneiform", 0x12000, 0x400), block-12000.data.at(code - 0x12000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12400 <= code and code <= 0x1247F {
    import "block-12400.typ"
    (("Cuneiform Numbers and Punctuation", 0x12400, 0x80), block-12400.data.at(code - 0x12400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12480 <= code and code <= 0x1254F {
    import "block-12480.typ"
    (("Early Dynastic Cuneiform", 0x12480, 0xD0), block-12480.data.at(code - 0x12480, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12F90 <= code and code <= 0x12FFF {
    import "block-12F90.typ"
    (("Cypro-Minoan", 0x12F90, 0x70), block-12F90.data.at(code - 0x12F90, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13000 <= code and code <= 0x1342F {
    import "block-13000.typ"
    (("Egyptian Hieroglyphs", 0x13000, 0x430), block-13000.data.at(code - 0x13000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13430 <= code and code <= 0x1345F {
    import "block-13430.typ"
    (("Egyptian Hieroglyph Format Controls", 0x13430, 0x30), block-13430.data.at(code - 0x13430, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13460 <= code and code <= 0x143FF {
    import "block-13460.typ"
    (("Egyptian Hieroglyphs Extended-A", 0x13460, 0xFA0), block-13460.data.at(code - 0x13460, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x14400 <= code and code <= 0x1467F {
    import "block-14400.typ"
    (("Anatolian Hieroglyphs", 0x14400, 0x280), block-14400.data.at(code - 0x14400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16100 <= code and code <= 0x1613F {
    import "block-16100.typ"
    (("Gurung Khema", 0x16100, 0x40), block-16100.data.at(code - 0x16100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16800 <= code and code <= 0x16A3F {
    import "block-16800.typ"
    (("Bamum Supplement", 0x16800, 0x240), block-16800.data.at(code - 0x16800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16A40 <= code and code <= 0x16A6F {
    import "block-16A40.typ"
    (("Mro", 0x16A40, 0x30), block-16A40.data.at(code - 0x16A40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16A70 <= code and code <= 0x16ACF {
    import "block-16A70.typ"
    (("Tangsa", 0x16A70, 0x60), block-16A70.data.at(code - 0x16A70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16AD0 <= code and code <= 0x16AFF {
    import "block-16AD0.typ"
    (("Bassa Vah", 0x16AD0, 0x30), block-16AD0.data.at(code - 0x16AD0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16B00 <= code and code <= 0x16B8F {
    import "block-16B00.typ"
    (("Pahawh Hmong", 0x16B00, 0x90), block-16B00.data.at(code - 0x16B00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16D40 <= code and code <= 0x16D7F {
    import "block-16D40.typ"
    (("Kirat Rai", 0x16D40, 0x40), block-16D40.data.at(code - 0x16D40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16E40 <= code and code <= 0x16E9F {
    import "block-16E40.typ"
    (("Medefaidrin", 0x16E40, 0x60), block-16E40.data.at(code - 0x16E40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16EA0 <= code and code <= 0x16EDF {
    import "block-16EA0.typ"
    (("Beria Erfe", 0x16EA0, 0x40), block-16EA0.data.at(code - 0x16EA0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16F00 <= code and code <= 0x16F9F {
    import "block-16F00.typ"
    (("Miao", 0x16F00, 0xA0), block-16F00.data.at(code - 0x16F00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16FE0 <= code and code <= 0x16FFF {
    import "block-16FE0.typ"
    (("Ideographic Symbols and Punctuation", 0x16FE0, 0x20), block-16FE0.data.at(code - 0x16FE0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x17000 <= code and code <= 0x187FF {
    import "block-17000.typ"
    (("Tangut", 0x17000, 0x1800), block-17000.data.at(upper(str(code - 0x17000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18800 <= code and code <= 0x18AFF {
    import "block-18800.typ"
    (("Tangut Components", 0x18800, 0x300), block-18800.data.at(code - 0x18800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18B00 <= code and code <= 0x18CFF {
    import "block-18B00.typ"
    (("Khitan Small Script", 0x18B00, 0x200), block-18B00.data.at(code - 0x18B00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18D00 <= code and code <= 0x18D7F {
    import "block-18D00.typ"
    (("Tangut Supplement", 0x18D00, 0x80), block-18D00.data.at(upper(str(code - 0x18D00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18D80 <= code and code <= 0x18DFF {
    import "block-18D80.typ"
    (("Tangut Components Supplement", 0x18D80, 0x80), block-18D80.data.at(code - 0x18D80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1AFF0 <= code and code <= 0x1AFFF {
    import "block-1AFF0.typ"
    (("Kana Extended-B", 0x1AFF0, 0x10), block-1AFF0.data.at(code - 0x1AFF0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1B000 <= code and code <= 0x1B0FF {
    import "block-1B000.typ"
    (("Kana Supplement", 0x1B000, 0x100), block-1B000.data.at(code - 0x1B000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1B100 <= code and code <= 0x1B12F {
    import "block-1B100.typ"
    (("Kana Extended-A", 0x1B100, 0x30), block-1B100.data.at(code - 0x1B100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1B130 <= code and code <= 0x1B16F {
    import "block-1B130.typ"
    (("Small Kana Extension", 0x1B130, 0x40), block-1B130.data.at(upper(str(code - 0x1B130, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1B170 <= code and code <= 0x1B2FF {
    import "block-1B170.typ"
    (("Nushu", 0x1B170, 0x190), block-1B170.data.at(code - 0x1B170, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1BC00 <= code and code <= 0x1BC9F {
    import "block-1BC00.typ"
    (("Duployan", 0x1BC00, 0xA0), block-1BC00.data.at(code - 0x1BC00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1BCA0 <= code and code <= 0x1BCAF {
    import "block-1BCA0.typ"
    (("Shorthand Format Controls", 0x1BCA0, 0x10), block-1BCA0.data.at(code - 0x1BCA0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1CC00 <= code and code <= 0x1CEBF {
    import "block-1CC00.typ"
    (("Symbols for Legacy Computing Supplement", 0x1CC00, 0x2C0), block-1CC00.data.at(code - 0x1CC00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1CEC0 <= code and code <= 0x1CEFF {
    import "block-1CEC0.typ"
    (("Miscellaneous Symbols Supplement", 0x1CEC0, 0x40), block-1CEC0.data.at(code - 0x1CEC0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1CF00 <= code and code <= 0x1CFCF {
    import "block-1CF00.typ"
    (("Znamenny Musical Notation", 0x1CF00, 0xD0), block-1CF00.data.at(code - 0x1CF00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D000 <= code and code <= 0x1D0FF {
    import "block-1D000.typ"
    (("Byzantine Musical Symbols", 0x1D000, 0x100), block-1D000.data.at(code - 0x1D000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D100 <= code and code <= 0x1D1FF {
    import "block-1D100.typ"
    (("Musical Symbols", 0x1D100, 0x100), block-1D100.data.at(code - 0x1D100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D200 <= code and code <= 0x1D24F {
    import "block-1D200.typ"
    (("Ancient Greek Musical Notation", 0x1D200, 0x50), block-1D200.data.at(code - 0x1D200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D2C0 <= code and code <= 0x1D2DF {
    import "block-1D2C0.typ"
    (("Kaktovik Numerals", 0x1D2C0, 0x20), block-1D2C0.data.at(code - 0x1D2C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D2E0 <= code and code <= 0x1D2FF {
    import "block-1D2E0.typ"
    (("Mayan Numerals", 0x1D2E0, 0x20), block-1D2E0.data.at(code - 0x1D2E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D300 <= code and code <= 0x1D35F {
    import "block-1D300.typ"
    (("Tai Xuan Jing Symbols", 0x1D300, 0x60), block-1D300.data.at(code - 0x1D300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D360 <= code and code <= 0x1D37F {
    import "block-1D360.typ"
    (("Counting Rod Numerals", 0x1D360, 0x20), block-1D360.data.at(code - 0x1D360, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D400 <= code and code <= 0x1D7FF {
    import "block-1D400.typ"
    (("Mathematical Alphanumeric Symbols", 0x1D400, 0x400), block-1D400.data.at(code - 0x1D400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1D800 <= code and code <= 0x1DAAF {
    import "block-1D800.typ"
    (("Sutton SignWriting", 0x1D800, 0x2B0), block-1D800.data.at(code - 0x1D800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1DF00 <= code and code <= 0x1DFFF {
    import "block-1DF00.typ"
    (("Latin Extended-G", 0x1DF00, 0x100), block-1DF00.data.at(code - 0x1DF00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E000 <= code and code <= 0x1E02F {
    import "block-1E000.typ"
    (("Glagolitic Supplement", 0x1E000, 0x30), block-1E000.data.at(code - 0x1E000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E030 <= code and code <= 0x1E08F {
    import "block-1E030.typ"
    (("Cyrillic Extended-D", 0x1E030, 0x60), block-1E030.data.at(code - 0x1E030, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E100 <= code and code <= 0x1E14F {
    import "block-1E100.typ"
    (("Nyiakeng Puachue Hmong", 0x1E100, 0x50), block-1E100.data.at(code - 0x1E100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E290 <= code and code <= 0x1E2BF {
    import "block-1E290.typ"
    (("Toto", 0x1E290, 0x30), block-1E290.data.at(code - 0x1E290, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E2C0 <= code and code <= 0x1E2FF {
    import "block-1E2C0.typ"
    (("Wancho", 0x1E2C0, 0x40), block-1E2C0.data.at(code - 0x1E2C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E4D0 <= code and code <= 0x1E4FF {
    import "block-1E4D0.typ"
    (("Nag Mundari", 0x1E4D0, 0x30), block-1E4D0.data.at(code - 0x1E4D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E5D0 <= code and code <= 0x1E5FF {
    import "block-1E5D0.typ"
    (("Ol Onal", 0x1E5D0, 0x30), block-1E5D0.data.at(code - 0x1E5D0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E6C0 <= code and code <= 0x1E6FF {
    import "block-1E6C0.typ"
    (("Tai Yo", 0x1E6C0, 0x40), block-1E6C0.data.at(code - 0x1E6C0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E7E0 <= code and code <= 0x1E7FF {
    import "block-1E7E0.typ"
    (("Ethiopic Extended-B", 0x1E7E0, 0x20), block-1E7E0.data.at(code - 0x1E7E0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E800 <= code and code <= 0x1E8DF {
    import "block-1E800.typ"
    (("Mende Kikakui", 0x1E800, 0xE0), block-1E800.data.at(code - 0x1E800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1E900 <= code and code <= 0x1E95F {
    import "block-1E900.typ"
    (("Adlam", 0x1E900, 0x60), block-1E900.data.at(code - 0x1E900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1EC70 <= code and code <= 0x1ECBF {
    import "block-1EC70.typ"
    (("Indic Siyaq Numbers", 0x1EC70, 0x50), block-1EC70.data.at(code - 0x1EC70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1ED00 <= code and code <= 0x1ED4F {
    import "block-1ED00.typ"
    (("Ottoman Siyaq Numbers", 0x1ED00, 0x50), block-1ED00.data.at(code - 0x1ED00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1EE00 <= code and code <= 0x1EEFF {
    import "block-1EE00.typ"
    (("Arabic Mathematical Alphabetic Symbols", 0x1EE00, 0x100), block-1EE00.data.at(code - 0x1EE00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F000 <= code and code <= 0x1F02F {
    import "block-1F000.typ"
    (("Mahjong Tiles", 0x1F000, 0x30), block-1F000.data.at(code - 0x1F000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F030 <= code and code <= 0x1F09F {
    import "block-1F030.typ"
    (("Domino Tiles", 0x1F030, 0x70), block-1F030.data.at(code - 0x1F030, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F0A0 <= code and code <= 0x1F0FF {
    import "block-1F0A0.typ"
    (("Playing Cards", 0x1F0A0, 0x60), block-1F0A0.data.at(code - 0x1F0A0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F100 <= code and code <= 0x1F1FF {
    import "block-1F100.typ"
    (("Enclosed Alphanumeric Supplement", 0x1F100, 0x100), block-1F100.data.at(code - 0x1F100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F200 <= code and code <= 0x1F2FF {
    import "block-1F200.typ"
    (("Enclosed Ideographic Supplement", 0x1F200, 0x100), block-1F200.data.at(code - 0x1F200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F300 <= code and code <= 0x1F5FF {
    import "block-1F300.typ"
    (("Miscellaneous Symbols and Pictographs", 0x1F300, 0x300), block-1F300.data.at(code - 0x1F300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F600 <= code and code <= 0x1F64F {
    import "block-1F600.typ"
    (("Emoticons", 0x1F600, 0x50), block-1F600.data.at(code - 0x1F600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F650 <= code and code <= 0x1F67F {
    import "block-1F650.typ"
    (("Ornamental Dingbats", 0x1F650, 0x30), block-1F650.data.at(code - 0x1F650, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F680 <= code and code <= 0x1F6FF {
    import "block-1F680.typ"
    (("Transport and Map Symbols", 0x1F680, 0x80), block-1F680.data.at(code - 0x1F680, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F700 <= code and code <= 0x1F77F {
    import "block-1F700.typ"
    (("Alchemical Symbols", 0x1F700, 0x80), block-1F700.data.at(code - 0x1F700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F780 <= code and code <= 0x1F7FF {
    import "block-1F780.typ"
    (("Geometric Shapes Extended", 0x1F780, 0x80), block-1F780.data.at(code - 0x1F780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F800 <= code and code <= 0x1F8FF {
    import "block-1F800.typ"
    (("Supplemental Arrows-C", 0x1F800, 0x100), block-1F800.data.at(code - 0x1F800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1F900 <= code and code <= 0x1F9FF {
    import "block-1F900.typ"
    (("Supplemental Symbols and Pictographs", 0x1F900, 0x100), block-1F900.data.at(code - 0x1F900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1FA00 <= code and code <= 0x1FA6F {
    import "block-1FA00.typ"
    (("Chess Symbols", 0x1FA00, 0x70), block-1FA00.data.at(code - 0x1FA00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1FA70 <= code and code <= 0x1FAFF {
    import "block-1FA70.typ"
    (("Symbols and Pictographs Extended-A", 0x1FA70, 0x90), block-1FA70.data.at(code - 0x1FA70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1FB00 <= code and code <= 0x1FBFF {
    import "block-1FB00.typ"
    (("Symbols for Legacy Computing", 0x1FB00, 0x100), block-1FB00.data.at(code - 0x1FB00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x20000 <= code and code <= 0x2A6DF {
    import "block-20000.typ"
    (("CJK Unified Ideographs Extension B", 0x20000, 0xA6E0), block-20000.data.at(upper(str(code - 0x20000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2A700 <= code and code <= 0x2B73F {
    import "block-2A700.typ"
    (("CJK Unified Ideographs Extension C", 0x2A700, 0x1040), block-2A700.data.at(upper(str(code - 0x2A700, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2B740 <= code and code <= 0x2B81F {
    import "block-2B740.typ"
    (("CJK Unified Ideographs Extension D", 0x2B740, 0xE0), block-2B740.data.at(upper(str(code - 0x2B740, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2B820 <= code and code <= 0x2CEAF {
    import "block-2B820.typ"
    (("CJK Unified Ideographs Extension E", 0x2B820, 0x1690), block-2B820.data.at(upper(str(code - 0x2B820, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2CEB0 <= code and code <= 0x2EBEF {
    import "block-2CEB0.typ"
    (("CJK Unified Ideographs Extension F", 0x2CEB0, 0x1D40), block-2CEB0.data.at(upper(str(code - 0x2CEB0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2EBF0 <= code and code <= 0x2EE5F {
    import "block-2EBF0.typ"
    (("CJK Unified Ideographs Extension I", 0x2EBF0, 0x270), block-2EBF0.data.at(upper(str(code - 0x2EBF0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2F800 <= code and code <= 0x2FA1F {
    import "block-2F800.typ"
    (("CJK Compatibility Ideographs Supplement", 0x2F800, 0x220), block-2F800.data.at(code - 0x2F800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x30000 <= code and code <= 0x3134F {
    import "block-30000.typ"
    (("CJK Unified Ideographs Extension G", 0x30000, 0x1350), block-30000.data.at(upper(str(code - 0x30000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31350 <= code and code <= 0x323AF {
    import "block-31350.typ"
    (("CJK Unified Ideographs Extension H", 0x31350, 0x1060), block-31350.data.at(upper(str(code - 0x31350, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x323B0 <= code and code <= 0x3347F {
    import "block-323B0.typ"
    (("CJK Unified Ideographs Extension J", 0x323B0, 0x10D0), block-323B0.data.at(upper(str(code - 0x323B0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xE0000 <= code and code <= 0xE007F {
    import "block-E0000.typ"
    (("Tags", 0xE0000, 0x80), block-E0000.data.at(code - 0xE0000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xE0100 <= code and code <= 0xE01EF {
    import "block-E0100.typ"
    (("Variation Selectors Supplement", 0xE0100, 0xF0), block-E0100.data.at(code - 0xE0100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xF0000 <= code and code <= 0xFFFFF {
    import "block-F0000.typ"
    (("Supplementary Private Use Area-A", 0xF0000, 0x10000), block-F0000.data.at(upper(str(code - 0xF0000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x100000 <= code and code <= 0x10FFFF {
    import "block-100000.typ"
    (("Supplementary Private Use Area-B", 0x100000, 0x10000), block-100000.data.at(upper(str(code - 0x100000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else {
    (none, (), ((), (), (), (), ()))
  }
}
