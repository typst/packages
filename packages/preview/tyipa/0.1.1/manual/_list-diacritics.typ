/// Display listing of tyipa diacritic functions.
/// 
/// This file was auto-generated. Re-run the package's
/// `./util/make-diacritics.py` script if you have
/// updated the definitions in `./src/_diacritics.csv`.
/// 
/// File generated on: 2025-07-05T12:16:57
/// Definitions included: 52

#import "../src/lib.typ" as ipa
#import "_display-layouts.typ": display-diac


== Phonation

#display-diac(
  ipa.diac.aspirated(ipa.sym.placeholder),
  "aspirated(base: str | symbol)",
  "Superscript h",
  "Aspirated",
  escape: "\\u{2b0}",
)
#display-diac(
  ipa.diac.breathy(ipa.sym.placeholder),
  "breathy(base: str | symbol)",
  "Subscript umlaut",
  "Breathy voiced",
  escape: "\\u{324}",
)
#display-diac(
  ipa.diac.creaky(ipa.sym.placeholder),
  "creaky(base: str | symbol)",
  "Subscript tilde",
  "Creaky voiced",
  escape: "\\u{330}",
)
#display-diac(
  ipa.diac.voiced(ipa.sym.placeholder),
  "voiced(base: str | symbol)",
  "Subscript wedge",
  "Voiced",
  escape: "\\u{32c}",
)
#display-diac(
  ipa.diac.voiceless-above(ipa.sym.placeholder),
  "voiceless-above(base: str | symbol)",
  "Over-ring",
  "Voiceless (above)",
  escape: "\\u{30a}",
)
#display-diac(
  ipa.diac.voiceless-below(ipa.sym.placeholder),
  "voiceless-below(base: str | symbol)",
  "Under-ring",
  "Voiceless",
  escape: "\\u{325}",
  aliases: ("voiceless(base: str | symbol)",),
)

== Place Of Articulation

#display-diac(
  ipa.diac.apical(ipa.sym.placeholder),
  "apical(base: str | symbol)",
  "Inverted subscript bridge",
  "Apical",
  escape: "\\u{33a}",
)
#display-diac(
  ipa.diac.dental(ipa.sym.placeholder),
  "dental(base: str | symbol)",
  "Subscript bridge",
  "Dental",
  escape: "\\u{32a}",
)
#display-diac(
  ipa.diac.laminal(ipa.sym.placeholder),
  "laminal(base: str | symbol)",
  "Subscript square",
  "Laminal",
  escape: "\\u{33b}",
)
#display-diac(
  ipa.diac.linguolabial(ipa.sym.placeholder),
  "linguolabial(base: str | symbol)",
  "Subscript seagull",
  "Linguolabial",
  escape: "\\u{33c}",
)

== Quality

#display-diac(
  ipa.diac.advanced(ipa.sym.placeholder),
  "advanced(base: str | symbol)",
  "Subscript plus",
  "Advanced",
  escape: "\\u{31f}",
)
#display-diac(
  ipa.diac.atr(ipa.sym.placeholder),
  "atr(base: str | symbol)",
  "Advancing sign",
  "Advanced tongue root (ATR)",
  escape: "\\u{318}",
)
#display-diac(
  ipa.diac.centralized(ipa.sym.placeholder),
  "centralized(base: str | symbol)",
  "Umlaut",
  "Centralized",
  escape: "\\u{308}",
)
#display-diac(
  ipa.diac.labialized(ipa.sym.placeholder),
  "labialized(base: str | symbol)",
  "Superscript w",
  "Labialized",
  escape: "\\u{2b7}",
)
#display-diac(
  ipa.diac.less-rounded(ipa.sym.placeholder),
  "less-rounded(base: str | symbol)",
  "Subscript left half-ring",
  "Less rounded",
  escape: "\\u{31c}",
)
#display-diac(
  ipa.diac.lowered(ipa.sym.placeholder),
  "lowered(base: str | symbol)",
  "Lowering sign",
  "Lowered",
  escape: "\\u{31e}",
)
#display-diac(
  ipa.diac.mid-centralized(ipa.sym.placeholder),
  "mid-centralized(base: str | symbol)",
  "Over-cross",
  "Mid-centralized",
  escape: "\\u{33d}",
)
#display-diac(
  ipa.diac.more-rounded(ipa.sym.placeholder),
  "more-rounded(base: str | symbol)",
  "Subscript right half-ring",
  "More rounded",
  escape: "\\u{339}",
)
#display-diac(
  ipa.diac.nasalized(ipa.sym.placeholder),
  "nasalized(base: str | symbol)",
  "Superscript tilde",
  "Nasalized",
  escape: "\\u{303}",
)
#display-diac(
  ipa.diac.palatalized(ipa.sym.placeholder),
  "palatalized(base: str | symbol)",
  "Superscript j",
  "Palatalized",
  escape: "\\u{2b2}",
)
#display-diac(
  ipa.diac.pharyngealized(ipa.sym.placeholder),
  "pharyngealized(base: str | symbol)",
  "Superscript reversed glottal stop",
  "Pharyngealized",
  escape: "\\u{2e4}",
)
#display-diac(
  ipa.diac.raised(ipa.sym.placeholder),
  "raised(base: str | symbol)",
  "Raising sign",
  "Raised",
  escape: "\\u{31d}",
)
#display-diac(
  ipa.diac.retracted(ipa.sym.placeholder),
  "retracted(base: str | symbol)",
  "Under-bar",
  "Retracted",
  escape: "\\u{320}",
)
#display-diac(
  ipa.diac.rhotic(ipa.sym.placeholder),
  "rhotic(base: str | symbol)",
  "Right hook",
  "Rhoticity",
  escape: "\\u{2de}",
)
#display-diac(
  ipa.diac.retroflex(ipa.sym.placeholder),
  "retroflex(base: str | symbol)",
  "Retroflex hook",
  "Diacritic retroflexion",
  escape: "\\u{322}",
)
#display-diac(
  ipa.diac.rtr(ipa.sym.placeholder),
  "rtr(base: str | symbol)",
  "Retracting sign",
  "Retracted tongue root (RTR)",
  escape: "\\u{319}",
)
#display-diac(
  ipa.diac.velarized(ipa.sym.placeholder),
  "velarized(base: str | symbol)",
  "Superscript gamma",
  "Velarized",
  escape: "\\u{2e0}",
)
#display-diac(
  ipa.diac.velopharyngealized(ipa.sym.placeholder),
  "velopharyngealized(base: str | symbol)",
  "Superimposed tilde",
  "Velarized or pharyngealized",
  escape: "\\u{334}",
  aliases: ("dark(base: str | symbol)",),
)

== Quantity

#display-diac(
  ipa.diac.extra-short(ipa.sym.placeholder),
  "extra-short(base: str | symbol)",
  "Breve",
  "Extra-short",
  escape: "\\u{306}",
)
#display-diac(
  ipa.diac.half-long(ipa.sym.placeholder),
  "half-long(base: str | symbol)",
  "Half-length mark",
  "Half-long",
  escape: "\\u{2d1}",
)
#display-diac(
  ipa.diac.long(ipa.sym.placeholder),
  "long(base: str | symbol)",
  "Length mark",
  "Long",
  escape: "\\u{2d0}",
)

== Release

#display-diac(
  ipa.diac.ejective(ipa.sym.placeholder),
  "ejective(base: str | symbol)",
  "Apostrophe",
  "Ejective",
  escape: "\\u{2bc}",
)
#display-diac(
  ipa.diac.lateral-release(ipa.sym.placeholder),
  "lateral-release(base: str | symbol)",
  "Superscript l",
  "Lateral release",
  escape: "\\u{2e1}",
)
#display-diac(
  ipa.diac.nasal-release(ipa.sym.placeholder),
  "nasal-release(base: str | symbol)",
  "Superscript n",
  "Nasal release",
  escape: "\\u{207f}",
)
#display-diac(
  ipa.diac.no-release(ipa.sym.placeholder),
  "no-release(base: str | symbol)",
  "Corner",
  "No audible release",
  escape: "\\u{31a}",
)

== Segmentation

#display-diac(
  ipa.diac.tied-above(ipa.sym.placeholder + ipa.sym.placeholder),
  "tied-above(base: str)",
  "Top tie bar",
  "Tie bar (above)",
  escape: "\\u{361}",
  aliases: ("tied(base: str)",),
  note: "Expects an argument of length exactly 2.",
)
#display-diac(
  ipa.diac.tied-below(ipa.sym.placeholder + ipa.sym.placeholder),
  "tied-below(base: str)",
  "Bottom tie bar",
  "Tie bar (below)",
  escape: "\\u{35c}",
  note: "Expects an argument of length exactly 2.",
)

== Syllabicity

#display-diac(
  ipa.diac.non-syllabic(ipa.sym.placeholder),
  "non-syllabic(base: str | symbol)",
  "Subscript arch",
  "Non-syllabic",
  escape: "\\u{32f}",
)
#display-diac(
  ipa.diac.syllabic(ipa.sym.placeholder),
  "syllabic(base: str | symbol)",
  "Syllabicity mark",
  "Syllabic",
  escape: "\\u{329}",
)

== Tone

#display-diac(
  ipa.diac.extra-high(ipa.sym.placeholder),
  "extra-high(base: str | symbol)",
  "Double acute accent (over)",
  "Extra high level tone",
  escape: "\\u{30b}",
)
#display-diac(
  ipa.diac.extra-low(ipa.sym.placeholder),
  "extra-low(base: str | symbol)",
  "Double grave accent (over)",
  "Extra low level tone",
  escape: "\\u{30f}",
)
#display-diac(
  ipa.diac.falling(ipa.sym.placeholder),
  "falling(base: str | symbol)",
  "Circumflex",
  "Falling contour tone",
  escape: "\\u{302}",
)
#display-diac(
  ipa.diac.falling-rising(ipa.sym.placeholder),
  "falling-rising(base: str | symbol)",
  "Acute + grave + acute accent",
  "Falling-rising contour tone",
  escape: "\\u{1dc9}",
)
#display-diac(
  ipa.diac.high(ipa.sym.placeholder),
  "high(base: str | symbol)",
  "Acute accent (over)",
  "High level tone",
  escape: "\\u{301}",
)
#display-diac(
  ipa.diac.high-mid-falling(ipa.sym.placeholder),
  "high-mid-falling(base: str | symbol)",
  "Acute accent + macron",
  "High-mid falling contour tone",
  escape: "\\u{1dc7}",
)
#display-diac(
  ipa.diac.high-rising(ipa.sym.placeholder),
  "high-rising(base: str | symbol)",
  "Macron + acute accent",
  "High rising contour tone",
  escape: "\\u{1dc4}",
)
#display-diac(
  ipa.diac.low(ipa.sym.placeholder),
  "low(base: str | symbol)",
  "Grave accent (over)",
  "Low level tone",
  escape: "\\u{300}",
)
#display-diac(
  ipa.diac.low-rising(ipa.sym.placeholder),
  "low-rising(base: str | symbol)",
  "Grave accent + macron",
  "Low rising contour tone",
  escape: "\\u{1dc5}",
)
#display-diac(
  ipa.diac.mid(ipa.sym.placeholder),
  "mid(base: str | symbol)",
  "Macron",
  "Mid level tone",
  escape: "\\u{304}",
)
#display-diac(
  ipa.diac.mid-low-falling(ipa.sym.placeholder),
  "mid-low-falling(base: str | symbol)",
  "Macron + grave accent",
  "Mid-low falling contour tone",
  escape: "\\u{1dc6}",
)
#display-diac(
  ipa.diac.rising(ipa.sym.placeholder),
  "rising(base: str | symbol)",
  "Wedge, hacek",
  "Rising contour tone",
  escape: "\\u{30c}",
)
#display-diac(
  ipa.diac.rising-falling(ipa.sym.placeholder),
  "rising-falling(base: str | symbol)",
  "Grave + acute + grave accent",
  "Rising-falling contour tone",
  escape: "\\u{1dc8}",
)
