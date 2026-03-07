#import "@preview/exercise-bank:0.4.0": exo, exo-setup

#set page(width: 14cm, height: 8cm, margin: 1cm)

#exo-setup(corr-loc: "pagebreak")  // Solutions on separate page

= Page Break Demo

Each solution appears on a new page after its exercise.

#exo(
  exercise: [
    Solve the equation $2x + 5 = 13$.
  ],
  solution: [
    $2x + 5 = 13$\
    $2x = 8$\
    $x = 4$
  ],
)

#exo(
  exercise: [
    Factor $x^2 - 9$.
  ],
  solution: [
    $x^2 - 9 = (x + 3)(x - 3)$
  ],
)
