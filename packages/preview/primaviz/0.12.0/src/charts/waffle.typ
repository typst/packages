// waffle.typ - Waffle chart (grid of squares showing proportions)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-vertical
#import "../primitives/layout.typ": resolve-size, max-text-width, text-height, spread-labels, place-centered

/// Renders a waffle chart — a grid of squares where each square represents
/// a unit or percentage of the total. Commonly used in infographics to
/// show proportions at a glance.
///
/// Values are normalized to percentages if they don't sum to 100.
/// Squares fill left-to-right, bottom-to-top with category colors.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - size (length): Overall chart width and height for the grid area
/// - rows (int): Number of rows in the grid
/// - cols (int): Number of columns in the grid
/// - gap (length): Spacing between squares
/// - rounded (bool): Whether squares have rounded corners
/// - title (none, content): Optional chart title
/// - show-legend (bool): Name the categories and show their colors: in a column beside the
///   grid, each name level with its own band of squares, when that fits (at most 40% of the
///   room); otherwise in a legend
/// - show-values (bool): Display each category's share beside its name
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let waffle-chart(
  data,
  size: 200pt,
  rows: 10,
  cols: 10,
  gap: 2pt,
  rounded: true,
  title: none,
  show-legend: true,
  show-values: true,
  theme: none,
  extra-legend-separation: 0pt,
) = context {
  layout(avail => {
  validate-simple-data(data, "waffle-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width

  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = labels.len()
  let total-cells = rows * cols
  let raw-sum = nonzero(values.sum())

  // Legend entries, "name (share)": the legend is as wide as its longest
  // entry, measured, and never more than 40% of the room
  let percentages = values.map(v => calc.round(v / raw-sum * 100, digits: 1))
  let legend-entries = ()
  if show-legend {
    for i in range(n) {
      let pct = str(percentages.at(i)) + "%"
      legend-entries.push(if show-values { labels.at(i) + " (" + pct + ")" } else { labels.at(i) })
    }
  }
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  // Names beside the grid, level with their bands, when they fit; else a legend
  let lsz = t.legend-size
  let sw = lsz * 0.8
  let direct-w = if show-legend and n > 0 { sw + 4pt + max-text-width(legend-entries, lsz) + 2pt } else { 0pt }
  let lh = calc.max(sw, text-height("Mg", lsz)) + 3pt
  let direct = show-legend and n > 0 and (avail-w == none or direct-w <= avail-w * 0.4) and n * lh <= size
  let legend-w = if show-legend and n > 0 and not direct {
    let natural = t.legend-swatch-size + 3pt + max-text-width(legend-entries, t.legend-size) + 2pt
    if avail-w != none { calc.min(natural, avail-w * 0.4) } else { natural }
  } else { 0pt }

  // Shrink the grid if grid + labels + container padding exceed the room
  let legend-overhead = if direct { direct-w + 10pt } else if show-legend { legend-w + 10pt } else { 0pt }
  let pad2 = 2 * t.container-inset
  if avail-w != none and size + legend-overhead + pad2 > avail-w {
    size = calc.max(20pt, avail-w - legend-overhead - pad2)
  }

  // Normalize values to percentages of total-cells
  let cell-counts = values.map(v => int(calc.round(v / raw-sum * total-cells)))

  // Adjust rounding so cell-counts sum to exactly total-cells
  let allocated = cell-counts.sum()
  if allocated != total-cells and n > 0 {
    // Add or remove from the largest category
    let max-idx = 0
    let max-val = cell-counts.at(0)
    for i in range(1, n) {
      if cell-counts.at(i) > max-val {
        max-val = cell-counts.at(i)
        max-idx = i
      }
    }
    cell-counts.at(max-idx) = cell-counts.at(max-idx) + (total-cells - allocated)
  }

  // Build a flat array mapping each cell index to a category index
  // Cells fill bottom-to-top, left-to-right
  let cell-colors = ()
  for (cat-idx, count) in cell-counts.enumerate() {
    for _ in range(count) {
      cell-colors.push(cat-idx)
    }
  }

  // Compute square size from available space
  let cell-w = (size - gap * (cols - 1)) / cols
  let cell-h = (size - gap * (rows - 1)) / rows
  let cell-size = calc.min(cell-w, cell-h)
  let radius = if rounded { 2pt } else { 0pt }

  // Compute actual grid dimensions
  let grid-width = cell-size * cols + gap * (cols - 1)
  let grid-height = cell-size * rows + gap * (rows - 1)

  // The squares: bottom-to-top, left-to-right
  let cells = box(width: grid-width, height: grid-height)[
    #for row in range(rows) {
      // bottom-to-top: row 0 is the bottom row visually
      let visual-row = rows - 1 - row
      for col in range(cols) {
        let cell-idx = row * cols + col
        let cat-idx = if cell-idx < cell-colors.len() { cell-colors.at(cell-idx) } else { 0 }
        place(
          dx: col * (cell-size + gap),
          dy: visual-row * (cell-size + gap),
          rect(width: cell-size, height: cell-size, fill: get-color(t, cat-idx), radius: radius),
        )
      }
    }
  ]

  // Force legend to right side for waffle charts
  let wt = (..t, legend-position: "right")

  if direct {
    // Each name sits level with the middle of its band of squares; names of
    // thin bands are spread apart so none overlaps another
    let pitch = cell-size + gap
    let row-of(idx) = rows - 1 - calc.div-euclid(calc.min(idx, total-cells - 1), cols)
    let starts = array.range(n).map(k => cell-counts.slice(0, k).fold(0, (a, b) => a + b))
    let centres = array.range(n).map(k => {
      let (a, b) = (starts.at(k), starts.at(k) + cell-counts.at(k))
      let top-row = row-of(calc.max(a, b - 1))
      let bot-row = row-of(a)
      ((top-row + bot-row + 1) / 2) * pitch - gap / 2
    })
    let ys = spread-labels(centres, sizes: lh, lo: 0pt, hi: grid-height, priority: cell-counts)
    let body-w = grid-width + 10pt + direct-w
    align(center, chart-container(body-w, grid-height, title, wt, extra-legend-separation: extra-legend-separation)[
      #box(width: body-w, height: grid-height)[
        #place(left + top, cells)
        #for k in range(n) {
          let pct = str(percentages.at(k)) + "%"
          if ys.at(k) != none { place-centered(grid-width + 10pt, ys.at(k), grid(columns: (auto, auto), column-gutter: 4pt, align: horizon,
            rect(width: sw, height: sw, fill: get-color(t, k), radius: 1pt),
            text(size: lsz, fill: t.text-color)[#labels.at(k)#if show-values [ #text(fill: t.text-color-light)[#pct]]])) }
        }
      ]
    ])
  } else {
    let legend-content = if show-legend and n > 0 { draw-legend-vertical(legend-entries, wt, width: legend-w) } else { none }
    align(center, chart-container(size, grid-height, title, wt, legend: legend-content, legend-width: legend-w, extra-legend-separation: extra-legend-separation)[
      #box(width: size, height: grid-height)[
        #align(center + top)[#cells]
      ]
    ])
  }
  })
}
