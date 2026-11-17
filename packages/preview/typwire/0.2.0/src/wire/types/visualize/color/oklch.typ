#import "../../../utils.typ": is-debug-assert

#let type-name = "color-oklch"

/// Encode an OKLCH color into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The lightness component of the color.
  ///
  /// -> ratio
  lightness,
  /// The chroma component of the color.
  ///
  /// -> float
  chroma,
  /// The hue component of the color.
  ///
  /// -> angle
  hue,
  /// The alpha (transparency) component of the color.
  ///
  /// -> ratio
  alpha,
  /// The wire format being encoded for. Unused -- `oklch` has the same
  /// shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(lightness) == std.ratio,
      message: "oklch.encode: lightness must be of type ratio",
    )
    assert(
      type(chroma) == std.float,
      message: "oklch.encode: chroma must be of type float",
    )
    assert(
      type(hue) == std.angle,
      message: "oklch.encode: hue must be of type angle",
    )
    assert(
      type(alpha) == std.ratio,
      message: "oklch.encode: alpha must be of type ratio",
    )
  }

  (
    typwire-type: type-name,
    lightness: lightness / 100%,
    chroma: chroma,
    hue: hue.rad(),
    alpha: alpha / 100%,
  )
}

/// Decode a wire-compatible dictionary into an OKLCH color.
///
/// -> color
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `oklch` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "oklch.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.lightness) == std.float,
      message: "oklch.decode: value.lightness must be of type float, Found "
        + str(type(value.lightness)),
    )
    assert(
      type(value.chroma) == std.float,
      message: "oklch.decode: value.chroma must be of type float, Found "
        + str(type(value.chroma)),
    )
    assert(
      type(value.hue) == std.float,
      message: "oklch.decode: value.hue must be of type float, Found "
        + str(type(value.hue)),
    )
    assert(
      type(value.alpha) == std.float,
      message: "oklch.decode: value.alpha must be of type float, Found "
        + str(type(value.alpha)),
    )
  }

  color.oklch(
    value.lightness * 100%,
    value.chroma,
    value.hue * 1rad,
    value.alpha * 100%,
  )
}
