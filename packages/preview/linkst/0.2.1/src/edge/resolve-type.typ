#import "@preview/cetz:0.4.0"
#import cetz.vector: *

#let resolve-bezier-grade(edge) = {
  let points = if edge.bezier-abs != none {edge.bezier-abs} else {edge.bezier-rel}

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
  if(edge.arc-abs != none) {
    return "arc"
  } else if(edge.bend != none) {
    return "bend"
  } else if(edge.bezier-abs != none or edge.bezier-rel != none) {
    return if(resolve-bezier-grade(edge) == "quadratic") { "quadratic-bezier" } else { "cubic-bezier" }
  } else {
    return "straight"
  }
}