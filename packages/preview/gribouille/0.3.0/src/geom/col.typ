///! Vertical bars taking heights directly from the y aesthetic.
///!
///! Use `geom-col` for pre-aggregated data; use \@geom-bar when you want the
///! layer to count observations for you. The layer honours `position: "stack"`,
///! `"dodge"`, and `"fill"` via the matching position adjustments.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../position/apply.typ": layer-position-name
#import "../position/dodge.typ": dodge-centre, dodge-half
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": discrete-slot-width, map-axis, map-position
#import "../utils/types.typ": parse-number
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": (
  radial-axis-ranges, radial-category-span, radial-wedge,
)
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

/// Bar layer with heights taken from the y aesthetic.
///
/// Each row becomes one bar centred at its x value. Use `geom-bar` (stat-count) when you want automatic counting; `geom-col` expects pre-aggregated y.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Bar width as a fraction of the category width (0 to 1).
/// - colour: Bar outline colour. `auto` resolves via the colour scale, falling back to the theme `ink` only when neither `colour` nor `fill` is set.
/// - fill: Bar fill colour. `auto` resolves via the fill scale or a neutral default.
/// - stroke: Bar outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Bar opacity in `[0, 1]`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - stat: Statistical transform name. Usually `"identity"`.
/// - position: Position adjustment: `"identity"`, `"stack"`, `"dodge"`, or `"fill"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-bar`, `position-stack`, `position-dodge`, `position-fill`.
///
/// Pre-aggregated heights drawn one bar per row.
///
/// ```typst
/// #let d = (
///   (q: "Q1", revenue: 10),
///   (q: "Q2", revenue: 18),
///   (q: "Q3", revenue: 25),
///   (q: "Q4", revenue: 22),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "revenue"),
///   layers: (geom-col(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Adding a `fill` mapping with `position: "stack"` (default for stacked) accumulates contributions per category.
///
/// ```typst
/// #let d = (
///   (q: "Q1", revenue: 6, region: "EU"),
///   (q: "Q1", revenue: 4, region: "US"),
///   (q: "Q2", revenue: 9, region: "EU"),
///   (q: "Q2", revenue: 9, region: "US"),
///   (q: "Q3", revenue: 14, region: "EU"),
///   (q: "Q3", revenue: 11, region: "US"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "revenue", fill: "region"),
///   layers: (geom-col(position: "stack"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-col(
  mapping: none,
  data: none,
  width: 0.9,
  colour: auto,
  fill: auto,
  stroke: none,
  alpha: auto,
  key: auto,
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "col",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  ),
  key: key,
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let _draw-radial(layer, ctx, mapping, data, radial) = {
  let cat-trained = ctx.trained.at("x", default: none)
  let value-trained = ctx.trained.at("y", default: none)
  if cat-trained == none or value-trained == none { return }
  if value-trained.type != "continuous" { return }

  let cat-col = mapping.x
  let value-col = mapping.y
  let position = layer-position-name(layer)
  let vmin-col = mapping.at("ymin", default: none)
  let vmax-col = mapping.at("ymax", default: none)
  let use-minmax = (
    (position == "stack" or position == "fill")
      and vmin-col != none
      and vmax-col != none
  )

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults, role: none),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  let baseline = calc.max(0.0, value-trained.domain.at(0))
  let bar-width-fraction = layer.params.width

  let (cat-range, value-range) = radial-axis-ranges(radial)
  let category-span = radial-category-span(
    cat-trained,
    cat-col,
    cat-range,
    data,
  )
  let half = category-span * bar-width-fraction / 2

  for row in data {
    let cat-c = map-position(
      cat-trained,
      row.at(cat-col, default: none),
      cat-range,
    )
    if cat-c == none { continue }

    let (v-lo, v-hi) = if use-minmax {
      let lo-v = parse-number(row.at(vmin-col, default: none))
      let hi-v = parse-number(row.at(vmax-col, default: none))
      if lo-v == none or hi-v == none { continue }
      (
        map-axis(value-trained, lo-v, value-range),
        map-axis(value-trained, hi-v, value-range),
      )
    } else {
      let raw = parse-number(row.at(value-col, default: none))
      if raw == none { continue }
      (
        map-axis(value-trained, baseline, value-range),
        map-axis(value-trained, raw, value-range),
      )
    }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )

    let (theta-lo, theta-hi, r-lo, r-hi) = if radial.cat-is-theta {
      (cat-c - half, cat-c + half, v-lo, v-hi)
    } else {
      (v-lo, v-hi, cat-c - half, cat-c + half)
    }
    if r-lo > r-hi { (r-lo, r-hi) = (r-hi, r-lo) }

    let pts = radial-wedge(theta-lo, theta-hi, r-lo, r-hi, radial)
    cetz.draw.line(
      ..pts,
      close: true,
      fill: final-fill,
      stroke: stroke-spec,
    )
  }
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let radial = ctx.at("radial", default: none)
  if radial != none {
    _draw-radial(layer, ctx, mapping, data, radial)
    return
  }

  let flipped = ctx.at("flipped", default: false)
  // Under flip, the value axis is x and the category axis is y; otherwise
  // the value axis is y and the category axis is x. Bind local aliases so
  // the rest of the routine reads the same regardless of orientation.
  let value-trained = if flipped { x-trained } else { y-trained }
  let cat-trained = if flipped { y-trained } else { x-trained }
  let value-col = if flipped { mapping.x } else { mapping.y }
  let cat-col = if flipped { mapping.y } else { mapping.x }
  let value-range = if flipped { ctx.px-range } else { ctx.py-range }
  let cat-range = if flipped { ctx.py-range } else { ctx.px-range }
  if value-trained.type != "continuous" { return }

  let position = layer-position-name(layer)
  let vmin-col = mapping.at(
    if flipped { "xmin" } else { "ymin" },
    default: none,
  )
  let vmax-col = mapping.at(
    if flipped { "xmax" } else { "ymax" },
    default: none,
  )
  // Stacked/filled bars receive ymin/ymax from the position adjustment under
  // either orientation; the position writes them under the y keys, and under
  // flip the renderer's mapping swap routes them onto x.
  if flipped and vmin-col == none and vmax-col == none {
    vmin-col = mapping.at("ymin", default: none)
    vmax-col = mapping.at("ymax", default: none)
  }
  let use-minmax = (
    (position == "stack" or position == "fill")
      and vmin-col != none
      and vmax-col != none
  )

  let g-defaults = resolve-geom-defaults(ctx.theme)
  let default-thickness = resolve-geom-linewidth(g-defaults)
  let (default-colour, default-fill) = resolve-pair-defaults(
    layer,
    mapping,
    resolve-geom-colour(g-defaults, role: none),
    resolve-geom-fill(g-defaults, role: "tint"),
  )

  let baseline-vc = map-axis(
    value-trained,
    calc.max(0.0, value-trained.domain.at(0)),
    value-range,
  )

  let (cat-lo, cat-hi) = cat-range
  let category-span = if (
    cat-trained.type == "discrete" and cat-trained.domain.len() > 0
  ) {
    discrete-slot-width(cat-trained, cat-range)
  } else {
    // Continuous category axis: infer from minimum gap between unique values.
    let xs = data
      .map(r => parse-number(r.at(cat-col, default: none)))
      .filter(v => v != none)
    let (d-lo, d-hi) = cat-trained.domain
    let sorted = xs.dedup().sorted()
    if sorted.len() < 2 or d-hi == d-lo {
      (cat-hi - cat-lo) / 10
    } else {
      let panel-gaps = range(sorted.len() - 1).map(i => calc.abs(
        map-axis(cat-trained, sorted.at(i + 1), cat-range)
          - map-axis(cat-trained, sorted.at(i), cat-range),
      ))
      calc.min(..panel-gaps)
    }
  }
  let bar-width-fraction = layer.params.width
  let half = category-span * bar-width-fraction / 2

  for row in data {
    let cat-c = map-position(
      cat-trained,
      row.at(cat-col, default: none),
      cat-range,
    )
    if cat-c == none { continue }

    let (v-lo-c, v-hi-c) = if use-minmax {
      let lo-v = parse-number(row.at(vmin-col, default: none))
      let hi-v = parse-number(row.at(vmax-col, default: none))
      if lo-v == none or hi-v == none { continue }
      (
        map-axis(value-trained, lo-v, value-range),
        map-axis(value-trained, hi-v, value-range),
      )
    } else {
      let raw = parse-number(row.at(value-col, default: none))
      if raw == none { continue }
      let vc = map-axis(value-trained, raw, value-range)
      if vc >= baseline-vc { (baseline-vc, vc) } else { (vc, baseline-vc) }
    }

    let centre = cat-c
    let bar-half = half
    if position == "dodge" {
      let bucket = category-span * bar-width-fraction
      centre = dodge-centre(row, cat-c, bucket)
      bar-half = dodge-half(row, bucket / 2)
    }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )

    let (a, b) = if flipped {
      ((v-lo-c, centre - bar-half), (v-hi-c, centre + bar-half))
    } else {
      ((centre - bar-half, v-lo-c), (centre + bar-half, v-hi-c))
    }

    cetz.draw.rect(
      a,
      b,
      fill: final-fill,
      stroke: stroke-spec,
    )
  }
}
