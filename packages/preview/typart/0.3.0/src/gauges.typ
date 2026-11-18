// Gauges: progress rings with a big percentage and a caption.
// Import with:  #import "gauges.typ": gauges
//
//   #gauges(((72, [Recall]), (91, [Precision], red), (45, [Coverage])))
#import "common.typ": _arc, _canvas, _dot, _items, _lens, _polar, _put, _tallest, _theme, _txt

#let gauges(
  items,
  radius: 3em,
  thickness: 0.6em,
  gap: 0.8em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("gauges", theme, style)
  let items = _items("gauges", items, t.palette, fields: ("value", "label"), numbers: ("value",))
  for (i, it) in items.enumerate() {
    if not (type(it.value) in (int, float)) { assert(false, message: "gauges: the value of item " + str(i + 1)
      + " must be a number from 0 to 100, got " + repr(it.value)) }
  }
  let (r, th, gap, size, em) = _lens("gauges", radius: radius, thickness: thickness, gap: gap, text-size: text-size,
    em: 1em).values()
  let ring(it) = box(width: 2 * r, height: 2 * r, {
    _dot(r, r, r - th / 2, stroke: t.panel + th)
    // clockwise from twelve o'clock; a full ring needs no arc maths
    if it.value >= 100 { _dot(r, r, r - th / 2, stroke: it.fill + th) } else if it.value > 0 {
      let a1 = 90deg - it.value * 3.6deg
      place(top + left, curve(stroke: (paint: it.fill, thickness: th, cap: "round"),
        curve.move(_polar(r, r, r - th / 2, 90deg)), .._arc(r, r, r - th / 2, 90deg, a1)))
    }
    _put(r, r, _txt([#it.value%], t.ink, size * t.large), w: 2 * r - 2 * th)
  })
  let labels = items.map(it => box(width: 2 * r, _txt(it.label, t.ink, size * t.small, weight: auto)))
  let n = items.len()
  let row-gap = 0.5 * em
  _canvas("gauges", t, width, area, n * 2 * r + (n - 1) * gap, 2 * r + row-gap + _tallest(labels, 2 * r),
    grid(columns: n, column-gutter: gap, row-gutter: row-gap, align: center + top, ..items.map(ring), ..labels))
})
