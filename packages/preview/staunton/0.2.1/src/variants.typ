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
    // single-letter abbreviation (lower case) -> kind; case selects color.
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

// Normalise a caller-supplied *inline* variant spec (a dictionary) into the
// canonical `(name, kinds, abbr, cols, rows, glyphs)` shape. This is the "define
// your own piece kinds per call" path (fairy chess): the user passes a dict as
// `variant`, optionally `extends`-ing a registered variant to reuse its kinds and
// letters. The non-overlap rule ("kinds and letters must be non-overlapping") is
// enforced here against the extended base.
#let _resolve-spec(spec) = {
  assert("kinds" in spec or "abbr" in spec or "extends" in spec,
    message: "custom variant spec must have at least `kinds`/`abbr` (or `extends`); got " + repr(spec))
  // `extends` inherits a REGISTERED variant's kinds/letters/geometry as the base.
  let base = if "extends" in spec {
    let e = spec.extends
    assert(type(e) == str and variants.keys().contains(e),
      message: "custom variant: `extends` must be a known variant name (one of " + repr(variants.keys()) + "), got " + repr(e))
    variants.at(e)
  } else {
    (name: "custom", kinds: (), abbr: (:), cols: 8, rows: 8)
  }
  let base-glyphs = base.at("glyphs", default: (:))
  let add-kinds = spec.at("kinds", default: ())
  let add-abbr = spec.at("abbr", default: (:))
  // Non-overlap against the extended base: new kinds and new letters must not
  // collide with the inherited ones (a flat `abbr` dict already forbids a letter
  // mapping to two kinds; this guards the extend seam).
  for k in add-kinds {
    assert(not base.kinds.contains(k),
      message: "custom variant: kind \"" + k + "\" already exists in extended variant \"" + base.name + "\" (kinds must be non-overlapping)")
  }
  for letter in add-abbr.keys() {
    assert(letter not in base.abbr,
      message: "custom variant: piece letter \"" + letter + "\" already used by extended variant \"" + base.name + "\" (letters must be non-overlapping)")
  }
  let kinds = base.kinds + add-kinds
  let abbr = base.abbr + add-abbr
  assert(kinds.len() > 0, message: "custom variant: needs at least one piece kind (a non-empty `kinds`)")
  for (letter, kind) in abbr {
    assert(letter.clusters().len() == 1,
      message: "custom variant: piece letter \"" + letter + "\" must be a single character")
    assert(lower(letter) == letter,
      message: "custom variant: piece letters must be lower case (\"" + letter + "\"); case selects color")
    assert(kinds.contains(kind),
      message: "custom variant: letter \"" + letter + "\" maps to unknown kind \"" + kind + "\" (not in `kinds`)")
  }
  (
    name: spec.at("name", default: base.name),
    kinds: kinds,
    abbr: abbr,
    cols: spec.at("cols", default: base.cols),
    rows: spec.at("rows", default: base.rows),
    glyphs: base-glyphs + spec.at("glyphs", default: (:)),
  )
}

/// The spec dict for a variant. Accepts either a registered variant *name* (a key
/// of `variants`) or an *inline* spec dictionary — the custom-kinds path, e.g.
/// `(extends: "standard", kinds: ("alfil",), abbr: (a: "alfil"))` — which is
/// normalised (and non-overlap-checked) into the canonical spec.
///
/// - variant (str, dictionary): a variant name, or an inline custom spec.
/// -> dictionary
#let variant-spec(variant) = {
  if type(variant) == dictionary { return _resolve-spec(variant) }
  assert(variants.keys().contains(variant), message: "unknown variant: " + repr(variant) + " (known: " + repr(variants.keys()) + ")")
  variants.at(variant)
}

/// Map a single piece character to `(kind, color)` for a variant — uppercase =
/// white, lowercase = black. Errors on an unknown abbreviation.
///
/// - ch (str): a one-character piece abbreviation.
/// - variant (str, dictionary): the variant whose abbreviations to use — a name
///   (default `"standard"`) or an inline custom spec.
/// -> dictionary
#let char-to-piece(ch, variant: "standard") = {
  let spec = variant-spec(variant)
  let key = lower(ch)
  assert(spec.abbr.keys().contains(key), message: "invalid piece char \"" + ch + "\" for variant \"" + spec.name + "\"")
  (kind: spec.abbr.at(key), color: if ch == upper(ch) { "white" } else { "black" })
}

/// Define a reusable custom variant — the named-argument sugar over the inline
/// spec dict (see `variant-spec`). It validates *eagerly* (so a bad letter or an
/// overlap errors at the definition, not at first use) and returns the canonical,
/// normalised spec, which you bind once and pass as `variant:`.
///
/// Typst has no mutable global registry that a position parser could read, so a
/// custom variant is a *value*, not a string key: bind it and reuse it. (Built-in
/// variants such as `"standard"` are still referred to by name.)
///
/// ```typ
/// #let fairy = define-variant("Fairy demo",
///   extends: "standard",
///   kinds: ("alfil", "dabbaba", "ferz"),
///   abbr:  (a: "alfil", d: "dabbaba", f: "ferz"))
/// #board(position((a1: "A"), variant: fairy))
/// ```
///
/// - name (str): a human-readable variant name (shown in error messages).
/// - extends (str, none): a built-in variant to inherit kinds/letters/geometry
///   from (e.g. `"standard"`); `none` for a from-scratch spec.
/// - kinds (array): the piece kinds to ADD (beyond any inherited).
/// - abbr (dictionary): `letter -> kind` for the added kinds — single lower-case
///   letters (case selects color); must not overlap an inherited letter.
/// - glyphs (dictionary): optional `kind -> glyph` fallback entries.
/// - cols (int, auto): board width (default: inherited, else `8`).
/// - rows (int, auto): board height (default: inherited, else `8`).
/// -> dictionary
#let define-variant(name, extends: none, kinds: (), abbr: (:), glyphs: (:), cols: auto, rows: auto) = {
  let spec = (name: name, kinds: kinds, abbr: abbr, glyphs: glyphs)
  if extends != none { spec.insert("extends", extends) }
  if cols != auto { spec.insert("cols", cols) }
  if rows != auto { spec.insert("rows", rows) }
  variant-spec(spec)
}
