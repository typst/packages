// Reusable "card" table — rounded cells with white gaps, lavender header,
// alternating pink rows, centred text. Import with:  #import "table.typ": card-table
//
//   #card-table(
//     ("Study", "Behavior used", "Approach", "Environment", "Dataset", "Indicators"),
//     (
//       ([Guo et al. (2023)], [Arm movements...], [Propose two...], [Mobile devices], [Homemade], [CDF, ...]),
//       ([Gurunathan (2024)], [PPG], [Exhaustive...], [Not specified], [PUT Vein], [FRR, ...]),
//     ),
//   )
//
// Every cell in a row gets the same height (= tallest cell), so the cards line
// up. `weights` sets relative column widths (default: all equal).

// Uso: #card-row((celda1, celda2, ...), fill: red, text-fill: white)
// Los parámetros `fill` y `text-fill` son opcionales.
#let card-row(cells, fill: none, text-fill: none) = (
  _card-row: true,
  cells: cells,
  fill: fill,
  text-fill: text-fill,
)

#let card-table(
  headers,
  rows,
  weights: none,
  header-fill: rgb("#aab4f7"),
  row-fills: (rgb("#f5e6e2"), rgb("#ecd0d2")),
  text-fill: rgb("#1f1f3a"),
  header-text-fill: auto,
  size: 18pt,
  radius: 12pt,
  gutter: 8pt,
  inset: 12pt,
) = layout(area => {
  let n = headers.len()
  let w = if weights == none { range(n).map(_ => 1) } else { weights }
  let total = w.sum()
  let avail = area.width - gutter * (n - 1)
  let colw = w.map(x => avail * x / total)

  let head-c = if header-text-fill == auto { text-fill } else { header-text-fill }
  set text(size: size, fill: text-fill)
  set par(justify: false, leading: 0.5em)

  // Helper: extrae cells, fill y text-fill de una fila (soporta card-row o tupla)
  let parse-row(r, i) = {
    if type(r) == dictionary and r.at("_card-row", default: false) == true {
      let fill = if r.fill != none { r.fill } else { row-fills.at(calc.rem(i, row-fills.len())) }
      let tcol = if r.text-fill != none { r.text-fill } else { text-fill }
      (cells: r.cells, fill: fill, tcol: tcol)
    } else {
      (cells: r, fill: row-fills.at(calc.rem(i, row-fills.len())), tcol: text-fill)
    }
  }

  let row-block(cells, fill, tcol, bold: false) = context {
    let hs = cells.enumerate().map(((i, c)) => measure(box(width: colw.at(i) - 2 * inset, c)).height)
    let row-h = calc.max(..hs) + 2 * inset

    stack(dir: ltr, spacing: gutter, ..cells
      .enumerate()
      .map(((i, c)) => box(
        width: colw.at(i),
        height: row-h,
        fill: fill,
        radius: radius,
        inset: inset,
        align(
          center + horizon,
          text(fill: tcol, if bold { strong(c) } else { c }),
        ),
      )))
  }

  // Procesamos las filas con parse-row
  let parsed-rows = rows
    .enumerate()
    .map(((i, r)) => {
      let p = parse-row(r, i)
      row-block(p.cells, p.fill, p.tcol)
    })

  stack(dir: ttb, spacing: gutter, row-block(headers, header-fill, head-c, bold: true), ..parsed-rows)
})
