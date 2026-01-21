#let get-data(code) = {
  if 0x0 <= code and code <= 0x7f {
    import "block-0000.typ"
    ("Basic Latin", block-0000.data.at(code - 0x0, default: ()))
  } else if 0x80 <= code and code <= 0xff {
    import "block-0080.typ"
    ("Latin-1 Supplement", block-0080.data.at(code - 0x80, default: ()))
  } else if 0x100 <= code and code <= 0x17f {
    import "block-0100.typ"
    ("Latin Extended-A", block-0100.data.at(code - 0x100, default: ()))
  } else if 0x180 <= code and code <= 0x24f {
    import "block-0180.typ"
    ("Latin Extended-B", block-0180.data.at(code - 0x180, default: ()))
  } else if 0x250 <= code and code <= 0x2af {
    import "block-0250.typ"
    ("IPA Extensions", block-0250.data.at(code - 0x250, default: ()))
  } else if 0x2b0 <= code and code <= 0x2ff {
    import "block-02B0.typ"
    ("Spacing Modifier Letters", block-02B0.data.at(code - 0x2b0, default: ()))
  } else if 0x300 <= code and code <= 0x36f {
    import "block-0300.typ"
    ("Combining Diacritical Marks", block-0300.data.at(code - 0x300, default: ()))
  } else if 0x370 <= code and code <= 0x3ff {
    import "block-0370.typ"
    ("Greek and Coptic", block-0370.data.at(code - 0x370, default: ()))
  } else if 0x400 <= code and code <= 0x4ff {
    import "block-0400.typ"
    ("Cyrillic", block-0400.data.at(code - 0x400, default: ()))
  } else if 0x500 <= code and code <= 0x52f {
    import "block-0500.typ"
    ("Cyrillic Supplement", block-0500.data.at(code - 0x500, default: ()))
  } else if 0x530 <= code and code <= 0x58f {
    import "block-0530.typ"
    ("Armenian", block-0530.data.at(code - 0x530, default: ()))
  } else if 0x590 <= code and code <= 0x5ff {
    import "block-0590.typ"
    ("Hebrew", block-0590.data.at(code - 0x590, default: ()))
  } else if 0x600 <= code and code <= 0x6ff {
    import "block-0600.typ"
    ("Arabic", block-0600.data.at(code - 0x600, default: ()))
  } else if 0x700 <= code and code <= 0x74f {
    import "block-0700.typ"
    ("Syriac", block-0700.data.at(code - 0x700, default: ()))
  } else if 0x750 <= code and code <= 0x77f {
    import "block-0750.typ"
    ("Arabic Supplement", block-0750.data.at(code - 0x750, default: ()))
  } else if 0x780 <= code and code <= 0x7bf {
    import "block-0780.typ"
    ("Thaana", block-0780.data.at(code - 0x780, default: ()))
  } else if 0x7c0 <= code and code <= 0x7ff {
    import "block-07C0.typ"
    ("NKo", block-07C0.data.at(code - 0x7c0, default: ()))
  } else if 0x800 <= code and code <= 0x83f {
    import "block-0800.typ"
    ("Samaritan", block-0800.data.at(code - 0x800, default: ()))
  } else if 0x840 <= code and code <= 0x85f {
    import "block-0840.typ"
    ("Mandaic", block-0840.data.at(code - 0x840, default: ()))
  } else if 0x860 <= code and code <= 0x86f {
    import "block-0860.typ"
    ("Syriac Supplement", block-0860.data.at(code - 0x860, default: ()))
  } else if 0x870 <= code and code <= 0x89f {
    import "block-0870.typ"
    ("Arabic Extended-B", block-0870.data.at(code - 0x870, default: ()))
  } else if 0x8a0 <= code and code <= 0x8ff {
    import "block-08A0.typ"
    ("Arabic Extended-A", block-08A0.data.at(code - 0x8a0, default: ()))
  } else if 0x900 <= code and code <= 0x97f {
    import "block-0900.typ"
    ("Devanagari", block-0900.data.at(code - 0x900, default: ()))
  } else if 0x980 <= code and code <= 0x9ff {
    import "block-0980.typ"
    ("Bengali", block-0980.data.at(code - 0x980, default: ()))
  } else if 0xa00 <= code and code <= 0xa7f {
    import "block-0A00.typ"
    ("Gurmukhi", block-0A00.data.at(code - 0xa00, default: ()))
  } else if 0xa80 <= code and code <= 0xaff {
    import "block-0A80.typ"
    ("Gujarati", block-0A80.data.at(code - 0xa80, default: ()))
  } else if 0xb00 <= code and code <= 0xb7f {
    import "block-0B00.typ"
    ("Oriya", block-0B00.data.at(code - 0xb00, default: ()))
  } else if 0xb80 <= code and code <= 0xbff {
    import "block-0B80.typ"
    ("Tamil", block-0B80.data.at(code - 0xb80, default: ()))
  } else if 0xc00 <= code and code <= 0xc7f {
    import "block-0C00.typ"
    ("Telugu", block-0C00.data.at(code - 0xc00, default: ()))
  } else if 0xc80 <= code and code <= 0xcff {
    import "block-0C80.typ"
    ("Kannada", block-0C80.data.at(code - 0xc80, default: ()))
  } else if 0xd00 <= code and code <= 0xd7f {
    import "block-0D00.typ"
    ("Malayalam", block-0D00.data.at(code - 0xd00, default: ()))
  } else if 0xd80 <= code and code <= 0xdff {
    import "block-0D80.typ"
    ("Sinhala", block-0D80.data.at(code - 0xd80, default: ()))
  } else if 0xe00 <= code and code <= 0xe7f {
    import "block-0E00.typ"
    ("Thai", block-0E00.data.at(code - 0xe00, default: ()))
  } else if 0xe80 <= code and code <= 0xeff {
    import "block-0E80.typ"
    ("Lao", block-0E80.data.at(code - 0xe80, default: ()))
  } else if 0xf00 <= code and code <= 0xfff {
    import "block-0F00.typ"
    ("Tibetan", block-0F00.data.at(code - 0xf00, default: ()))
  } else if 0x1000 <= code and code <= 0x109f {
    import "block-1000.typ"
    ("Myanmar", block-1000.data.at(code - 0x1000, default: ()))
  } else if 0x10a0 <= code and code <= 0x10ff {
    import "block-10A0.typ"
    ("Georgian", block-10A0.data.at(code - 0x10a0, default: ()))
  } else if 0x1100 <= code and code <= 0x11ff {
    import "block-1100.typ"
    ("Hangul Jamo", block-1100.data.at(code - 0x1100, default: ()))
  } else if 0x1200 <= code and code <= 0x137f {
    import "block-1200.typ"
    ("Ethiopic", block-1200.data.at(code - 0x1200, default: ()))
  } else if 0x1380 <= code and code <= 0x139f {
    import "block-1380.typ"
    ("Ethiopic Supplement", block-1380.data.at(code - 0x1380, default: ()))
  } else if 0x13a0 <= code and code <= 0x13ff {
    import "block-13A0.typ"
    ("Cherokee", block-13A0.data.at(code - 0x13a0, default: ()))
  } else if 0x1400 <= code and code <= 0x167f {
    import "block-1400.typ"
    ("Unified Canadian Aboriginal Syllabics", block-1400.data.at(code - 0x1400, default: ()))
  } else if 0x1680 <= code and code <= 0x169f {
    import "block-1680.typ"
    ("Ogham", block-1680.data.at(code - 0x1680, default: ()))
  } else if 0x16a0 <= code and code <= 0x16ff {
    import "block-16A0.typ"
    ("Runic", block-16A0.data.at(code - 0x16a0, default: ()))
  } else if 0x1700 <= code and code <= 0x171f {
    import "block-1700.typ"
    ("Tagalog", block-1700.data.at(code - 0x1700, default: ()))
  } else if 0x1720 <= code and code <= 0x173f {
    import "block-1720.typ"
    ("Hanunoo", block-1720.data.at(code - 0x1720, default: ()))
  } else if 0x1740 <= code and code <= 0x175f {
    import "block-1740.typ"
    ("Buhid", block-1740.data.at(code - 0x1740, default: ()))
  } else if 0x1760 <= code and code <= 0x177f {
    import "block-1760.typ"
    ("Tagbanwa", block-1760.data.at(code - 0x1760, default: ()))
  } else if 0x1780 <= code and code <= 0x17ff {
    import "block-1780.typ"
    ("Khmer", block-1780.data.at(code - 0x1780, default: ()))
  } else if 0x1800 <= code and code <= 0x18af {
    import "block-1800.typ"
    ("Mongolian", block-1800.data.at(code - 0x1800, default: ()))
  } else if 0x18b0 <= code and code <= 0x18ff {
    import "block-18B0.typ"
    ("Unified Canadian Aboriginal Syllabics Extended", block-18B0.data.at(code - 0x18b0, default: ()))
  } else if 0x1900 <= code and code <= 0x194f {
    import "block-1900.typ"
    ("Limbu", block-1900.data.at(code - 0x1900, default: ()))
  } else if 0x1950 <= code and code <= 0x197f {
    import "block-1950.typ"
    ("Tai Le", block-1950.data.at(code - 0x1950, default: ()))
  } else if 0x1980 <= code and code <= 0x19df {
    import "block-1980.typ"
    ("New Tai Lue", block-1980.data.at(code - 0x1980, default: ()))
  } else if 0x19e0 <= code and code <= 0x19ff {
    import "block-19E0.typ"
    ("Khmer Symbols", block-19E0.data.at(code - 0x19e0, default: ()))
  } else if 0x1a00 <= code and code <= 0x1a1f {
    import "block-1A00.typ"
    ("Buginese", block-1A00.data.at(code - 0x1a00, default: ()))
  } else if 0x1a20 <= code and code <= 0x1aaf {
    import "block-1A20.typ"
    ("Tai Tham", block-1A20.data.at(code - 0x1a20, default: ()))
  } else if 0x1ab0 <= code and code <= 0x1aff {
    import "block-1AB0.typ"
    ("Combining Diacritical Marks Extended", block-1AB0.data.at(code - 0x1ab0, default: ()))
  } else if 0x1b00 <= code and code <= 0x1b7f {
    import "block-1B00.typ"
    ("Balinese", block-1B00.data.at(code - 0x1b00, default: ()))
  } else if 0x1b80 <= code and code <= 0x1bbf {
    import "block-1B80.typ"
    ("Sundanese", block-1B80.data.at(code - 0x1b80, default: ()))
  } else if 0x1bc0 <= code and code <= 0x1bff {
    import "block-1BC0.typ"
    ("Batak", block-1BC0.data.at(code - 0x1bc0, default: ()))
  } else if 0x1c00 <= code and code <= 0x1c4f {
    import "block-1C00.typ"
    ("Lepcha", block-1C00.data.at(code - 0x1c00, default: ()))
  } else if 0x1c50 <= code and code <= 0x1c7f {
    import "block-1C50.typ"
    ("Ol Chiki", block-1C50.data.at(code - 0x1c50, default: ()))
  } else if 0x1c80 <= code and code <= 0x1c8f {
    import "block-1C80.typ"
    ("Cyrillic Extended-C", block-1C80.data.at(code - 0x1c80, default: ()))
  } else if 0x1c90 <= code and code <= 0x1cbf {
    import "block-1C90.typ"
    ("Georgian Extended", block-1C90.data.at(code - 0x1c90, default: ()))
  } else if 0x1cc0 <= code and code <= 0x1ccf {
    import "block-1CC0.typ"
    ("Sundanese Supplement", block-1CC0.data.at(code - 0x1cc0, default: ()))
  } else if 0x1cd0 <= code and code <= 0x1cff {
    import "block-1CD0.typ"
    ("Vedic Extensions", block-1CD0.data.at(code - 0x1cd0, default: ()))
  } else if 0x1d00 <= code and code <= 0x1d7f {
    import "block-1D00.typ"
    ("Phonetic Extensions", block-1D00.data.at(code - 0x1d00, default: ()))
  } else if 0x1d80 <= code and code <= 0x1dbf {
    import "block-1D80.typ"
    ("Phonetic Extensions Supplement", block-1D80.data.at(code - 0x1d80, default: ()))
  } else if 0x1dc0 <= code and code <= 0x1dff {
    import "block-1DC0.typ"
    ("Combining Diacritical Marks Supplement", block-1DC0.data.at(code - 0x1dc0, default: ()))
  } else if 0x1e00 <= code and code <= 0x1eff {
    import "block-1E00.typ"
    ("Latin Extended Additional", block-1E00.data.at(code - 0x1e00, default: ()))
  } else if 0x1f00 <= code and code <= 0x1fff {
    import "block-1F00.typ"
    ("Greek Extended", block-1F00.data.at(code - 0x1f00, default: ()))
  } else if 0x2000 <= code and code <= 0x206f {
    import "block-2000.typ"
    ("General Punctuation", block-2000.data.at(code - 0x2000, default: ()))
  } else if 0x2070 <= code and code <= 0x209f {
    import "block-2070.typ"
    ("Superscripts and Subscripts", block-2070.data.at(code - 0x2070, default: ()))
  } else if 0x20a0 <= code and code <= 0x20cf {
    import "block-20A0.typ"
    ("Currency Symbols", block-20A0.data.at(code - 0x20a0, default: ()))
  } else if 0x20d0 <= code and code <= 0x20ff {
    import "block-20D0.typ"
    ("Combining Diacritical Marks for Symbols", block-20D0.data.at(code - 0x20d0, default: ()))
  } else if 0x2100 <= code and code <= 0x214f {
    import "block-2100.typ"
    ("Letterlike Symbols", block-2100.data.at(code - 0x2100, default: ()))
  } else if 0x2150 <= code and code <= 0x218f {
    import "block-2150.typ"
    ("Number Forms", block-2150.data.at(code - 0x2150, default: ()))
  } else if 0x2190 <= code and code <= 0x21ff {
    import "block-2190.typ"
    ("Arrows", block-2190.data.at(code - 0x2190, default: ()))
  } else if 0x2200 <= code and code <= 0x22ff {
    import "block-2200.typ"
    ("Mathematical Operators", block-2200.data.at(code - 0x2200, default: ()))
  } else if 0x2300 <= code and code <= 0x23ff {
    import "block-2300.typ"
    ("Miscellaneous Technical", block-2300.data.at(code - 0x2300, default: ()))
  } else if 0x2400 <= code and code <= 0x243f {
    import "block-2400.typ"
    ("Control Pictures", block-2400.data.at(code - 0x2400, default: ()))
  } else if 0x2440 <= code and code <= 0x245f {
    import "block-2440.typ"
    ("Optical Character Recognition", block-2440.data.at(code - 0x2440, default: ()))
  } else if 0x2460 <= code and code <= 0x24ff {
    import "block-2460.typ"
    ("Enclosed Alphanumerics", block-2460.data.at(code - 0x2460, default: ()))
  } else if 0x2500 <= code and code <= 0x257f {
    import "block-2500.typ"
    ("Box Drawing", block-2500.data.at(code - 0x2500, default: ()))
  } else if 0x2580 <= code and code <= 0x259f {
    import "block-2580.typ"
    ("Block Elements", block-2580.data.at(code - 0x2580, default: ()))
  } else if 0x25a0 <= code and code <= 0x25ff {
    import "block-25A0.typ"
    ("Geometric Shapes", block-25A0.data.at(code - 0x25a0, default: ()))
  } else if 0x2600 <= code and code <= 0x26ff {
    import "block-2600.typ"
    ("Miscellaneous Symbols", block-2600.data.at(code - 0x2600, default: ()))
  } else if 0x2700 <= code and code <= 0x27bf {
    import "block-2700.typ"
    ("Dingbats", block-2700.data.at(code - 0x2700, default: ()))
  } else if 0x27c0 <= code and code <= 0x27ef {
    import "block-27C0.typ"
    ("Miscellaneous Mathematical Symbols-A", block-27C0.data.at(code - 0x27c0, default: ()))
  } else if 0x27f0 <= code and code <= 0x27ff {
    import "block-27F0.typ"
    ("Supplemental Arrows-A", block-27F0.data.at(code - 0x27f0, default: ()))
  } else if 0x2800 <= code and code <= 0x28ff {
    import "block-2800.typ"
    ("Braille Patterns", block-2800.data.at(code - 0x2800, default: ()))
  } else if 0x2900 <= code and code <= 0x297f {
    import "block-2900.typ"
    ("Supplemental Arrows-B", block-2900.data.at(code - 0x2900, default: ()))
  } else if 0x2980 <= code and code <= 0x29ff {
    import "block-2980.typ"
    ("Miscellaneous Mathematical Symbols-B", block-2980.data.at(code - 0x2980, default: ()))
  } else if 0x2a00 <= code and code <= 0x2aff {
    import "block-2A00.typ"
    ("Supplemental Mathematical Operators", block-2A00.data.at(code - 0x2a00, default: ()))
  } else if 0x2b00 <= code and code <= 0x2bff {
    import "block-2B00.typ"
    ("Miscellaneous Symbols and Arrows", block-2B00.data.at(code - 0x2b00, default: ()))
  } else if 0x2c00 <= code and code <= 0x2c5f {
    import "block-2C00.typ"
    ("Glagolitic", block-2C00.data.at(code - 0x2c00, default: ()))
  } else if 0x2c60 <= code and code <= 0x2c7f {
    import "block-2C60.typ"
    ("Latin Extended-C", block-2C60.data.at(code - 0x2c60, default: ()))
  } else if 0x2c80 <= code and code <= 0x2cff {
    import "block-2C80.typ"
    ("Coptic", block-2C80.data.at(code - 0x2c80, default: ()))
  } else if 0x2d00 <= code and code <= 0x2d2f {
    import "block-2D00.typ"
    ("Georgian Supplement", block-2D00.data.at(code - 0x2d00, default: ()))
  } else if 0x2d30 <= code and code <= 0x2d7f {
    import "block-2D30.typ"
    ("Tifinagh", block-2D30.data.at(code - 0x2d30, default: ()))
  } else if 0x2d80 <= code and code <= 0x2ddf {
    import "block-2D80.typ"
    ("Ethiopic Extended", block-2D80.data.at(code - 0x2d80, default: ()))
  } else if 0x2de0 <= code and code <= 0x2dff {
    import "block-2DE0.typ"
    ("Cyrillic Extended-A", block-2DE0.data.at(code - 0x2de0, default: ()))
  } else if 0x2e00 <= code and code <= 0x2e7f {
    import "block-2E00.typ"
    ("Supplemental Punctuation", block-2E00.data.at(code - 0x2e00, default: ()))
  } else if 0x2e80 <= code and code <= 0x2eff {
    import "block-2E80.typ"
    ("CJK Radicals Supplement", block-2E80.data.at(code - 0x2e80, default: ()))
  } else if 0x2f00 <= code and code <= 0x2fdf {
    import "block-2F00.typ"
    ("Kangxi Radicals", block-2F00.data.at(code - 0x2f00, default: ()))
  } else if 0x2ff0 <= code and code <= 0x2fff {
    import "block-2FF0.typ"
    ("Ideographic Description Characters", block-2FF0.data.at(code - 0x2ff0, default: ()))
  } else if 0x3000 <= code and code <= 0x303f {
    import "block-3000.typ"
    ("CJK Symbols and Punctuation", block-3000.data.at(code - 0x3000, default: ()))
  } else if 0x3040 <= code and code <= 0x309f {
    import "block-3040.typ"
    ("Hiragana", block-3040.data.at(code - 0x3040, default: ()))
  } else if 0x30a0 <= code and code <= 0x30ff {
    import "block-30A0.typ"
    ("Katakana", block-30A0.data.at(code - 0x30a0, default: ()))
  } else if 0x3100 <= code and code <= 0x312f {
    import "block-3100.typ"
    ("Bopomofo", block-3100.data.at(code - 0x3100, default: ()))
  } else if 0x3130 <= code and code <= 0x318f {
    import "block-3130.typ"
    ("Hangul Compatibility Jamo", block-3130.data.at(code - 0x3130, default: ()))
  } else if 0x3190 <= code and code <= 0x319f {
    import "block-3190.typ"
    ("Kanbun", block-3190.data.at(code - 0x3190, default: ()))
  } else if 0x31a0 <= code and code <= 0x31bf {
    import "block-31A0.typ"
    ("Bopomofo Extended", block-31A0.data.at(code - 0x31a0, default: ()))
  } else if 0x31c0 <= code and code <= 0x31ef {
    import "block-31C0.typ"
    ("CJK Strokes", block-31C0.data.at(code - 0x31c0, default: ()))
  } else if 0x31f0 <= code and code <= 0x31ff {
    import "block-31F0.typ"
    ("Katakana Phonetic Extensions", block-31F0.data.at(code - 0x31f0, default: ()))
  } else if 0x3200 <= code and code <= 0x32ff {
    import "block-3200.typ"
    ("Enclosed CJK Letters and Months", block-3200.data.at(code - 0x3200, default: ()))
  } else if 0x3300 <= code and code <= 0x33ff {
    import "block-3300.typ"
    ("CJK Compatibility", block-3300.data.at(code - 0x3300, default: ()))
  } else if 0x3400 <= code and code <= 0x4dbf {
    import "block-3400.typ"
    ("CJK Unified Ideographs Extension A", block-3400.data.at(str(code - 0x3400, base: 16), default: ()))
  } else if 0x4dc0 <= code and code <= 0x4dff {
    import "block-4DC0.typ"
    ("Yijing Hexagram Symbols", block-4DC0.data.at(code - 0x4dc0, default: ()))
  } else if 0x4e00 <= code and code <= 0x9fff {
    import "block-4E00.typ"
    ("CJK Unified Ideographs", block-4E00.data.at(str(code - 0x4e00, base: 16), default: ()))
  } else if 0xa000 <= code and code <= 0xa48f {
    import "block-A000.typ"
    ("Yi Syllables", block-A000.data.at(code - 0xa000, default: ()))
  } else if 0xa490 <= code and code <= 0xa4cf {
    import "block-A490.typ"
    ("Yi Radicals", block-A490.data.at(code - 0xa490, default: ()))
  } else if 0xa4d0 <= code and code <= 0xa4ff {
    import "block-A4D0.typ"
    ("Lisu", block-A4D0.data.at(code - 0xa4d0, default: ()))
  } else if 0xa500 <= code and code <= 0xa63f {
    import "block-A500.typ"
    ("Vai", block-A500.data.at(code - 0xa500, default: ()))
  } else if 0xa640 <= code and code <= 0xa69f {
    import "block-A640.typ"
    ("Cyrillic Extended-B", block-A640.data.at(code - 0xa640, default: ()))
  } else if 0xa6a0 <= code and code <= 0xa6ff {
    import "block-A6A0.typ"
    ("Bamum", block-A6A0.data.at(code - 0xa6a0, default: ()))
  } else if 0xa700 <= code and code <= 0xa71f {
    import "block-A700.typ"
    ("Modifier Tone Letters", block-A700.data.at(code - 0xa700, default: ()))
  } else if 0xa720 <= code and code <= 0xa7ff {
    import "block-A720.typ"
    ("Latin Extended-D", block-A720.data.at(code - 0xa720, default: ()))
  } else if 0xa800 <= code and code <= 0xa82f {
    import "block-A800.typ"
    ("Syloti Nagri", block-A800.data.at(code - 0xa800, default: ()))
  } else if 0xa830 <= code and code <= 0xa83f {
    import "block-A830.typ"
    ("Common Indic Number Forms", block-A830.data.at(code - 0xa830, default: ()))
  } else if 0xa840 <= code and code <= 0xa87f {
    import "block-A840.typ"
    ("Phags-pa", block-A840.data.at(code - 0xa840, default: ()))
  } else if 0xa880 <= code and code <= 0xa8df {
    import "block-A880.typ"
    ("Saurashtra", block-A880.data.at(code - 0xa880, default: ()))
  } else if 0xa8e0 <= code and code <= 0xa8ff {
    import "block-A8E0.typ"
    ("Devanagari Extended", block-A8E0.data.at(code - 0xa8e0, default: ()))
  } else if 0xa900 <= code and code <= 0xa92f {
    import "block-A900.typ"
    ("Kayah Li", block-A900.data.at(code - 0xa900, default: ()))
  } else if 0xa930 <= code and code <= 0xa95f {
    import "block-A930.typ"
    ("Rejang", block-A930.data.at(code - 0xa930, default: ()))
  } else if 0xa960 <= code and code <= 0xa97f {
    import "block-A960.typ"
    ("Hangul Jamo Extended-A", block-A960.data.at(code - 0xa960, default: ()))
  } else if 0xa980 <= code and code <= 0xa9df {
    import "block-A980.typ"
    ("Javanese", block-A980.data.at(code - 0xa980, default: ()))
  } else if 0xa9e0 <= code and code <= 0xa9ff {
    import "block-A9E0.typ"
    ("Myanmar Extended-B", block-A9E0.data.at(code - 0xa9e0, default: ()))
  } else if 0xaa00 <= code and code <= 0xaa5f {
    import "block-AA00.typ"
    ("Cham", block-AA00.data.at(code - 0xaa00, default: ()))
  } else if 0xaa60 <= code and code <= 0xaa7f {
    import "block-AA60.typ"
    ("Myanmar Extended-A", block-AA60.data.at(code - 0xaa60, default: ()))
  } else if 0xaa80 <= code and code <= 0xaadf {
    import "block-AA80.typ"
    ("Tai Viet", block-AA80.data.at(code - 0xaa80, default: ()))
  } else if 0xaae0 <= code and code <= 0xaaff {
    import "block-AAE0.typ"
    ("Meetei Mayek Extensions", block-AAE0.data.at(code - 0xaae0, default: ()))
  } else if 0xab00 <= code and code <= 0xab2f {
    import "block-AB00.typ"
    ("Ethiopic Extended-A", block-AB00.data.at(code - 0xab00, default: ()))
  } else if 0xab30 <= code and code <= 0xab6f {
    import "block-AB30.typ"
    ("Latin Extended-E", block-AB30.data.at(code - 0xab30, default: ()))
  } else if 0xab70 <= code and code <= 0xabbf {
    import "block-AB70.typ"
    ("Cherokee Supplement", block-AB70.data.at(code - 0xab70, default: ()))
  } else if 0xabc0 <= code and code <= 0xabff {
    import "block-ABC0.typ"
    ("Meetei Mayek", block-ABC0.data.at(code - 0xabc0, default: ()))
  } else if 0xac00 <= code and code <= 0xd7af {
    import "block-AC00.typ"
    ("Hangul Syllables", block-AC00.data.at(str(code - 0xac00, base: 16), default: ()))
  } else if 0xd7b0 <= code and code <= 0xd7ff {
    import "block-D7B0.typ"
    ("Hangul Jamo Extended-B", block-D7B0.data.at(code - 0xd7b0, default: ()))
  } else if 0xd800 <= code and code <= 0xdb7f {
    import "block-D800.typ"
    ("High Surrogates", block-D800.data.at(str(code - 0xd800, base: 16), default: ()))
  } else if 0xdb80 <= code and code <= 0xdbff {
    import "block-DB80.typ"
    ("High Private Use Surrogates", block-DB80.data.at(str(code - 0xdb80, base: 16), default: ()))
  } else if 0xdc00 <= code and code <= 0xdfff {
    import "block-DC00.typ"
    ("Low Surrogates", block-DC00.data.at(str(code - 0xdc00, base: 16), default: ()))
  } else if 0xe000 <= code and code <= 0xf8ff {
    import "block-E000.typ"
    ("Private Use Area", block-E000.data.at(str(code - 0xe000, base: 16), default: ()))
  } else if 0xf900 <= code and code <= 0xfaff {
    import "block-F900.typ"
    ("CJK Compatibility Ideographs", block-F900.data.at(code - 0xf900, default: ()))
  } else if 0xfb00 <= code and code <= 0xfb4f {
    import "block-FB00.typ"
    ("Alphabetic Presentation Forms", block-FB00.data.at(code - 0xfb00, default: ()))
  } else if 0xfb50 <= code and code <= 0xfdff {
    import "block-FB50.typ"
    ("Arabic Presentation Forms-A", block-FB50.data.at(code - 0xfb50, default: ()))
  } else if 0xfe00 <= code and code <= 0xfe0f {
    import "block-FE00.typ"
    ("Variation Selectors", block-FE00.data.at(code - 0xfe00, default: ()))
  } else if 0xfe10 <= code and code <= 0xfe1f {
    import "block-FE10.typ"
    ("Vertical Forms", block-FE10.data.at(code - 0xfe10, default: ()))
  } else if 0xfe20 <= code and code <= 0xfe2f {
    import "block-FE20.typ"
    ("Combining Half Marks", block-FE20.data.at(code - 0xfe20, default: ()))
  } else if 0xfe30 <= code and code <= 0xfe4f {
    import "block-FE30.typ"
    ("CJK Compatibility Forms", block-FE30.data.at(code - 0xfe30, default: ()))
  } else if 0xfe50 <= code and code <= 0xfe6f {
    import "block-FE50.typ"
    ("Small Form Variants", block-FE50.data.at(code - 0xfe50, default: ()))
  } else if 0xfe70 <= code and code <= 0xfeff {
    import "block-FE70.typ"
    ("Arabic Presentation Forms-B", block-FE70.data.at(code - 0xfe70, default: ()))
  } else if 0xff00 <= code and code <= 0xffef {
    import "block-FF00.typ"
    ("Halfwidth and Fullwidth Forms", block-FF00.data.at(code - 0xff00, default: ()))
  } else if 0xfff0 <= code and code <= 0xffff {
    import "block-FFF0.typ"
    ("Specials", block-FFF0.data.at(str(code - 0xfff0, base: 16), default: ()))
  } else if 0x10000 <= code and code <= 0x1007f {
    import "block-10000.typ"
    ("Linear B Syllabary", block-10000.data.at(code - 0x10000, default: ()))
  } else if 0x10080 <= code and code <= 0x100ff {
    import "block-10080.typ"
    ("Linear B Ideograms", block-10080.data.at(code - 0x10080, default: ()))
  } else if 0x10100 <= code and code <= 0x1013f {
    import "block-10100.typ"
    ("Aegean Numbers", block-10100.data.at(code - 0x10100, default: ()))
  } else if 0x10140 <= code and code <= 0x1018f {
    import "block-10140.typ"
    ("Ancient Greek Numbers", block-10140.data.at(code - 0x10140, default: ()))
  } else if 0x10190 <= code and code <= 0x101cf {
    import "block-10190.typ"
    ("Ancient Symbols", block-10190.data.at(code - 0x10190, default: ()))
  } else if 0x101d0 <= code and code <= 0x101ff {
    import "block-101D0.typ"
    ("Phaistos Disc", block-101D0.data.at(code - 0x101d0, default: ()))
  } else if 0x10280 <= code and code <= 0x1029f {
    import "block-10280.typ"
    ("Lycian", block-10280.data.at(code - 0x10280, default: ()))
  } else if 0x102a0 <= code and code <= 0x102df {
    import "block-102A0.typ"
    ("Carian", block-102A0.data.at(code - 0x102a0, default: ()))
  } else if 0x102e0 <= code and code <= 0x102ff {
    import "block-102E0.typ"
    ("Coptic Epact Numbers", block-102E0.data.at(code - 0x102e0, default: ()))
  } else if 0x10300 <= code and code <= 0x1032f {
    import "block-10300.typ"
    ("Old Italic", block-10300.data.at(code - 0x10300, default: ()))
  } else if 0x10330 <= code and code <= 0x1034f {
    import "block-10330.typ"
    ("Gothic", block-10330.data.at(code - 0x10330, default: ()))
  } else if 0x10350 <= code and code <= 0x1037f {
    import "block-10350.typ"
    ("Old Permic", block-10350.data.at(code - 0x10350, default: ()))
  } else if 0x10380 <= code and code <= 0x1039f {
    import "block-10380.typ"
    ("Ugaritic", block-10380.data.at(code - 0x10380, default: ()))
  } else if 0x103a0 <= code and code <= 0x103df {
    import "block-103A0.typ"
    ("Old Persian", block-103A0.data.at(code - 0x103a0, default: ()))
  } else if 0x10400 <= code and code <= 0x1044f {
    import "block-10400.typ"
    ("Deseret", block-10400.data.at(code - 0x10400, default: ()))
  } else if 0x10450 <= code and code <= 0x1047f {
    import "block-10450.typ"
    ("Shavian", block-10450.data.at(code - 0x10450, default: ()))
  } else if 0x10480 <= code and code <= 0x104af {
    import "block-10480.typ"
    ("Osmanya", block-10480.data.at(code - 0x10480, default: ()))
  } else if 0x104b0 <= code and code <= 0x104ff {
    import "block-104B0.typ"
    ("Osage", block-104B0.data.at(code - 0x104b0, default: ()))
  } else if 0x10500 <= code and code <= 0x1052f {
    import "block-10500.typ"
    ("Elbasan", block-10500.data.at(code - 0x10500, default: ()))
  } else if 0x10530 <= code and code <= 0x1056f {
    import "block-10530.typ"
    ("Caucasian Albanian", block-10530.data.at(code - 0x10530, default: ()))
  } else if 0x10570 <= code and code <= 0x105bf {
    import "block-10570.typ"
    ("Vithkuqi", block-10570.data.at(code - 0x10570, default: ()))
  } else if 0x105c0 <= code and code <= 0x105ff {
    import "block-105C0.typ"
    ("Todhri", block-105C0.data.at(code - 0x105c0, default: ()))
  } else if 0x10600 <= code and code <= 0x1077f {
    import "block-10600.typ"
    ("Linear A", block-10600.data.at(code - 0x10600, default: ()))
  } else if 0x10780 <= code and code <= 0x107bf {
    import "block-10780.typ"
    ("Latin Extended-F", block-10780.data.at(code - 0x10780, default: ()))
  } else if 0x10800 <= code and code <= 0x1083f {
    import "block-10800.typ"
    ("Cypriot Syllabary", block-10800.data.at(code - 0x10800, default: ()))
  } else if 0x10840 <= code and code <= 0x1085f {
    import "block-10840.typ"
    ("Imperial Aramaic", block-10840.data.at(code - 0x10840, default: ()))
  } else if 0x10860 <= code and code <= 0x1087f {
    import "block-10860.typ"
    ("Palmyrene", block-10860.data.at(code - 0x10860, default: ()))
  } else if 0x10880 <= code and code <= 0x108af {
    import "block-10880.typ"
    ("Nabataean", block-10880.data.at(code - 0x10880, default: ()))
  } else if 0x108e0 <= code and code <= 0x108ff {
    import "block-108E0.typ"
    ("Hatran", block-108E0.data.at(code - 0x108e0, default: ()))
  } else if 0x10900 <= code and code <= 0x1091f {
    import "block-10900.typ"
    ("Phoenician", block-10900.data.at(code - 0x10900, default: ()))
  } else if 0x10920 <= code and code <= 0x1093f {
    import "block-10920.typ"
    ("Lydian", block-10920.data.at(code - 0x10920, default: ()))
  } else if 0x10980 <= code and code <= 0x1099f {
    import "block-10980.typ"
    ("Meroitic Hieroglyphs", block-10980.data.at(code - 0x10980, default: ()))
  } else if 0x109a0 <= code and code <= 0x109ff {
    import "block-109A0.typ"
    ("Meroitic Cursive", block-109A0.data.at(code - 0x109a0, default: ()))
  } else if 0x10a00 <= code and code <= 0x10a5f {
    import "block-10A00.typ"
    ("Kharoshthi", block-10A00.data.at(code - 0x10a00, default: ()))
  } else if 0x10a60 <= code and code <= 0x10a7f {
    import "block-10A60.typ"
    ("Old South Arabian", block-10A60.data.at(code - 0x10a60, default: ()))
  } else if 0x10a80 <= code and code <= 0x10a9f {
    import "block-10A80.typ"
    ("Old North Arabian", block-10A80.data.at(code - 0x10a80, default: ()))
  } else if 0x10ac0 <= code and code <= 0x10aff {
    import "block-10AC0.typ"
    ("Manichaean", block-10AC0.data.at(code - 0x10ac0, default: ()))
  } else if 0x10b00 <= code and code <= 0x10b3f {
    import "block-10B00.typ"
    ("Avestan", block-10B00.data.at(code - 0x10b00, default: ()))
  } else if 0x10b40 <= code and code <= 0x10b5f {
    import "block-10B40.typ"
    ("Inscriptional Parthian", block-10B40.data.at(code - 0x10b40, default: ()))
  } else if 0x10b60 <= code and code <= 0x10b7f {
    import "block-10B60.typ"
    ("Inscriptional Pahlavi", block-10B60.data.at(code - 0x10b60, default: ()))
  } else if 0x10b80 <= code and code <= 0x10baf {
    import "block-10B80.typ"
    ("Psalter Pahlavi", block-10B80.data.at(code - 0x10b80, default: ()))
  } else if 0x10c00 <= code and code <= 0x10c4f {
    import "block-10C00.typ"
    ("Old Turkic", block-10C00.data.at(code - 0x10c00, default: ()))
  } else if 0x10c80 <= code and code <= 0x10cff {
    import "block-10C80.typ"
    ("Old Hungarian", block-10C80.data.at(code - 0x10c80, default: ()))
  } else if 0x10d00 <= code and code <= 0x10d3f {
    import "block-10D00.typ"
    ("Hanifi Rohingya", block-10D00.data.at(code - 0x10d00, default: ()))
  } else if 0x10d40 <= code and code <= 0x10d8f {
    import "block-10D40.typ"
    ("Garay", block-10D40.data.at(code - 0x10d40, default: ()))
  } else if 0x10e60 <= code and code <= 0x10e7f {
    import "block-10E60.typ"
    ("Rumi Numeral Symbols", block-10E60.data.at(code - 0x10e60, default: ()))
  } else if 0x10e80 <= code and code <= 0x10ebf {
    import "block-10E80.typ"
    ("Yezidi", block-10E80.data.at(code - 0x10e80, default: ()))
  } else if 0x10ec0 <= code and code <= 0x10eff {
    import "block-10EC0.typ"
    ("Arabic Extended-C", block-10EC0.data.at(str(code - 0x10ec0, base: 16), default: ()))
  } else if 0x10f00 <= code and code <= 0x10f2f {
    import "block-10F00.typ"
    ("Old Sogdian", block-10F00.data.at(code - 0x10f00, default: ()))
  } else if 0x10f30 <= code and code <= 0x10f6f {
    import "block-10F30.typ"
    ("Sogdian", block-10F30.data.at(code - 0x10f30, default: ()))
  } else if 0x10f70 <= code and code <= 0x10faf {
    import "block-10F70.typ"
    ("Old Uyghur", block-10F70.data.at(code - 0x10f70, default: ()))
  } else if 0x10fb0 <= code and code <= 0x10fdf {
    import "block-10FB0.typ"
    ("Chorasmian", block-10FB0.data.at(code - 0x10fb0, default: ()))
  } else if 0x10fe0 <= code and code <= 0x10fff {
    import "block-10FE0.typ"
    ("Elymaic", block-10FE0.data.at(code - 0x10fe0, default: ()))
  } else if 0x11000 <= code and code <= 0x1107f {
    import "block-11000.typ"
    ("Brahmi", block-11000.data.at(code - 0x11000, default: ()))
  } else if 0x11080 <= code and code <= 0x110cf {
    import "block-11080.typ"
    ("Kaithi", block-11080.data.at(code - 0x11080, default: ()))
  } else if 0x110d0 <= code and code <= 0x110ff {
    import "block-110D0.typ"
    ("Sora Sompeng", block-110D0.data.at(code - 0x110d0, default: ()))
  } else if 0x11100 <= code and code <= 0x1114f {
    import "block-11100.typ"
    ("Chakma", block-11100.data.at(code - 0x11100, default: ()))
  } else if 0x11150 <= code and code <= 0x1117f {
    import "block-11150.typ"
    ("Mahajani", block-11150.data.at(code - 0x11150, default: ()))
  } else if 0x11180 <= code and code <= 0x111df {
    import "block-11180.typ"
    ("Sharada", block-11180.data.at(code - 0x11180, default: ()))
  } else if 0x111e0 <= code and code <= 0x111ff {
    import "block-111E0.typ"
    ("Sinhala Archaic Numbers", block-111E0.data.at(code - 0x111e0, default: ()))
  } else if 0x11200 <= code and code <= 0x1124f {
    import "block-11200.typ"
    ("Khojki", block-11200.data.at(code - 0x11200, default: ()))
  } else if 0x11280 <= code and code <= 0x112af {
    import "block-11280.typ"
    ("Multani", block-11280.data.at(code - 0x11280, default: ()))
  } else if 0x112b0 <= code and code <= 0x112ff {
    import "block-112B0.typ"
    ("Khudawadi", block-112B0.data.at(code - 0x112b0, default: ()))
  } else if 0x11300 <= code and code <= 0x1137f {
    import "block-11300.typ"
    ("Grantha", block-11300.data.at(code - 0x11300, default: ()))
  } else if 0x11380 <= code and code <= 0x113ff {
    import "block-11380.typ"
    ("Tulu-Tigalari", block-11380.data.at(code - 0x11380, default: ()))
  } else if 0x11400 <= code and code <= 0x1147f {
    import "block-11400.typ"
    ("Newa", block-11400.data.at(code - 0x11400, default: ()))
  } else if 0x11480 <= code and code <= 0x114df {
    import "block-11480.typ"
    ("Tirhuta", block-11480.data.at(code - 0x11480, default: ()))
  } else if 0x11580 <= code and code <= 0x115ff {
    import "block-11580.typ"
    ("Siddham", block-11580.data.at(code - 0x11580, default: ()))
  } else if 0x11600 <= code and code <= 0x1165f {
    import "block-11600.typ"
    ("Modi", block-11600.data.at(code - 0x11600, default: ()))
  } else if 0x11660 <= code and code <= 0x1167f {
    import "block-11660.typ"
    ("Mongolian Supplement", block-11660.data.at(code - 0x11660, default: ()))
  } else if 0x11680 <= code and code <= 0x116cf {
    import "block-11680.typ"
    ("Takri", block-11680.data.at(code - 0x11680, default: ()))
  } else if 0x116d0 <= code and code <= 0x116ff {
    import "block-116D0.typ"
    ("Myanmar Extended-C", block-116D0.data.at(code - 0x116d0, default: ()))
  } else if 0x11700 <= code and code <= 0x1174f {
    import "block-11700.typ"
    ("Ahom", block-11700.data.at(code - 0x11700, default: ()))
  } else if 0x11800 <= code and code <= 0x1184f {
    import "block-11800.typ"
    ("Dogra", block-11800.data.at(code - 0x11800, default: ()))
  } else if 0x118a0 <= code and code <= 0x118ff {
    import "block-118A0.typ"
    ("Warang Citi", block-118A0.data.at(code - 0x118a0, default: ()))
  } else if 0x11900 <= code and code <= 0x1195f {
    import "block-11900.typ"
    ("Dives Akuru", block-11900.data.at(code - 0x11900, default: ()))
  } else if 0x119a0 <= code and code <= 0x119ff {
    import "block-119A0.typ"
    ("Nandinagari", block-119A0.data.at(code - 0x119a0, default: ()))
  } else if 0x11a00 <= code and code <= 0x11a4f {
    import "block-11A00.typ"
    ("Zanabazar Square", block-11A00.data.at(code - 0x11a00, default: ()))
  } else if 0x11a50 <= code and code <= 0x11aaf {
    import "block-11A50.typ"
    ("Soyombo", block-11A50.data.at(code - 0x11a50, default: ()))
  } else if 0x11ab0 <= code and code <= 0x11abf {
    import "block-11AB0.typ"
    ("Unified Canadian Aboriginal Syllabics Extended-A", block-11AB0.data.at(code - 0x11ab0, default: ()))
  } else if 0x11ac0 <= code and code <= 0x11aff {
    import "block-11AC0.typ"
    ("Pau Cin Hau", block-11AC0.data.at(code - 0x11ac0, default: ()))
  } else if 0x11b00 <= code and code <= 0x11b5f {
    import "block-11B00.typ"
    ("Devanagari Extended-A", block-11B00.data.at(code - 0x11b00, default: ()))
  } else if 0x11bc0 <= code and code <= 0x11bff {
    import "block-11BC0.typ"
    ("Sunuwar", block-11BC0.data.at(code - 0x11bc0, default: ()))
  } else if 0x11c00 <= code and code <= 0x11c6f {
    import "block-11C00.typ"
    ("Bhaiksuki", block-11C00.data.at(code - 0x11c00, default: ()))
  } else if 0x11c70 <= code and code <= 0x11cbf {
    import "block-11C70.typ"
    ("Marchen", block-11C70.data.at(code - 0x11c70, default: ()))
  } else if 0x11d00 <= code and code <= 0x11d5f {
    import "block-11D00.typ"
    ("Masaram Gondi", block-11D00.data.at(code - 0x11d00, default: ()))
  } else if 0x11d60 <= code and code <= 0x11daf {
    import "block-11D60.typ"
    ("Gunjala Gondi", block-11D60.data.at(code - 0x11d60, default: ()))
  } else if 0x11ee0 <= code and code <= 0x11eff {
    import "block-11EE0.typ"
    ("Makasar", block-11EE0.data.at(code - 0x11ee0, default: ()))
  } else if 0x11f00 <= code and code <= 0x11f5f {
    import "block-11F00.typ"
    ("Kawi", block-11F00.data.at(code - 0x11f00, default: ()))
  } else if 0x11fb0 <= code and code <= 0x11fbf {
    import "block-11FB0.typ"
    ("Lisu Supplement", block-11FB0.data.at(code - 0x11fb0, default: ()))
  } else if 0x11fc0 <= code and code <= 0x11fff {
    import "block-11FC0.typ"
    ("Tamil Supplement", block-11FC0.data.at(code - 0x11fc0, default: ()))
  } else if 0x12000 <= code and code <= 0x123ff {
    import "block-12000.typ"
    ("Cuneiform", block-12000.data.at(code - 0x12000, default: ()))
  } else if 0x12400 <= code and code <= 0x1247f {
    import "block-12400.typ"
    ("Cuneiform Numbers and Punctuation", block-12400.data.at(code - 0x12400, default: ()))
  } else if 0x12480 <= code and code <= 0x1254f {
    import "block-12480.typ"
    ("Early Dynastic Cuneiform", block-12480.data.at(code - 0x12480, default: ()))
  } else if 0x12f90 <= code and code <= 0x12fff {
    import "block-12F90.typ"
    ("Cypro-Minoan", block-12F90.data.at(code - 0x12f90, default: ()))
  } else if 0x13000 <= code and code <= 0x1342f {
    import "block-13000.typ"
    ("Egyptian Hieroglyphs", block-13000.data.at(code - 0x13000, default: ()))
  } else if 0x13430 <= code and code <= 0x1345f {
    import "block-13430.typ"
    ("Egyptian Hieroglyph Format Controls", block-13430.data.at(code - 0x13430, default: ()))
  } else if 0x13460 <= code and code <= 0x143ff {
    import "block-13460.typ"
    ("Egyptian Hieroglyphs Extended-A", block-13460.data.at(code - 0x13460, default: ()))
  } else if 0x14400 <= code and code <= 0x1467f {
    import "block-14400.typ"
    ("Anatolian Hieroglyphs", block-14400.data.at(code - 0x14400, default: ()))
  } else if 0x16100 <= code and code <= 0x1613f {
    import "block-16100.typ"
    ("Gurung Khema", block-16100.data.at(code - 0x16100, default: ()))
  } else if 0x16800 <= code and code <= 0x16a3f {
    import "block-16800.typ"
    ("Bamum Supplement", block-16800.data.at(code - 0x16800, default: ()))
  } else if 0x16a40 <= code and code <= 0x16a6f {
    import "block-16A40.typ"
    ("Mro", block-16A40.data.at(code - 0x16a40, default: ()))
  } else if 0x16a70 <= code and code <= 0x16acf {
    import "block-16A70.typ"
    ("Tangsa", block-16A70.data.at(code - 0x16a70, default: ()))
  } else if 0x16ad0 <= code and code <= 0x16aff {
    import "block-16AD0.typ"
    ("Bassa Vah", block-16AD0.data.at(code - 0x16ad0, default: ()))
  } else if 0x16b00 <= code and code <= 0x16b8f {
    import "block-16B00.typ"
    ("Pahawh Hmong", block-16B00.data.at(code - 0x16b00, default: ()))
  } else if 0x16d40 <= code and code <= 0x16d7f {
    import "block-16D40.typ"
    ("Kirat Rai", block-16D40.data.at(code - 0x16d40, default: ()))
  } else if 0x16e40 <= code and code <= 0x16e9f {
    import "block-16E40.typ"
    ("Medefaidrin", block-16E40.data.at(code - 0x16e40, default: ()))
  } else if 0x16f00 <= code and code <= 0x16f9f {
    import "block-16F00.typ"
    ("Miao", block-16F00.data.at(code - 0x16f00, default: ()))
  } else if 0x16fe0 <= code and code <= 0x16fff {
    import "block-16FE0.typ"
    ("Ideographic Symbols and Punctuation", block-16FE0.data.at(str(code - 0x16fe0, base: 16), default: ()))
  } else if 0x17000 <= code and code <= 0x187ff {
    import "block-17000.typ"
    ("Tangut", block-17000.data.at(str(code - 0x17000, base: 16), default: ()))
  } else if 0x18800 <= code and code <= 0x18aff {
    import "block-18800.typ"
    ("Tangut Components", block-18800.data.at(code - 0x18800, default: ()))
  } else if 0x18b00 <= code and code <= 0x18cff {
    import "block-18B00.typ"
    ("Khitan Small Script", block-18B00.data.at(code - 0x18b00, default: ()))
  } else if 0x18d00 <= code and code <= 0x18d7f {
    import "block-18D00.typ"
    ("Tangut Supplement", block-18D00.data.at(str(code - 0x18d00, base: 16), default: ()))
  } else if 0x1aff0 <= code and code <= 0x1afff {
    import "block-1AFF0.typ"
    ("Kana Extended-B", block-1AFF0.data.at(code - 0x1aff0, default: ()))
  } else if 0x1b000 <= code and code <= 0x1b0ff {
    import "block-1B000.typ"
    ("Kana Supplement", block-1B000.data.at(code - 0x1b000, default: ()))
  } else if 0x1b100 <= code and code <= 0x1b12f {
    import "block-1B100.typ"
    ("Kana Extended-A", block-1B100.data.at(code - 0x1b100, default: ()))
  } else if 0x1b130 <= code and code <= 0x1b16f {
    import "block-1B130.typ"
    ("Small Kana Extension", block-1B130.data.at(str(code - 0x1b130, base: 16), default: ()))
  } else if 0x1b170 <= code and code <= 0x1b2ff {
    import "block-1B170.typ"
    ("Nushu", block-1B170.data.at(code - 0x1b170, default: ()))
  } else if 0x1bc00 <= code and code <= 0x1bc9f {
    import "block-1BC00.typ"
    ("Duployan", block-1BC00.data.at(code - 0x1bc00, default: ()))
  } else if 0x1bca0 <= code and code <= 0x1bcaf {
    import "block-1BCA0.typ"
    ("Shorthand Format Controls", block-1BCA0.data.at(code - 0x1bca0, default: ()))
  } else if 0x1cc00 <= code and code <= 0x1cebf {
    import "block-1CC00.typ"
    ("Symbols for Legacy Computing Supplement", block-1CC00.data.at(code - 0x1cc00, default: ()))
  } else if 0x1cf00 <= code and code <= 0x1cfcf {
    import "block-1CF00.typ"
    ("Znamenny Musical Notation", block-1CF00.data.at(code - 0x1cf00, default: ()))
  } else if 0x1d000 <= code and code <= 0x1d0ff {
    import "block-1D000.typ"
    ("Byzantine Musical Symbols", block-1D000.data.at(code - 0x1d000, default: ()))
  } else if 0x1d100 <= code and code <= 0x1d1ff {
    import "block-1D100.typ"
    ("Musical Symbols", block-1D100.data.at(code - 0x1d100, default: ()))
  } else if 0x1d200 <= code and code <= 0x1d24f {
    import "block-1D200.typ"
    ("Ancient Greek Musical Notation", block-1D200.data.at(code - 0x1d200, default: ()))
  } else if 0x1d2c0 <= code and code <= 0x1d2df {
    import "block-1D2C0.typ"
    ("Kaktovik Numerals", block-1D2C0.data.at(code - 0x1d2c0, default: ()))
  } else if 0x1d2e0 <= code and code <= 0x1d2ff {
    import "block-1D2E0.typ"
    ("Mayan Numerals", block-1D2E0.data.at(code - 0x1d2e0, default: ()))
  } else if 0x1d300 <= code and code <= 0x1d35f {
    import "block-1D300.typ"
    ("Tai Xuan Jing Symbols", block-1D300.data.at(code - 0x1d300, default: ()))
  } else if 0x1d360 <= code and code <= 0x1d37f {
    import "block-1D360.typ"
    ("Counting Rod Numerals", block-1D360.data.at(code - 0x1d360, default: ()))
  } else if 0x1d400 <= code and code <= 0x1d7ff {
    import "block-1D400.typ"
    ("Mathematical Alphanumeric Symbols", block-1D400.data.at(code - 0x1d400, default: ()))
  } else if 0x1d800 <= code and code <= 0x1daaf {
    import "block-1D800.typ"
    ("Sutton SignWriting", block-1D800.data.at(code - 0x1d800, default: ()))
  } else if 0x1df00 <= code and code <= 0x1dfff {
    import "block-1DF00.typ"
    ("Latin Extended-G", block-1DF00.data.at(code - 0x1df00, default: ()))
  } else if 0x1e000 <= code and code <= 0x1e02f {
    import "block-1E000.typ"
    ("Glagolitic Supplement", block-1E000.data.at(code - 0x1e000, default: ()))
  } else if 0x1e030 <= code and code <= 0x1e08f {
    import "block-1E030.typ"
    ("Cyrillic Extended-D", block-1E030.data.at(code - 0x1e030, default: ()))
  } else if 0x1e100 <= code and code <= 0x1e14f {
    import "block-1E100.typ"
    ("Nyiakeng Puachue Hmong", block-1E100.data.at(code - 0x1e100, default: ()))
  } else if 0x1e290 <= code and code <= 0x1e2bf {
    import "block-1E290.typ"
    ("Toto", block-1E290.data.at(code - 0x1e290, default: ()))
  } else if 0x1e2c0 <= code and code <= 0x1e2ff {
    import "block-1E2C0.typ"
    ("Wancho", block-1E2C0.data.at(code - 0x1e2c0, default: ()))
  } else if 0x1e4d0 <= code and code <= 0x1e4ff {
    import "block-1E4D0.typ"
    ("Nag Mundari", block-1E4D0.data.at(code - 0x1e4d0, default: ()))
  } else if 0x1e5d0 <= code and code <= 0x1e5ff {
    import "block-1E5D0.typ"
    ("Ol Onal", block-1E5D0.data.at(code - 0x1e5d0, default: ()))
  } else if 0x1e7e0 <= code and code <= 0x1e7ff {
    import "block-1E7E0.typ"
    ("Ethiopic Extended-B", block-1E7E0.data.at(code - 0x1e7e0, default: ()))
  } else if 0x1e800 <= code and code <= 0x1e8df {
    import "block-1E800.typ"
    ("Mende Kikakui", block-1E800.data.at(code - 0x1e800, default: ()))
  } else if 0x1e900 <= code and code <= 0x1e95f {
    import "block-1E900.typ"
    ("Adlam", block-1E900.data.at(code - 0x1e900, default: ()))
  } else if 0x1ec70 <= code and code <= 0x1ecbf {
    import "block-1EC70.typ"
    ("Indic Siyaq Numbers", block-1EC70.data.at(code - 0x1ec70, default: ()))
  } else if 0x1ed00 <= code and code <= 0x1ed4f {
    import "block-1ED00.typ"
    ("Ottoman Siyaq Numbers", block-1ED00.data.at(code - 0x1ed00, default: ()))
  } else if 0x1ee00 <= code and code <= 0x1eeff {
    import "block-1EE00.typ"
    ("Arabic Mathematical Alphabetic Symbols", block-1EE00.data.at(code - 0x1ee00, default: ()))
  } else if 0x1f000 <= code and code <= 0x1f02f {
    import "block-1F000.typ"
    ("Mahjong Tiles", block-1F000.data.at(code - 0x1f000, default: ()))
  } else if 0x1f030 <= code and code <= 0x1f09f {
    import "block-1F030.typ"
    ("Domino Tiles", block-1F030.data.at(code - 0x1f030, default: ()))
  } else if 0x1f0a0 <= code and code <= 0x1f0ff {
    import "block-1F0A0.typ"
    ("Playing Cards", block-1F0A0.data.at(code - 0x1f0a0, default: ()))
  } else if 0x1f100 <= code and code <= 0x1f1ff {
    import "block-1F100.typ"
    ("Enclosed Alphanumeric Supplement", block-1F100.data.at(code - 0x1f100, default: ()))
  } else if 0x1f200 <= code and code <= 0x1f2ff {
    import "block-1F200.typ"
    ("Enclosed Ideographic Supplement", block-1F200.data.at(code - 0x1f200, default: ()))
  } else if 0x1f300 <= code and code <= 0x1f5ff {
    import "block-1F300.typ"
    ("Miscellaneous Symbols and Pictographs", block-1F300.data.at(code - 0x1f300, default: ()))
  } else if 0x1f600 <= code and code <= 0x1f64f {
    import "block-1F600.typ"
    ("Emoticons", block-1F600.data.at(code - 0x1f600, default: ()))
  } else if 0x1f650 <= code and code <= 0x1f67f {
    import "block-1F650.typ"
    ("Ornamental Dingbats", block-1F650.data.at(code - 0x1f650, default: ()))
  } else if 0x1f680 <= code and code <= 0x1f6ff {
    import "block-1F680.typ"
    ("Transport and Map Symbols", block-1F680.data.at(code - 0x1f680, default: ()))
  } else if 0x1f700 <= code and code <= 0x1f77f {
    import "block-1F700.typ"
    ("Alchemical Symbols", block-1F700.data.at(code - 0x1f700, default: ()))
  } else if 0x1f780 <= code and code <= 0x1f7ff {
    import "block-1F780.typ"
    ("Geometric Shapes Extended", block-1F780.data.at(code - 0x1f780, default: ()))
  } else if 0x1f800 <= code and code <= 0x1f8ff {
    import "block-1F800.typ"
    ("Supplemental Arrows-C", block-1F800.data.at(code - 0x1f800, default: ()))
  } else if 0x1f900 <= code and code <= 0x1f9ff {
    import "block-1F900.typ"
    ("Supplemental Symbols and Pictographs", block-1F900.data.at(code - 0x1f900, default: ()))
  } else if 0x1fa00 <= code and code <= 0x1fa6f {
    import "block-1FA00.typ"
    ("Chess Symbols", block-1FA00.data.at(code - 0x1fa00, default: ()))
  } else if 0x1fa70 <= code and code <= 0x1faff {
    import "block-1FA70.typ"
    ("Symbols and Pictographs Extended-A", block-1FA70.data.at(code - 0x1fa70, default: ()))
  } else if 0x1fb00 <= code and code <= 0x1fbff {
    import "block-1FB00.typ"
    ("Symbols for Legacy Computing", block-1FB00.data.at(code - 0x1fb00, default: ()))
  } else if 0x20000 <= code and code <= 0x2a6df {
    import "block-20000.typ"
    ("CJK Unified Ideographs Extension B", block-20000.data.at(str(code - 0x20000, base: 16), default: ()))
  } else if 0x2a700 <= code and code <= 0x2b73f {
    import "block-2A700.typ"
    ("CJK Unified Ideographs Extension C", block-2A700.data.at(str(code - 0x2a700, base: 16), default: ()))
  } else if 0x2b740 <= code and code <= 0x2b81f {
    import "block-2B740.typ"
    ("CJK Unified Ideographs Extension D", block-2B740.data.at(str(code - 0x2b740, base: 16), default: ()))
  } else if 0x2b820 <= code and code <= 0x2ceaf {
    import "block-2B820.typ"
    ("CJK Unified Ideographs Extension E", block-2B820.data.at(str(code - 0x2b820, base: 16), default: ()))
  } else if 0x2ceb0 <= code and code <= 0x2ebef {
    import "block-2CEB0.typ"
    ("CJK Unified Ideographs Extension F", block-2CEB0.data.at(str(code - 0x2ceb0, base: 16), default: ()))
  } else if 0x2ebf0 <= code and code <= 0x2ee5f {
    import "block-2EBF0.typ"
    ("CJK Unified Ideographs Extension I", block-2EBF0.data.at(str(code - 0x2ebf0, base: 16), default: ()))
  } else if 0x2f800 <= code and code <= 0x2fa1f {
    import "block-2F800.typ"
    ("CJK Compatibility Ideographs Supplement", block-2F800.data.at(code - 0x2f800, default: ()))
  } else if 0x30000 <= code and code <= 0x3134f {
    import "block-30000.typ"
    ("CJK Unified Ideographs Extension G", block-30000.data.at(str(code - 0x30000, base: 16), default: ()))
  } else if 0x31350 <= code and code <= 0x323af {
    import "block-31350.typ"
    ("CJK Unified Ideographs Extension H", block-31350.data.at(str(code - 0x31350, base: 16), default: ()))
  } else if 0xe0000 <= code and code <= 0xe007f {
    import "block-E0000.typ"
    ("Tags", block-E0000.data.at(code - 0xe0000, default: ()))
  } else if 0xe0100 <= code and code <= 0xe01ef {
    import "block-E0100.typ"
    ("Variation Selectors Supplement", block-E0100.data.at(code - 0xe0100, default: ()))
  } else if 0xf0000 <= code and code <= 0xfffff {
    import "block-F0000.typ"
    ("Supplementary Private Use Area-A", block-F0000.data.at(str(code - 0xf0000, base: 16), default: ()))
  } else if 0x100000 <= code and code <= 0x10ffff {
    import "block-100000.typ"
    ("Supplementary Private Use Area-B", block-100000.data.at(str(code - 0x100000, base: 16), default: ()))
  } else {
    (none, ())
  }
}
