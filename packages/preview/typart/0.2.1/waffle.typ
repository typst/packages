// Waffle: a grid of squares showing shares of a whole, with a legend.
// Import with:  #import "waffle.typ": waffle
//
//   #waffle(([Responders], 62), ([Partial], 23), ([No change], 15))
#import "common.typ": _col, _txt, palette

#let waffle(
  ..parts,
  total: 100,
  columns: 10,
  cell: 0.55cm,
  gap: 3pt,
  rest: luma(232),
  text-fill: rgb("#1f1f3a"),
  size: 14pt,
) = {
  let parts = parts.pos()
  // cell i takes the colour of the part whose running total first exceeds i
  let ends = parts.map(p => p.at(1))
  let cum = range(ends.len()).map(k => ends.slice(0, k + 1).sum())
  let colour(i) = {
    let k = cum.position(c => i < c)
    if k == none { rest } else { _col(parts.at(k), k, at: 2) }
  }
  stack(dir: ttb, spacing: 12pt,
    // cells are placed directly: no grid track sizing for a fixed lattice
    box(width: columns * (cell + gap) - gap, height: calc.ceil(total / columns) * (cell + gap) - gap,
      for i in range(total) {
        place(top + left, dx: calc.rem(i, columns) * (cell + gap), dy: calc.quo(i, columns) * (cell + gap),
          box(width: cell, height: cell, radius: cell / 5, fill: colour(i)))
      }),
    grid(columns: 2, column-gutter: 6pt, row-gutter: 6pt, align: horizon,
      ..parts.enumerate().map(((k, p)) => (
        box(width: size * 0.8, height: size * 0.8, radius: size / 6, fill: _col(p, k, at: 2)),
        _txt([#p.at(0) · #p.at(1)], text-fill, size, weight: auto),
      )).flatten()))
}
