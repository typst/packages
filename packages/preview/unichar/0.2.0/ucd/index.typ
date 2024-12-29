#let get-data(code) = {
  import "aliases.typ"
  if 0x0 <= code and code <= 0x7f {
    import "block-0000.typ"
    (("Basic Latin", 0x0000, 0x80), block-0000.data.at(code - 0x0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x80 <= code and code <= 0xff {
    import "block-0080.typ"
    (("Latin-1 Supplement", 0x0080, 0x80), block-0080.data.at(code - 0x80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x100 <= code and code <= 0x17f {
    import "block-0100.typ"
    (("Latin Extended-A", 0x0100, 0x80), block-0100.data.at(code - 0x100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x180 <= code and code <= 0x24f {
    import "block-0180.typ"
    (("Latin Extended-B", 0x0180, 0xd0), block-0180.data.at(code - 0x180, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x250 <= code and code <= 0x2af {
    import "block-0250.typ"
    (("IPA Extensions", 0x0250, 0x60), block-0250.data.at(code - 0x250, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2b0 <= code and code <= 0x2ff {
    import "block-02B0.typ"
    (("Spacing Modifier Letters", 0x02B0, 0x50), block-02B0.data.at(code - 0x2b0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x300 <= code and code <= 0x36f {
    import "block-0300.typ"
    (("Combining Diacritical Marks", 0x0300, 0x70), block-0300.data.at(code - 0x300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x370 <= code and code <= 0x3ff {
    import "block-0370.typ"
    (("Greek and Coptic", 0x0370, 0x90), block-0370.data.at(code - 0x370, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x400 <= code and code <= 0x4ff {
    import "block-0400.typ"
    (("Cyrillic", 0x0400, 0x100), block-0400.data.at(code - 0x400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x500 <= code and code <= 0x52f {
    import "block-0500.typ"
    (("Cyrillic Supplement", 0x0500, 0x30), block-0500.data.at(code - 0x500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x530 <= code and code <= 0x58f {
    import "block-0530.typ"
    (("Armenian", 0x0530, 0x60), block-0530.data.at(code - 0x530, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x590 <= code and code <= 0x5ff {
    import "block-0590.typ"
    (("Hebrew", 0x0590, 0x70), block-0590.data.at(code - 0x590, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x600 <= code and code <= 0x6ff {
    import "block-0600.typ"
    (("Arabic", 0x0600, 0x100), block-0600.data.at(code - 0x600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x700 <= code and code <= 0x74f {
    import "block-0700.typ"
    (("Syriac", 0x0700, 0x50), block-0700.data.at(code - 0x700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x750 <= code and code <= 0x77f {
    import "block-0750.typ"
    (("Arabic Supplement", 0x0750, 0x30), block-0750.data.at(code - 0x750, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x780 <= code and code <= 0x7bf {
    import "block-0780.typ"
    (("Thaana", 0x0780, 0x40), block-0780.data.at(code - 0x780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x7c0 <= code and code <= 0x7ff {
    import "block-07C0.typ"
    (("NKo", 0x07C0, 0x40), block-07C0.data.at(code - 0x7c0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x800 <= code and code <= 0x83f {
    import "block-0800.typ"
    (("Samaritan", 0x0800, 0x40), block-0800.data.at(code - 0x800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x840 <= code and code <= 0x85f {
    import "block-0840.typ"
    (("Mandaic", 0x0840, 0x20), block-0840.data.at(code - 0x840, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x860 <= code and code <= 0x86f {
    import "block-0860.typ"
    (("Syriac Supplement", 0x0860, 0x10), block-0860.data.at(code - 0x860, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x870 <= code and code <= 0x89f {
    import "block-0870.typ"
    (("Arabic Extended-B", 0x0870, 0x30), block-0870.data.at(code - 0x870, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x8a0 <= code and code <= 0x8ff {
    import "block-08A0.typ"
    (("Arabic Extended-A", 0x08A0, 0x60), block-08A0.data.at(code - 0x8a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x900 <= code and code <= 0x97f {
    import "block-0900.typ"
    (("Devanagari", 0x0900, 0x80), block-0900.data.at(code - 0x900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x980 <= code and code <= 0x9ff {
    import "block-0980.typ"
    (("Bengali", 0x0980, 0x80), block-0980.data.at(code - 0x980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa00 <= code and code <= 0xa7f {
    import "block-0A00.typ"
    (("Gurmukhi", 0x0A00, 0x80), block-0A00.data.at(code - 0xa00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa80 <= code and code <= 0xaff {
    import "block-0A80.typ"
    (("Gujarati", 0x0A80, 0x80), block-0A80.data.at(code - 0xa80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xb00 <= code and code <= 0xb7f {
    import "block-0B00.typ"
    (("Oriya", 0x0B00, 0x80), block-0B00.data.at(code - 0xb00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xb80 <= code and code <= 0xbff {
    import "block-0B80.typ"
    (("Tamil", 0x0B80, 0x80), block-0B80.data.at(code - 0xb80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xc00 <= code and code <= 0xc7f {
    import "block-0C00.typ"
    (("Telugu", 0x0C00, 0x80), block-0C00.data.at(code - 0xc00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xc80 <= code and code <= 0xcff {
    import "block-0C80.typ"
    (("Kannada", 0x0C80, 0x80), block-0C80.data.at(code - 0xc80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xd00 <= code and code <= 0xd7f {
    import "block-0D00.typ"
    (("Malayalam", 0x0D00, 0x80), block-0D00.data.at(code - 0xd00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xd80 <= code and code <= 0xdff {
    import "block-0D80.typ"
    (("Sinhala", 0x0D80, 0x80), block-0D80.data.at(code - 0xd80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xe00 <= code and code <= 0xe7f {
    import "block-0E00.typ"
    (("Thai", 0x0E00, 0x80), block-0E00.data.at(code - 0xe00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xe80 <= code and code <= 0xeff {
    import "block-0E80.typ"
    (("Lao", 0x0E80, 0x80), block-0E80.data.at(code - 0xe80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xf00 <= code and code <= 0xfff {
    import "block-0F00.typ"
    (("Tibetan", 0x0F00, 0x100), block-0F00.data.at(code - 0xf00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1000 <= code and code <= 0x109f {
    import "block-1000.typ"
    (("Myanmar", 0x1000, 0xa0), block-1000.data.at(code - 0x1000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10a0 <= code and code <= 0x10ff {
    import "block-10A0.typ"
    (("Georgian", 0x10A0, 0x60), block-10A0.data.at(code - 0x10a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1100 <= code and code <= 0x11ff {
    import "block-1100.typ"
    (("Hangul Jamo", 0x1100, 0x100), block-1100.data.at(code - 0x1100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1200 <= code and code <= 0x137f {
    import "block-1200.typ"
    (("Ethiopic", 0x1200, 0x180), block-1200.data.at(code - 0x1200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1380 <= code and code <= 0x139f {
    import "block-1380.typ"
    (("Ethiopic Supplement", 0x1380, 0x20), block-1380.data.at(code - 0x1380, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13a0 <= code and code <= 0x13ff {
    import "block-13A0.typ"
    (("Cherokee", 0x13A0, 0x60), block-13A0.data.at(code - 0x13a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1400 <= code and code <= 0x167f {
    import "block-1400.typ"
    (("Unified Canadian Aboriginal Syllabics", 0x1400, 0x280), block-1400.data.at(code - 0x1400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1680 <= code and code <= 0x169f {
    import "block-1680.typ"
    (("Ogham", 0x1680, 0x20), block-1680.data.at(code - 0x1680, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16a0 <= code and code <= 0x16ff {
    import "block-16A0.typ"
    (("Runic", 0x16A0, 0x60), block-16A0.data.at(code - 0x16a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1700 <= code and code <= 0x171f {
    import "block-1700.typ"
    (("Tagalog", 0x1700, 0x20), block-1700.data.at(code - 0x1700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1720 <= code and code <= 0x173f {
    import "block-1720.typ"
    (("Hanunoo", 0x1720, 0x20), block-1720.data.at(code - 0x1720, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1740 <= code and code <= 0x175f {
    import "block-1740.typ"
    (("Buhid", 0x1740, 0x20), block-1740.data.at(code - 0x1740, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1760 <= code and code <= 0x177f {
    import "block-1760.typ"
    (("Tagbanwa", 0x1760, 0x20), block-1760.data.at(code - 0x1760, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1780 <= code and code <= 0x17ff {
    import "block-1780.typ"
    (("Khmer", 0x1780, 0x80), block-1780.data.at(code - 0x1780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1800 <= code and code <= 0x18af {
    import "block-1800.typ"
    (("Mongolian", 0x1800, 0xb0), block-1800.data.at(code - 0x1800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18b0 <= code and code <= 0x18ff {
    import "block-18B0.typ"
    (("Unified Canadian Aboriginal Syllabics Extended", 0x18B0, 0x50), block-18B0.data.at(code - 0x18b0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1900 <= code and code <= 0x194f {
    import "block-1900.typ"
    (("Limbu", 0x1900, 0x50), block-1900.data.at(code - 0x1900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1950 <= code and code <= 0x197f {
    import "block-1950.typ"
    (("Tai Le", 0x1950, 0x30), block-1950.data.at(code - 0x1950, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1980 <= code and code <= 0x19df {
    import "block-1980.typ"
    (("New Tai Lue", 0x1980, 0x60), block-1980.data.at(code - 0x1980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x19e0 <= code and code <= 0x19ff {
    import "block-19E0.typ"
    (("Khmer Symbols", 0x19E0, 0x20), block-19E0.data.at(code - 0x19e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1a00 <= code and code <= 0x1a1f {
    import "block-1A00.typ"
    (("Buginese", 0x1A00, 0x20), block-1A00.data.at(code - 0x1a00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1a20 <= code and code <= 0x1aaf {
    import "block-1A20.typ"
    (("Tai Tham", 0x1A20, 0x90), block-1A20.data.at(code - 0x1a20, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1ab0 <= code and code <= 0x1aff {
    import "block-1AB0.typ"
    (("Combining Diacritical Marks Extended", 0x1AB0, 0x50), block-1AB0.data.at(code - 0x1ab0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1b00 <= code and code <= 0x1b7f {
    import "block-1B00.typ"
    (("Balinese", 0x1B00, 0x80), block-1B00.data.at(code - 0x1b00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1b80 <= code and code <= 0x1bbf {
    import "block-1B80.typ"
    (("Sundanese", 0x1B80, 0x40), block-1B80.data.at(code - 0x1b80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1bc0 <= code and code <= 0x1bff {
    import "block-1BC0.typ"
    (("Batak", 0x1BC0, 0x40), block-1BC0.data.at(code - 0x1bc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1c00 <= code and code <= 0x1c4f {
    import "block-1C00.typ"
    (("Lepcha", 0x1C00, 0x50), block-1C00.data.at(code - 0x1c00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1c50 <= code and code <= 0x1c7f {
    import "block-1C50.typ"
    (("Ol Chiki", 0x1C50, 0x30), block-1C50.data.at(code - 0x1c50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1c80 <= code and code <= 0x1c8f {
    import "block-1C80.typ"
    (("Cyrillic Extended-C", 0x1C80, 0x10), block-1C80.data.at(code - 0x1c80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1c90 <= code and code <= 0x1cbf {
    import "block-1C90.typ"
    (("Georgian Extended", 0x1C90, 0x30), block-1C90.data.at(code - 0x1c90, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1cc0 <= code and code <= 0x1ccf {
    import "block-1CC0.typ"
    (("Sundanese Supplement", 0x1CC0, 0x10), block-1CC0.data.at(code - 0x1cc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1cd0 <= code and code <= 0x1cff {
    import "block-1CD0.typ"
    (("Vedic Extensions", 0x1CD0, 0x30), block-1CD0.data.at(code - 0x1cd0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d00 <= code and code <= 0x1d7f {
    import "block-1D00.typ"
    (("Phonetic Extensions", 0x1D00, 0x80), block-1D00.data.at(code - 0x1d00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d80 <= code and code <= 0x1dbf {
    import "block-1D80.typ"
    (("Phonetic Extensions Supplement", 0x1D80, 0x40), block-1D80.data.at(code - 0x1d80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1dc0 <= code and code <= 0x1dff {
    import "block-1DC0.typ"
    (("Combining Diacritical Marks Supplement", 0x1DC0, 0x40), block-1DC0.data.at(code - 0x1dc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e00 <= code and code <= 0x1eff {
    import "block-1E00.typ"
    (("Latin Extended Additional", 0x1E00, 0x100), block-1E00.data.at(code - 0x1e00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f00 <= code and code <= 0x1fff {
    import "block-1F00.typ"
    (("Greek Extended", 0x1F00, 0x100), block-1F00.data.at(code - 0x1f00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2000 <= code and code <= 0x206f {
    import "block-2000.typ"
    (("General Punctuation", 0x2000, 0x70), block-2000.data.at(code - 0x2000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2070 <= code and code <= 0x209f {
    import "block-2070.typ"
    (("Superscripts and Subscripts", 0x2070, 0x30), block-2070.data.at(code - 0x2070, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x20a0 <= code and code <= 0x20cf {
    import "block-20A0.typ"
    (("Currency Symbols", 0x20A0, 0x30), block-20A0.data.at(code - 0x20a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x20d0 <= code and code <= 0x20ff {
    import "block-20D0.typ"
    (("Combining Diacritical Marks for Symbols", 0x20D0, 0x30), block-20D0.data.at(code - 0x20d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2100 <= code and code <= 0x214f {
    import "block-2100.typ"
    (("Letterlike Symbols", 0x2100, 0x50), block-2100.data.at(code - 0x2100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2150 <= code and code <= 0x218f {
    import "block-2150.typ"
    (("Number Forms", 0x2150, 0x40), block-2150.data.at(code - 0x2150, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2190 <= code and code <= 0x21ff {
    import "block-2190.typ"
    (("Arrows", 0x2190, 0x70), block-2190.data.at(code - 0x2190, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2200 <= code and code <= 0x22ff {
    import "block-2200.typ"
    (("Mathematical Operators", 0x2200, 0x100), block-2200.data.at(code - 0x2200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2300 <= code and code <= 0x23ff {
    import "block-2300.typ"
    (("Miscellaneous Technical", 0x2300, 0x100), block-2300.data.at(code - 0x2300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2400 <= code and code <= 0x243f {
    import "block-2400.typ"
    (("Control Pictures", 0x2400, 0x40), block-2400.data.at(code - 0x2400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2440 <= code and code <= 0x245f {
    import "block-2440.typ"
    (("Optical Character Recognition", 0x2440, 0x20), block-2440.data.at(code - 0x2440, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2460 <= code and code <= 0x24ff {
    import "block-2460.typ"
    (("Enclosed Alphanumerics", 0x2460, 0xa0), block-2460.data.at(code - 0x2460, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2500 <= code and code <= 0x257f {
    import "block-2500.typ"
    (("Box Drawing", 0x2500, 0x80), block-2500.data.at(code - 0x2500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2580 <= code and code <= 0x259f {
    import "block-2580.typ"
    (("Block Elements", 0x2580, 0x20), block-2580.data.at(code - 0x2580, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x25a0 <= code and code <= 0x25ff {
    import "block-25A0.typ"
    (("Geometric Shapes", 0x25A0, 0x60), block-25A0.data.at(code - 0x25a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2600 <= code and code <= 0x26ff {
    import "block-2600.typ"
    (("Miscellaneous Symbols", 0x2600, 0x100), block-2600.data.at(code - 0x2600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2700 <= code and code <= 0x27bf {
    import "block-2700.typ"
    (("Dingbats", 0x2700, 0xc0), block-2700.data.at(code - 0x2700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x27c0 <= code and code <= 0x27ef {
    import "block-27C0.typ"
    (("Miscellaneous Mathematical Symbols-A", 0x27C0, 0x30), block-27C0.data.at(code - 0x27c0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x27f0 <= code and code <= 0x27ff {
    import "block-27F0.typ"
    (("Supplemental Arrows-A", 0x27F0, 0x10), block-27F0.data.at(code - 0x27f0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2800 <= code and code <= 0x28ff {
    import "block-2800.typ"
    (("Braille Patterns", 0x2800, 0x100), block-2800.data.at(code - 0x2800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2900 <= code and code <= 0x297f {
    import "block-2900.typ"
    (("Supplemental Arrows-B", 0x2900, 0x80), block-2900.data.at(code - 0x2900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2980 <= code and code <= 0x29ff {
    import "block-2980.typ"
    (("Miscellaneous Mathematical Symbols-B", 0x2980, 0x80), block-2980.data.at(code - 0x2980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2a00 <= code and code <= 0x2aff {
    import "block-2A00.typ"
    (("Supplemental Mathematical Operators", 0x2A00, 0x100), block-2A00.data.at(code - 0x2a00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2b00 <= code and code <= 0x2bff {
    import "block-2B00.typ"
    (("Miscellaneous Symbols and Arrows", 0x2B00, 0x100), block-2B00.data.at(code - 0x2b00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2c00 <= code and code <= 0x2c5f {
    import "block-2C00.typ"
    (("Glagolitic", 0x2C00, 0x60), block-2C00.data.at(code - 0x2c00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2c60 <= code and code <= 0x2c7f {
    import "block-2C60.typ"
    (("Latin Extended-C", 0x2C60, 0x20), block-2C60.data.at(code - 0x2c60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2c80 <= code and code <= 0x2cff {
    import "block-2C80.typ"
    (("Coptic", 0x2C80, 0x80), block-2C80.data.at(code - 0x2c80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2d00 <= code and code <= 0x2d2f {
    import "block-2D00.typ"
    (("Georgian Supplement", 0x2D00, 0x30), block-2D00.data.at(code - 0x2d00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2d30 <= code and code <= 0x2d7f {
    import "block-2D30.typ"
    (("Tifinagh", 0x2D30, 0x50), block-2D30.data.at(code - 0x2d30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2d80 <= code and code <= 0x2ddf {
    import "block-2D80.typ"
    (("Ethiopic Extended", 0x2D80, 0x60), block-2D80.data.at(code - 0x2d80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2de0 <= code and code <= 0x2dff {
    import "block-2DE0.typ"
    (("Cyrillic Extended-A", 0x2DE0, 0x20), block-2DE0.data.at(code - 0x2de0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2e00 <= code and code <= 0x2e7f {
    import "block-2E00.typ"
    (("Supplemental Punctuation", 0x2E00, 0x80), block-2E00.data.at(code - 0x2e00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2e80 <= code and code <= 0x2eff {
    import "block-2E80.typ"
    (("CJK Radicals Supplement", 0x2E80, 0x80), block-2E80.data.at(code - 0x2e80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2f00 <= code and code <= 0x2fdf {
    import "block-2F00.typ"
    (("Kangxi Radicals", 0x2F00, 0xe0), block-2F00.data.at(code - 0x2f00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2ff0 <= code and code <= 0x2fff {
    import "block-2FF0.typ"
    (("Ideographic Description Characters", 0x2FF0, 0x10), block-2FF0.data.at(code - 0x2ff0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3000 <= code and code <= 0x303f {
    import "block-3000.typ"
    (("CJK Symbols and Punctuation", 0x3000, 0x40), block-3000.data.at(code - 0x3000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3040 <= code and code <= 0x309f {
    import "block-3040.typ"
    (("Hiragana", 0x3040, 0x60), block-3040.data.at(code - 0x3040, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x30a0 <= code and code <= 0x30ff {
    import "block-30A0.typ"
    (("Katakana", 0x30A0, 0x60), block-30A0.data.at(code - 0x30a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3100 <= code and code <= 0x312f {
    import "block-3100.typ"
    (("Bopomofo", 0x3100, 0x30), block-3100.data.at(code - 0x3100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3130 <= code and code <= 0x318f {
    import "block-3130.typ"
    (("Hangul Compatibility Jamo", 0x3130, 0x60), block-3130.data.at(code - 0x3130, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3190 <= code and code <= 0x319f {
    import "block-3190.typ"
    (("Kanbun", 0x3190, 0x10), block-3190.data.at(code - 0x3190, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31a0 <= code and code <= 0x31bf {
    import "block-31A0.typ"
    (("Bopomofo Extended", 0x31A0, 0x20), block-31A0.data.at(code - 0x31a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31c0 <= code and code <= 0x31ef {
    import "block-31C0.typ"
    (("CJK Strokes", 0x31C0, 0x30), block-31C0.data.at(code - 0x31c0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31f0 <= code and code <= 0x31ff {
    import "block-31F0.typ"
    (("Katakana Phonetic Extensions", 0x31F0, 0x10), block-31F0.data.at(code - 0x31f0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3200 <= code and code <= 0x32ff {
    import "block-3200.typ"
    (("Enclosed CJK Letters and Months", 0x3200, 0x100), block-3200.data.at(code - 0x3200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3300 <= code and code <= 0x33ff {
    import "block-3300.typ"
    (("CJK Compatibility", 0x3300, 0x100), block-3300.data.at(code - 0x3300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x3400 <= code and code <= 0x4dbf {
    import "block-3400.typ"
    (("CJK Unified Ideographs Extension A", 0x3400, 0x19c0), block-3400.data.at(upper(str(code - 0x3400, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x4dc0 <= code and code <= 0x4dff {
    import "block-4DC0.typ"
    (("Yijing Hexagram Symbols", 0x4DC0, 0x40), block-4DC0.data.at(code - 0x4dc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x4e00 <= code and code <= 0x9fff {
    import "block-4E00.typ"
    (("CJK Unified Ideographs", 0x4E00, 0x5200), block-4E00.data.at(upper(str(code - 0x4e00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa000 <= code and code <= 0xa48f {
    import "block-A000.typ"
    (("Yi Syllables", 0xA000, 0x490), block-A000.data.at(code - 0xa000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa490 <= code and code <= 0xa4cf {
    import "block-A490.typ"
    (("Yi Radicals", 0xA490, 0x40), block-A490.data.at(code - 0xa490, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa4d0 <= code and code <= 0xa4ff {
    import "block-A4D0.typ"
    (("Lisu", 0xA4D0, 0x30), block-A4D0.data.at(code - 0xa4d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa500 <= code and code <= 0xa63f {
    import "block-A500.typ"
    (("Vai", 0xA500, 0x140), block-A500.data.at(code - 0xa500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa640 <= code and code <= 0xa69f {
    import "block-A640.typ"
    (("Cyrillic Extended-B", 0xA640, 0x60), block-A640.data.at(code - 0xa640, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa6a0 <= code and code <= 0xa6ff {
    import "block-A6A0.typ"
    (("Bamum", 0xA6A0, 0x60), block-A6A0.data.at(code - 0xa6a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa700 <= code and code <= 0xa71f {
    import "block-A700.typ"
    (("Modifier Tone Letters", 0xA700, 0x20), block-A700.data.at(code - 0xa700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa720 <= code and code <= 0xa7ff {
    import "block-A720.typ"
    (("Latin Extended-D", 0xA720, 0xe0), block-A720.data.at(code - 0xa720, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa800 <= code and code <= 0xa82f {
    import "block-A800.typ"
    (("Syloti Nagri", 0xA800, 0x30), block-A800.data.at(code - 0xa800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa830 <= code and code <= 0xa83f {
    import "block-A830.typ"
    (("Common Indic Number Forms", 0xA830, 0x10), block-A830.data.at(code - 0xa830, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa840 <= code and code <= 0xa87f {
    import "block-A840.typ"
    (("Phags-pa", 0xA840, 0x40), block-A840.data.at(code - 0xa840, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa880 <= code and code <= 0xa8df {
    import "block-A880.typ"
    (("Saurashtra", 0xA880, 0x60), block-A880.data.at(code - 0xa880, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa8e0 <= code and code <= 0xa8ff {
    import "block-A8E0.typ"
    (("Devanagari Extended", 0xA8E0, 0x20), block-A8E0.data.at(code - 0xa8e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa900 <= code and code <= 0xa92f {
    import "block-A900.typ"
    (("Kayah Li", 0xA900, 0x30), block-A900.data.at(code - 0xa900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa930 <= code and code <= 0xa95f {
    import "block-A930.typ"
    (("Rejang", 0xA930, 0x30), block-A930.data.at(code - 0xa930, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa960 <= code and code <= 0xa97f {
    import "block-A960.typ"
    (("Hangul Jamo Extended-A", 0xA960, 0x20), block-A960.data.at(code - 0xa960, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa980 <= code and code <= 0xa9df {
    import "block-A980.typ"
    (("Javanese", 0xA980, 0x60), block-A980.data.at(code - 0xa980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xa9e0 <= code and code <= 0xa9ff {
    import "block-A9E0.typ"
    (("Myanmar Extended-B", 0xA9E0, 0x20), block-A9E0.data.at(code - 0xa9e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xaa00 <= code and code <= 0xaa5f {
    import "block-AA00.typ"
    (("Cham", 0xAA00, 0x60), block-AA00.data.at(code - 0xaa00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xaa60 <= code and code <= 0xaa7f {
    import "block-AA60.typ"
    (("Myanmar Extended-A", 0xAA60, 0x20), block-AA60.data.at(code - 0xaa60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xaa80 <= code and code <= 0xaadf {
    import "block-AA80.typ"
    (("Tai Viet", 0xAA80, 0x60), block-AA80.data.at(code - 0xaa80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xaae0 <= code and code <= 0xaaff {
    import "block-AAE0.typ"
    (("Meetei Mayek Extensions", 0xAAE0, 0x20), block-AAE0.data.at(code - 0xaae0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xab00 <= code and code <= 0xab2f {
    import "block-AB00.typ"
    (("Ethiopic Extended-A", 0xAB00, 0x30), block-AB00.data.at(code - 0xab00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xab30 <= code and code <= 0xab6f {
    import "block-AB30.typ"
    (("Latin Extended-E", 0xAB30, 0x40), block-AB30.data.at(code - 0xab30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xab70 <= code and code <= 0xabbf {
    import "block-AB70.typ"
    (("Cherokee Supplement", 0xAB70, 0x50), block-AB70.data.at(code - 0xab70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xabc0 <= code and code <= 0xabff {
    import "block-ABC0.typ"
    (("Meetei Mayek", 0xABC0, 0x40), block-ABC0.data.at(code - 0xabc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xac00 <= code and code <= 0xd7af {
    import "block-AC00.typ"
    (("Hangul Syllables", 0xAC00, 0x2bb0), block-AC00.data.at(upper(str(code - 0xac00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xd7b0 <= code and code <= 0xd7ff {
    import "block-D7B0.typ"
    (("Hangul Jamo Extended-B", 0xD7B0, 0x50), block-D7B0.data.at(code - 0xd7b0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xd800 <= code and code <= 0xdb7f {
    import "block-D800.typ"
    (("High Surrogates", 0xD800, 0x380), block-D800.data.at(upper(str(code - 0xd800, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xdb80 <= code and code <= 0xdbff {
    import "block-DB80.typ"
    (("High Private Use Surrogates", 0xDB80, 0x80), block-DB80.data.at(upper(str(code - 0xdb80, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xdc00 <= code and code <= 0xdfff {
    import "block-DC00.typ"
    (("Low Surrogates", 0xDC00, 0x400), block-DC00.data.at(upper(str(code - 0xdc00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xe000 <= code and code <= 0xf8ff {
    import "block-E000.typ"
    (("Private Use Area", 0xE000, 0x1900), block-E000.data.at(upper(str(code - 0xe000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xf900 <= code and code <= 0xfaff {
    import "block-F900.typ"
    (("CJK Compatibility Ideographs", 0xF900, 0x200), block-F900.data.at(code - 0xf900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfb00 <= code and code <= 0xfb4f {
    import "block-FB00.typ"
    (("Alphabetic Presentation Forms", 0xFB00, 0x50), block-FB00.data.at(code - 0xfb00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfb50 <= code and code <= 0xfdff {
    import "block-FB50.typ"
    (("Arabic Presentation Forms-A", 0xFB50, 0x2b0), block-FB50.data.at(code - 0xfb50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfe00 <= code and code <= 0xfe0f {
    import "block-FE00.typ"
    (("Variation Selectors", 0xFE00, 0x10), block-FE00.data.at(code - 0xfe00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfe10 <= code and code <= 0xfe1f {
    import "block-FE10.typ"
    (("Vertical Forms", 0xFE10, 0x10), block-FE10.data.at(code - 0xfe10, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfe20 <= code and code <= 0xfe2f {
    import "block-FE20.typ"
    (("Combining Half Marks", 0xFE20, 0x10), block-FE20.data.at(code - 0xfe20, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfe30 <= code and code <= 0xfe4f {
    import "block-FE30.typ"
    (("CJK Compatibility Forms", 0xFE30, 0x20), block-FE30.data.at(code - 0xfe30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfe50 <= code and code <= 0xfe6f {
    import "block-FE50.typ"
    (("Small Form Variants", 0xFE50, 0x20), block-FE50.data.at(code - 0xfe50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfe70 <= code and code <= 0xfeff {
    import "block-FE70.typ"
    (("Arabic Presentation Forms-B", 0xFE70, 0x90), block-FE70.data.at(code - 0xfe70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xff00 <= code and code <= 0xffef {
    import "block-FF00.typ"
    (("Halfwidth and Fullwidth Forms", 0xFF00, 0xf0), block-FF00.data.at(code - 0xff00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xfff0 <= code and code <= 0xffff {
    import "block-FFF0.typ"
    (("Specials", 0xFFF0, 0x10), block-FFF0.data.at(upper(str(code - 0xfff0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10000 <= code and code <= 0x1007f {
    import "block-10000.typ"
    (("Linear B Syllabary", 0x10000, 0x80), block-10000.data.at(code - 0x10000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10080 <= code and code <= 0x100ff {
    import "block-10080.typ"
    (("Linear B Ideograms", 0x10080, 0x80), block-10080.data.at(code - 0x10080, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10100 <= code and code <= 0x1013f {
    import "block-10100.typ"
    (("Aegean Numbers", 0x10100, 0x40), block-10100.data.at(code - 0x10100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10140 <= code and code <= 0x1018f {
    import "block-10140.typ"
    (("Ancient Greek Numbers", 0x10140, 0x50), block-10140.data.at(code - 0x10140, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10190 <= code and code <= 0x101cf {
    import "block-10190.typ"
    (("Ancient Symbols", 0x10190, 0x40), block-10190.data.at(code - 0x10190, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x101d0 <= code and code <= 0x101ff {
    import "block-101D0.typ"
    (("Phaistos Disc", 0x101D0, 0x30), block-101D0.data.at(code - 0x101d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10280 <= code and code <= 0x1029f {
    import "block-10280.typ"
    (("Lycian", 0x10280, 0x20), block-10280.data.at(code - 0x10280, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x102a0 <= code and code <= 0x102df {
    import "block-102A0.typ"
    (("Carian", 0x102A0, 0x40), block-102A0.data.at(code - 0x102a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x102e0 <= code and code <= 0x102ff {
    import "block-102E0.typ"
    (("Coptic Epact Numbers", 0x102E0, 0x20), block-102E0.data.at(code - 0x102e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10300 <= code and code <= 0x1032f {
    import "block-10300.typ"
    (("Old Italic", 0x10300, 0x30), block-10300.data.at(code - 0x10300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10330 <= code and code <= 0x1034f {
    import "block-10330.typ"
    (("Gothic", 0x10330, 0x20), block-10330.data.at(code - 0x10330, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10350 <= code and code <= 0x1037f {
    import "block-10350.typ"
    (("Old Permic", 0x10350, 0x30), block-10350.data.at(code - 0x10350, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10380 <= code and code <= 0x1039f {
    import "block-10380.typ"
    (("Ugaritic", 0x10380, 0x20), block-10380.data.at(code - 0x10380, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x103a0 <= code and code <= 0x103df {
    import "block-103A0.typ"
    (("Old Persian", 0x103A0, 0x40), block-103A0.data.at(code - 0x103a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10400 <= code and code <= 0x1044f {
    import "block-10400.typ"
    (("Deseret", 0x10400, 0x50), block-10400.data.at(code - 0x10400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10450 <= code and code <= 0x1047f {
    import "block-10450.typ"
    (("Shavian", 0x10450, 0x30), block-10450.data.at(code - 0x10450, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10480 <= code and code <= 0x104af {
    import "block-10480.typ"
    (("Osmanya", 0x10480, 0x30), block-10480.data.at(code - 0x10480, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x104b0 <= code and code <= 0x104ff {
    import "block-104B0.typ"
    (("Osage", 0x104B0, 0x50), block-104B0.data.at(code - 0x104b0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10500 <= code and code <= 0x1052f {
    import "block-10500.typ"
    (("Elbasan", 0x10500, 0x30), block-10500.data.at(code - 0x10500, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10530 <= code and code <= 0x1056f {
    import "block-10530.typ"
    (("Caucasian Albanian", 0x10530, 0x40), block-10530.data.at(code - 0x10530, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10570 <= code and code <= 0x105bf {
    import "block-10570.typ"
    (("Vithkuqi", 0x10570, 0x50), block-10570.data.at(code - 0x10570, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x105c0 <= code and code <= 0x105ff {
    import "block-105C0.typ"
    (("Todhri", 0x105C0, 0x40), block-105C0.data.at(code - 0x105c0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10600 <= code and code <= 0x1077f {
    import "block-10600.typ"
    (("Linear A", 0x10600, 0x180), block-10600.data.at(code - 0x10600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10780 <= code and code <= 0x107bf {
    import "block-10780.typ"
    (("Latin Extended-F", 0x10780, 0x40), block-10780.data.at(code - 0x10780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10800 <= code and code <= 0x1083f {
    import "block-10800.typ"
    (("Cypriot Syllabary", 0x10800, 0x40), block-10800.data.at(code - 0x10800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10840 <= code and code <= 0x1085f {
    import "block-10840.typ"
    (("Imperial Aramaic", 0x10840, 0x20), block-10840.data.at(code - 0x10840, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10860 <= code and code <= 0x1087f {
    import "block-10860.typ"
    (("Palmyrene", 0x10860, 0x20), block-10860.data.at(code - 0x10860, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10880 <= code and code <= 0x108af {
    import "block-10880.typ"
    (("Nabataean", 0x10880, 0x30), block-10880.data.at(code - 0x10880, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x108e0 <= code and code <= 0x108ff {
    import "block-108E0.typ"
    (("Hatran", 0x108E0, 0x20), block-108E0.data.at(code - 0x108e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10900 <= code and code <= 0x1091f {
    import "block-10900.typ"
    (("Phoenician", 0x10900, 0x20), block-10900.data.at(code - 0x10900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10920 <= code and code <= 0x1093f {
    import "block-10920.typ"
    (("Lydian", 0x10920, 0x20), block-10920.data.at(code - 0x10920, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10980 <= code and code <= 0x1099f {
    import "block-10980.typ"
    (("Meroitic Hieroglyphs", 0x10980, 0x20), block-10980.data.at(code - 0x10980, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x109a0 <= code and code <= 0x109ff {
    import "block-109A0.typ"
    (("Meroitic Cursive", 0x109A0, 0x60), block-109A0.data.at(code - 0x109a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10a00 <= code and code <= 0x10a5f {
    import "block-10A00.typ"
    (("Kharoshthi", 0x10A00, 0x60), block-10A00.data.at(code - 0x10a00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10a60 <= code and code <= 0x10a7f {
    import "block-10A60.typ"
    (("Old South Arabian", 0x10A60, 0x20), block-10A60.data.at(code - 0x10a60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10a80 <= code and code <= 0x10a9f {
    import "block-10A80.typ"
    (("Old North Arabian", 0x10A80, 0x20), block-10A80.data.at(code - 0x10a80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10ac0 <= code and code <= 0x10aff {
    import "block-10AC0.typ"
    (("Manichaean", 0x10AC0, 0x40), block-10AC0.data.at(code - 0x10ac0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10b00 <= code and code <= 0x10b3f {
    import "block-10B00.typ"
    (("Avestan", 0x10B00, 0x40), block-10B00.data.at(code - 0x10b00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10b40 <= code and code <= 0x10b5f {
    import "block-10B40.typ"
    (("Inscriptional Parthian", 0x10B40, 0x20), block-10B40.data.at(code - 0x10b40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10b60 <= code and code <= 0x10b7f {
    import "block-10B60.typ"
    (("Inscriptional Pahlavi", 0x10B60, 0x20), block-10B60.data.at(code - 0x10b60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10b80 <= code and code <= 0x10baf {
    import "block-10B80.typ"
    (("Psalter Pahlavi", 0x10B80, 0x30), block-10B80.data.at(code - 0x10b80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10c00 <= code and code <= 0x10c4f {
    import "block-10C00.typ"
    (("Old Turkic", 0x10C00, 0x50), block-10C00.data.at(code - 0x10c00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10c80 <= code and code <= 0x10cff {
    import "block-10C80.typ"
    (("Old Hungarian", 0x10C80, 0x80), block-10C80.data.at(code - 0x10c80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10d00 <= code and code <= 0x10d3f {
    import "block-10D00.typ"
    (("Hanifi Rohingya", 0x10D00, 0x40), block-10D00.data.at(code - 0x10d00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10d40 <= code and code <= 0x10d8f {
    import "block-10D40.typ"
    (("Garay", 0x10D40, 0x50), block-10D40.data.at(code - 0x10d40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10e60 <= code and code <= 0x10e7f {
    import "block-10E60.typ"
    (("Rumi Numeral Symbols", 0x10E60, 0x20), block-10E60.data.at(code - 0x10e60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10e80 <= code and code <= 0x10ebf {
    import "block-10E80.typ"
    (("Yezidi", 0x10E80, 0x40), block-10E80.data.at(code - 0x10e80, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10ec0 <= code and code <= 0x10eff {
    import "block-10EC0.typ"
    (("Arabic Extended-C", 0x10EC0, 0x40), block-10EC0.data.at(upper(str(code - 0x10ec0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10f00 <= code and code <= 0x10f2f {
    import "block-10F00.typ"
    (("Old Sogdian", 0x10F00, 0x30), block-10F00.data.at(code - 0x10f00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10f30 <= code and code <= 0x10f6f {
    import "block-10F30.typ"
    (("Sogdian", 0x10F30, 0x40), block-10F30.data.at(code - 0x10f30, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10f70 <= code and code <= 0x10faf {
    import "block-10F70.typ"
    (("Old Uyghur", 0x10F70, 0x40), block-10F70.data.at(code - 0x10f70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10fb0 <= code and code <= 0x10fdf {
    import "block-10FB0.typ"
    (("Chorasmian", 0x10FB0, 0x30), block-10FB0.data.at(code - 0x10fb0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x10fe0 <= code and code <= 0x10fff {
    import "block-10FE0.typ"
    (("Elymaic", 0x10FE0, 0x20), block-10FE0.data.at(code - 0x10fe0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11000 <= code and code <= 0x1107f {
    import "block-11000.typ"
    (("Brahmi", 0x11000, 0x80), block-11000.data.at(code - 0x11000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11080 <= code and code <= 0x110cf {
    import "block-11080.typ"
    (("Kaithi", 0x11080, 0x50), block-11080.data.at(code - 0x11080, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x110d0 <= code and code <= 0x110ff {
    import "block-110D0.typ"
    (("Sora Sompeng", 0x110D0, 0x30), block-110D0.data.at(code - 0x110d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11100 <= code and code <= 0x1114f {
    import "block-11100.typ"
    (("Chakma", 0x11100, 0x50), block-11100.data.at(code - 0x11100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11150 <= code and code <= 0x1117f {
    import "block-11150.typ"
    (("Mahajani", 0x11150, 0x30), block-11150.data.at(code - 0x11150, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11180 <= code and code <= 0x111df {
    import "block-11180.typ"
    (("Sharada", 0x11180, 0x60), block-11180.data.at(code - 0x11180, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x111e0 <= code and code <= 0x111ff {
    import "block-111E0.typ"
    (("Sinhala Archaic Numbers", 0x111E0, 0x20), block-111E0.data.at(code - 0x111e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11200 <= code and code <= 0x1124f {
    import "block-11200.typ"
    (("Khojki", 0x11200, 0x50), block-11200.data.at(code - 0x11200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11280 <= code and code <= 0x112af {
    import "block-11280.typ"
    (("Multani", 0x11280, 0x30), block-11280.data.at(code - 0x11280, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x112b0 <= code and code <= 0x112ff {
    import "block-112B0.typ"
    (("Khudawadi", 0x112B0, 0x50), block-112B0.data.at(code - 0x112b0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11300 <= code and code <= 0x1137f {
    import "block-11300.typ"
    (("Grantha", 0x11300, 0x80), block-11300.data.at(code - 0x11300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11380 <= code and code <= 0x113ff {
    import "block-11380.typ"
    (("Tulu-Tigalari", 0x11380, 0x80), block-11380.data.at(code - 0x11380, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11400 <= code and code <= 0x1147f {
    import "block-11400.typ"
    (("Newa", 0x11400, 0x80), block-11400.data.at(code - 0x11400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11480 <= code and code <= 0x114df {
    import "block-11480.typ"
    (("Tirhuta", 0x11480, 0x60), block-11480.data.at(code - 0x11480, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11580 <= code and code <= 0x115ff {
    import "block-11580.typ"
    (("Siddham", 0x11580, 0x80), block-11580.data.at(code - 0x11580, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11600 <= code and code <= 0x1165f {
    import "block-11600.typ"
    (("Modi", 0x11600, 0x60), block-11600.data.at(code - 0x11600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11660 <= code and code <= 0x1167f {
    import "block-11660.typ"
    (("Mongolian Supplement", 0x11660, 0x20), block-11660.data.at(code - 0x11660, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11680 <= code and code <= 0x116cf {
    import "block-11680.typ"
    (("Takri", 0x11680, 0x50), block-11680.data.at(code - 0x11680, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x116d0 <= code and code <= 0x116ff {
    import "block-116D0.typ"
    (("Myanmar Extended-C", 0x116D0, 0x30), block-116D0.data.at(code - 0x116d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11700 <= code and code <= 0x1174f {
    import "block-11700.typ"
    (("Ahom", 0x11700, 0x50), block-11700.data.at(code - 0x11700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11800 <= code and code <= 0x1184f {
    import "block-11800.typ"
    (("Dogra", 0x11800, 0x50), block-11800.data.at(code - 0x11800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x118a0 <= code and code <= 0x118ff {
    import "block-118A0.typ"
    (("Warang Citi", 0x118A0, 0x60), block-118A0.data.at(code - 0x118a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11900 <= code and code <= 0x1195f {
    import "block-11900.typ"
    (("Dives Akuru", 0x11900, 0x60), block-11900.data.at(code - 0x11900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x119a0 <= code and code <= 0x119ff {
    import "block-119A0.typ"
    (("Nandinagari", 0x119A0, 0x60), block-119A0.data.at(code - 0x119a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11a00 <= code and code <= 0x11a4f {
    import "block-11A00.typ"
    (("Zanabazar Square", 0x11A00, 0x50), block-11A00.data.at(code - 0x11a00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11a50 <= code and code <= 0x11aaf {
    import "block-11A50.typ"
    (("Soyombo", 0x11A50, 0x60), block-11A50.data.at(code - 0x11a50, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11ab0 <= code and code <= 0x11abf {
    import "block-11AB0.typ"
    (("Unified Canadian Aboriginal Syllabics Extended-A", 0x11AB0, 0x10), block-11AB0.data.at(code - 0x11ab0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11ac0 <= code and code <= 0x11aff {
    import "block-11AC0.typ"
    (("Pau Cin Hau", 0x11AC0, 0x40), block-11AC0.data.at(code - 0x11ac0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11b00 <= code and code <= 0x11b5f {
    import "block-11B00.typ"
    (("Devanagari Extended-A", 0x11B00, 0x60), block-11B00.data.at(code - 0x11b00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11bc0 <= code and code <= 0x11bff {
    import "block-11BC0.typ"
    (("Sunuwar", 0x11BC0, 0x40), block-11BC0.data.at(code - 0x11bc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11c00 <= code and code <= 0x11c6f {
    import "block-11C00.typ"
    (("Bhaiksuki", 0x11C00, 0x70), block-11C00.data.at(code - 0x11c00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11c70 <= code and code <= 0x11cbf {
    import "block-11C70.typ"
    (("Marchen", 0x11C70, 0x50), block-11C70.data.at(code - 0x11c70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11d00 <= code and code <= 0x11d5f {
    import "block-11D00.typ"
    (("Masaram Gondi", 0x11D00, 0x60), block-11D00.data.at(code - 0x11d00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11d60 <= code and code <= 0x11daf {
    import "block-11D60.typ"
    (("Gunjala Gondi", 0x11D60, 0x50), block-11D60.data.at(code - 0x11d60, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11ee0 <= code and code <= 0x11eff {
    import "block-11EE0.typ"
    (("Makasar", 0x11EE0, 0x20), block-11EE0.data.at(code - 0x11ee0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11f00 <= code and code <= 0x11f5f {
    import "block-11F00.typ"
    (("Kawi", 0x11F00, 0x60), block-11F00.data.at(code - 0x11f00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11fb0 <= code and code <= 0x11fbf {
    import "block-11FB0.typ"
    (("Lisu Supplement", 0x11FB0, 0x10), block-11FB0.data.at(code - 0x11fb0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x11fc0 <= code and code <= 0x11fff {
    import "block-11FC0.typ"
    (("Tamil Supplement", 0x11FC0, 0x40), block-11FC0.data.at(code - 0x11fc0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12000 <= code and code <= 0x123ff {
    import "block-12000.typ"
    (("Cuneiform", 0x12000, 0x400), block-12000.data.at(code - 0x12000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12400 <= code and code <= 0x1247f {
    import "block-12400.typ"
    (("Cuneiform Numbers and Punctuation", 0x12400, 0x80), block-12400.data.at(code - 0x12400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12480 <= code and code <= 0x1254f {
    import "block-12480.typ"
    (("Early Dynastic Cuneiform", 0x12480, 0xd0), block-12480.data.at(code - 0x12480, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x12f90 <= code and code <= 0x12fff {
    import "block-12F90.typ"
    (("Cypro-Minoan", 0x12F90, 0x70), block-12F90.data.at(code - 0x12f90, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13000 <= code and code <= 0x1342f {
    import "block-13000.typ"
    (("Egyptian Hieroglyphs", 0x13000, 0x430), block-13000.data.at(code - 0x13000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13430 <= code and code <= 0x1345f {
    import "block-13430.typ"
    (("Egyptian Hieroglyph Format Controls", 0x13430, 0x30), block-13430.data.at(code - 0x13430, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x13460 <= code and code <= 0x143ff {
    import "block-13460.typ"
    (("Egyptian Hieroglyphs Extended-A", 0x13460, 0xfa0), block-13460.data.at(code - 0x13460, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x14400 <= code and code <= 0x1467f {
    import "block-14400.typ"
    (("Anatolian Hieroglyphs", 0x14400, 0x280), block-14400.data.at(code - 0x14400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16100 <= code and code <= 0x1613f {
    import "block-16100.typ"
    (("Gurung Khema", 0x16100, 0x40), block-16100.data.at(code - 0x16100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16800 <= code and code <= 0x16a3f {
    import "block-16800.typ"
    (("Bamum Supplement", 0x16800, 0x240), block-16800.data.at(code - 0x16800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16a40 <= code and code <= 0x16a6f {
    import "block-16A40.typ"
    (("Mro", 0x16A40, 0x30), block-16A40.data.at(code - 0x16a40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16a70 <= code and code <= 0x16acf {
    import "block-16A70.typ"
    (("Tangsa", 0x16A70, 0x60), block-16A70.data.at(code - 0x16a70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16ad0 <= code and code <= 0x16aff {
    import "block-16AD0.typ"
    (("Bassa Vah", 0x16AD0, 0x30), block-16AD0.data.at(code - 0x16ad0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16b00 <= code and code <= 0x16b8f {
    import "block-16B00.typ"
    (("Pahawh Hmong", 0x16B00, 0x90), block-16B00.data.at(code - 0x16b00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16d40 <= code and code <= 0x16d7f {
    import "block-16D40.typ"
    (("Kirat Rai", 0x16D40, 0x40), block-16D40.data.at(code - 0x16d40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16e40 <= code and code <= 0x16e9f {
    import "block-16E40.typ"
    (("Medefaidrin", 0x16E40, 0x60), block-16E40.data.at(code - 0x16e40, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16f00 <= code and code <= 0x16f9f {
    import "block-16F00.typ"
    (("Miao", 0x16F00, 0xa0), block-16F00.data.at(code - 0x16f00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x16fe0 <= code and code <= 0x16fff {
    import "block-16FE0.typ"
    (("Ideographic Symbols and Punctuation", 0x16FE0, 0x20), block-16FE0.data.at(upper(str(code - 0x16fe0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x17000 <= code and code <= 0x187ff {
    import "block-17000.typ"
    (("Tangut", 0x17000, 0x1800), block-17000.data.at(upper(str(code - 0x17000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18800 <= code and code <= 0x18aff {
    import "block-18800.typ"
    (("Tangut Components", 0x18800, 0x300), block-18800.data.at(code - 0x18800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18b00 <= code and code <= 0x18cff {
    import "block-18B00.typ"
    (("Khitan Small Script", 0x18B00, 0x200), block-18B00.data.at(code - 0x18b00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x18d00 <= code and code <= 0x18d7f {
    import "block-18D00.typ"
    (("Tangut Supplement", 0x18D00, 0x80), block-18D00.data.at(upper(str(code - 0x18d00, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1aff0 <= code and code <= 0x1afff {
    import "block-1AFF0.typ"
    (("Kana Extended-B", 0x1AFF0, 0x10), block-1AFF0.data.at(code - 0x1aff0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1b000 <= code and code <= 0x1b0ff {
    import "block-1B000.typ"
    (("Kana Supplement", 0x1B000, 0x100), block-1B000.data.at(code - 0x1b000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1b100 <= code and code <= 0x1b12f {
    import "block-1B100.typ"
    (("Kana Extended-A", 0x1B100, 0x30), block-1B100.data.at(code - 0x1b100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1b130 <= code and code <= 0x1b16f {
    import "block-1B130.typ"
    (("Small Kana Extension", 0x1B130, 0x40), block-1B130.data.at(upper(str(code - 0x1b130, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1b170 <= code and code <= 0x1b2ff {
    import "block-1B170.typ"
    (("Nushu", 0x1B170, 0x190), block-1B170.data.at(code - 0x1b170, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1bc00 <= code and code <= 0x1bc9f {
    import "block-1BC00.typ"
    (("Duployan", 0x1BC00, 0xa0), block-1BC00.data.at(code - 0x1bc00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1bca0 <= code and code <= 0x1bcaf {
    import "block-1BCA0.typ"
    (("Shorthand Format Controls", 0x1BCA0, 0x10), block-1BCA0.data.at(code - 0x1bca0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1cc00 <= code and code <= 0x1cebf {
    import "block-1CC00.typ"
    (("Symbols for Legacy Computing Supplement", 0x1CC00, 0x2c0), block-1CC00.data.at(code - 0x1cc00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1cf00 <= code and code <= 0x1cfcf {
    import "block-1CF00.typ"
    (("Znamenny Musical Notation", 0x1CF00, 0xd0), block-1CF00.data.at(code - 0x1cf00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d000 <= code and code <= 0x1d0ff {
    import "block-1D000.typ"
    (("Byzantine Musical Symbols", 0x1D000, 0x100), block-1D000.data.at(code - 0x1d000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d100 <= code and code <= 0x1d1ff {
    import "block-1D100.typ"
    (("Musical Symbols", 0x1D100, 0x100), block-1D100.data.at(code - 0x1d100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d200 <= code and code <= 0x1d24f {
    import "block-1D200.typ"
    (("Ancient Greek Musical Notation", 0x1D200, 0x50), block-1D200.data.at(code - 0x1d200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d2c0 <= code and code <= 0x1d2df {
    import "block-1D2C0.typ"
    (("Kaktovik Numerals", 0x1D2C0, 0x20), block-1D2C0.data.at(code - 0x1d2c0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d2e0 <= code and code <= 0x1d2ff {
    import "block-1D2E0.typ"
    (("Mayan Numerals", 0x1D2E0, 0x20), block-1D2E0.data.at(code - 0x1d2e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d300 <= code and code <= 0x1d35f {
    import "block-1D300.typ"
    (("Tai Xuan Jing Symbols", 0x1D300, 0x60), block-1D300.data.at(code - 0x1d300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d360 <= code and code <= 0x1d37f {
    import "block-1D360.typ"
    (("Counting Rod Numerals", 0x1D360, 0x20), block-1D360.data.at(code - 0x1d360, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d400 <= code and code <= 0x1d7ff {
    import "block-1D400.typ"
    (("Mathematical Alphanumeric Symbols", 0x1D400, 0x400), block-1D400.data.at(code - 0x1d400, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1d800 <= code and code <= 0x1daaf {
    import "block-1D800.typ"
    (("Sutton SignWriting", 0x1D800, 0x2b0), block-1D800.data.at(code - 0x1d800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1df00 <= code and code <= 0x1dfff {
    import "block-1DF00.typ"
    (("Latin Extended-G", 0x1DF00, 0x100), block-1DF00.data.at(code - 0x1df00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e000 <= code and code <= 0x1e02f {
    import "block-1E000.typ"
    (("Glagolitic Supplement", 0x1E000, 0x30), block-1E000.data.at(code - 0x1e000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e030 <= code and code <= 0x1e08f {
    import "block-1E030.typ"
    (("Cyrillic Extended-D", 0x1E030, 0x60), block-1E030.data.at(code - 0x1e030, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e100 <= code and code <= 0x1e14f {
    import "block-1E100.typ"
    (("Nyiakeng Puachue Hmong", 0x1E100, 0x50), block-1E100.data.at(code - 0x1e100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e290 <= code and code <= 0x1e2bf {
    import "block-1E290.typ"
    (("Toto", 0x1E290, 0x30), block-1E290.data.at(code - 0x1e290, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e2c0 <= code and code <= 0x1e2ff {
    import "block-1E2C0.typ"
    (("Wancho", 0x1E2C0, 0x40), block-1E2C0.data.at(code - 0x1e2c0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e4d0 <= code and code <= 0x1e4ff {
    import "block-1E4D0.typ"
    (("Nag Mundari", 0x1E4D0, 0x30), block-1E4D0.data.at(code - 0x1e4d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e5d0 <= code and code <= 0x1e5ff {
    import "block-1E5D0.typ"
    (("Ol Onal", 0x1E5D0, 0x30), block-1E5D0.data.at(code - 0x1e5d0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e7e0 <= code and code <= 0x1e7ff {
    import "block-1E7E0.typ"
    (("Ethiopic Extended-B", 0x1E7E0, 0x20), block-1E7E0.data.at(code - 0x1e7e0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e800 <= code and code <= 0x1e8df {
    import "block-1E800.typ"
    (("Mende Kikakui", 0x1E800, 0xe0), block-1E800.data.at(code - 0x1e800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1e900 <= code and code <= 0x1e95f {
    import "block-1E900.typ"
    (("Adlam", 0x1E900, 0x60), block-1E900.data.at(code - 0x1e900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1ec70 <= code and code <= 0x1ecbf {
    import "block-1EC70.typ"
    (("Indic Siyaq Numbers", 0x1EC70, 0x50), block-1EC70.data.at(code - 0x1ec70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1ed00 <= code and code <= 0x1ed4f {
    import "block-1ED00.typ"
    (("Ottoman Siyaq Numbers", 0x1ED00, 0x50), block-1ED00.data.at(code - 0x1ed00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1ee00 <= code and code <= 0x1eeff {
    import "block-1EE00.typ"
    (("Arabic Mathematical Alphabetic Symbols", 0x1EE00, 0x100), block-1EE00.data.at(code - 0x1ee00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f000 <= code and code <= 0x1f02f {
    import "block-1F000.typ"
    (("Mahjong Tiles", 0x1F000, 0x30), block-1F000.data.at(code - 0x1f000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f030 <= code and code <= 0x1f09f {
    import "block-1F030.typ"
    (("Domino Tiles", 0x1F030, 0x70), block-1F030.data.at(code - 0x1f030, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f0a0 <= code and code <= 0x1f0ff {
    import "block-1F0A0.typ"
    (("Playing Cards", 0x1F0A0, 0x60), block-1F0A0.data.at(code - 0x1f0a0, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f100 <= code and code <= 0x1f1ff {
    import "block-1F100.typ"
    (("Enclosed Alphanumeric Supplement", 0x1F100, 0x100), block-1F100.data.at(code - 0x1f100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f200 <= code and code <= 0x1f2ff {
    import "block-1F200.typ"
    (("Enclosed Ideographic Supplement", 0x1F200, 0x100), block-1F200.data.at(code - 0x1f200, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f300 <= code and code <= 0x1f5ff {
    import "block-1F300.typ"
    (("Miscellaneous Symbols and Pictographs", 0x1F300, 0x300), block-1F300.data.at(code - 0x1f300, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f600 <= code and code <= 0x1f64f {
    import "block-1F600.typ"
    (("Emoticons", 0x1F600, 0x50), block-1F600.data.at(code - 0x1f600, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f650 <= code and code <= 0x1f67f {
    import "block-1F650.typ"
    (("Ornamental Dingbats", 0x1F650, 0x30), block-1F650.data.at(code - 0x1f650, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f680 <= code and code <= 0x1f6ff {
    import "block-1F680.typ"
    (("Transport and Map Symbols", 0x1F680, 0x80), block-1F680.data.at(code - 0x1f680, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f700 <= code and code <= 0x1f77f {
    import "block-1F700.typ"
    (("Alchemical Symbols", 0x1F700, 0x80), block-1F700.data.at(code - 0x1f700, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f780 <= code and code <= 0x1f7ff {
    import "block-1F780.typ"
    (("Geometric Shapes Extended", 0x1F780, 0x80), block-1F780.data.at(code - 0x1f780, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f800 <= code and code <= 0x1f8ff {
    import "block-1F800.typ"
    (("Supplemental Arrows-C", 0x1F800, 0x100), block-1F800.data.at(code - 0x1f800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1f900 <= code and code <= 0x1f9ff {
    import "block-1F900.typ"
    (("Supplemental Symbols and Pictographs", 0x1F900, 0x100), block-1F900.data.at(code - 0x1f900, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1fa00 <= code and code <= 0x1fa6f {
    import "block-1FA00.typ"
    (("Chess Symbols", 0x1FA00, 0x70), block-1FA00.data.at(code - 0x1fa00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1fa70 <= code and code <= 0x1faff {
    import "block-1FA70.typ"
    (("Symbols and Pictographs Extended-A", 0x1FA70, 0x90), block-1FA70.data.at(code - 0x1fa70, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x1fb00 <= code and code <= 0x1fbff {
    import "block-1FB00.typ"
    (("Symbols for Legacy Computing", 0x1FB00, 0x100), block-1FB00.data.at(code - 0x1fb00, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x20000 <= code and code <= 0x2a6df {
    import "block-20000.typ"
    (("CJK Unified Ideographs Extension B", 0x20000, 0xa6e0), block-20000.data.at(upper(str(code - 0x20000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2a700 <= code and code <= 0x2b73f {
    import "block-2A700.typ"
    (("CJK Unified Ideographs Extension C", 0x2A700, 0x1040), block-2A700.data.at(upper(str(code - 0x2a700, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2b740 <= code and code <= 0x2b81f {
    import "block-2B740.typ"
    (("CJK Unified Ideographs Extension D", 0x2B740, 0xe0), block-2B740.data.at(upper(str(code - 0x2b740, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2b820 <= code and code <= 0x2ceaf {
    import "block-2B820.typ"
    (("CJK Unified Ideographs Extension E", 0x2B820, 0x1690), block-2B820.data.at(upper(str(code - 0x2b820, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2ceb0 <= code and code <= 0x2ebef {
    import "block-2CEB0.typ"
    (("CJK Unified Ideographs Extension F", 0x2CEB0, 0x1d40), block-2CEB0.data.at(upper(str(code - 0x2ceb0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2ebf0 <= code and code <= 0x2ee5f {
    import "block-2EBF0.typ"
    (("CJK Unified Ideographs Extension I", 0x2EBF0, 0x270), block-2EBF0.data.at(upper(str(code - 0x2ebf0, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x2f800 <= code and code <= 0x2fa1f {
    import "block-2F800.typ"
    (("CJK Compatibility Ideographs Supplement", 0x2F800, 0x220), block-2F800.data.at(code - 0x2f800, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x30000 <= code and code <= 0x3134f {
    import "block-30000.typ"
    (("CJK Unified Ideographs Extension G", 0x30000, 0x1350), block-30000.data.at(upper(str(code - 0x30000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x31350 <= code and code <= 0x323af {
    import "block-31350.typ"
    (("CJK Unified Ideographs Extension H", 0x31350, 0x1060), block-31350.data.at(upper(str(code - 0x31350, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xe0000 <= code and code <= 0xe007f {
    import "block-E0000.typ"
    (("Tags", 0xE0000, 0x80), block-E0000.data.at(code - 0xe0000, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xe0100 <= code and code <= 0xe01ef {
    import "block-E0100.typ"
    (("Variation Selectors Supplement", 0xE0100, 0xf0), block-E0100.data.at(code - 0xe0100, default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0xf0000 <= code and code <= 0xfffff {
    import "block-F0000.typ"
    (("Supplementary Private Use Area-A", 0xF0000, 0x10000), block-F0000.data.at(upper(str(code - 0xf0000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else if 0x100000 <= code and code <= 0x10ffff {
    import "block-100000.typ"
    (("Supplementary Private Use Area-B", 0x100000, 0x10000), block-100000.data.at(upper(str(code - 0x100000, base: 16)), default: ()), aliases.aliases.at(upper(str(code, base: 16)), default: ((), (), (), (), ())))
  } else {
    (none, (), ())
  }
}
