// utils.typ - Shared utility functions

/// Compute the duration of an event in whole notes (as a fraction).
/// A whole note = 1, half = 1/2, quarter = 1/4, etc.
/// Dots add 1/2, 1/4, etc. of the base duration.
#let duration-to-beats(duration, dots: 0) = {
  let base = 1.0 / duration
  let total = base
  let dot-value = base
  for _ in range(dots) {
    dot-value = dot-value / 2.0
    total = total + dot-value
  }
  total
}

/// Logarithmic spacing factor for a given duration.
/// Quarter note = 1.0 as reference.
/// Longer notes get more space (but not proportionally).
/// Shorter notes get less space.
#let duration-spacing-factor(duration, dots: 0) = {
  // Use log2-based spacing: each doubling of duration adds a fixed increment
  // Quarter note (4) = factor 1.0
  // Half note (2) = factor ~1.5
  // Whole note (1) = factor ~2.0
  // Eighth note (8) = factor ~0.7
  // Sixteenth (16) = factor ~0.5
  let base-factor = calc.log(4.0 / duration, base: 2) + 1.0
  // Clamp to minimum - ensures 8th notes and shorter have adequate space
  let factor = calc.max(base-factor, 0.75)
  // Dots increase spacing slightly
  if dots >= 1 { factor = factor * 1.15 }
  if dots >= 2 { factor = factor * 1.1 }
  factor
}

/// Convert a string to an array of characters for manual parsing.
#let str-to-chars(s) = {
  let chars = ()
  for i in range(s.len()) {
    chars.push(s.at(i))
  }
  chars
}

/// Check if a character is a digit.
#let is-digit(ch) = {
  ch >= "0" and ch <= "9"
}

/// Check if a character is a lowercase letter.
#let is-lower(ch) = {
  ch >= "a" and ch <= "z"
}

/// Check if a character is an uppercase letter.
#let is-upper(ch) = {
  ch >= "A" and ch <= "Z"
}

/// Check if a character is whitespace.
#let is-whitespace(ch) = {
  ch == " " or ch == "\t" or ch == "\n" or ch == "\r"
}

/// Parse an integer from a string. Returns the integer value.
#let parse-int(s) = {
  int(s)
}
