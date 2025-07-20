#import "@preview/cetz:0.4.0"
#import cetz.vector: *
#import "resolve-type.typ": resolve-type
#import "../utils/rotations.typ": *


#let node-border-point(node, point) = {
  let n = norm(sub(point, node.position))
  let border-point = scale(n, node.style.connection-size)
  return (border-point, neg(n))
}


#let straight(node, other-node, edge, index, is-start-node) = {
  if(edge.start-node == edge.end-node) {
    panic("Straight edge cannot be a loop")
  } else {
    let n = norm(sub(other-node.position, node.position))
    let border-point = scale(n, node.style.connection-size)
    let intersection-point = add(node.position, border-point)

    let connection-point = (position: intersection-point, edge: index, normal: neg(n), edge-style: edge.style)
    return (connection-point,)
  }
}

#let arc(node, other-node, edge, index, is-start-node) = {
  
}

#let quadratic-bezier(node, other-node, edge, index, is-start-node) = {
  let ctrl = edge.bezier.at(0)

  if(edge.start-node == edge.end-node) {
    panic("Quadratic bezier edge cannot be a loop")
  } else {
    let (border-point, n) = node-border-point(node, ctrl)
    let intersection-point = add(node.position, border-point)
    let connection-point = (position: intersection-point, edge: index, normal: n, edge-style: edge.style)
    return (connection-point,)
  }
}

#let cubic-bezier(node, other-node, edge, index, is-start-node) = {
  let ctrl-1 = edge.bezier.at(0)
  let ctrl-2 = edge.bezier.at(1)

  if(edge.start-node == edge.end-node) {
    let (border-point-1, n-1) = node-border-point(node, ctrl-1)
    let (border-point-2, n-2) = node-border-point(node, ctrl-2)
    let intersection-point-1 = add(node.position, border-point-1)
    let intersection-point-2 = add(node.position, border-point-2)
    let connection-point-1 = (position: intersection-point-1, edge: index, normal: n-1, edge-style: edge.style)
    let connection-point-2 = (position: intersection-point-2, edge: index, normal: n-2, edge-style: edge.style)
    return (connection-point-1, connection-point-2)
  } else {
    let (border-point, n) = node-border-point(node, if is-start-node { ctrl-1 } else { ctrl-2 })
    let intersection-point = add(node.position, border-point)
    let connection-point = (position: intersection-point, edge: index, normal: n, edge-style: edge.style)
    return (connection-point,)
  }
}

#let bend(node, other-node, edge, index, is-start-node) = {
  if(edge.start-node == edge.end-node) {
    panic("Bend edge cannot be a loop")
  } else {

    let start-node = if is-start-node { node } else { other-node }
    let end-node = if is-start-node { other-node } else { node }

    
    let theta = edge.bend

    // normalize theta to be between -180 and 180 degrees
    if theta > 180deg {
      theta = theta - 360deg
    } else if theta < -180deg {
      theta = theta + 360deg
    }
    theta = calc.rem(theta / 1deg, 180) * 1deg

    // infinitely large arc needed, so straight line
    if theta == 0deg {
      return straight(node, other-node, edge, index, is-start-node)
    }

    // explenation:
    // https://www.desmos.com/calculator/tj4mz7w2b3
    
    let r = node.style.connection-size
    let d = dist(node.position, other-node.position) / 2
    let l = d / calc.tan(theta)
    let k = calc.sqrt(l * l + d * d)
    let a = calc.asin(r / (2 * k))
    let g = calc.abs(theta) - 2 * a
    let center = (d, -l)

    let s = if is-start-node { g + 90deg } else { 90deg - g } * (theta / calc.abs(theta))
    let p = add((calc.cos(s) * k, calc.sin(s) * k), center)
    let n = if is-start-node { rot--90(norm(sub(p, center))) } else { rot-90(norm(sub(p, center))) }
    n = scale(n, (theta / calc.abs(theta)))

    let node-d = sub(end-node.position, start-node.position)
    let node-angle = calc.atan2(node-d.at(0), node-d.at(1))
    p = rotate-z(p, node-angle)
    p = add(p, start-node.position)
    n = rotate-z(n, node-angle)

    let connection-point = (position: p, edge: index, normal: n, edge-style: edge.style)
    return (connection-point,)
  }
}

#let get-connection-points(node, other-node, edge, index, is-start-node) = {
  if(edge.edge-type == "arc") {
    return arc(node, other-node, edge, index, is-start-node)
  } else if(edge.edge-type == "bend") {
    return bend(node, other-node, edge, index, is-start-node)
  } else if(edge.edge-type == "quadratic-bezier") {
    return quadratic-bezier(node, other-node, edge, index, is-start-node)
  } else if(edge.edge-type == "cubic-bezier") {
    return cubic-bezier(node, other-node, edge, index, is-start-node)
  } else if(edge.edge-type == "straight") {
    return straight(node, other-node, edge, index, is-start-node)
  }
}