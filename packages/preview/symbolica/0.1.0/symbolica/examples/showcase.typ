#import "@preview/symbolica:0.1.0": *

#set document(title: "An exact polynomial-system case study")
#set page(paper: "a4", margin: 22mm)
#set text(size: 10.5pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.")

= Circle–hyperbola intersections

Consider the intersection of the circle $x^2 + y^2 = 5$ with the rectangular
hyperbola $x y = 2$. This small problem combines exact polynomial solving,
factorization, symbolic matrices, and substitution in one reproducible Typst
document.

#let x = symbol("x")
#let y = symbol("y")
#let system = (
  math($x^2 + y^2 - 5$),
  math($x y - 2$),
)

The equations passed to `solve` are expressions understood as equal to
zero:

$
  #to-typst(system.at(0)) &= 0, \
  #to-typst(system.at(1)) &= 0.
$

Eliminating $y$ gives a univariate polynomial whose exact factorization makes
the four possible $x$ coordinates visible:

#let eliminant = math($x^4 - 5 x^2 + 4$)

$ #to-typst(eliminant) = #to-typst(factor(eliminant)). $

== Solve exactly

#let solutions = solve(system, (x, y), domain: "real")

The `values` in each solution follow the requested variable order `(x, y)`.

#table(
  columns: (auto, 1fr, 1fr),
  align: (center, center, center),
  inset: 7pt,
  stroke: 0.5pt + luma(75%),
  table.header([*Solution*], [$x$], [$y$]),
  ..solutions.branches.enumerate().map(pair => {
    let index = pair.at(0)
    let solution = pair.at(1)
    (
      [#(index + 1)],
      [#to-typst(solution.values.at(0))],
      [#to-typst(solution.values.at(1))],
    )
  }).flatten(),
)

== Inspect the local geometry

The Jacobian of the two left-hand sides is

#let jacobian = matrix($mat(2 x, 2 y; y, x)$)
#let jacobian-det = det(jacobian)

$ J(x, y) = #to-typst(jacobian), quad det J = #to-typst(jacobian-det). $

We can substitute each exact solution into the determinant without converting
anything to floating point.

#let at-solution(expression, solution) = replace(
  replace(expression, x, solution.values.at(0)),
  y,
  solution.values.at(1),
)

#table(
  columns: (auto, 1fr),
  align: (center, center),
  inset: 7pt,
  stroke: 0.5pt + luma(75%),
  table.header([*Point*], [$det J$]),
  ..solutions.branches.enumerate().map(pair => {
    let index = pair.at(0)
    let solution = pair.at(1)
    (
      [#(index + 1)],
      [#to-typst(at-solution(jacobian-det, solution))],
    )
  }).flatten(),
)

Every determinant is nonzero, so all four intersections are transverse. The
entire calculation—from Typst math input to the typeset exact results—runs when
this document is compiled.
