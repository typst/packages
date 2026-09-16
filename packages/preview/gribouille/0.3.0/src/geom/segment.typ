///! Straight line segments from `(x, y)` to `(xend, yend)`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/radial.typ": project-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

/// Segment layer: one line from `(x, y)` to `(xend, yend)` per row.
///
/// Mapping must provide `x`, `y`, `xend`, `yend`. Colour and linetype may be mapped or set as fixed layer parameters.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, `xend`, `yend`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
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
/// See also: `geom-line`, `geom-path`.
///
/// Three crossing segments specified by their two endpoints.
///
/// ```typst
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3),
///   (x: 0, y: 3, xend: 4, yend: 0),
///   (x: 2, y: 0, xend: 2, yend: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend"),
///   layers: (geom-segment(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `colour` and `linetype` to colour-coded categorical segments.
///
/// ```typst
/// #let d = (
///   (x: 0, y: 0, xend: 4, yend: 3, k: "a"),
///   (x: 0, y: 3, xend: 4, yend: 0, k: "b"),
///   (x: 2, y: 0, xend: 2, yend: 3, k: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", xend: "xend", yend: "yend", colour: "k", linetype: "k"),
///   layers: (geom-segment(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Dumbbell connectors on a discrete `y` axis: `x`, `xend`, or `yend` resolve through the trained scale, so categorical slots work.
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
///   layers: (geom-segment(stroke: 2pt),),
///   scales: (scale-y-discrete(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-segment(
  mapping: none,
  data: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "segment",
  mapping: mapping,
  data: data,
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

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
