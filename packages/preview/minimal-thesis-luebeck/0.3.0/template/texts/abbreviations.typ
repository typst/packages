#import "@preview/abbr:0.2.1"

#abbr.make(
  ("PDE", "Partial Differential Equation"),
  ("BC", "Boundary Condition"),
  ("DOF", "Degree of Freedom", "Degrees of Freedom"),
)
#let char(null) = {sym.space.nobreak}
#abbr.config(space-char: char)
#abbr.list()
