// heatmap.typ - Heatmap/matrix charts
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": lerp-color, heat-color, nonzero, day-of-week
#import "../validate.typ": validate-heatmap-data, validate-calendar-data, validate-correlation-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": density-skip
#import "../primitives/legend.typ": draw-gradient-legend

/// Renders a heatmap grid with color-coded cells.
///
/// - data (dictionary): Dict with `rows` (row labels), `cols` (column labels), and `values` (2D array)
/// - cell-size (length): Width and height of each cell
/// - title (none, content): Optional chart title
/// - show-values (bool): Display numeric values inside cells
/// - palette (str, array): Color palette name or array of color stops. Append `"-r"` to reverse named palettes.
/// - show-legend (bool): Show color scale legend
/// - reverse (bool): Reverse palette direction
/// - theme (none, dictionary): Theme overrides
/// -> content
#let heatmap(
  data,
  cell-size: 30pt,
  title: none,
  show-values: true,
  palette: "viridis",
  show-legend: true,
  reverse: false,
  theme: none,
) = context {
  validate-heatmap-data(data, "heatmap")
  let t = _resolve-ctx(theme)
  let rows = data.rows
  let cols = data.cols
  let values = data.values

  let n-rows = rows.len()
  let n-cols = cols.len()

  // Find min/max values
  let all-vals = values.flatten()
  let min-val = calc.min(..all-vals)
  let max-val = calc.max(..all-vals)
  let val-range = nonzero(max-val - min-val)

  let row-label-width = calc.max(30pt, n-cols * cell-size * 0.2 + 20pt)
  let col-label-height = calc.max(30pt, cell-size * 1.8)
  let legend-width = if show-legend { 60pt } else { 0pt }

  let grid-width = n-cols * cell-size
  let grid-height = n-rows * cell-size

  chart-container(row-label-width + grid-width + legend-width + 20pt, col-label-height + grid-height, title, t, extra-height: 40pt)[
    #box[
      // Column labels (rotated) — skip when columns are narrow
      #let col-skip = density-skip(n-cols, n-cols * cell-size)
      #for (j, col) in cols.enumerate() {
        if calc.rem(j, col-skip) == 0 or j == n-cols - 1 {
          place(
            left + top,
            dx: row-label-width + j * cell-size + cell-size / 2,
            dy: col-label-height - 4pt,
            rotate(-45deg, origin: bottom + left, text(size: t.axis-label-size, fill: t.text-color)[#col])
          )
        }
      }

      // Grid cells and row labels
      #for (i, row) in rows.enumerate() {
        // Row label — right-aligned into label area
        place(
          left + top,
          dx: 0pt,
          dy: col-label-height + i * cell-size + cell-size / 2,
          box(width: row-label-width - 4pt, height: 0pt,
            align(right, move(dy: -0.5em,
              text(size: t.axis-label-size, fill: t.text-color)[#row])))
        )

        // Cells for this row
        for (j, val) in values.at(i).enumerate() {
          let normalized = (val - min-val) / val-range
          let cell-color = heat-color(normalized, palette: palette, reverse: reverse)

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

          // Value label — centered in cell
          if show-values {
            let is-dark = if reverse { normalized < 0.5 } else { normalized > 0.5 }
            let text-color = if is-dark { t.text-color-inverse } else { t.text-color }
            place(
              left + top,
              dx: row-label-width + j * cell-size,
              dy: col-label-height + i * cell-size,
              box(width: cell-size, height: cell-size,
                align(center + horizon,
                  text(size: t.axis-label-size, fill: text-color)[#calc.round(val, digits: 1)]))
            )
          }
        }
      }

      // Color legend
      #if show-legend {
        let legend-x = row-label-width + grid-width + 15pt
        let legend-height = grid-height * 0.8
        let legend-y = col-label-height + (grid-height - legend-height) / 2
        place(left + top, dx: legend-x, dy: legend-y,
          draw-gradient-legend(min-val, max-val, palette, t, bar-height: legend-height, reverse: reverse))
      }
    ]
  ]
}

/// Renders a calendar-style heatmap grid (similar to a GitHub contribution graph).
///
/// - data (dictionary): Dict with `dates` (array of `"YYYY-MM-DD"` strings) and `values` (array of numbers)
/// - cell-size (length): Size of each day cell
/// - title (none, content): Optional chart title
/// - palette (str, array): Color palette name or array of color stops
/// - show-month-labels (bool): Display month labels above the grid
/// - show-day-labels (bool): Display day-of-week labels on the left
/// - reverse (bool): Reverse palette direction
/// - theme (none, dictionary): Theme overrides
/// -> content
#let calendar-heatmap(
  data,
  cell-size: 12pt,
  title: none,
  palette: "heat",
  show-month-labels: true,
  show-day-labels: true,
  reverse: false,
  theme: none,
) = context {
  validate-calendar-data(data, "calendar-heatmap")
  let t = _resolve-ctx(theme)
  let dates = data.dates
  let values = data.values
  let n = dates.len()

  // Find min/max (excluding zeros for color scaling)
  let non-zero-vals = values.filter(v => v > 0)
  let min-val = if non-zero-vals.len() > 0 { calc.min(..non-zero-vals) } else { 0 }
  let max-val = calc.max(..values)
  let val-range = nonzero(max-val - min-val)

  // Compute the starting day-of-week offset (0=Mon..6=Sun)
  let start-dow = day-of-week(dates.at(0))  // 0=Mon..6=Sun

  // Total grid slots = offset + n data cells, rounded up to full weeks
  let total-slots = start-dow + n
  let n-weeks = calc.ceil(total-slots / 7)

  let day-label-width = if show-day-labels { 25pt } else { 0pt }
  let month-label-height = if show-month-labels { 20pt } else { 0pt }

  // Theme-aware empty cell styling
  let empty-fill = if t.background != none { t.background.lighten(15%) } else { luma(235) }
  let empty-stroke = if t.background != none { 0.5pt + t.text-color-light } else { 0.5pt + luma(210) }

  chart-container(day-label-width + n-weeks * cell-size + 20pt, month-label-height + 7 * cell-size, title, t, extra-height: 40pt)[
    #box[
      // Month labels along the top (x-axis)
      #if show-month-labels {
        let month-names = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
        let prev-month = ""
        for (i, dt) in dates.enumerate() {
          let parts = dt.split("-")
          let month-str = if parts.len() >= 2 { parts.at(1) } else { "" }
          if month-str != prev-month and month-str != "" {
            // Position based on actual grid column (accounting for start offset)
            let grid-idx = start-dow + i
            let week = calc.floor(grid-idx / 7)
            let month-idx = int(month-str) - 1
            let label = if month-idx >= 0 and month-idx < 12 { month-names.at(month-idx) } else { month-str }
            place(left + top,
              dx: day-label-width + week * cell-size,
              dy: 0pt,
              text(size: 6pt, fill: t.text-color)[#label])
            prev-month = month-str
          }
        }
      }

      // Day labels (Mon, Wed, Fri)
      #if show-day-labels {
        let days = ("Mon", "", "Wed", "", "Fri", "", "Sun")
        for (i, day) in days.enumerate() {
          if day != "" {
            place(
              left + top,
              dx: 0pt,
              dy: month-label-height + i * cell-size + cell-size / 2,
              move(dy: -0.5em, text(size: 6pt, fill: t.text-color)[#day])
            )
          }
        }
      }

      // Empty padding cells before the first date
      #for d in range(start-dow) {
        place(
          left + top,
          dx: day-label-width,
          dy: month-label-height + d * cell-size,
          rect(
            width: cell-size - 2pt,
            height: cell-size - 2pt,
            fill: empty-fill,
            stroke: empty-stroke,
            radius: 2pt,
          )
        )
      }

      // Data cells — positioned by actual day-of-week
      #for (i, val) in values.enumerate() {
        let grid-idx = start-dow + i
        let week = calc.floor(grid-idx / 7)
        let day = calc.rem(grid-idx, 7)
        let normalized = if val > 0 { (val - min-val) / val-range } else { 0 }
        let cell-color = if val == 0 { empty-fill } else { heat-color(normalized, palette: palette, reverse: reverse) }

        place(
          left + top,
          dx: day-label-width + week * cell-size,
          dy: month-label-height + day * cell-size,
          rect(
            width: cell-size - 2pt,
            height: cell-size - 2pt,
            fill: cell-color,
            stroke: if val == 0 { empty-stroke } else { none },
            radius: 2pt,
          )
        )
      }

      // Empty padding cells after the last date (fill remaining week)
      #let last-grid-idx = start-dow + n - 1
      #let last-day = calc.rem(last-grid-idx, 7)
      #if last-day < 6 {
        let last-week = calc.floor(last-grid-idx / 7)
        for d in range(last-day + 1, 7) {
          place(
            left + top,
            dx: day-label-width + last-week * cell-size,
            dy: month-label-height + d * cell-size,
            rect(
              width: cell-size - 2pt,
              height: cell-size - 2pt,
              fill: empty-fill,
              stroke: empty-stroke,
              radius: 2pt,
            )
          )
        }
      }

      // Legend
      #let legend-y = month-label-height + 7 * cell-size + 10pt
      #place(left + top, dx: day-label-width, dy: legend-y, text(size: 6pt, fill: t.text-color)[Less])
      #for i in array.range(5) {
        let normalized = i / 4
        let cell-color = heat-color(normalized, palette: palette, reverse: reverse)
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
) = context {
  validate-correlation-data(data, "correlation-matrix")
  let t = _resolve-ctx(theme)
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
      // Column labels — skip when columns are narrow
      #let col-skip = density-skip(n, n * cell-size)
      #for (j, lbl) in labels.enumerate() {
        if calc.rem(j, col-skip) == 0 or j == n - 1 {
          place(
            left + top,
            dx: label-area + j * cell-size + cell-size / 2,
            dy: label-area - 12pt,
            rotate(-45deg, origin: bottom + left, text(size: t.axis-label-size, fill: t.text-color)[#lbl])
          )
        }
      }

      // Cells and row labels
      #for (i, row-lbl) in labels.enumerate() {
        // Row label — right-aligned into label area
        place(
          left + top,
          dx: 0pt,
          dy: label-area + i * cell-size + cell-size / 2,
          box(width: label-area - 4pt, height: 0pt,
            align(right, move(dy: -0.5em,
              text(size: t.axis-label-size, fill: t.text-color)[#row-lbl])))
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
              dx: label-area + j * cell-size,
              dy: label-area + i * cell-size,
              box(width: cell-size, height: cell-size,
                align(center + horizon,
                  text(size: t.axis-label-size, fill: text-color)[#calc.round(val, digits: 2)]))
            )
          }
        }
      }
    ]
  ]
}
