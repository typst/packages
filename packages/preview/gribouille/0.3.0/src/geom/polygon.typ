///! Closed polygons from `(x, y)` rows, one polygon per group.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": project-point
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

/// Polygon layer: one closed filled polygon per group.
///
/// Rows are connected in input order and the polygon is closed back to the first vertex. Use `group`, `colour`, `fill`, or `linetype` to split rows into separate polygons.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Fixed fill colour. `auto` resolves via the fill scale.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Fill opacity in `[0, 1]`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-rect`, `geom-area`.
///
/// Two filled triangles, each defined by three vertex rows in a shared column.
///
/// ```typst
/// #let d = (
///   (x: 0, y: 0, k: "a"),
///   (x: 2, y: 0, k: "a"),
///   (x: 1, y: 2, k: "a"),
///   (x: 3, y: 1, k: "b"),
///   (x: 5, y: 1, k: "b"),
///   (x: 4, y: 3, k: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "k"),
///   layers: (geom-polygon(alpha: 0.5),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A regular pentagon constructed from sampled angles.
///
/// ```typst
/// #let n = 5
/// #let d = range(0, n).map(i => (
///   x: calc.cos(2 * calc.pi * i / n),
///   y: calc.sin(2 * calc.pi * i / n),
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-polygon(
///     fill: rgb("#4c78a8"),
///     colour: black,
///     stroke: 1pt,
///     alpha: 0.7,
///   ),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-polygon(
  mapping: none,
  data: none,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "polygon",
  mapping: mapping,
  data: data,
  params: (colour: colour, fill: fill, stroke: stroke, alpha: alpha),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let pts = ()
    for row in rows {
      let p = project-point(
        ctx,
        row.at(mapping.x, default: none),
        row.at(mapping.y, default: none),
      )
      if p == none { continue }
      pts.push(p)
    }
    if pts.len() < 3 { continue }

    let leader = rows.first()
    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      leader,
      default-fill,
      colour-fallback: false,
      default-alpha: 0.6,
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
      stroke: stroke-spec,
    )
  }
}
