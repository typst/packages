/// Clamps a numeric value between bounds.
///
/// - value (length): Value to clamp.
/// - min (length): Lower bound.
/// - max (length): Upper bound.
/// -> length
#let _clamp(value, min, max) = {
  if value < min { min } else if value > max { max } else { value }
}

/// Resolves a potentially relative length to an absolute length.
///
/// - value (length): Length value to resolve.
/// -> length
#let _resolve-length(value) = measure(box(width: value)[]).width
