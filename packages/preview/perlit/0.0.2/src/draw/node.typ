#import "@preview/cetz:0.4.2": canvas, draw

#import "../utils/helpers.typ": get_color
#import "../utils/components.typ": label
#import "file.typ": handle_file

#let draw_nodes(nodes, ..args) = {
  import draw: *
  for (id, node) in nodes {
    rect(
      (node.x, node.y),
      (node.bx, node.by),
      stroke: get_color(node),
      fill: if node.type == "file" {} else if node.type == "group" { get_color(node).transparentize(95%) } else {
        get_color(node).lighten(85%)
      },
    )

    if node.type == "text" {
      content(node.anchors.center, node.text)
    } else if node.type == "group" {
      label(node.anchors.northwest, node.label, get_color(node), justify: "west")
    } else if node.type == "file" {
      content(node.anchors.center, handle_file(node, ..args))
    }
  }
}

#let parse_nodes(nodes) = {
  let min-x = calc.min(..nodes.map(n => n.x))
  let max-x = calc.max(..nodes.map(n => n.x + n.width))
  let min-y = calc.min(..nodes.map(n => n.y))
  let max-y = calc.max(..nodes.map(n => n.y + n.height))

  let span-x = max-x - min-x
  let span-y = max-y - min-y
  let scale = calc.max(span-x, span-y)


  let norm(val, min) = {
    if scale == 0 { 0 } else { (val - min) / scale }
  }

  let get_x(node) = norm(node.x, min-x)
  let get_y(node) = -norm(node.y, min-y)
  let get_width(node) = node.width / scale
  let get_height(node) = node.height / scale

  let create_anchors(node) = {
    (
      node
        + (
          anchors: (
            north: ((node.x + node.bx) / 2, node.y),
            northeast: (node.bx, node.y),
            east: (node.bx, (node.y + node.by) / 2),
            southeast: (node.bx, node.by),
            south: ((node.x + node.bx) / 2, node.by),
            southwest: (node.x, node.by),
            west: (node.x, (node.y + node.by) / 2),
            northwest: (node.x, node.y),
            center: ((node.x + node.bx) / 2, (node.y + node.by) / 2),
          ),
        )
    )
  }

  nodes
    .map(node => (
      node
        + (
          x: get_x(node),
          y: get_y(node),
          width: get_width(node),
          height: get_height(node),
          bx: get_x(node) + get_width(node),
          by: get_y(node) - get_height(node),
        )
    ))
    .map(create_anchors)
}
