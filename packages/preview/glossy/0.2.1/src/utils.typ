// Returns the provided value if it is not none, otherwise returns the default value
// Parameters:
//   val: The value to check
//   default: The fallback value to use if val is none
// Returns: val if not none, otherwise default
#let __default(val, default) = if val == none { default } else { val }

// Converts an English word to its plural form following standard English pluralization rules
// Parameters:
//   word: The singular word to pluralize
// Returns: The pluralized form of the word, or none if input is none
#let __pluralize(word) = {
  // early exit with invalid input
  if word == none {
    return none
  }

  // Define helper functions for checking endings
  let ends_with = (suffix) => lower(word).ends-with(suffix)
  let ends_with_any = (suffixes) => suffixes.any((suffix) => ends_with(suffix))

  // Handle special cases for "es" endings (s, x, z, sh, ch)
  if ends_with_any(( "s", "x", "z", "sh", "ch" )) {
    word + "es"
  } else if ends_with("y") and not ends_with_any(( "a", "e", "i", "o", "u" )) {
    // Convert y to ies when y follows a consonant
    word.slice(0, -1) + "ies"
  } else if ends_with("f") {
    // Convert f to ves
    word.slice(0, -1) + "ves"
  } else if ends_with("fe") {
    // Convert fe to ves
    word.slice(0, -2) + "ves"
  } else {
    // Default case: just add s
    word + "s"
  }
}
