#import "@preview/exercise-bank:0.2.0": exo, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(
  solution-mode: "inline",
  fallback-to-correction: true,
)

= Correction Fallback Demo

== Exercise with solution only
#exo(
  exercise: [
    Calculate $3 + 4 times 2$.
  ],
  solution: [
    $3 + 4 times 2 = 3 + 8 = 11$
  ],
)

== Exercise with correction only (fallback enabled)
#exo(
  exercise: [
    Solve $x^2 = 9$.
  ],
  correction: [
    *Teacher's correction:*\
    This is a basic quadratic equation.\
    $x^2 = 9$\
    $x = plus.minus 3$\
    \
    Students often forget the negative root. Make sure to emphasize both solutions.
  ],
)

== Exercise with both solution and correction
#exo(
  exercise: [
    Factor $x^2 - 4$.
  ],
  solution: [
    $x^2 - 4 = (x + 2)(x - 2)$
  ],
  correction: [
    *Detailed correction:*\
    This is a difference of squares: $a^2 - b^2 = (a+b)(a-b)$\
    With $a = x$ and $b = 2$:\
    $x^2 - 4 = (x + 2)(x - 2)$
  ],
)

#pagebreak()

= Without Fallback
#exo-setup(fallback-to-correction: false)

== Exercise with correction only (fallback disabled)
#exo(
  exercise: [
    Simplify $2x + 3x$.
  ],
  correction: [
    This correction won't be shown because fallback is disabled.
  ],
)

== Exercise with solution
#exo(
  exercise: [
    Calculate $5 times 6$.
  ],
  solution: [
    $5 times 6 = 30$
  ],
)
