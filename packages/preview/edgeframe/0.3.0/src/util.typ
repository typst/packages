/*
  File: util.typ
  Author: neuralpain
  Date Modified: 2025-12-09

  Description: Utility functions for Edgeframe.
*/

// Modulus function to substitute lack of modulus operator `%` in Typst
#let mod(x) = {
  calc.rem(x, 2)
}

#let xlinebreak(size) = {
  linebreak() * size
}

#let xpagebreak(size) = {
  pagebreak() * size
}
