// Venn diagram (2 or 3 overlapping circles).  Import with:  #import "venn.typ": venn
//
//   #venn((([Behavior], red), [Signal], [Security]))
#import "common.typ": _canvas, _dot, _fit, _items, _lens, _put, _theme, _txt

#let venn(
  items,
  radius: 5.5em,
  transparency: 45%,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("venn", theme, style)
  let items = _items("venn", items, t.palette, min: 2, max: 3)
  let (r, size, em) = _lens("venn", radius: radius, text-size: text-size, em: 1em).values()
  let three = items.len() > 2
  // centres and label anchors in units of the radius, from the top-left corner
  let (centers, labels) = if three {
    (((1.66, 1), (1, 2.12), (2.32, 2.12)), ((1.66, 0.27), (0.51, 2.57), (2.81, 2.57)))
  } else {
    (((1, 1), (2.2, 1)), ((0.6, 1), (2.6, 1)))
  }
  let (w, h) = if three { (r, r * 0.5) } else { (r * 1.05, r * 1.2) }
  let s = _fit(items.map(it => it.label), t.ink, size, w, h)
  _canvas("venn", t, width, area, r * (if three { 3.32 } else { 3.2 }), r * (if three { 3.12 } else { 2 }), {
    for (it, (x, y)) in items.zip(centers) {
      _dot(x * r, y * r, r, fill: it.fill.transparentize(transparency), stroke: it.fill + 0.12 * em)
    }
    for (it, (x, y)) in items.zip(labels) { _put(x * r, y * r, _txt(it.label, t.ink, s), w: w) }
  })
})
