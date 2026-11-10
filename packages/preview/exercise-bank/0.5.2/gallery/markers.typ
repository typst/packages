#import "@preview/exercise-bank:0.5.2": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt)

= Exercise Markers

== Optional exercises

#exo(
  exercise: [Skip this if you're short on time. Solve $x^2 - x - 6 = 0$.],
  solution: [$x = 3$ or $x = -2$],
  optional: true,
)

#exo(
  exercise: [Solve $3x - 9 = 0$.],
  solution: [$x = 3$],
)

Customize the optional symbol:

#exo-setup(optional-symbol: [⭐])
#exo(
  exercise: [Optional with star marker. Solve $2x + 4 = 0$.],
  solution: [$x = -2$],
  optional: true,
)

#exo-setup(optional-symbol: optional-star-icon())

== Correction-given exercises

Mark exercises whose printed correction will be distributed to students:

#exo(
  exercise: [Factor $x^2 - 9$.],
  solution: [$(x-3)(x+3)$],
  corr-given: true,
)

#exo(
  exercise: [Solve the system $cases(x + y = 5, x - y = 1)$.],
  solution: [$x = 3$, $y = 2$],
)

== Combined markers

#exo(
  exercise: [*Challenging and optional.* Prove that $sqrt(2)$ is irrational.],
  advanced: true,
  optional: true,
)
