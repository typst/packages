#import "/src/cetz.typ": vector

/// Clip a single component of a list of vectors between [min, max]
/// and returns a list of clipped shapes.
#let clip-component-axis(component, min, max, points) = {
  if points == () {
    return ()
  }

  // List of tuples (index, ratio, inside)
  let intersections = ()

  // Collect all intersections
  let inside = auto
  for (i, pt) in points.enumerate() {
    let v = pt.at(component, default: min)
    let this-inside = min <= v and v <= max

    if inside == auto {
      inside = this-inside
    } else if inside != this-inside {
      inside = not inside
      if this-inside {
        intersections.push((i, (v - min) / (max - min), inside))
      } else {
        intersections.push((i, (v - min) / (max - min), inside))
      }
    }
  }

  // Clip intersections
  if intersections != () {
    let shapes = ()

    let start = none
    let start-ratio = none
    for (i, ratio, this-inside) in intersections {
      if this-inside {
        start = i
        start-ratio = ratio
      } else {
        let start-pt = if start == 0 or start == points.len() - 1 {
          points.at(start)
        } else {
          vector.lerp(points.at(start - 1), points.at(start), start-ratio)
        }

        let end-pt = if i == points.len() - 1 {
          points.last()
        } else {
          vector.lerp(points.at(i - 1), points.at(i), ratio)
        }

        shapes.push((
          start-pt, ..points.slice(start, i), end-pt,
        ))
        start = none
      }
    }

    return shapes
  }

  return (points,)
}
