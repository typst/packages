///! Hexagonal two-dimensional bin layer. Wraps \@stat-bin-hex over a hex
///! polygon draw routine.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha
#import "../deps.typ": cetz
#import "../utils/bin.typ": check-bin-params
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../stat/bin-hex.typ": stat-bin-hex
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/hex.typ": hex-vertices
#import "../utils/flip.typ": project-user-point, user-axes, user-columns
#import "../utils/stroke.typ": resolve-stroke-spec, seal-seam
#import "../utils/types.typ": parse-number
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

#let spec = (
  reads: ("x", "y", "colour", "fill", "alpha", "stroke"),
  extents: none,
)

/// Hex bin layer: counts (x, y) into a pointy-top hex grid and draws one hexagon per non-empty cell. Default fill encodes count via the fill scale.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x` and `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - bins: Scalar or `(x, y)` pair — target bin counts.
/// - binwidth: Scalar or `(x, y)` pair — fixed pitches.
/// - colour: Cell outline colour.
/// - fill: Cell fill colour. `auto` lets the fill scale paint by `_count`.
/// - stroke: Outline thickness or stroke dictionary.
/// - alpha: Cell opacity in `[0, 1]`.
/// - stat: Statistical transform. `auto` builds the geom's default stat from the parameters above; pass a stat name or stat object to override.
/// - position: Position adjustment name. Usually left at `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-bin-2d`, `stat-bin-hex`.
///
/// 25-bin pointy-top hex grid coloured by count.
///
/// ```typst
/// #let n = 600
/// #let d = range(0, n).map(i => (
///   x: calc.sin(i * 0.13) * 4,
///   y: calc.cos(i * 0.21) * 4,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-hex(bins: 25),),
///   scales: scales(fill: scale-viridis-c(option: "magma")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-hex(
  mapping: none,
  data: none,
  bins: 30,
  binwidth: none,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  stat: auto,
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-hex", position)
  assert-alpha("geom-hex", alpha)
  make-layer(
    "hex",
    mapping: mapping,
    data: data,
    params: (
      colour: colour,
      fill: fill,
      stroke: stroke,
      alpha: alpha,
    )
      + split-aes-params("geom-hex", args, spec.reads),
    stat: if stat == auto {
      check-bin-params("geom-hex", bins, binwidth, pair: true)
      stat-bin-hex(bins: bins, binwidth: binwidth)
    } else { stat },
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  // The binned centres and the `_hex-dx`/`_hex-dy` spacings are in the
  // user's x/y space, which coord-flip draws along the y/x axes.
  let cols = user-columns(mapping, ctx)
  let (x-col, y-col) = (cols.x, cols.y)
  if x-col == none or y-col == none { return }
  let axes = user-axes(ctx)
  if (
    axes == none
      or axes.x-trained.type != "continuous"
      or axes.y-trained.type != "continuous"
  ) { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults, role: none),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  for row in data {
    let cx = parse-number(row.at(x-col, default: none))
    let cy = parse-number(row.at(y-col, default: none))
    let dx = row.at("_hex-dx", default: none)
    let dy = row.at("_hex-dy", default: none)
    if cx == none or cy == none or dx == none or dy == none { continue }
    let pts = hex-vertices(cx, cy, dx, dy).map(((vx, vy)) => (
      project-user-point(ctx, vx, vy)
    ))
    if pts.any(p => p == none) { continue }

    let final-fill = resolve-channel(
      "fill",
      layer.params,
      mapping,
      ctx,
      row,
      default-fill,
      colour-fallback: false,
    )
    let stroke-spec = resolve-stroke-spec(
      layer.params,
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
      stroke: seal-seam(stroke-spec, final-fill),
    )
  }
}
