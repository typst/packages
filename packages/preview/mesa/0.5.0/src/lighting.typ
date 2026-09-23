#import "geometry.typ": (
  scale,
  dot,
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
