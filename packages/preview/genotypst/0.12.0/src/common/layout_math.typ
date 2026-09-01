/// Clamps a numeric value between bounds.
///
/// - value (length): Value to clamp.
/// - min (length): Lower bound.
/// - max (length): Upper bound.
/// -> length
#let _clamp(value, min, max) = {
  if value < min { min } else if value > max { max } else { value }
}

/// Clamps a centered label so it stays inside a track.
///
/// - center (length): Desired label center.
/// - label-width (length): Measured label width.
/// - left (length): Left edge of the track.
/// - extent (length): Track width.
/// -> length
#let _clamp-centered-label-left(center, label-width, left, extent) = _clamp(
  center - label-width / 2,
  left,
  calc.max(left, left + extent - label-width),
)

/// Resolves a potentially relative length to an absolute length.
///
/// Finite non-negative absolute lengths are returned directly, skipping the
/// layout pass. Everything else goes through `measure`, which floors negative
/// and infinite lengths to zero; use `_resolve-signed-length` to keep the sign.
///
/// - value (length, ratio, relative): Length value to resolve.
/// -> length
#let _resolve-length(value) = {
  if type(value) == length and value.em == 0.0 {
    let absolute = value.abs
    // Infinite widths reach here from inside `measure`, where the available
    // width is unbounded; they must keep falling through to the layout pass.
    if absolute >= 0pt and absolute.pt() < float.inf { return absolute }
  }
  measure(box(width: value)[]).width
}

/// Resolves one possibly signed length.
///
/// An em component is resolved before the sign is taken, since a mixed em and
/// absolute length cannot be compared against `0pt`.
///
/// - value (length): Length to resolve.
/// -> length
#let _resolve-signed-length(value) = {
  let resolved = if value.em == 0.0 {
    value.abs
  } else {
    value.abs + _resolve-length(1em) * value.em
  }
  if resolved < 0pt {
    -_resolve-length(-resolved)
  } else {
    _resolve-length(resolved)
  }
}
