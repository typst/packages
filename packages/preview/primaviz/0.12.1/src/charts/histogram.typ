// histogram.typ - Histogram chart (frequency distribution of numeric data)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nice-ticks
#import "../validate.typ": validate-histogram-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, fit-label-size
#import "../primitives/layout.typ": resolve-size, pin

/// Renders a histogram showing the frequency distribution of numeric data.
///
/// With everything automatic (`bins`, `min-val`, `max-val`) the bin edges are
/// round numbers; otherwise the bins are evenly spaced from `min-val` to
/// `max-val`. Either way the x ticks sit on bin edges.
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
/// - annotations (none, array): Optional annotation descriptors
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter minor grid lines between the major ones
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

  let data-min = if min-val == auto { calc.min(..values) } else { min-val }
  let data-max = if max-val == auto { calc.max(..values) } else { max-val }
  // All values identical: give the single bin some width
  if data-min == data-max { data-max = data-min + 1 }

  // Bin edges: round numbers when everything is automatic, otherwise even steps
  let sturges = calc.ceil(calc.log(n, base: 2) + 1)
  let edges = if bins == auto and min-val == auto and max-val == auto {
    nice-ticks(data-min, data-max, count: sturges + 1).ticks
  } else {
    let nb = if bins == auto { sturges } else { bins }
    let step = (data-max - data-min) / nb
    range(nb + 1).map(i => data-min + i * step)
  }
  let num-bins = edges.len() - 1
  let bin-width = edges.at(1) - edges.at(0)

  let counts = range(num-bins).map(bi => values.filter(v => {
    let last = bi == num-bins - 1
    v >= edges.at(bi) and (if last { v <= edges.at(bi + 1) } else { v < edges.at(bi + 1) })
  }).len())
  let heights = if density { counts.map(c => c / (n * bin-width)) } else { counts.map(c => float(c)) }

  // Ticks sit on bin edges (every k-th when they are too many), with just
  // enough decimals to tell neighbouring edges apart
  let edge-digits = calc.max(0, 1 - calc.floor(calc.log(bin-width, base: 10)))
  let edge-ticks = (min: edges.first(), max: edges.last(), ticks: edges, step: bin-width, digits: edge-digits, thin: true)
  let fill-color = if color != none { color } else { get-color(t, 0) }

  cartesian-frame(width, height, t,
    x: value-axis(edges.first(), edges.last(), title: x-label, ticks: edge-ticks),
    y: value-axis(0, calc.max(..heights), title: y-label),
    title: title, show-ticks: show-ticks, show-minor-grid: show-minor-grid,
    baseline: (y: 0), annotations: annotations,
    reserve: (top: if show-values { t.value-label-size + t.label-offset } else { 0pt }),
    p => {
      let (px, py) = (p.px, p.py)
      let vsize = fit-label-size(counts.map(str), p.w / num-bins, t.value-label-size)
      for bi in range(num-bins) {
        let (x-left, x-right, y-top) = (px(edges.at(bi)), px(edges.at(bi + 1)), py(heights.at(bi)))
        place(left + top, dx: x-left, dy: y-top,
          rect(width: x-right - x-left, height: py(0) - y-top, fill: fill-color, stroke: t.marker-stroke))
        if show-values and counts.at(bi) > 0 and vsize != none {
          place(left + top, dx: x-left, dy: y-top - t.label-offset,
            pin(width: x-right - x-left, align: center + bottom,
              text(size: vsize, fill: t.text-color)[#counts.at(bi)]))
        }
      }
    },
  )
  })
}
