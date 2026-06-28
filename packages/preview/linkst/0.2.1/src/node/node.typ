#let node(
  ..position,
  style: (:),
  layer: 0,

  name: "",
  connect: auto,

  label: [],
  label-offset: (0, 0),
) = (
  type: "node",
  index: none,
  position: position,
  edges: (),
  style: style,
  layer: layer,

  name: name,
  connect: connect,
  connection-points: (),

  label: label,
  label-offset: label-offset,
)
