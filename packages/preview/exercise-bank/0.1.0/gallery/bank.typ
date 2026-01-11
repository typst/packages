#import "@preview/exercise-bank:0.1.0": exo-define, exo-show, exo-show-many, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(solution-mode: "inline")

= Exercise Bank

// Define exercises (not displayed yet)
#exo-define(
  id: "quad-1",
  topic: "quadratics",
  solution: [$x = 2$ or $x = 3$],
)[Solve $x^2 - 5x + 6 = 0$.]

#exo-define(
  id: "quad-2",
  topic: "quadratics",
  solution: [$x = frac(-b plus.minus sqrt(b^2 - 4 a c), 2 a)$],
)[State the quadratic formula.]

#exo-define(
  id: "geom-1",
  topic: "geometry",
  solution: [$A = pi r^2 = 25pi$],
)[Find the area of a circle with radius 5.]

== Selected Exercises

// Show specific exercises by ID
#exo-show("quad-1")
#exo-show("geom-1")
