//! Core article selection heuristics used by the aoran package.
//!
//! This module exposes helpers that determine whether a word should be
//! prefixed with `a` or `an`. The implementation is a standalone extraction of
//! the logic that originally lived in the Glossy package.

// Set of acronym letters whose spoken names begin with a vowel sound.
#let acronym-vowel-letters = (
  "A", // "ay"
  "E", // "ee"
  "F", // "eff"
  "H", // "aitch"
  "I", // "eye"
  "L", // "el"
  "M", // "em"
  "N", // "en"
  "O", // "oh"
  "R", // "ar"
  "S", // "ess"
  "X", // "ex"
)

// Prefixes where the leading "h" is silent for the purposes of article choice.
#let silent-h-prefixes = (
  "heir", // "air"
  "herb", // "erb" (AmE)
  "homage", // "oh-mij" or "ah-mij"
  "honest", // "on-est"
  "honor", // "on-or" (AmE)
  "honour", // "on-our" (BrE)
  "hour", // "our"
)

// "U" prefixes that sound like "yoo" and therefore take "a" instead of "an".
#let yoo-sound-prefixes = (
  "ubi", // ubiquitous
  "uni", // uniform, universe, university, unilateral, unique, union
  "usa", // usage, usability
  "use", // use, useful, useless
  "usu", // usual, usually
  "usur", // usurp
  "ute", // utensil, uterus
  "uti", // utility, utilize
  "uto", // utopia, utopian
  "uku", // ukulele
  "ufo", // UFO when styled lowercase
)

#let vowels = ("a", "e", "i", "o", "u")

/// Returns the first codepoint of `text` or `none` if the string is empty.
#let first-codepoint(text) = {
  let iterator = text.codepoints().slice(0, 1)
  if iterator.len() == 0 {
    none
  } else {
    iterator.first()
  }
}

/// Determines whether a word should be considered an acronym for article rules.
#let is-acronym(word) = {
  if word == none {
    return false
  }
  let cleaned = word.replace(".", "").replace("-", "")
  cleaned.len() > 0 and cleaned.codepoints().all(c => c == upper(c))
}

/// Returns the lowercase version of the input word without surrounding space.
#let normalized-lower(word) = lower(word.trim())

/// Determine the appropriate indefinite article (`"a"` or `"an"`) for `word`.
///
/// Returns `none` when `word` is `none` or empty after trimming.
#let determine(word) = {
  if word == none or word.trim() == "" {
    return none
  }

  let trimmed = word.trim()
  let lower-word = normalized-lower(trimmed)
  let first-token = trimmed.replace("-", " ").split(regex("\\s+")).first()

  if first-token == none {
    return none
  }

  if is-acronym(first-token) {
    let first = first-codepoint(first-token)
    if first == none {
      return none
    }
    if acronym-vowel-letters.contains(first) {
      "an"
    } else {
      "a"
    }
  } else {
    let first = first-codepoint(lower-word)
    if first == none {
      return none
    }

    if silent-h-prefixes.any(prefix => lower-word.starts-with(prefix)) {
      "an"
    } else if lower-word.starts-with("eu") {
      "a"
    } else if first == "u" {
      let uni-exceptions = (
        "unim", // unimaginable, unimpressive
        "unin", // uninspired, uninvited
      )
      if uni-exceptions.any(prefix => lower-word.starts-with(prefix)) {
        "an"
      } else if yoo-sound-prefixes.any(prefix => lower-word.starts-with(
        prefix,
      )) {
        "a"
      } else {
        "an"
      }
    } else if vowels.contains(first) {
      "an"
    } else {
      "a"
    }
  }
}
