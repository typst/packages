// violin.typ - Violin plot (distribution shape visualization)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-violin-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis
#import "../primitives/layout.typ": resolve-size

/// Renders a violin plot showing the full density shape of distributions.
///
/// Each group's data is visualised as a mirrored kernel density estimate (KDE)
/// curve, optionally with a small box-plot (median dot + IQR bar) inside. The
/// value axis covers the curves, nothing more.
///
/// - data (dictionary): Dict with `labels` (array of str) and `datasets`
///   (array of arrays of numbers). Each dataset is the raw observations for
///   the corresponding label.
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-box (bool): Draw a small box-plot (median + IQR) inside each violin
/// - bandwidth (auto, float): KDE bandwidth; `auto` uses Silverman's rule
/// - samples (int): Number of evaluation points along the density curve
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - stroke-width (length): Stroke width for violin outlines and the median/IQR marks
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let violin-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  show-box: true,
  bandwidth: auto,
  samples: 30,
  show-grid: auto,
  stroke-width: 1.2pt,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-violin-data(data, "violin-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, datasets) = (data.labels, data.datasets)

  let mean(arr) = arr.sum() / arr.len()
  let std-dev(arr) = {
    let m = mean(arr)
    let variance = arr.map(v => (v - m) * (v - m)).sum() / arr.len()
    if variance == 0 { 1.0 } else { calc.sqrt(variance) }
  }

  // Median of a sorted array
  let median-of(sorted) = {
    let len = sorted.len()
    let mid = calc.div-euclid(len, 2)
    if calc.rem(len, 2) == 1 { sorted.at(mid) } else { (sorted.at(mid - 1) + sorted.at(mid)) / 2 }
  }

  // Quartiles (Q1, median, Q3) of a sorted array
  let quartiles(sorted) = {
    let len = sorted.len()
    let med = median-of(sorted)
    let half = calc.div-euclid(len, 2)
    let lower = sorted.slice(0, half)
    let upper = if calc.rem(len, 2) == 1 { sorted.slice(half + 1) } else { sorted.slice(half) }
    (q1: if lower.len() > 0 { median-of(lower) } else { med },
     median: med,
     q3: if upper.len() > 0 { median-of(upper) } else { med })
  }

  // KDE of a sorted dataset: `(lo, hi)` extent and `(value, density)` samples.
  // The curve runs 10% of the data range past the extremes, so its tails close,
  // but not below zero when every observation is non-negative (no -20 on a score axis).
  let compute-kde(ds) = {
    let nn = ds.len()
    // Silverman's rule of thumb
    let bw = nonzero(if bandwidth != auto { bandwidth } else { 1.06 * std-dev(ds) * calc.pow(nn, -0.2) }, fallback: 1.0)
    // (identical observations have no range: the tails get three bandwidths to close)
    let ext = nonzero((ds.last() - ds.first()) * 0.1, fallback: 3 * bw)
    let (lo, hi) = (ds.first() - ext, ds.last() + ext)
    if ds.first() >= 0 { lo = calc.max(lo, 0) }
    let step = (hi - lo) / (samples - 1)
    // Density, up to the constant 1/sqrt(2 pi): relative magnitudes stay right across groups
    let points = range(samples).map(si => {
      let x = lo + si * step
      (value: x, density: ds.map(v => calc.exp(-0.5 * calc.pow((x - v) / bw, 2))).sum() / (nn * bw))
    })
    (lo: lo, hi: hi, points: points, max-density: calc.max(..points.map(p => p.density)))
  }
  let kdes = datasets.map(ds => compute-kde(ds.sorted()))
  let global-max-density = nonzero(calc.max(..kdes.map(k => k.max-density)), fallback: 1.0)

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: value-axis(calc.min(..kdes.map(k => k.lo)), calc.max(..kdes.map(k => k.hi)), title: y-label),
    title: title, annotations: annotations,
    p => {
      let (px, py) = (p.px, p.py)
      // Widest half of a violin: 40% of its slot
      let max-half-w = p.X.pitch * 0.4
      for (i, kde) in kdes.enumerate() {
        let cx = px(i)
        let color = get-color(t, i)
        let half(d) = d / global-max-density * max-half-w

        // Right side top-to-bottom, then the left side back up
        let right-pts = kde.points.map(pt => (cx + half(pt.density), py(pt.value)))
        let left-pts = kde.points.map(pt => (cx - half(pt.density), py(pt.value))).rev()
        place(left + top, polygon(fill: color.transparentize(30%), stroke: stroke-width + color, ..right-pts, ..left-pts))

        // Inner box plot: an IQR bar with the median as a dot, in theme colours
        if show-box {
          let q = quartiles(datasets.at(i).sorted())
          let bar-w = calc.min(2pt, max-half-w * 0.2)
          let (y-q1, y-med, y-q3) = (py(q.q1), py(q.median), py(q.q3))
          place(left + top, dx: cx - bar-w / 2, dy: y-q3,
            rect(width: bar-w, height: y-q1 - y-q3, fill: t.text-color, stroke: none))
          place(left + top, dx: cx - bar-w * 1.1, dy: y-med - bar-w * 1.1,
            circle(radius: bar-w * 1.1, fill: if t.background != none { t.background } else { white }, stroke: none))
        }
      }
    },
  )
  })
}
