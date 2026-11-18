// Checks: a comparison matrix of methods against criteria, with check and cross marks.
// Import with:  #import "checks.typ": checks
//
//   #checks(([Method], [Open], [Real time]), (([Ours], true, true), ([Baseline], true, false)))
#import "common.typ": _fluid, _lens, _or, _theme, _txt

#let checks(
  columns,
  rows,
  gap: 0.5em,
  fills: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("checks", theme, style)
  if not (type(columns) == array and columns.len() >= 2) { assert(false, message: "checks: `columns` must be an array of at least 2 headers, got "
    + repr(columns)) }
  if not (type(rows) == array) { assert(false, message: "checks: `rows` must be an array of rows, got " + repr(rows)) }
  for (i, row) in rows.enumerate() {
    if not (type(row) == array and row.len() == columns.len()) { assert(false, message: "checks: row " + str(i + 1) + " must have "
      + str(columns.len()) + " cells (its label, then one per column), got " + repr(row)) }
  }
  let (gap, size, em) = _lens("checks", gap: gap, text-size: text-size, em: 1em).values()
  let total = _fluid("checks", width, area)
  // a mark is one or more strokes through points given as fractions of its square
  let side = 0.8 * size
  let mark(paint, ..strokes) = box(width: side, height: side, for pts in strokes.pos() {
    place(curve(stroke: (paint: paint, thickness: 0.15 * size, cap: "round", join: "round"),
      curve.move(pts.first().map(v => v * side)), ..pts.slice(1).map(p => curve.line(p.map(v => v * side)))))
  })
  let fills = _or(fills, (t.accent, t.palette.at(3)))
  if not (type(fills) == array and fills.len() == 2) { assert(false, message: "checks: `fills` is auto or the colours of the check and "
    + "the cross, got " + repr(fills)) }
  let cell(v) = if v == true { mark(fills.at(0), ((0.08, 0.55), (0.38, 0.85), (0.92, 0.18))) } else if v == false {
    mark(fills.at(1), ((0.15, 0.15), (0.85, 0.85)), ((0.85, 0.15), (0.15, 0.85)))
  } else if v == none { mark(t.muted, ((0.2, 0.5), (0.8, 0.5))) } else { _txt(v, t.ink, size, weight: auto) }
  let names = rows.map(row => _txt(row.first(), t.ink, size, weight: auto))
  let heads = columns.map(c => _txt(c, t.ink, size))
  // the label column is as wide as its longest cell, at most 40% of the width
  let name-w = calc.min(0.4 * total, calc.max(..(heads.first(), ..names).map(b => measure(b).width)) + em)
  let rule(weight) = grid.hline(stroke: t.stroke * weight + t.ink)
  box(width: total, grid(
    columns: (name-w,) + (1fr,) * (columns.len() - 1),
    align: (x, _) => if x == 0 { left + horizon } else { center + horizon },
    inset: (x: 0.5 * em, y: gap),
    rule(1.6), ..heads, rule(0.9),
    ..rows.zip(names).map(((row, name)) => (name, ..row.slice(1).map(cell))).flatten(),
    rule(1.6)))
})
