/// fixes short notation like (x, y) -> ((x, y),) and ((x, y),) -> ((x, y),) to make it compatible
#let resolve-short-not(edge) = {
  if edge.bezier-abs != none and type(edge.bezier-abs.at(0)) != array { edge.bezier-abs = (edge.bezier-abs,) }
  if edge.bezier-rel != none and type(edge.bezier-rel.at(0)) != array { edge.bezier-rel = (edge.bezier-rel,) }
  edge
}
