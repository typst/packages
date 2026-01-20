#import "@preview/exercise-bank:0.2.0": exo, exo-setup

#exo-setup(
  append-solution-to-correction: true,
  solution-in-correction-style: (
    weight: "bold",
    fill: rgb("#1565c0"),
    style: "normal",
  ),
)

#exo(
  exercise: [
    Solve the equation $x^2 = 9$.
  ],
  correction: [
    This is a basic quadratic equation.

    Students often forget the negative root.
  ],
  solution: [
    The solutions are $x = 3$ and $x = -3$.
  ],
)

#exo(
  exercise: [
    Calculate the area of a circle with radius 5.
  ],
  correction: [
    Use the formula $A = pi r^2$.

    Substitute $r = 5$.
  ],
  solution: [
    $A = pi times 5^2 = 25pi approx 78.54$
  ],
)
