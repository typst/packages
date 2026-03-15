// violin.typ - Violin plot (distribution shape visualization)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-violin-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-y-ticks, draw-x-category-labels, draw-grid, draw-axis-titles

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
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let violin-plot(
  data,
  width: 350pt,
  height: 250pt,
  title: none,
  show-box: true,
  bandwidth: auto,
  samples: 30,
  show-grid: auto,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-violin-data(data, "violin-plot")
  let t = resolve-theme(theme)

  if show-grid != auto {
    t.insert("show-grid", show-grid)
  }

  let labels = data.labels
  let datasets = data.datasets
  let n = labels.len()

  // ── Helper: sort an array of numbers ──────────────────────────────────
  let sort-arr(arr) = {
    arr.sorted()
  }

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
  let val-range = global-max - global-min
  if val-range == 0 { val-range = 1 }
  let padding = val-range * 0.15
  let y-min = global-min - padding
  let y-max = global-max + padding

  // ── Compute KDE for each dataset ──────────────────────────────────────
  // Returns array of (value, density) pairs, plus the max density.
  let compute-kde(ds) = {
    let nn = ds.len()
    let sd = std-dev(ds)
    // Silverman's rule of thumb
    let bw = if bandwidth != auto { bandwidth } else {
      1.06 * sd * calc.pow(nn, -0.2)
    }
    if bw == 0 { bw = 1.0 }

    let d-min = ds.first()
    let d-max = ds.last()
    // Extend range slightly beyond data for smooth tails
    let ext = (d-max - d-min) * 0.1
    if ext == 0 { ext = 1.0 }
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
    let sorted = sort-arr(ds)
    let kde = compute-kde(sorted)
    kdes.push(kde)
    if kde.max-density > global-max-density {
      global-max-density = kde.max-density
    }
  }
  if global-max-density == 0 { global-max-density = 1.0 }

  // ── Drawing ───────────────────────────────────────────────────────────
  let pad-left = t.axis-padding-left
  let pad-bottom = t.axis-padding-bottom
  let pad-top = t.axis-padding-top
  let pad-right = t.axis-padding-right

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-width = width - pad-left - pad-right
    #let chart-height = height - pad-top - pad-bottom

    #let origin-x = pad-left
    #let origin-y = pad-top + chart-height
    #let y-start = pad-top

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, y-start, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, y-start, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, y-start, 2pt, t, digits: 1)

      // X-axis category labels
      #let spacing = chart-width / n
      #draw-x-category-labels(labels, origin-x, spacing, origin-y + 4pt, t, center-offset: spacing / 2 - 10pt)

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2 - 20pt, origin-y / 2, t)

      // Helper: map data value to y-coordinate
      #let y-range = y-max - y-min
      #if y-range == 0 { y-range = 1 }
      #let map-y(val) = {
        y-start + chart-height - ((val - y-min) / y-range) * chart-height
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
            stroke: 1.2pt + color,
            ..all-pts,
          )
        )

        // Optional inner box-plot
        if show-box {
          let ds-sorted = sort-arr(datasets.at(i))
          let q = quartiles(ds-sorted)
          let box-half-w = max-half-w * 0.15
          let whisker-stroke = 1pt + t.text-color

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
              fill: white.transparentize(40%),
              stroke: whisker-stroke,
            )
          )

          // Median line
          place(left + top,
            line(
              start: (center-x - box-half-w, y-med),
              end: (center-x + box-half-w, y-med),
              stroke: 2pt + t.text-color,
            )
          )
        }
      }
    ]
  ]
}
