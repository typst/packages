///! Point at `(x, y)` plus a vertical range from `ymin` to `ymax`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/radial.typ": project-point
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

/// Pointrange layer: a marker at `(x, y)` plus a linerange from `ymin` to `ymax`.
///
/// Mapping must provide `x`, `y`, `ymin`, `ymax`. `colour` paints the range line and the point outline; `fill` paints the point body.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Point radius (a Typst length).
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed range-line colour. `auto` resolves via the colour scale.
/// - fill: Fixed point body fill. `auto` resolves via the fill scale, falling back to the resolved range-line colour.
/// - alpha: Opacity in `[0, 1]`.
/// - linetype: Dash keyword for the range line. Defaults to `"solid"`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-linerange`, `geom-errorbar`, `geom-crossbar`.
///
/// Centred point with vertical range, drawn together for forest-plot style summaries.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i,
///   y: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (geom-pointrange(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `colour` to a categorical column to colour both the point and its range per group.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i, y: i, lo: i - 0.5, hi: i + 0.5,
///   k: if calc.rem(i, 2) == 0 { "even" } else { "odd" },
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi", colour: "k"),
///   layers: (geom-pointrange(size: 3pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-pointrange(
  mapping: none,
  data: none,
  size: 2.5pt,
  stroke: auto,
  colour: auto,
  fill: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "pointrange",
  mapping: mapping,
  data: data,
  params: (
    size: size,
    stroke: stroke,
    colour: colour,
    fill: fill,
    alpha: alpha,
    linetype: linetype,
  ),
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
  let ymin-col = mapping.at("ymin", default: none)
  let ymax-col = mapping.at("ymax", default: none)
  if (
    x-col == none or y-col == none or ymin-col == none or ymax-col == none
  ) { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))

  for row in data {
    let xv = row.at(x-col, default: none)
    let mid = parse-number(row.at(y-col, default: none))
    let lo = parse-number(row.at(ymin-col, default: none))
    let hi = parse-number(row.at(ymax-col, default: none))
    if xv == none or mid == none or lo == none or hi == none { continue }
    let p-mid = project-point(ctx, xv, mid)
    let p-lo = project-point(ctx, xv, lo)
    let p-hi = project-point(ctx, xv, hi)
    if p-mid == none or p-lo == none or p-hi == none { continue }
    let (cx-mid, cy-mid) = p-mid
    let (cx-lo, cy-lo) = p-lo
    let (cx-hi, cy-hi) = p-hi

    let final-colour = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      final-colour,
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
      (cx-lo, cy-lo),
      (cx-hi, cy-hi),
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: layer.params.linetype,
      ),
    )
    let radius = resolve-channel(
      "size",
      layer,
      mapping,
      ctx,
      row,
      layer.params.size,
    )
    cetz.draw.circle(
      (cx-mid, cy-mid),
      radius: radius,
      fill: final-fill,
      stroke: none,
    )
  }
}
