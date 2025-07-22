#import "@preview/cetz:0.4.0"
#import cetz.draw: *
#import cetz.vector: *
#import "resolve-type.typ": resolve-type

#let help-line-color = rgb("#b341bd88")
#let help-line-dot-radius = 0.02
#let help-line-stroke = (thickness: 0.5pt, paint: help-line-color)
#let help-line-stroke-dashed = (thickness: 0.5pt, paint: help-line-color, dash: "dashed")


#let arc-circle(
  position,
  start,
  stop,
  radius: 1,
  ..args,
) = {
  let rel-start = scale((calc.cos(start), calc.sin(start)), radius)
  let translated-position = add(position, rel-start)

  arc(
    translated-position,
    start: start,
    stop: stop,
    radius: radius,
    ..args,
  )
}

/// Filter for the connection points from the notes that are from this edge
#let find-connection-points(node1, node2, index) = {
  if node1.index == node2.index {

    let c1 = node1.connection-points.find(p => (p.edge == index))
    let c2 = node1.connection-points.find(p => p.edge == index and c1.index != p.index)
    return (c1, c2)

  } else {

    let c1 = node1.connection-points.find(p => (p.edge == index))
    let c2 = node2.connection-points.find(p => p.edge == index)
    return (c1, c2)

  }
}


#let draw-straight(
  edge,
  node1,
  node2,
  style,
) = {

  let (node1-connection-point, node2-connection-point) = find-connection-points(node1, node2, edge.index)

  line(
    node1-connection-point.position,
    node2-connection-point.position,
    name: "edge",
    stroke: style.stroke,
  )
  
}

#let draw-quadratic-bezier(edge, node1, node2, style) = {

  let (node1-connection-point, node2-connection-point) = find-connection-points(node1, node2, edge.index)

  bezier(
    node1-connection-point.position,
    node2-connection-point.position,
    edge.bezier-abs.at(0),
    name: "edge",
    stroke: style.stroke,
  )

  if style.debug.bezier {
    line(
      node1-connection-point.position,
      edge.bezier-abs.at(0),
      node2-connection-point.position,
      stroke: help-line-stroke-dashed,
    )
    
    circle(
      node1-connection-point.position,
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )
    
    circle(
      edge.bezier-abs.at(0),
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )
    
    circle(
      node2-connection-point.position,
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )
  }
}

#let draw-cubic-bezier(edge, node1, node2, style) = {

  let (node1-connection-point, node2-connection-point) = find-connection-points(node1, node2, edge.index)

  bezier(
    node1-connection-point.position,
    node2-connection-point.position,
    edge.bezier-abs.at(0),
    edge.bezier-abs.at(1),
    name: "edge",
    stroke: style.stroke,
  )

  if style.debug.bezier {
    line(
      "edge.start",
      "edge.ctrl-0",
      "edge.ctrl-1",
      "edge.end",
      stroke: help-line-stroke-dashed,
    )

    circle(
      "edge.start",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )

    circle(
      "edge.ctrl-0",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )

    circle(
      "edge.ctrl-1",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )
    
    circle(
      "edge.end",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )
  }
}

#let draw-arc(edge, node1, node2, style) = {

}

#let draw-bend(edge, node1, node2, style) = {

  let (node1-connection-point, node2-connection-point) = find-connection-points(node1, node2, edge.index)

  edge.bend = calc.rem(edge.bend / 1deg, 180) * 1deg
  if edge.bend == 0deg {
    return draw-straight(edge, node1, node2, style)
  }

  arc-through(
    node1-connection-point.position,
    sub(node1-connection-point.position, scale(node1-connection-point.normal, 10e-6)), // to align to the normal
    node2-connection-point.position,
    name: "edge",
    stroke: style.stroke,
  )

  if style.debug.bend {
    if node1.index == node2.index {
      anchor("b1", node1-connection-point.position)
      anchor("b2", node1.position)
      anchor("b3", node2-connection-point.position)
    } else {
      anchor("b1", node1.position)
      anchor("b2", "edge.origin")
      anchor("b3", node2.position)
    }

    line(
      "b1",
      "b2",
      "b3",
      stroke: help-line-stroke-dashed,
    )

    circle(
      "b1",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )

    circle(
      "b2",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )

    circle(
      "b3",
      radius: help-line-dot-radius,
      fill: help-line-color,
      stroke: none,
    )

    get-ctx(ctx => {
      let (ctx, origin) = cetz.coordinate.resolve(ctx, "edge.origin")

      let circle-radius = dist(node1.position, origin)

      if edge.bend > 0deg {
        cetz.angle.angle(
          "b2",
          "b3",
          "b1",
          radius: circle-radius / 10,
          stroke: help-line-stroke
        )
      } else {
        cetz.angle.angle(
          "b2",
          "b1",
          "b3",
          radius: circle-radius / 10,
          stroke: help-line-stroke
        )
      }
    })
  }
}

#let draw-edge(
  edge,
  node1,
  node2,
) = {
  if(edge.edge-type == "arc") {
    draw-arc(edge, node1, node2, edge.style)
  } else if(edge.edge-type == "bend") {
    draw-bend(edge, node1, node2, edge.style)
  } else if(edge.edge-type == "quadratic-bezier") {
    draw-quadratic-bezier(edge, node1, node2, edge.style)
  } else if(edge.edge-type == "cubic-bezier") {
    draw-cubic-bezier(edge, node1, node2, edge.style)
  } else {
    draw-straight(edge, node1, node2, edge.style)
  }

  if edge.style.debug.edges {

    circle(
      "edge.mid",
      radius: 0.15,
      name: "node",
      fill: color.linear-rgb(45.64%, 58.41%, 72.31%, 53.4%),
      stroke: none,
    )

    content(
      "edge.mid",
      [#text(6pt * edge.style.scale)[#edge.index]]
    )

  }
}