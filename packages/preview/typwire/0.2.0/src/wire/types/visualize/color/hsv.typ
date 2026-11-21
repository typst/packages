#import "../../../utils.typ": is-debug-assert

#let type-name = "color-hsv"

/// Encode an HSV color into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The hue component of the color.
  ///
  /// -> angle
  hue,
  /// The saturation component of the color.
  ///
  /// -> ratio
  saturation,
  /// The value (brightness) component of the color.
  ///
  /// -> ratio
  value,
  /// The alpha (transparency) component of the color.
  ///
  /// -> ratio
  alpha,
  /// The wire format being encoded for. Unused -- `hsv` has the same
  /// shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(hue) == std.angle,
      message: "hsv.encode: hue must be of type angle",
    )
    assert(
      type(saturation) == std.ratio,
      message: "hsv.encode: saturation must be of type ratio",
    )
    assert(
      type(value) == std.ratio,
      message: "hsv.encode: value must be of type ratio",
    )
    assert(
      type(alpha) == std.ratio,
      message: "hsv.encode: alpha must be of type ratio",
    )
  }

  (
    typwire-type: type-name,
    hue: hue.rad(),
    saturation: saturation / 100%,
    value: value / 100%,
    alpha: alpha / 100%,
  )
}

/// Decode a wire-compatible dictionary into an HSV color.
///
/// -> color
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `hsv` decodes the same
  /// way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "hsv.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.hue) == std.float,
      message: "hsv.decode: value.hue must be of type float, Found "
        + str(type(value.hue)),
    )
    assert(
      type(value.saturation) == std.float,
      message: "hsv.decode: value.saturation must be of type float, Found "
        + str(type(value.saturation)),
    )
    assert(
      type(value.value) == std.float,
      message: "hsv.decode: value.value must be of type float, Found "
        + str(type(value.value)),
    )
    assert(
      type(value.alpha) == std.float,
      message: "hsv.decode: value.alpha must be of type float, Found "
        + str(type(value.alpha)),
    )
  }

  color.hsv(
    value.hue * 1rad,
    value.saturation * 100%,
    value.value * 100%,
    value.alpha * 100%,
  )
}
