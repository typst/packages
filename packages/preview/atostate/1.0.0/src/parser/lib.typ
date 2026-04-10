#import "ast.typ"
#import "parsers.typ" as p

#let LETTER_RGX = regex("^[A-Za-z]")
#let LOWERCASE_RGX = regex("^[a-z]")
#let UPPERCASE_RGX = regex("^[A-Z]")

#let positive-number = p.map(p.integer, ast.number)

#let number = p.map(
  p.alt(p.negative-integer, p.integer),
  ast.number,
)

#let fraction(input) = {
  let bookmark = input

  let (input, output) = p.seq(
    p.integer,
    p.whitespace,
    p.tag("/"),
    p.whitespace,
    p.integer,
  )(input)

  let (n, _, s, _, d) = output

  if n == none or s == none {
    (bookmark, none)
  } else if d == none {
    p.error(
      bookmark,
      "positive integer '/' positive integer"
    )
  } else {
    (input, ast.fraction(n, d))
  }
}

// Fraction must come first, as positive-number will succeed on all fractions.
#let fraction-or-number = p.alt(fraction, positive-number)

#let ensured-frac-or-num = p.ensure(
  fraction-or-number,
  "positive integer",
  "positive integer '/' positive integer"
)

#let bracketed-frac-or-num = p.delim(
  p.tag("["),
  ensured-frac-or-num,
  p.ensured-tag("]"),
)

#let subscript = p.delim(
  p.tag("<"),
  ensured-frac-or-num,
  p.ensured-tag(">"),
)

#let element = p.map(
  p.delim(
    p.tag("["),
    p.rgx(regex("^\w+")),
    p.tag("]"),
  ),
  ast.element,
)

#let orbital(input) = {
  let (input, n) = p.ensure(
    p.alt(
      positive-number,
      p.map(p.rgx(LETTER_RGX), ast.letter)
    ),
    "positive number",
    "single letter",
  )(input)

  let (input, _) = p.whitespace(input)

  let (input, l) = p.ensure(
    p.alt(
      p.map(p.rgx(LOWERCASE_RGX), ast.letter),
      bracketed-frac-or-num,
    ),
    "lowercase letter",
    "'['"
  )(input)

  let (input, _) = p.whitespace(input)

  let (input, s) = subscript(input)

  let (input, _) = p.whitespace(input)

  let (input, occupation) = p.map-or(
    number,
    n => n,
    ast.number(1)
  )(input)

  (
    input,
    ast.orbital(
      n,
      l,
      occupation,
      subscript: s,
    ),
  )
}

#let term-symbol(input) = {
  let (input, multiplicity) = p.ensure(positive-number, "positive integer")(input)
  let (input, _) = p.whitespace(input)

  let (input, character) = p.ensure(
    p.alt(
      p.map(p.rgx(UPPERCASE_RGX), ast.letter),
      bracketed-frac-or-num,
    ),
    "uppercase letter",
    "'['"
  )(input)

  let (input, _) = p.whitespace(input)
  let (input, J) = subscript(input)
  let (input, _) = p.whitespace(input)

  let (input, parity) = p.map-or(
    p.tag("*"),
    (_) => ast.parity.odd,
    ast.parity.even,
  )(input)

  (
    input,
    ast.term(
      multiplicity,
      character,
      J: J,
      pi: parity,
    )
  )
}

#let state(input) = {
  let (input, _) = p.whitespace(input)
  let (input, el) = element(input)
  let (input, _) = p.whitespace(input)

  let (input, configuration) = p.sep1(
    p.alt(
      p.delim(p.tag("("), term-symbol, p.ensured-tag(")")),
      orbital,
    ),
    p.tag("."),
    first: orbital,
  )(input)

  let (input, _) = p.whitespace(input)

  let (input, colon) = p.tag(":")(input)

  let (input, term) = if colon != none {
    let (input, _) = p.whitespace(input)
    term-symbol(input)
  } else {
    (input, none)
  }

  let (input, _) = p.whitespace(input)
  if input.len() != 0 {
    p.error(input, "end of string")
  }

  ast.state(configuration, element: el, term: term)
}
