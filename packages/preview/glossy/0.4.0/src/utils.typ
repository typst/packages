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
  // Early exit for invalid input
  if word == none {
    return none
  }

  // Helper functions for checking endings
  let ends_with = (suffix) => lower(word).ends-with(suffix)
  let ends_with_any = (suffixes) => suffixes.any((suffix) => ends_with(suffix))

  // Map of irregular plurals for common words
  let irregulars = (
    "alumna": "alumnae",
    "alumnus": "alumni",
    "analysis": "analyses",
    "appendix": "appendices",
    "basis": "bases",
    "cactus": "cacti",
    "child": "children",
    "crisis": "crises",
    "criterion": "criteria",
    "datum": "data",
    "foot": "feet",
    "fungus": "fungi",
    "goose": "geese",
    "man": "men",
    "medium": "media",
    "mouse": "mice",
    "nucleus": "nuclei",
    "oasis": "oases",
    "person": "people",
    "phenomenon": "phenomena",
    "stimulus": "stimuli",
    "thesis": "theses",
    "tooth": "teeth",
    "woman": "women",
  )

  // Set of plural-only words
  let plural_only = (
    "advice",
    "alumni",
    "bison",
    "children",
    "criteria",
    "data",
    "deer",
    "feet",
    "fish",
    "geese",
    "information",
    "media",
    "men",
    "mice",
    "money",
    "moose",
    "octopi",
    "octopodes",
    "people",
    "scissors",
    "series",
    "sheep",
    "species",
    "teeth",
    "trousers",
    "women",
  )

  // Irregular suffixes
  let f_to_ves = ("leaf", "loaf", "calf", "half", "wolf", "thief")
  let fe_to_ves = ("wife", "knife", "life")
  let o_to_os = ("photo", "piano", "halo", "radio", "video", "studio", "solo", "taco", "memo", "zero")

  // Convenience
  let w = lower(word)

  // Check for words already plural
  if plural_only.contains(w) {
    return word
  }

  // Check for irregular singulars
  if irregulars.keys().contains(w) {
    return irregulars.at(w)
  }

  // Standard pluralization rules
  if ends_with("iz") {
    word + "zes"
  } else if ends_with_any(("s", "x", "z", "sh", "ch")) {
    word + "es"
  } else if ends_with("y") {
    if not ends_with_any(("ay", "ey", "iy", "oy", "uy")) {
      word.slice(0, -1) + "ies"
    } else {
      word + "s"
    }
  } else if ends_with("f") {
    if f_to_ves.contains(w) {
      word.slice(0, -1) + "ves"
    } else {
      word + "s"
    }
  } else if ends_with("fe") {
    if fe_to_ves.contains(w) {
      word.slice(0, -2) + "ves"
    } else {
      word + "s"
    }
  } else if ends_with("us") {
    word.slice(0, -2) + "i"
  } else if ends_with("is") {
    word.slice(0, -2) + "es"
  } else if ends_with("on") {
      word + "s"
  } else if ends_with("o") {
    if o_to_os.contains(w) {
      word + "s"
    } else {
      word + "es"
    }
  } else {
    word + "s"
  }
}

// Determines the appropriate indefinite article ("a" or "an") for a given English word.
//
// Heuristic rules:
// 1. If word looks like an acronym (all uppercase or letters separated by dots):
//    - Use "an" if the first letter's name starts with a vowel sound, e.g. A (ay), E (ee), F (eff), H (aitch), I (eye), L (el), M (em), N (en), O (oh), R (ar), S (ess), X (ex).
//    - Otherwise "a".
//
// 2. Otherwise, lowercase the word and apply standard rules:
//    - Starts with a vowel (a, e, i, o): "an".
//    - Starts with "u":
//      * If it begins with "uni", "use", "user", or "eu" (e.g. "university", "use", "Europe"), we treat it as a "yoo" sound -> "a".
//      * Otherwise -> "an".
//    - Special silent 'h' words: if it starts with "hour", "honest", "honor", "honour", or other, use "an".
//      Otherwise if starts with 'h', use "a".
//    - Default: "a".
//
// Notes:
// - This is a best-effort heuristic and won't be perfect.
// - These are for singular forms. If plural form is requested alongside
//   articles, the caller should panic before calling this function.
//
// Returns:
//   "a" or "an"
//
// Example:
//   __determine_article("RF") -> "an" (Ar-Ef)
//   __determine_article("radio") -> "a"
//   __determine_article("hour") -> "an"
//   __determine_article("honest") -> "an"
//   __determine_article("university") -> "a"
//   __determine_article("umbrella") -> "an"
//   __determine_article("Europe") -> "a" (because we assume "yoo-ruhp")
#let __determine_article(word) = {
  // Check input
  if word == none or word.trim() == "" {
    // If invalid, default to none
    return none
  }

  // Normalize the word
  let upper_word = word.trim()
  let lower_word = lower(upper_word)

  // When these letters are spelled out, they get an "an" (i.e. "an RFC")
  let acronym_vowels = (
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

  // Helper to detect if word looks like an acronym
  let is_acronym = {
    // All uppercase or letters separated by non-alphabetical chars
    let cleaned = upper_word.replace(".", "").replace("-", "")
    cleaned.codepoints().all(c => c == upper(c)) and cleaned.len() > 0
  }

  if is_acronym {
    // Use acronym rules
    let first_char = upper_word.slice(0,1)
    if acronym_vowels.contains(first_char) {
      "an"
    } else {
      "a"
    }
  } else {
    // Non-acronym rules
    let first_char = lower_word.slice(0,1)

    // Special cases for words matching a set of known 'silent h' prefixes
    let silent_h_words = (
      "heir",   // "air"
      "herb",   // "erb" (in American English)
      "homage", // "oh-mij" or "ah-mij"
      "honest", // "on-est"
      "honor",  // "on-or" (American English)
      "honour", // "on-our" (British English)
      "hour",   // "our"
    )
    if silent_h_words.any(w => lower_word.starts-with(w)) {
      return "an"
    }

    // Words starting with 'eu', which has the 'yoo' sound
    if lower_word.starts-with("eu") {
      return "a"
    }

    // Words starting with 'u', that get the 'yoo' sound
    if first_char == "u" {
      let yoo_sounds = (
        "ubi",  // ubiquitous
        "uni",  // unicycle, uniform, universe, university, unilateral, unique, union, etc.
        "usa",  // usage, usability
        "use",  // use, useful, useless
        "usu",  // usual, usually
        "usur", // usurp
        "ute",  // utensil, uterus
        "uti",  // utility, utilize, utilization
        "uto",  // utopia, utopian
      )
      if yoo_sounds.any(w => lower_word.starts-with(w)) {
        return "a"
      }
    }

    // Vowel start
    if "aeiou".contains(first_char) {
      return "an"
    }

    // the default case, plus 'h' words not in the silent list
    "a"
  }
}
