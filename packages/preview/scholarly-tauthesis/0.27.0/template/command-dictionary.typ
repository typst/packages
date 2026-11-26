//
// command-dictionary.typ
//
// A dictionary of mathematical notations, for use with the
// functions of the file formula.typ. The formula functions
// typeset each source code string in math mode with eval,
// against this dictionary together with the standard math mode
// names of Typst, and the same string is used as the
// alternative text of the resulting equation.
//
// The dictionary below carries the notations of the
// example document: each notation is registered under a
// name that reads like the actual voice of your formulas, so
// that a screen reader user hears the semantics of each
// formula, and not just its letters. Edit it freely, and
// keep it limited to the notations that you actually use.
//
// Each name must be a single word, since a name is called
// inside math mode source code strings, where a hyphen always
// reads as a subtraction, with or without spaces around it,
// so a name such as partial-derivative is not callable.
// Register longer notations under one readable word, like the
// entry conjugate below, which stands for the complex
// conjugate command of the preamble, and compose longer source
// code phrases from several short names instead: for example,
// the source code string "second derivative of position" is
// best written as "second derivative(position)", once
// suitable names have been registered.
//
// The notation values below reuse the commands defined in the
// file preamble.typ, which this file imports in full.
//

#import "preamble.typ": *
#import "brakets.typ": braket

#let command-dictionary = {

  let cd = (:)

  cd += (
// Vectors and matrices.

  vector: vector,
  matrix: matrix,

  // Physical quantities.

  position: position,
  velocity: velocity,
  force: force,
  mass: mass,
  acceleration: acceleration,

  // The complex conjugate and the Dirac bra--ket.

  conjugate: xx => complex-conjugate(xx),
  braket: braket,

  // Derivatives.

  derivative: derivative,
  partialderivative: partialderivative,

  // Common sets of numbers.

  reals: $bb(R)$,
  complexes: $bb(C)$,

  // A few common units.

  meter: meter,
  gram: gram,
  second: second,
  newton: newton,
  bar: bar,
  pascal: pascal,
  celsius: celsius,
  pt: pt,
  )

  // Units with a power of ten prefix, generated below, so that
  // a compound unit name such as kilogram typesets as one
  // unit symbol, like kg, without a space between the prefix
  // and the unit. A prefixed unit is registered under its
  // compound name, so that it reads as one word in the source
  // code strings, and in the alternative texts.

  let prefix-symbols = (
    femto: "f",
    nano: "n",
    micro: "μ",
    milli: "m",
    centi: "c",
    deci: "d",
    kilo: "k",
    mega: "M",
    giga: "G",
    tera: "T",
    peta: "P",
  )
  let unit-symbols = (
    meter: "m",
    gram: "g",
    second: "s",
    newton: "N",
    joule: "J",
    bar: "bar",
    pascal: "Pa",
  )
  for (prefix-name, prefix-symbol) in prefix-symbols {
    for (unit-name, unit-symbol) in unit-symbols {
      cd.insert(prefix-name + unit-name, unit(prefix-symbol + unit-symbol))
    }
  }

  cd

}
