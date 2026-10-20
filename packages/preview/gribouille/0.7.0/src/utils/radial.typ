///! Joint `(x, y) → (cx, cy)` projection helpers for `coord-radial`.

#import "../scale/train.typ": (
  discrete-slot-width, level-position, map-axis, map-position,
)
#import "types.typ": parse-number

// True when the coord is any flavour of `coord-radial`.
#let is-radial(coord) = (
  coord != none and coord.at("name", default: none) == "radial"
)

// Gap (cm) between the outer theta arc and the tick labels ringing it. The
// draw site offsets the labels by it and the chrome stage reserves the band
// they land in, so the two cannot drift apart.
#let THETA-LABEL-PAD = 0.2

// The axis the sweep runs along. `none` off a radial coord, so callers can
// compare an axis key against it unguarded.
#let theta-axis-of(coord) = if is-radial(coord) {
  coord.at("theta", default: "x")
} else { none }

// Its complement, the axis the radius runs along: "y" when theta is "x"
// (rose/radar) and "x" when theta is "y" (pie). Used during scale expansion,
// which runs before trained scales exist and so cannot route through
// `radial-ctx`.
#let radial-axis-of(coord) = {
  let theta = theta-axis-of(coord)
  if theta == none { none } else if theta == "x" { "y" } else { "x" }
}

// The `(theta-lo, theta-hi)` sweep in canvas radians. It falls out of the
// coord alone, with no panel rect in sight, which is what lets the chrome
// stage project theta breaks before the panel it will draw them in exists.
// Unlike `theta-axis-of` it reads a radial coord's own keys, so callers
// establish they have one first.
#let theta-range-of(coord) = {
  let start = coord.at("start", default: 0)
  let direction = coord.at("direction", default: 1)
  let end = coord.at("end", default: none)
  let end-eff = if end == none { start + direction * 2 * calc.pi } else { end }
  (calc.pi / 2 - start, calc.pi / 2 - end-eff)
}

// `start = 0` plus `direction = 1` reproduce the conventional layout: the
// first slice opens at 12 o'clock and the sweep advances clockwise. Encoding the
// sweep as a `(theta-lo, theta-hi)` pair lets `map-position` produce angles
// directly through the existing scale-mapping routines.
// Below this the angle is flat enough against an axis that the label reaches
// nothing along it, and the bound it would give divides by nearly zero.
#let _TRIG-EPS = 1e-9

// `label-bounds` carries one record per theta tick label: the canvas angle
// `theta` it is drawn at and the half-extents `hw` / `hh` it reaches from
// there. `tick-cm` is how far the theta tick marks reach outward from the
// circle, drawn between it and the labels. Each label is centred `tick-cm`
// plus `THETA-LABEL-PAD` beyond `r-max`, so both stay inside the panel while
//
//   (r-max + tick-cm + THETA-LABEL-PAD) * |cos theta| + hw <= half-width
//   (r-max + tick-cm + THETA-LABEL-PAD) * |sin theta| + hh <= half-height
//
// and `r-max` is the tightest radius those two bounds leave across every
// label. Solving per label rather than insetting all four sides by the widest
// one means a label only costs the circle the direction it is drawn in: the
// panel is the room the chrome already granted this plot, and growing past it
// would push the whole figure past the `width`/`height` it was asked for.
// `tick-cm` comes off the seed too, because a plot with no theta labels at all
// still draws its ticks, and there the inscribed circle is what binds.
#let radial-ctx(
  coord,
  x-trained,
  y-trained,
  px-range,
  py-range,
  label-bounds: (),
  tick-cm: 0.0,
) = {
  if not is-radial(coord) { return none }
  let (px-lo, px-hi) = px-range
  let (py-lo, py-hi) = py-range
  let centre = ((px-lo + px-hi) / 2, (py-lo + py-hi) / 2)
  let half-w = (px-hi - px-lo) / 2
  let half-h = (py-hi - py-lo) / 2
  let outer-pad = tick-cm + THETA-LABEL-PAD
  let r-max = calc.min(half-w, half-h) - tick-cm
  for b in label-bounds {
    let cos-t = calc.abs(calc.cos(b.theta))
    let sin-t = calc.abs(calc.sin(b.theta))
    if cos-t > _TRIG-EPS {
      r-max = calc.min(r-max, (half-w - b.hw) / cos-t - outer-pad)
    }
    if sin-t > _TRIG-EPS {
      r-max = calc.min(r-max, (half-h - b.hh) / sin-t - outer-pad)
    }
  }
  r-max = calc.max(0, r-max)
  let theta-axis = theta-axis-of(coord)
  let (theta-lo, theta-hi) = theta-range-of(coord)
  (
    coord: "radial",
    centre: centre,
    r-max: r-max,
    theta-axis: theta-axis,
    cat-is-theta: theta-axis == "x",
    theta-range: (theta-lo, theta-hi),
    r-range: (0, r-max),
    clip: coord.at("clip", default: false),
    x-trained: x-trained,
    y-trained: y-trained,
  )
}

#let _theta-trained(radial) = if radial.cat-is-theta {
  radial.x-trained
} else { radial.y-trained }

#let _r-trained(radial) = if radial.cat-is-theta {
  radial.y-trained
} else { radial.x-trained }

#let radial-theta(value, radial) = {
  let trained = _theta-trained(radial)
  if trained == none { return none }
  map-position(trained, value, radial.theta-range)
}

#let radial-r(value, radial) = {
  let trained = _r-trained(radial)
  if trained == none { return none }
  map-position(trained, value, radial.r-range)
}

#let radial-point(x-val, y-val, radial) = {
  let (ang-val, rad-val) = if radial.cat-is-theta {
    (x-val, y-val)
  } else { (y-val, x-val) }
  let theta = radial-theta(ang-val, radial)
  let r = radial-r(rad-val, radial)
  if theta == none or r == none { return none }
  let (cx, cy) = radial.centre
  (cx + r * calc.cos(theta), cy + r * calc.sin(theta))
}

// Single entry point for geoms: projects a row's `(x, y)` to canvas units
// via either the trained scales or the active radial bundle. Returns `none`
// when either coordinate fails to resolve.
#let project-point(ctx, xv, yv) = {
  let radial = ctx.at("radial", default: none)
  if radial != none { return radial-point(xv, yv, radial) }
  let xt = ctx.trained.at("x", default: none)
  let yt = ctx.trained.at("y", default: none)
  if xt == none or yt == none { return none }
  let cx = map-position(xt, xv, ctx.px-range)
  let cy = map-position(yt, yv, ctx.py-range)
  if cx == none or cy == none { return none }
  (cx, cy)
}

// Trained scale for one axis, taken from the radial bundle when a radial coord
// is active and from `ctx.trained` otherwise. Mirrors `project-point`'s split.
#let _axis-trained(ctx, axis) = {
  let radial = ctx.at("radial", default: none)
  if radial != none { return radial.at(axis + "-trained", default: none) }
  ctx.trained.at(axis, default: none)
}

// Numeric position of `value` on one axis: the parsed number on a continuous
// scale and the 1-indexed level position on a discrete one. `none` when the
// value resolves to neither, so callers can skip that axis.
#let axis-numeric(ctx, axis, value) = {
  let trained = _axis-trained(ctx, axis)
  if trained == none { return none }
  if trained.type == "continuous" { return parse-number(value) }
  level-position(trained, value)
}

// Add a canvas-cm `(dx, dy)` offset to a projected `(cx, cy)` point.
#let shift-point(p, delta) = (p.at(0) + delta.at(0), p.at(1) + delta.at(1))

// Group break values by canvas angle modulo a full turn. `project` maps a
// break to canvas radians (or `none` to skip). Returns an array of groups,
// where each group is an array of `(idx, b, theta)` records sharing an
// angle. First-seen order is preserved so a full-sweep wrap renders as
// `<last>/<first>` (higher-domain break first).
#let group-theta-breaks(breaks, project) = {
  let groups = ()
  let seen = (:)
  for (idx, b) in breaks.enumerate() {
    let theta = project(b)
    if theta == none { continue }
    let r = calc.rem(theta, 2 * calc.pi)
    if r < 0 { r += 2 * calc.pi }
    // 6-digit rounding absorbs float noise from `map-position` round-trips
    // so theta-lo and theta-hi (mathematically 2π apart) collide on key.
    let key = str(calc.round(r, digits: 6))
    let rec = (idx: idx, b: b, theta: theta)
    if key in seen {
      groups.at(seen.at(key)).push(rec)
    } else {
      seen.insert(key, groups.len())
      groups.push((rec,))
    }
  }
  groups
}

// Canvas point at radial position `(theta, r)`. Avoids open-coding the
// `(cx + r * cos(t), cy + r * sin(t))` recipe at every call site.
#let polar-canvas(radial, theta, r) = {
  let (cx, cy) = radial.centre
  (cx + r * calc.cos(theta), cy + r * calc.sin(theta))
}

// Bar-width category span derived from a trained scale. Discrete scales use
// `discrete-slot-width`; continuous scales fall back to the smallest gap
// between sorted unique x values, mirroring `geom-col`'s heuristic.
#let radial-category-span(cat-trained, cat-col, cat-range, data) = {
  if cat-trained.type == "discrete" {
    return discrete-slot-width(cat-trained, cat-range)
  }
  let xs = data
    .map(r => parse-number(r.at(cat-col, default: none)))
    .filter(v => v != none)
  let (d-lo, d-hi) = cat-trained.domain
  if xs.len() < 2 or d-hi == d-lo {
    return (cat-range.at(1) - cat-range.at(0)) / 10
  }
  let sorted = xs.dedup().sorted()
  let panel-gaps = range(sorted.len() - 1).map(i => calc.abs(
    map-axis(cat-trained, sorted.at(i + 1), cat-range)
      - map-axis(cat-trained, sorted.at(i), cat-range),
  ))
  calc.min(..panel-gaps)
}

// Resolve `cat-range` and `value-range` from a radial bundle so callers
// don't repeat the `cat-is-theta` ternary.
#let radial-axis-ranges(radial) = {
  if radial.cat-is-theta {
    (cat-range: radial.theta-range, value-range: radial.r-range)
  } else {
    (cat-range: radial.r-range, value-range: radial.theta-range)
  }
}

// Tangent-cap offset for composite-bar geoms (errorbar, errorbarh).
// Returns `(nx, ny)` perpendicular to the chord `(p-lo, p-hi)` with length
// `half`, or `none` when the chord is degenerate.
#let radial-tangent-cap(p-lo, p-hi, half) = {
  let (sx-lo, sy-lo) = p-lo
  let (sx-hi, sy-hi) = p-hi
  let dx = sx-hi - sx-lo
  let dy = sy-hi - sy-lo
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return none }
  (-dy / len * half, dx / len * half)
}

// Default canvas-unit half-cap for radial composite-bar geoms when the user
// supplied a relative cap width that has no meaningful pixel mapping under
// polar.
#let RADIAL-DEFAULT-CAP-HALF = 0.15

// Samples one polyline takes over `span` radians: one step per five degrees,
// with a floor of eight so even a narrow arc looks round. Every curve drawn at
// a constant radius reads it, so a swept axis is sampled as finely as the
// wedges and whiskers beside it.
#let arc-steps(span) = calc.max(8, int(calc.ceil(
  calc.abs(span) / (calc.pi / 36),
)))

// Polyline samples along an arc at constant radius between `theta-lo` and
// `theta-hi`. Used by composite geoms (boxplot, crossbar) to draw a median
// or whisker line that follows the polar layout.
#let radial-arc(theta-lo, theta-hi, r, radial, n: none) = {
  let (cx, cy) = radial.centre
  let steps = if n != none { n } else { arc-steps(theta-hi - theta-lo) }
  range(steps + 1).map(i => {
    let t = theta-lo + (theta-hi - theta-lo) * i / steps
    (cx + r * calc.cos(t), cy + r * calc.sin(t))
  })
}

// Closed wedge polygon (centre or annulus segment). `theta-lo` and
// `theta-hi` are math-space radians, `r-lo` and `r-hi` are canvas units.
// `n` defaults to one step per ~5° of arc with a floor of eight steps so
// even narrow wedges look round.
#let radial-wedge(theta-lo, theta-hi, r-lo, r-hi, radial, n: none) = {
  let (cx, cy) = radial.centre
  let steps = if n != none { n } else { arc-steps(theta-hi - theta-lo) }
  let pts = ()
  for i in range(steps + 1) {
    let t = theta-lo + (theta-hi - theta-lo) * i / steps
    pts.push((cx + r-hi * calc.cos(t), cy + r-hi * calc.sin(t)))
  }
  if r-lo > 0 {
    for i in range(steps + 1) {
      let t = theta-hi - (theta-hi - theta-lo) * i / steps
      pts.push((cx + r-lo * calc.cos(t), cy + r-lo * calc.sin(t)))
    }
  } else {
    pts.push((cx, cy))
  }
  pts
}
