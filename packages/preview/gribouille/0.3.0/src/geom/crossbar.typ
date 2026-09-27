///! Hollow box from `ymin` to `ymax` with a thicker bar at `y` (the median).

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../position/apply.typ": layer-position-name
#import "../position/dodge.typ": dodge-centre, dodge-half
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-axis, map-position
#import "../utils/band.typ": axis-band
#import "../utils/radial.typ": (
  polar-canvas, radial-arc, radial-axis-ranges, radial-category-span,
  radial-wedge,
)
#import "../utils/types.typ": parse-number
#import "../utils/stroke.typ": build-stroke
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
)

/// Crossbar layer: a box from `ymin` to `ymax` with a horizontal bar at `y`.
///
/// Mapping must provide `x`, `y`, `ymin`, `ymax`. The `width` parameter sets the box width in x data units for continuous x, and as a fraction of the per-category slot width for discrete x.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x`, `y`, `ymin`, `ymax`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Box width. In x data units for continuous x; a fraction of the slot width for discrete x.
/// - colour: Stroke colour for the box and the median bar. `auto` falls back to the theme ink, since the outline and median carry the crossbar's structure even when `fill` supplies the body colour.
/// - fill: Box fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Stroke thickness for the box outline.
/// - middle-stroke: Stroke thickness for the median bar.
/// - alpha: Box opacity in `[0, 1]`.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment name. Defaults to `"identity"`; use `"dodge"` to place groups side by side per fill level.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-errorbar`, `geom-pointrange`, `geom-boxplot`.
///
/// Box from `lo` to `hi` with the median bar at `y`.
///
/// ```typst
/// #let d = range(1, 5).map(i => (
///   x: i,
///   y: i,
///   lo: i - 0.6,
///   hi: i + 0.6,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi"),
///   layers: (geom-crossbar(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `fill` to a categorical column to colour the box per group.
///
/// ```typst
/// #let d = range(1, 5).map(i => (
///   x: i, y: i, lo: i - 0.6, hi: i + 0.6,
///   k: if calc.rem(i, 2) == 0 { "even" } else { "odd" },
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", ymin: "lo", ymax: "hi", fill: "k"),
///   layers: (geom-crossbar(alpha: 0.6),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-crossbar(
  mapping: none,
  data: none,
  width: 0.6,
  colour: auto,
  fill: auto,
  stroke: 0.6pt,
  middle-stroke: 1.2pt,
  alpha: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "crossbar",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    colour: colour,
    fill: fill,
    stroke: stroke,
    middle-stroke: middle-stroke,
    alpha: alpha,
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

  let g-defaults = resolve-geom-defaults(ctx.theme)
  // Box outline and median bar carry the crossbar's structure, so the
  // stroke default always stands even when fill is mapped or pinned.
  let default-colour = resolve-geom-colour(g-defaults)
  let default-fill = resolve-geom-fill(g-defaults, role: "paper")

  let half-width = layer.params.width / 2
  let position-name = layer-position-name(layer)

  let radial = ctx.at("radial", default: none)
  if radial != none {
    let cat-trained = if radial.cat-is-theta { x-trained } else { y-trained }
    let val-trained = if radial.cat-is-theta { y-trained } else { x-trained }
    let cat-col = if radial.cat-is-theta { x-col } else { y-col }
    let (cat-range, value-range) = radial-axis-ranges(radial)
    let half = (
      radial-category-span(cat-trained, cat-col, cat-range, data)
        * layer.params.width
        / 2
    )
    for row in data {
      let raw-cat = if radial.cat-is-theta {
        row.at(x-col, default: none)
      } else { row.at(y-col, default: none) }
      let cat-c = map-position(cat-trained, raw-cat, cat-range)
      let mid = parse-number(row.at(y-col, default: none))
      let lo = parse-number(row.at(ymin-col, default: none))
      let hi = parse-number(row.at(ymax-col, default: none))
      if cat-c == none or mid == none or lo == none or hi == none { continue }
      let v-mid = map-axis(val-trained, mid, value-range)
      let v-lo = map-axis(val-trained, lo, value-range)
      let v-hi = map-axis(val-trained, hi, value-range)
      let (theta-lo, theta-hi, r-lo, r-hi, r-mid) = if radial.cat-is-theta {
        (cat-c - half, cat-c + half, v-lo, v-hi, v-mid)
      } else {
        (v-lo, v-hi, cat-c - half, cat-c + half, cat-c)
      }
      if r-lo > r-hi { (r-lo, r-hi) = (r-hi, r-lo) }

      let final-fill = resolve-channel(
        "fill",
        layer,
        mapping,
        ctx,
        row,
        default-fill,
      )
      let resolved-stroke = resolve-channel(
        "colour",
        layer,
        mapping,
        ctx,
        row,
        default-colour,
      )
      let stroke-spec = build-stroke(layer.params.stroke, resolved-stroke)
      let middle-stroke-spec = build-stroke(
        layer.params.middle-stroke,
        resolved-stroke,
      )

      let pts = radial-wedge(theta-lo, theta-hi, r-lo, r-hi, radial)
      cetz.draw.line(
        ..pts,
        close: true,
        fill: final-fill,
        stroke: stroke-spec,
      )
      if radial.cat-is-theta {
        let median = radial-arc(theta-lo, theta-hi, r-mid, radial)
        cetz.draw.line(..median, stroke: middle-stroke-spec)
      } else {
        cetz.draw.line(
          polar-canvas(radial, v-mid, r-lo),
          polar-canvas(radial, v-mid, r-hi),
          stroke: middle-stroke-spec,
        )
      }
    }
    return
  }

  for row in data {
    let raw-x = row.at(x-col, default: none)
    let cx = map-position(x-trained, raw-x, ctx.px-range)
    let mid = parse-number(row.at(y-col, default: none))
    let lo = parse-number(row.at(ymin-col, default: none))
    let hi = parse-number(row.at(ymax-col, default: none))
    if cx == none or mid == none or lo == none or hi == none { continue }
    let cy-mid = map-position(y-trained, mid, ctx.py-range)
    let cy-lo = map-position(y-trained, lo, ctx.py-range)
    let cy-hi = map-position(y-trained, hi, ctx.py-range)
    if cy-mid == none or cy-lo == none or cy-hi == none { continue }

    let band = axis-band(x-trained, raw-x, half-width, ctx.px-range)
    let (cx-lo, cx-hi) = if band == none { (cx, cx) } else { band }

    if position-name == "dodge" {
      let span = cx-hi - cx-lo
      let centre = dodge-centre(row, cx, span)
      let half = dodge-half(row, span / 2)
      cx-lo = centre - half
      cx-hi = centre + half
    }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let resolved-stroke = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      default-colour,
    )
    let stroke-spec = build-stroke(layer.params.stroke, resolved-stroke)
    let middle-stroke-spec = build-stroke(
      layer.params.middle-stroke,
      resolved-stroke,
    )

    cetz.draw.rect(
      (cx-lo, cy-lo),
      (cx-hi, cy-hi),
      fill: final-fill,
      stroke: stroke-spec,
    )
    cetz.draw.line(
      (cx-lo, cy-mid),
      (cx-hi, cy-mid),
      stroke: middle-stroke-spec,
    )
  }
}
