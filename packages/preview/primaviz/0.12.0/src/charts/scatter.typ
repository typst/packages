// scatter.typ - Scatter plot and bubble chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, label-len
#import "../primitives/layout.typ": try-fit-label, resolve-size
#import "../validate.typ": validate-scatter-data, validate-multi-scatter-data, validate-bubble-data, validate-multi-bubble-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis
#import "../primitives/legend.typ": draw-legend-auto, draw-size-legend, legend-max-width

// Both axes of an x-y chart. Small marks keep `inset` free at the ends of each
// axis, so a mark centred on an extreme value stays inside the plot. With `radii`
// (one per point: bubbles) the axes instead widen to the next nice tick until every
// bubble lies inside the plot, so the axis line, the ticks and the plot agree.
#let _xy-axes(points, inset, x-label, y-label, radii: none) = {
  let xs = points.map(p => p.at(0))
  let ys = points.map(p => p.at(1))
  let marks(i) = if radii == none { () } else { points.zip(radii).map(((pt, r)) => (pt.at(i), r)) }
  let inset = if radii == none { inset } else { 0pt }
  (
    x: value-axis(calc.min(..xs), calc.max(..xs), title: x-label, inset: inset, marks: marks(0)),
    y: value-axis(calc.min(..ys), calc.max(..ys), title: y-label, inset: inset, marks: marks(1)),
  )
}

// Resolves the theme with the chart's own `show-grid` override applied.
#let _scatter-theme(theme, show-grid) = _resolve-ctx(theme, overrides: if show-grid != auto { (show-grid: show-grid) } else { none })

// Radius bubbles are drawn at: the largest bubble never takes over the plot (its
// diameter stays under about 36% of the plot height, `height` less the room the
// axes take, and 24% of the width).
#let _bubble-radii(max-radius, min-radius, width, height, t) = {
  let hi = calc.min(max-radius, (height - 6 * t.axis-label-size) * 0.18, width * 0.12)
  (hi: hi, lo: calc.min(min-radius, hi * 0.5))
}

// Whether two `(x, y, w, h)` boxes overlap.
#let _hit(a, b) = a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h

// Spot for a label of `w` x `h` beside bubble `b`: the nearest of eight directions,
// tried at three distances, that stays in `bounds`, clear of the `taken` label boxes
// and clear of the other bubbles (`all`). When none is clear, the least bad one.
#let _label-spot(b, all, taken, bounds, w, h) = {
  let gap = 2pt
  let spots = ()
  for (k, off) in (0pt, h * 1.1, h * 2.2).enumerate() {
    let d = b.radius + gap + off
    let e = d * 0.71
    for (i, (x, y)) in (
      (b.px + d, b.py - h / 2), (b.px - d - w, b.py - h / 2),
      (b.px - w / 2, b.py + d), (b.px - w / 2, b.py - d - h),
      (b.px + e, b.py + e), (b.px - e - w, b.py + e),
      (b.px + e, b.py - e - h), (b.px - e - w, b.py - e - h),
    ).enumerate() {
      let box = (x: x, y: y, w: w, h: h)
      let cost = k * 50 + i
      if x < bounds.left or y < bounds.top or x + w > bounds.right or y + h > bounds.bottom { cost += 3000 }
      cost += 10000 * taken.filter(o => _hit(o, box)).len()
      for o in all {
        if o.i == b.i { continue }
        let (nx, ny) = (calc.min(calc.max(o.px, x), x + w), calc.min(calc.max(o.py, y), y + h))
        if ((nx - o.px) / 1pt) * ((nx - o.px) / 1pt) + ((ny - o.py) / 1pt) * ((ny - o.py) / 1pt) < (o.radius / 1pt) * (o.radius / 1pt) {
          cost += 1000
        }
      }
      spots.push((cost: cost, box: box))
    }
  }
  spots.sorted(key: s => s.cost).first().box
}

// Radius of the bubble for `size`: linear in size between the smallest and largest.
#let _bubble-radius(size, size-min, size-range, r) = r.lo + ((size - size-min) / size-range) * (r.hi - r.lo)

// Size legend below a bubble chart: three reference circles.
#let _bubble-size-legend(size-label, size-max, max-radius, t) = if size-label != none {
  let ref-sizes = (
    (size-max, str(calc.round(size-max))),
    (calc.round(size-max * 0.5), str(calc.round(size-max * 0.5))),
    (calc.round(size-max * 0.15), str(calc.round(size-max * 0.15))),
  )
  draw-size-legend(ref-sizes, max-radius, size-max, t, title: size-label)
}

/// Renders a scatter plot of x-y data points.
///
/// - data (array, dictionary): Array of `(x, y)` tuples or dict with `x` and `y` arrays
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - point-size (length): Diameter of point markers
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - color (none, color): Override point color
/// - annotations (none, array): Optional annotation descriptors
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter minor grid lines between the major ones
/// - subtitle (none, content): Optional subtitle below the title
/// - radius (length): Corner radius of the chart container
/// - theme (none, dictionary): Theme overrides
/// -> content
#let scatter-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: auto,
  color: none,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  subtitle: none,
  radius: 0pt,
  theme: none,
) = context {
  layout(size => {
  validate-scatter-data(data, "scatter-plot")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let points = if type(data) == dictionary { data.x.zip(data.y) } else { data }
  let point-color = if color != none { color } else { get-color(t, 0) }
  let axes = _xy-axes(points, point-size / 2 + 1pt, x-label, y-label)

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, subtitle: subtitle, radius: radius, annotations: annotations,
    show-ticks: show-ticks, show-minor-grid: show-minor-grid,
    p => {
      for pt in points {
        place(left + top, dx: (p.px)(pt.at(0)) - point-size / 2, dy: (p.py)(pt.at(1)) - point-size / 2,
          circle(radius: point-size / 2, fill: point-color, stroke: t.marker-stroke))
      }
    },
  )
  })
}

/// Renders a multi-series scatter plot with color-coded point groups.
///
/// - data (dictionary): Dict with `series` array, each containing `name` and `points` (array of `(x, y)`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - point-size (length): Diameter of point markers
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - show-legend (bool): Show series legend
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let multi-scatter-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: auto,
  show-legend: true,
  annotations: none,
  extra-legend-separation: 0pt,
  theme: none,
) = context {
  layout(size => {
  validate-multi-scatter-data(data, "multi-scatter-plot")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let series = data.series
  let axes = _xy-axes(series.map(s => s.points).join(), point-size / 2 + 1pt, x-label, y-label)

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, annotations: annotations, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle", fit-width: true, max-width: legend-max-width(width, t)),
    p => {
      for (si, s) in series.enumerate() {
        for pt in s.points {
          place(left + top, dx: (p.px)(pt.at(0)) - point-size / 2, dy: (p.py)(pt.at(1)) - point-size / 2,
            circle(radius: point-size / 2, fill: get-color(t, si), stroke: t.marker-stroke))
        }
      }
    },
  )
  })
}

/// Renders a bubble chart where each point has an x, y, and size dimension.
///
/// - data (array, dictionary): Array of `(x, y, size)` tuples or dict with `x`, `y`, `size` arrays
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - min-radius (length): Minimum bubble radius
/// - max-radius (length): Maximum bubble radius
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - color (none, color): Override bubble color
/// - show-labels (bool): Display text labels on bubbles
/// - labels (none, array): Array of label strings for each bubble
/// - size-label (none, content): Title for the bubble size legend; `none` hides the legend
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bubble-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  size-label: none,
  min-radius: 5pt,
  max-radius: 30pt,
  show-grid: auto,
  color: none,
  show-labels: false,
  labels: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-bubble-data(data, "bubble-chart")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let points = if type(data) == dictionary {
    data.x.zip(data.y).zip(data.size).map(p => (p.at(0).at(0), p.at(0).at(1), p.at(1)))
  } else { data }
  let sizes = points.map(p => p.at(2))
  let (size-min, size-max) = (calc.min(..sizes), calc.max(..sizes))
  let size-range = nonzero(size-max - size-min)
  let bubble-color = if color != none { color } else { get-color(t, 0) }
  let r = _bubble-radii(max-radius, min-radius, width, height, t)
  let axes = _xy-axes(points, 0pt, x-label, y-label,
    radii: sizes.map(s => _bubble-radius(s, size-min, size-range, r) + 1pt))

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, annotations: annotations,
    legend: _bubble-size-legend(size-label, size-max, max-radius, t),
    p => {
      let (px, py) = (p.px, p.py)
      let bounds = (left: p.x0, right: p.x1, top: p.y0, bottom: p.y1)
      let computed = points.enumerate().map(((i, pt)) => (
        i: i, px: px(pt.at(0)), py: py(pt.at(1)),
        radius: _bubble-radius(pt.at(2), size-min, size-range, r),
      ))

      for b in computed {
        place(left + top, dx: b.px - b.radius, dy: b.py - b.radius,
          circle(radius: b.radius, fill: bubble-color.transparentize(40%), stroke: bubble-color + 1.5pt))
      }

      // Labels: inside the bubble when they fit, otherwise beside it (with a leader
      // line when it had to move away). Beside labels pick the nearest spot that
      // clears every other label and every other bubble.
      if show-labels and labels != none {
        let lbl-size = t.axis-label-size
        let lbl-h = lbl-size * 1.4
        let (inside, outside) = ((), ())
        let taken = ()  // boxes of the labels placed so far
        let order = computed.sorted(key: b => -b.radius)  // biggest bubbles first
        for b in order {
          if b.i >= labels.len() { continue }
          let lbl = labels.at(b.i)
          let lbl-w = measure(text(size: lbl-size, weight: "bold")[#lbl]).width
          // (not below 80% of the axis label size: smaller text goes beside the bubble instead)
          let fit = try-fit-label(b.radius * 2, b.radius * 2, lbl-size, label-len(lbl), shrink-min: lbl-size * 0.8)
          let in-w = measure(text(size: fit.size, weight: "bold")[#lbl]).width
          let box-in = (x: b.px - in-w / 2 - 1pt, y: b.py - fit.size * 0.7, w: in-w + 2pt, h: fit.size * 1.4)
          // Fits its bubble and does not run into the label of a neighbouring bubble
          // (the text box has to sit inside the outline, not on it)
          let half = (in-w / 2 / 1pt, fit.size * 0.5 / 1pt)
          let inside-ok = fit.fits and calc.sqrt(half.at(0) * half.at(0) + half.at(1) * half.at(1)) * 1pt <= b.radius - 0.75pt
          if inside-ok and not taken.any(o => _hit(o, box-in)) {
            inside.push((px: b.px, py: b.py, lbl: lbl, size: fit.size, w: in-w))
            taken.push(box-in)
          } else {
            let box = _label-spot(b, order, taken, bounds, lbl-w + 2pt, lbl-h)
            taken.push(box)
            outside.push((cx: b.px, cy: b.py, radius: b.radius, box: box, lbl: lbl))
          }
        }

        for il in inside {
          place(left + top, dx: il.px - il.w / 2 - 1pt, dy: il.py - il.size * 0.7,
            box(width: il.w + 2pt, height: il.size * 1.4,
              align(center + horizon, text(size: il.size, fill: t.text-color, weight: "bold")[#il.lbl])))
        }
        for ol in outside {
          let bx = ol.box
          // Leader from the bubble edge to the label, when the label stands off the bubble
          let near = (calc.min(calc.max(ol.cx, bx.x), bx.x + bx.w), calc.min(calc.max(ol.cy, bx.y), bx.y + bx.h))
          let (dx, dy) = ((near.at(0) - ol.cx) / 1pt, (near.at(1) - ol.cy) / 1pt)
          let dist = calc.max(1.0, calc.sqrt(dx * dx + dy * dy))
          if dist * 1pt - ol.radius > 3.5pt {
            place(left + top, line(
              start: (ol.cx + dx / dist * ol.radius, ol.cy + dy / dist * ol.radius), end: near,
              stroke: 0.5pt + t.text-color-light))
          }
          place(left + top, dx: bx.x, dy: bx.y,
            box(width: bx.w, height: bx.h, align(center + horizon, text(size: lbl-size, fill: t.text-color, weight: "bold")[#ol.lbl])))
        }
      }
    },
  )
  })
}

/// Renders a multi-series bubble chart with color-coded point groups and
/// per-point size dimension.
///
/// - data (dictionary): Dict with `series` array, each containing `name` and
///   `points` (array of `(x, y, size)` tuples)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - min-radius (length): Minimum bubble radius
/// - max-radius (length): Maximum bubble radius
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - show-legend (bool): Show series legend
/// - size-label (none, content): Title for the bubble size legend; `none` hides the legend
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let multi-bubble-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  size-label: none,
  min-radius: 4pt,
  max-radius: 25pt,
  show-grid: auto,
  show-legend: true,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-multi-bubble-data(data, "multi-bubble-chart")
  let t = _scatter-theme(theme, show-grid)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
  let series = data.series
  let points = series.map(s => s.points).join()
  let sizes = points.map(p => p.at(2))
  let (size-min, size-max) = (calc.min(..sizes), calc.max(..sizes))
  let size-range = nonzero(size-max - size-min)
  let r = _bubble-radii(max-radius, min-radius, width, height, t)
  let axes = _xy-axes(points, 0pt, x-label, y-label,
    radii: sizes.map(s => _bubble-radius(s, size-min, size-range, r) + 1pt))
  let series-legend = draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle", fit-width: true, max-width: legend-max-width(width, t))

  cartesian-frame(width, height, t, x: axes.x, y: axes.y,
    title: title, annotations: annotations,
    legend: { series-legend; _bubble-size-legend(size-label, size-max, max-radius, t) },
    p => {
      for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        for pt in s.points {
          let rad = _bubble-radius(pt.at(2), size-min, size-range, r)
          place(left + top, dx: (p.px)(pt.at(0)) - rad, dy: (p.py)(pt.at(1)) - rad,
            circle(radius: rad, fill: color.transparentize(40%), stroke: color + 1.5pt))
        }
      }
    },
  )
  })
}
