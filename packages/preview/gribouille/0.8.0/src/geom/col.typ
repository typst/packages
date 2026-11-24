///! Vertical bars taking heights directly from the y aesthetic.
///!
///! Use `geom-col` for pre-aggregated data; use \@geom-bar when you want the
///! layer to count observations for you. The layer honours `position: "stack"`,
///! `"dodge"`, and `"fill"` via the matching position adjustments.

#import "../utils/errors.typ": assert-alpha, assert-fraction
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../position/apply.typ": (
  assert-position, layer-marks-abut, layer-position-name,
)
#import "../position/dodge.typ": dodge-centre, dodge-geometry, dodge-half
#import "../utils/aes-resolve.typ": resolve-channel
#import "../coord/project.typ": axis-mapper, project-uvs
#import "../scale/train.typ": discrete-slot-width, mapping-ref-col
#import "../utils/flip.typ": user-axes, user-axis-key, user-columns, user-point
#import "../utils/types.typ": parse-number
#import "../utils/aes-pair.typ": resolve-pair-defaults
#import "../utils/radial.typ": (
  radial-category-span, radial-mappers, radial-wedge,
)
#import "../utils/bucket.typ": bucket-index
#import "../utils/stroke.typ": (
  resolve-stroke-spec, seals-seam, seam-seal-thickness,
)
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
  resolve-geom-linewidth,
)

// Outer edges of the bars on a continuous `x` axis. A bar spans
// `width` times the smallest gap between distinct `x` values, the same rule
// as `draw`. Dodged rows of mixed `width` share out the whole gap, so the
// outer bars reach half a gap past the outer `x`. `none` when the layer has
// no numeric `x` or nothing to pad.
#let _extents(params, mapping, data) = {
  let none-ext = (x: none, y: none)
  let x-col = mapping-ref-col(mapping.at("x", default: none))
  if x-col == none { return none-ext }
  // Sorted first, then walked: duplicates sit side by side as a zero gap,
  // which is skipped, so no `dedup` pass is needed.
  let xs = data
    .map(r => parse-number(r.at(x-col, default: none)))
    .filter(v => v != none)
    .sorted()
  if xs.len() == 0 { return none-ext }
  let min-gap = none
  for i in range(xs.len() - 1) {
    let gap = xs.at(i + 1) - xs.at(i)
    if gap == 0 { continue }
    if min-gap == none or gap < min-gap { min-gap = gap }
  }
  if min-gap == none { return none-ext }
  // Dodge writes its offset on every row, so the first row tells whether
  // the layer dodged, and the widths are read only when it did. One width
  // for every row splits each gap evenly, inside `width` of it. A row with
  // no `width` takes the layer width, as in dodge.
  let bar-frac = params.at("width", default: 0.9)
  let fills-gap = (
    "_dodge-offset" in data.first()
      and data
        .map(r => {
          let w = parse-number(r.at("width", default: none))
          if w == none { bar-frac } else { w }
        })
        .dedup()
        .len()
        > 1
  )
  let reach = if fills-gap { calc.max(bar-frac, 1) } else { bar-frac }
  let bar-half = min-gap * reach / 2
  if bar-half <= 0 { return none-ext }
  (x: (xs.first() - bar-half, xs.last() + bar-half), y: none)
}

#let spec = (
  reads: ("x", "y", "ymin", "ymax", "colour", "fill", "alpha", "stroke"),
  extents: _extents,
)

/// Bar layer with heights taken from the y aesthetic.
///
/// Each row becomes one bar centred at its x value. Use `geom-bar` (stat-count) when you want automatic counting; `geom-col` expects pre-aggregated y.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Bar width as a fraction of the category width, in `(0, 1]`.
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
  ..args,
) = {
  assert-alpha("geom-col", alpha)
  assert-fraction("geom-col", "width", width)
  assert-position("geom-col", position)
  make-layer(
    "col",
    mapping: mapping,
    data: data,
    params: (
      width: width,
      colour: colour,
      fill: fill,
      stroke: stroke,
      alpha: alpha,
    )
      + split-aes-params("geom-col", args, spec.reads),
    key: key,
    stat: stat,
    position: position,
    inherit-aes: inherit-aes,
  )
}

// Canvas length every sealed segment overlaps its neighbour by.
#let _overlap = seam-seal-thickness / 1cm

// Angle that spans `_overlap` along an arc of radius `r`. A segment at the
// centre has no arc to measure, so its overlap is clamped by its neighbour
// alone.
#let _overlap-angle(r) = if r > 0 { _overlap / r } else { float.inf }

// Corners of one bar segment in category and value coordinates, filled from
// its lower value edge up to `top`. `sliver`, when set, is `(lo, hi, reach)`:
// over the value span from `lo` to `hi`, the segment reaches past its upper
// category edge to `reach`, into the bar next to it.
#let _segment-corners(segment, top, sliver) = {
  let (s-lo, s-hi, reach) = sliver
  (
    (segment.lo, segment.v-lo),
    (segment.hi, segment.v-lo),
    (segment.hi, s-lo),
    (reach, s-lo),
    (reach, s-hi),
    (segment.hi, s-hi),
    (segment.hi, top),
    (segment.lo, top),
  )
}

#let _draw-segment(ctx, segment, top, sliver: none) = {
  if sliver == none {
    cetz.draw.rect(
      user-point(ctx, segment.lo, segment.v-lo),
      user-point(ctx, segment.hi, top),
      fill: segment.fill,
      stroke: segment.stroke,
    )
    return
  }
  cetz.draw.line(
    .._segment-corners(segment, top, sliver).map(((u, v)) => user-point(
      ctx,
      u,
      v,
    )),
    close: true,
    fill: segment.fill,
    stroke: segment.stroke,
  )
}

// The wedge of one bar segment under `coord-radial`, with the same corners
// as `_draw-segment`. The category is the angle under `theta: "x"` and the
// radius under `theta: "y"`.
#let _draw-wedge(ctx, segment, top, sliver: none) = {
  let pts = if sliver != none {
    project-uvs(ctx, _segment-corners(segment, top, sliver), closed: true)
  } else if ctx.radial.cat-is-theta {
    radial-wedge(segment.lo, segment.hi, segment.v-lo, top, ctx.radial)
  } else {
    radial-wedge(segment.v-lo, top, segment.lo, segment.hi, ctx.radial)
  }
  cetz.draw.line(
    ..pts,
    close: true,
    fill: segment.fill,
    stroke: segment.stroke,
  )
}

// Stacked segments seal their seams by overlap, not by the seal stroke. The
// stroke paints outside every side, so a segment would spill onto the bar
// next to it, and the group drawn last would set where that edge falls.
// A sealed segment reaches `rise(segment)` up into the sealed segment above
// it, and `across(segment, lo)` across into the bar on its upper category
// side over the span that bar covers, from value `lo` up. Both default to
// `_overlap`, the plain length on a Cartesian panel. Stacks draw in
// category order and each one from the bottom up, so a segment drawn later
// covers every overlap. No overlap reaches past the top of its own stack or
// the far edge of the next bar, so each outer edge stays where the data
// puts it.
//
// `turn`, when set, is the value span of a full circle. A stack that spans
// it has its top meet its bottom, and its bottom segment, drawn first,
// reaches down into the top segment, which covers that overlap.
#let _draw-stacked(
  segments,
  draw,
  rise: _ => _overlap,
  across: (..) => _overlap,
  turn: none,
) = {
  let stacks = bucket-index(
    segments.sorted(key: s => (s.lo, s.v-lo)),
    s => repr(s.lo),
  ).buckets

  for (i, stack) in stacks.enumerate() {
    let next = stacks.at(i + 1, default: none)
    let abuts = (
      next != none
        and next.all(s => s.sealed)
        and calc.abs(next.first().lo - stack.first().hi) < 1e-9
    )
    let span = if abuts {
      (calc.min(..next.map(s => s.v-lo)), calc.max(..next.map(s => s.v-hi)))
    } else { none }
    // Segments overlap where a stack holds a negative value, so the last
    // one by its lower edge need not reach the highest edge.
    let first = stack.first()
    let last = stack.sorted(key: s => s.v-hi).last()
    let stack-top = last.v-hi
    let wraps = (
      turn != none
        and first.sealed
        and last.sealed
        and calc.abs(stack-top - first.v-lo - turn) < 1e-9
    )

    for (j, segment) in stack.enumerate() {
      if not segment.sealed {
        draw(segment, segment.v-hi)
        continue
      }
      if j == 0 and wraps {
        segment.v-lo -= calc.min(rise(segment), last.v-hi - last.v-lo)
      }
      let above = stack.at(j + 1, default: none)
      let top = if above != none and above.sealed {
        calc.max(
          segment.v-hi,
          calc.min(segment.v-hi + rise(segment), above.v-hi),
        )
      } else { segment.v-hi }
      let sliver = if span == none { none } else {
        let s-lo = calc.max(segment.v-lo, span.at(0))
        let s-hi = calc.min(top, span.at(1))
        let reach = calc.min(
          segment.hi + across(segment, s-lo),
          next.first().hi,
        )
        if s-hi > s-lo { (s-lo, s-hi, reach) } else { none }
      }
      draw(segment, top, sliver: sliver)
    }
  }
}

#let _draw-radial(layer, ctx, mapping, data, radial) = {
  let cat-trained = ctx.trained.at("x", default: none)
  let value-trained = ctx.trained.at("y", default: none)
  if cat-trained == none or value-trained == none { return }
  if value-trained.type != "continuous" { return }

  let cat-col = mapping.x
  let value-col = mapping.y
  let position = layer-position-name(layer)
  let dodge = dodge-geometry(ctx, layer)
  // Only stacked segments share an edge; a bar that stands on its own would
  // lose part of its category gap to the seal.
  let abutting = layer-marks-abut(layer)
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

  let (cat: map-cat, value: map-value) = radial-mappers(ctx)
  let category-span = radial-category-span(ctx, cat-col, data)
  let half = category-span * bar-width-fraction / 2

  let segments = ()
  for row in data {
    let cat-c = map-cat(row.at(cat-col, default: none))
    if cat-c == none { continue }

    let (v-lo, v-hi) = if use-minmax {
      let lo-v = parse-number(row.at(vmin-col, default: none))
      let hi-v = parse-number(row.at(vmax-col, default: none))
      if lo-v == none or hi-v == none { continue }
      (map-value(lo-v), map-value(hi-v))
    } else {
      let raw = parse-number(row.at(value-col, default: none))
      if raw == none { continue }
      (map-value(baseline), map-value(raw))
    }

    let final-fill = resolve-channel(
      "fill",
      layer.params,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = resolve-stroke-spec(
      layer.params,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )
    let sealed = seals-seam(stroke-spec, final-fill, abutting: abutting)
    if use-minmax and v-lo == v-hi and sealed { continue }

    let centre = cat-c
    let bar-half = half
    if position == "dodge" {
      centre = dodge-centre(dodge, row, cat-c, 2 * half)
      bar-half = dodge-half(row, half)
    }

    let segment = (
      lo: calc.min(centre - bar-half, centre + bar-half),
      hi: calc.max(centre - bar-half, centre + bar-half),
      v-lo: calc.min(v-lo, v-hi),
      v-hi: calc.max(v-lo, v-hi),
      fill: final-fill,
      stroke: stroke-spec,
      sealed: sealed,
    )
    if use-minmax {
      segments.push(segment)
    } else {
      _draw-wedge(ctx, segment, segment.v-hi)
    }
  }
  if not use-minmax { return }
  // Along the radius an overlap is a plain length. Along the angle it is
  // measured on the smallest radius it covers, so it is never shorter than
  // `_overlap` on the canvas.
  if radial.cat-is-theta {
    _draw-stacked(
      segments,
      _draw-wedge.with(ctx),
      across: (_, lo) => _overlap-angle(lo),
    )
  } else {
    _draw-stacked(
      segments,
      _draw-wedge.with(ctx),
      rise: segment => _overlap-angle(segment.lo),
      turn: 2 * calc.pi,
    )
  }
}

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or mapping.x == none or mapping.y == none { return }
  let axes = user-axes(ctx)
  if axes == none { return }

  let radial = ctx.at("radial", default: none)
  if radial != none {
    _draw-radial(layer, ctx, mapping, data, radial)
    return
  }

  // The value axis is the user's y and the category axis the user's x, which
  // the flip swap moves onto the other canvas axes.
  let value-trained = axes.y-trained
  let cat-trained = axes.x-trained
  let columns = user-columns(mapping, ctx)
  let value-col = columns.y
  let cat-col = columns.x
  let cat-range = axes.x-range
  if value-trained.type != "continuous" { return }

  let position = layer-position-name(layer)
  let dodge = dodge-geometry(ctx, layer)
  // Only stacked segments share an edge; a bar that stands on its own would
  // lose part of its category gap to the seal.
  let abutting = layer-marks-abut(layer)
  // Stacked/filled bars receive ymin/ymax from the position adjustment under
  // either orientation; the position writes them under the y keys, and under
  // flip the renderer's mapping swap routes them onto x.
  let vmin-col = columns.ymin
  let vmax-col = columns.ymax
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

  let map-cat = axis-mapper(ctx, user-axis-key("x", ctx))
  let map-cat-stat = axis-mapper(ctx, user-axis-key("x", ctx), space: "stat")
  let map-value = axis-mapper(
    ctx,
    user-axis-key("y", ctx),
    space: "stat",
  )
  let baseline-vc = map-value(calc.max(0.0, value-trained.domain.at(0)))

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
        map-cat-stat(sorted.at(i + 1)) - map-cat-stat(sorted.at(i)),
      ))
      calc.min(..panel-gaps)
    }
  }
  let bar-width-fraction = layer.params.width
  let half = category-span * bar-width-fraction / 2

  let segments = ()
  for row in data {
    let cat-c = map-cat(row.at(cat-col, default: none))
    if cat-c == none { continue }

    let (v-lo-c, v-hi-c) = if use-minmax {
      let lo-v = parse-number(row.at(vmin-col, default: none))
      let hi-v = parse-number(row.at(vmax-col, default: none))
      if lo-v == none or hi-v == none { continue }
      (map-value(lo-v), map-value(hi-v))
    } else {
      let raw = parse-number(row.at(value-col, default: none))
      if raw == none { continue }
      let vc = map-value(raw)
      if vc >= baseline-vc { (baseline-vc, vc) } else { (vc, baseline-vc) }
    }

    let centre = cat-c
    let bar-half = half
    if position == "dodge" {
      let bucket = category-span * bar-width-fraction
      centre = dodge-centre(dodge, row, cat-c, bucket)
      bar-half = dodge-half(row, bucket / 2)
    }

    let final-fill = resolve-channel(
      "fill",
      layer.params,
      mapping,
      ctx,
      row,
      default-fill,
    )
    let stroke-spec = resolve-stroke-spec(
      layer.params,
      mapping,
      ctx,
      row,
      default-colour,
      default-thickness: default-thickness,
    )

    let sealed = seals-seam(stroke-spec, final-fill, abutting: abutting)
    if use-minmax and v-lo-c == v-hi-c and sealed { continue }
    let segment = (
      lo: centre - bar-half,
      hi: centre + bar-half,
      v-lo: calc.min(v-lo-c, v-hi-c),
      v-hi: calc.max(v-lo-c, v-hi-c),
      fill: final-fill,
      stroke: stroke-spec,
      sealed: sealed,
    )
    if use-minmax {
      segments.push(segment)
    } else {
      _draw-segment(ctx, segment, segment.v-hi)
    }
  }
  if use-minmax {
    _draw-stacked(segments, _draw-segment.with(ctx))
  }
}
