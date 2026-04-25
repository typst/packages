// =============================================================================
// source-to-class-diagram — General Utilities
// =============================================================================

/// Sanitize a class name for use as a CeTZ anchor name.
/// Replaces dots, spaces, and special chars with underscores.
#let sanitize-name(name) = {
  name.replace(".", "_").replace(" ", "_").replace("<", "_").replace(">", "_")
}

/// Check if a string is empty or only whitespace.
#let is-blank(s) = {
  s.trim() == ""
}

/// Safe array access with default value.
#let safe-at(arr, idx, default: none) = {
  if idx >= 0 and idx < arr.len() {
    arr.at(idx)
  } else {
    default
  }
}
