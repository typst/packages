// citeproc-typst - Core Utility Functions
//
// Common utility functions used across the codebase.

// =============================================================================
// Module-level regex patterns (avoid recompilation)
// =============================================================================

// Pattern for stripping periods after letters (preserves periods in numbers)
#let _period-after-letter-pattern = regex("([a-zA-Z\\u{00C0}-\\u{024F}])\\.")

// =============================================================================
// String Utilities
// =============================================================================

/// Capitalize the first character of a string (Unicode-safe)
#let capitalize-first-char(s) = {
  if s.len() == 0 { return s }
  let chars = s.clusters()
  if chars.len() == 0 { return s }
  upper(chars.first()) + chars.slice(1).join()
}

/// Left-pad a string with zeros to a given width
#let zero-pad(s, width) = {
  let s = str(s)
  let padding = width - s.len()
  if padding > 0 {
    "0" * padding + s
  } else {
    s
  }
}

/// Strip periods from a string (CSL strip-periods="true")
/// Only removes periods after letters, preserves periods in numbers (e.g., "2.1.0")
#let strip-periods-from-str(s) = {
  if type(s) != str { return s }
  s.replace(_period-after-letter-pattern, m => m.captures.at(0))
}

// =============================================================================
// Content Utilities
// =============================================================================

/// Check if content is empty (handles strings, arrays, and content)
#let is-empty(x) = {
  if x == none { return true }
  if x == [] { return true }
  if type(x) == str { return x.trim() == "" }
  if type(x) == array { return x.len() == 0 }
  // For content, convert to string and check
  if type(x) == content {
    let fields = x.fields()
    if "children" in fields {
      return fields.children.len() == 0
    }
    if "text" in fields {
      return fields.text.trim() == ""
    }
    if "body" in fields {
      return is-empty(fields.body)
    }
    return repr(x) == "[]"
  }
  false
}

/// Join parts with delimiter
///
/// Note: Punctuation collapsing (e.g., ".." → ".") is now handled by
/// show rules in lib.typ using regex replacement. This is more reliable
/// than trying to detect punctuation in complex nested content structures.
#let join-with-delimiter(parts, delimiter) = {
  if parts.len() == 0 { return [] }
  if parts.len() == 1 { return parts.first() }
  parts.join(delimiter)
}
