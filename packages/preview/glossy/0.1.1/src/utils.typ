#let __default(val, default) = if val == none { default } else { val }

#let __pluralize(word) = {
  // Define helper functions for checking endings
  let ends_with = (suffix) => lower(word).ends-with(suffix)
  let ends_with_any = (suffixes) => suffixes.any((suffix) => ends_with(suffix))

  if ends_with_any(( "s", "x", "z", "sh", "ch" )) { // Handle special cases for "es" endings
    word + "es"
  } else if ends_with("y") and not ends_with_any(( "a", "e", "i", "o", "u" )) { // Handle "y" -> "ies"
    word.slice(0, -1) + "ies"
  } else if ends_with("f") { // Handle "f" or "fe" -> "ves"
    word.slice(0, -1) + "ves"
  } else if ends_with("fe") {
    word.slice(0, -2) + "ves"
  } else { // Default to adding "s"
    word + "s"
  }
}
