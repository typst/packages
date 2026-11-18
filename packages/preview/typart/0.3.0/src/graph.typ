// Graph: nodes on a ring (or around a hub) joined by edges written as "A -- B" or
// "A -> B".  Import with:  #import "graph.typ": graph
//
//   #graph(("A -- B", "B -- C", "C -- A", "A -> D"))
#import "common.typ": _canvas, _dot, _fit, _in-circle, _items, _lens, _link, _on, _or, _put, _theme, _txt

#let graph(
  edges,
  nodes: (),
  layout: "circle",
  radius: auto,
  node-radius: auto,
  node-fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = std.layout(area => {
  let t = _theme("graph", theme, style)
  if not (layout in ("circle", "star")) { assert(false, message: "graph: `layout` must be \"circle\" or \"star\", got " + repr(layout)) }
  let edges = _items("graph", edges, (t.line,), fields: ("edge",), optional: ("label",), cycle: false).enumerate().map(((i, e)) => {
    let ends = if type(e.edge) == str { e.edge.split(regex("--|->")).map(end => end.trim()) } else { () }
    if not (ends.len() == 2 and ends.all(end => end != "")) { assert(false, message: "graph: edge " + str(i + 1)
      + " must be \"A -- B\" or \"A -> B\", got " + repr(e.edge)) }
    e + (from: ends.at(0), to: ends.at(1), directed: "->" in e.edge)
  })
  // the nodes given first, in their order, then the others as the edges mention them
  let given = _items("graph: nodes", nodes, (_or(node-fill, t.palette.first()),), fields: ("name",), min: 0, cycle: false)
  let names = (..given.map(n => n.name), ..edges.map(e => (e.from, e.to)).flatten()).dedup()
  let fills = names.map(name => given.find(n => n.name == name)).map(n => if n == none { _or(node-fill, t.palette.first()) } else { n.fill })
  let (size, em) = _lens("graph", text-size: text-size, em: 1em).values()
  // auto: the circles are as large as the longest name needs
  let r = if node-radius != auto { _lens("graph", node-radius: node-radius).node-radius } else {
    calc.max(1.2 * em, ..names.map(name => {
      let m = measure(_txt(name, t.ink, size))
      calc.norm(m.width / 2pt, m.height / 2pt) * 1pt + 0.3 * em
    }))
  }
  let ring = if layout == "star" { names.slice(1) } else { names }
  let n = ring.len()
  // neighbours on the ring keep clear of each other (radius is a minimum)
  let reach = calc.max(if radius == auto { 0pt } else { _lens("graph", radius: radius).radius }, 2 * r + 2.6 * em,
    if n > 1 { (r + 0.9 * em) / calc.sin(180deg / n) } else { 0pt })
  let at = (:)
  if layout == "star" { at.insert(names.first(), (0pt, 0pt)) }
  for (i, name) in ring.enumerate() {
    let a = 90deg - i * 360deg / calc.max(n, 1)
    at.insert(name, (reach * calc.cos(a), -reach * calc.sin(a)))
  }
  let (xs, ys) = (at.values().map(p => p.at(0)), at.values().map(p => p.at(1)))
  let (ox, oy) = (r - calc.min(..xs), r - calc.min(..ys))
  let s = _fit(names, t.ink, size, 2 * r - 0.3 * em, _in-circle(r - 0.15 * em))
  _canvas("graph", t, width, area, ox + calc.max(..xs) + r, oy + calc.max(..ys) + r, {
    for e in edges {
      let ((ax, ay), (bx, by)) = (at.at(e.from), at.at(e.to))
      let d = calc.max(calc.norm((bx - ax) / 1pt, (by - ay) / 1pt) * 1pt, 0.01pt)
      // from border to border of the two circles
      let ((ux, uy), gap) = (((bx - ax) / d, (by - ay) / d), r + 0.15 * em)
      let (p, q) = ((ox + ax + ux * gap, oy + ay + uy * gap), (ox + bx - ux * gap, oy + by - uy * gap))
      if e.directed { _link(t + (line: e.fill), p, q) } else {
        place(top + left, line(start: p, end: q, stroke: 1.4 * t.stroke + e.fill))
      }
      if e.label != none {
        _put((p.at(0) + q.at(0)) / 2, (p.at(1) + q.at(1)) / 2, box(fill: t.surface, inset: 0.15 * em,
          _txt(e.label, t.ink, size * t.small, weight: auto)))
      }
    }
    for (name, fill) in names.zip(fills) {
      let (x, y) = at.at(name)
      _dot(shadow: t.shadow, ox + x, oy + y, r, fill: fill, stroke: t.stroke + t.line)
      _put(ox + x, oy + y, _txt(name, _on(t, fill), s), w: 2 * r - 0.3 * em)
    }
  })
})
