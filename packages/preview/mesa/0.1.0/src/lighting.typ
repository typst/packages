#import "geometry.typ": (
  add,
  subtract,
  scale,
  dot,
  cross,
  unit,
  clip-polygon,
  signed-polygon-area,
  polygon-area,
  point-in-convex,
)

#let direction(angles) = {
  let azimuth = angles.at("azimuth", default: 0deg)
  let elevation = angles.at("elevation", default: 0deg)
  let horizontal = calc.cos(elevation)

  (
    calc.sin(azimuth) * horizontal,
    calc.cos(azimuth) * horizontal,
    -calc.sin(elevation),
  )
}

#let intensity(light) = {
  let value = light.at("intensity", default: 0.25)
  let value = if type(value) == ratio {
    value / 100%
  } else {
    value
  }
  assert(
    type(value) in (int, float) and value >= 0 and value <= 1,
    message: "light intensity must be between 0 and 1",
  )
  value
}

#let toward-light(light) = scale(direction(light), -1)

#let face-brightness(normal, shading, light, visibility: 1) = {
  if shading == "none" {
    return 1
  }
  assert(
    shading in ("flat", "fancy"),
    message: "shading must be \"none\", \"flat\", or \"fancy\"",
  )

  let incoming = toward-light(light)
  let cosine = calc.max(0, dot(normal, incoming))
  let ambient = 1 - intensity(light)
  let direct = intensity(light) * visibility * cosine
  ambient + direct
}

#let _face-basis(face) = {
  let origin = face.points.first()
  let u = unit(subtract(face.points.at(1), origin))
  let v = unit(cross(face.normal, u))
  (
    origin: origin,
    u: u,
    v: v,
  )
}

#let _to-face-plane(point, basis) = {
  let relative = subtract(point, basis.origin)
  (
    dot(relative, basis.u),
    dot(relative, basis.v),
    0,
  )
}

#let _shadow-polygons(receiver, receiver-index, faces, toward-light) = {
  let denominator = dot(receiver.normal, toward-light)
  if denominator <= 1e-6 {
    return ()
  }

  let basis = _face-basis(receiver)
  let polygons = ()
  for (occluder-index, occluder) in faces.enumerate() {
    if occluder-index != receiver-index {
      let distance = point => dot(
        subtract(point, basis.origin),
        receiver.normal,
      )
      let clipped = clip-polygon(occluder.points, distance)
      if clipped.len() >= 3 {
        let projected = clipped.map(point => {
          let amount = distance(point) / denominator
          subtract(point, scale(toward-light, amount))
        })
        let local = projected.map(point => _to-face-plane(point, basis))
        if signed-polygon-area(local) < 0 {
          local = local.rev()
        }
        if polygon-area(local) > 1e-8 {
          polygons.push(local)
        }
      }
    }
  }
  polygons
}

#let face-visibility(receiver, receiver-index, faces, shading, light) = {
  if shading == "none" or intensity(light) == 0 {
    return 1
  }

  let incoming = toward-light(light)
  if dot(receiver.normal, incoming) <= 1e-6 {
    return 0
  }
  let polygons = _shadow-polygons(
    receiver,
    receiver-index,
    faces,
    incoming,
  )
  if polygons.len() == 0 {
    return 1
  }

  let basis = _face-basis(receiver)
  let center = receiver.points.map(
    point => _to-face-plane(point, basis),
  ).fold(
    (0, 0, 0),
    (sum, point) => add(sum, point),
  )
  center = scale(center, 1 / receiver.points.len())
  if polygons.any(polygon => point-in-convex(center, polygon)) {
    0
  } else {
    1
  }
}
