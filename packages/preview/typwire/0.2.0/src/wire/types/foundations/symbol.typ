#import "../../utils.typ": is-debug-assert, unescape-repr-content

#let type-name = "symbol"

// A symbol's `repr` is `symbol(` followed by a comma-separated list of
// either a bare `"glyph"` (the modifier-less/default variant, at most one)
// or `("dotted.modifiers", "glyph")` tuples, then `)`. Modifiers are plain
// dot-joined identifiers (no escaping possible there), but `glyph` uses the
// same escaped-string-literal form as any other `repr`'d string, so the
// second capture group needs the same "quote or backslash, or anything
// else" alternation `path.typ`/`unescape-repr-content` already handle.
//
// This only ever matches the parenthesized tuples, deliberately skipping
// the bare default entry -- `encode` gets that one from `str(value)`
// instead, which is documented, stable API, rather than depending on
// `repr`'s exact (undocumented, unstable) formatting for it too.
#let variant-pattern = regex(
  "\\(\\s*\"([^\"]*)\"\\s*,\\s*\"((?:[^\"\\\\]|\\\\.)*)\"\\s*\\)",
)

/// Encode a symbol into a CBOR-compatible dictionary. A symbol can carry a
/// whole table of named modifier variants (e.g. `sym.arrow.r` also covers
/// `.double`, `.long`, `.squiggly`, ...); Typst exposes no way to
/// enumerate them from script, but `repr` prints the full table as Typst
/// source (`symbol("→", ("double", "⇒"), ...)`), so `variant-pattern`
/// picks the `(modifiers, glyph)` tuples back out of that text -- parsing
/// a small, well-defined grammar, not `eval`ing it.
///
/// -> dictionary
#let encode(
  /// A symbol.
  ///
  /// -> symbol
  value,
  /// The wire format being encoded for. Unused -- `symbol` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == symbol,
      message: "symbol.encode: value must be of type symbol",
    )
  }

  let variants = repr(value)
    .matches(variant-pattern)
    .map(m => (
      modifiers: m.captures.at(0),
      glyph: unescape-repr-content(m.captures.at(1)),
    ))

  (
    typwire-type: type-name,
    default: str(value),
    variants: variants,
  )
}

/// Decode a CBOR-compatible dictionary into a symbol.
///
/// The result is functionally equivalent to the original -- `str(...)` and
/// modifier field access (`.some-modifier`) both agree with it -- but is
/// never `==` to a built-in (`sym.*`/`emoji.*`) original, even with every
/// variant faithfully restored: built-in symbols and anything `symbol(...)`
/// constructs are different internal representations in Typst itself, and
/// nothing puts them back into the same one. Reconstructing a symbol that
/// was itself built with `symbol(...)` (i.e. not one of Typst's own
/// predefined ones) round-trips `==`-equal, as long as its variants are
/// restored in the same order `encode` saw them in -- which they always
/// are, since both `repr` and this decode walk the variant list in the same
/// order.
///
/// -> symbol
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `symbol` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "symbol.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.default) == str,
      message: "symbol.decode: value.default must be of type str, Found "
        + str(type(value.default)),
    )
    assert(
      value.default.clusters().len() == 1,
      message: "symbol.decode: value.default must be exactly one grapheme cluster",
    )
    assert(
      type(value.variants) == array,
      message: "symbol.decode: value.variants must be of type array, Found "
        + str(type(value.variants)),
    )
  }

  symbol(value.default, ..value.variants.map(v => (v.modifiers, v.glyph)))
}
