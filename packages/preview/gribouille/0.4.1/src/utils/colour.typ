/// Blend two colours.
///
/// `amount` is the fraction of `colour2` (0 = pure `colour1`, 1 = pure `colour2`). Mixing happens in sRGB so `colour-mix(black, white, 0.92)` returns `grey92`.
///
/// - colour1: Base colour.
/// - colour2: Colour to blend in.
/// - amount: Fraction of `colour2` in the result (0 to 1).
///
/// Returns: Blended colour.
///
/// Inline blending: half-mix two brand colours.
///
/// ```typst
/// #let purple = colour-mix(rgb("#1f77b4"), rgb("#d62728"), 0.5)
/// ```
///
/// Sweeping `amount` from 0 to 1 produces a custom two-stop ramp, rendered as a swatch via `geom-rect`.
///
/// ```typst
/// #let stops = range(0, 9).map(i => colour-mix(
///   rgb("#1f77b4"), rgb("#d62728"), i / 8,
/// ))
/// #let d = stops.enumerate().map(((i, _)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: str(i),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-manual(values: stops),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let colour-mix(colour1, colour2, amount) = color.mix(
  (colour1, 1 - amount),
  (colour2, amount),
  space: rgb,
)

// Build an n-stop grey ramp from `start` (darker) to `end` (lighter), each
// expressed as a fraction in 0..1 where 0 is black and 1 is white. Returns
// `n` `luma` colours evenly spaced in luminance.
#let grey-palette(n, start: 0.2, end: 0.8) = {
  let count = calc.max(1, int(n))
  if count == 1 { return (luma(start * 100%),) }
  range(count).map(i => {
    let t = i / (count - 1)
    let v = start + t * (end - start)
    luma(v * 100%)
  })
}

// Build an n-stop equally-spaced hue ramp in OKLCh space. `h` is a pair
// `(start, end)` of angles. The first colour sits at `h.at(0)` and
// successive colours step by `(end - start) / n` so the endpoint is
// excluded.
#let hue-palette(n, h: (15deg, 375deg), c: 100, l: 65) = {
  let count = calc.max(1, int(n))
  let (h-lo, h-hi) = h
  let span = h-hi - h-lo
  let step = span / count
  let lightness = calc.max(0, calc.min(100, l)) * 1%
  let chroma-frac = calc.max(0, calc.min(100, c)) / 100
  let chroma = chroma-frac * 0.18 + 0.02
  range(count).map(i => oklch(lightness, chroma, h-lo + step * i))
}

// Walk an n-stop palette: linearly interpolate between consecutive stops to
// turn a normalised position `t` (in 0..1) into a colour. Used by gradientn
// resolvers in the renderer and the legend.
#let interpolate-stops(palette, t) = {
  let n = palette.len()
  if n == 0 { return none }
  if n == 1 { return palette.first() }
  let tc = calc.max(0.0, calc.min(1.0, t))
  if tc <= 0.0 { return palette.first() }
  if tc >= 1.0 { return palette.last() }
  let scaled = tc * (n - 1)
  let i = int(scaled)
  let frac = scaled - i
  let a = palette.at(i)
  let b = palette.at(i + 1)
  a.mix((b, frac * 100%))
}

// Snap a normalised position `t` in 0..1 to the midpoint of one of `n` equal
// bins. Used by binned colour scales to quantise the gradient lookup.
#let _snap-bin(t, n) = {
  let count = calc.max(1, int(n))
  let tc = calc.max(0.0, calc.min(1.0, t))
  let idx = calc.min(count - 1, int(tc * count))
  (idx + 0.5) / count
}

// Resolve the canonical bin edges of a binned scale spec over `[lo, hi]`.
// User `breaks` (an array of >= 2 edges) are taken as-is, sorted; the trained
// domain has already been widened to cover them by the break fold in
// `_train-entry`. Otherwise the domain is cut into `n-breaks` equal-width bins.
// Always returns at least two edges.
#let bin-edges(spec, lo, hi) = {
  let breaks = if spec == none { auto } else {
    spec.at("breaks", default: auto)
  }
  if type(breaks) == array and breaks.len() >= 2 { return breaks.sorted() }
  let n = if spec == none { 5 } else { spec.at("n-breaks", default: 5) }
  let count = calc.max(1, int(n))
  if hi == lo { return (lo, hi) }
  range(count + 1).map(i => lo + i * (hi - lo) / count)
}

// Index of the bin (the `[edge_i, edge_{i+1})` interval) holding `value`, in
// `[0, edges.len() - 2]`. Values at or above the top edge fall in the last bin.
#let bin-index-edges(value, edges) = {
  let last = edges.len() - 2
  if last <= 0 { return 0 }
  let idx = 0
  while idx < last and value >= edges.at(idx + 1) { idx += 1 }
  idx
}

// Midpoints of consecutive edges, e.g. for placing one legend glyph per bin.
#let edge-midpoints(edges) = range(edges.len() - 1).map(i => (
  (edges.at(i) + edges.at(i + 1)) / 2
))

// Resolve a continuous numeric value to a colour, given a trained scale dict
// (with `domain`) and a palette of one or more stops. If the trained spec
// carries a `midpoint`, treat the palette as `(low, mid, high)` and split
// the interpolation at the midpoint. If the spec carries `binned: true`, the
// domain is partitioned into bins (explicit `breaks` edges, else `n-breaks`
// equal-width bins) and the lookup snaps to each bin's midpoint, producing a
// stepped palette. A diverging `midpoint` always uses equal-width bins.
#let resolve-continuous-colour(trained, value, palette, fallback) = {
  if palette == none or palette.len() == 0 { return fallback }
  let (lo, hi) = trained.domain
  if hi == lo { return palette.first() }
  let spec = trained.at("spec", default: none)
  let midpoint = if spec == none { none } else {
    spec.at("midpoint", default: none)
  }
  let binned = if spec == none { false } else {
    spec.at("binned", default: false)
  }
  let n-breaks = if spec == none { 5 } else {
    spec.at("n-breaks", default: 5)
  }
  if midpoint != none and palette.len() >= 3 {
    let low = palette.first()
    let mid = palette.at(1)
    let high = palette.last()
    if value <= midpoint {
      let span = midpoint - lo
      if span <= 0 { return mid }
      let t = calc.max(0.0, calc.min(1.0, (value - lo) / span))
      if binned { t = _snap-bin(t, n-breaks) }
      if t <= 0.0 { return low }
      if t >= 1.0 { return mid }
      return low.mix((mid, t * 100%))
    }
    let span = hi - midpoint
    if span <= 0 { return mid }
    let t = calc.max(0.0, calc.min(1.0, (value - midpoint) / span))
    if binned { t = _snap-bin(t, n-breaks) }
    if t <= 0.0 { return mid }
    if t >= 1.0 { return high }
    return mid.mix((high, t * 100%))
  }
  let breaks = if spec == none { auto } else {
    spec.at("breaks", default: auto)
  }
  if binned and type(breaks) == array {
    let edges = bin-edges(spec, lo, hi)
    // Palette position is the bin's midpoint in palette space, so colours are
    // spaced evenly regardless of (possibly non-uniform) bin widths.
    let idx = bin-index-edges(value, edges)
    return interpolate-stops(
      palette,
      (idx + 0.5) / calc.max(1, edges.len() - 1),
    )
  }
  let t = (value - lo) / (hi - lo)
  if binned { t = _snap-bin(t, n-breaks) }
  interpolate-stops(palette, t)
}
