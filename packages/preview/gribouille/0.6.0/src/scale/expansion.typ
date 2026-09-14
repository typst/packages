///! Scale expansion plumbing for positional scales.
///!
///! Positional scales (`scale-continuous`, `scale-continuous`,
///! `scale-discrete`, `scale-discrete`, `scale-binned`, `scale-binned`,
///! `scale-date`, etc.) expose an `expand:` argument that pads the data
///! domain so points are not flush against the panel edges.
///!
///! Each side accepts a `ratio` (multiplicative breathing room, proportional
///! to the data span), a `length` (absolute canvas-cm padding), or a
///! `relative` value combining both. Pass a 2-tuple `(lo, hi)` to set the
///! sides independently, where either element may be `auto` to keep the
///! per-scale default on that side. `auto` resolves to a sensible per-scale
///! default; `false` and `none` collapse to zero.

#import "../utils/errors.typ": fail

#let _resolve-piece(piece) = {
  if piece == 0 { return (0, 0) }
  let t = type(piece)
  if t == ratio { return (piece / 100%, 0) }
  if t == length { return (0, piece / 1cm) }
  if t == relative { return (piece.ratio / 100%, piece.length / 1cm) }
  fail(
    "expand",
    "expected a ratio (e.g., 5%), length (e.g., 5pt), or relative; got "
      + repr(piece),
  )
}

// Continuous scales get 5% breathing room on each side. Discrete scales get
// no multiplicative or canvas-space padding by default; the data-unit slot
// padding (0.6 of one level) is applied by the renderer when `expand` is
// `auto`, so it can be overridden by passing any explicit value.
#let _default-for(scale-type) = {
  if scale-type == "discrete" { return (0, 0, 0, 0) }
  (0.05, 0, 0.05, 0)
}

// Default extra padding (in data units) added to discrete axes when the user
// leaves `expand` at `auto`. Each level sits at integer 0..n-1, so 0.6 means
// ~60% of one slot on each side.
#let DISCRETE-AUTO-DATA-PAD = 0.6

// Coerce a user-provided `expand:` value into the canonical 4-tuple
// `(mult-lo, add-cm-lo, mult-hi, add-cm-hi)`. `mult-*` is a unitless ratio
// (e.g., 0.05 for 5%); `add-cm-*` is a canvas-cm length (e.g., `5pt / 1cm`).
#let normalise-expansion(value, scale-type) = {
  if value == auto { return _default-for(scale-type) }
  if value == false or value == none { return (0, 0, 0, 0) }
  let (lo, hi) = if type(value) == array and value.len() == 2 {
    (value.at(0), value.at(1))
  } else {
    (value, value)
  }
  let defaults = _default-for(scale-type)
  let (mult-lo, add-lo) = if lo == auto {
    (defaults.at(0), defaults.at(1))
  } else { _resolve-piece(lo) }
  let (mult-hi, add-hi) = if hi == auto {
    (defaults.at(2), defaults.at(3))
  } else { _resolve-piece(hi) }
  (mult-lo, add-lo, mult-hi, add-hi)
}
