// Pixels: a matrix drawn cell by cell: an image patch, a convolution kernel, an S-box,
// an array.  Import with:  #import "pixels.typ": pixels
//
//   #pixels(((1, 0, -1), (2, 0, -2), (1, 0, -1)))
#import "common.typ": _canvas, _lens, _on, _put, _theme, _txt

#let pixels(
  cells,
  cell: 2em,
  shade: false,
  values: true,
  mark: none,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("pixels", theme, style)
  if not (type(cells) == array and cells.len() > 0 and cells.all(row => type(row) == array and row.len() == cells.first().len()
    and row.len() > 0)) { assert(false, message: "pixels: expected an array of rows of equal length, got " + repr(cells)) }
  let numbers = cells.flatten().filter(v => type(v) in (int, float))
  assert(not shade or numbers.len() == cells.flatten().len(), message: "pixels: `shade` needs every cell to be a number")
  if not (mark == none or type(mark) == array and mark.len() == 2 and mark.flatten().len() == 4 and mark.flatten().all(v =>
    type(v) == int)) { assert(false, message: "pixels: `mark` is ((row, column), (row, column)), its first and last cell, got " + repr(mark)) }
  let (c, size, em) = _lens("pixels", cell: cell, text-size: text-size, em: 1em).values()
  let (rows, columns) = (cells.len(), cells.first().len())
  // shaded cells read as an image: the smallest value black, the largest white
  let (lo, hi) = if shade { (calc.min(..numbers), calc.max(..numbers)) } else { (0, 1) }
  let fill(v) = if shade { luma(if hi == lo { 50% } else { (v - lo) / (hi - lo) * 100% }) } else { t.panel }
  _canvas("pixels", t, width, area, columns * c, rows * c, {
    for (i, row) in cells.enumerate() {
      for (j, v) in row.enumerate() {
        place(top + left, dx: j * c, dy: i * c, box(width: c, height: c, fill: fill(v), stroke: t.stroke + t.line))
        if values { _put((j + 0.5) * c, (i + 0.5) * c, _txt([#v], _on(t, fill(v)), size * t.small, weight: auto), w: c) }
      }
    }
    if mark != none {
      let ((r0, c0), (r1, c1)) = mark
      place(top + left, dx: c0 * c, dy: r0 * c, box(width: (c1 - c0 + 1) * c, height: (r1 - r0 + 1) * c,
        stroke: t.thick + t.accent))
    }
  })
})
