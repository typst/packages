///! Axis-aligned rectangles from `xmin`, `ymin`, `xmax`, `ymax`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-axis, map-position
#import "../utils/types.typ": parse-number
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": radial-wedge
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

/// Rectangle layer drawing one filled box per row from the four corners.
///
/// Mapping must provide `xmin`, `xmax`, `ymin`, `ymax`. Fill resolves via the fill scale or a fixed `fill` parameter.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `xmin`, `xmax`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Fixed fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline and the `colour` aesthetic.
/// - alpha: Fill opacity in `[0, 1]`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Usually `"identity"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-tile`, `geom-col`.
///
/// Three categorical rectangles overlapping along x.
///
/// ```typst
/// #let d = (
///   (xmin: 0, xmax: 1, ymin: 0, ymax: 2, k: "a"),
///   (xmin: 1, xmax: 3, ymin: 1, ymax: 4, k: "b"),
///   (xmin: 3, xmax: 4, ymin: 2, ymax: 3, k: "a"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A unit-strip swatch lays out a discrete palette horizontally, one rectangle per level.
///
/// ```typst
/// #let levels = ("a", "b", "c", "d", "e")
/// #let d = levels.enumerate().map(((i, k)) => (
///   xmin: i, xmax: i + 1, ymin: 0, ymax: 1, k: k,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(xmin: "xmin", xmax: "xmax", ymin: "ymin", ymax: "ymax", fill: "k"),
///   layers: (geom-rect(),),
///   scales: (scale-fill-brewer(palette: "Set1"),),
///   guides: guides(fill: none),
///   theme: theme-void(),
///   width: 8cm,
///   height: 1cm,
/// )
/// ```
#let geom-rect(
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
  "rect",
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
  let xmin-col = mapping.at("xmin", default: none)
  let xmax-col = mapping.at("xmax", default: none)
  let ymin-col = mapping.at("ymin", default: none)
  let ymax-col = mapping.at("ymax", default: none)
  if (
    xmin-col == none or xmax-col == none or ymin-col == none or ymax-col == none
  ) { return }
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

  let radial = ctx.at("radial", default: none)
  for row in data {
    let x0 = parse-number(row.at(xmin-col, default: none))
    let x1 = parse-number(row.at(xmax-col, default: none))
    let y0 = parse-number(row.at(ymin-col, default: none))
    let y1 = parse-number(row.at(ymax-col, default: none))
    if x0 == none or x1 == none or y0 == none or y1 == none { continue }

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

    if radial != none {
      let cat-is-theta = radial.cat-is-theta
      let theta-range = radial.theta-range
      let r-range = radial.r-range
      let (theta-lo, theta-hi, r-lo, r-hi) = if cat-is-theta {
        (
          map-axis(x-trained, x0, theta-range),
          map-axis(x-trained, x1, theta-range),
          map-axis(y-trained, y0, r-range),
          map-axis(y-trained, y1, r-range),
        )
      } else {
        (
          map-axis(y-trained, y0, theta-range),
          map-axis(y-trained, y1, theta-range),
          map-axis(x-trained, x0, r-range),
          map-axis(x-trained, x1, r-range),
        )
      }
      if r-lo > r-hi { (r-lo, r-hi) = (r-hi, r-lo) }
      let pts = radial-wedge(theta-lo, theta-hi, r-lo, r-hi, radial)
      cetz.draw.line(
        ..pts,
        close: true,
        fill: final-fill,
        stroke: stroke-spec,
      )
    } else {
      let cx0 = map-position(x-trained, x0, ctx.px-range)
      let cx1 = map-position(x-trained, x1, ctx.px-range)
      let cy0 = map-position(y-trained, y0, ctx.py-range)
      let cy1 = map-position(y-trained, y1, ctx.py-range)
      if cx0 == none or cx1 == none or cy0 == none or cy1 == none { continue }
      cetz.draw.rect(
        (cx0, cy0),
        (cx1, cy1),
        fill: final-fill,
        stroke: stroke-spec,
      )
    }
  }
}
