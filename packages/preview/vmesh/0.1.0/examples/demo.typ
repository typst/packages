#import "../src/lib.typ": draw-mesh
#import "@preview/subpar:0.2.2"

#set page(
  paper: "a5",
)
#set par(justify: true)

Make sure you have generated the `.msh2` file using Gmsh's 2.2 format with
\`gmsh typst.geo -2 -format msh2 -o typst.msh2\`.

The vmesh package allows one to read a `.msh2` file and draw it as a Typst figure through CeTZ, with options for customizing the appearance of the mesh.

#let mesh-data = read("../assets/typst.msh2")

#figure(
  draw-mesh(
    mesh-data,
    width: 1.5cm,
  ),
  caption: [A demo `.msh2` file.],
) <my-mesh-plot>

As we can clearly see in @my-mesh-plot, the mesh has been successfully loaded and rendered. As shown in @my-mesh-plot-2, we can also turn on the display of node and element numbers.

#let mesh-data-2 = read("../assets/m1.msh2")
#let my-colors = ("1": blue.lighten(20%), "2": red.lighten(20%), "3": green.lighten(20%))
#let my-edges = ("4": 1pt + red, "5": 1pt + purple, "6": 1pt + green)

#figure(
  draw-mesh(
    mesh-data-2,
    width: 5.5cm,
    height: auto,
    edge-stroke-map: my-edges,
    mesh-stroke: 0.1pt + white,
    color-map: my-colors,
    show-node-ids: true,
    show-element-ids: true,
    id-size: 7pt,
  ),
  caption: [A demo `.msh` file (`m1.msh2`) with highlighted boundaries, colored domains, node and element IDs.],
) <my-mesh-plot-2>

As shown in @my-mesh-plot-3 and @my-mesh-plot-4, the package also supports 3D meshes!

#let mesh-data-3 = read("../assets/t14.msh2")

#figure(
  draw-mesh(
    mesh-data-3,
    light-direction: (-0.5, 0.5, 0.7),
    width: 7cm,
    height: auto,
    pitch: -45deg,
    yaw: 45deg,
    mesh-stroke: 0.1pt + black,
    show-axes: false,
    show-domain-ids: false,
    show-node-ids: false,
    show-element-ids: false,
  ),
  caption: [A 3D mesh.],
) <my-mesh-plot-3>

#let mesh-data-4 = read("../assets/t5.msh2")
#let mesh-data-5 = read("../assets/ball8.msh2")
#let mesh-data-6 = read("../assets/part_sphere.msh2")

#subpar.grid(
  figure(
    draw-mesh(
      mesh-data-4,
      light-direction: (-0.5, 0.5, 0.7),
      width: 3cm,
      height: auto,
      pitch: -45deg,
      yaw: 45deg,
      mesh-stroke: 0.1pt + black,
      show-domain-ids: false,
      show-node-ids: false,
      show-element-ids: false,
    ),
  ),
  <a>,

  figure(
    draw-mesh(
      mesh-data-5,
      light-direction: (-0.5, 0.5, 0.7),
      width: 3cm,
      height: auto,
      pitch: -45deg,
      yaw: 45deg,
      mesh-stroke: 0.1pt + black,
      show-domain-ids: false,
      show-node-ids: false,
      show-element-ids: false,
    ),
  ),
  <b>,

  figure(
    draw-mesh(
      mesh-data-6,
      light-direction: (-0.5, -0.5, 0.7),
      width: 3cm,
      height: auto,
      pitch: -125deg,
      yaw: 45deg,
      mesh-stroke: 0.1pt + black,
      show-domain-ids: false,
      show-node-ids: false,
      show-element-ids: false,
    ),
  ),
  <b>,

  columns: (1fr, 1fr, 1fr),
  caption: [More 3D meshes.],
  label: <my-mesh-plot-4>,
)
