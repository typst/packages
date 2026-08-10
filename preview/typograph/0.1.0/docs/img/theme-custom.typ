// Generates docs/img/theme-custom.svg — the "write your own theme" walkthrough
// and the box/gate theming example from the Theming chapter.
//   typst compile --root . --ignore-system-fonts docs/img/theme-custom.typ docs/img/theme-custom.svg
#import "../../src/lib.typ" as typ
#set page(width: auto, height: auto, margin: 8pt)
#set text(size: 8pt)

#let pentagon = typ.node-type("pentagon")
#let link = typ.edge-type("link")

#let my-theme = typ.theme(
  node-presets: (
    pentagon: (
      shape: typ.shapes.regular(vertices: 5, rotate: -90deg),
      fill: rgb("#f2e8ff"),
      stroke: 0.8pt + purple,
      min-size: 13pt,
      inset: 3pt,
    ),
  ),
  edge-presets: (
    link: (stroke: (paint: gray, dash: "dashed")),
  ),
)

#let diagram = typ.diagram.with(theme: my-theme)

#align(center, stack(spacing: 10pt,
  diagram(scale: 1.1cm, {
    let p = pentagon(0, 0, label: [P])
    let q = typ.node(1.4, 0, label: [Q], style: (shape: typ.shapes.circle, fill: rgb("#c7e9ff"), stroke: 0.8pt + navy, min-size: 13pt, inset: 3pt))
    link(p, q)
  }),
  diagram(scale: 1.1cm, { import typ: *; gate(0, 0, [ideal], style: (stroke: 1pt + purple)) }),
))
