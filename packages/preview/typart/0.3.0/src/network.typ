// Network: a fully connected neural network, one column of neurons per layer.
// Import with:  #import "network.typ": network
//
//   #network(((3, [Input]), (5, [Hidden]), (2, [Output])))
#import "common.typ": _canvas, _dot, _items, _lens, _pair, _tallest, _theme, _txt

#let network(
  layers,
  node-radius: 0.7em,
  gap: (5em, 0.6em),
  max-nodes: 6,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("network", theme, style)
  let layers = _items("network", layers, t.palette, fields: ("count", "label"), numbers: ("count",))
  for (i, l) in layers.enumerate() {
    if not (type(l.count) == int and l.count > 0) { assert(false, message: "network: layer " + str(i + 1)
      + " needs a positive number of neurons, got " + repr(l.count)) }
  }
  if not (type(max-nodes) == int and max-nodes >= 2) { assert(false, message: "network: `max-nodes` must be an integer of at least 2, got "
    + repr(max-nodes)) }
  let (r, size, em) = _lens("network", node-radius: node-radius, text-size: text-size, em: 1em).values()
  let (gx, gy) = _pair("network", "gap", gap)
  let pitch = 2 * r + gy
  // a layer over max-nodes keeps max-nodes neurons around a middle slot for the ellipsis
  let slots(l) = if l.count > max-nodes { max-nodes + 1 } else { l.count }
  let height = calc.max(..layers.map(slots)) * pitch - gy
  let labels = layers.map(l => if l.label != none { _txt(l.label, t.ink, size * t.small, weight: auto) })
  let label-w = 2 * r + gx - 0.6 * em
  // the first and last labels may reach past the outer neurons
  let reach(label) = if label == none { 0pt } else { calc.max(0pt, measure(label, width: label-w).width / 2 - r) }
  let x(i) = reach(labels.first()) + r + i * (2 * r + gx)
  let columns = layers.enumerate().map(((i, l)) => {
    let skip = if l.count > max-nodes { calc.quo(slots(l), 2) }
    let top = (height - slots(l) * pitch + gy) / 2 + r
    (fill: l.fill, pts: range(slots(l)).filter(k => k != skip).map(k => (x(i), top + k * pitch)),
      more: if skip != none { top + skip * pitch })
  })
  let label-h = _tallest(labels.filter(l => l != none), label-w)
  _canvas("network", t, width, area, x(layers.len() - 1) + r + reach(labels.last()),
    height + (if label-h > 0pt { 0.6 * em + label-h } else { 0pt }), {
    // one curve per pair of layers holds all their links
    for (a, b) in columns.windows(2) {
      place(top + left, curve(stroke: t.stroke * 0.7 + t.muted,
        ..a.pts.map(p => b.pts.map(q => (curve.move(p), curve.line(q)))).flatten()))
    }
    for (i, col) in columns.enumerate() {
      for (px, py) in col.pts { _dot(px, py, r, fill: col.fill, stroke: t.stroke + t.line) }
      if col.more != none {
        for k in (-1, 0, 1) { _dot(x(i), col.more + k * 0.32 * em, 0.08 * em, fill: t.line) }
      }
      if labels.at(i) != none {
        place(top + left, dx: x(i) - label-w / 2, dy: height + 0.6 * em, box(width: label-w, align(center, labels.at(i))))
      }
    }
  })
})
