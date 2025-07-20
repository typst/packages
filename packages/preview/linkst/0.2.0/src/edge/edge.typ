#let edge(
  start-node,
  end-node,
  style: (:),
  stroke: none,
  layer: 0,
  
  // edge types
  mode: auto,
  arc: none,
  bezier: none,
  bezier-rel: none,
  bend: none,
  
) = (
  type: "edge",
  index: none,
  start-node: start-node,
  end-node: end-node,
  start-connection-point: none,
  end-connection-point: none,
  
  style: { if stroke != none { style.stroke = stroke }; style },
  layer: layer,
  
  // edge types
  edge-type: "straight",
  mode:mode,
  arc: arc,
  bezier: bezier,
  bezier-rel: bezier-rel,
  bend: bend,
  
)
