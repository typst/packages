// Hierarchy diagram: one root over a single row of children.
// Import with:  #import "hierarchy.typ": hierarchy
//
//   #hierarchy([CEO], (([Eng], red), [Sales], [HR]))
#import "common.typ": _canvas, _items, _lens, _node, _on, _or, _pair, _tallest, _theme, _txt

#let hierarchy(
  root,
  children,
  item-width: 7em,
  item-height: 2.8em,
  gap: (1.2em, 2.4em),
  root-fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("hierarchy", theme, style)
  // the root takes the first colour; the children cycle through the rest
  let children = _items("hierarchy", children, t.palette.slice(1) + t.palette.slice(0, 1))
  let (w, h, size, em) = _lens("hierarchy", item-width: item-width, item-height: item-height, text-size: text-size,
    em: 1em).values()
  let (gap-x, gap-y) = _pair("hierarchy", "gap", gap)
  let n = children.len()
  let fills = (_or(root-fill, t.palette.first()), ..children.map(it => it.fill))
  let labels = (root, ..children.map(it => it.label)).zip(fills).map(((l, fill)) => _txt(l, _on(t, fill), size,
    weight: auto))
  let h = calc.max(h, _tallest(labels, w - 0.7 * em) + 1.3 * em)
  let row = n * w + (n - 1) * gap-x
  let span = calc.max(w, row)
  let cx = i => (span - row) / 2 + w / 2 + i * (w + gap-x)
  let cy = h * 1.5 + gap-y
  let mid = h + gap-y / 2
  let node(x, y, lab, fill) = _node(shadow: t.shadow, x, y, w, h, lab, fill: fill, radius: t.corner-radius, inset: 0.35 * em)
  _canvas("hierarchy", t, width, area, span, 2 * h + gap-y, {
    for i in range(n) {
      place(top + left, curve(stroke: (paint: t.accent, thickness: t.thick, join: "round"),
        curve.move((span / 2, h)), curve.line((span / 2, mid)), curve.line((cx(i), mid)),
        curve.line((cx(i), cy - h / 2))))
    }
    node(span / 2, h / 2, labels.first(), fills.first())
    for i in range(n) { node(cx(i), cy, labels.at(i + 1), fills.at(i + 1)) }
  })
})
