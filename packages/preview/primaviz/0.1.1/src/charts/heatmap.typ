// heatmap.typ - Heatmap/matrix charts
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": lerp-color, heat-color
#import "../validate.typ": validate-heatmap-data, validate-calendar-data, validate-correlation-data
#import "../primitives/container.typ": chart-container

/// Renders a heatmap grid with color-coded cells.
///
/// - data (dictionary): Dict with `rows` (row labels), `cols` (column labels), and `values` (2D array)
/// - cell-size (length): Width and height of each cell
/// - title (none, content): Optional chart title
/// - show-values (bool): Display numeric values inside cells
/// - palette (str): Color palette name (`"viridis"`, `"heat"`, `"grayscale"`)
/// - show-legend (bool): Show color scale legend
/// - theme (none, dictionary): Theme overrides
/// -> content
#let heatmap(
  data,
  cell-size: 30pt,
  title: none,
  show-values: true,
  palette: "viridis",
  show-legend: true,
  theme: none,
) = {
  validate-heatmap-data(data, "heatmap")
  let t = resolve-theme(theme)
  let rows = data.rows
  let cols = data.cols
  let values = data.values

  let n-rows = rows.len()
  let n-cols = cols.len()

  // Find min/max values
  let all-vals = values.flatten()
  let min-val = calc.min(..all-vals)
  let max-val = calc.max(..all-vals)
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }

  let row-label-width = 60pt
  let col-label-height = 40pt
  let legend-width = if show-legend { 60pt } else { 0pt }

  let grid-width = n-cols * cell-size
  let grid-height = n-rows * cell-size

  chart-container(row-label-width + grid-width + legend-width + 20pt, col-label-height + grid-height, title, t, extra-height: 40pt)[
    #box[
      // Column labels (rotated)
      #for (j, col) in cols.enumerate() {
        place(
          left + top,
          dx: row-label-width + j * cell-size + cell-size / 2 - 5pt,
          dy: 5pt,
          rotate(-45deg, origin: bottom + left, text(size: t.axis-label-size, fill: t.text-color)[#col])
        )
      }

      // Grid cells and row labels
      #for (i, row) in rows.enumerate() {
        // Row label
        place(
          left + top,
          dx: 5pt,
          dy: col-label-height + i * cell-size + cell-size / 2 - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#row]
        )

        // Cells for this row
        for (j, val) in values.at(i).enumerate() {
          let normalized = (val - min-val) / val-range
          let cell-color = heat-color(normalized, palette: palette)

          place(
            left + top,
            dx: row-label-width + j * cell-size,
            dy: col-label-height + i * cell-size,
            rect(
              width: cell-size,
              height: cell-size,
              fill: cell-color,
              stroke: white + 0.5pt,
            )
          )

          // Value label
          if show-values {
            let text-color = if normalized > 0.5 { t.text-color-inverse } else { t.text-color }
            place(
              left + top,
              dx: row-label-width + j * cell-size + cell-size / 2 - 8pt,
              dy: col-label-height + i * cell-size + cell-size / 2 - 5pt,
              text(size: t.axis-label-size, fill: text-color)[#calc.round(val, digits: 1)]
            )
          }
        }
      }

      // Color legend
      #if show-legend {
        let legend-x = row-label-width + grid-width + 15pt
        let legend-height = grid-height * 0.8
        let legend-y = col-label-height + (grid-height - legend-height) / 2

        // Gradient bar
        for i in array.range(20) {
          let normalized = 1 - i / 20
          let cell-color = heat-color(normalized, palette: palette)
          place(
            left + top,
            dx: legend-x,
            dy: legend-y + (i / 20) * legend-height,
            rect(
              width: 15pt,
              height: legend-height / 20 + 1pt,
              fill: cell-color,
              stroke: none,
            )
          )
        }

        // Legend labels
        place(left + top, dx: legend-x + 20pt, dy: legend-y - 5pt, text(size: t.axis-label-size, fill: t.text-color)[#calc.round(max-val, digits: 1)])
        place(left + top, dx: legend-x + 20pt, dy: legend-y + legend-height - 5pt, text(size: t.axis-label-size, fill: t.text-color)[#calc.round(min-val, digits: 1)])
      }
    ]
  ]
}

/// Renders a calendar-style heatmap grid (similar to a GitHub contribution graph).
///
/// - data (dictionary): Dict with `dates` (array of `"YYYY-MM-DD"` strings) and `values` (array of numbers)
/// - cell-size (length): Size of each day cell
/// - title (none, content): Optional chart title
/// - palette (str): Color palette name
/// - show-month-labels (bool): Display month labels above the grid
/// - show-day-labels (bool): Display day-of-week labels on the left
/// - theme (none, dictionary): Theme overrides
/// -> content
#let calendar-heatmap(
  data,
  cell-size: 12pt,
  title: none,
  palette: "heat",
  show-month-labels: true,
  show-day-labels: true,
  theme: none,
) = {
  validate-calendar-data(data, "calendar-heatmap")
  let t = resolve-theme(theme)
  let dates = data.dates
  let values = data.values
  let n = dates.len()

  // Find min/max
  let min-val = calc.min(..values)
  let max-val = calc.max(..values)
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }

  // Assume dates are in order and calculate grid
  // For simplicity, we'll arrange in a 7-row (days of week) grid
  let n-weeks = calc.ceil(n / 7)

  let day-label-width = if show-day-labels { 25pt } else { 0pt }
  let month-label-height = if show-month-labels { 20pt } else { 0pt }

  chart-container(day-label-width + n-weeks * cell-size + 20pt, month-label-height + 7 * cell-size, title, t, extra-height: 40pt)[
    #box[
      // Day labels (Mon, Wed, Fri)
      #if show-day-labels {
        let days = ("Mon", "", "Wed", "", "Fri", "", "Sun")
        for (i, day) in days.enumerate() {
          if day != "" {
            place(
              left + top,
              dx: 0pt,
              dy: month-label-height + i * cell-size + cell-size / 2 - 4pt,
              text(size: 6pt, fill: t.text-color)[#day]
            )
          }
        }
      }

      // Cells
      #for (i, val) in values.enumerate() {
        let week = calc.floor(i / 7)
        let day = calc.rem(i, 7)
        let normalized = (val - min-val) / val-range
        let cell-color = if val == 0 { luma(240) } else { heat-color(normalized, palette: palette) }

        place(
          left + top,
          dx: day-label-width + week * cell-size,
          dy: month-label-height + day * cell-size,
          rect(
            width: cell-size - 2pt,
            height: cell-size - 2pt,
            fill: cell-color,
            radius: 2pt,
          )
        )
      }

      // Legend
      #let legend-y = month-label-height + 7 * cell-size + 10pt
      #place(left + top, dx: day-label-width, dy: legend-y, text(size: 6pt, fill: t.text-color)[Less])
      #for i in array.range(5) {
        let normalized = i / 4
        let cell-color = heat-color(normalized, palette: palette)
        place(
          left + top,
          dx: day-label-width + 25pt + i * (cell-size + 2pt),
          dy: legend-y,
          rect(width: cell-size, height: cell-size, fill: cell-color, radius: 2pt)
        )
      }
      #place(left + top, dx: day-label-width + 25pt + 5 * (cell-size + 2pt) + 5pt, dy: legend-y, text(size: 6pt, fill: t.text-color)[More])
    ]
  ]
}

/// Renders a correlation matrix as a symmetric heatmap (blue to red for -1 to +1).
///
/// - data (dictionary): Dict with `labels` and `values` (2D symmetric array, -1 to 1 range)
/// - cell-size (length): Width and height of each cell
/// - title (none, content): Optional chart title
/// - show-values (bool): Display correlation values inside cells
/// - theme (none, dictionary): Theme overrides
/// -> content
#let correlation-matrix(
  data,
  cell-size: 35pt,
  title: none,
  show-values: true,
  theme: none,
) = {
  validate-correlation-data(data, "correlation-matrix")
  let t = resolve-theme(theme)
  let labels = data.labels
  let values = data.values
  let n = labels.len()

  let label-area = 50pt

  // Correlation color: blue (-1) -> white (0) -> red (+1)
  let corr-color(val) = {
    let v = calc.max(-1, calc.min(1, val))
    if v < 0 {
      lerp-color(rgb("#2166ac"), white, (v + 1))
    } else {
      lerp-color(white, rgb("#b2182b"), v)
    }
  }

  chart-container(label-area + n * cell-size + 20pt, label-area + n * cell-size, title, t, extra-height: 40pt)[
    #box[
      // Column labels
      #for (j, lbl) in labels.enumerate() {
        place(
          left + top,
          dx: label-area + j * cell-size + cell-size / 2 - 10pt,
          dy: 5pt,
          rotate(-45deg, origin: bottom + left, text(size: t.axis-label-size, fill: t.text-color)[#lbl])
        )
      }

      // Cells and row labels
      #for (i, row-lbl) in labels.enumerate() {
        // Row label
        place(
          left + top,
          dx: 5pt,
          dy: label-area + i * cell-size + cell-size / 2 - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#row-lbl]
        )

        // Cells
        for (j, val) in values.at(i).enumerate() {
          let cell-color = corr-color(val)

          place(
            left + top,
            dx: label-area + j * cell-size,
            dy: label-area + i * cell-size,
            rect(
              width: cell-size,
              height: cell-size,
              fill: cell-color,
              stroke: white + 0.5pt,
            )
          )

          if show-values {
            let text-color = if calc.abs(val) > 0.5 { t.text-color-inverse } else { t.text-color }
            place(
              left + top,
              dx: label-area + j * cell-size + cell-size / 2 - 10pt,
              dy: label-area + i * cell-size + cell-size / 2 - 5pt,
              text(size: t.axis-label-size, fill: text-color)[#calc.round(val, digits: 2)]
            )
          }
        }
      }
    ]
  ]
}
