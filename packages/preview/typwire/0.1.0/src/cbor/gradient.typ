#import "center.typ"
#import "stop.typ"

#let linear(stops, angle, space) = {
  assert(type(stops) == std.array, message: "gradient.linear: stops must be of type array")
  assert(type(angle) == std.angle, message: "gradient.linear: angle must be of type angle")
  assert(type(space) == std.str, message: "gradient.linear: space must be of type str")

   (
     "typwire-type": "gradient-linear",
     "stops": stops,
     "angle": angle,
     "space": space
   )
}

#let radial(stops, center, radius, focal-center, focal-radius, space) = {
  assert(type(stops) == std.array, message: "gradient.radial: stops must be of type array")
  assert(type(center) == std.dictionary, message: "gradient.radial: center must be of type dictionary")
  assert(type(radius) == std.ratio, message: "gradient.radial: radius must be of type ratio")
  assert(type(focal-center) == std.dictionary, message: "gradient.radial: angle must be of type dictionary")
  assert(type(focal-radius) == std.ratio, message: "gradient.radial: angle must be of type ratio")
  assert(type(space) == std.str, message: "gradient.radial: space must be of type str")

  (
    "typwire-type": "gradient-radial",
    "stops": stops,
    "center": center,
    "radius": radius,
    "focal-center": focal-center,
    "focal-radius": focal-radius,
    "space": space,
  )
}

#let conic(stops, angle, center, space) = {
  assert(type(stops) == std.array, message: "gradient.conic: stops must be of type array")
  assert(type(angle) == std.angle, message: "gradient.conic: angle must be of type angle")
  assert(type(center) == std.dictionary, message: "gradient.conic: center must be of type dictionary")
  assert(type(space) == std.str, message: "gradient.conic: space must be of type str")

  (
    "typwire-type": "gradient-conic",
    "stops": stops,
    "angle": angle,
    "center": center,
    "space": space,
  )
}

/// Encode a gradient into a CBOR-compatible dictionary.
///
/// - gradient (gradient): A gradient.
/// -> dictionary
#let encode(gradient) = {
  assert(type(gradient) == std.gradient, message: "gradient.encode: gradient must be of type gradient")

  let stops = gradient.stops().map(s => stop.encode(s.at(0), s.at(1)))
  let space = if gradient.space() == std.color.luma {
    "luma"
  } else if gradient.space() == std.color.oklab {
    "oklab"
  } else if gradient.space() == std.color.oklch {
    "oklch"
  } else if gradient.space() == std.color.linear-rgb {
    "linear-rgb"
  } else if gradient.space() == std.color.rgb {
    "rgb"
  } else if gradient.space() == std.color.cmyk {
    "cmyk"
  } else if gradient.space() == std.color.hsl {
    "hsl"
  } else if gradient.space() == std.color.hsv {
    "hsv"
  } else {
    panic("gradient.encode: Invalid gradient color space")
  }

  if gradient.kind() == std.gradient.linear {
    linear(stops, gradient.angle(), space)
  } else if gradient.kind() == std.gradient.radial {
    radial(stops, center.encode(..gradient.center()), gradient.radius(), center.encode(..gradient.focal-center()), gradient.focal-radius(), space)
  } else if gradient.kind() == std.gradient.conic {
    conic(stops, gradient.angle(), center.encode(..gradient.center()), space)
  } else {
    panic("gradient.encode: Invalid gradient type")
  }
}
