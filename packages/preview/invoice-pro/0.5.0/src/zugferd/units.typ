// The codes of units given as text (see `resolve-unit` of model.typ): the
// unit names and abbreviations invoice-pro knows. Most invoices give their
// units with the `unit` module, which carry their codes, so model.typ
// loads this module only for the first unit given as text (Typst parses a
// module when it is first imported).

#import "code-lists.typ": lists
#import "../data/unit.typ": unit-db
#import "../locale/lang/lang.typ" as languages

// The UN/ECE Recommendation 20 codes of the units of the `unit` module, by
// their key in the language files.
#let _unit-codes = (
  piece: "H87",
  "set": "SET",
  pair: "PR",
  "lump-sum": "LS",
  hour: "HUR",
  day: "DAY",
  month: "MON",
  year: "ANN",
  kilogram: "KGM",
  gram: "GRM",
  tonne: "TNE",
  metre: "MTR",
  "square-metre": "MTK",
  millimetre: "MMT",
  centimetre: "CMT",
  kilometre: "KMT",
  litre: "LTR",
  "cubic-metre": "MTQ",
)

/// Unit texts and the UN/ECE Recommendation 20 codes they stand for, by the
/// text in lower case without a trailing ".": the symbols and names of the
/// unit database, the unit names of every language of invoice-pro and common
/// abbreviations. Only whole texts match, never a part of one.
///
/// It is built on the first call, which Typst memoizes, and only for an
/// invoice with a unit given as text.
///
/// -> dictionary
#let unit-aliases() = {
  let table = (:)
  for (code, texts) in (
    HUR: ("hr", "hrs", "std", "stunde", "stunden"),
    MIN: ("min", "mins", "minute", "minutes", "minuten"),
    SEC: ("s", "sec", "sek", "second", "seconds", "sekunde", "sekunden"),
    WEE: ("wk", "wks", "week", "weeks", "woche", "wochen"),
    MON: ("mon",),
    ANN: ("yr", "yrs"),
    KGM: ("kilo", "kilos"),
    TNE: ("to", "tonnen"),
    MTR: ("meter", "meters", "lfm"),
    MTK: ("m2", "qm", "sqm", "square meter", "square meters"),
    MTQ: ("m3", "cbm", "cubic meter", "cubic meters"),
    LTR: ("ltr", "liter", "liters"),
    MLT: ("ml",),
    KWH: ("kwh",),
    MWH: ("mwh",),
    H87: ("st", "stk", "stck", "pc", "pcs", "pce"),
    LS: ("psch", "pausch", "pauschal", "flat", "flat rate", "lumpsum"),
    IE: ("person", "persons", "pers", "personen"),
    ZP: ("page", "pages", "seite", "seiten"),
    P1: ("%", "percent", "prozent"),
  ).pairs() {
    for text in texts { table.insert(text, code) }
  }
  // Plurals that the languages list no own form for and that are no singular
  // with "s" (French, Italian and Spanish).
  for (code, texts) in (
    H87: ("pezzi", "unidades"),
    PR: ("paia", "pares"),
    HUR: ("ore",),
    DAY: ("giorni",),
    MON: ("mesi",),
    ANN: ("anni", "année", "années"),
    KGM: ("chilogrammi",),
    GRM: ("grammi",),
    TNE: ("tonnellate",),
    MTR: ("metri",),
    MTK: ("mètres carrés", "metri quadrati", "metros cuadrados"),
    MMT: ("millimetri",),
    CMT: ("centimetri",),
    KMT: ("chilometri",),
    LTR: ("litri",),
    MTQ: ("mètres cubes", "metri cubi", "metros cúbicos"),
  ).pairs() {
    for text in texts { table.insert(text, code) }
  }
  for unit in unit-db {
    if unit.symbol != none { table.insert(lower(unit.symbol), unit.code) }
    table.insert(lower(unit.name), unit.code)
  }
  for strings in (
    languages.de,
    languages.en,
    languages.fr,
    languages.it,
    languages.es,
  ) {
    for (key, names) in strings.units.pairs() {
      let code = _unit-codes.at(key, default: none)
      if code == none { continue }
      // A name, or its singular and plural.
      let names = if type(names) == dictionary { names.values() } else {
        (names,)
      }
      for name in names { table.insert(lower(name), code) }
    }
  }
  table
}

// Unit codes that are also common German abbreviations of other units, with
// what the code means and what the abbreviation stands for. Taken verbatim,
// they most likely do not mean what the code says.
#let _ambiguous-unit-codes = (
  STK: ("stick", "Stück"),
  PAL: ("pascal", "Palette"),
  FL: ("flake ton", "Flasche"),
  GL: ("gram per litre", "Glas"),
  KT: ("kit", "Karton"),
)

/// The UN/ECE Recommendation 20 code of a unit given as text (not empty) as
/// `(code: .., issue: ..)`, see `resolve-unit` of model.typ: a text that is
/// exactly a code (e.g. "H87") is taken as it is, but a code that is also a
/// common abbreviation of another unit (e.g. "STK", the code of sticks) has
/// the issue `(kind: "ambiguous", ..)`. Any other text is looked up in the
/// unit names and abbreviations invoice-pro knows ("Std.", "m²", "qm",
/// "Stück", "pauschal", ...). A text it does not know has the issue
/// `(kind: "unknown", text: ..)` and the code C62 ("one") as placeholder:
/// invoice-pro does not guess what it means.
///
/// -> dictionary
#let resolve-text-unit(text) = {
  // A unit written exactly as a code; case-sensitive, so that "min" is not
  // looked up as the code "MIN" but as an abbreviation (which gives the
  // same).
  if (
    not text.contains(" ") and (" " + text + " ") in lists.unit.every
  ) {
    let ambiguous = _ambiguous-unit-codes.at(text, default: none)
    return (
      code: text,
      issue: if ambiguous != none {
        (
          kind: "ambiguous",
          text: text,
          meaning: ambiguous.first(),
          abbreviation: ambiguous.last(),
        )
      },
    )
  }
  let aliases = unit-aliases()
  let key = lower(text).trim(".", at: end)
  let code = aliases.at(key, default: none)
  // A plural with "s" ("heures", "kgs"), but not "ms" for "m".
  if code == none and key.ends-with("s") and key.clusters().len() > 2 {
    code = aliases.at(key.slice(0, -1), default: none)
  }
  if code != none { return (code: code, issue: none) }
  (code: "C62", issue: (kind: "unknown", text: text))
}
