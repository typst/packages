#set page(width: 10cm, height: 3cm)
#set align(horizon + center)
#import "@preview/eqrun:0.1.0": eqrun-builder

#let init = (
  w: 6,
  h: 7,
)
#let eqrun = eqrun-builder(init)

The area of a rectangle with sides $#init.w times #init.h$:
#eqrun($A = w dot h$)

#pagebreak()

Half of the square root of that is:
#eqrun($A^tau_"half sqrt" = sqrt(A) / 2$)

#pagebreak()

#context [
  #let state = eqrun()
  A: #state.A\
  A triangle: #state.A-half-sqrt-tau
]

#pagebreak()

Changing the precision:
#eqrun($tau = 2.019 / 2$, precision: 4)

#pagebreak()

This also works:
#eqrun($b^n = 2^sqrt(A div 6)$)

