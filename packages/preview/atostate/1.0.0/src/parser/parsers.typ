#let INTEGER_RGX = regex("^\d+")
#let WHITESPACE_RGX = regex("^\s+")

/// Fail with a helpful error message.
#let error(
  /// Input that caused the error.
  /// -> str
  input,
  /// Description of what was expected to be at this location.
  ///
  /// Where needed this should be structural, rather than descriptive, e.g.
  /// ```typ
  /// error(input, "positive integer '/' positive integer")
  /// ```
  /// as opposed to:
  /// ```typ
  /// error(input, "fraction of positive integers")
  /// ```
  ///
  /// -> array
  ..expected
) = {
  let count = calc.min(5, input.len())

  panic(
    "error at '" +
    input.slice(0, count: count) +
    "', expected: " +
    expected.pos().join(", ", last: " or "),
  )
}

/// Ensure that the parser has found its target.
///
/// Since parsers are optional by default, this is an easy way to make one mandatory.
///
/// ```example
/// // Succeeds!
/// #ensure(tag("1"), "'1'")("123")
/// // Would panic.
/// // #ensure(tag("1"), "'1'")("23")
/// ```
///
/// -> func
#let ensure(
  /// The parsing function to wrap.
  /// -> func
  parser,
  /// Description of what was expected to be at this location.
  /// -> (str,)
  ..expected,
) = input => {
  let (input, output) = parser(input)

  if output == none {
    error(input, ..expected)
  }

  (input, output)
}

/// Match and return a given string.
///
/// The tag must not be an empty string.
///
/// ```example
/// #tag("hello")("hello, world")
/// ```
///
/// -> func
#let tag(
  /// The string that should be matched.
  /// -> str
  expected,
) = {
  assert.ne(expected, "")
  input => {
    if input.starts-with(expected) {
      (input.slice(expected.len()), expected)
    } else {
      (input, none)
    }
  }
}

/// Apply the @tag parser, and raise a sensible error if it is none.
///
/// ```example
/// // Succeeds!
/// #ensured-tag("hello")("hello, world")
/// // Would fail.
/// // #ensured-tag("hello")(", world")
/// ```
///
/// -> func
#let ensured-tag(
  /// The string that should be matched.
  /// -> str
  expected,
) = ensure(tag(expected), "'" + expected + "'")

/// Match a regular expression and return its match.
///
/// *Your regex should start with the `^` or `\A` matchers, otherwise unexpected behaviour may occur.*
/// This is checked at parse-time, but not perfectly.
///
/// ```example
/// #rgx(regex("^\d+"))("123 abc")
/// // This would panic.
/// // #rgx(regex("\d+"))("abc 123")
/// ```
///
/// -> func
#let rgx(
  /// The regular expression to match.
  /// -> regex
  expression
) = input => {
  let match = input.match(expression)
  if match == none {
    return (input, none)
  } else {
    assert.eq(match.start, 0)
    (input.slice(match.end), match.text)
  }
}

/// Apply a function to the successful result of a parser.
///
/// ```example
/// #map(tag("123"), int)("123 abc")
///
/// #map(tag("123"), int)("abc 123")
/// ```
///
/// -> func
#let map(
  /// The parsing function to wrap.
  /// -> func
  parser,
  /// The function to apply to the result.
  /// -> func
  transformer,
) = input => {
  let (input, output) = parser(input)

  if output == none {
    (input, output)
  } else {
    (input, transformer(output))
  }
}

/// Apply a function to the successful result of a parser, or return the given value on the unsuccessful result.
///
/// ```example
/// #map-or(tag("123"), int, 321)("123 abc")
///
/// #map-or(tag("123"), int, 321)("abc 123")
/// ```
///
/// ->
#let map-or(
  /// The parsing function to wrap.
  /// -> func
  parser,
  /// The function to apply to the result.
  /// -> func
  transformer,
  /// The value to return if the parser fails.
  /// -> any
  other,
) = input => {
  let (input, output) = parser(input)
  if output == none {
    (input, other)
  } else {
    (input, transformer(output))
  }
}

/// Try a list of parsers until one succeeds.
///
/// *There is no ambiguity checking, make sure you order the parsers in such a way that a later parser can't be matched by an earlier parser.*
///
/// ```example
/// #let parser = alt(tag("123"), tag("abc"))
///
/// #parser("123 abc")
///
/// #parser("abc 123")
///
/// #parser("xyz 123")
/// ```
///
/// -> func
#let alt(
  /// The parsing functions to try.
  /// -> func
  ..parsers,
) = input => {
  let bookmark = input

  for parser in parsers.pos() {
    let (input, output) = parser(bookmark)

    if output != none {
      return (input, output)
    }
  }

  (bookmark, none)
}

/// Apply a list of parsers one after the other.
///
/// The output list will always be the same length as there are parsers.
/// If a parser fails, ```typ none``` will be entered into the list.
///
/// ```example
/// #seq(tag("ab"), tag("12"), tag("yz"))("abyz")
///
/// #seq(tag("ab"), tag("12"), tag("yz"))("ab12yz")
///
/// #seq(tag("ab"), tag("12"), tag("yz"))("ab12")
/// ```
///
/// *Take care! This parser always succeeds, even if all the parsers fail (in which case ```typ none``` will be returned for all parsers).*
///
/// -> func
#let seq(
  /// The parsing functions to apply.
  /// -> func
  ..parsers,
) = input => {
  let outputs = ()

  for parser in parsers.pos() {
    let (advanced, output) = parser(input)
    input = advanced
    outputs.push(output)
  }

  (input, outputs)
}

/// Apply a list of parsers one after the other, returning only the outputs of parsers that succeed.
///
/// "comp" is short for "compress".
///
/// ```example
/// #seq-comp(tag("ab"), tag("12"), tag("yz"))("abyz")
///
/// #seq-comp(tag("ab"), tag("12"), tag("yz"))("ab12yz")
///
/// #seq-comp(tag("ab"), tag("12"), tag("yz"))("ab12")
/// ```
///
/// *Take care! This parser always succeeds, even if all the parsers fail (in which case an empty array will be returned).*
/// -> func
#let seq-comp(
  /// The parsing functions to apply.
  /// -> func
  ..parsers
) = map(
  seq(..parsers),
  output => output.filter(el => el != none),
)

/// Apply a list of parsers one after the other, _if all succeed_.
///
/// If any parser returns ```typ none``` then this parser will stop and return ```typ none```.
///
/// ```example
/// #all(tag("ab"), tag("12"), tag("yz"))("abyz")
///
/// #all(tag("ab"), tag("12"), tag("yz"))("ab12yz")
///
/// #all(tag("ab"), tag("12"), tag("yz"))("ab12")
/// ```
///
/// -> func
#let all(
  /// The parsing functions to apply.
  /// -> func
  ..parsers,
) = input => {
  let bookmark = input
  let outputs = ()

  for parser in parsers.pos() {
    let (advanced, output) = parser(input)
    input = advanced

    if output == none {
      return (bookmark, none)
    }

    outputs.push(output)
  }

  (input, outputs)
}

/// Match a run of whitespace.
///
/// ```example
/// #whitespace("\n\t a \t\n")
///
/// #all(tag("a"), whitespace, tag("b"))("a b")
/// ```
#let whitespace = input => {
  let match = input.match(WHITESPACE_RGX)

  if match == none {
    (input, none)
  } else {
    (input.slice(match.end), match.text)
  }
}

/// Match a positive integer.
///
/// ```example
/// #map(integer, int)("123abc")
/// ```
///
/// ```example
/// #map(
///   all(tag("-"), integer),
///   o => int(o.join()),
/// )("-23")
/// ```
#let integer = input => {
  let match = input.match(INTEGER_RGX)

  if match == none {
    (input, none)
  } else {
    (input.slice(match.end), match.text)
  }
}

/// Match a negative integer.
///
/// ```example
/// #map(negative-integer, int)("-123for")
/// ```
#let negative-integer = map(
  all(tag("-"), integer),
  ((minus, number)) => minus + number,
)

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// TODO: These shouldn't rely on whitespace, have an `eat-ws` function that makes this easy. //
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Match a delimited parser.
///
/// Applies the first parser and discards it, then applies the second and keeps the result, and finally applies the third and discards it.
///
/// Whitespace directly after the left delimiter, or before the right delimiter, is ignored.
///
/// ```example
/// #delim(tag("("), integer, tag(")"))("( 123 )")
/// ```
///
/// ```example
/// #delim(tag("|"), tag("psi"), tag(">"))("| psi >")
/// ```
///
/// -> func
#let delim(
  /// The parser to match the left delimiter.
  /// -> func
  left,
  /// The parser to match the delimited contents.
  /// -> func
  delimited,
  /// The parser to match the right delimiter.
  /// -> func
  right,
) = input => {
  let bookmark = input

  let (input, delimiter) = left(input)
  if delimiter == none {
    return (bookmark, none)
  }

  let (input, _) = whitespace(input)

  let (input, output) = delimited(input)
  if output == none {
    return (bookmark, output)
  }

  let (input, _) = whitespace(input)

  let (input, delimiter) = right(input)
  if delimiter == none {
    return (bookmark, none)
  }

  (input, output)
}

/// Match at least one element of a separated list.
///
/// Optionally use a different parser for the first element.
///
/// ```example
/// #sep1(
///   map(alt(integer, negative-integer), int),
///  tag(","),
/// )("123, -456, 789")
/// ```
///
/// ```example
/// #sep1(
///   map(alt(integer, negative-integer), int),
///  tag(","),
///  first: map(integer, int)
/// )("-123, 456, -789")
/// ```
///
/// -> func
#let sep1(
  /// The parser to match elements of the list.
  /// -> func
  element,
  /// The parser to match the separator.
  /// -> func
  separator,
  /// The parser to match the first element of the list.
  /// -> func
  // TODO: Can this be element?
  first: none,
) = input => {
  let bookmark = input
  let outputs = ()

  let (input, output) = if first == none {
    element(input)
  } else {
    first(input)
  }

  if output == none {
    return (bookmark, none)
  } else {
    outputs.push(output)
  }

  let (input, _) = whitespace(input)

  let (input, sep) = separator(input)
  while sep != none {
    let bookmark = input

    (input, _) = whitespace(input)
    (input, output) = element(input)

    if output == none {
      return (bookmark, outputs)
    } else {
      outputs.push(output)
    }

    (input, _) = whitespace(input)
    (input, sep) = separator(input)
  }

  (input, outputs)
}
