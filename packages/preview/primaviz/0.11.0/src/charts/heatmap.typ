// heatmap.typ - Heatmap/matrix charts
#import "../theme.typ": _resolve-ctx, get-color, _phi, _shade
#import "../util.typ": lerp-color, heat-color, nonzero, contrast-text
#import "../validate.typ": validate-heatmap-data, validate-calendar-data, validate-correlation-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/layout.typ": density-skip, font-to-fit-width, pin
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
/// - subtitle (none, content): Optional subtitle below the title
/// - radius (length): Corner radius of the chart container
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

      // Resolve every cell's position and color once, so the fills and the
      // value labels can be drawn in two separate passes below.
      #let cells = values.enumerate().map(((i, row-vals)) => {
        row-vals.enumerate().map(((j, val)) => (
          x: row-label-width + j * cell-size,
          y: col-label-height + i * cell-size,
          value: val,
          color: heat-color((val - min-val) / val-range, palette: palette, reverse: reverse),
        ))
      })

      // Grid cells and row labels
      #for (i, row) in rows.enumerate() {
        // Row label — right-aligned into label area
        place(
          left + top,
          dx: 0pt,
          dy: col-label-height + i * cell-size + cell-size / 2,
          box(width: row-label-width - t.label-offset, height: 0pt,
            align(right + horizon,
              text(size: t.axis-label-size, fill: t.text-color)[#row]))
        )

        // Cells for this row
        for cell in cells.at(i) {
          place(
            left + top,
            dx: cell.x,
            dy: cell.y,
            rect(
              width: cell-size,
              height: cell-size,
              fill: cell.color,
              stroke: t.marker-stroke,
            )
          )
        }
      }

      // Value labels — drawn after every cell. Cells sit flush against each
      // other, so a value wider than its cell overflows past the edge and a
      // label emitted alongside its own cell loses that tail to the next one.
      #if show-values {
        // Size off the longest value in the grid so every cell shares one
        // size, and so the widest number is the one that has to fit.
        let widest = cells.flatten()
          .map(c => str(calc.round(c.value, digits: 1)).clusters().len())
          .fold(0, calc.max)
        let value-size = font-to-fit-width(cell-size - 4pt, t.axis-label-size, widest)
        for row-cells in cells {
          for cell in row-cells {
            place(
              left + top,
              dx: cell.x,
              dy: cell.y,
              box(width: cell-size, height: cell-size,
                align(center + horizon,
                  text(size: value-size, fill: contrast-text(cell.color))[
                    #calc.round(cell.value, digits: 1)]))
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
  // Place each value by its actual date: gaps between dates stay empty and
  // repeated dates add up, so sparse data (e.g. weekly) lands on the right day
  let parse(dt) = {
    let p = dt.split("-")
    assert(p.len() == 3, message: "calendar-heatmap: dates must be YYYY-MM-DD, got " + repr(dt))
    datetime(year: int(p.at(0)), month: int(p.at(1)), day: int(p.at(2)))
  }
  let days = data.dates.map(parse)
  let first = days.fold(days.at(0), (a, d) => if d < a { d } else { a })
  let last = days.fold(days.at(0), (a, d) => if d > a { d } else { a })
  let span = int((last - first).days()) + 1
  let by-offset = (:)
  for (d, v) in days.zip(data.values) {
    let k = str(int((d - first).days()))
    by-offset.insert(k, by-offset.at(k, default: 0) + v)
  }
  let values = by-offset.values()

  // Find min/max (excluding zeros for color scaling)
  let non-zero-vals = values.filter(v => v > 0)
  let min-val = if non-zero-vals.len() > 0 { calc.min(..non-zero-vals) } else { 0 }
  let max-val = calc.max(..values)
  let val-range = nonzero(max-val - min-val)

  // Starting day-of-week offset (0=Mon..6=Sun)
  let start-dow = first.weekday() - 1

  // Total grid slots = offset + every day in the range, rounded up to full weeks
  let n-weeks = calc.ceil((start-dow + span) / 7)

  let day-label-width = if show-day-labels { t.axis-padding-bottom } else { 0pt }
  let month-label-height = if show-month-labels { t.axis-padding-bottom } else { 0pt }

  // Theme-aware empty cell styling
  let empty-fill = if t.background != none { _shade(t, 15%) } else { t.text-color-light.transparentize(80%) }
  let empty-stroke = t.stroke-thin + t.text-color-light.transparentize(40%)

  let legend-total-w = t.axis-padding-bottom + 5 * (cell-size + t.cell-gap) + t.label-offset + t.axis-padding-bottom  // Less + boxes + More
  let grid-w = n-weeks * cell-size
  // Wide enough for the legend and title too, so short ranges don't wrap them
  let title-w = if title != none { measure(text(size: t.title-size, weight: t.title-weight)[#title]).width } else { 0pt }
  let body-w = calc.max(day-label-width + grid-w, legend-total-w, title-w)
  let x0 = (body-w - day-label-width - grid-w) / 2  // centres the grid
  // Day/month labels shrink with small cells so rows don't collide
  let cal-label-size = calc.min(t.axis-label-size * 0.85, cell-size * 0.8)
  align(center, chart-container(body-w, month-label-height + 7 * cell-size, title, t, extra-height: t.axis-padding-left)[
    #box(width: body-w)[
      // Month labels along the top (x-axis) — skip labels that would overlap
      #if show-month-labels {
        let month-names = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
        let prev-month = ""
        let last-label-x = -100pt  // track last placed label x to prevent overlap
        let min-label-gap = t.axis-padding-bottom   // minimum horizontal gap between month labels
        for k in range(span) {
          let d = first + duration(days: k)
          let month-str = str(d.month())
          if month-str != prev-month {
            let week = calc.floor((start-dow + k) / 7)
            let label-x = x0 + day-label-width + week * cell-size
            let label = month-names.at(d.month() - 1)
            // Only place if far enough from previous label
            if label-x - last-label-x >= min-label-gap {
              place(left + top,
                dx: label-x,
                dy: 0pt,
                text(size: cal-label-size, fill: t.text-color)[#label])
              last-label-x = label-x
            }
            prev-month = month-str
          }
        }
      }

      // Day labels
      #if show-day-labels {
        for (i, day) in ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun").enumerate() {
          place(
            left + top,
            dx: x0,
            dy: month-label-height + i * cell-size + cell-size / 2,
            pin(text(size: cal-label-size, fill: t.text-color)[#day])
          )
        }
      }

      // Every slot starts as an empty cell (padding and dates without data)
      #for slot in range(n-weeks * 7) {
        place(
          left + top,
          dx: x0 + day-label-width + calc.floor(slot / 7) * cell-size,
          dy: month-label-height + calc.rem(slot, 7) * cell-size,
          rect(
            width: cell-size - t.cell-gap,
            height: cell-size - t.cell-gap,
            fill: empty-fill,
            stroke: empty-stroke,
            radius: t.cell-gap,
          )
        )
      }

      // Data cells — positioned by date
      #for (k, val) in by-offset {
        if val == 0 { continue }
        let slot = start-dow + int(k)
        let normalized = (val - min-val) / val-range
        place(
          left + top,
          dx: x0 + day-label-width + calc.floor(slot / 7) * cell-size,
          dy: month-label-height + calc.rem(slot, 7) * cell-size,
          rect(
            width: cell-size - t.cell-gap,
            height: cell-size - t.cell-gap,
            fill: heat-color(normalized, palette: palette, reverse: reverse),
            stroke: none,
            radius: t.cell-gap,
          )
        )
      }

      // Legend — centered under the grid
      #let legend-y = month-label-height + 7 * cell-size + t.legend-gap
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

      // Resolve every cell's position and color once, so the fills and the
      // value labels can be drawn in two separate passes below.
      #let cells = values.enumerate().map(((i, row-vals)) => {
        row-vals.enumerate().map(((j, val)) => (
          x: label-area + j * cell-size,
          y: label-area + i * cell-size,
          value: val,
          // Map correlation range [-1, +1] to normalized [0, 1] for heat-color
          color: heat-color((calc.max(-1, calc.min(1, val)) + 1) / 2, palette: palette, reverse: reverse),
        ))
      })

      // Cells and row labels
      #for (i, row-lbl) in labels.enumerate() {
        // Row label — right-aligned into label area
        place(
          left + top,
          dx: 0pt,
          dy: label-area + i * cell-size + cell-size / 2,
          box(width: label-area - t.label-offset, height: 0pt,
            align(right + horizon,
              text(size: t.axis-label-size, fill: t.text-color)[#row-lbl]))
        )

        // Cells
        for cell in cells.at(i) {
          place(
            left + top,
            dx: cell.x,
            dy: cell.y,
            rect(
              width: cell-size,
              height: cell-size,
              fill: cell.color,
              stroke: t.marker-stroke,
            )
          )
        }
      }

      // Value labels — drawn after every cell, so a value wider than its cell
      // keeps the tail that overflows into the neighbour.
      #if show-values {
        // Size off the longest value in the grid so every cell shares one size
        let widest = cells.flatten()
          .map(c => str(calc.round(c.value, digits: 2)).clusters().len())
          .fold(0, calc.max)
        let value-size = font-to-fit-width(cell-size - 4pt, t.axis-label-size, widest)
        for row-cells in cells {
          for cell in row-cells {
            place(
              left + top,
              dx: cell.x,
              dy: cell.y,
              box(width: cell-size, height: cell-size,
                align(center + horizon,
                  text(size: value-size, fill: contrast-text(cell.color))[
                    #calc.round(cell.value, digits: 2)]))
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
