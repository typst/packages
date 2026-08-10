// Unit tests for the pure, context-free helper functions in typograph. A
// clean compile (no panics) means every check passed; each also prints a
// PASS line so this file doubles as a human-readable report when rendered.
//
// Run: typst compile --root . tests/unit.typ tests/unit.pdf

#import "/src/utility.typ": is-coord, unwrap-node, direction-to-angle, split-direction, vadd, vsub, vscale, vlen, vmid, vperp, vunit
#import "/src/geometry.typ": (
  regular-polygon, dir-vector, to-screen, rotate-point,
  rect-radius, rounded-rect-radius, polygon-radius,
  resolve-inset,
)
#import "/src/style.typ": merge-style, merge-per-kind, scale-stroke
#import "/src/edge.typ": edge, smooth, quad, cubic, resolve-edge-path, point-on-segment, point-on-path, bend-control, normalize-highlight, resolve-endpoint, path-start-direction, path-end-direction, trim-resolved, rel, ref
#import "/src/node.typ": (
  gate, port, shape-outline, shape-radius, gate-port-on-outline, node-type,
)
#import "/src/content.typ": group
#import "/src/diagram.typ": (
  baseline-shift, math-axis-height, node-key, resolve-deferred-waypoints,
  stroke-outset, offset-polyline,
)

// Local, minimal fixtures standing in for a real theme's kinds — this file
// tests the generic mechanism, not any particular visual language, so any
// node-type() declaration exercises it equally well.
#let dot = node-type("dot")
#let tri = node-type("tri", flippable: true)

#let eps = 1e-9
#let approx(a, b) = calc.abs(a - b) < eps
#let vapprox(a, b) = approx(a.at(0), b.at(0)) and approx(a.at(1), b.at(1))
// Length-valued variants (calc.abs on a `length` can't be compared to a
// bare float), used for the regular-polygon/to-screen checks below.
#let approx-len(a, b) = calc.abs(a / 1pt - b / 1pt) < 1e-6
#let vapprox-len(a, b) = approx-len(a.at(0), b.at(0)) and approx-len(a.at(1), b.at(1))

#import "/src/style.typ": (
  node-defaults, resolve-node-style, expand-min-size,
)
#import "/src/shape.typ" as shapes
#import "/src/shape.typ": build-outline
#import "/src/style.typ": edge-defaults, resolve-edge-style
#import "/src/theme.typ": theme as make-theme

// A small local theme, standing in for a real one, just to exercise preset
// layering and the closed edge-style schema.
#let test-theme = make-theme(
  palette: (alert: red, warn: orange),
  node-presets: (
    dot: (shape: shapes.circle, shape-labelled: shapes.stadium, min-size: 9pt, inset: 4pt),
    ghost: (shape: shapes.bare),
  ),
  edge-defaults: (:),
  edge-presets: (
    plain: (:),
    alert: (highlight: red),
    duo: (highlight: (red, orange)),
    thick: (stroke: 2pt + black),
  ),
)
#let node-presets = test-theme.node-presets
#let edge-presets = test-theme.edge-presets
#let palette = test-theme.palette

// `shape-outline` takes a *resolved* style — presets are partial by design,
// so a test that wants one has to go through the same layering the renderer
// does. This is that, spelled once.
#let styled(..over) = resolve-node-style("node", (:), ..over)
#let preset-style(kind) = resolve-node-style(kind, node-presets)

#let n-checks = counter("typograph-unit-checks")
#let check(name, cond) = {
  n-checks.step()
  assert(cond, message: "FAILED: " + name)
  [#text(fill: green.darken(20%))[✓] #name]
  linebreak()
}

= typograph unit tests

== utility.typ

#check("is-coord accepts (int, int)", is-coord((1, 2)))
#check("is-coord accepts (float, float)", is-coord((1.5, -2.25)))
#check("is-coord rejects length-3 array", not is-coord((1, 2, 3)))
#check("is-coord rejects array of content", not is-coord(([a], [b])))

#check("unwrap-node unwraps a constructor array", unwrap-node(dot(1, 2)) == dot(1, 2).first())
#check("unwrap-node passes through a bare node dict", unwrap-node(dot(1, 2).first()) == dot(1, 2).first())
#check("unwrap-node rejects a multi-node fragment", unwrap-node(dot(0, 0) + dot(1, 0)) == none)
#check("unwrap-node returns none for a coordinate", unwrap-node((1, 2)) == none)
#check("unwrap-node returns none for unrelated content", unwrap-node([hi]) == none)

// Diagram coordinates are math-convention (+y up), so `top` is the
// *positive* y direction here.
#check("direction-to-angle(left) == 180deg", direction-to-angle(left) == 180deg)
#check("direction-to-angle(right) == 0deg", direction-to-angle(right) == 0deg)
#check("direction-to-angle(top) == 90deg", direction-to-angle(top) == 90deg)
#check("direction-to-angle(bottom) == -90deg", direction-to-angle(bottom) == -90deg)
#check("direction-to-angle passes angles through", direction-to-angle(37deg) == 37deg)

#check("split-direction(auto) == (auto, 1)", split-direction(auto) == (auto, 1))
#check("split-direction(angle) defaults strength 1", split-direction(45deg) == (45deg, 1))
#check("split-direction((angle, strength))", split-direction((45deg, 2)) == (45deg, 2))
#check("split-direction is order-independent", split-direction((2, 45deg)) == (45deg, 2))
#check("split-direction resolves alignments too", split-direction(left) == (180deg, 1))

#check("vadd", vadd((1, 2), (3, 4)) == (4, 6))
#check("vsub", vsub((3, 4), (1, 2)) == (2, 2))
#check("vlen(3,4) == 5", approx(vlen((3, 4)), 5))

== geometry.typ

#let square-pts = regular-polygon(4, 10pt, rotate: 0deg)
#check("regular-polygon(4, ..) has 4 vertices", square-pts.len() == 4)
#check("regular-polygon first vertex at (r, 0) when rotate: 0deg", vapprox-len(square-pts.first(), (10pt, 0pt)))
#check(
  "regular-polygon vertices all lie at radius r",
  square-pts.all(p => {
    let (x, y) = (p.at(0) / 1pt, p.at(1) / 1pt)
    calc.abs(calc.sqrt(x * x + y * y) - 10) < 1e-6
  }),
)

#check("dir-vector(0deg) == (1, 0)", vapprox(dir-vector(0deg), (1, 0)))
#check("dir-vector(90deg) has positive y (unit-space up)", dir-vector(90deg).at(1) > 0.99)

// to-screen is the one place diagram-unit (+y up) becomes screen-pt (+y
// down): x is untouched, y is negated and scaled.
#check("to-screen scales x by unit", to-screen((2, 0), 1cm) == (2cm, 0cm))
#check("to-screen negates+scales y (unit up -> screen down)", to-screen((0, 3), 1cm) == (0cm, -3cm))
#check("to-screen at origin is the origin", to-screen((0, 0), 1cm) == (0cm, 0cm))

#check("rotate-point(_, 0deg) is the identity", vapprox-len(rotate-point((10pt, 0pt), 0deg), (10pt, 0pt)))
#check(
  "rotate-point(_, 90deg) screen-rotates (1,0) to (0,1)",
  vapprox-len(rotate-point((10pt, 0pt), 90deg), (0pt, 10pt)),
)
#check(
  "a maximally rounded square clips like its circular silhouette",
  approx-len(rounded-rect-radius(10pt, 10pt, 10pt, 45deg), 10pt),
)
#check(
  "zero-radius rounded rectangle is the sharp rectangle",
  approx-len(
    rounded-rect-radius(10pt, 6pt, 0pt, 35deg),
    rect-radius(10pt, 6pt, 35deg),
  ),
)
#let percent-square = build-outline(
  shapes.square,
  (width: 0pt, height: 0pt),
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  node-defaults + (min-width: 20pt, min-height: 20pt, radius: 50%),
)
#check("percentage corner radii resolve against the shorter side", approx-len(percent-square.radius, 5pt))

== style.typ

#check(
  "merge-style: override replaces a key",
  merge-style((a: 1, b: 2), (b: 3)) == (a: 1, b: 3),
)
#check(
  "merge-style: later overrides win",
  merge-style((a: 1), (a: 2), (a: 3)) == (a: 3),
)
#check(
  "merge-style: none/auto overrides are no-ops",
  merge-style((a: 1), none, auto) == (a: 1),
)

== edge.typ (path resolution — pure, no context needed)

#let e1 = edge((0, 0), (1, 0)).last()
#let r1 = resolve-edge-path(e1)
#check("plain 2-point edge resolves to 1 segment", r1.segments.len() == 1)
#check("plain 2-point edge is a straight line", r1.segments.first().kind == "line")
#check("plain 2-point edge start", r1.start == (0, 0))
#check("plain 2-point edge end", r1.segments.first().end == (1, 0))

#let e2 = edge((0, 0), (1, 0), from: right, to: left).last()
#let r2 = resolve-edge-path(e2)
#check("from:/to: bend produces a cubic segment", r2.segments.first().kind == "cubic")
#check("cubic segment has 2 control points", r2.segments.first().ctrl.len() == 2)

#let e3 = edge((0, 0), (2, 0), (4, 0)).last()
#let r3 = resolve-edge-path(e3)
#check("3-waypoint edge produces 2 segments", r3.segments.len() == 2)
#check(
  "point-on-path(0) is the overall start",
  vapprox(point-on-path(r3, 0), (0, 0)),
)
#check(
  "point-on-path(1) is the overall end",
  vapprox(point-on-path(r3, 1), (4, 0)),
)
#check(
  "point-on-path(0.5) lands on the segment boundary",
  vapprox(point-on-path(r3, 0.5), (2, 0)),
)
#let unequal-path = resolve-edge-path(edge((0, 0), (1, 0), (10, 0)).last())
#check(
  "point-on-path uses distance along unequal segments",
  vapprox(point-on-path(unequal-path, 0.5), (5, 0)),
)
#check(
  "point-on-segment at t=0.5 on a straight segment is its midpoint",
  vapprox(point-on-segment((0, 0), r1.segments.first(), 0.5), (0.5, 0)),
)

#check(
  "bend-control offsets perpendicular to the chord, at its midpoint",
  vapprox(bend-control((0, 0), (2, 0), 1), (1, 1)),
)
#check("bend-control at amount 0 is just the midpoint", vapprox(bend-control((0, 0), (2, 0), 0), (1, 0)))
#let e4 = edge((0, 0), (2, 0), bend: 1).last()
#let r4 = resolve-edge-path(e4)
#check("bend: produces a quad segment", r4.segments.first().kind == "quad")
#check("bend: control point matches bend-control", vapprox(r4.segments.first().ctrl.first(), (1, 1)))

#check("normalize-highlight(none) is empty", normalize-highlight(none) == ())
#check("normalize-highlight(color) duplicates it across both bands", normalize-highlight(red) == (red, red))
#check("normalize-highlight((color,)) duplicates it across both bands", normalize-highlight((red,)) == (red, red))
#check("normalize-highlight((c1, c2)) passes an already-2-color array through", normalize-highlight((red, blue)) == (red, blue))

#let g0 = gate(0, 0, [U]).first()
#check(
  "resolve-endpoint on a coordinate captures nothing and clips to nothing",
  resolve-endpoint((1, 2)) == (end: (1, 2), defer: none, node: none, clip-to: none),
)
#check(
  "resolve-endpoint on a node captures it and clips to it",
  resolve-endpoint(dot(1, 2)) == (end: (1, 2), defer: none, node: dot(1, 2).first(), clip-to: dot(1, 2).first()),
)
// A port's coordinate depends on the gate's rendered size, so it is deferred
// to layout. The gate is still captured (so it gets drawn), but the wire must
// not be clipped back — a port already lies *on* the outline.
#let g1 = gate(0, 0, [U], legs: (left: 1, right: 1))
#let pref = port(g1, "left")
#let presolved = resolve-endpoint(pref)
#check("resolve-endpoint defers a port()", presolved.end == none and presolved.defer == pref)
#check("resolve-endpoint on a port() still captures the gate", presolved.node == g1.first())
#check("resolve-endpoint on a port() does NOT clip to the gate", presolved.clip-to == none)
#check("port() records the side and index it was asked for", pref.side == "left" and pref.index == 0)

#let rresolved = resolve-endpoint(rel(1, -2))
#check("resolve-endpoint defers a rel()", rresolved.end == none and rresolved.defer.type == "rel")
#check("rel() records its offset", rresolved.defer.dx == 1 and rresolved.defer.dy == -2)
#let nresolved = resolve-endpoint(ref("a"))
#check("resolve-endpoint defers a ref()", nresolved.end == none and nresolved.defer.type == "ref")
#check("ref() records the name", nresolved.defer.name == "a")
// A ref cannot capture its node (it does not have it), so the node must be
// emitted separately — that is the documented trade-off for skipping the
// `let` binding.
#check("ref() captures nothing", nresolved.node == none)

== node.typ — gate ports come from the rendered box

// Ports are resolved one at a time from the rendered outline, avoiding an
// allocation of every side's candidates for each endpoint.
#let circle-port = gate-port-on-outline(
  (kind: "circle", radius: 10pt),
  (left: 2, right: 0, top: 0, bottom: 0),
  "left",
  0,
)
#check("multi-port circular gates project each port onto the silhouette", {
  let (x, y) = (circle-port.at(0) / 1pt, circle-port.at(1) / 1pt)
  approx(calc.sqrt(x * x + y * y), 10)
})
#let rect-port = gate-port-on-outline(
  (kind: "rect", half-width: 20pt, half-height: 10pt, radius: 0pt),
  (left: 2, right: 0, top: 0, bottom: 0),
  "left",
  0,
)
#check("rectangular gate ports retain their even side positions", {
  approx-len(rect-port.at(0), -20pt) and approx-len(rect-port.at(1), -7pt)
})
#let rect-port-2 = gate-port-on-outline(
  (kind: "rect", half-width: 20pt, half-height: 10pt, radius: 0pt),
  (left: 2, right: 0, top: 0, bottom: 0),
  "left",
  1,
)
#check("two side ports remain symmetric", approx-len(rect-port.at(1), -rect-port-2.at(1)))
#let lone-right = gate-port-on-outline(
  (kind: "rect", half-width: 20pt, half-height: 10pt, radius: 0pt),
  (left: 0, right: 1, top: 0, bottom: 0),
  "right",
  0,
)
#check("a lone port is centred on its side", lone-right == (20pt, 0pt))



== node.typ (gate construction — pure, no context needed)

#let g = gate(0, 0, [U], legs: (left: 2, right: 1))
#let gn = g.first()
#check("gate() records requested leg counts", gn.legs == (left: 2, right: 1))
#check("gate() has no baked-in size (it is measured at layout)", gn.size == auto)
#let p0 = port(g, "right", index: 0)
#check("port() carries a reference back to its gate (for edge auto-capture)", p0.node == gn)
#check("port() records which attachment point it means", (p0.side, p0.index) == ("right", 0))

== content.typ (group — pure, no context needed)

#let moved = group(dx: 5, dy: -2, dot(0, 0)).first()
#check("group(dx:, dy:) translates a node", (moved.x, moved.y) == (5, -2))
#let scaled = group(scale: 2, dot(3, 0)).first()
#check("group(scale:) scales position about the default pivot (0, 0)", (scaled.x, scaled.y) == (6, 0))
#check("group(scale:) scales the node's size-scale too", scaled.size-scale == 2)
#let rotated = group(rotate: 90deg, dot(1, 0)).first()
#check("group(rotate:) rotates position about the default pivot", vapprox((rotated.x, rotated.y), (0, 1)))
#check("group() with no-op args returns items unchanged", group(dot(1, 2)) == dot(1, 2))

// Curvature parameters are geometric too: the same affine transform must
// reach bend amounts and requested outward endpoint handles.
#let grouped-bend = group(scale: 3, edge((0, 0), (1, 0), bend: 0.5)).first()
#check("group(scale:) scales edge bend", approx(grouped-bend.bend, 1.5))
#let grouped-tangents = group(
  scale: 2,
  rotate: 90deg,
  edge((0, 0), (1, 0), from: (right, 2), to: (top, 3)),
).first()
#check("group(rotate:) rotates an edge's from: direction", split-direction(grouped-tangents.from) == (90deg, 4))
#check("group(rotate:) rotates an edge's to: direction", split-direction(grouped-tangents.to) == (180deg, 6))
#let nested-tangent = group(
  scale: 2,
  rotate: 30deg,
  group(scale: 3, rotate: 60deg, edge((0, 0), (1, 0), from: (right, 1))),
).first()
#check("nested group transforms compose for tangent angle and strength", split-direction(nested-tangent.from) == (90deg, 6))
#let grouped-deferred-control = group(
  dx: 1,
  dy: 2,
  scale: 2,
  edge((0, 0), quad((0.5, 1), rel(1, 0))),
).first()
#check(
  "group transforms controls whose path endpoint is deferred",
  vapprox(grouped-deferred-control.waypoints.last().ctrl.first(), (2, 4)),
)

== geometry.typ — boundary radii (edge attachment)

#check("rect-radius along +x is the half-width", approx-len(rect-radius(20pt, 10pt, 0deg), 20pt))
#check("rect-radius along +y is the half-height", approx-len(rect-radius(20pt, 10pt, 90deg), 10pt))
#check(
  "rect-radius at 45deg hits the nearer (top) edge",
  approx-len(rect-radius(20pt, 10pt, 45deg), 10pt / calc.sin(45deg)),
)
#let sq-pts = ((10pt, 10pt), (-10pt, 10pt), (-10pt, -10pt), (10pt, -10pt))
#check("polygon-radius on a square matches rect-radius on its axis", approx-len(polygon-radius(sq-pts, 0deg), 10pt))
#check(
  "polygon-radius on a square reaches the corner at 45deg",
  approx-len(polygon-radius(sq-pts, 45deg), 10pt / calc.cos(45deg)),
)
// The case behind the multiplier-tip bug: a rightward ray must exit exactly
// at the apex, not at the (nearer) back edge.
#let tri-pts = ((10pt, 0pt), (-10pt, -8pt), (-10pt, 8pt))
#check("polygon-radius exits a right-pointing triangle at its tip", approx-len(polygon-radius(tri-pts, 0deg), 10pt))

== node.typ — shapes and radii

#check(
  "an unlabeled node keeps its preset shape",
  shape-outline(preset-style("dot"), [], (width: 0pt, height: 0pt)).kind == "circle",
)
#check(
  "a labelled node grows into its shape-labelled form",
  shape-outline(preset-style("dot"), [x], (width: 12pt, height: 6pt)).kind == "rect",
)
#check("the neutral generic node is invisible", node-defaults.shape == shapes.empty)
#check("a bare preset is frameless", node-presets.ghost.shape == shapes.bare)
#check("a flippable node-type() follows the common semantic-node interface", tri(0, 0, label: [W]).first().label == [W])
#check("shape-radius of an invisible node is zero", approx-len(shape-radius((kind: "empty"), 30deg), 0pt))
#check("shape-radius of a circle is its radius at any angle", approx-len(shape-radius((kind: "circle", radius: 7pt), 123deg), 7pt))

== edge.typ — smooth waypoints and trimming

#let es = edge((0, 0), smooth((1, 1)), (2, 0)).last()
#let rs = resolve-edge-path(es)
#check("smooth() with one interior waypoint gives a single quad", rs.segments.len() == 1)
#check("smooth() uses that waypoint as the control point", vapprox(rs.segments.first().ctrl.first(), (1, 1)))
#check("smooth() still ends at the final waypoint", vapprox(rs.segments.first().end, (2, 0)))
#let es2 = edge((0, 0), smooth((1, 1)), smooth((2, 1)), (3, 0)).last()
#let rs2 = resolve-edge-path(es2)
#check("consecutive smooth() guides give two quads", rs2.segments.len() == 2)
#check(
  "consecutive smooth() guides hand off at their midpoint (C1 join)",
  vapprox(rs2.segments.first().end, (1.5, 1)),
)
#let mixed = resolve-edge-path(edge(
  (0, 0), smooth((1, 1)), (2, 0), (3, 0), smooth((4, 1)), (5, 0),
).last())
#check("bare waypoints split smooth runs with exact segments", {
  (
    mixed.segments.len() == 3
      and mixed.segments.at(0).kind == "quad"
      and mixed.segments.at(1).kind == "line"
      and mixed.segments.at(2).kind == "quad"
  )
})
#check("a bare waypoint is the exact endpoint of the preceding smooth run", {
  (
    vapprox(mixed.segments.at(0).end, (2, 0))
      and vapprox(mixed.segments.at(1).end, (3, 0))
  )
})

#let rl = resolve-edge-path(edge((0, 0), (10, 0)).last())
#check("path-start-direction points along the wire", vapprox(path-start-direction(rl), (10, 0)))
#check("path-end-direction points along the wire", vapprox(path-end-direction(rl), (10, 0)))
#let stationary-controls = resolve-edge-path(
  edge((0, 0), cubic((0, 0), (2, 0), (2, 0))).last(),
)
#check(
  "path-start-direction skips a stationary first control",
  path-start-direction(stationary-controls).at(0) > 0,
)
#check(
  "path-end-direction skips a stationary last control",
  path-end-direction(stationary-controls).at(0) > 0,
)
#check(
  "path-start-direction skips zero-length leading segments",
  path-start-direction(resolve-edge-path(edge((0, 0), (0, 0), (2, 0)).last())).at(0) > 0,
)
#check(
  "path-end-direction skips zero-length trailing segments",
  path-end-direction(resolve-edge-path(edge((0, 0), (2, 0), (2, 0)).last())).at(0) > 0,
)
#let trimmed = trim-resolved(rl, 1, 2)
#check("trim-resolved pulls the start in along the tangent", vapprox(trimmed.start, (1, 0)))
#check("trim-resolved pulls the end in along the tangent", vapprox(trimmed.segments.last().end, (8, 0)))
#let over = trim-resolved(resolve-edge-path(edge((0, 0), (1, 0)).last()), 5, 5)
#check(
  "trim-resolved refuses to collapse/invert a short wire",
  over.segments.last().end.at(0) > over.start.at(0),
)
#let loop = resolve-edge-path(edge(
  (0, 0), cubic((1, 0), (0, 1), (0, 0)),
).last())
#let trimmed-loop = trim-resolved(loop, 0.2, 0.2)
#check(
  "trim-resolved handles a curved loop with coincident endpoints",
  trimmed-loop.start != loop.start and trimmed-loop.segments.last().end != loop.segments.last().end,
)
#check(
  "trim-resolved preserves a loop's cubic representation",
  trimmed-loop.segments.len() == 1
    and trimmed-loop.segments.first().kind == "cubic"
    and trimmed-loop.segments.first().ctrl.len() == 2,
)
#check(
  "trim-resolved keeps the retained loop tangents non-degenerate",
  vlen(path-start-direction(trimmed-loop)) > 0
    and vlen(path-end-direction(trimmed-loop)) > 0,
)

// A trim can be longer than the first/last segment of a routed path. Those
// short segments must be consumed rather than leaving a reversed stub behind.
#let short-leading = trim-resolved(
  resolve-edge-path(edge((0, 0), (0.1, 0), (10, 0)).last()),
  1, 0,
)
#check(
  "trim-resolved consumes a short leading line segment",
  short-leading.segments.len() == 1
    and vapprox(short-leading.start, (1, 0))
    and path-start-direction(short-leading).at(0) > 0,
)
#let short-trailing = trim-resolved(
  resolve-edge-path(edge((0, 0), (9.9, 0), (10, 0)).last()),
  0, 1,
)
#check(
  "trim-resolved consumes a short trailing line segment",
  short-trailing.segments.len() == 1
    and vapprox(short-trailing.segments.last().end, (9, 0))
    and path-end-direction(short-trailing).at(0) > 0,
)

// Long chains exercise the index-based consumption path. Whole segments are
// dropped from both ends, followed by one final slice.
#let long-chain = resolve-edge-path(
  edge(..range(101).map(index => (index, 0))).last(),
)
#let long-trimmed = trim-resolved(long-chain, 30, 20)
#check(
  "trim-resolved consumes long chains from both ends",
  vapprox(long-trimmed.start, (30, 0))
    and vapprox(long-trimmed.segments.last().end, (80, 0))
    and long-trimmed.segments.len() == 50,
)

// The same rule applies when the consumed segment is itself curved.
#let short-leading-curve = trim-resolved(
  resolve-edge-path(edge((0, 0), quad((0.03, 0), (0.1, 0)), (10, 0)).last()),
  1, 0,
)
#check(
  "trim-resolved consumes a short leading Bezier segment",
  short-leading-curve.segments.len() == 1
    and short-leading-curve.segments.first().kind == "line"
    and short-leading-curve.start.at(0) > 0.99
    and path-start-direction(short-leading-curve).at(0) > 0,
)
#let short-trailing-curve = trim-resolved(
  resolve-edge-path(edge((0, 0), (9.9, 0), quad((9.97, 0), (10, 0))).last()),
  0, 1,
)
#check(
  "trim-resolved consumes a short trailing Bezier segment",
  short-trailing-curve.segments.len() == 1
    and short-trailing-curve.segments.first().kind == "line"
    and short-trailing-curve.segments.last().end.at(0) < 9.01
    and path-end-direction(short-trailing-curve).at(0) > 0,
)

// Partial curve trims use de Casteljau: the retained segment keeps its kind
// and control-point count, and its controls remain ahead/behind the endpoints
// rather than being jumped over by a moved endpoint.
#let trimmed-quad = trim-resolved(
  resolve-edge-path(edge((0, 0), quad((0.1, 0), (10, 0))).last()),
  1, 1,
)
#check(
  "trim-resolved preserves a quadratic segment and its control point",
  trimmed-quad.segments.len() == 1
    and trimmed-quad.segments.first().kind == "quad"
    and trimmed-quad.segments.first().ctrl.len() == 1,
)
#check(
  "trim-resolved preserves forward quadratic endpoint tangents",
  path-start-direction(trimmed-quad).at(0) > 0
    and path-end-direction(trimmed-quad).at(0) > 0,
)
#check(
  "resolved paths keep one canonical geometry representation",
  "points" not in trimmed-quad
    and trimmed-quad.start != trimmed-quad.segments.first().end,
)

== node.typ — `inset: 0pt` removes padding, not size floors

#let m10 = (width: 10pt, height: 6pt)
#let boxy(inset) = styled((shape: shapes.rect, min-size: 40pt, inset: inset))
#let loose = shape-outline(boxy(4pt), [x], m10)
#let tight = shape-outline(boxy(0pt), [x], m10)
#check("a non-zero inset still honours min-size", approx-len(loose.half-width * 2, 40pt))
#check("inset: 0pt preserves the labelled min-size width floor", approx-len(tight.half-width * 2, 40pt))
#check("inset: 0pt preserves the labelled min-size height floor", approx-len(tight.half-height * 2, 40pt))
// An unlabeled node must keep the same floor, or it would disappear entirely.
#let circ = shape-outline(styled((shape: shapes.circle, min-size: 9pt, inset: 0pt)), [], (width: 0pt, height: 0pt))
#check("inset: 0pt on an unlabeled node keeps min-size (does not vanish)", approx-len(circ.radius * 2, 9pt))

== shape.typ — builders are geometry, kinds are styling

#let m = (width: 10pt, height: 6pt)
#let out(over) = shape-outline(styled(over), [x], m)

#check("shape builders are first-class functions", type(shapes.circle) == function)
#check("circle", out((shape: shapes.circle)).kind == "circle")
#check("ellipse", out((shape: shapes.ellipse)).kind == "ellipse")
#check("stadium is a maximally rounded rect", out((shape: shapes.stadium)).kind == "rect")
#check("rect", out((shape: shapes.rect)).kind == "rect")
#check("square is a rect with equal sides", {
  let o = out((shape: shapes.square))
  o.kind == "rect" and approx-len(o.half-width, o.half-height)
})
#check("triangle", out((shape: shapes.triangle)).kind == "polygon")
#check("diamond", out((shape: shapes.diamond)).kind == "polygon")
#check("hexagon", out((shape: shapes.hexagon)).kind == "polygon")
#check("trapezoid", out((shape: shapes.trapezoid)).kind == "polygon")
#check("arrow", out((shape: shapes.arrow)).kind == "polygon")
#check("empty draws nothing", out((shape: shapes.empty)).kind == "empty")
#check("bare is the label alone", out((shape: shapes.bare)).kind == "bare")

// The point of the split: a kind's geometry is a *styling*, not a fixed
// property of the kind, so any preset can be any shape.
#check(
  "a kind's geometry is not fixed to it — a preset kind can be a diamond",
  shape-outline(
    resolve-node-style("dot", node-presets, (shape: shapes.diamond)), [], m,
  ).kind == "polygon",
)

== shape.typ — a label changes the shape only if you ask

#check(
  "by default a node keeps its shape once labelled",
  out((shape: shapes.rect)).kind == shape-outline(styled((shape: shapes.rect)), [], m).kind,
)
#check(
  "shape-labelled opts in to a different labelled form",
  shape-outline(styled((shape: shapes.circle, shape-labelled: shapes.rect)), [x], m).kind == "rect",
)
#check(
  "shape-labelled is ignored while there is no label",
  shape-outline(styled((shape: shapes.circle, shape-labelled: shapes.rect)), [], m).kind == "circle",
)
#check(
  "a preset's shape-labelled is where its labelled form comes from",
  node-presets.dot.shape-labelled == shapes.stadium,
)

== shape.typ — per-axis floors and per-side padding

#let big = (width: 4pt, height: 4pt)
#check("min-width and min-height are independent", {
  let o = shape-outline(styled((shape: shapes.rect, min-width: 40pt, min-height: 12pt)), [], big)
  approx-len(o.half-width * 2, 40pt) and approx-len(o.half-height * 2, 12pt)
})
#check("min-size is shorthand for both axes", {
  let o = shape-outline(styled((shape: shapes.rect, min-size: 30pt)), [], big)
  approx-len(o.half-width * 2, 30pt) and approx-len(o.half-height * 2, 30pt)
})
#check("an explicit axis beats the min-size shorthand", {
  let st = expand-min-size((min-size: 10pt, min-width: 44pt))
  approx-len(st.min-width, 44pt) and approx-len(st.min-height, 10pt)
})
#check("inset accepts a per-side dictionary", {
  // 10pt wide label, 3pt left + 7pt right = 20pt of content width.
  let o = shape-outline(styled((shape: shapes.rect, inset: (left: 3pt, right: 7pt))), [x], m)
  approx-len(o.half-width * 2, 20pt)
})
#check("inset x/y shorthands work like Typst's", {
  let o = shape-outline(styled((shape: shapes.rect, inset: (x: 5pt, y: 2pt))), [x], m)
  approx-len(o.half-width * 2, 20pt) and approx-len(o.half-height * 2, 10pt)
})
#check("inset rest fills the sides not named", {
  let o = shape-outline(styled((shape: shapes.rect, inset: (rest: 4pt, left: 0pt))), [x], m)
  approx-len(o.half-width * 2, 14pt)
})
#check("the trapezoid's slant is a knob, not a constant", {
  let shallow = shape-outline(styled((shape: shapes.trapezoid, slant: 0.1, min-size: 20pt)), [], big)
  let steep = shape-outline(styled((shape: shapes.trapezoid, slant: 0.9, min-size: 20pt)), [], big)
  shallow.points.first().at(1) != steep.points.first().at(1)
})
#check("the arrow's tip fraction is a knob", {
  let blunt = shape-outline(styled((shape: shapes.arrow, tip: 0.1, min-size: 20pt)), [], big)
  let sharp = shape-outline(styled((shape: shapes.arrow, tip: 0.8, min-size: 20pt)), [], big)
  blunt.points.at(1).at(0) != sharp.points.at(1).at(0)
})

== style.typ — layering

#check("a preset fills from the shared defaults", {
  let st = resolve-node-style("ghost", node-presets)
  st.shape == shapes.bare and st.rotate == 0deg
})
#check("later layers win", {
  resolve-node-style("dot", node-presets, (fill: red), (fill: blue)).fill == blue
})
#check("an unknown kind still resolves to the defaults", {
  resolve-node-style("nope", node-presets).shape == node-defaults.shape
})

== style.typ — edges layer the same way nodes do

#let wire(..over) = resolve-edge-style(
  (preset: none, style: (:), stroke: auto) + over.named(), (:), presets: edge-presets,
)
#check("an edge with no preset is the defaults", wire().stroke == edge-defaults.stroke)
#check("a preset changes the wire", wire(preset: "thick").stroke != edge-defaults.stroke)
#check("a preset can carry a highlight", wire(preset: "alert").highlight == palette.alert)
#check(
  "a preset can carry a two-sided highlight",
  wire(preset: "duo").highlight == (palette.alert, palette.warn),
)
#check("highlight:none explicitly disables a preset highlight", {
  let e = edge((0, 0), (1, 0), preset: "alert", highlight: none).last()
  resolve-edge-style(e, (:), presets: edge-presets).highlight == ()
})
#check("a per-edge style beats the preset", {
  wire(preset: "thick", style: (stroke: 9pt + black)).stroke == 9pt + black
})
#check("a direct stroke: beats everything", {
  wire(preset: "thick", style: (stroke: 9pt + black), stroke: 2pt + red).stroke == 2pt + red
})
#check("diagram-wide overrides sit between preset and per-edge style", {
  let s = resolve-edge-style(
    (preset: "plain", style: (:), stroke: auto),
    (highlight-width: 8pt),
    presets: edge-presets,
  )
  approx-len(s.highlight-width, 8pt)
})
#check("clip is a style knob now", edge-defaults.clip == true)
#check(
  "default wires end exactly at their endpoints and miter waypoint joins",
  edge-defaults.stroke.cap == "butt" and edge-defaults.stroke.join == "miter",
)
#check("edge labels expose background and padding styles", {
  let s = wire(style: (label-fill: yellow, label-inset: 3pt, label-size: 8pt))
  s.label-fill == yellow and approx-len(s.label-inset, 3pt) and approx-len(s.label-size, 8pt)
})

== utility.typ — the rest of the vector vocabulary

#check("vscale", vscale((2, 3), 2) == (4, 6))
#check("vmid is the midpoint", vapprox(vmid((0, 0), (4, 2)), (2, 1)))
#check("vperp rotates a quarter turn", vapprox(vperp((1, 0)), (0, 1)))
#check("vperp is orthogonal to its input", approx(vperp((3, 4)).at(0) * 3 + vperp((3, 4)).at(1) * 4, 0))
#check("vunit has length 1", approx(vlen(vunit((3, 4))), 1))
#check("vunit keeps direction", vapprox(vunit((3, 4)), (0.6, 0.8)))
#check("vunit leaves the zero vector alone (no division by zero)", vunit((0, 0)) == (0, 0))

== style.typ — per-kind style merging

#check(
  "merge-per-kind combines two different keys of the same kind",
  merge-per-kind((a: (fill: 1)), (a: (stroke: 2))) == (a: (fill: 1, stroke: 2)),
)
#check(
  "merge-per-kind lets the override win on a shared key",
  merge-per-kind((a: (fill: 1)), (a: (fill: 2))) == (a: (fill: 2)),
)
#check(
  "merge-per-kind passes through kinds only one side mentions",
  merge-per-kind((a: (fill: 1)), (b: (fill: 2))) == (a: (fill: 1), b: (fill: 2)),
)
#check(
  "a later min-size overrides an earlier explicit axis",
  merge-per-kind(
    (a: (min-width: 30pt)),
    (a: (min-size: 20pt)),
  ).a == (min-width: 20pt, min-height: 20pt),
)
#check(
  "a later explicit axis overrides an earlier min-size on that axis only",
  merge-per-kind(
    (a: (min-size: 20pt)),
    (a: (min-width: 30pt)),
  ).a == (min-width: 30pt, min-height: 20pt),
)

== diagram.typ — baseline anchoring (the math-axis fix)

// `bounds.bottom` is the screen-pt distance from the diagram's y = 0 line
// down to the box's bottom edge, so the shift is that distance minus the
// math axis height. No percentage, and no dependence on the box's height —
// which is precisely why diagrams of different sizes align with each other.
#let bnds(top, bottom) = (left: 0pt, right: 0pt, top: top, bottom: bottom)

#check(
  "a symmetric diagram reproduces the old 50%-of-height value",
  approx-len(baseline-shift(bnds(-10pt, 10pt), 0, 1cm, 0pt), 10pt),
)
#check(
  "the axis height is subtracted from the shift",
  approx-len(baseline-shift(bnds(-10pt, 10pt), 0, 1cm, 2pt), 8pt),
)
#check(
  "extra content ABOVE y = 0 does not move the anchor (the old bug)",
  approx-len(baseline-shift(bnds(-100pt, 10pt), 0, 1cm, 0pt), 10pt),
)
#check(
  "extra content BELOW y = 0 does move it, by exactly that much",
  approx-len(baseline-shift(bnds(-10pt, 30pt), 0, 1cm, 0pt), 30pt),
)
#check(
  "anchor: 1 aligns the y = 1 line instead, one unit further up",
  approx-len(baseline-shift(bnds(-10pt, 10pt), 1, 1cm, 0pt), 10pt + 1cm),
)
#check("the math axis constant is the standard 0.25em", math-axis-height == 0.25em)

== geometry.typ — `inset:` resolution

#check(
  "a bare number applies to all four sides, in diagram units",
  resolve-inset(2, 10pt) == (left: 20pt, right: 20pt, top: 20pt, bottom: 20pt),
)
#check(
  "a length is taken as-is, not multiplied by the unit",
  resolve-inset(3pt, 10pt) == (left: 3pt, right: 3pt, top: 3pt, bottom: 3pt),
)
#check(
  "x/y set the axes",
  resolve-inset((x: 1, y: 2), 10pt) == (left: 10pt, right: 10pt, top: 20pt, bottom: 20pt),
)
#check(
  "rest fills in whatever is unspecified",
  resolve-inset((left: 1, rest: 0), 10pt) == (left: 10pt, right: 0pt, top: 0pt, bottom: 0pt),
)
#check(
  "a specific side beats the axis it belongs to",
  resolve-inset((x: 1, left: 5), 10pt) == (left: 50pt, right: 10pt, top: 0pt, bottom: 0pt),
)
#check(
  "sides may mix diagram units and absolute lengths",
  resolve-inset((left: 1, right: 4pt, rest: 0), 10pt).right == 4pt,
)

== style.typ — stroke scaling

#check("scale-stroke leaves a factor of 1 alone", scale-stroke(0.6pt + red, 1) == 0.6pt + red)
#check("scale-stroke passes none/auto through", scale-stroke(none, 2) == none and scale-stroke(auto, 2) == auto)
#check("scale-stroke doubles a stroke's thickness", approx-len(scale-stroke(0.6pt + red, 2).thickness, 1.2pt))
#check("scale-stroke keeps the paint", scale-stroke(0.6pt + red, 2).paint == red)
#check("scale-stroke keeps the dash pattern", scale-stroke((paint: red, thickness: 1pt, dash: "dashed"), 2).dash != none)
#check("scale-stroke handles a dictionary spec", approx-len(scale-stroke((paint: red, thickness: 1pt), 3).thickness, 3pt))
#check("scale-stroke handles a bare length", approx-len(scale-stroke(2pt, 1.5), 3pt))
// A colour-only stroke has no explicit thickness, so it scales from Typst's
// 1pt default rather than being left un-scaled.
#check("scale-stroke scales a colour-only stroke from the 1pt default", approx-len(scale-stroke(red, 2).thickness, 2pt))
#check(
  "miter bounds use Typst's full-thickness miter-limit ratio",
  approx-len(stroke-outset(2pt + black, miter: true), 8pt),
)

== diagram.typ — deferred endpoint resolution

// Pure: it takes the laid-out lookup tables rather than reading global state.
#let fake-gate = gate(2, 3, [U], legs: (left: 1, right: 2)).first()
#let gate-outline = (kind: "rect", half-width: 10pt, half-height: 8pt, radius: 0pt)
#let outlines = ((node-key(fake-gate)): ((node: fake-gate, outline: gate-outline),))
#let names = (n: dot(5, 6, name: "n").first())
#let resolve(e) = resolve-deferred-waypoints(e.last(), outlines, names, 10pt)

#let e-rel = resolve(edge((1, 1), rel(2, -1)))
#check("rel() offsets from the preceding waypoint", vapprox(e-rel.waypoints.last().end, (3, 0)))
#let e-chain = resolve(edge((0, 0), rel(1, 0), rel(0, 2)))
#check(
  "a chain of rel()s each builds on the one before",
  vapprox(e-chain.waypoints.at(1).end, (1, 0)) and vapprox(e-chain.waypoints.at(2).end, (1, 2)),
)
#let e-smooth-rel = resolve(edge(
  (0, 0), smooth(rel(1, 1)), rel(1, -1),
))
#check(
  "smooth() preserves deferred relative waypoint resolution",
  e-smooth-rel.waypoints.at(1).smooth
    and resolve-edge-path(e-smooth-rel).segments.first().kind == "quad",
)
#let e-ref = resolve(edge(ref("n"), (0, 0)))
#check("ref() resolves to the named node's position", vapprox(e-ref.waypoints.first().end, (5, 6)))
#check("ref() also becomes the clip target, so the wire stops at its outline", e-ref.waypoints.first().clip-to != none)
// hw = 10pt over a 10pt unit is exactly one diagram unit left of centre.
#let e-port = resolve(edge(port(fake-gate, "left"), (0, 0)))
#check("port() resolves onto the rendered box's edge", vapprox(e-port.waypoints.first().end, (1, 3)))
#let e-port2 = resolve(edge(port(fake-gate, "right", 1), (0, 0)))
#check("a right-side port lands on the right edge", approx(e-port2.waypoints.first().end.at(0), 3))
#check(
  "two ports on one side straddle the centre line",
  resolve(edge(port(fake-gate, "right", 0), (0, 0))).waypoints.first().end.at(1)
    != e-port2.waypoints.first().end.at(1),
)
#let rotating-gate = gate(0, 0, [R], legs: (right: 1)).first()
#let grouped-port-edge = group(
  rotate: 90deg,
  edge(port((rotating-gate,), "right"), rel(1, 0)),
).first()
#let grouped-gate = grouped-port-edge.waypoints.first().node
#let grouped-outlines = (
  (node-key(grouped-gate)): ((node: grouped-gate, outline: gate-outline),),
)
#let resolved-grouped-port = resolve-deferred-waypoints(
  grouped-port-edge,
  grouped-outlines,
  (:),
  10pt,
)
#check(
  "group rotation carries a deferred port from the right side to the top",
  vapprox(resolved-grouped-port.waypoints.first().end, (0, 0.8)),
)
#check(
  "group rotation composes the port with its following relative vector",
  vapprox(resolved-grouped-port.waypoints.last().end, (0, 1.8)),
)
#check(
  "an edge with no deferred waypoints is returned untouched",
  resolve-deferred-waypoints(edge((0, 0), (1, 1)).last(), (:), (:), 10pt) == edge((0, 0), (1, 1)).last(),
)

== diagram.typ — highlight joins

// Offset joints are intersections of displaced segment lines. This keeps the
// band exactly 2pt from both legs instead of narrowing it at a bend.
#let right-turn = offset-polyline(
  ((0pt, 0pt), (10pt, 0pt), (10pt, 10pt)),
  2pt,
)
#check(
  "a right-angle offset has an exact miter joint",
  vapprox-len(right-turn.at(1), (8pt, 2pt)),
)
#let oblique-turn = offset-polyline(
  ((0pt, 0pt), (10pt, 0pt), (16pt, 8pt)),
  2pt,
)
#check(
  "an oblique offset stays the requested distance from both legs",
  vapprox-len(oblique-turn.at(1), (9pt, 2pt)),
)
#check(
  "the opposite band receives the symmetric miter",
  vapprox-len(
    offset-polyline(
      ((0pt, 0pt), (10pt, 0pt), (10pt, 10pt)),
      -2pt,
    ).at(1),
    (12pt, -2pt),
  ),
)

#line(length: 100%)
#context text(fill: green.darken(20%), weight: "bold")[All #n-checks.get().first() checks passed.]
