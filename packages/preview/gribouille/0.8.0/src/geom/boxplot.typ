///! Boxplots from raw observations using \@stat-boxplot.
///!
///! The default `stat = "boxplot"` reduces each group to one summary row
///! before the geom draws. Pass `stat: "identity"` only when the layer
///! receives pre-computed summary rows (`x`, `lower`, `middle`, `upper`,
///! `ymin`, `ymax`, optional `outliers`).

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
  reads: (
    "x",
    "y",
    "ymin",
    "ymax",
    "lower",
    "middle",
    "upper",
    "colour",
    "fill",
    "alpha",
  ),
  extents: none,
)

/// Boxplot layer: draws a Tukey box, whiskers, and outlier points per group.
///
/// Defaults to `stat = "boxplot"`, so the layer accepts raw observations and computes the five-number summary per group internally. The default `position = "identity"` keeps groups at their categorical x slot; switch to `"dodge"` if you want side-by-side boxes per fill level.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Box width in x data units. For discrete x this is also a data-unit width.
/// - colour: Stroke colour for the box, median, and whiskers. `auto` falls back to the theme ink, since the outline carries the box's structure even when `fill` supplies the body colour.
/// - fill: Box fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Stroke thickness for the box outline and whiskers.
/// - alpha: Box opacity in `[0, 1]`.
/// - outlier-size: Marker size for outlier points.
/// - outlier-colour: Marker colour for outlier points. `auto` follows the box stroke colour.
/// - whisker-cap: Cap length at the whisker ends as a fraction of `width`.
/// - stat: Statistical transform name. `"boxplot"` by default.
/// - position: Position adjustment name. `"identity"` by default.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-boxplot`, `geom-col`.
///
/// Five-number summary computed per category from raw observations.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for i in range(20) {
///     d.push((grp: grp, y: calc.sin(i) + i / 10))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-boxplot(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Add a second mapping (`fill`) and switch `position` to `"dodge"` to compare distributions side by side per group.
///
/// ```typst
/// #let d = ()
/// #for grp in ("a", "b", "c") {
///   for k in ("x", "y") {
///     for i in range(20) {
///       d.push((grp: grp, k: k, y: calc.sin(i) + i / 10 + (if k == "y" { 0.7 } else { 0 })))
///     }
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "k"),
///   layers: (geom-boxplot(position: "dodge"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-boxplot(
  mapping: none,
  data: none,
  width: 0.6,
  colour: auto,
  fill: auto,
  stroke: 0.6pt,
  alpha: auto,
  outlier-size: 1.8pt,
  outlier-colour: auto,
  whisker-cap: 0.5,
  stat: "boxplot",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-boxplot", position)
  assert-alpha("geom-boxplot", alpha)
  assert-number("geom-boxplot", "width", width, min: 0)
  make-layer(
    "boxplot",
    mapping: mapping,
    data: data,
    params: (
      width: width,
      colour: colour,
      fill: fill,
      stroke: stroke,
      alpha: alpha,
      outlier-size: outlier-size,
      outlier-colour: outlier-colour,
      whisker-cap: whisker-cap,
    )
      + split-aes-params("geom-boxplot", args, spec.reads),
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
  let lower-col = mapping.at("lower", default: none)
  let middle-col = mapping.at("middle", default: none)
  let upper-col = mapping.at("upper", default: none)
  if (
    cols.x == none
      or lower-col == none
      or middle-col == none
      or upper-col == none
      or cols.ymin == none
      or cols.ymax == none
  ) { return }

  let axes = user-axes(ctx)
  if axes == none { return }
  let (x-trained, y-trained) = (axes.x-trained, axes.y-trained)
  let x-range = axes.x-range

  let g-defaults = resolve-geom-defaults(ctx.theme)
  // Box outline, median, and whiskers carry the boxplot's structure, so
  // the stroke default always stands even when fill is mapped or pinned.
  let default-colour = resolve-geom-colour(g-defaults)
  let default-fill = resolve-geom-fill(g-defaults, role: "paper")
  let outlier-colour-param = layer.params.outlier-colour
  let outlier-paint-of(resolved-stroke) = if outlier-colour-param != auto {
    outlier-colour-param
  } else { resolved-stroke }
  let stroke-thickness = layer.params.stroke
  let half-width = layer.params.width / 2
  let cap-half = half-width * layer.params.whisker-cap

  let position-name = layer-position-name(layer)
  let dodge = dodge-geometry(ctx, layer)

  let radial = ctx.at("radial", default: none)
  if radial != none {
    if y-trained.type != "continuous" { return }
    // The categories are the user's x on either theta axis, as for every
    // point-like geom: `radial-mappers` puts them on the polar axis x takes.
    let (cat: map-cat, value: map-value) = radial-mappers(ctx)
    let span = radial-category-span(ctx, cols.x, data) * layer.params.width
    for row in data {
      let cat-c = map-cat(row.at(cols.x, default: none))
      let lower = parse-number(row.at(lower-col, default: none))
      let middle = parse-number(row.at(middle-col, default: none))
      let upper = parse-number(row.at(upper-col, default: none))
      let ymin = parse-number(row.at(cols.ymin, default: none))
      let ymax = parse-number(row.at(cols.ymax, default: none))
      if (
        cat-c == none
          or lower == none
          or middle == none
          or upper == none
          or ymin == none
          or ymax == none
      ) { continue }
      let whisker-lo = parse-number(row.at("whisker-lo", default: none))
      let whisker-hi = parse-number(row.at("whisker-hi", default: none))
      if whisker-lo == none { whisker-lo = ymin }
      if whisker-hi == none { whisker-hi = ymax }
      let v-lower = map-value(lower)
      let v-middle = map-value(middle)
      let v-upper = map-value(upper)
      let v-wlo = map-value(whisker-lo)
      let v-whi = map-value(whisker-hi)

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
      let stroke-spec = build-stroke(stroke-thickness, resolved-stroke)

      let half = span / 2
      if position-name == "dodge" {
        cat-c = dodge-centre(dodge, row, cat-c, span)
        half = dodge-half(row, span / 2)
      }
      let cap-half-cat = half * layer.params.whisker-cap

      if radial.cat-is-theta {
        let theta-lo = cat-c - half
        let theta-hi = cat-c + half
        let cap-lo = cat-c - cap-half-cat
        let cap-hi = cat-c + cap-half-cat
        let (r-lower, r-upper) = if v-lower <= v-upper {
          (v-lower, v-upper)
        } else { (v-upper, v-lower) }
        let pts = radial-wedge(theta-lo, theta-hi, r-lower, r-upper, radial)
        cetz.draw.line(
          ..pts,
          close: true,
          fill: final-fill,
          stroke: stroke-spec,
        )
        let median-pts = radial-arc(theta-lo, theta-hi, v-middle, radial)
        cetz.draw.line(..median-pts, stroke: stroke-spec)
        cetz.draw.line(
          polar-canvas(radial, cat-c, v-wlo),
          polar-canvas(radial, cat-c, r-lower),
          stroke: stroke-spec,
        )
        cetz.draw.line(
          polar-canvas(radial, cat-c, r-upper),
          polar-canvas(radial, cat-c, v-whi),
          stroke: stroke-spec,
        )
        if layer.params.whisker-cap > 0 {
          let cap-lo-pts = radial-arc(cap-lo, cap-hi, v-wlo, radial)
          let cap-hi-pts = radial-arc(cap-lo, cap-hi, v-whi, radial)
          cetz.draw.line(..cap-lo-pts, stroke: stroke-spec)
          cetz.draw.line(..cap-hi-pts, stroke: stroke-spec)
        }
        let outlier-paint = outlier-paint-of(resolved-stroke)
        let outliers = row.at("outliers", default: ())
        for ov in outliers {
          let v = parse-number(ov)
          if v == none { continue }
          let r = map-value(v)
          cetz.draw.circle(
            polar-canvas(radial, cat-c, r),
            radius: layer.params.outlier-size,
            fill: outlier-paint,
            stroke: none,
          )
        }
      } else {
        // Theta-axis carries values: box wedge spans the theta range, with
        // category along radial. Whiskers run as arcs at constant r-mid.
        let r-lo = cat-c - half
        let r-hi = cat-c + half
        let cap-rlo = cat-c - cap-half-cat
        let cap-rhi = cat-c + cap-half-cat
        let pts = radial-wedge(v-lower, v-upper, r-lo, r-hi, radial)
        cetz.draw.line(
          ..pts,
          close: true,
          fill: final-fill,
          stroke: stroke-spec,
        )
        cetz.draw.line(
          polar-canvas(radial, v-middle, r-lo),
          polar-canvas(radial, v-middle, r-hi),
          stroke: stroke-spec,
        )
        let whisker-lo-pts = radial-arc(v-wlo, v-lower, cat-c, radial)
        let whisker-hi-pts = radial-arc(v-upper, v-whi, cat-c, radial)
        cetz.draw.line(..whisker-lo-pts, stroke: stroke-spec)
        cetz.draw.line(..whisker-hi-pts, stroke: stroke-spec)
        if layer.params.whisker-cap > 0 {
          cetz.draw.line(
            polar-canvas(radial, v-wlo, cap-rlo),
            polar-canvas(radial, v-wlo, cap-rhi),
            stroke: stroke-spec,
          )
          cetz.draw.line(
            polar-canvas(radial, v-whi, cap-rlo),
            polar-canvas(radial, v-whi, cap-rhi),
            stroke: stroke-spec,
          )
        }
        let outlier-paint = outlier-paint-of(resolved-stroke)
        let outliers = row.at("outliers", default: ())
        for ov in outliers {
          let v = parse-number(ov)
          if v == none { continue }
          let theta = map-value(v)
          cetz.draw.circle(
            polar-canvas(radial, theta, cat-c),
            radius: layer.params.outlier-size,
            fill: outlier-paint,
            stroke: none,
          )
        }
      }
    }
    return
  }

  if y-trained.type != "continuous" { return }

  let pt = user-point.with(ctx)
  let map-x = axis-mapper(ctx, user-axis-key("x", ctx))
  let map-y = axis-mapper(ctx, user-axis-key("y", ctx), space: "stat")

  for row in data {
    let raw-x = row.at(cols.x, default: none)
    let cx = map-x(raw-x)
    if cx == none { continue }

    let lower = parse-number(row.at(lower-col, default: none))
    let middle = parse-number(row.at(middle-col, default: none))
    let upper = parse-number(row.at(upper-col, default: none))
    let ymin = parse-number(row.at(cols.ymin, default: none))
    let ymax = parse-number(row.at(cols.ymax, default: none))
    if (
      lower == none
        or middle == none
        or upper == none
        or ymin == none
        or ymax == none
    ) { continue }

    // Whisker endpoints come from explicit fields when stat-boxplot supplies
    // them; otherwise we fall back to ymin/ymax (identity stat with
    // pre-computed summaries that omit outlier extremes).
    let whisker-lo = parse-number(row.at("whisker-lo", default: none))
    let whisker-hi = parse-number(row.at("whisker-hi", default: none))
    if whisker-lo == none { whisker-lo = ymin }
    if whisker-hi == none { whisker-hi = ymax }

    let cy-lower = map-y(lower)
    let cy-middle = map-y(middle)
    let cy-upper = map-y(upper)
    let cy-whisker-lo = map-y(whisker-lo)
    let cy-whisker-hi = map-y(whisker-hi)

    let boaxis-band = axis-band(x-trained, raw-x, half-width, x-range)
    let cap-band = axis-band(x-trained, raw-x, cap-half, x-range)
    if boaxis-band == none or cap-band == none { continue }
    let (cx-lo, cx-hi) = boaxis-band
    let (cap-lo, cap-hi) = cap-band

    let centre = cx
    if position-name == "dodge" {
      let span = cx-hi - cx-lo
      centre = dodge-centre(dodge, row, cx, span)
      let box-half = dodge-half(row, span / 2)
      let cap-half-shrunk = dodge-half(row, (cap-hi - cap-lo) / 2)
      cx-lo = centre - box-half
      cx-hi = centre + box-half
      cap-lo = centre - cap-half-shrunk
      cap-hi = centre + cap-half-shrunk
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
    let stroke-spec = build-stroke(stroke-thickness, resolved-stroke)

    cetz.draw.rect(
      pt(cx-lo, cy-lower),
      pt(cx-hi, cy-upper),
      fill: final-fill,
      stroke: stroke-spec,
    )

    cetz.draw.line(
      pt(cx-lo, cy-middle),
      pt(cx-hi, cy-middle),
      stroke: stroke-spec,
    )

    cetz.draw.line(
      pt(centre, cy-whisker-lo),
      pt(centre, cy-lower),
      stroke: stroke-spec,
    )
    cetz.draw.line(
      pt(centre, cy-upper),
      pt(centre, cy-whisker-hi),
      stroke: stroke-spec,
    )

    if layer.params.whisker-cap > 0 {
      cetz.draw.line(
        pt(cap-lo, cy-whisker-lo),
        pt(cap-hi, cy-whisker-lo),
        stroke: stroke-spec,
      )
      cetz.draw.line(
        pt(cap-lo, cy-whisker-hi),
        pt(cap-hi, cy-whisker-hi),
        stroke: stroke-spec,
      )
    }

    let outlier-paint = outlier-paint-of(resolved-stroke)
    let outliers = row.at("outliers", default: ())
    for ov in outliers {
      let v = parse-number(ov)
      if v == none { continue }
      let cy = map-y(v)
      cetz.draw.circle(
        pt(centre, cy),
        radius: layer.params.outlier-size,
        fill: outlier-paint,
        stroke: none,
      )
    }
  }
}
