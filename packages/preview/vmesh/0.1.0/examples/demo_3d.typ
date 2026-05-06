#import "@preview/vmesh:0.1.0": draw-mesh

#set page(
  width: auto,
  height: auto,
)

#let mesh-typst-3d = read("../assets/typst_3d.msh2")
#let my-colors = ("1": blue.lighten(20%), "2": white.lighten(20%), "3": green.lighten(20%))

#figure(
  draw-mesh(
    mesh-typst-3d,
    light-direction: (-0.5, 0.5, 0.7),
    width: 4.5cm,
    pitch: -45deg,
    yaw: 25deg,
    color-map: my-colors,
    mesh-stroke: 0.1pt + black,
    show-axes: false,
    show-domain-ids: false,
    show-node-ids: false,
    show-element-ids: false,
  ),
  // caption: [A 3D mesh.],
) <mesh-typst-3d>
