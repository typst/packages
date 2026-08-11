#import "@preview/cetz:0.4.2": canvas, draw

#import "../utils/constants.typ": side_map
#import "../utils/paths.typ": beautify_paths, line_at
#import "../utils/helpers.typ": get_color
#import "../utils/components.typ": label

#let get_start(edge, nodes) = {
  nodes.at(edge.fromNode).anchors.at(side_map.at(edge.fromSide))
}

#let get_target(edge, nodes) = {
  nodes.at(edge.toNode).anchors.at(side_map.at(edge.toSide))
}

#let set_arrow(edge) = {
  import draw: *

  if "fromEnd" in edge and edge.fromEnd == "arrow" {
    set-style(mark: (symbol: ">", end: ">"))
  } else if "toEnd" in edge and edge.toEnd == "none" {
    set-style(mark: (symbol: none, end: none))
  } else {
    set-style(mark: (symbol: none, end: ">"))
  }
}

#let create_bezier_points(edge, nodes, velocity: float) = {
  let start = get_start(edge, nodes)
  let target = get_target(edge, nodes)

  let get_velocity(point, side) = {
    let velocity_map = (
      "top": (point.at(0), point.at(1) + velocity),
      "bottom": (point.at(0), point.at(1) - velocity),
      "left": (point.at(0) - velocity, point.at(1)),
      "right": (point.at(0) + velocity, point.at(1)),
    )

    velocity_map.at(side)
  }

  let start_ctrl = get_velocity(start, edge.fromSide)
  let target_ctrl = get_velocity(target, edge.toSide)

  (
    start: start_ctrl,
    target: target_ctrl,
  )
}

#let draw_edges(edges, nodes, curve: false, ..args) = {
  import draw: *

  for (id, edge) in edges {
    set_arrow(edge)

    let (start, target, ctrl_points) = edge

    if curve {
      bezier(
        start,
        target,
        ctrl_points.start,
        ctrl_points.target,
        name: edge.id,
        stroke: get_color(edge),
      )
    } else {
      line(
        start,
        ..ctrl_points.values(),
        target,
        name: edge.id,
        stroke: get_color(edge),
      )
    }
  }
}

#let parse_edges(edges, nodes, ..args) = {
  edges.map(edge => (
    edge
      + beautify_paths(
        get_start(edge, nodes),
        get_target(edge, nodes),
        create_bezier_points(edge, nodes, ..args),
        edge,
      )
  ))
}
