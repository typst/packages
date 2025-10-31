#import "@preview/auto-div:0.1.0": poly-div, poly-div-working

Just the working itself (works both inside and outside math mode):

$ #poly-div-working((1, 3, 0, "5/2", 6), (1, 2)) $

Obtaining parts of the polynomial division as math:

#let result = poly-div((1, 3, 0, "5/2", 6), (1, 2))
$
  result.dividend = (result.quotient) (result.divisor) + (result.remainder)
$

Obtaining quotient and remainder as an array of polynomial coefficients:

Quotient: #result.quot-coeff

Remainder: #result.rem-coeff

Note: for doing fraction math using the above fractions as strings, use #link("https://typst.app/universe/package/fractus/")[#underline[`@preview/fractus`]].