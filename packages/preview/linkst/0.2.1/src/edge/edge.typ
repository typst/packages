#let edge(
  start-node,
  end-node,
  style: (:),
  stroke: none,
  layer: 0,
  orientation: 0deg,
  
  // edge types
  mode: auto,
  arc-abs: none,
  arc-rel: none,
  bezier-abs: none,
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
  orientation: orientation,
  
  // edge types
  edge-type: "straight",
  mode:mode,
  arc-abs: arc-abs,
  arc-rel: arc-rel,
  bezier-abs: bezier-abs,
  bezier-rel: bezier-rel,
  bend: bend,
  
)
