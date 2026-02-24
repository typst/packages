#import "@preview/cetz:0.4.0"
#import cetz.vector: *
#import "rotations.typ": rot-90

#let resolve-relative(edge, node1, node2) = {

  let coordinates
  if edge.edge-type == "quadratic-bezier" or edge.edge-type == "cubic-bezier" { coordinates = edge.bezier-rel }

  if coordinates == none {
    return edge
  } else {
    coordinates = coordinates.map(p => {
      let t = p.at(0) // map -1-1 between node1 and node2
      let k = p.at(1) // same scale but orthogonal and

      t = (t + 1) / 2 // normalize to 0-1
      let d = sub(node2.position, node1.position)
      if d == (0, 0) { d = (-calc.sin(edge.orientation), calc.cos(edge.orientation)); t -= 0.5 }
      let pt = add(node1.position, scale(d, t))

      let pk = scale(rot-90(d), k)

      return add(pt, pk)
    })

    if edge.edge-type == "quadratic-bezier" or edge.edge-type == "cubic-bezier" { edge.bezier-abs = coordinates }

    return edge
  }

}