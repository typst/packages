// bar.typ - Bar charts (simple, horizontal, grouped, stacked, grouped-stacked)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, normalize-errors
#import "../validate.typ": validate-simple-data, validate-series-data, validate-grouped-stacked-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis, fit-label-size, value-text
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/polar.typ": separator-stroke
#import "../primitives/layout.typ": resolve-size, pin
#import "../primitives/row-chart.typ": row-chart

// A vertical bar spanning the values v0..v1, `w` wide, centred on `cx`.
#let _vbar(py, cx, w, v0, v1, fill, stroke: none) = {
  let (ya, yb) = (py(v0), py(v1))
  place(left + top, dx: cx - w / 2, dy: calc.min(ya, yb),
    rect(width: w, height: calc.abs(ya - yb), fill: fill, stroke: stroke))
}

// Width of a bar in a group whose bars are `w` apart: the theme's gap between
// bars, but never more than a quarter of the slot, so dense groups keep their bars.
#let _grouped-width(t, w) = w - calc.min(t.bar-gap, w * 0.25)

// A bar (or a group of bars) never grows past ten label heights: with one or
// two categories the slots are huge, and a bar as wide as the plot says nothing.
#let _slot-cap(t, w) = calc.min(w, 10 * t.axis-label-size)

// The value axis of a bar chart: always includes the zero baseline.
// `pad` is the room value labels past negative bar ends need below the axis start.
#let _bar-axis(lo, hi, title, pad: 0pt) = {
  let (lo, hi) = (calc.min(0, lo), calc.max(0, hi))
  value-axis(lo, if lo == hi { 1 } else { hi }, title: title, pad: (lo: if lo < 0 { pad } else { 0pt }))
}

// Signed stacks: positives pile up from zero, negatives down from zero.
// Returns, per stack, the (series index, from, to) segments and the extent.
#let _stack-segments(values-by-series) = {
  let (pos, neg) = (0, 0)
  let segs = ()
  for (si, v) in values-by-series.enumerate() {
    if v >= 0 { segs.push((si, pos, pos + v)); pos += v } else { segs.push((si, neg, neg + v)); neg += v }
  }
  (segs: segs, lo: neg, hi: pos)
}

/// Renders a horizontal bar chart with category labels on the y-axis.
///
/// Every row is labelled: with `height: auto` the chart grows with the number of
/// rows; with a fixed height the labels shrink to the theme's
/// `category-label-min-size` (5pt unless set) and are thinned only below that.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (auto, length): Chart height; `auto` gives every row room for its label
/// - bar-height (float): Bar thickness as fraction of slot (0 to 1)
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels beside bars
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let horizontal-bar-chart(
  data,
  width: auto,
  height: auto,
  bar-height: 0.6,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-simple-data(data, "horizontal-bar-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  row-chart(norm.labels, norm.values, width, height, size, t,
    title: title, x-label: x-label, y-label: y-label, annotations: annotations,
    extra-legend-separation: extra-legend-separation, show-values: show-values,
    (i, y, x-from, x-to, color, row-h) => {
      let bh = _slot-cap(t, row-h * bar-height)
      place(left + top, dx: calc.min(x-from, x-to), dy: y - bh / 2,
        rect(width: calc.abs(x-to - x-from), height: bh, fill: color))
    },
  )
  })
}

/// Renders a vertical bar chart with one bar per category.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - bar-width (float): Bar width as fraction of slot (0 to 1)
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels above bars
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - errors (none, array): Symmetric `(e1, e2, ...)` or asymmetric `((lo1, hi1), ...)`
/// - error-color (auto, color): Error bar color; `auto` uses the theme text color
/// - error-cap-width (auto, length): Width of the error bar caps; `auto` scales with bar width
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter minor grid lines between the major ones
/// - subtitle (none, content): Optional subtitle below the title
/// - radius (length): Corner radius of the chart container
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let bar-chart(
  data,
  width: auto,
  height: auto,
  bar-width: 0.6,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  errors: none,
  error-color: auto,
  error-cap-width: auto,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  subtitle: none,
  radius: 0pt,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-simple-data(data, "bar-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t)
  let errs = normalize-errors(errors, n)
  let strs = values.map(v => value-text(v, t))

  // The axis covers the error bars too
  let lo = calc.min(..values.enumerate().map(((i, v)) => v - if errs != none { errs.at(i).low } else { 0 }))
  let hi = calc.max(..values.enumerate().map(((i, v)) => v + if errs != none { errs.at(i).high } else { 0 }))

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: _bar-axis(lo, hi, y-label, pad: if show-values { 1.2 * t.value-label-size + t.label-offset } else { 0pt }),
    baseline: (y: 0), annotations: annotations,
    title: title, subtitle: subtitle, radius: radius,
    show-ticks: show-ticks, show-minor-grid: show-minor-grid,
    extra-legend-separation: extra-legend-separation,
    reserve: (top: if show-values { t.value-label-size + t.label-offset } else { 0pt }),
    p => {
      let (px, py) = (p.px, p.py)
      let bw = _slot-cap(t, p.X.pitch * bar-width)
      let vsize = fit-label-size(strs, p.X.pitch, t.value-label-size)
      let err-stroke = t.stroke-thin + if error-color != auto { error-color } else { t.text-color }
      for (i, val) in values.enumerate() {
        let cx = px(i)
        _vbar(py, cx, bw, 0, val, get-color(t, i))

        // Error bar: a vertical rule with a cap at each end
        if errs != none {
          let (y-low, y-high) = (py(val - errs.at(i).low), py(val + errs.at(i).high))
          let cap-w = if error-cap-width != auto { error-cap-width } else { bw * 0.4 }
          place(left + top, line(start: (cx, y-low), end: (cx, y-high), stroke: err-stroke))
          for y in (y-low, y-high) {
            place(left + top, line(start: (cx - cap-w / 2, y), end: (cx + cap-w / 2, y), stroke: err-stroke))
          }
        }

        // Value label sits just beyond the bar end (and its error bar)
        if show-values and vsize != none {
          let above = val >= 0
          let reach = if errs != none { if above { errs.at(i).high } else { errs.at(i).low } } else { 0 }
          let end = py(val + if above { reach } else { -reach })
          place(left + top, dx: cx - p.X.pitch / 2, dy: end + if above { -t.label-offset } else { t.label-offset },
            pin(width: p.X.pitch, align: center + if above { bottom } else { top },
              text(size: vsize, fill: t.text-color)[#strs.at(i)]))
        }
      }
    },
  )
  })
}

/// Renders a grouped bar chart with multiple series side by side.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let grouped-bar-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-legend: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "grouped-bar-chart")
  let t = _resolve-ctx(theme)
  let (labels, series) = (data.labels, data.series)
  let n-series = series.len()
  // Auto-width uses n_groups × n_series since each series gets its own bar column
  let (width, height) = resolve-size(width, height, size, n: labels.len() * n-series, theme: t)
  let all-values = series.map(s => s.values).flatten()

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: _bar-axis(calc.min(..all-values), calc.max(..all-values), y-label),
    baseline: (y: 0), annotations: annotations,
    title: title, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, fit-width: true, max-width: legend-max-width(width, t)),
    p => {
      let (px, py) = (p.px, p.py)
      // The bars of a group share 80% of its slot, centred on it
      let bw = _slot-cap(t, p.X.pitch * 0.8) / n-series
      for gi in range(labels.len()) {
        for (si, s) in series.enumerate() {
          let cx = px(gi) + (si - (n-series - 1) / 2) * bw
          _vbar(py, cx, _grouped-width(t, bw), 0, s.values.at(gi), get-color(t, si))
        }
      }
    },
  )
  })
}

/// Renders a stacked bar chart with series values stacked vertically.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let stacked-bar-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-legend: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "stacked-bar-chart")
  let t = _resolve-ctx(theme)
  let (labels, series) = (data.labels, data.series)
  let (width, height) = resolve-size(width, height, size, n: labels.len(), theme: t)
  let stacks = range(labels.len()).map(i => _stack-segments(series.map(s => s.values.at(i))))

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: _bar-axis(calc.min(..stacks.map(s => s.lo)), calc.max(..stacks.map(s => s.hi)), y-label),
    baseline: (y: 0), annotations: annotations,
    title: title, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, fit-width: true, max-width: legend-max-width(width, t)),
    p => {
      let (px, py) = (p.px, p.py)
      for (i, stack) in stacks.enumerate() {
        for (si, from, to) in stack.segs {
          _vbar(py, px(i), _slot-cap(t, p.X.pitch * 0.6), from, to, get-color(t, si), stroke: separator-stroke(t, thickness: t.stroke-thin))
        }
      }
    },
  )
  })
}

/// Renders a grouped-stacked bar chart combining side-by-side groups with
/// stacked segments within each group.
///
/// - data (dictionary): Dict with `labels` (x-axis categories) and `groups`
///   (array of dicts each with `name` and `segments`, where each segment has
///   `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show segment legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let grouped-stacked-bar-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-legend: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-grouped-stacked-data(data, "grouped-stacked-bar-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, groups) = (data.labels, data.groups)
  let n-groups = groups.len()

  // Guard: nothing to draw
  if labels.len() == 0 or n-groups == 0 { return }

  // Unique segment names (first-seen order) give the legend and the colors
  let segment-names = ()
  for g in groups {
    for seg in g.segments {
      if seg.name not in segment-names { segment-names.push(seg.name) }
    }
  }

  // One signed stack per (label, group); names may be content, so look colors up by position
  let stacks = range(labels.len()).map(li => groups.map(g => {
    let st = _stack-segments(g.segments.map(seg => seg.values.at(li)))
    (..st, segs: st.segs.zip(g.segments).map(((s, seg)) => (segment-names.position(nm => nm == seg.name), s.at(1), s.at(2))))
  }))
  let all = stacks.flatten()

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: _bar-axis(calc.min(..all.map(s => s.lo)), calc.max(..all.map(s => s.hi)), y-label),
    baseline: (y: 0), annotations: annotations,
    title: title, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(segment-names, t, show-legend: show-legend, fit-width: true, max-width: legend-max-width(width, t)),
    p => {
      let (px, py) = (p.px, p.py)
      // The groups of a label share 85% of its slot, centred on it
      let gw = _slot-cap(t, p.X.pitch * 0.85) / n-groups
      for (li, row) in stacks.enumerate() {
        for (gi, stack) in row.enumerate() {
          for (ci, from, to) in stack.segs {
            _vbar(py, px(li) + (gi - (n-groups - 1) / 2) * gw, _grouped-width(t, gw), from, to, get-color(t, ci),
              stroke: separator-stroke(t, thickness: t.stroke-thin))
          }
        }
      }
    },
  )
  })
}
