// Difficulty encoding - exercise-bank
// Up to 5 levels, shown as badge colors, stars, or symbols

#import "@preview/exercise-bank:0.6.1": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt)

= Difficulty Levels

== Colors (default)

The exercise badge takes the color of the difficulty level:

#exo(exercise: [Level 1 -- introductory. Compute $2 + 2$.], difficulty: 1)
#exo(exercise: [Level 2 -- standard. Solve $3x = 12$.], difficulty: 2)
#exo(exercise: [Level 3 -- exam-type. Solve $x^2 - 4x + 3 = 0$.], difficulty: 3)
#exo(exercise: [Level 4 -- advanced. Show that $sqrt(2)$ is irrational.], difficulty: 4)
#exo(exercise: [Level 5 -- expert. Prove there are infinitely many primes.], difficulty: 5)

== Stars

#exo-setup(difficulty-display: "stars")

#exo(exercise: [One star. Compute $5 dot 6$.], difficulty: 1)
#exo(exercise: [Three stars. Factor $x^2 - 9$.], difficulty: 3)
#exo(exercise: [Five stars. A real challenge.], difficulty: 5)

== Symbols

Seedling, pencil, target, mountain, star:

#exo-setup(difficulty-display: "symbols")

#exo(exercise: [Seedling -- introductory.], difficulty: 1)
#exo(exercise: [Pencil -- standard.], difficulty: 2)
#exo(exercise: [Target -- exam-type.], difficulty: 3)
#exo(exercise: [Mountain -- advanced.], difficulty: 4)
#exo(exercise: [Star -- expert.], difficulty: 5)

== Custom scale

Define your own levels, colors, and symbols:

#exo-setup(
  difficulty-display: "color",
  difficulty-scale: (
    "easy": (color: rgb("#00897b")),
    "hard": (color: rgb("#e65100")),
  ),
)

#exo(exercise: [An "easy" one.], difficulty: "easy")
#exo(exercise: [A "hard" one.], difficulty: "hard")
