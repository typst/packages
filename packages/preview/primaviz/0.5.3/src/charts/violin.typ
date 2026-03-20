// violin.typ - Violin plot (distribution shape visualization)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-ceil
#import "../validate.typ": validate-violin-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-y-ticks, draw-x-category-labels, draw-grid, draw-axis-titles, measure-y-tick-width
#import "../primitives/layout.typ": resolve-size

/// Renders a violin plot showing the full density shape of distributions.
///
/// Each group's data is visualised as a mirrored kernel density estimate (KDE)
/// curve, optionally with a small box-plot (median line + IQR box) inside.
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
/// - stroke-width (length): Stroke width for violin outlines and inner box elements
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
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
  theme: none,
) = context {
  layout(size => {
  validate-violin-data(data, "violin-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)

  let labels = data.labels
  let datasets = data.datasets
  let n = labels.len()

  // ── Helper: compute mean ──────────────────────────────────────────────
  let mean(arr) = {
    let s = 0
    for v in arr { s += v }
    s / arr.len()
  }

  // ── Helper: compute standard deviation ────────────────────────────────
  let std-dev(arr) = {
    let m = mean(arr)
    let ss = 0
    for v in arr { ss += (v - m) * (v - m) }
    let variance = ss / arr.len()
    if variance == 0 { return 1.0 }
    calc.sqrt(variance)
  }

  // ── Helper: compute median of a sorted array ─────────────────────────
  let median-of(sorted) = {
    let len = sorted.len()
    if calc.rem(len, 2) == 1 {
      sorted.at(calc.div-euclid(len, 2))
    } else {
      let mid = calc.div-euclid(len, 2)
      (sorted.at(mid - 1) + sorted.at(mid)) / 2
    }
  }

  // ── Helper: compute quartiles (Q1, median, Q3) of a sorted array ─────
  let quartiles(sorted) = {
    let len = sorted.len()
    let med = median-of(sorted)
    let half = calc.div-euclid(len, 2)
    let lower = sorted.slice(0, half)
    let upper = if calc.rem(len, 2) == 1 { sorted.slice(half + 1) } else { sorted.slice(half) }
    let q1 = if lower.len() > 0 { median-of(lower) } else { med }
    let q3 = if upper.len() > 0 { median-of(upper) } else { med }
    (q1: q1, median: med, q3: q3)
  }

  // ── Global Y range across all datasets ────────────────────────────────
  let global-min = datasets.at(0).at(0)
  let global-max = datasets.at(0).at(0)
  for ds in datasets {
    for v in ds {
      if v < global-min { global-min = v }
      if v > global-max { global-max = v }
    }
  }
  // Extend y-range slightly to contain KDE tails (10% padding)
  let data-span = nonzero(global-max - global-min, fallback: 1.0)
  let y-pad = data-span * 0.1
  let y-min = calc.min(0, global-min - y-pad)
  let y-max = nice-ceil(global-max + y-pad)

  // ── Compute KDE for each dataset ──────────────────────────────────────
  // Returns array of (value, density) pairs, plus the max density.
  let compute-kde(ds) = {
    let nn = ds.len()
    let sd = std-dev(ds)
    // Silverman's rule of thumb
    let bw = nonzero(if bandwidth != auto { bandwidth } else {
      1.06 * sd * calc.pow(nn, -0.2)
    }, fallback: 1.0)

    let d-min = ds.first()
    let d-max = ds.last()
    // Extend range slightly beyond data for smooth tails
    let ext = nonzero((d-max - d-min) * 0.1, fallback: 1.0)
    let lo = d-min - ext
    let hi = d-max + ext
    let step = (hi - lo) / (samples - 1)

    let points = ()
    let max-density = 0.0
    for si in range(samples) {
      let x = lo + si * step
      let density = 0.0
      for v in ds {
        let u = (x - v) / bw
        density += calc.exp(-0.5 * u * u)
      }
      // Normalise: 1/(n*bw*sqrt(2*pi)) * sum(K)
      // We skip the constant factor and normalise to max later for drawing,
      // but keep relative magnitudes correct across groups.
      density = density / (nn * bw)
      if density > max-density { max-density = density }
      points.push((value: x, density: density))
    }
    (points: points, max-density: max-density)
  }

  // Pre-compute KDEs and find global max density for consistent scaling
  let kdes = ()
  let global-max-density = 0.0
  for ds in datasets {
    let sorted = ds.sorted()
    let kde = compute-kde(sorted)
    kdes.push(kde)
    if kde.max-density > global-max-density {
      global-max-density = kde.max-density
    }
  }
  let global-max-density = nonzero(global-max-density, fallback: 1.0)

  // ── Drawing ───────────────────────────────────────────────────────────
  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 40pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y
    #let y-start = pad-top

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, y-start, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, y-start, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, y-start, origin-x, t, digits: 1)

      // X-axis category labels
      #let spacing = chart-width / n
      #draw-x-category-labels(labels, origin-x, spacing, origin-y + t.label-offset, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(y-min, y-max, t, digits: 1)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)

      // Helper: map data value to y-coordinate, clamped to chart bounds
      #let y-range = nonzero(y-max - y-min)
      #let map-y(val) = {
        let raw = y-start + chart-height - ((val - y-min) / y-range) * chart-height
        calc.max(y-start, calc.min(origin-y, raw))
      }

      // Draw each violin
      #for (i, kde) in kdes.enumerate() {
        let center-x = origin-x + i * spacing + spacing / 2
        // Maximum half-width for the violin (fraction of slot)
        let max-half-w = spacing * 0.4
        let color = get-color(t, i)
        let fill-color = color.transparentize(30%)

        let pts = kde.points

        // Build polygon points: right side top-to-bottom, then left side bottom-to-top
        // Right side
        let right-pts = ()
        for p in pts {
          let yy = map-y(p.value)
          let dx = (p.density / global-max-density) * max-half-w
          right-pts.push((center-x + dx, yy))
        }
        // Left side (reversed)
        let left-pts = ()
        for p in pts {
          let yy = map-y(p.value)
          let dx = (p.density / global-max-density) * max-half-w
          left-pts.push((center-x - dx, yy))
        }
        // Reverse left-pts for correct polygon winding
        let left-rev = ()
        let li = left-pts.len()
        for j in range(li) {
          left-rev.push(left-pts.at(li - 1 - j))
        }

        let all-pts = right-pts + left-rev

        // Draw the violin shape as a polygon
        place(left + top,
          polygon(
            fill: fill-color,
            stroke: stroke-width + color,
            ..all-pts,
          )
        )

        // Optional inner box-plot
        if show-box {
          let ds-sorted = datasets.at(i).sorted()
          let q = quartiles(ds-sorted)
          let box-half-w = max-half-w * 0.15
          let whisker-stroke = calc.max(0.5pt, stroke-width - 0.2pt) + t.text-color

          let y-q1 = map-y(q.q1)
          let y-med = map-y(q.median)
          let y-q3 = map-y(q.q3)

          // IQR box
          let box-top-y = y-q3
          let box-h = y-q1 - y-q3
          place(left + top,
            dx: center-x - box-half-w,
            dy: box-top-y,
            rect(
              width: box-half-w * 2,
              height: box-h,
              fill: (if t.background != none { t.background } else { white }).transparentize(40%),
              stroke: whisker-stroke,
            )
          )

          // Median line
          place(left + top,
            line(
              start: (center-x - box-half-w, y-med),
              end: (center-x + box-half-w, y-med),
              stroke: stroke-width * 1.5 + t.text-color,
            )
          )
        }
      }
    ]
  ]
  })
}
