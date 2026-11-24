// parliament.typ - Semicircular parliament/seat chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend
#import "../primitives/radial.typ": legend-room, side-legend, split-width
#import "../primitives/layout.typ": resolve-size

/// Renders a parliament (hemicycle) chart — a semicircle of dots showing seat distribution.
///
/// Each dot represents one seat. By default the parties take the seats in
/// angular blocks: the first party gets a wedge at the left end of the
/// hemicycle, the next one the wedge after it, and so on over the top to the
/// right end, so a party reads as one block across all rows. Every row keeps
/// its seat count either way.
///
/// - data (dictionary, array): Label-value pairs where values are seat counts
/// - size (length): Width of the chart area
/// - dot-size (length): Diameter of each seat dot
/// - gap (length): Gap between dots
/// - fill-order (str): How parties take the seats. `"angular"` (default): one wedge per party, left to right. `"rows"`: along the concentric rows from the innermost to the outermost (the layout before wedges became the default), which gives one band per party
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show the party legend (where the theme's `legend-position` puts it)
/// - theme (none, dictionary): Theme overrides
/// -> content
#let parliament-chart(
  data,
  size: 250pt,
  dot-size: 4pt,
  gap: 1pt,
  fill-order: "angular",
  title: none,
  show-legend: true,
  theme: none,
) = context {
  assert(fill-order in ("angular", "rows"),
    message: "parliament-chart: fill-order must be \"angular\" or \"rows\", got " + repr(fill-order))
  layout(avail => {
  validate-simple-data(data, "parliament-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let total = values.sum()
  if total == 0 {
    return
  }

  // Legend where the theme puts it: beside the hemicycle (which then shrinks
  // to leave room), or under/over it
  let entries = labels.enumerate().filter(((i, _)) => values.at(i) > 0)
    .map(((i, lbl)) => (name: [#lbl (#values.at(i))], color: get-color(t, i)))
  let lp = t.legend-position
  let legend-on = show-legend and lp != "none" and entries.len() > 0
  let beside = lp == "left" or lp == "right"
  // (many parties flow into columns rather than one column far taller than the hemicycle)
  let side-lg = if legend-on and beside {
    side-legend(entries, t, position: lp, max-height: size * 0.65, max-total: legend-room(size, avail.width, t, margin: 0pt))
  } else { none }
  let size = if side-lg != none { split-width(size, 10pt + side-lg.width, avail.width, t).first() } else { size }

  let radius = size / 2
  let dot-r = dot-size / 2
  let spacing = dot-size + gap

  // Determine rows and seat distribution.
  // We start from an inner radius and add rows outward until we have enough seats.
  // Each row at radius r fits floor(pi * r / spacing) dots along the semicircle.
  // If even the tightest packing can't seat everyone, shrink dots and gaps
  // together and try again rather than silently dropping seats.
  let n-rows = 1
  let row-radii = ()
  let row-seats = ()
  let found = false
  while not found and spacing > 0.5pt {
    let min-inner = spacing * 2
    let max-outer = radius - dot-r

    // Start with 1 row, increase until capacity >= total seats
    for try-rows in range(1, 100) {
      let step = (max-outer - min-inner) / calc.max(try-rows, 1)
      if step < spacing {
        // Rows too close, use fewer
        break
      }
      let radii = ()
      let seats = ()
      let cap = 0
      for ri in range(try-rows) {
        let r = min-inner + ri * step + step / 2
        let n = calc.max(1, int(calc.pi * r / spacing))
        radii.push(r)
        seats.push(n)
        cap = cap + n
      }
      row-radii = radii
      row-seats = seats
      n-rows = try-rows
      if cap >= total {
        found = true
        break
      }
    }
    if not found {
      dot-r *= 0.9
      spacing *= 0.9
    }
  }

  // If capacity exceeds total, scale down seats per row proportionally
  let capacity = row-seats.sum()
  if capacity > total {
    // Reduce seats proportionally, keeping total exact
    let new-seats = ()
    let assigned = 0
    for (i, s) in row-seats.enumerate() {
      if i == row-seats.len() - 1 {
        new-seats.push(total - assigned)
      } else {
        let n = calc.max(1, int(calc.round(s / capacity * total)))
        new-seats.push(n)
        assigned = assigned + n
      }
    }
    row-seats = new-seats
  }

  // Build flat list of seats: position, angle (0 = right end, 180 = left end) and row
  let cx = radius
  let cy = radius
  let seats = ()

  for (ri, r) in row-radii.enumerate() {
    let n = row-seats.at(ri)
    if n <= 0 { continue }
    for di in range(n) {
      let angle = if n == 1 { 90.0 } else { 180.0 * di / (n - 1) }
      let x = cx + r * calc.cos(angle * 1deg)
      let y = cy - r * calc.sin(angle * 1deg)
      seats.push((x: x, y: y, angle: calc.round(angle, digits: 6), row: ri))
    }
  }

  // The order seats are handed out in. "rows" is the layout order (row by row,
  // inner to outer); "angular" sweeps the hemicycle from the left end over the
  // top to the right end, so each party gets one wedge (ties, seats at the same
  // angle in different rows, go inner to outer).
  if fill-order == "angular" {
    seats = seats.sorted(key: s => (-s.angle, s.row))
  }

  // Assign party colors to seats (fill in order)
  let dot-colors = ()
  let seat-idx = 0
  for (pi, count) in values.enumerate() {
    for _ in range(count) {
      if seat-idx < seats.len() {
        dot-colors.push(get-color(t, pi))
      }
      seat-idx = seat-idx + 1
    }
  }
  let dots = seats.map(s => (s.x, s.y))

  let chart-height = radius + dot-r

  let lg = if side-lg != none {
    side-lg
  } else if legend-on {
    (legend: draw-legend(entries, t), width: auto, theme: t)
  } else { (legend: none, width: 0pt, theme: t) }

  align(center, chart-container(size, chart-height, title, lg.theme,
    legend: lg.legend, legend-width: lg.width)[
    #box(width: size, height: chart-height)[
      #for (i, pos) in dots.enumerate() {
        if i < dot-colors.len() {
          place(
            left + top,
            dx: pos.at(0) - dot-r,
            dy: pos.at(1) - dot-r,
            circle(radius: dot-r, fill: dot-colors.at(i), stroke: none)
          )
        }
      }
    ]
  ])
  })
}
