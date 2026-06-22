///! Random horizontal and vertical offset.
///!
///! Useful for revealing overplotted points by spreading them out by a
///! small amount. Offsets are deterministic for a given `seed` so renders
///! are reproducible.

#import "../utils/types.typ": parse-number

/// Random per-row offset on x and y.
///
/// `width` and `height` cap the absolute jitter in data units. The same `seed` always produces the same offsets, so the figure is stable across renders.
///
/// Only continuous (numeric) columns are jittered: a discrete x is left alone. Users wanting jitter over a discrete axis should map the column via `as-numeric` first.
///
/// - width: Maximum absolute jitter applied to the x position.
/// - height: Maximum absolute jitter applied to the y position.
/// - seed: Integer seed for the deterministic pseudo-random offsets.
///
/// Returns: Position dictionary with `name: "jitter"`, consumed by `plot`.
///
/// See also: `position-nudge`, `geom-jitter`.
///
/// Spread overplotted points with the default jitter amount.
///
/// ```typst
/// #let d = ()
/// #for x in (1, 2, 3) {
///   for _ in range(0, 12) { d.push((x: x, y: 1)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-jitter(size: 2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Tighten `width` and zero `height` to keep jitter purely horizontal; bump `seed` to draw a different reproducible cloud.
///
/// ```typst
/// #let d = ()
/// #for x in (1, 2, 3) {
///   for _ in range(0, 12) { d.push((x: x, y: 1)) }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(
///     size: 2pt,
///     position: position-jitter(width: 0.15, height: 0, seed: 7),
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-jitter(width: 0.4, height: 0.4, seed: 0) = (
  kind: "position",
  name: "jitter",
  params: (width: width, height: height, seed: seed),
)

// Deterministic pseudo-random in [-1, 1) seeded by an integer index. Uses
// the standard sin-fract noise trick so renders are reproducible without
// any RNG state.
#let _noise(seed) = {
  let v = calc.sin(seed * 12.9898 + 78.233) * 43758.5453
  let r = v - calc.floor(v)
  r * 2 - 1
}

#let apply(data, mapping, params: (:), coord: none) = {
  let width = params.at("width", default: 0.4)
  let height = params.at("height", default: 0.4)
  let seed = params.at("seed", default: 0)
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let new-data = data
    .enumerate()
    .map(((i, row)) => {
      let r = row
      if x-col != none and width != 0 {
        let v = parse-number(row.at(x-col, default: none))
        if v != none { r.insert(x-col, v + _noise(i + seed) * width) }
      }
      if y-col != none and height != 0 {
        let v = parse-number(row.at(y-col, default: none))
        if v != none {
          r.insert(y-col, v + _noise(i + seed + 1000) * height)
        }
      }
      r
    })
  (data: new-data, mapping: mapping)
}
