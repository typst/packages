#import "@preview/exercise-bank:0.3.0": exo-define, exo-select, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(solution-mode: "none")

// Define exercises with metadata
#exo-define(
  id: "alg-1",
  exercise: [Solve $x + 5 = 12$.],
  topic: "algebra",
  level: "easy",
)

#exo-define(
  id: "alg-2",
  exercise: [Solve $2x^2 - 8 = 0$.],
  topic: "algebra",
  level: "medium",
)

#exo-define(
  id: "geom-1",
  exercise: [Calculate the perimeter of a square with side 4.],
  topic: "geometry",
  level: "easy",
)

#exo-define(
  id: "geom-2",
  exercise: [Find the area of a triangle with base 6 and height 8.],
  topic: "geometry",
  level: "medium",
)

= Filtering by Topic

== Algebra Exercises
#exo-select(topic: "algebra")

== Geometry Exercises
#exo-select(topic: "geometry")

= Filtering by Level

== Easy Exercises
#exo-select(level: "easy")
