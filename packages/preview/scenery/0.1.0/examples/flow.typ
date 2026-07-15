// 2D-mode diagram: a labelled flow graph proving that flat figures share the
// exact same pipeline as the 3D scenes. `camera-2d()` passes (x, y) straight
// through, so spheres become shaded node discs and arrows become 2D connectors —
// no projection, no depth foreshortening, same `build-scene` / `render-scene`.
#import "@preview/scenery:0.1.0": sphere, arrow, label, build-scene
#import "@preview/scenery:0.1.0": camera-2d, render-scene

#set page(width: auto, height: auto, margin: 0.5cm)
#set text(font: "New Computer Modern", size: 9pt)

#let node-color = rgb("#6485a6")
#let accent = rgb("#cc8963")

// The scenery pipeline itself, as a left-to-right data-flow of stages.
#let nodes = (
  (name: [primitives], at: (0, 0), color: node-color),
  (name: [build-scene], at: (2.6, 0), color: node-color),
  (name: [sort-prims], at: (5.2, 0), color: node-color),
  (name: [render], at: (7.8, 0), color: node-color),
)

#let discs = nodes.map(n => sphere(n.at("at"), 0.5, color: n.color))
#let names = nodes.map(n => label((n.at("at").at(0), n.at("at").at(1) + 0.95), n.name))

// Forward arrows between consecutive stages, plus a "camera" feedback loop.
#let flow = ()
#for i in range(nodes.len() - 1) {
  let a = nodes.at(i).at("at")
  let b = nodes.at(i + 1).at("at")
  flow.push(arrow((a.at(0) + 0.6, a.at(1)), (b.at(0) - 0.6, b.at(1)), color: luma(70)))
}

#let scene = build-scene(
  ..flow,
  ..discs,
  ..names,
  // a camera annotation feeding the sort stage from below
  arrow((5.2, -1.7), (5.2, -0.6), color: accent),
  label((5.2, -2.0), text(fill: accent)[camera]),
)

#render-scene(scene, camera-2d(), width: 12cm)
