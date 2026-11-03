// sci-brain-slides . CeTZ gadgets (optional, requires @preview/cetz)
// ====================================================================
// Small drawing helpers for the diagrams that recur in scientific slides:
// tensor-network nodes, finite-automaton states, boxes, and connectors.
// Each is called *inside* a `canvas{ … }` block where CeTZ coordinates apply.
//
// Radii are in CANVAS UNITS (not pt), so node size scales with the canvas
// `length` and demo coordinates stay collision-free at any scale. Space nodes
// ≥ 2.5 units apart. Edges are undirected by default; pass
// `mark: (end: "straight")` for an arrow.
//
//   #import "@preview/cetz:0.5.2": canvas
//   #import "@preview/sci-brain-slides:0.1.0": cetz-gadgets as make
//   #let D = make(palette)
//   #canvas(length: 1cm, {
//     import "@preview/cetz:0.5.2": draw
//     D.tensor((0,0), "A", [$A$])
//     D.tensor((3,0), "B", [$B$])
//     D.edge("A", "B")
//   })

#import "@preview/cetz:0.5.2": draw

#let make(pal) = (
  // Tensor-network node: small filled circle + label at its centre.
  "tensor": (loc, name, label, radius: 0.45) => {
    draw.circle(loc, radius: radius, name: name,
      fill: color.mix((pal.primary, 18%), (pal.paper, 82%)), stroke: 1.1pt + pal.primary)
    draw.content(name, text(fill: pal.ink)[#label])
  },

  // Automaton state. Accept states get a double ring.
  "automaton-state": (loc, name, label, accept: false, radius: 0.55) => {
    draw.circle(loc, radius: radius, name: name,
      fill: pal.paper, stroke: 1.1pt + pal.primary)
    if accept {
      draw.circle(loc, radius: radius - 0.12, stroke: 0.8pt + pal.primary)
    }
    draw.content(name, text(fill: pal.ink)[#label])
  },

  // Connector between two named anchors. Undirected by default (tensor legs);
  // pass mark: (end: "straight") for automaton/flow arrows.
  "edge": (from, to, mark: none, stroke: none) => {
    draw.line(from, to, mark: mark,
      stroke: if stroke == none { 1pt + pal.text_soft } else { stroke })
  },

  // Boxed node for flowcharts / architecture diagrams (auto-sized to its label).
  // Connect via side anchors ("in.east", "out.west") so edges stop at borders.
  "flowbox": (loc, name, label) => {
    draw.content(loc, text(fill: pal.ink)[#label], name: name,
      frame: "rect", fill: color.mix((pal.primary, 12%), (pal.paper, 88%)),
      stroke: 1pt + pal.primary,
      padding: (left: 10pt, right: 10pt, top: 6pt, bottom: 6pt))
  },
)
