#import "@preview/datify-core:1.0.0": *
#import "utils.typ": *

#let custom-date-format = (
  date,
  pattern: "full",
  lang: "en",
) => {
  // Validate date type (must be a datetime)
  if type(date) != datetime {
    panic("Invalid date: must be a datetime object, got " + str(type(date)))
  }

  // Validate pattern
  if type(pattern) != str {
    panic("Invalid pattern: must be a string, got " + str(type(pattern)))
  }

  // Validate lang
  if type(lang) != str {
    panic("Invalid language: must be a string, got " + str(type(lang)))
  }

  // Symbol lookup
  let symbol-values = (
    "EEEE": get-day-name(date.weekday(), lang: lang, usage: "format", width: "wide"),
    "EEE": get-day-name(date.weekday(), lang: lang, usage: "format", width: "abbreviated"),
    "MMMM": get-month-name(date.month(), lang: lang, usage: "format", width: "wide"),
    "MMM": get-month-name(date.month(), lang: lang, usage: "format", width: "abbreviated"),
    "MM": pad(date.month(), 2),
    "M": str(date.month()),
    "dd": pad(date.day(), 2),
    "d": str(date.day()),
    "yyyy": str(date.year()),
    "y": str(date.year()),
  )

  let tokens = ("EEEE", "MMMM", "yyyy", "EEE", "MMM", "MM", "dd", "M", "d", "y")

  // If named pattern, resolve it
  if pattern == "full" or pattern == "long" or pattern == "medium" or pattern == "short" {
    pattern = get-date-pattern(pattern, lang: lang)
  }

  // Parse the pattern string into the final result
  let result = ""
  let in_literal_mode = false
  let current_position = 0
  let pattern_length = pattern.clusters().len()

  while (current_position < pattern_length) {
    let current_char = safe-slice(pattern, current_position, current_position + 1)

    // Handle literal mode (quoted text)
    if (current_char == "'") {
      // Check for escaped quote (two single quotes in a row)
      if (current_position + 1 < pattern_length and
          safe-slice(pattern, current_position + 1, current_position + 2) == "'") {
        result += "'"
        current_position += 2
        continue
      }
      // Toggle literal mode
      in_literal_mode = not in_literal_mode
      current_position += 1
      continue
    }

    // In literal mode, append characters as-is
    if (in_literal_mode) {
      result += current_char
      current_position += 1
      continue
    }

    // Try to match any token at the current position
    let token_matched = false
    for token in tokens {
      let token_length = token.len()
      // Check if the token matches the current position in the pattern
      if (current_position + token_length <= pattern_length and
          safe-slice(pattern, current_position, current_position + token_length) == token) {
        result += symbol-values.at(token)
        current_position += token_length
        token_matched = true
        break
      }
    }

    // If no token matched, append the character as-is
    if (not token_matched) {
      result += current_char
      current_position += 1
    }
  }

  return result
}
