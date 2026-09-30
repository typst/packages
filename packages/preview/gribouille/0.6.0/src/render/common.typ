// Shared leaf helpers for the render pipeline: mapping/data resolution and
// small per-axis / accumulator primitives used across the render submodules.

#import "../scale/train.typ": mapping-ref-col
#import "../utils/typst-markup.typ": is-typst-markup
#import "../utils/aes-resolve.typ": merge-mapping
#import "../data.typ": _normalise-data

// Flatten a merged aesthetic mapping so geoms receive plain column-name
// strings. Both `mapping-ref` annotations (`as-factor`/`as-numeric`) and
// `typst-markup` annotations (`typst()`) are collapsed; the typst intent
// is captured separately by `_typst-marks-of` so display surfaces can
// honour it. Late-binding markers (`from-theme`, `after-stat`, ...)
// pass through unchanged because `mapping-ref-col` is a no-op on them.
#let _strip-mapping-refs(mapping) = {
  if mapping == none { return none }
  // Fast path: nothing carries a `mapping-ref` annotation.
  let any-ref = false
  for (_, v) in mapping.pairs() {
    if v == none { continue }
    if mapping-ref-col(v) != v {
      any-ref = true
      break
    }
  }
  if not any-ref { return mapping }
  let out = mapping
  for (k, v) in mapping.pairs() {
    if v == none { continue }
    let col = mapping-ref-col(v)
    if col != v { out.insert(k, col) }
  }
  out
}

// Build a dictionary of `(aes-name: true)` entries for every aesthetic
// whose mapping value carries a `typst-markup` tag (at any nesting depth
// inside `mapping-ref` wrappers). Returns an empty dict when nothing is
// typst-tagged.
#let _typst-marks-of(mapping) = {
  if mapping == none { return (:) }
  // Fast path: if no value is typst-tagged we don't allocate at all.
  let any = false
  for (_, v) in mapping.pairs() {
    if v != none and is-typst-markup(v) {
      any = true
      break
    }
  }
  if not any { return (:) }
  let marks = (:)
  for (k, v) in mapping.pairs() {
    if v == none { continue }
    if is-typst-markup(v) { marks.insert(k, true) }
  }
  marks
}

#let _resolve-mapping(layer, plot-mapping) = {
  _strip-mapping-refs(merge-mapping(layer, plot-mapping))
}

// `data-trusted: true` on the layer signals that `layer.data` is already in
// canonical row-store form; the faceted path sets it on per-panel buckets it
// has just produced from a normalised source, avoiding a second validation
// pass over the same rows.
#let _resolve-data(layer, plot-data) = {
  if layer.data == none { return plot-data }
  if type(layer.data) == function {
    return _normalise-data((layer.data)(plot-data))
  }
  if layer.at("data-trusted", default: false) { return layer.data }
  _normalise-data(layer.data)
}

// Per-row min/max accumulator helper used by the `_scan-*` passes.
#let _track-min-max(lo, hi, v) = (
  if lo == none { v } else { calc.min(lo, v) },
  if hi == none { v } else { calc.max(hi, v) },
)

// Resolve every side of an axis-* family into a record keyed by short side
// codes (xb=x-bottom, xt=x-top, yl=y-left, yr=y-right). The builder receives
// `(prefix, side, axis)` so it can either build a full surface key
// (`prefix + "-" + side`) or hand `(prefix, side, axis)` to a cascade.
#let _per-side(builder, prefix) = (
  xb: builder(prefix, "x-bottom", "x"),
  xt: builder(prefix, "x-top", "x"),
  yl: builder(prefix, "y-left", "y"),
  yr: builder(prefix, "y-right", "y"),
)

// Whether a tick draw should emit anything: needs both an active stroke and
// a positive length.
#let _should-draw-tick(stroke, len) = stroke != none and len > 0
