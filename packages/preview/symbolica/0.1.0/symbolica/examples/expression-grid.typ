// Inspired by TimeTravelPenguin/symbolic-eval:
// https://github.com/TimeTravelPenguin/symbolic-eval/blob/79c6588351603b85b11b6c92b1fbff3faf478215/examples/eval_multiple_exprs.typ
#import "@preview/symbolica:0.1.0": init

#set document(title: "Batched evaluation of several expressions")
#set page(paper: "a4", margin: 18mm)
#set text(size: 9.5pt)

= Four formulas, one parameter grid

Symbolica can compile several expressions into one evaluator and run all of
them at every requested point. Here the definitions

#align(center)[
  $
    h_1(x, y) &= x^2 + 2 y + 1, \
    h_2(x, y) &= sin(pi x) + cos(y - e), \
    h_3(x, y) &= exp(x - y) - 1, \
    h_4(x, y) &= x^2 + y^2 + x sin(x)
  $
]

are evaluated together. The last expression is the expanded form of
$f(x,y)+g(x)$ for $f(x,y)=x^2+y^2$ and $g(x)=x sin(x)$.

#let sym = init(namespace: "symbolica")
#let parse = sym.math
#let symbol = sym.symbol
#let evaluate-many = sym.evaluate-many

#let x = symbol("x")
#let y = symbol("y")
#let p = symbol("p")
#let q = symbol("q")
#let expressions = (
  parse($x^2 + 2 y + 1$),
  parse($sin(p x) + cos(y - q)$),
  parse($exp(x - y) - 1$),
  parse($x^2 + y^2 + x sin(x)$),
)

#let x-values = (-10.0, -10.0 / 3.0, 10.0 / 3.0, 10.0)
#let y-values = (-5.0, 0.0, 5.0)
#let points = {
  let rows = ()
  for x-value in x-values {
    for y-value in y-values {
      // p and q carry pi and e as evaluator inputs. This keeps transcendental
      // arguments numerical without embedding decimal literals in the atoms.
      rows.push((x-value, y-value, calc.pi, calc.e))
    }
  }
  rows
}

#let values = evaluate-many(expressions, (x, y, p, q), points)

#let rounded(value) = {
  let value = calc.round(value, digits: 3)
  if calc.abs(value) < 0.0005 { 0 } else { value }
}

#let cells = ()
#for index in range(points.len()) {
  let point = points.at(index)
  cells.push([#rounded(point.at(0))])
  cells.push([#rounded(point.at(1))])
  for value in values.at(index) {
    cells.push([#rounded(value.re)])
  }
}

#show table.cell.where(y: 0): set text(weight: "bold")
#align(center)[
  #table(
    columns: (auto,) * 6,
    align: (right,) * 6,
    inset: (x: 9pt, y: 5pt),
    stroke: 0.5pt + luma(78%),
    table.header([$x$], [$y$], [$h_1$], [$h_2$], [$h_3$], [$h_4$]),
    ..cells,
  )
]

#v(4mm)
#text(size: 8pt, fill: luma(40%))[
  Independently adapted for Symbolica from the evaluation example in
  #link("https://github.com/TimeTravelPenguin/symbolic-eval")[`symbolic-eval`].
]
