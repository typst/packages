///! Hollow box from `ymin` to `ymax` with a thicker bar at `y` (the median).

#import "../utils/errors.typ": assert-alpha, assert-number
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../position/apply.typ": assert-position, layer-position-name
#import "../position/dodge.typ": dodge-centre, dodge-geometry, dodge-half
#import "../utils/aes-resolve.typ": resolve-channel
#import "../coord/project.typ": axis-mapper
#import "../utils/band.typ": axis-band
#import "../utils/radial.typ": (
  polar-canvas, radial-arc, radial-category-span, radial-mappers, radial-wedge,
)
#import "../utils/flip.typ": user-axes, user-axis-key, user-columns, user-point
#import "../utils/types.typ": parse-number
#import "../utils/stroke.typ": build-stroke
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
)

#let spec = (
  reads: ("x", "y", "ymin", "ymax", "colour", "fill", "alpha"),
  extents: none,
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
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
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
///   mapping: aes(x: as-factor("x"), y: "y", ymin: "lo", ymax: "hi"),
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
///   mapping: aes(x: as-factor("x"), y: "y", ymin: "lo", ymax: "hi", fill: "k"),
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
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-crossbar", position)
  assert-alpha("geom-crossbar", alpha)
  assert-number("geom-crossbar", "width", width, min: 0)
  make-layer(
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
    )
      + split-aes-params("geom-crossbar", args, spec.reads),
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
  let axes = user-axes(ctx)
  if axes == none { return }
  let (x-trained, x-range) = (axes.x-trained, axes.x-range)

  let g-defaults = resolve-geom-defaults(ctx.theme)
  // Box outline and median bar carry the crossbar's structure, so the
  // stroke default always stands even when fill is mapped or pinned.
  let default-colour = resolve-geom-colour(g-defaults)
  let default-fill = resolve-geom-fill(g-defaults, role: "paper")

  let half-width = layer.params.width / 2
  let position-name = layer-position-name(layer)
  let dodge = dodge-geometry(ctx, layer)
  let pt = user-point.with(ctx)

  let radial = ctx.at("radial", default: none)
  if radial != none {
    // The categories are the user's x on either theta axis, as for every
    // point-like geom: `radial-mappers` puts them on the polar axis x takes.
    let (cat: map-cat, value: map-value) = radial-mappers(ctx)
    let span = radial-category-span(ctx, cols.x, data) * layer.params.width
    for row in data {
      let cat-c = map-cat(row.at(cols.x, default: none))
      let mid = parse-number(row.at(cols.y, default: none))
      let lo = parse-number(row.at(cols.ymin, default: none))
      let hi = parse-number(row.at(cols.ymax, default: none))
      if cat-c == none or mid == none or lo == none or hi == none { continue }
      let v-mid = map-value(mid)
      let v-lo = map-value(lo)
      let v-hi = map-value(hi)
      if v-mid == none or v-lo == none or v-hi == none { continue }
      let centre = cat-c
      let half = span / 2
      if position-name == "dodge" {
        centre = dodge-centre(dodge, row, cat-c, span)
        half = dodge-half(row, span / 2)
      }
      let (theta-lo, theta-hi, r-lo, r-hi) = if radial.cat-is-theta {
        (centre - half, centre + half, v-lo, v-hi)
      } else {
        (v-lo, v-hi, centre - half, centre + half)
      }
      if r-lo > r-hi { (r-lo, r-hi) = (r-hi, r-lo) }

      let final-fill = resolve-channel(
        "fill",
        layer.params,
        mapping,
        ctx,
        row,
        default-fill,
      )
      let resolved-stroke = resolve-channel(
        "colour",
        layer.params,
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
        let median = radial-arc(theta-lo, theta-hi, v-mid, radial)
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

  let map-x = axis-mapper(ctx, user-axis-key("x", ctx))
  let map-y = axis-mapper(ctx, user-axis-key("y", ctx))

  for row in data {
    let raw-x = row.at(cols.x, default: none)
    let cx = map-x(raw-x)
    let mid = parse-number(row.at(cols.y, default: none))
    let lo = parse-number(row.at(cols.ymin, default: none))
    let hi = parse-number(row.at(cols.ymax, default: none))
    if cx == none or mid == none or lo == none or hi == none { continue }
    let cy-mid = map-y(mid)
    let cy-lo = map-y(lo)
    let cy-hi = map-y(hi)
    if cy-mid == none or cy-lo == none or cy-hi == none { continue }

    let band = axis-band(x-trained, raw-x, half-width, x-range)
    let (cx-lo, cx-hi) = if band == none { (cx, cx) } else { band }

    if position-name == "dodge" {
      let span = cx-hi - cx-lo
      let centre = dodge-centre(dodge, row, cx, span)
      let half = dodge-half(row, span / 2)
      cx-lo = centre - half
      cx-hi = centre + half
    }

    let final-fill = resolve-channel(
      "fill",
      layer.params,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let resolved-stroke = resolve-channel(
      "colour",
      layer.params,
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
      pt(cx-lo, cy-lo),
      pt(cx-hi, cy-hi),
      fill: final-fill,
      stroke: stroke-spec,
    )
    cetz.draw.line(
      pt(cx-lo, cy-mid),
      pt(cx-hi, cy-mid),
      stroke: middle-stroke-spec,
    )
  }
}
