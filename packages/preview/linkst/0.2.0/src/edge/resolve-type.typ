#import "@preview/cetz:0.4.0"
#import cetz.vector: *

#let resolve-bezier-grade(edge) = {
  let points = if edge.bezier != none {edge.bezier} else {edge.bezier-rel}

  if(points.len() == 1) {
    return "quadratic"
  } else if(points.len() == 2) {
    return "cubic"
  } else {
    panic("Bezier edge must have 1 or 2 control points")
  }
}

/// Resolves the type of the edge based on its properties.
#let resolve-type(edge) = {
  if(edge.arc != none) {
    return "arc"
  } else if(edge.bend != none) {
    return "bend"
  } else if(edge.bezier != none or edge.bezier-rel != none) {
    return if(resolve-bezier-grade(edge) == "quadratic") { "quadratic-bezier" } else { "cubic-bezier" }
  } else {
    return "straight"
  }
}

/* #let resolve-type(edge, node1, node2) = {
  let type = "straight"

  if(edge.arc != none) {
    type = "arc"
  } else if(edge.bend != none) {
    type = "bend"
  } else if(edge.bezier != none) {
    if(resolve-bezier-grade(edge.bezier) == "quadratic") { type =  "quadratic-bezier" } else { type =  "cubic-bezier" }
  } else if(edge.bezier-rel != none) {
    if(resolve-bezier-grade(edge.bezier-rel) == "quadratic") { type =  "quadratic-bezier" } else { type =  "cubic-bezier" }
    edge.bezier = resolve-relative(edge, edge.bezier-rel, node1, node2)
  }

  return (type, edge)
} */