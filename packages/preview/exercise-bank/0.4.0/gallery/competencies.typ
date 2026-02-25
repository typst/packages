#import "@preview/exercise-bank:0.4.0": exo-define, exo-show, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(
  show-competencies: true,
)

= Exercises with Competencies

#exo-define(
  id: "comp-1",
  exercise: [Solve $2x + 5 = 13$ and explain your method.],
  competencies: ("C1.1", "C2.3"),
  solution: [$x = 4$],
)

#exo-define(
  id: "comp-2",
  exercise: [Determine the nature of the roots of $x^2 - 3x + 2 = 0$.],
  competencies: ("C1.2", "C3.1", "C4.1"),
  solution: [The discriminant is $b^2 - 4 a c = 1 > 0$, so there are two real solutions.],
)

#exo-show("comp-1")
#exo-show("comp-2")
