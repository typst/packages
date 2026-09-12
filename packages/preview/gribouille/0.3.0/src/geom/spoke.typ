///! Directed segments from `(x, y)` along a per-row `(angle, radius)`.
///!
///! Polar counterpart of \@geom-segment. Each row's `(angle, radius)` gives
///! the offset to the segment endpoint via `xend = x + radius * cos(angle)`
///! and `yend = y + radius * sin(angle)`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/radial.typ": project-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

/// Spoke layer: one segment from `(x, y)` along `(angle, radius)` per row.
///
/// `angle` is a Typst angle (e.g., `45deg`) when supplied as a layer parameter; mapped values are read as numbers in radians from the data. `radius` is the segment length in data units.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`. `angle` and `radius` may be mapped or left to the layer-level fallbacks.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - angle: Layer-level direction (a Typst angle, e.g., `45deg`) used when `aes(angle: ...)` is not mapped.
/// - radius: Layer-level length in data units used when `aes(radius: ...)` is not mapped.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword. Defaults to `"solid"`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-segment`, `geom-curve`.
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
#let geom-spoke(
  mapping: none,
  data: none,
  angle: 0deg,
  radius: 1,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
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
  ),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

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
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let angle-col = mapping.at("angle", default: none)
  let radius-col = mapping.at("radius", default: none)
  let angle-fallback = _to-angle(layer.params.angle)
  let radius-fallback = layer.params.radius
  // Constant-angle layers compute the trig once and reuse it per row;
  // mapped-angle layers fall back to the per-row branch below.
  let cos-fb = calc.cos(angle-fallback)
  let sin-fb = calc.sin(angle-fallback)

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))

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
    let p0 = project-point(ctx, x0, y0)
    let p1 = project-point(ctx, x1, y1)
    if p0 == none or p1 == none { continue }
    let (cx0, cy0) = p0
    let (cx1, cy1) = p1

    let final-colour = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let thickness = resolve-channel(
      "linewidth",
      layer,
      mapping,
      ctx,
      row,
      0.8pt,
    )
    cetz.draw.line(
      (cx0, cy0),
      (cx1, cy1),
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: layer.params.linetype,
      ),
    )
  }
}
