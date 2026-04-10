// parliament.typ - Semicircular parliament/seat chart
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container

/// Renders a parliament (hemicycle) chart — a semicircle of dots showing seat distribution.
///
/// Each dot represents one seat. Parties fill dots in order along concentric
/// semicircular rows from inner to outer radius, left to right.
///
/// - data (dictionary, array): Label-value pairs where values are seat counts
/// - size (length): Width of the chart area
/// - dot-size (length): Diameter of each seat dot
/// - gap (length): Gap between dots
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show party legend below the chart
/// - theme (none, dictionary): Theme overrides
/// -> content
#let parliament-chart(
  data,
  size: 250pt,
  dot-size: 4pt,
  gap: 1pt,
  title: none,
  show-legend: true,
  theme: none,
) = {
  validate-simple-data(data, "parliament-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let total = values.sum()
  if total == 0 {
    return
  }

  let n-parties = values.len()
  let radius = size / 2
  let dot-r = dot-size / 2
  let spacing = dot-size + gap

  // Determine rows and seat distribution.
  // We start from an inner radius and add rows outward until we have enough seats.
  // Each row at radius r fits floor(pi * r / spacing) dots along the semicircle.
  let min-inner = spacing * 2
  let max-outer = radius - dot-r

  // Try increasing row count until total capacity >= total seats
  let n-rows = 1
  let row-radii = ()
  let row-seats = ()

  // Binary-search style: start with 1 row, increase until enough
  let found = false
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

  // Build flat list of dot positions
  let cx = radius
  let cy = radius
  let dots = ()

  for (ri, r) in row-radii.enumerate() {
    let n = row-seats.at(ri)
    if n <= 0 { continue }
    for di in range(n) {
      let angle = if n == 1 { 90.0 } else { 180.0 * di / (n - 1) }
      let x = cx + r * calc.cos(angle * 1deg)
      let y = cy - r * calc.sin(angle * 1deg)
      dots.push((x, y))
    }
  }

  // Assign party colors to dots (fill in order)
  let dot-colors = ()
  let seat-idx = 0
  for (pi, count) in values.enumerate() {
    for _ in range(count) {
      if seat-idx < dots.len() {
        dot-colors.push(get-color(t, pi))
      }
      seat-idx = seat-idx + 1
    }
  }

  // Calculate legend height
  let legend-height = if show-legend { 12pt * n-parties + 20pt } else { 0pt }
  let chart-height = radius + dot-r
  let total-height = chart-height + legend-height

  let legend-width = 140pt
  let total-width = size + (if show-legend { 20pt + legend-width } else { 0pt })

  chart-container(total-width, total-height, title, t, extra-height: 40pt)[
    #grid(
      columns: if show-legend { (size, legend-width) } else { (size,) },
      column-gutter: 20pt,

      // Hemicycle
      box(width: size, height: chart-height)[
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
      ],

      // Legend
      if show-legend {
        box(width: legend-width)[
          #v(10pt)
          #for (i, lbl) in labels.enumerate() {
            let count = values.at(i)
            if count > 0 {
              box(inset: (x: 0pt, y: 2pt))[
                #box(width: t.legend-swatch-size, height: t.legend-swatch-size, fill: get-color(t, i), baseline: 2pt, radius: 2pt)
                #h(6pt)
                #text(size: t.legend-size, fill: t.text-color)[#lbl (#count)]
              ]
              linebreak()
            }
          }
        ]
      }
    )
  ]
}
