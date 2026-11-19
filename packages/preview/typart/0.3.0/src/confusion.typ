// Confusion matrix: actual against predicted classes as a shaded grid (also a plain heatmap).
// Import with:  #import "confusion.typ": confusion
//
//   #confusion(((48, 2), (5, 45)), ([Genuine], [Impostor]))
#import "common.typ": _canvas, _fit, _lens, _on, _or, _put, _tallest, _theme, _txt

#let confusion(
  matrix,
  labels,
  x-title: [Predicted],
  y-title: [Actual],
  cell: 3em,
  normalize: false,
  fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("confusion", theme, style)
  if not (type(labels) == array and labels.len() > 0) { assert(false, message: "confusion: `labels` must be an array with one label per class, got "
    + repr(labels)) }
  let n = labels.len()
  assert(type(matrix) == array and matrix.len() == n and matrix.all(row => type(row) == array and row.len() == n
    and row.all(v => type(v) in (int, float))),
    message: "confusion: with " + str(n) + " label(s) the matrix must be " + str(n) + " row(s) of " + str(n)
      + " number(s), got " + repr(matrix))
  let (c, size, em) = _lens("confusion", cell: cell, text-size: text-size, em: 1em).values()
  let peak = calc.max(..matrix.flatten())
  // class labels share one size that fits a cell's width in at most two lines
  let small = _fit(labels, t.ink, size * t.small, c - 0.3 * em, 2.4 * size)
  let names = labels.map(l => _txt(l, t.ink, small, weight: auto))
  let (name-w, name-h) = (calc.max(..names.map(b => measure(b, width: 7 * em).width)), _tallest(names, c - 0.3 * em))
  let title(body) = if body != none { _txt(body, t.ink, size) }
  let room(body) = if body == none { 0pt } else { measure(title(body)).height + 0.6 * em }
  let (x0, y0) = (room(y-title) + name-w + 0.5 * em, room(x-title) + name-h + 0.4 * em)
  _canvas("confusion", t, width, area, x0 + n * c, y0 + n * c, {
    for (i, row) in matrix.enumerate() {
      let whole = if normalize { row.sum() } else { peak }
      for (j, v) in row.enumerate() {
        let share = if whole == 0 { 0 } else { v / whole }
        let fill = color.mix((_or(fill, t.palette.first()), share * 100%), (t.surface, 100% - share * 100%))
        place(top + left, dx: x0 + j * c, dy: y0 + i * c, box(width: c, height: c, fill: fill,
          stroke: 0.12 * em + t.surface, align(center + horizon,
            _txt(if normalize [#calc.round(share * 100)%] else [#v], _on(t, fill), size, weight: auto))))
      }
      place(top + left, dx: x0 - 0.5 * em - name-w, dy: y0 + i * c,
        box(width: name-w, height: c, align(right + horizon, names.at(i))))
      place(top + left, dx: x0 + i * c, dy: y0 - 0.4 * em - name-h,
        box(width: c, height: name-h, align(center + bottom, names.at(i))))
    }
    // the frame keeps the palest cells visible on the page
    place(top + left, dx: x0, dy: y0, rect(width: n * c, height: n * c, stroke: t.stroke + t.muted))
    if x-title != none { _put(x0 + n * c / 2, room(x-title) / 2 - 0.3 * em, title(x-title)) }
    if y-title != none {
      _put(room(y-title) / 2 - 0.3 * em, y0 + n * c / 2, rotate(-90deg, reflow: true, title(y-title)))
    }
  })
})
