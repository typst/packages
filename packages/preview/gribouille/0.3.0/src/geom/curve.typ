///! Curved segments from `(x, y)` to `(xend, yend)`.
///!
///! Quadratic-bezier counterpart of \@geom-segment. The control point sits
///! perpendicular to the chord at a position controlled by `curvature` and
///! `angle`, then the curve is sampled into a polyline drawn through the
///! same draw chain.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/errors.typ": fail-range
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/radial.typ": project-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

/// Curved segment layer: one quadratic bezier from `(x, y)` to `(xend, yend)` per row.
///
/// `curvature` chooses the magnitude and side of the bow:
///
/// - `0` collapses to a straight `geom-segment`.
/// - Positive values curve to the right of the chord (looking from start to end).
/// - Negative values curve to the left.
///
/// `angle` shifts the control point along the chord (in addition to the perpendicular offset), producing asymmetric arcs. `90deg` gives a symmetric bow; smaller or larger angles bias the apex toward one end.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, `xend`, `yend`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - curvature: Bezier-control offset as a fraction of the chord length. `0` draws a straight segment; sign flips the side of the bow.
/// - angle: Apex angle in `(0deg, 180deg)`. `90deg` is symmetric.
/// - n: Number of polyline samples along the curve.
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
/// See also: `geom-segment`, `geom-line`.
///
/// Three curved connectors with the default symmetric bow.
///
/// ```typst
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3, k: "a"),
///   (x: 0, y: 3, xend: 4, yend: 0, k: "b"),
///   (x: 2, y: 0, xend: 2, yend: 3, k: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k"),
///   layers: (geom-curve(curvature: 0.5, stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Negative `curvature` flips the arc to the other side.
///
/// ```typst
/// #let d = ((x: 0, y: 0, xend: 4, yend: 3),)
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
///   layers: (geom-curve(curvature: -0.5, stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Curved connectors on a discrete `y` axis: endpoints resolve through the trained scale, so categorical slots work.
///
/// ```typst
/// #let d = (
///   (lo: 1, hi: 4, grp: "alpha"),
///   (lo: 2, hi: 5, grp: "beta"),
///   (lo: 3, hi: 6, grp: "gamma"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "lo", y: "grp", xend: "hi", yend: "grp"),
///   layers: (geom-curve(stroke: 2pt),),
///   scales: (scale-y-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-curve(
  mapping: none,
  data: none,
  curvature: 0.5,
  angle: 90deg,
  n: 32,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = {
  if curvature < -1 or curvature > 1 {
    fail-range(
      "geom-curve",
      "curvature",
      curvature,
      -1,
      1,
      lo-open: false,
      hi-open: false,
    )
  }
  make-layer(
    "curve",
    mapping: mapping,
    data: data,
    params: (
      curvature: curvature,
      angle: angle,
      n: n,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
      linetype: linetype,
    ),
    stat: stat,
    position: position,
    inherit-aes: inherit-aes,
  )
}

// Quadratic-bezier samples between (cx0, cy0) and (cx1, cy1). The control
// point sits perpendicular to the chord at a distance proportional to
// `curvature * chord-length`. `cos-angle` is the cached `calc.cos(angle)`
// supplied by the caller (the angle is constant per layer, so the trig is
// hoisted out of the per-row loop). 90deg places the apex at the midpoint.
//
// Returns `n + 1` points to include both endpoints exactly; circle/ellipse
// samplers wrap and use `n` points instead.
#let _curve-points(cx0, cy0, cx1, cy1, curvature, cos-angle, n) = {
  let dx = cx1 - cx0
  let dy = cy1 - cy0
  let length = calc.sqrt(dx * dx + dy * dy)
  if length == 0 { return ((cx0, cy0),) }
  let t-mid = cos-angle * 0.5 + 0.5
  let mx = cx0 + t-mid * dx
  let my = cy0 + t-mid * dy
  let perp-x = -dy / length
  let perp-y = dx / length
  let offset = curvature * length
  let cx = mx + offset * perp-x
  let cy = my + offset * perp-y
  range(0, n + 1).map(i => {
    let t = i / n
    let u = 1 - t
    let bx = u * u * cx0 + 2 * u * t * cx + t * t * cx1
    let by = u * u * cy0 + 2 * u * t * cy + t * t * cy1
    (bx, by)
  })
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let xend-col = mapping.at("xend", default: none)
  let yend-col = mapping.at("yend", default: none)
  if x-col == none or y-col == none or xend-col == none or yend-col == none {
    return
  }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  let curvature = layer.params.curvature
  let cos-angle = calc.cos(layer.params.angle)
  let n = layer.params.n

  for row in data {
    let x0 = row.at(x-col, default: none)
    let y0 = row.at(y-col, default: none)
    let x1 = row.at(xend-col, default: none)
    let y1 = row.at(yend-col, default: none)
    if x0 == none or y0 == none or x1 == none or y1 == none { continue }
    let p0 = project-point(ctx, x0, y0)
    let p1 = project-point(ctx, x1, y1)
    if p0 == none or p1 == none { continue }
    let (cx0, cy0) = p0
    let (cx1, cy1) = p1

    let pts = _curve-points(cx0, cy0, cx1, cy1, curvature, cos-angle, n)
    if pts.len() < 2 { continue }

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
      ..pts,
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: layer.params.linetype,
      ),
    )
  }
}
