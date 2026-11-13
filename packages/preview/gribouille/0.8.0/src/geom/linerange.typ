///! Vertical range from `ymin` to `ymax` at each `x`.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha, assert-linetype
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/linetype-resolve.typ": resolve-linetype
#import "../utils/types.typ": parse-number
#import "../utils/flip.typ": user-axes, user-columns
#import "../position/dodge.typ": dodge-geometry, project-dodged-path
#import "../utils/colour-resolve.typ": apply-alpha
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

#let spec = (
  reads: ("x", "ymin", "ymax", "colour", "alpha", "linewidth", "linetype"),
  extents: none,
)

/// Linerange layer: one vertical line from `ymin` to `ymax` at each `x`.
///
/// Mapping must provide `x`, `ymin`, `ymax`. Colour and linetype may be mapped or set as fixed layer parameters.
///
/// Under `coord-radial` a range that sweeps theta follows the polar grid as an arc.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` resolves via the colour scale.
/// - alpha: Line opacity in `[0, 1]`.
/// - linetype: Dash keyword (e.g., `"solid"`, `"dashed"`). `auto` honours the linetype scale.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-errorbar`, `geom-pointrange`.
///
/// Bare vertical ranges, no end caps.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi"),
///   layers: (geom-linerange(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `colour` to a categorical column to differentiate ranges per group.
///
/// ```typst
/// #let d = range(1, 6).map(i => (
///   x: i, lo: i - 0.5, hi: i + 0.5,
///   k: if calc.rem(i, 2) == 0 { "even" } else { "odd" },
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi", colour: "k"),
///   layers: (geom-linerange(stroke: 1.2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-linerange(
  mapping: none,
  data: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: auto,
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-alpha("geom-linerange", alpha)
  assert-linetype("geom-linerange", linetype)
  assert-position("geom-linerange", position)
  make-layer(
    "linerange",
    mapping: mapping,
    data: data,
    params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype)
      + split-aes-params("geom-linerange", args, spec.reads),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

// Build one row's vertical range line, horizontal under coord-flip and an arc
// when the range sweeps theta under coord-radial; shared with geom-pointrange.
// Returns `(elem, colour)` — the cetz line element to emit and the resolved
// line colour for follow-up marks — or `none` when the row does not resolve.
// `line-alpha: true` folds the alpha channel into the line paint; pointrange
// keeps the paint opaque so its marker fill inherits the plain colour.
//
// `params` and `dodge` both arrive resolved, and for the same reason: this runs
// once a row, so it takes the layer's parameters and its dodge slot rather than
// the layer, which reaches every row of the plot.
#let range-line-row(
  params,
  mapping,
  ctx,
  row,
  x-col,
  ymin-col,
  ymax-col,
  theme-colour,
  dodge,
  line-alpha: true,
) = {
  let xv = row.at(x-col, default: none)
  let lo = parse-number(row.at(ymin-col, default: none))
  let hi = parse-number(row.at(ymax-col, default: none))
  if xv == none or lo == none or hi == none { return none }
  let points = project-dodged-path(ctx, dodge, row, ((xv, lo), (xv, hi)))
  if points.len() < 2 { return none }

  let colour = resolve-channel(
    "colour",
    params,
    mapping,
    ctx,
    row,
    theme-colour,
  )
  let paint = if line-alpha {
    apply-alpha(colour, resolve-channel(
      "alpha",
      params,
      mapping,
      ctx,
      row,
      1,
    ))
  } else { colour }

  let thickness = resolve-channel(
    "linewidth",
    params,
    mapping,
    ctx,
    row,
    0.8pt,
  )
  (
    elem: cetz.draw.line(
      ..points,
      stroke: (
        paint: paint,
        thickness: thickness,
        dash: resolve-linetype(params, mapping, ctx, row),
      ),
    ),
    colour: colour,
  )
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let cols = user-columns(mapping, ctx)
  if cols.x == none or cols.ymin == none or cols.ymax == none { return }
  if user-axes(ctx) == none { return }

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  let dodge = dodge-geometry(ctx, layer)

  for row in data {
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
    )
    if res != none { res.elem }
  }
}
