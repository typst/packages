///! Filled area between the x axis and y.
///!
///! Equivalent to a ribbon with `ymin = 0`. Rows are sorted by x within
///! each group and the polygon closes back along `y = 0`.
///! Under \@coord-flip the polygon still closes along the user's `y = 0`
///! line; check the rendered output if both axes are continuous.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/errors.typ": fail-enum
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "grouped-path.typ": sort-rows-by-x
#import "../utils/group.typ": partition-by-group
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/band.typ": band-polygon
#import "../utils/stroke.typ": resolve-stroke-spec, seal-seam
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

/// Area layer: filled polygon from `y = 0` up to `y` along x, per group.
///
/// Mapping must provide `x` and `y`. Discrete colour, fill, or `group` mappings split rows into separate filled polygons drawn back to front.
///
/// (default) draws a smooth polygon; `"hv"` (horizontal then vertical) or `"vh"` (vertical then horizontal) step the top edge like `geom-step`.
///
/// resamples all groups onto a shared x-grid before stacking so bands join cleanly even when groups carry different x values. Pass `"identity"` to skip alignment.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Fixed fill colour. `auto` resolves via the fill scale, the colour scale, or a neutral default.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Fill opacity in `[0, 1]`.
/// - direction: Step interpolation for the filled top edge. `none`
/// - stat: Statistical transform name. Defaults to `"align"`, which
/// - position: Position adjustment name. Defaults to `"stack"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-ribbon`, `geom-line`.
///
/// Single filled area between `y = 0` and a smooth curve.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: calc.sin(i * 0.6) + 1.5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-area(alpha: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `fill` to a discrete column; groups stack automatically.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 12) {
///     d.push((x: i, y: 1.5 + calc.sin(i * 0.5) + (if grp == "b" { 1 } else { 0 }), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "grp"),
///   layers: (geom-area(alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Step the top edge with `direction: "hv"` for a histogram-like filled area.
///
/// ```typst
/// #let d = range(0, 7).map(i => (x: i, y: calc.rem(i * 3, 5) + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-area(direction: "hv", alpha: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-area(
  mapping: none,
  data: none,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  direction: none,
  stat: "align",
  position: "stack",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  if direction != none and direction != "hv" and direction != "vh" {
    fail-enum("geom-area", "direction", direction, ("hv", "vh"))
  }
  make-layer(
    "area",
    mapping: mapping,
    data: data,
    params: (
      colour: colour,
      fill: fill,
      stroke: stroke,
      alpha: alpha,
      direction: direction,
    )
      + split-aes-params("geom-area", args),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }
  if y-trained.type != "continuous" { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  // Wrappers with a visible default outline (geom-density) opt in via the
  // internal `outline-role` param; a plain area keeps no outline default.
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(
      g-defaults,
      role: layer.params.at("outline-role", default: none),
    ),
    resolve-geom-fill(
      g-defaults,
      role: layer.params.at("fill-role", default: "tint"),
    ),
  )

  let ymin-col = mapping.at("ymin", default: none)
  let direction = layer.params.direction

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let sorted = sort-rows-by-x(rows, mapping, x-trained)
      .map(row => (
        x: row.at(mapping.x, default: none),
        y: parse-number(row.at(mapping.y, default: none)),
        ymin: if ymin-col != none {
          parse-number(row.at(ymin-col, default: 0))
        } else { 0.0 },
      ))
      .filter(p => p.y != none)
    if sorted.len() < 2 { continue }

    let pts = band-polygon(
      ctx,
      sorted,
      p => p.y,
      p => p.ymin,
      direction: direction,
    )
    if pts.any(p => p == none) { continue }

    let leader = rows.first()
    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      leader,
      default-fill,
      colour-fallback: false,
      default-alpha: 1,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      leader,
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
