#import "../../../utils.typ": is-debug-assert

#let type-name = "color-linear-rgb"

/// Encode a linear RGB color into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The red component of the color.
  ///
  /// -> ratio
  r,
  /// The green component of the color.
  ///
  /// -> ratio
  g,
  /// The blue component of the color.
  ///
  /// -> ratio
  b,
  /// The alpha (transparency) component of the color.
  ///
  /// -> ratio
  alpha,
  /// The wire format being encoded for. Unused -- `linear-rgb` has the
  /// same tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(r) == std.ratio,
      message: "linear-rgb.encode: r must be of type ratio",
    )
    assert(
      type(g) == std.ratio,
      message: "linear-rgb.encode: g must be of type ratio",
    )
    assert(
      type(b) == std.ratio,
      message: "linear-rgb.encode: b must be of type ratio",
    )
    assert(
      type(alpha) == std.ratio,
      message: "linear-rgb.encode: alpha must be of type ratio",
    )
  }

  (
    typwire-type: type-name,
    r: r / 100%,
    g: g / 100%,
    b: b / 100%,
    alpha: alpha / 100%,
  )
}

/// Decode a wire-compatible dictionary into a linear RGB color.
///
/// -> color
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `linear-rgb` decodes
  /// the same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "linear-rgb.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
    assert(
      type(value.r) == std.float,
      message: "linear-rgb.decode: value.r must be of type float, Found "
        + str(type(value.r)),
    )
    assert(
      type(value.g) == std.float,
      message: "linear-rgb.decode: value.g must be of type float, Found "
        + str(type(value.g)),
    )
    assert(
      type(value.b) == std.float,
      message: "linear-rgb.decode: value.b must be of type float, Found "
        + str(type(value.b)),
    )
    assert(
      type(value.alpha) == std.float,
      message: "linear-rgb.decode: value.alpha must be of type float, Found "
        + str(type(value.alpha)),
    )
  }

  color.linear-rgb(
    value.r * 100%,
    value.g * 100%,
    value.b * 100%,
    value.alpha * 100%,
  )
}
