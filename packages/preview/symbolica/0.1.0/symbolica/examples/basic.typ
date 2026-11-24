#import "@preview/symbolica:0.1.0": *

#set page(width: 150mm, height: auto, margin: 18mm)
#set text(size: 11pt)
#set par(leading: 0.7em)

= Exact algebra in one document

Symbolica turns native Typst mathematics into an exact Symbolica expression and
places the computed result back into the document.

#let x = symbol("x")
#let polynomial = math($x^4 - 5 x^2 + 4$)
#let factored = factor(polynomial)
#let slope = derivative(polynomial, x)

$
  f(x) &= #to-typst(polynomial) \
       &= #to-typst(factored) quad "factored" \
  f'(x) &= #to-typst(slope)
$

All coefficients remain exact.
