#import "@preview/exercise-bank:0.4.0": exo, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(
  corrDisplay: "correction",  // Show corrections instead of solutions
)

= Correction Display Demo

== Exercise with correction only
#exo(
  exercise: [
    Calculate $3 + 4 times 2$.
  ],
  correction: [
    $3 + 4 times 2 = 3 + 8 = 11$
  ],
)

== Exercise with detailed correction
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

== Exercise with both (correction shown)
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
