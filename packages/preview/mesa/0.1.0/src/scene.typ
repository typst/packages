#import "@preview/cetz:0.5.2": draw
#import "kernel.typ" as kernel

#let _validate-volume(volume, index) = {
  assert(
    type(volume) == dictionary,
    message: "volume " + str(index) + " must be a dictionary",
  )
  assert(
    "shapes" in volume,
    message: "volume " + str(index) + " requires shapes",
  )
  assert(
    "bottom" in volume
      and "top" in volume
      and volume.top > volume.bottom,
    message: "volume " + str(index) + " requires top > bottom",
  )
}

#let deposit(volumes, shapes, thickness) = {
  if volumes.len() == 0 {
    return ((
      shapes: shapes,
      bottom: 0,
      top: thickness,
    ),)
  }

  let remaining = shapes
  let result = ()
  for volume in volumes.sorted(key: volume => -volume.top) {
    if remaining.len() > 0 {
      let landed = kernel.intersection(remaining, volume.shapes)
      if landed.len() > 0 {
        result.push((
          shapes: landed,
          bottom: volume.top,
          top: volume.top + thickness,
        ))
        remaining = kernel.difference(remaining, volume.shapes)
      }
    }
  }
  assert(
    remaining.len() == 0,
    message: "deposition mask extends beyond the existing sample",
  )
  result
}

#let etch(volumes, shapes, depth) = {
  let rays = ((shapes: shapes, remaining: depth),)
  let result = ()

  for volume in volumes.sorted(key: volume => -volume.top) {
    let untouched = volume.shapes
    let next-rays = ()
    let thickness = volume.top - volume.bottom

    for ray in rays {
      let overlap = kernel.intersection(ray.shapes, volume.shapes)
      let bypass = kernel.difference(ray.shapes, volume.shapes)
      if bypass.len() > 0 {
        next-rays.push((
          shapes: bypass,
          remaining: ray.remaining,
        ))
      }
      if overlap.len() > 0 {
        untouched = kernel.difference(untouched, overlap)
        if ray.remaining < thickness {
          let etched = volume
          etched.shapes = overlap
          etched.top = volume.top - ray.remaining
          result.push(etched)
        } else if ray.remaining > thickness {
          next-rays.push((
            shapes: overlap,
            remaining: ray.remaining - thickness,
          ))
        }
      }
    }

    if untouched.len() > 0 {
      let kept = volume
      kept.shapes = untouched
      result.push(kept)
    }
    rays = next-rays
  }

  result
}

#let _render-faces(volumes, view, render-face: none) = {
  for (index, volume) in volumes.enumerate() {
    _validate-volume(volume, index)
  }

  let faces = kernel.scene-surfaces(volumes, view)
  for (index, face) in faces.enumerate() {
    if face.normal.at(2) >= 0 {
      let volume = volumes.at(face.material)
      draw.on-layer(-1 + index / (faces.len() + 1), {
        if render-face == none {
          let fill = if face.normal.at(2) > 0 {
            volume.at("top-fill", default: rgb("#b8d6ed"))
          } else {
            volume.at("side-fill", default: rgb("#91b4ce"))
          }
          draw.compound-path({
            for contour in face.contours {
              draw.line(..contour, close: true)
            }
          }, fill: fill, fill-rule: "even-odd", stroke: none)
        } else {
          render-face(face, volume)
        }
      })
    }
  }
}

#let edge-styles = (
  outline: rgb("#263843") + .5pt,
  material: rgb("#263843") + .4pt,
  internal: rgb("#49606e") + .3pt,
)

#let _normal-edge-role(edge) = {
  if edge.visibility == "occluded" or edge.kind == "smooth" {
    none
  } else if edge.kind == "bevel" {
    "internal"
  } else if edge.kind == "material" {
    "material"
  } else if edge.interior {
    "internal"
  } else {
    "outline"
  }
}

#let _render-edges(volumes, view, styles, render-edge: none) = {
  draw.on-layer(100, {
    for edge in kernel.scene-topology(volumes, view) {
      let role = _normal-edge-role(edge)
      if role != none {
        if render-edge == none {
          draw.line(
            edge.start,
            edge.end,
            stroke: styles.at(role),
          )
        } else {
          render-edge(edge, volumes, styles.at(role))
        }
      }
    }
  })
}

#let render(
  volumes,
  view: none,
  styles: edge-styles,
  render-face: none,
  render-edge: none,
) = {
  assert(view != none, message: "3D scene rendering requires a view")
  _render-faces(volumes, view, render-face: render-face)
  _render-edges(volumes, view, styles, render-edge: render-edge)
}

#let render-section(volumes, y) = {
  for (index, volume) in volumes.enumerate() {
    _validate-volume(volume, index)
  }

  for volume in volumes.sorted(key: volume => volume.bottom) {
    let intervals = kernel.cross-section(volume.shapes, y)
    for interval in intervals {
      draw.rect(
        (interval.first(), volume.bottom),
        (interval.last(), volume.top),
        fill: volume.at(
          "section-fill",
          default: volume.at("side-fill", default: rgb("#91b4ce")),
        ),
        stroke: volume.at(
          "stroke",
          default: rgb("#263843") + .5pt,
        ),
      )
    }
  }
}

#let cut-y(volumes, y, keep: "positive") = {
  let result = ()
  for volume in volumes {
    let shapes = kernel.clip-y(volume.shapes, y, keep: keep)
    if shapes.len() > 0 {
      let clipped = volume
      clipped.shapes = shapes
      result.push(clipped)
    }
  }
  result
}

#let cut-line(volumes, line, keep: "left") = {
  assert(
    type(line) == array and line.len() == 2,
    message: "cut line must contain two points",
  )
  let result = ()
  for volume in volumes {
    let shapes = kernel.clip-line(
      volume.shapes,
      line.first(),
      line.last(),
      keep: keep,
    )
    if shapes.len() > 0 {
      let clipped = volume
      clipped.shapes = shapes
      result.push(clipped)
    }
  }
  result
}

#let topology-debug-styles = (
  outline: (
    paint: rgb("#263843"),
    thickness: .8pt,
  ),
  material: (
    paint: rgb("#e98a15"),
    thickness: .6pt,
  ),
  occluded: (
    paint: rgb("#7c3aed"),
    thickness: .45pt,
    dash: "dashed",
  ),
  internal: (
    paint: black,
    thickness: .45pt,
    dash: "dashed",
  ),
)

#let render-topology-debug(volumes, view: none) = {
  assert(view != none, message: "topology debug rendering requires a view")
  let debug-volumes = volumes.map(volume => {
    let debug-volume = volume
    debug-volume.stroke = none
    let debug-fill = volume.at(
      "debug-fill",
      default: rgb("#b8d6ed"),
    ).transparentize(45%)
    debug-volume.top-fill = debug-fill
    debug-volume.side-fill = debug-fill
    debug-volume
  })
  _render-faces(debug-volumes, view)

  draw.on-layer(100, {
    for edge in kernel.scene-topology(volumes, view) {
      let role = if edge.visibility == "occluded" {
        "occluded"
      } else if edge.kind == "material" {
        "material"
      } else if edge.interior or edge.kind == "smooth" {
        "internal"
      } else {
        "outline"
      }
      draw.line(
        edge.start,
        edge.end,
        stroke: topology-debug-styles.at(role),
      )
    }
  })
}
