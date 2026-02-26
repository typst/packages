// waffle.typ - Waffle chart (grid of squares showing proportions)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend

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
/// - show-legend (bool): Display legend with category names and colors
/// - show-values (bool): Display percentage labels in the legend
/// - theme (none, dictionary): Theme overrides
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
) = {
  validate-simple-data(data, "waffle-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = labels.len()
  let total-cells = rows * cols

  // Normalize values to percentages of total-cells
  let raw-sum = values.sum()
  if raw-sum == 0 { raw-sum = 1 }  // division-by-zero guard
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

  // Compute percentages for legend display
  let percentages = values.map(v => calc.round(v / raw-sum * 100, digits: 1))

  // Build legend entries
  let legend-entries = ()
  if show-legend {
    for i in range(n) {
      let label-text = labels.at(i)
      if show-values {
        label-text = label-text + " (" + str(percentages.at(i)) + "%)"
      }
      legend-entries.push(label-text)
    }
  }

  let legend-height = if show-legend { 30pt } else { 0pt }

  chart-container(size, size + legend-height, title, t)[
    // Draw grid bottom-to-top, left-to-right
    #let grid-width = cell-size * cols + gap * (cols - 1)
    #let grid-height = cell-size * rows + gap * (rows - 1)

    #box(width: size, height: size)[
      #align(center + horizon)[
        #box(width: grid-width, height: grid-height)[
          #for row in range(rows) {
            // bottom-to-top: row 0 is the bottom row visually
            let visual-row = rows - 1 - row
            for col in range(cols) {
              let cell-idx = row * cols + col
              let cat-idx = if cell-idx < cell-colors.len() {
                cell-colors.at(cell-idx)
              } else {
                0
              }
              let color = get-color(t, cat-idx)
              place(
                dx: col * (cell-size + gap),
                dy: visual-row * (cell-size + gap),
                rect(
                  width: cell-size,
                  height: cell-size,
                  fill: color,
                  radius: radius,
                ),
              )
            }
          }
        ]
      ]
    ]

    // Legend
    #if show-legend {
      draw-legend(legend-entries, t)
    }
  ]
}
