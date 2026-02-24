#let std-style = (
  stroke: stroke(),
  scale: 1,
  debug: false,

  // connections
  connection-size: 0.3,
  bezier-connection: 0.7,
  //  bridges
  bridge-space: 0.4,
  bridge-offset: 0,
  bridge-type: none,
  bridge-color: rgb(0, 0, 0, 0),

  // translation
  transform: (),

  // canvas
  background: none,
  padding: 0pt,
  canvas-stroke: none,
)

#let knot-bool-style = (
  stroke: true,
  scale: true,
  debug: true,

  connection-size: true,
  bezier-connection: true,
  bridge-space: true,
  bridge-offset: true,
  bridge-type: true,
  bridge-color: true,

  transform: true,
  pre-transform: true,
)

#let edge-bool-style = (
  stroke: true,
  scale: true,
  debug: (
    edges: true,
    bezier: true,
    arc: true,
    bend: true,
  ),
)

#let node-bool-style = (
  scale: true,
  debug: (
    nodes: true,
    connections: true,
    connect: true,
  ),

  connection-size: true,
  bezier-connection: true,
  bridge-space: true,
  bridge-offset: true,
  bridge-type: true,
  bridge-color: true,
)
