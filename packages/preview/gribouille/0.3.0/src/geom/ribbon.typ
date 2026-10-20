///! Filled band between `ymin` and `ymax` along x.
///!
///! Requires the aesthetic mapping to provide `x`, `ymin`, and `ymax`. Useful
///! for uncertainty envelopes and shaded ranges under a line.
///! Under \@coord-flip the band currently keeps its `ymin`/`ymax` semantics
///! against the user's original y axis; the visual result may not match a
///! sideways ribbon and should be inspected per use.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "grouped-path.typ": sort-rows-by-x
#import "../utils/group.typ": partition-by-group
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/band.typ": band-polygon
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

/// Filled band between `ymin` and `ymax` along the x aesthetic, per group.
///
/// The mapping must provide `x`, `ymin`, and `ymax`. Within each group rows are sorted by x and the polygon is closed between the lower and upper boundaries. Discrete colour, fill, or `group` mappings split rows into separate bands.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - colour: Band outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Band fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Band outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Band opacity in `[0, 1]`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-smooth`, `geom-line`.
///
/// Plain shaded band between `ymin` and `ymax`.
///
/// ```typst
/// #let d = range(0, 10).map(i => (
///   x: i,
///   lo: i * 0.5 - 1,
///   hi: i * 0.5 + 1,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi"),
///   layers: (geom-ribbon(alpha: 0.3),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pair the ribbon with `geom-line` over a `y` mid-line for a classic uncertainty-around-trend visualisation.
///
/// ```typst
/// #let d = range(0, 10).map(i => (
///   x: i, y: i * 0.5, lo: i * 0.5 - 0.6, hi: i * 0.5 + 0.6,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (
///     geom-ribbon(alpha: 0.3),
///     geom-line(stroke: 1pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `fill` to a discrete column to draw one band per group.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 10) {
///     let mid = i * 0.5 + (if grp == "b" { 3 } else { 0 })
///     d.push((x: i, lo: mid - 0.8, hi: mid + 0.8, grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi", fill: "grp"),
///   layers: (geom-ribbon(alpha: 0.4),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-ribbon(
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
  "ribbon",
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
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let lo-col = mapping.at("ymin", default: none)
  let hi-col = mapping.at("ymax", default: none)
  if x-col == none or lo-col == none or hi-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults, role: none),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let sorted = sort-rows-by-x(rows, mapping, x-trained)
      .map(row => (
        x: row.at(x-col, default: none),
        lo: parse-number(row.at(lo-col, default: none)),
        hi: parse-number(row.at(hi-col, default: none)),
      ))
      .filter(p => p.lo != none and p.hi != none)
    if sorted.len() < 2 { continue }

    let pts = band-polygon(ctx, sorted, p => p.hi, p => p.lo)
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
      default-alpha: 0.3,
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
