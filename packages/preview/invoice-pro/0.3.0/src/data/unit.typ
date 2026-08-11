#let new(code, symbol, name: none, description: none) = (
  code: code,
  symbol: symbol,
  name: name,
  description: description,
)

// Subset of:
//    CODES FOR UNITS OF MEASURE USED IN INTERNATIONAL TRADE Revision 17
//    (UNECE/CEFACT Trade Facilitation Recommendation No.20)
#let unit-db = (
  // Amount
  (
    code: "H87",
    symbol: none,
    name: "piece",
    description: "A unit of count defining the number of pieces (piece: a single item, article or exemplar).",
  ),
  (
    code: "SET",
    symbol: none,
    name: "set",
    description: "A unit of count defining the number of sets (set: a number of objects grouped together).",
  ),
  (
    code: "PR",
    symbol: none,
    name: "pair",
    description: "A unit of count defining the number of pairs (pair: item described by two's).",
  ),
  (
    code: "LS",
    symbol: none,
    name: "lump sum",
    description: "A unit of count defining the number of whole or a complete monetary amounts.",
  ),

  // Time
  (code: "HUR", symbol: "h", name: "hour", description: none),
  (code: "DAY", symbol: "d", name: "day", description: none),
  (
    code: "MON",
    symbol: "mo",
    name: "month",
    description: "Unit of time equal to 1/12 of a year of 365,25 days.",
  ),
  (
    code: "ANN",
    symbol: "y",
    name: "year",
    description: "Unit of time equal to 365,25 days.
Synonym: Julian year",
  ),

  // Weight
  (
    code: "KGM",
    symbol: "kg",
    name: "kilogram",
    description: "A unit of mass equal to one thousand grams.",
  ),
  (code: "GRM", symbol: "g", name: "gram", description: none),
  (
    code: "TNE",
    symbol: "t",
    name: "tonne (metric ton)",
    description: "Synonym: metric ton",
  ),

  // Length & Area
  (code: "MTR", symbol: "m", name: "metre", description: none),
  (code: "MTK", symbol: "m²", name: "square metre", description: none),
  (code: "MMT", symbol: "mm", name: "millimetre", description: none),
  (code: "CMT", symbol: "cm", name: "centimetre", description: none),
  (code: "KMT", symbol: "km", name: "kilometre", description: none),

  // Volume
  (code: "LTR", symbol: "l", name: "litre", description: none),
  (
    code: "MTQ",
    symbol: "m³",
    name: "cubic metre",
    description: "Synonym: metre cubed",
  ),
)

#let find-unit(query) = {
  if query == none or query == "" { return none }

  let q = lower(str(query))

  let match = unit-db.find(u => lower(u.code) == q)
  if match != none { return match }

  match = unit-db.find(u => u.symbol != none and lower(u.symbol) == q)
  if match != none { return match }

  match = unit-db.find(u => u.name != none and q in lower(u.name))
  if match != none { return match }

  return none
}

#let to-unit(value) = {
  if type(value) == str { return find-unit(value) }
  return value
}
