///! Hexagonal two-dimensional bin layer. Wraps \@stat-bin-hex over a hex
///! polygon draw routine.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-position
#import "../stat/bin-hex.typ": stat-bin-hex
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/hex.typ": hex-vertices
#import "../utils/radial.typ": project-point
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../utils/types.typ": parse-number
#import "../theme/theme.typ": (
  geom-colour-default, geom-default, geom-defaults, geom-fill-default,
  geom-linewidth,
)

/// Hex bin layer: counts (x, y) into a pointy-top hex grid and draws one
/// hexagon per non-empty cell. Default fill encodes count via the fill
/// scale.
///
/// \@category Geoms
/// \@subcategory Rectangles and bins
/// \@stability stable
/// \@since 0.4.0
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x` and `y`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param bins Scalar or `(x, y)` pair — target bin counts.
///
/// \@param binwidth Scalar or `(x, y)` pair — fixed pitches.
///
/// \@param colour Cell outline colour.
///
/// \@param fill Cell fill colour. `auto` lets the fill scale paint by `_count`.
///
/// \@param stroke Outline thickness or stroke dictionary.
///
/// \@param alpha Cell opacity in `[0, 1]`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples 25-bin pointy-top hex grid coloured by count.
/// ```
/// //| alt: "Hexagonal bin grid of 600 sine/cosine samples with pointy-top cells shaded by count via the magma palette."
/// #let n = 600
/// #let d = range(0, n).map(i => (
///   x: calc.sin(i * 0.13) * 4,
///   y: calc.cos(i * 0.21) * 4,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-hex(bins: 25),),
///   scales: (scale-fill-viridis-c(option: "magma"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-bin-2d, \@stat-bin-hex
#let geom-hex(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  inherit-aes: true,
) = make-layer(
  "hex",
  mapping: mapping,
  data: data,
  params: (
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  stat: stat-bin-hex(bins: bins, binwidth: binwidth),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if (
    x-trained == none
      or y-trained == none
      or x-trained.type != "continuous"
      or y-trained.type != "continuous"
  ) { return }

  let g-defaults = geom-defaults(ctx.theme)
  let default-thickness = geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    geom-colour-default(g-defaults, role: none),
    geom-fill-default(g-defaults, role: "tint"),
  )

  for row in data {
    let cx = parse-number(row.at(x-col, default: none))
    let cy = parse-number(row.at(y-col, default: none))
    let dx = row.at("_hex-dx", default: none)
    let dy = row.at("_hex-dy", default: none)
    if cx == none or cy == none or dx == none or dy == none { continue }
    let pts = hex-vertices(cx, cy, dx, dy).map(((vx, vy)) => (
      project-point(ctx, vx, vy)
    ))
    if pts.any(p => p == none) { continue }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
      colour-fallback: false,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )

    cetz.draw.line(
      ..pts,
      close: true,
      fill: final-fill,
      stroke: stroke-spec,
    )
  }
}
