#set page(height:auto, width: 16cm, margin: 1em)
#import "@preview/abbr:0.1.0"

#abbr.list()
#abbr.make(
  ("PDE", "Partial Differential Equation"),
  ("BC", "Boundary Condition"),
  ("DOF", "Degree of Freedom", "Degrees of Freedom"),
)

= Constrained Equations

#abbr.pla[BC] constrain the #abbr.pla[DOF] of the #abbr.pla[PDE] they act on.\
#abbr.pla[BC] constrain the #abbr.pla[DOF] of the #abbr.pla[PDE] they act on.

#abbr.add("MOL", "Method of Lines")
The #abbr.a[MOL] is a procedure to solve #abbr.pla[PDE] in time.
