// TODO: Numerical values should be numerical so that we can do greater than checks etc.
// TODO: Sense checks (e.g. occupation > 0).

/// The parity of a term symbol.
///
/// This dictionary contains only the fields ```typ parity.odd``` and ```typ parity.even```.
///
/// This in, in practice, an enum, so the specific values of the fields should never be relied upon.
///
/// -> dictionary
#let parity = (
  odd: 34,
  even: 66,
)

/// A single character from the latin alphabet.
///
/// This is used primarily to differentiate between spectroscopic and jj notation when rendering.
#let letter(
  /// The letter itself.
  ///
  /// Must have ```typ value.len() == 1```.
  ///
  /// -> str
  value
) = {
  assert(type(value) == str)
  assert(value.len() == 1)

  (tag: "letter", value: value)
}

#let _coerce-number(value) = if type(value) == str {
  int(value)
} else {
  assert(type(value) == int)
  value
}

/// A single integer.
#let number(
  /// The number itself.
  ///
  /// If a string then it must contain a valid integer.
  ///
  /// -> int | str
  value
) = {
  let value = _coerce-number(value)

  (tag: "number", value: value)
}

/// A fraction, funnily enough.
#let fraction(
  /// The numerator itself.
  ///
  /// Must conform to the rules of @number.value.
  ///
  /// -> int | str
  numerator,
  /// The denominator itself.
  ///
  /// Must conform to the rules of @number.value.
  ///
  /// -> int | str
  denominator,
) = {
  let numerator = _coerce-number(numerator)
  let denominator = _coerce-number(denominator)

  (
    tag: "fraction",
    numerator: numerator,
    denominator: denominator,
  )
}

/// The element that may optionally be at the start of the state.
#let element(
  /// The element itself.
  ///
  /// This must not be empty.
  ///
  /// -> str
  value
) = {
  assert(type(value) == str)
  assert(value.len() > 0)

  (tag: "element", value: value)
}

/// A single orbital in the configuration list.
#let orbital(
  /// The principle number of the orbital, $n$.
  ///
  /// Accepted AST tags:
  /// - @letter
  /// - @number
  /// -> dictionary
  principal,
  /// The azimuthal orbital number of the configuration list, $l$.
  ///
  /// Accepted AST tags:
  /// - @letter
  /// - @number
  /// - @fraction
  /// -> dictionary
  azimuth,
  /// The occupation number of the orbital.
  ///
  /// Currently this should not be zero, this restriction may potentially be lifted in the future.
  ///
  /// Accepted AST tags: @number
  /// -> dictionary
  occupation,
  /// The subscript of the orbital.
  ///
  /// Accepted AST tags:
  /// - @number
  /// - @fraction
  /// -> none | dictionary
  subscript: none
) = {
  assert(("letter", "number").contains(principal.tag))
  assert(("letter", "number", "fraction").contains(azimuth.tag))
  assert(occupation.tag == "number")
  assert(
    subscript == none or
    ("number", "fraction").contains(subscript.tag)
  )

  (
    tag: "orbital",
    principal: principal,
    azimuth: azimuth,
    occupation: occupation,
    subscript: subscript
  )
}

/// A term symbol.
#let term(
  /// The multiplicity of the term symbol, $2S + 1$.
  ///
  /// Accepted AST tags: @number
  /// -> dictionary
  multiplicity,
  /// The character of the term symbol.
  ///
  /// Accepted AST tags:
  /// - @letter
  /// - @number
  /// - @fraction
  /// -> dictionary
  character,
  /// The $J$-value of the term symbol.
  ///
  /// Accepted AST tags:
  /// - @number
  /// - @fraction
  /// -> none | dictionary
  J: none,
  /// The parity of the term symbol.
  ///
  /// Must be equal to ```typ parity.odd``` or ```typ parity.even```.
  ///
  /// -> int
  pi: parity.even
) = {
  assert(multiplicity.tag == "number")
  assert(("letter", "number", "fraction").contains(character.tag))
  assert(J == none or ("number", "fraction").contains(J.tag))
  assert(pi == parity.odd or pi == parity.even)

  (
    tag: "term",
    multiplicity: multiplicity,
    character: character,
    J: J,
    pi: pi,
  )
}

/// The full state of the atom.
#let state(
  /// The configuration list.
  ///
  /// Each element must be an @orbital or a @term.
  ///
  /// -> array
  configuration,
  /// The total term of the state.
  ///
  /// Accepted AST tags: @term
  /// -> none | dictionary
  term: none,
  /// The optional element at the start of the state.
  ///
  /// Accepted AST tags: @element
  /// -> none | dictionary
  element: none,
) = {
  assert(configuration.fold(
    true,
    (acc, c) => acc and (c.tag == "orbital" or c.tag == "term"),
  ))
  assert(term == none or term.tag == "term")
  assert(element == none or element.tag == "element")

  (
    tag: "state",
    element: element,
    configuration: configuration,
    term: term,
  )
}
