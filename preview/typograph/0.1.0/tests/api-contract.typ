// Public construction and extension contracts. A clean compile means every
// assertion passed.
#import "/src/lib.typ" as typ
#import "/src/node.typ": shape-outline, shape-radius
#import "/src/edge.typ": (
  resolve-edge-path, path-start-direction, path-end-direction,
)
#import "/src/diagram.typ": resolve-clipped-edge

#let diagram = typ.diagram

// Local fixtures standing in for a real theme's kinds. `dot` is a plain
// circle; `pointer` reuses the built-in arrow builder specifically for its
// asymmetric tip, needed below to test directed clipping against a
// non-circular silhouette; `tri`/`tri-flip` reuse flat-triangle the same way
// `state`/`effect` do in a real ZX theme — a mirrored pair, not a rotated one.
#let dot = typ.node-type("dot", base-style: (shape: typ.shapes.circle, min-size: 9pt))
#let pointer = typ.node-type("pointer", flippable: true, base-style: (shape: typ.shapes.arrow, min-size: 11pt))
#let tri = typ.node-type("tri", base-style: (shape: typ.shapes.flat-triangle, min-width: 26pt, min-height: 20pt))
#let tri-flip = typ.node-type("tri-flip", base-style: (shape: typ.shapes.flat-triangle, flip: true, min-width: 26pt, min-height: 20pt))

// A reusable semantic constructor can carry shape geometry directly. There
// is no registry key whose spelling must stay synchronized with the type.
#let phase = typ.node-type("phase", base-style: (
  shape: typ.shapes.diamond,
  fill: purple.lighten(70%),
  min-size: 12pt,
))
#let p = phase(1, 2, label: [P], name: "p", style: (stroke: 2pt + red)).first()

#assert(p.type == "node" and p.kind == "phase")
#assert((p.x, p.y) == (1, 2))
#assert(p.label == [P] and p.name == "p")
#assert(p.style == (stroke: 2pt + red))
#assert(p.base-style.shape == typ.shapes.diamond and p.size-scale == 1)

// Simple semantic constructors are declarations over the generic model.
#for (kind, ctor) in (
  ("a", typ.node-type("a")), ("b", typ.node-type("b")), ("c", typ.node-type("c")),
) {
  assert(
    ctor(3, 4, label: [L], name: "n", style: (fill: blue))
      == typ.node-type(kind)(3, 4, label: [L], name: "n", style: (fill: blue)),
  )
}

// Factory defaults sit below theme/diagram styles; instance style wins.
#let resolved = typ.resolve-node-style(
  p.kind,
  (:),
  p.base-style,
  (fill: blue),
  p.style,
)
#assert(resolved.shape == typ.shapes.diamond and resolved.fill == blue)
#assert(resolved.stroke == 2pt + red)

// Explicit convenience arguments are call-site intent and beat style bags.
#assert(typ.box(0, 0, fill: red, style: (fill: blue)).first().style.fill == red)
#assert(typ.gate(0, 0, [U], inset: 2pt, style: (inset: 9pt)).first().style.inset == 2pt)
// flippable: true is a node-type() option, not special-cased per kind — any
// directional semantic constructor that opts in gets the same flip: sugar.
#assert(pointer(0, 0, flip: true).first().style.flip == true)
#assert(typ.place(0, 0, [P], align: left + top).first().align == left + top)

// Custom kinds retain capture, transform, and rendering behavior.
#let captured = typ.edge(phase(0, 0), (1, 0))
#assert(captured.last().type == "edge")
#assert(captured.last().waypoints.first().node.kind == "phase")
#assert(typ.group(dx: 2, phase(0, 0)).first().kind == "phase")
#diagram({
  phase(0, 0, label: [P])
  dot(1, 0)
})

// Identity uses a discriminating bucket key plus exact equality. Common visual
// differences split buckets; function metadata can still collide under repr
// and must survive the authoritative equality check.
#import "/src/diagram.typ": node-key
#let co-a = dot(0, 0, label: [A]).first()
#let co-b = dot(0, 0, label: [B]).first()
#assert(node-key(co-a) != node-key(co-b) and co-a != co-b)
#let callback-a = value => value
#let callback-b = value => value + 1
#let fn-a = typ.make-node("dot", 0, 0, callback: callback-a).first()
#let fn-b = typ.make-node("dot", 0, 0, callback: callback-b).first()
#assert(repr(callback-a) == repr(callback-b) and node-key(fn-a) == node-key(fn-b) and fn-a != fn-b)
#diagram({ (co-a, co-b, fn-a, fn-b) })

// Names and refs intentionally use strings, enabling direct dictionary lookup
// instead of repr/equality buckets on every deferred endpoint.
#let name-a = "a"
#let name-b = "b"
#diagram({
  dot(0, 0, name: name-a)
  dot(1, 0, name: name-b)
  typ.edge(typ.ref(name-a), typ.ref(name-b))
})

// Reusable edge defaults get their own lower-precedence layer.
#let emphasized = typ.edge-type(none, base-style: (stroke: 1.5pt + purple))
#let emphasized-edge = emphasized((0, 0), (1, 0)).last()
#assert(typ.resolve-edge-style(emphasized-edge, (:)).stroke == 1.5pt + purple)
#assert(typ.resolve-edge-style(emphasized-edge, (stroke: 2pt + blue)).stroke == 2pt + blue)
#assert(typ.resolve-edge-style(typ.edge((0, 0), (1, 0), clip: false).last(), (:)).clip == false)
#let named-presets = (thick: (stroke: 3pt + black), plain: (:))
#let default-thick = typ.edge-type("thick")
#assert(typ.resolve-edge-style(
  default-thick((0, 0), (1, 0)).last(),
  (:),
  presets: named-presets,
).stroke == named-presets.thick.stroke)
#assert(typ.resolve-edge-style(
  default-thick((0, 0), (1, 0), preset: "plain").last(),
  (:),
  presets: named-presets,
).stroke == typ.edge-defaults.stroke)

// Bundled semantic wire constructors are discoverable without spelling
// palette paths or preset strings at each call site.
#let alert-presets = (alert: (highlight: (red, orange)))
#let alert = typ.edge-type("alert")
#let alert-web = alert((0, 0), (1, 0)).last()
#assert(alert-web.preset == "alert")
#assert(
  typ.resolve-edge-style(
    alert-web,
    (:),
    presets: alert-presets,
  ).highlight == (red, orange),
)
#assert(alert((0, 0), (1, 0), highlight: none).last().highlight == ())

// Every explicit path constructor is part of the public facade, including a
// line whose endpoint remains deferred until layout.
#let deferred-line = typ.edge((0, 0), typ.line(typ.rel(1, 0))).last()
#assert(deferred-line.waypoints.last().kind == "line")
#assert(deferred-line.waypoints.last().defer.type == "rel")
#let mixed-smooth = resolve-edge-path(typ.edge(
  (0, 0), typ.smooth((1, 1)), (2, 0), (3, 0),
).last())
#assert(
  mixed-smooth.segments.first().kind == "quad"
    and mixed-smooth.segments.last().kind == "line",
)
#diagram({
  typ.edge(
    (0, 0), (1, 0), label: [relative inset],
    style: (label-inset: 10% + 1pt),
  )
})

// flip:, not rotate:, is how a mirrored pair of the same shape is expressed —
// the two orientations must actually differ, and in exactly the mirrored way.
#let prepared(n) = shape-outline(
  typ.resolve-node-style(n.kind, (:), n.base-style, n.style),
  [],
  (width: 0pt, height: 0pt),
)
#let close(a, b, epsilon: 1e-6) = calc.abs(a - b) < epsilon
#let point-close(a, b, epsilon: 1e-6) = (
  close(a.at(0), b.at(0), epsilon: epsilon)
    and close(a.at(1), b.at(1), epsilon: epsilon)
)
#let point-on-outline(point, center, outline, unit: 1pt, epsilon: 2e-3) = {
  let dx = point.at(0) - center.at(0)
  let dy = point.at(1) - center.at(1)
  let distance = calc.sqrt(dx * dx + dy * dy)
  let angle = calc.atan2(dx, -dy)
  close(distance, shape-radius(outline, angle) / unit, epsilon: epsilon)
}
#let unique-right-tip(outline) = {
  let xs = outline.points.map(point => point.at(0))
  xs.filter(value => value == calc.max(..xs)).len() == 1
}
#let unique-left-tip(outline) = {
  let xs = outline.points.map(point => point.at(0))
  xs.filter(value => value == calc.min(..xs)).len() == 1
}
#assert(unique-right-tip(prepared(tri(0, 0).first())))
#assert(unique-left-tip(prepared(tri-flip(0, 0).first())))
#assert(tri-flip(0, 0).first().kind == "tri-flip")

// Endpoint directions are outward handles. At the terminal endpoint the path
// travels opposite `to:`, so `to: right` selects the node's right boundary.
#let to-right = resolve-edge-path(typ.edge((0, 0), (1, 0), to: right).last())
#assert(path-start-direction(to-right) != (0, 0))
#assert(to-right.segments.last().ctrl.last().at(0) > 1)
#assert(path-end-direction(to-right).at(0) < 0)
#let from-right = resolve-edge-path(typ.edge((0, 0), (1, 0), from: right).last())
#assert(path-end-direction(from-right) != (0, 0))
#let to-left = resolve-edge-path(typ.edge((0, 0), (1, 0), to: left).last())
#assert(path-end-direction(to-left).at(0) > 0)

// Regression: from:/to: directions select exact boundary anchors when clipping
// is enabled. A radial outline distance is not a distance along the old curve.
#let circle-node = dot(0, 0).first()
#let arrow-node = pointer(0, 1).first()
#let circle-outline = prepared(circle-node)
#let arrow-outline = prepared(pointer(0, 1).first())
#let directed-item = typ.edge(
  circle-node,
  arrow-node,
  from: (right, 1.0),
  to: (right, 1.0),
).last()
#let directed-clipped = resolve-clipped-edge(
  directed-item,
  start-outline: circle-outline,
  end-outline: arrow-outline,
  unit: 1cm,
)
#let tip-x = calc.max(..arrow-outline.points.map(point => point.at(0)))
#let right-tip = arrow-outline.points.filter(point => point.at(0) == tip-x).first()
#let expected-start = (circle-outline.radius / 1cm, 0)
#let expected-end = (
  arrow-node.x + right-tip.at(0) / 1cm,
  arrow-node.y - right-tip.at(1) / 1cm,
)
#assert(point-close(directed-clipped.start, expected-start))
#assert(point-close(directed-clipped.segments.last().end, expected-end))
// Handle strength is measured from the visible anchor, not the hidden centre.
#assert(point-close(
  directed-clipped.segments.first().ctrl.first(),
  (expected-start.at(0) + 0.5, expected-start.at(1)),
))
#assert(point-close(
  directed-clipped.segments.last().ctrl.last(),
  (expected-end.at(0) + 0.5, expected-end.at(1)),
))
#let directed-strengths = resolve-clipped-edge(
  typ.edge(
    circle-node,
    arrow-node,
    from: (right, 0.25),
    to: (right, 2),
  ).last(),
  start-outline: circle-outline,
  end-outline: arrow-outline,
  unit: 1cm,
)
#assert(point-close(directed-strengths.start, expected-start))
#assert(point-close(directed-strengths.segments.last().end, expected-end))
#assert(close(
  directed-strengths.segments.first().ctrl.first().at(0) - expected-start.at(0),
  0.125,
))
#assert(close(
  directed-strengths.segments.last().ctrl.last().at(0) - expected-end.at(0),
  1,
))

// clip:false is intentionally centre-to-centre. Node overdraw can make that
// look clipped in a PDF, so the geometry contract must assert it directly.
#let directed-raw = resolve-clipped-edge(
  directed-item,
  start-outline: circle-outline,
  end-outline: arrow-outline,
  unit: 1cm,
  clip: false,
)
#assert(directed-raw == resolve-edge-path(directed-item))
#assert(directed-raw.start == (0, 0))
#assert(directed-raw.segments.last().end == (0, 1))
#assert(directed-raw.segments.last().ctrl == ((0.5, 0), (0.5, 1)))
#assert(typ.edge-defaults.clip == true)

// Automatic curved clipping preserves the original curve outside the nodes
// and intersects each circle rather than trimming by the circle radius as arc
// length. Both retained endpoints must lie exactly on their silhouettes.
#let bend-end = dot(2, 0).first()
#let bent-clipped = resolve-clipped-edge(
  typ.edge(circle-node, bend-end, bend: 1).last(),
  start-outline: circle-outline,
  end-outline: prepared(bend-end),
  unit: 1cm,
)
#let circle-radius = circle-outline.radius / 1cm
#let bent-start-radius = calc.sqrt(
  bent-clipped.start.at(0) * bent-clipped.start.at(0)
    + bent-clipped.start.at(1) * bent-clipped.start.at(1)
)
#let bent-end-point = bent-clipped.segments.last().end
#let bent-end-radius = calc.sqrt(
  (bent-end-point.at(0) - 2) * (bent-end-point.at(0) - 2)
    + bent-end-point.at(1) * bent-end-point.at(1)
)
#assert(close(bent-start-radius, circle-radius, epsilon: 5e-5))
#assert(close(bent-end-radius, circle-radius, epsilon: 5e-5))

// Every native outline kind follows the same boolean containment contract.
// This ellipse catches accidental multiline arithmetic results: the crossing
// search must receive a boolean, then land on the ellipse equation itself.
#let ellipse-outline = (
  kind: "ellipse",
  half-width: 6pt,
  half-height: 3pt,
)
#let ellipse-clipped = resolve-clipped-edge(
  typ.edge((0, 0), (20, 10), bend: 5).last(),
  start-outline: ellipse-outline,
  unit: 1pt,
)
#let ellipse-start = ellipse-clipped.start
#let ellipse-equation = (
  (ellipse-start.at(0) / 6) * (ellipse-start.at(0) / 6)
    + (ellipse-start.at(1) / 3) * (ellipse-start.at(1) / 3)
)
#assert(close(ellipse-equation, 1, epsilon: 2e-3))

#let rounded-outline = (
  kind: "rect",
  half-width: 6pt,
  half-height: 3pt,
  radius: 2pt,
)
#let rounded-clipped = resolve-clipped-edge(
  typ.edge((0, 0), (20, 10), bend: 5).last(),
  start-outline: rounded-outline,
  unit: 1pt,
)
#assert(point-on-outline(
  rounded-clipped.start,
  (0, 0),
  rounded-outline,
))

// A routed line may exit, re-enter, and exit a supported concave polygon.
// Exact segment/edge intersections must retain the first visible interval in
// both traversal directions instead of jumping to the final outer boundary.
#let concave-outline = (
  kind: "polygon",
  points: (
    (-1pt, -1pt),
    (1pt, -1pt),
    (1pt, 0.5pt),
    (3pt, 0.5pt),
    (3pt, -1pt),
    (5pt, -1pt),
    (5pt, 1pt),
    (-1pt, 1pt),
  ),
)
#let concave-forward = resolve-clipped-edge(
  typ.edge((0, 0), (4, 0), (7, 0)).last(),
  start-outline: concave-outline,
  unit: 1pt,
)
#assert(point-close(concave-forward.start, (1, 0)))
#let concave-reverse = resolve-clipped-edge(
  typ.edge((7, 0), (4, 0), (0, 0)).last(),
  end-outline: concave-outline,
  unit: 1pt,
)
#assert(point-close(concave-reverse.segments.last().end, (1, 0)))

// Refinement accuracy is physical rather than a fixed fraction of a segment.
// Ten parameter bisections alone miss a 1pt circle on this long routed line by
// several points.
#let tiny-circle = (kind: "circle", radius: 1pt)
#let long-clipped = resolve-clipped-edge(
  typ.edge((0, 0), (10000, 0), (10001, 0)).last(),
  start-outline: tiny-circle,
  unit: 1pt,
)
#assert(close(long-clipped.start.at(0), 1, epsilon: 1.1e-3))
#assert(close(long-clipped.start.at(1), 0))

// A zero-area silhouette is a true no-op, not an epsilon-sized artificial
// disk that nudges a curved endpoint away from its centre.
#let zero-item = typ.edge((0, 0), (0, 10), bend: 2).last()
#let zero-clipped = resolve-clipped-edge(
  zero-item,
  start-outline: (kind: "circle", radius: 0pt),
  end-outline: (kind: "circle", radius: 0pt),
  unit: 1pt,
)
#assert(zero-clipped == resolve-edge-path(zero-item))

// A node wider than the default handle still gets an outward handle. Moving
// only the endpoint after construction would reverse this tangent.
#let large-node = dot(0, 0, style: (min-size: 40pt)).first()
#let large-outline = prepared(large-node)
#let large-directed = resolve-clipped-edge(
  typ.edge(large-node, (0, 2), from: right).last(),
  start-outline: large-outline,
  unit: 1cm,
)
#assert(large-directed.start.at(0) > 0.5)
#assert(close(
  large-directed.segments.first().ctrl.first().at(0) - large-directed.start.at(0),
  0.5,
))

// Rotated polygon extents conservatively contain every transformed point.
#let rotated = shape-outline(
  typ.resolve-node-style("node", (:), (
    shape: typ.shapes.flat-triangle,
    rotate: 45deg,
    min-width: 26pt,
    min-height: 20pt,
  )),
  [],
  (width: 0pt, height: 0pt),
)
#assert(rotated.points.all(point => calc.abs(point.at(0)) <= rotated.half-width))
#assert(rotated.points.all(point => calc.abs(point.at(1)) <= rotated.half-height))

// A one-off custom builder can consume style.rotate without any global
// registry mutation.
#let rotating-rect(label, pad, style) = {
  let (width, height) = typ.fit-box(label, pad, style)
  let (half-width, half-height) = (width / 2, height / 2)
  let points = (
    (-half-width, -half-height),
    (half-width, -half-height),
    (half-width, half-height),
    (-half-width, half-height),
  ).map(point => typ.rotate-point(point, style.rotate))
  typ.polygon-outline(points)
}
#typ.diagram({
  typ.node(0, 0, label: [R], style: (
    shape: rotating-rect,
    rotate: 45deg,
    fill: white,
    stroke: 0.6pt + black,
  ))
})

// The neutral renderer remains useful without any domain theme.
#typ.diagram({
  let g = typ.gate(0, 0, [U])
  typ.edge(typ.port(g, "left"), (-1, 0))
})
#diagram({
  let g = typ.gate(0, 0, [M], kind: "measurement")
  typ.edge(typ.port(g, "right"), (1, 0))
})

// Diagram bounds include centered node strokes, not just fill geometry.
#context {
  let rendered = typ.diagram(inset: 0pt, {
    typ.node(0, 0, style: (
      shape: typ.shapes.circle,
      min-size: 10pt,
      inset: 0pt,
      fill: none,
      stroke: 10pt + black,
    ))
  })
  let size = measure(rendered)
  assert(size.width >= 20pt and size.height >= 20pt)
}
