// histogram.typ - Histogram chart (frequency distribution of numeric data)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-histogram-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-grid, draw-y-ticks, draw-x-ticks, draw-axis-titles

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
  width: 350pt,
  height: 250pt,
  title: none,
  bins: auto,
  min-val: auto,
  max-val: auto,
  show-values: false,
  color: none,
  density: false,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-histogram-data(values, "histogram")
  let t = resolve-theme(theme)

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

  let y-max = calc.max(..y-values)
  if y-max == 0 { y-max = 1 }

  // Render
  let left-pad = 40pt
  let bottom-pad = 20pt
  let top-pad = 10pt
  let right-pad = 10pt

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - bottom-pad - top-pad
    #let chart-width = width - left-pad - right-pad

    #box(width: width, height: height - 10pt)[
      // Grid
      #draw-grid(left-pad, top-pad, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(left-pad, top-pad + chart-height, left-pad + chart-width, top-pad, t)

      // Draw bars (no gaps — contiguous)
      #let bar-w = chart-width / num-bins
      #for bi in array.range(num-bins) {
        let val = y-values.at(bi)
        let bar-h = (val / y-max) * chart-height
        let x-pos = left-pad + bi * bar-w
        let y-pos = top-pad + chart-height - bar-h

        let fill-color = if color != none { color } else { get-color(t, 0) }

        place(
          left + top,
          dx: x-pos,
          dy: y-pos,
          rect(
            width: bar-w,
            height: bar-h,
            fill: fill-color,
            stroke: (if t.background != none { t.background } else { white }) + 0.5pt,
          )
        )

        if show-values and val > 0 {
          let count-val = counts.at(bi)
          place(
            left + top,
            dx: x-pos + bar-w / 2 - 6pt,
            dy: y-pos - 12pt,
            text(size: t.value-label-size, fill: t.text-color)[#count-val]
          )
        }
      }

      // Y-axis ticks
      #draw-y-ticks(0, y-max, chart-height, top-pad, 2pt, t, digits: if density { 3 } else { 1 })

      // X-axis ticks (numeric)
      #draw-x-ticks(data-min, data-max, chart-width, left-pad, top-pad + chart-height + 5pt, t, digits: 1)

      // Axis titles
      #draw-axis-titles(x-label, y-label, left-pad + chart-width / 2, top-pad + chart-height / 2, t)
    ]
  ]
}
