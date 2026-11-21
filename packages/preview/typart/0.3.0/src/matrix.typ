// 2×2 matrix with optional axis labels.  Import with:  #import "matrix.typ": matrix
//
//   #matrix(([TL], [TR], [BL], [BR]), x-axis: ([Low], [High]), y-axis: ([High], [Low]))
#import "common.typ": _canvas, _items, _lens, _on, _tallest, _theme, _txt

#let matrix(
  cells,
  x-axis: none,
  y-axis: none,
  item-width: 9em,
  item-height: 6em,
  gap: 0.5em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("matrix", theme, style)
  let cells = _items("matrix", cells, t.palette, min: 4, max: 4)
  for (name, axis) in (("x-axis", x-axis), ("y-axis", y-axis)) {
    assert(axis == none or type(axis) == array and axis.len() == 2,
      message: "matrix: `" + name + "` must be none or two labels, got " + repr(axis))
  }
  let (cw, ch, gap, size, em) = _lens("matrix", item-width: item-width, item-height: item-height, gap: gap,
    text-size: text-size, em: 1em).values()
  let labels = cells.map(it => _txt(it.label, _on(t, it.fill), size))
  let ch = calc.max(ch, _tallest(labels, cw - 1.3 * em) + 1.3 * em)
  let ax(c, w) = box(width: w, align(center, _txt(c, t.ink, size)))
  let core = grid(columns: (cw, cw), gutter: gap, ..cells.zip(labels).map(((it, label)) => box(
    width: cw, height: ch, fill: it.fill, radius: t.corner-radius, inset: (x: 0.65 * em),
    align(center + horizon, label))))
  let drawing = grid(columns: if y-axis == none { 1 } else { 2 }, gutter: 0.4 * em,
    ..if y-axis != none {
      (grid(row-gutter: gap, ..y-axis.map(c => box(height: ch, align(horizon, rotate(-90deg, reflow: true, ax(c, ch)))))),)
    },
    core,
    ..if x-axis != none {
      (..if y-axis != none { ([],) }, grid(columns: (cw, cw), column-gutter: gap, ..x-axis.map(c => ax(c, cw))))
    })
  // measuring a grid that is also laid out costs a second layout iteration, so the
  // size is added up from the cells and the axis labels
  let axis-room(axis, w) = if axis == none { 0pt } else { 0.4 * em + calc.max(..axis.map(c => measure(ax(c, w)).height)) }
  _canvas("matrix", t, width, area, axis-room(y-axis, ch) + 2 * cw + gap, 2 * ch + gap + axis-room(x-axis, cw), drawing)
})
