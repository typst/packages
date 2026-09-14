// Level-to-value resolution for legend glyph composition.
//
// Each aesthetic maps a value (a discrete level string or a continuous number)
// to a visual quantity: a colour, a shape keyword, a dash keyword, a size
// length, an opacity, or a stroke thickness. The geom drawing path uses the
// per-row resolvers in `colour-resolve.typ`/`fill-resolve.typ`; the legend
// path needs the same answer keyed by *level* rather than by row, so this
// module exposes a thin level-driven kernel that the swatch composer can call.
//
// Returns `none` when the aesthetic cannot be resolved (e.g., continuous
// linetype is meaningless): the caller treats `none` as "drop this aesthetic
// from the composed glyph".

#import "./colour.typ": resolve-continuous-colour
#import "./palette.typ": (
  default-linetypes, default-shapes, palette-at, spec-palette,
)
#import "../scale/train.typ": map-continuous

#let spec-range(trained, fallback) = {
  let spec = trained.at("spec", default: none)
  if spec == none { return fallback }
  spec.at("range", default: fallback)
}

#let discrete-index(trained, level) = {
  let s = str(level)
  let lookup = trained.at("level-index", default: none)
  if lookup == none { trained.domain.position(v => v == s) } else {
    lookup.at(s, default: none)
  }
}

#let discrete-numeric(trained, level, range) = {
  let n = trained.domain.len()
  if n == 0 { return none }
  let (lo, hi) = range
  if n == 1 { return (lo + hi) / 2 }
  let idx = discrete-index(trained, level)
  if idx == none { return none }
  lo + idx * (hi - lo) / (n - 1)
}

#let continuous-numeric(trained, value, range) = {
  let (d-lo, d-hi) = trained.domain
  let (lo, hi) = range
  if d-hi == d-lo { return (lo + hi) / 2 }
  let t = (value - d-lo) / (d-hi - d-lo)
  let t-clamped = if t < 0 { 0 } else if t > 1 { 1 } else { t }
  lo + t-clamped * (hi - lo)
}

// Discretise a continuous value into one of `n-breaks` equal-width bins over
// `[lo, hi]`. Returns an integer in `[0, n-breaks - 1]`.
#let bin-index(value, lo, hi, n-breaks) = {
  if n-breaks <= 1 or hi == lo { return 0 }
  let t = (value - lo) / (hi - lo)
  let raw = int(calc.floor(t * n-breaks))
  if raw < 0 { 0 } else if raw >= n-breaks { n-breaks - 1 } else { raw }
}

// Resolve a binned-continuous trained scale to a palette entry. Returns
// `none` when the trained scale is not binned (caller falls back to its own
// default).
#let resolve-binned(trained, value, fallback-palette) = {
  let spec = trained.at("spec", default: none)
  if spec == none or not spec.at("binned", default: false) { return none }
  let pal = spec-palette(trained, fallback-palette)
  if pal == none or pal.len() == 0 { return none }
  let (lo, hi) = trained.domain
  let n = spec.at("n-breaks", default: 4)
  palette-at(pal, bin-index(value, lo, hi, n))
}

// Colour/fill: palette-driven on discrete; continuous mapper on numeric.
#let _resolve-colour-aes(trained, value, palette, ink) = {
  let pal = spec-palette(trained, palette)
  if pal == none { return ink }
  if trained.type == "discrete" {
    let idx = discrete-index(trained, value)
    if idx == none { return ink }
    return palette-at(pal, idx)
  }
  resolve-continuous-colour(trained, value, pal, ink)
}

// Shape / linetype: palette-driven on discrete; binned on numeric (returns
// `none` when the trained scale is not binned, which is treated as
// "drop this aesthetic" by the caller).
#let _resolve-palette-aes(trained, value, fallback-palette) = {
  if trained.type == "discrete" {
    let idx = discrete-index(trained, value)
    if idx == none { return none }
    return palette-at(spec-palette(trained, fallback-palette), idx)
  }
  resolve-binned(trained, value, fallback-palette)
}

// Size / linewidth / stroke / alpha: numeric range; discrete uses the
// trained spec's palette when present, else equal-spacing across the range.
#let _resolve-numeric-aes(trained, value, range-fallback) = {
  let range = spec-range(trained, range-fallback)
  if trained.type == "discrete" {
    let pal = spec-palette(trained, none)
    if pal != none and pal.len() > 0 {
      let idx = discrete-index(trained, value)
      if idx == none { return none }
      return palette-at(pal, idx)
    }
    return discrete-numeric(trained, value, range)
  }
  continuous-numeric(trained, value, range)
}

// Per-aesthetic dispatch table. Each entry is a closure
// `(trained, value, palette, ink) -> resolved` so the public `resolve-level`
// only does table lookup + identity / none handling.
#let _RESOLVERS = (
  colour: (t, v, p, ink) => _resolve-colour-aes(t, v, p, ink),
  fill: (t, v, p, ink) => _resolve-colour-aes(t, v, p, ink),
  shape: (t, v, _, _) => _resolve-palette-aes(t, v, default-shapes),
  linetype: (t, v, _, _) => _resolve-palette-aes(t, v, default-linetypes),
  size: (t, v, _, _) => _resolve-numeric-aes(t, v, (1pt, 6pt)),
  linewidth: (t, v, _, _) => _resolve-numeric-aes(t, v, (0.4pt, 1.4pt)),
  stroke: (t, v, _, _) => _resolve-numeric-aes(t, v, (0.2pt, 1.4pt)),
  alpha: (t, v, _, _) => _resolve-numeric-aes(t, v, (0.1, 1)),
)

// Resolve a single aesthetic for a given value. `value` is a discrete level
// string when `trained.type == "discrete"` and a number when continuous.
//
// `palette` overrides the trained spec's palette where the aesthetic is
// palette-driven (colour/fill); pass `none` to use the trained spec or the
// library default.
#let resolve-level(aesthetic, trained, value, palette: none, ink: black) = {
  if trained == none { return none }
  if trained.type == "identity" { return value }
  let handler = _RESOLVERS.at(aesthetic, default: none)
  if handler == none { return none }
  handler(trained, value, palette, ink)
}
