#import "@preview/exercise-bank:0.1.0": exo-define, exo-select, exo-setup

#set page(width: 14cm, height: auto, margin: 1cm)

#exo-setup(solution-mode: "none")

// Define exercises with metadata
#exo-define(
  id: "alg-1",
  topic: "algebra",
  level: "easy",
)[Solve $x + 5 = 12$.]

#exo-define(
  id: "alg-2",
  topic: "algebra",
  level: "medium",
)[Solve $2x^2 - 8 = 0$.]

#exo-define(
  id: "geom-1",
  topic: "geometry",
  level: "easy",
)[Calculate the perimeter of a square with side 4.]

#exo-define(
  id: "geom-2",
  topic: "geometry",
  level: "medium",
)[Find the area of a triangle with base 6 and height 8.]

= Filtering by Topic

== Algebra Exercises
#exo-select(topic: "algebra")

== Geometry Exercises
#exo-select(topic: "geometry")

= Filtering by Level

== Easy Exercises
#exo-select(level: "easy")
