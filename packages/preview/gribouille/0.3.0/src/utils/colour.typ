/// Blend two colours.
///
/// `amount` is the fraction of `col2` (0 = pure `col1`, 1 = pure `col2`). Mixing happens in sRGB so `col-mix(black, white, 0.92)` returns `grey92`.
///
/// - col1: Base colour.
/// - col2: Colour to blend in.
/// - amount: Fraction of `col2` in the result (0 to 1).
///
/// Returns: Blended colour.
///
/// Inline blending: half-mix two brand colours.
///
/// ```typst
/// #let purple = col-mix(rgb("#1f77b4"), rgb("#d62728"), 0.5)
/// ```
///
/// Sweeping `amount` from 0 to 1 produces a custom two-stop ramp, rendered as a swatch via `geom-rect`.
///
/// ```typst
/// #let stops = range(0, 9).map(i => col-mix(
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
#let col-mix(col1, col2, amount) = color.mix(
  (col1, 1 - amount),
  (col2, amount),
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

// Resolve a continuous numeric value to a colour, given a trained scale dict
// (with `domain`) and a palette of one or more stops. If the trained spec
// carries a `midpoint`, treat the palette as `(low, mid, high)` and split
// the interpolation at the midpoint. If the spec carries `binned: true`, the
// domain is partitioned into `n-breaks` equal-width bins and the lookup
// snaps to each bin's midpoint, producing a stepped palette.
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
  let t = (value - lo) / (hi - lo)
  if binned { t = _snap-bin(t, n-breaks) }
  interpolate-stops(palette, t)
}
