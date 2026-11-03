#import "@preview/vmesh:0.1.0": draw-mesh

#set page(
  width: auto,
  height: auto,
)

#let mesh-2d = read("../assets/typst.msh2")

#figure(
  draw-mesh(
    mesh-2d,
    width: 3.5cm,
  ),
  // caption: [A 2D mesh.],
) <my-mesh-plot>
