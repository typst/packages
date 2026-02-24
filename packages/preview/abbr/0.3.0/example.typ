#set page(height:auto, width: 16cm, margin: 1em)
#import "@preview/abbr:0.3.0"

#show: abbr.show-rule

#abbr.list()
#abbr.make(
  ("PDE", "Partial Differential Equation"),
  ("BC", "Boundary Condition"),
  ("DOF", "Degree of Freedom", "Degrees of Freedom"),
  ("TGV", "High speed train"),
)
#abbr.add-alt("TGV","Train à grande vitesse", supplement: "from French")


= Constrained Equations

@BC:pla constrain the @DOF:pla of the @PDE:pla they act on.

#abbr.config(style: it => text(red, it), space-char: sym.arrow.l.r)

@BC:pla constrain the @DOF:pla of the @PDE:pla they act on.

#abbr.add("MOL", "Method of Lines")
The @MOL is a procedure to solve @PDE:pla in time.

= A note about trains

The @TGV has a commercial speed of up to 320 km/h.
