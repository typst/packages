// Generates docs/img/curves.svg — a visual key to the five curve controls
// an edge. Regenerate with:
//   typst compile --root . --ignore-system-fonts docs/img/curves.typ docs/img/curves.svg
#import "../../src/lib.typ" as typ
#let diagram = typ.diagram
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 8pt)

// Same sizes a real theme would use for a circular node and an arrow-shaped
// one — chosen so the from:/to: panel's boundary-anchor ratios below stay
// simple, exactly as they would for any theme using these shapes at these
// sizes.
#let dot = typ.node-type("dot", base-style: (shape: typ.shapes.circle, fill: aqua.lighten(70%), stroke: 0.6pt + teal, min-size: 9pt, inset: 4pt))
#let pointer = typ.node-type("pointer", base-style: (shape: typ.shapes.arrow, fill: luma(220), stroke: 0.6pt + black, min-size: 11pt, inset: 3pt))

#let dotted = (paint: gray, thickness: .4pt, dash: "dotted")
#let dot-style = (shape: typ.shapes.circle, fill: red, stroke: none, min-size: 3pt, inset: 0pt)

// Dotted guide lines from each endpoint to a control point, so you can see
// how the handle relates to the resulting curve. The control-point marker
// itself is passed in (rather than created here) because two same-kind
// nodes at one position de-duplicate — in the `smooth()` panel the marker
// *is* the waypoint.
#let guide(from-pt, ctrl, to-pt) = {
  import typ: *
  edge(from-pt, ctrl, stroke: dotted, clip: false)
  edge(ctrl, to-pt, stroke: dotted, clip: false)
}
#let mark(pt) = typ.node(pt.at(0), pt.at(1), style: dot-style)

#table(
  columns: 5,
  align: center + horizon,
  stroke: none,
  column-gutter: 10pt,
  row-gutter: 4pt,
  [*`bend: 0.5`*],
  [*`smooth(point)`*],
  [*`from:` / `to:`*],
  [*`quad(c, end)`*],
  [*`cubic(c1, c2, end)`*],
  diagram(scale: 1.1cm, {
    import typ: *
    edge(dot(0, 0), dot(2, 0), bend: 0.5)
    edge(dot(0, 0), dot(2, 0), stroke: dotted, clip: false)
  }),
  diagram(scale: 1.1cm, {
    import typ: *
    // the red marker doubles as the waypoint the wire curves around
    edge(dot(0, 0), smooth(node(1, 1, style: dot-style)), dot(2, 0))
    guide((0, 0), (1, 1), (2, 0))
  }),
  diagram(scale: 1.1cm, {
    import typ: *
    // Boundary anchors in diagram units. Node geometry and the coordinate
    // unit scale together, so these ratios stay constant here.
    let dot-right = 4.5pt / 1cm
    let pointer-right = (11pt / (1 + .32)) / 1cm
    edge(dot(0, 0), pointer(0, 1), from: right, to: right)
    edge((dot-right, 0), (dot-right + 0.5, 0), stroke: dotted, clip: false)
    edge((pointer-right, 1), (pointer-right + 0.5, 1), stroke: dotted, clip: false)
    mark((dot-right + 0.5, 0))
    mark((pointer-right + 0.5, 1))
  }),
  diagram(scale: 1.1cm, {
    import typ: *
    edge(dot(0, 0), quad((1, 1), dot(2, 0)))
    guide((0, 0), (1, 1), (2, 0))
    mark((1, 1))
  }),
  diagram(scale: 1.1cm, {
    import typ: *
    edge(dot(0, 0), cubic((0.2, 1.1), (1.8, 1.1), dot(2, 0)))
    edge((0, 0), (0.2, 1.1), stroke: dotted, clip: false)
    edge((2, 0), (1.8, 1.1), stroke: dotted, clip: false)
    mark((0.2, 1.1))
    mark((1.8, 1.1))
  }),
  [perpendicular\ offset from\ the chord],
  [waypoint is the\ control point;\ curve misses it],
  [handles start at\ exact right anchors;\ terminal lands\ on the tip],
  [same as smooth\ with one guide,\ written explicitly],
  [one handle out of\ each endpoint],
)
