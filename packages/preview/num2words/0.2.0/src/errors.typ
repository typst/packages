/// Error helpers for consistent `num2words` error messages.

/// Formats the `num2words` prefix, optionally scoped to a language.
///
/// - lang (str, none): The language code, or `none` for the top-level function.
/// -> str
#let _prefix(lang) = {
  if lang == none {
    "num2words"
  } else {
    "num2words (" + lang + ")"
  }
}

/// Asserts that a value has the expected type. Panics with a consistent message if not.
///
/// - param (str): The parameter name.
/// - expected-type (type): The expected type (e.g., `int`, `str`).
/// - value (any): The actual value received.
/// - lang (str, none): The language code, or `none` for the top-level function.
#let assert-type(param, expected-type, value, lang: none) = {
  let value-type = type(value)
  assert(
    value-type == expected-type,
    message: _prefix(lang) + ": expected " + str(expected-type) + " for '" + param + "', got " + str(value-type),
  )
}

/// Asserts that a language code is supported.
///
/// - lang (str): The language code to check.
/// - supported (array, dictionary): The supported languages (array of strings or dictionary with language keys).
#let assert-lang(lang, supported) = {
  assert(
    lang in supported,
    message: _prefix(none) + ": unsupported language '" + lang + "'",
  )
}

/// Asserts that a parameter value is among a set of supported values. Used for
/// any option with a finite set of valid choices (e.g. `form`, `gender`).
///
/// - param (str): The parameter name.
/// - value (any): The value to check.
/// - supported (array, dictionary): The supported values (array, or dictionary whose keys are the supported values).
/// - lang (str, none): The language code, or `none` for the top-level function.
#let assert-option(param, value, supported, lang: none) = {
  assert(
    value in supported,
    message: _prefix(lang) + ": unsupported value '" + str(value) + "' for '" + param + "'",
  )
}

/// Asserts that a number is within the supported range. Panics if not.
///
/// - number (int): The number to check.
/// - min (int, none): The minimum supported value, or `none` if unbounded below.
/// - max (int, none): The maximum supported value, or `none` if unbounded above.
/// - lang (str, none): The language code, or `none` for the top-level function.
#let out-of-range(number, min: none, max: none, lang: none) = {
  let in-range = (
    (min == none or number >= min) and (max == none or number <= max)
  )
  let range-str = if min != none and max != none {
    "[" + str(min) + ", " + str(max) + "]"
  } else if min != none {
    ">= " + str(min)
  } else {
    "<= " + str(max)
  }
  assert(
    in-range,
    message: _prefix(lang) + ": number " + str(number) + " is out of range (" + range-str + ")",
  )
}
