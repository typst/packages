#import "/src/lib.typ" as typ
#set page(height: auto, margin: 8pt)

// Local fixtures standing in for a real theme's kinds — same shapes a ZX
// theme would use (circle/stadium, triangle, square, arrow, bare,
// flat-triangle mirrored pair, trapezoid), declared directly so this file
// needs no theme at all.
#let dot = typ.node-type("dot", base-style: (shape: typ.shapes.circle, shape-labelled: typ.shapes.stadium, fill: aqua.lighten(60%), stroke: 0.6pt + navy, min-size: 9pt, inset: 4pt))
#let wedge = typ.node-type("wedge", flippable: true, base-style: (shape: typ.shapes.triangle, fill: white, stroke: 0.6pt + black, min-size: 17pt, inset: 2pt))
#let sq = typ.node-type("sq", base-style: (shape: typ.shapes.square, fill: yellow.lighten(60%), stroke: 0.6pt + black, min-size: 8pt, inset: 2pt))
#let arrow = typ.node-type("arrow", flippable: true, base-style: (shape: typ.shapes.arrow, fill: luma(220), stroke: 0.6pt + black, min-size: 11pt, inset: 3pt))
#let label-only = typ.node-type("label-only", base-style: (shape: typ.shapes.bare))
#let tri = typ.node-type("tri", base-style: (shape: typ.shapes.flat-triangle, fill: white, stroke: 0.6pt + black, min-width: 26pt, min-height: 20pt, inset: 3pt))
#let tri-flip = typ.node-type("tri-flip", base-style: (shape: typ.shapes.flat-triangle, flip: true, fill: white, stroke: 0.6pt + black, min-width: 26pt, min-height: 20pt, inset: 3pt))
#let trap = typ.node-type("trap", flippable: true, base-style: (shape: typ.shapes.trapezoid, fill: white, stroke: 0.6pt + black, min-width: 10pt, min-height: 22pt, inset: 4pt))

#let diagram = typ.diagram

= empty
#diagram({})

= single node
#diagram({ dot(0, 0) })

= unqualified names via a scoped `import typ: *`
#diagram({
  import typ: *
  edge(dot(0, 0, label: $e^(i a x)$), dot(1, 0))
})

= labeled nodes (pill) + basic edge
#diagram({
  import typ: *
  let a = dot(0, 0, label: $alpha$)
  let b = dot(1, 0)
  edge(a, b)
  edge(a, (-1, 0))
  edge(b, (2, 0))
})

= every node kind
#diagram({
  import typ: *
  let f = dot(0, 0, label: $g$)
  let w1 = wedge(1, 0)
  let h1 = sq(2, 0)
  let h2 = sq(3, 0, label: $H$)
  let m = arrow(4, 0, label: $m$)
  let s = label-only(5, 0, label: $sqrt(2)$); s // no legs, so re-emit
  let bx = box(6, 0, label: $k$, fill: luma(245), stroke: 0.5pt + gray, radius: 2pt, inset: 4pt); bx
  let g = gate(7, 0, $S(r)$)
  edge(f, w1, h1, h2, m)
  edge(m, g)
})

= a mirrored pair and a rotated trapezoid (Picturing-Quantum-Processes style)
#diagram({
  import typ: *
  edge(tri(0, 0, label: $psi$), tri-flip(1.6, 0, label: $phi$))
  let m1 = trap(0, -1.3, label: $f$)
  let m2 = trap(1.6, -1.3, label: $g$, flip: true)
  edge((-1, -1.3), m1, m2, (2.6, -1.3))
  let m3 = trap(0, -2.6, label: $f$, style: (rotate: 90deg)); m3
})

= invisible node() as a routing waypoint (sharp), and smooth():
#diagram({
  import typ: *
  edge(dot(0, 0), node(1, 1), dot(2, 0))
})
#diagram({
  import typ: *
  edge(dot(0, 0), smooth(node(1, 1)), dot(2, 0))
})
#diagram({
  import typ: *
  edge(dot(0, 0), smooth(node(0, 1)), smooth(node(3, 1)), dot(3, 0))
})

= node() is also a general styleable escape hatch
#diagram({
  import typ: *
  edge(
    node(0, 0, label: $?$, style: (
      shape: typ.shapes.circle, fill: purple.lighten(70%), stroke: 0.6pt + purple,
      min-size: 12pt, inset: 3pt,
    )),
    (1.2, 0),
  )
})

= reusable custom node type with an arbitrary public polygon builder
#let kite-shape = typ.shapes.polygon(
  ((0, -1), (1.5, 0), (0, 1), (-1.0, 0)),
  clearance: (1.0, 3.0),
  label-offset: (-0.25, 0)
)
#let kite = typ.node-type("kite", base-style: (
  shape: kite-shape, fill: purple.lighten(75%), stroke: 0.6pt + purple,
  min-size: 16pt,
))
#diagram({
  let a = kite(0, 0, label: $K$)
  typ.edge(a, dot(1, 0))
})

= a port-capable gate may use a non-rectangular shape
#diagram({
  let g = typ.gate(
    0, 0, [U], legs: (left: 2, right: 0),
    style: (shape: typ.shapes.circle),
  )
  typ.edge(typ.port(g, "left", 0), typ.rel(-1, 0))
  typ.edge(typ.port(g, "left", 1), typ.rel(-1, 0))
})

= injected edge preset and documented edge-label style controls
#let signal-theme = typ.theme(
  edge-presets: (
    signal: (stroke: 1pt + purple, highlight: purple.lighten(65%)),
  ),
)
#typ.diagram(
  theme: signal-theme,
  edge-styles: (label-size: 8pt, label-offset: 0pt),
  inset: 0pt,
  {
    typ.edge((0, 0), (2, 0), preset: "signal", label: [signal])
  },
)

= from/to bend, and bend: sugar
#table(
  columns: 2,
  stroke: none,
  align: center + horizon,
  [*default `clip: true`*],
  [*`clip: false`*],
  diagram({
    import typ: *
    let a = dot(0, 0)
    let b = arrow(0, 1, label: $tau$)
    edge(a, b, from: (right, 1.0), to: (right, 1.0))
    edge((-1, 0), a)
    edge((-1, 1), b)
  }),
  diagram({
    import typ: *
    let a = dot(0, 0)
    let b = arrow(0, 1)
    edge(a, b, from: (right, 5.0), to: (right, 5.0), clip: false)
    edge((-1, 0), a)
    edge((-1, 1), b)
  }),
)
#diagram({
  import typ: *
  let a = dot(0, 0)
  let b = dot(2, 0)
  edge(a, b, bend: 1.0)
  edge(a, b, bend: -1.0)
})

= chain edge through multiple nodes
#diagram({
  import typ: *
  let a = dot(0, 0.)
  let b = dot(0., 1.)
  let c = dot(1.25, 1.)
  let d = dot(1., 0)
  edge(a, b, c, d, a)
})

= gate with multiple ports; port() auto-captures the gate
#diagram({
  import typ: *
  let bs = gate(0, 0, $B(theta,phi)$, legs: (left: 2, right: 2))
  edge((-1, -1.0), port(bs, "left", index: 0))
  edge((-1, 1.0), port(bs, "left", index: 1))
  edge(port(bs, "right", index: 0), (1, -0.3))
  edge(port(bs, "right", index: 1), (1, 0.3))
})

= gate inset control
#diagram({
  import typ: *
  edge(gate(0, 0, $U$, inset: 0pt), gate(1.5, 0, $U$, inset: 10pt))
})

= highlight: single color and two-color split, alongside restyled wires
#diagram(grid: true, {
  import typ: *
  let a = dot(0, 0)
  let b = dot(1, 0)
  let c = dot(2, 0)
  let d = dot(1, 1)
  edge(a, b, highlight: green)
  edge(b, c, highlight: (green, red))
  edge(b, d, stroke: 1.2pt + blue)
  edge(d, (1, 2), stroke: (paint: orange, thickness: 0.9pt, dash: "dashed"))
})

= custom path elements (quad/cubic) and wire label
#diagram({
  import typ: *
  edge(
    (0, 0),
    quad((1, 1), (2, 0)),
    cubic((2.5, -0.5), (3, -1), (3.5, -1)),
    label: $C^2$,
  )
})

= font-size: global and per-node
#diagram(font-size: 12pt, {
  import typ: *
  edge(dot(0, 0, label: $alpha$), dot(1, 0, label: $beta$, style: (font-size: 7pt)))
})

= group: translate, scale, rotate
#diagram({
  import typ: *
  group(dx: 0, dy: 0, { edge(dot(0, 0), dot(1, 0)) })
  group(dx: 0, dy: 1.5, scale: 0.6, { edge(dot(0, 0), dot(1, 0)) })
  group(dx: 3, dy: 0, rotate: 90deg, { edge(dot(0, 0), dot(1, 0)) })
})

= group: a named fragment, reused and re-transformed (the reuse pattern)
#let cnot = {
  import typ: *
  let c = dot(0, 0)
  let t = dot(0, -1)
  edge(c, t) + edge((-0.7, 0), c, (0.7, 0)) + edge((-0.7, -1), t, (0.7, -1))
}
#diagram({
  typ.group(cnot)
  typ.group(dx: 2, cnot)
  typ.group(dx: 4, scale: 0.6, cnot)
  // grouping an already-grouped fragment composes
  typ.group(dy: -2, typ.group(dx: 1, cnot))
})

= place text
#diagram({
  typ.place(0, 0, $ dots.v $)
  typ.place(1, 0, [hello])
})

= style overrides
#diagram(node-styles: (dot: (fill: orange)), edge-styles: (highlight-width: 4pt), {
  import typ: *
  let a = dot(0, 0)
  let b = dot(2, 0)
  let c = gate(1, 0, $dagger$)
  edge(a, b, highlight: purple)
  c
})

= y-axis points up
#diagram(grid: true, {
  import typ: *
  edge(dot(0, 0, label: $0$), dot(0, 1, label: $1$))
})

= embedded in math: baseline centering and auto-sizing delimiters
#let lhs = diagram(scale: 0.7cm, { import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0)) })
#let rhs = diagram(scale: 0.7cm, { import typ: *; edge(dot(0, 0), dot(1, 0), dot(1, 2)) })
$ #lhs = 2 dot lr(( #rhs )) $

Inline too: a state #diagram(scale: 0.5cm, { import typ: *; edge(tri(0, 0, label: $psi$), (1, 0)) }) sits on the baseline. When I write something really long here and just keep writing and writing and writing and writing. Will this overlap with the diagram or will this be placed correctly at a distance such that this does not happen

= inset: 0pt hugs the label; unlabeled nodes keep their min-size
#diagram({
  import typ: *
  edge(
    gate(0, 0, $U$),
    gate(1.3, 0, $U$, inset: 0pt),
    gate(2.6, 0, $B(theta,phi)$, inset: 1pt),
  )
  let p = dot(0, -1.2, label: $alpha$)
  let q = box(1.3, -1.2, label: $k$, inset: 1pt, stroke: 0.5pt + black)
  let r = dot(2.6, -1.2, style: (inset: 0pt))   // unlabeled: keeps min-size
  edge(p, q, r)
})

= config(): scope-wide defaults, nesting, and per-diagram override
#typ.config(font-size: 7pt, scale: 0.8cm)[
  #diagram({ import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0, label: $beta$)) })
  #typ.config(font-size: 14pt)[
    #diagram({ import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0, label: $beta$)) })
  ]
  #diagram({ import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0, label: $beta$)) })
  #diagram(font-size: 16pt, { import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0)) })
]
#diagram({ import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0, label: $beta$)) })

= config() as a show rule, and merging of per-kind styles across levels
#[
  #show: typ.config.with(scale: 0.5cm, node-styles: (dot: (fill: orange)))
  #diagram(node-styles: (dot: (stroke: 1pt + blue)), {
    import typ: *
    edge(dot(0, 0), dot(1, 0), dot(2, 0))
  })
]

= baseline: centred on the math axis at any diagram size
#let dd(sc, ac) = diagram(scale: sc, anchor: ac, { import typ: *; edge(dot(0, 1, label: $alpha$), dot(1, 1)) })
$ - - #dd(0.35cm, 0) - - #dd(0.7cm, 1) - - #dd(1.4cm, 1) - - = B $

= scale zooms everything; scale-edges stretches only the grid
#stack(dir: ltr, spacing: 10pt,
  ..(0.5cm, 1cm, 1.5cm).map(sc =>
    diagram(scale: sc, { import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0)) })),
)
#stack(dir: ltr, spacing: 10pt,
  ..(0.6, 1, 1.8).map(se =>
    diagram(scale-edges: se, { import typ: *; edge(dot(0, 0, label: $alpha$), dot(1, 0)) })),
)
// A gate is sized in pt like every other node, so `scale-edges` spreads its
// wires without resizing the box, and `rel()` gives dead-straight leads
// without having to know where each port landed.
#stack(dir: ltr, spacing: 10pt, ..(1.0, 1.8).map(se => diagram(scale-edges: se, {
  import typ: *
  let g = gate(0, 0, $U$, legs: (left: 2, right: 2))
  edge(port(g, "left", index: 0), rel(-1, 0))
  edge(port(g, "left", index: 1), rel(-1, 0))
  edge(port(g, "right", index: 0), rel(1, 0))
  edge(port(g, "right", index: 1), rel(1, 0))
})))

= rel(): an endpoint as an offset from the previous waypoint
#diagram(grid: true, {
  import typ: *
  let a = dot(0, 0)
  edge(a, rel(1, 0))
  edge(a, rel(0, 1))
  edge(a, rel(-0.8, -0.8))
  // chains: each rel is relative to the point before it
  edge(dot(2, 0), rel(0.6, 0.6), rel(0.6, -0.6))
})

= ref(): name a node, then refer to it without a variable
#diagram({
  import typ: *
  dot(0, 0, name: "top")            // emitted directly, and named
  dot(1.4, 0, name: "right")
  edge(ref("top"), ref("right"))
  edge(ref("top"), rel(0, -1))
})

= inset: one value, per-axis, per-side, and absolute lengths
#stack(dir: ltr, spacing: 8pt,
  ..(0, 0.5, (x: 0.6, y: 0), (left: 1, rest: 0), 6pt).map(i =>
    rect(stroke: 0.4pt + red, inset: 0pt,
      diagram(inset: i, { import typ: *; edge(dot(0, 0), dot(1, 0)) }))),
)

= a gate with ports inside a transformed group (box and ports must move together)
#let gate-gadget = {
  import typ: *
  let g = gate(0, 0, $U$, legs: (left: 2, right: 2))
  edge(port(g, "left", 0), rel(-0.8, 0))
  edge(port(g, "left", 1), rel(-0.8, 0))
  edge(port(g, "right", 0), rel(0.8, 0))
  edge(port(g, "right", 1), rel(0.8, 0))
}
#diagram(scale: 1cm, {
  typ.group(gate-gadget)
  typ.group(dy: -1.5, scale: 0.6, gate-gadget)
  typ.group(dy: -3.2, scale: 1.4, gate-gadget)
})


#diagram({
  let n1 = dot(0, 0)
  let n2 = dot(2, 0)
  typ.edge(
    n1,
    typ.smooth((0, 1)),
    (1,1),
    typ.smooth((2, 1)),
    n2
  )
})
