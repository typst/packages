// ===========================================================================
// Chess variant registry.
//
// A "variant" fixes the vocabulary of piece kinds, the single-letter
// abbreviations used in notation/positions (lower case = black, upper case =
// white), and the default board geometry. Only "standard" (western chess) is
// implemented today; the registry exists so the position model, string parser
// and (later) renderer can be variant-aware without rewrites.
//
// To add a variant later (e.g. xiangqi), add an entry here; nothing else in the
// position layer hardcodes the western piece set.
// ===========================================================================

/// The variant registry: a dict of variant name → spec `(name, kinds, abbr, cols,
/// rows)`. Only `standard` is implemented today.
#let variants = (
  standard: (
    name: "Standard chess",
    kinds: ("king", "queen", "rook", "bishop", "knight", "pawn"),
    // single-letter abbreviation (lower case) -> kind; case selects colour.
    abbr: (k: "king", q: "queen", r: "rook", b: "bishop", n: "knight", p: "pawn"),
    cols: 8,
    rows: 8,
  ),
  // Reserved for the future (NOT implemented): Chinese chess, 9x10.
  //   xiangqi: (name: "Xiangqi", kinds: ("general","advisor","chariot",
  //     "elephant","horse","cannon","soldier"), abbr: (g:"general", a:"advisor",
  //     r:"chariot", e:"elephant", h:"horse", c:"cannon", s:"soldier"),
  //     cols: 9, rows: 10),
)

/// The spec dict for a variant; errors on an unknown variant name.
///
/// - variant (str): a variant name (a key of `variants`).
/// -> dictionary
#let variant-spec(variant) = {
  assert(variants.keys().contains(variant), message: "unknown variant: " + repr(variant) + " (known: " + repr(variants.keys()) + ")")
  variants.at(variant)
}

/// Map a single piece character to `(kind, color)` for a variant — uppercase =
/// white, lowercase = black. Errors on an unknown abbreviation.
///
/// - ch (str): a one-character piece abbreviation.
/// - variant (str): the variant whose abbreviations to use (default
///   `"standard"`).
/// -> dictionary
#let char-to-piece(ch, variant: "standard") = {
  let spec = variant-spec(variant)
  let key = lower(ch)
  assert(spec.abbr.keys().contains(key), message: "invalid piece char \"" + ch + "\" for variant \"" + variant + "\"")
  (kind: spec.abbr.at(key), color: if ch == upper(ch) { "white" } else { "black" })
}
