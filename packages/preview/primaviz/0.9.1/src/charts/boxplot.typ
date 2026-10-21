// boxplot.typ - Box-and-whisker plot
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-ticks
#import "../primitives/annotations.typ": draw-annotations
#import "../validate.typ": validate-boxplot-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-y-ticks, draw-x-category-labels, draw-grid, draw-axis-titles, measure-y-tick-width, measure-x-tick-height
#import "../primitives/layout.typ": resolve-size

/// Renders a box-and-whisker plot for comparing distributions.
///
/// - data (dictionary): Dict with `labels` and `boxes` (each with `min`, `q1`, `median`, `q3`, `max`,
///   and optional `outliers` array of values outside the whiskers)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - box-width (float): Box width as fraction of slot (0 to 1)
/// - show-values (bool): Display five-number summary labels beside each box
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - stroke-width (length): Stroke width for box outlines and whiskers
/// - outlier-radius (length): Radius of outlier marker dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors (see annotations.typ)
/// - theme (none, dictionary): Theme overrides
/// -> content
#let box-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  box-width: 0.5,
  show-values: false,
  show-grid: auto,
  stroke-width: 1pt,
  outlier-radius: 2pt,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-boxplot-data(data, "box-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)

  let labels = data.labels
  let boxes = data.boxes
  let n = labels.len()

  // Find global min/max across all boxes for Y-axis scaling
  // Include outliers so they fit within the chart area
  let global-min = boxes.at(0).min
  let global-max = boxes.at(0).max
  for b in boxes {
    if b.min < global-min { global-min = b.min }
    if b.max > global-max { global-max = b.max }
    if "outliers" in b {
      for o in b.outliers {
        if o < global-min { global-min = o }
        if o > global-max { global-max = o }
      }
    }
  }
  let nt = nice-ticks(calc.min(0, global-min), global-max, count: t.tick-count)
  let y-min = nt.min
  let y-max = nt.max

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y
    #let y-start = pad-top

    #box(width: width, height: height)[
      // Grid lines behind everything
      #draw-grid(origin-x, y-start, chart-width, chart-height, t, num-ticks: nt.ticks.len())

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, y-start, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, y-start, origin-x, t)

      // X-axis category labels
      #let spacing = chart-width / n
      #draw-x-category-labels(labels, origin-x, spacing, origin-y + t.label-offset, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(y-min, y-max, t)
      #let x-th = measure-x-tick-height(labels, t, rotated: n > t.rotated-threshold)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw, x-tick-height: x-th)

      // Draw each box
      #for (i, b) in boxes.enumerate() {
        let center-x = origin-x + i * spacing + spacing / 2
        let actual-box-w = spacing * box-width
        let half-box = actual-box-w / 2
        let cap-w = actual-box-w * 0.5
        let half-cap = cap-w / 2

        let color = get-color(t, i)
        let fill-color = color.transparentize(20%)
        let whisker-stroke = stroke-width + t.text-color
        let median-stroke = stroke-width * 2 + t.text-color-inverse

        // Helper: map a data value to y-coordinate
        // y = y-start + chart-height - ((val - y-min) / (y-max - y-min)) * chart-height
        let y-range = nonzero(y-max - y-min)
        let map-y(val) = {
          y-start + chart-height - ((val - y-min) / y-range) * chart-height
        }

        let y-min-pos = map-y(b.min)
        let y-q1-pos = map-y(b.q1)
        let y-median-pos = map-y(b.median)
        let y-q3-pos = map-y(b.q3)
        let y-max-pos = map-y(b.max)

        // Lower whisker: vertical line from min to q1
        place(left + top,
          line(start: (center-x, y-min-pos), end: (center-x, y-q1-pos), stroke: whisker-stroke)
        )

        // Upper whisker: vertical line from q3 to max
        place(left + top,
          line(start: (center-x, y-q3-pos), end: (center-x, y-max-pos), stroke: whisker-stroke)
        )

        // Cap at min
        place(left + top,
          line(start: (center-x - half-cap, y-min-pos), end: (center-x + half-cap, y-min-pos), stroke: whisker-stroke)
        )

        // Cap at max
        place(left + top,
          line(start: (center-x - half-cap, y-max-pos), end: (center-x + half-cap, y-max-pos), stroke: whisker-stroke)
        )

        // Box: filled rectangle from q1 to q3
        let box-top = y-q3-pos
        let box-height = y-q1-pos - y-q3-pos
        place(left + top,
          dx: center-x - half-box,
          dy: box-top,
          rect(
            width: actual-box-w,
            height: box-height,
            fill: fill-color,
            stroke: stroke-width + color,
          )
        )

        // Median line across the box
        place(left + top,
          line(
            start: (center-x - half-box, y-median-pos),
            end: (center-x + half-box, y-median-pos),
            stroke: median-stroke,
          )
        )

        // Outliers: dots at values outside the whiskers
        if "outliers" in b {
          for o in b.outliers {
            let y-pos = map-y(o)
            place(left + top,
              dx: center-x - outlier-radius,
              dy: y-pos - outlier-radius,
              circle(radius: outlier-radius, fill: color, stroke: none)
            )
          }
        }

        // Optional value labels
        if show-values {
          let label-dx = center-x + half-box + 3pt
          for (val, y-pos) in ((b.max, y-max-pos), (b.q3, y-q3-pos), (b.median, y-median-pos), (b.q1, y-q1-pos), (b.min, y-min-pos)) {
            place(left + top, dx: label-dx, dy: y-pos - 5pt,
              text(size: t.value-label-size, fill: t.text-color)[#val]
            )
          }
        }
      }

      // Annotations — x-axis is category index [-0.5, n-0.5]
      #draw-annotations(annotations, origin-x, y-start, chart-width, chart-height, -0.5, n - 0.5, y-min, y-max, t)
    ]
  ]
  })
}
