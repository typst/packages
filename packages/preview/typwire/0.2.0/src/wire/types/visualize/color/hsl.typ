#import "../../../utils.typ": is-debug-assert

#let type-name = "color-hsl"

/// Encode an HSL color into a wire-compatible dictionary.
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
  /// The lightness component of the color.
  ///
  /// -> ratio
  lightness,
  /// The alpha (transparency) component of the color.
  ///
  /// -> ratio
  alpha,
  /// The wire format being encoded for. Unused -- `hsl` has the same
  /// shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(hue) == std.angle,
      message: "hsl.encode: hue must be of type angle",
    )
    assert(
      type(saturation) == std.ratio,
      message: "hsl.encode: saturation must be of type ratio",
    )
    assert(
      type(lightness) == std.ratio,
      message: "hsl.encode: lightness must be of type ratio",
    )
    assert(
      type(alpha) == std.ratio,
      message: "hsl.encode: alpha must be of type ratio",
    )
  }

  (
    typwire-type: type-name,
    hue: hue.rad(),
    saturation: saturation / 100%,
    lightness: lightness / 100%,
    alpha: alpha / 100%,
  )
}

/// Decode a wire-compatible dictionary into an HSL color.
///
/// -> color
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `hsl` decodes the same
  /// way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "hsl.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.hue) == std.float,
      message: "hsl.decode: value.hue must be of type float, Found "
        + str(type(value.hue)),
    )
    assert(
      type(value.saturation) == std.float,
      message: "hsl.decode: value.saturation must be of type float, Found "
        + str(type(value.saturation)),
    )
    assert(
      type(value.lightness) == std.float,
      message: "hsl.decode: value.lightness must be of type float, Found "
        + str(type(value.lightness)),
    )
    assert(
      type(value.alpha) == std.float,
      message: "hsl.decode: value.alpha must be of type float, Found "
        + str(type(value.alpha)),
    )
  }

  color.hsl(
    value.hue * 1rad,
    value.saturation * 100%,
    value.lightness * 100%,
    value.alpha * 100%,
  )
}
