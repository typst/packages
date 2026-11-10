// heatmap.typ - Heatmap/matrix charts
#import "../theme.typ": _resolve-ctx, _phi, _shade
#import "../util.typ": heat-color, nonzero, contrast-text
#import "../validate.typ": validate-heatmap-data, validate-calendar-data, validate-correlation-data
#import "../primitives/container.typ": chart-container, container-inset
#import "../primitives/layout.typ": text-width, text-height
#import "../primitives/matrix.typ": matrix-layout, cell-label-size
#import "../primitives/legend.typ": draw-gradient-legend, gradient-legend-width

// A labelled grid of colour-coded cells with a gradient key: the body shared
// by `heatmap` and `correlation-matrix`. Label gutters, cell size and the
// container's height all come from measurement, so the chart is exactly as big
// as its content: no dead bands, no label wider than its cell.
//
// - norm: function mapping a cell value to 0..1 for the palette
// - lo, hi: the values the key's ends stand for
// - digits: decimals printed inside the cells
#let _matrix-chart(
  rows, cols, values, avail, t,
  cell-size, palette, reverse, show-values, show-legend,
  norm, lo, hi, digits,
  title, subtitle, radius,
) = {
  let n-rows = rows.len()
  let n-cols = cols.len()
  let ci = t.at("container-inset", default: container-inset)

  // The key: a gradient bar with its end labels, as wide as those labels need
  let key-bar-w = 15pt
  let key-w = if show-legend { gradient-legend-width(lo, hi, t, bar-width: key-bar-w) + t.legend-gap } else { 0pt }

  // Cells shrink to the room there is: row gutter (measured) + key + insets
  let avail-w = if type(avail.width) == length and avail.width > 0pt { avail.width } else { none }
  let probe = matrix-layout(rows, cols, cell-size, cell-size, t)
  let cell = if avail-w != none and probe.row-w + n-cols * cell-size + key-w + 2 * ci > avail-w {
    calc.max(2pt, (avail-w - probe.row-w - key-w - 2 * ci) / n-cols)
  } else { cell-size }
  let lay = matrix-layout(rows, cols, cell, cell, t)

  let grid-w = n-cols * cell
  let grid-h = n-rows * cell
  let body-w = lay.gx + calc.max(grid-w + key-w, grid-w + lay.overhang)
  let body-h = lay.gy + grid-h

  // The key sits against the grid's vertical middle; its end labels hang
  // outside the bar, so keep the bar clear of the grid's top and bottom
  let key-h = calc.max(20pt, calc.min(grid-h * 0.8, grid-h - 2 * (t.axis-label-size + 4pt)))
  let key-y = lay.gy + (grid-h - key-h) / 2

  let value-size = if show-values {
    cell-label-size(values.flatten().map(v => str(calc.round(v, digits: digits))), cell, cell, t)
  } else { none }

  chart-container(body-w, body-h, title, t, subtitle: subtitle, radius: radius)[
    #box(width: body-w, height: body-h)[
      #lay.labels

      // Fills first, then the values, so a value never loses a tail to the
      // next cell's fill
      #let fills = values.map(row => row.map(v => heat-color(norm(v), palette: palette, reverse: reverse)))
      #for (i, row-fills) in fills.enumerate() {
        for (j, fill) in row-fills.enumerate() {
          place(left + top, dx: lay.gx + j * cell, dy: lay.gy + i * cell,
            rect(width: cell, height: cell, fill: fill, stroke: t.marker-stroke))
        }
      }
      #if value-size != none {
        for (i, row) in values.enumerate() {
          for (j, v) in row.enumerate() {
            place(left + top, dx: lay.gx + j * cell, dy: lay.gy + i * cell,
              box(width: cell, height: cell, align(center + horizon,
                text(size: value-size, fill: contrast-text(fills.at(i).at(j), theme: t))[#calc.round(v, digits: digits)])))
          }
        }
      }

      #if show-legend {
        place(left + top, dx: lay.gx + grid-w + t.legend-gap, dy: key-y,
          draw-gradient-legend(lo, hi, palette, t, bar-width: key-bar-w, bar-height: key-h, reverse: reverse))
      }
    ]
  ]
}

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

  let all-vals = data.values.flatten()
  let min-val = calc.min(..all-vals)
  let max-val = calc.max(..all-vals)
  let val-range = nonzero(max-val - min-val)

  _matrix-chart(
    data.rows, data.cols, data.values, avail, t,
    cell-size, palette, reverse, show-values, show-legend,
    v => (v - min-val) / val-range, min-val, max-val, 1,
    title, subtitle, radius,
  )
  })
}

/// Renders a calendar-style heatmap grid (similar to a GitHub contribution graph).
///
/// Values run from a pale tint to a dark one along an ordered ramp, so more is
/// always darker; days without data stay a flat pale grey. The key at the
/// bottom uses cells of the same size as the data cells.
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

  // Colour scale over the non-zero values; the ramp starts a little above its
  // palest end so the lowest day is still distinct from a day with no data
  let non-zero-vals = values.filter(v => v > 0)
  let min-val = if non-zero-vals.len() > 0 { calc.min(..non-zero-vals) } else { 0 }
  let max-val = calc.max(..values)
  let val-range = nonzero(max-val - min-val)
  let ramp(x) = heat-color(0.18 + 0.82 * x, palette: palette, reverse: reverse)

  // Starting day-of-week offset (0=Mon..6=Sun); grid slots rounded up to full weeks
  let start-dow = first.weekday() - 1
  let n-weeks = calc.ceil((start-dow + span) / 7)

  let cell = cell-size
  let gap = calc.min(t.cell-gap, cell * 0.15)
  let inner = cell - gap
  let radius = calc.min(2pt, inner * 0.25)
  let empty-fill = if t.background != none { _shade(t, 15%) } else { t.text-color-light.transparentize(80%) }

  // Day gutter measured from the day names; month band from the label height
  let day-names = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
  let month-names = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  let dl = matrix-layout(day-names, (), cell, cell, t)
  let lbl-size = dl.size
  let day-w = if show-day-labels { dl.row-w } else { 0pt }
  let month-h = if show-month-labels { text-height("Mg", lbl-size) + t.label-offset + 1pt } else { 0pt }

  let grid-w = n-weeks * cell
  let grid-h = 7 * cell
  let key-gap = t.legend-gap
  let key-labels = (text-width("Less", lbl-size), text-width("More", lbl-size))
  let key-w = key-labels.at(0) + key-labels.at(1) + 5 * cell + 2 * t.label-offset
  let title-w = if title != none { text-width(title, t.title-size, weight: t.title-weight) } else { 0pt }
  // Wide enough for the key and title too, so short ranges don't wrap them
  let body-w = calc.max(day-w + grid-w, key-w, title-w)
  let x0 = (body-w - day-w - grid-w) / 2  // centres the grid
  let body-h = month-h + grid-h + key-gap + inner

  align(center, chart-container(body-w, body-h, title, t)[
    #box(width: body-w, height: body-h)[
      // Month names above the week that starts them, skipping any that would
      // touch the previous one
      #if show-month-labels {
        let prev-end = -100pt
        let prev-month = 0
        for k in range(span) {
          let d = first + duration(days: k)
          if d.month() == prev-month { continue }
          prev-month = d.month()
          let label-x = x0 + day-w + calc.floor((start-dow + k) / 7) * cell
          let name = month-names.at(d.month() - 1)
          let w = text-width(name, lbl-size)
          if label-x >= prev-end + 4pt {
            place(left + top, dx: label-x, dy: 0pt, text(size: lbl-size, fill: t.text-color)[#name])
            prev-end = label-x + w
          }
        }
      }

      #if show-day-labels { place(left + top, dx: x0, dy: month-h, dl.labels) }

      // Every slot starts as an empty cell (padding and dates without data)
      #for slot in range(n-weeks * 7) {
        place(left + top,
          dx: x0 + day-w + calc.floor(slot / 7) * cell, dy: month-h + calc.rem(slot, 7) * cell,
          rect(width: inner, height: inner, fill: empty-fill, stroke: none, radius: radius))
      }

      // Data cells, positioned by date
      #for (k, val) in by-offset {
        if val == 0 { continue }
        let slot = start-dow + int(k)
        place(left + top,
          dx: x0 + day-w + calc.floor(slot / 7) * cell, dy: month-h + calc.rem(slot, 7) * cell,
          rect(width: inner, height: inner, fill: ramp((val - min-val) / val-range), stroke: none, radius: radius))
      }

      // Key: Less, five cells of the data cells' size, More; centred under the grid
      #let key-y = month-h + grid-h + key-gap
      #let key-x = (body-w - key-w) / 2
      #place(left + top, dx: key-x, dy: key-y + inner / 2,
        box(height: 0pt, align(horizon, text(size: lbl-size, fill: t.text-color)[Less])))
      #for i in range(5) {
        place(left + top, dx: key-x + key-labels.at(0) + t.label-offset + i * cell, dy: key-y,
          rect(width: inner, height: inner, fill: ramp(i / 4), stroke: none, radius: radius))
      }
      #place(left + top, dx: key-x + key-labels.at(0) + t.label-offset + 5 * cell + t.label-offset - gap, dy: key-y + inner / 2,
        box(height: 0pt, align(horizon, text(size: lbl-size, fill: t.text-color)[More])))
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

  _matrix-chart(
    data.labels, data.labels, data.values, avail, t,
    cell-size, palette, reverse, show-values, show-legend,
    // Correlation range [-1, +1] maps onto the palette's 0..1
    v => (calc.max(-1, calc.min(1, v)) + 1) / 2, -1, 1, 2,
    title, none, 0pt,
  )
  })
}
