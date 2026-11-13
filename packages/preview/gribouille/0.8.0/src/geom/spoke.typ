///! Directed segments from `(x, y)` along a per-row `(angle, radius)`.
///!
///! Polar counterpart of \@geom-segment. Each row's `(angle, radius)` gives
///! the offset to the segment endpoint via `xend = x + radius * cos(angle)`
///! and `yend = y + radius * sin(angle)`.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha, assert-linetype
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/arrow.typ": assert-arrow, draw-arrow-heads
#import "../utils/linetype-resolve.typ": resolve-linetype
#import "../utils/types.typ": parse-number
#import "../utils/flip.typ": project-user-path, user-axes, user-columns
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

#let spec = (
  reads: (
    "x",
    "y",
    "angle",
    "radius",
    "colour",
    "alpha",
    "linewidth",
    "linetype",
  ),
  extents: none,
)

/// Spoke layer: one segment from `(x, y)` along `(angle, radius)` per row.
///
/// `angle` is a Typst angle (e.g., `45deg`) when supplied as a layer parameter; mapped values are read as numbers in radians from the data. `radius` is the segment length in data units. Under `coord-flip`, the angle still runs from the user's x axis, so the spoke mirrors across the diagonal. Under `coord-radial` a spoke that sweeps theta follows the polar grid as an arc.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`. `angle` and `radius` may be mapped or left to the layer-level fallbacks.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - angle: Layer-level direction (a Typst angle, e.g., `45deg`) used when `aes(angle: ...)` is not mapped.
/// - radius: Layer-level length in data units used when `aes(radius: ...)` is not mapped.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - arrow: Arrowhead spec built with `arrow`, marking the direction each spoke points in. `none` draws no head.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-segment`, `geom-curve`, `arrow`.
///
/// Eight unit-length spokes radiating from the origin at evenly spaced angles.
///
/// ```typst
/// #let d = range(0, 8).map(i => (
///   x: 0, y: 0, angle: i * calc.pi / 4, r: 1,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", angle: "angle", radius: "r"),
///   layers: (geom-spoke(stroke: 1pt),),
///   width: 8cm,
///   height: 8cm,
/// )
/// ```
///
/// A vector field: an `arrow` head turns each spoke into the directed segment the geom is named for. The limits leave room past the tips, since a head at the panel edge is clipped with its line.
///
/// ```typst
/// #let d = range(0, 3).map(i => range(0, 3).map(j => (
///   x: i, y: j, angle: (i + j) * calc.pi / 5, r: 0.6,
/// ))).flatten()
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", angle: "angle", radius: "r"),
///   layers: (geom-spoke(stroke: 1pt, arrow: arrow(length: 6pt)),),
///   scales: scales(
///     x: scale-continuous(limits: (-1, 3)),
///     y: scale-continuous(limits: (-1, 3)),
///   ),
///   width: 8cm,
///   height: 8cm,
/// )
/// ```
#let geom-spoke(
  mapping: none,
  data: none,
  angle: 0deg,
  radius: 1,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  arrow: none,
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-spoke", position)
  assert-alpha("geom-spoke", alpha)
  assert-linetype("geom-spoke", linetype)
  assert-arrow("geom-spoke", arrow)
  make-layer(
    "spoke",
    mapping: mapping,
    data: data,
    params: (
      angle: angle,
      radius: radius,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
      linetype: linetype,
      arrow: arrow,
    )
      + split-aes-params("geom-spoke", args, spec.reads),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

#let _to-angle(v) = if type(v) == angle { v } else { v * 1rad }

#let _row-angle(row, col, fallback-angle) = {
  if col == none { return fallback-angle }
  let v = parse-number(row.at(col, default: none))
  if v == none { fallback-angle } else { v * 1rad }
}

#let _row-radius(row, col, fallback) = {
  if col == none { return fallback }
  let v = parse-number(row.at(col, default: none))
  if v == none { return fallback }
  v
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  // The endpoint offset resolves in the user's x/y space, so under
  // coord-flip the spoke mirrors across the diagonal.
  let cols = user-columns(mapping, ctx)
  let (x-col, y-col) = (cols.x, cols.y)
  if x-col == none or y-col == none { return }
  if user-axes(ctx) == none { return }

  let angle-col = mapping.at("angle", default: none)
  let radius-col = mapping.at("radius", default: none)
  let angle-fallback = _to-angle(layer.params.angle)
  let radius-fallback = layer.params.radius
  // Constant-angle layers compute the trig once and reuse it per row;
  // mapped-angle layers fall back to the per-row branch below.
  let cos-fb = calc.cos(angle-fallback)
  let sin-fb = calc.sin(angle-fallback)

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  let arrow-spec = layer.params.at("arrow", default: none)

  for row in data {
    let x0 = parse-number(row.at(x-col, default: none))
    let y0 = parse-number(row.at(y-col, default: none))
    if x0 == none or y0 == none { continue }
    let r = _row-radius(row, radius-col, radius-fallback)
    let (cos-t, sin-t) = if angle-col == none {
      (cos-fb, sin-fb)
    } else {
      let theta = _row-angle(row, angle-col, angle-fallback)
      (calc.cos(theta), calc.sin(theta))
    }
    let x1 = x0 + r * cos-t
    let y1 = y0 + r * sin-t
    let pts = project-user-path(ctx, ((x0, y0), (x1, y1)))
    if pts.len() < 2 { continue }

    let final-colour = resolve-channel(
      "colour",
      layer.params,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let thickness = resolve-channel(
      "linewidth",
      layer.params,
      mapping,
      ctx,
      row,
      0.8pt,
    )
    cetz.draw.line(
      ..pts,
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: resolve-linetype(layer.params, mapping, ctx, row),
      ),
    )
    draw-arrow-heads(
      pts,
      arrow-spec,
      final-colour,
      thickness,
    )
  }
}
