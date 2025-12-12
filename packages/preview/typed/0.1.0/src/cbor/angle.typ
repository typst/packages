/// Encode an angle into a CBOR-compatible dictionary.
///
/// - angle (angle): A angle.
/// -> dictionary
#let encode(angle) = {
  assert(type(angle) == std.angle, message: "angle.encode: angle must be of type angle")

  (
    "typed-type": "angle",
    "radians": angle.rad(),
  )
}
