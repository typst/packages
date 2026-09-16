#import "@preview/vmesh:0.1.0": draw-mesh

#set page(
  width: auto,
  height: auto,
)

#let mesh-2d = read("../assets/m1.msh2")
#let my-colors = ("1": blue.lighten(20%), "2": green.lighten(20%), "3": white.lighten(20%))
#let my-edges = ("4": 1pt + red, "5": 1pt + purple, "6": 1pt + orange)

#figure(
  draw-mesh(
    mesh-2d,
    width: 3.5cm,
    edge-stroke-map: my-edges,
    color-map: my-colors,
    show-node-ids: true,
    show-element-ids: true,
    id-size: 5pt,
  ),
  // caption: [A 2D mesh.],
) <my-mesh-plot>
