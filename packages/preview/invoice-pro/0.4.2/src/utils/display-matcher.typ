// Copied code from loom
// Can be import in later versions when display is published

#let _SIG_KEY = "__loom_matcher_sig__"
#let _SIG_VAL = "loom-matcher-v1-7600d448"

/// Converts a matcher schema into a human-readable string representation.
///
/// # Example
/// ```typ
/// display(matcher.many(int)) // -> "array<int>"
/// display(matcher.choice("a", "b")) // -> "\"a\" | \"b\""
/// ```
///
/// -> str
#let display(pattern) = {
  // A. Handle custom Matcher Descriptors
  if (
    type(pattern) == dictionary
      and pattern.at(_SIG_KEY, default: none) == _SIG_VAL
  ) {
    if pattern.type == "matcher-any" {
      return "*"
    }
    if pattern.type == "matcher-exact" {
      return display(pattern.value)
    }
    if pattern.type == "matcher-instance" {
      return "<" + display(pattern.target) + ">"
    }
    if pattern.type == "matcher-choice" {
      return pattern.options.map(display).join(" | ")
    }
    if pattern.type == "matcher-many" {
      return "array<(" + display(pattern.schema) + ")>"
    }
    if pattern.type == "matcher-dict" {
      return "dict<(" + display(pattern.schema) + ")>"
    }
  }

  // B. Handle Syntax / Literal Patterns

  // 1. Types (e.g., int -> "int")
  if type(pattern) == type {
    let type-str = repr(pattern)
    return type-str
  }

  // 2. Tuples / Arrays
  if type(pattern) == array {
    return "(" + pattern.map(display).join(", ") + ")"
  }

  // 3. Records / Dictionaries
  if type(pattern) == dictionary {
    let pairs = pattern
      .pairs()
      .map(pair => pair.at(0) + ": " + display(pair.at(1)))
    return "(" + pairs.join(", ") + ")"
  }

  // 4. Literals (strings, numbers, booleans, auto, none)
  return repr(pattern)
}
