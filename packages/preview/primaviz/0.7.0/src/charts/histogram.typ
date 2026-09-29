// histogram.typ - Histogram chart (frequency distribution of numeric data)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-ticks
#import "../validate.typ": validate-histogram-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-y-ticks, draw-x-ticks, draw-axis-titles, measure-y-tick-width, measure-x-tick-height
#import "../primitives/annotations.typ": draw-annotations
#import "../primitives/layout.typ": resolve-size

/// Renders a histogram showing the frequency distribution of numeric data.
///
/// - values (array): Array of numeric data values to bin
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - bins (auto, int): Number of bins; `auto` uses Sturges' rule
/// - min-val (auto, int, float): Minimum bin edge; `auto` uses data minimum
/// - max-val (auto, int, float): Maximum bin edge; `auto` uses data maximum
/// - show-values (bool): Display count labels above bars
/// - color (none, color): Override bar color
/// - density (bool): Normalize to probability density instead of counts
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let histogram(
  values,
  width: auto,
  height: auto,
  title: none,
  bins: auto,
  min-val: auto,
  max-val: auto,
  show-values: false,
  color: none,
  density: false,
  x-label: none,
  y-label: none,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  theme: none,
) = context {
  layout(size => {
  validate-histogram-data(values, "histogram")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)

  let n = values.len()

  // Compute min/max from data if auto
  let data-min = if min-val == auto { calc.min(..values) } else { min-val }
  let data-max = if max-val == auto { calc.max(..values) } else { max-val }

  // Handle edge case: all values identical
  if data-min == data-max {
    data-max = data-min + 1
  }

  // Compute number of bins via Sturges' rule if auto
  let num-bins = if bins == auto {
    calc.ceil(calc.log(n, base: 2) + 1)
  } else {
    bins
  }

  let bin-width = (data-max - data-min) / num-bins

  // Compute bin edges
  let edges = array.range(num-bins + 1).map(i => data-min + i * bin-width)

  // Count values per bin using accumulator pattern
  let counts = array.range(num-bins).map(bi => {
    let lo = edges.at(bi)
    let hi = edges.at(bi + 1)
    let is-last = bi == num-bins - 1
    values.filter(v => {
      if is-last {
        v >= lo and v <= hi
      } else {
        v >= lo and v < hi
      }
    }).len()
  })

  // If density mode, divide by (total * bin_width)
  let y-values = if density {
    let total = n
    counts.map(c => c / (total * bin-width))
  } else {
    counts.map(c => float(c))
  }

  let ynt = nice-ticks(0, nonzero(calc.max(..y-values)), count: t.tick-count)
  let y-max = ynt.max

  // Render
  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t, show-minor-grid: show-minor-grid, num-ticks: ynt.ticks.len())

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t, show-ticks: show-ticks)

      // Draw bars (no gaps — contiguous)
      #let bar-w = chart-width / num-bins
      #for bi in array.range(num-bins) {
        let val = y-values.at(bi)
        let bar-h = (val / y-max) * chart-height
        let x-pos = origin-x + bi * bar-w
        let y-pos = pad-top + chart-height - bar-h

        let fill-color = if color != none { color } else { get-color(t, 0) }

        place(
          left + top,
          dx: x-pos,
          dy: y-pos,
          rect(
            width: bar-w,
            height: bar-h,
            fill: fill-color,
            stroke: t.marker-stroke,
          )
        )

        if show-values and val > 0 {
          let count-val = counts.at(bi)
          place(
            left + top,
            dx: x-pos,
            dy: y-pos - 1.2em,
            box(width: bar-w,
              align(center, text(size: t.value-label-size, fill: t.text-color)[#count-val]))
          )
        }
      }

      // Y-axis ticks
      #draw-y-ticks(0, y-max, chart-height, pad-top, origin-x, t)

      // X-axis ticks (numeric)
      #draw-x-ticks(data-min, data-max, chart-width, origin-x, origin-y + t.label-offset, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(0, y-max, t)
      #let x-th = measure-x-tick-height(([#data-max],), t)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw, x-tick-height: x-th)

      // Annotations — x is data value [data-min, data-max], y is frequency [0, y-max]
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, data-min, data-max, 0, y-max, t)
    ]
  ]
  })
}
