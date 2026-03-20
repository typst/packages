// heatmap.typ - Heatmap/matrix charts
#import "../theme.typ": _resolve-ctx, get-color, _phi
#import "../util.typ": lerp-color, heat-color, nonzero, day-of-week, contrast-text
#import "../validate.typ": validate-heatmap-data, validate-calendar-data, validate-correlation-data
#import "../primitives/container.typ": chart-container, container-inset
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
  cell-size: auto,
  title: none,
  show-values: true,
  palette: "viridis",
  show-legend: true,
  reverse: false,
  subtitle: none,
  radius: 0pt,
  theme: none,
) = context {
  layout(avail => {
  validate-heatmap-data(data, "heatmap")
  let t = _resolve-ctx(theme)

  // Default cell-size scales from seeds: base-gap × φ³ ≈ 25pt at default
  let cell-size = if cell-size == auto { t.cell-size } else { cell-size }

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

  let row-label-width = calc.max(t.axis-padding-left, n-cols * cell-size * 0.15 + t.axis-padding-bottom / 2)
  let col-label-height = calc.max(t.axis-padding-left, cell-size * 1.5)
  let legend-width = if show-legend { t.axis-padding-left } else { 0pt }

  // Shrink cell-size if total width exceeds available space
  let ci = t.at("container-inset", default: container-inset)
  let overhead = row-label-width + legend-width + t.legend-gap + 2 * ci
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  let cell-size = if avail-w != none and n-cols * cell-size + overhead > avail-w {
    (avail-w - overhead) / n-cols
  } else { cell-size }

  let grid-width = n-cols * cell-size
  let grid-height = n-rows * cell-size

  chart-container(row-label-width + grid-width + legend-width + t.legend-gap, col-label-height + grid-height, title, t, extra-height: t.axis-padding-left, subtitle: subtitle, radius: radius)[
    #box[
      // Column labels (rotated) — skip when columns are narrow
      #let col-skip = density-skip(n-cols, n-cols * cell-size)
      #for (j, col) in cols.enumerate() {
        if calc.rem(j, col-skip) == 0 or j == n-cols - 1 {
          place(
            left + top,
            dx: row-label-width + j * cell-size + cell-size / 2,
            dy: col-label-height - t.label-offset,
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
          box(width: row-label-width - t.label-offset, height: 0pt,
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
              stroke: t.marker-stroke,
            )
          )

          // Value label — centered in cell
          if show-values {
            let text-color = contrast-text(cell-color)
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
        let legend-x = row-label-width + grid-width + t.legend-gap
        let legend-height = grid-height * 0.8
        let legend-y = col-label-height + (grid-height - legend-height) / 2
        place(left + top, dx: legend-x, dy: legend-y,
          draw-gradient-legend(min-val, max-val, palette, t, bar-height: legend-height, reverse: reverse))
      }
    ]
  ]
  })
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

  let day-label-width = if show-day-labels { t.axis-padding-bottom } else { 0pt }
  let month-label-height = if show-month-labels { t.axis-padding-bottom } else { 0pt }

  // Theme-aware empty cell styling
  let empty-fill = if t.background != none { t.background.lighten(15%) } else { t.text-color-light.transparentize(80%) }
  let empty-stroke = t.stroke-thin + t.text-color-light.transparentize(40%)

  let legend-total-w = t.axis-padding-bottom + 5 * (cell-size + t.cell-gap) + t.label-offset + t.axis-padding-bottom  // Less + boxes + More
  let grid-w = n-weeks * cell-size
  let body-w = day-label-width + grid-w
  align(center, chart-container(body-w, month-label-height + 7 * cell-size, title, t, extra-height: t.axis-padding-left)[
    #box(width: body-w)[
      // Month labels along the top (x-axis) — skip labels that would overlap
      #if show-month-labels {
        let month-names = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
        let prev-month = ""
        let last-label-x = -100pt  // track last placed label x to prevent overlap
        let min-label-gap = t.axis-padding-bottom   // minimum horizontal gap between month labels
        for (i, dt) in dates.enumerate() {
          let parts = dt.split("-")
          let month-str = if parts.len() >= 2 { parts.at(1) } else { "" }
          if month-str != prev-month and month-str != "" {
            let grid-idx = start-dow + i
            let week = calc.floor(grid-idx / 7)
            let label-x = day-label-width + week * cell-size
            let month-idx = int(month-str) - 1
            let label = if month-idx >= 0 and month-idx < 12 { month-names.at(month-idx) } else { month-str }
            // Only place if far enough from previous label
            if label-x - last-label-x >= min-label-gap {
              place(left + top,
                dx: label-x,
                dy: 0pt,
                text(size: t.axis-label-size * 0.85, fill: t.text-color)[#label])
              last-label-x = label-x
            }
            prev-month = month-str
          }
        }
      }

      // Day labels (Mon, Wed, Fri)
      #if show-day-labels {
        let days = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
        for (i, day) in days.enumerate() {
          if day != "" {
            place(
              left + top,
              dx: 0pt,
              dy: month-label-height + i * cell-size + cell-size / 2,
              move(dy: -0.5em, text(size: t.axis-label-size * 0.85, fill: t.text-color)[#day])
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
            width: cell-size - t.cell-gap,
            height: cell-size - t.cell-gap,
            fill: empty-fill,
            stroke: empty-stroke,
            radius: t.cell-gap,
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
            width: cell-size - t.cell-gap,
            height: cell-size - t.cell-gap,
            fill: cell-color,
            stroke: if val == 0 { empty-stroke } else { none },
            radius: t.cell-gap,
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
              radius: t.cell-gap,
            )
          )
        }
      }

      // Legend — centered under the grid
      #let legend-y = month-label-height + 7 * cell-size + t.legend-gap
      #let grid-width = n-weeks * cell-size
      #let legend-start = calc.max(0pt, (body-w - legend-total-w) / 2)
      #place(left + top, dx: legend-start, dy: legend-y, text(size: t.axis-label-size * 0.85, fill: t.text-color)[Less])
      #for i in array.range(5) {
        let normalized = i / 4
        let cell-color = heat-color(normalized, palette: palette, reverse: reverse)
        place(
          left + top,
          dx: legend-start + t.axis-padding-bottom + i * (cell-size + t.cell-gap),
          dy: legend-y,
          rect(width: cell-size, height: cell-size, fill: cell-color, radius: t.cell-gap)
        )
      }
      #place(left + top, dx: legend-start + t.axis-padding-bottom + 5 * (cell-size + t.cell-gap) + t.label-offset, dy: legend-y, text(size: t.axis-label-size * 0.85, fill: t.text-color)[More])
    ]
  ])
}

/// Renders a correlation matrix as a symmetric heatmap with configurable palette.
///
/// - data (dictionary): Dict with `labels` and `values` (2D symmetric array, -1 to 1 range)
/// - cell-size (length): Width and height of each cell
/// - title (none, content): Optional chart title
/// - show-values (bool): Display correlation values inside cells
/// - palette (str, array): Color palette name or array of color stops. Append `"-r"` to reverse named palettes.
/// - show-legend (bool): Show color scale legend
/// - reverse (bool): Reverse palette direction
/// - theme (none, dictionary): Theme overrides
/// -> content
#let correlation-matrix(
  data,
  cell-size: auto,
  title: none,
  show-values: true,
  palette: "coolwarm",
  show-legend: true,
  reverse: false,
  theme: none,
) = context {
  layout(avail => {
  validate-correlation-data(data, "correlation-matrix")
  let t = _resolve-ctx(theme)
  let cell-size = if cell-size == auto { t.cell-size * _phi } else { cell-size }
  let labels = data.labels
  let values = data.values
  let n = labels.len()

  let label-area = t.axis-padding-left + t.axis-label-gap
  let legend-width = if show-legend { t.axis-padding-left } else { 0pt }

  // Shrink cell-size if total width exceeds available space
  let ci = t.at("container-inset", default: container-inset)
  let overhead = label-area + legend-width + t.legend-gap + 2 * ci
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  let cell-size = if avail-w != none and n * cell-size + overhead > avail-w {
    (avail-w - overhead) / n
  } else { cell-size }

  let grid-width = n * cell-size
  let grid-height = n * cell-size

  chart-container(label-area + grid-width + legend-width + t.legend-gap, label-area + grid-height, title, t, extra-height: t.axis-padding-left)[
    #box[
      // Column labels — skip when columns are narrow
      #let col-skip = density-skip(n, n * cell-size)
      #for (j, lbl) in labels.enumerate() {
        if calc.rem(j, col-skip) == 0 or j == n - 1 {
          place(
            left + top,
            dx: label-area + j * cell-size + cell-size / 2,
            dy: label-area - t.legend-gap,
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
          box(width: label-area - t.label-offset, height: 0pt,
            align(right, move(dy: -0.5em,
              text(size: t.axis-label-size, fill: t.text-color)[#row-lbl])))
        )

        // Cells
        for (j, val) in values.at(i).enumerate() {
          // Map correlation range [-1, +1] to normalized [0, 1] for heat-color
          let normalized = (calc.max(-1, calc.min(1, val)) + 1) / 2
          let cell-color = heat-color(normalized, palette: palette, reverse: reverse)
          let cell-stroke = t.marker-stroke

          place(
            left + top,
            dx: label-area + j * cell-size,
            dy: label-area + i * cell-size,
            rect(
              width: cell-size,
              height: cell-size,
              fill: cell-color,
              stroke: cell-stroke,
            )
          )

          if show-values {
            let text-color = contrast-text(cell-color)
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

      // Color legend
      #if show-legend {
        let legend-x = label-area + grid-width + t.legend-gap
        let legend-height = grid-height * 0.8
        let legend-y = label-area + (grid-height - legend-height) / 2
        place(left + top, dx: legend-x, dy: legend-y,
          draw-gradient-legend(-1, 1, palette, t, bar-height: legend-height, reverse: reverse))
      }
    ]
  ]
  })
}
