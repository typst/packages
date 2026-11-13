///! Point at `(x, y)` plus a vertical range from `ymin` to `ymax`.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha, assert-linetype
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults
#import "../position/dodge.typ": dodge-geometry, project-dodged
#import "../utils/flip.typ": user-axes, user-columns, user-point
#import "linerange.typ": range-line-row

#let spec = (
  reads: (
    "x",
    "y",
    "ymin",
    "ymax",
    "colour",
    "fill",
    "alpha",
    "size",
    "linewidth",
    "linetype",
  ),
  extents: none,
)

/// Pointrange layer: a marker at `(x, y)` plus a linerange from `ymin` to `ymax`.
///
/// Mapping must provide `x`, `y`, `ymin`, `ymax`. `colour` paints the range line and the point outline; `fill` paints the point body.
///
/// Under `coord-radial` a range that sweeps theta follows the polar grid as an arc.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - size: Point radius (a Typst length).
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed range-line colour. `auto` resolves via the colour scale.
/// - fill: Fixed point body fill. `auto` resolves via the fill scale, falling back to the resolved range-line colour.
/// - alpha: Opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
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
  linetype: auto,
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-pointrange", position)
  assert-alpha("geom-pointrange", alpha)
  assert-linetype("geom-pointrange", linetype)
  make-layer(
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
    )
      + split-aes-params("geom-pointrange", args, spec.reads),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let cols = user-columns(mapping, ctx)
  if (
    cols.x == none or cols.y == none or cols.ymin == none or cols.ymax == none
  ) { return }
  if user-axes(ctx) == none { return }

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  let dodge = dodge-geometry(ctx, layer)

  for row in data {
    let xv = row.at(cols.x, default: none)
    let mid = parse-number(row.at(cols.y, default: none))
    if xv == none or mid == none { continue }
    let p-mid = project-dodged(ctx, dodge, row, ..user-point(ctx, xv, mid))
    if p-mid == none { continue }
    let res = range-line-row(
      layer.params,
      mapping,
      ctx,
      row,
      cols.x,
      cols.ymin,
      cols.ymax,
      theme-colour,
      dodge,
      line-alpha: false,
    )
    if res == none { continue }
    res.elem
    let (cx-mid, cy-mid) = p-mid
    let final-fill = resolve-channel(
      "fill",
      layer.params,
      mapping,
      ctx,
      row,
      res.colour,
    )
    let radius = resolve-channel(
      "size",
      layer.params,
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
