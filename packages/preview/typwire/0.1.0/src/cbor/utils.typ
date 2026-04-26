/// Convert a ratio (0% - 100%) to an integer (0 - 255).
///
/// - ratio (ratio): A ratio value between 0% and 100%.
/// -> int
#let ratio-to-int(ratio) = {
  int(255 * calc.clamp(ratio / 100%, 0, 1))
}

/// Convert a ratio to a float.
///
/// - ratio (ratio): A ratio of any value.
/// -> float
#let ratio-to-float(ratio) = {
  ratio / 100%
}
