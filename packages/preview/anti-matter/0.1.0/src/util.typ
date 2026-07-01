#import "@preview/oxifmt:0.2.0"

/// Run `func` in locate to get a location, skip locate if a location is already given.
///
/// - loc (location): a `location` which may not be set
/// - func (function): a function which receives a `location`
/// -> any
#let maybe-locate(loc, func) = {
  if loc != none {
    func(loc)
  } else {
    locate(func)
  }
}

/// Returns the cardinality of a numbering pattern, i.e the number of counting symbols it contains.
///
/// - pattern (str): the numbering pattern to get the cardinality for
/// -> integer
#let cardinality(pattern) = {
  let symbols = ("1", "a", "A", "i", "I", "い", "イ", "א", "가", "ㄱ", "\\*")
  pattern.matches(regex(symbols.join("|"))).len()
}

/// Panics with an error message if the given pattern is not valid.
///
/// - pattern (any): a value that may or may not be a valid pattern
/// -> none
#let assert-pattern(pattern) = {
  if type(pattern) not in (str, function) {
    oxifmt.strfmt("Expected `str` or `function`, got `{}`", i, type(n))
  }

  if type(pattern) == str {
    let card = cardinality(pattern)
    if card not in (1, 2) {
      oxifmt.strfmt("Pattern can only contain 1 or 2 counting symbols, had {} (`\"{}\"`)", card, n)
    }
  }
}
