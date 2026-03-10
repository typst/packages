#import "@preview/exercise-bank:0.4.0": *

#set page(width: 16cm, height: auto, margin: 1cm)

= Draft Mode Demo

== Part 1: Draft Mode OFF (Student Version)

Empty corrections/solutions maintain counter but show no placeholder.

#exo-setup(
  draft-mode: false,  // Student version - no placeholders visible
)

#exo(
  exercise: [Solve $x + 5 = 12$],
  solution: [],  // Empty - shows space but no placeholder
)

#exo(
  exercise: [Calculate $3 times 4$],
  solution: [$3 times 4 = 12$],  // Normal solution
)

#exo(
  exercise: [Simplify $2x + 3x$],
  solution: [],  // Empty - counter continues
)

#pagebreak()

== Part 2: Draft Mode ON (Teacher Version)

Empty corrections/solutions show placeholders for completion.

#exo-setup(
  draft-mode: true,  // Teacher draft - shows placeholders
  correction-placeholder: [_[To be completed]_],
  solution-placeholder: [_[Answer to be written]_],
)

#exo(
  exercise: [Solve $x + 5 = 12$],
  solution: [],  // Shows placeholder: "To be completed"
)

#exo(
  exercise: [Calculate $3 times 4$],
  solution: [$3 times 4 = 12$],  // Normal solution
)

#exo(
  exercise: [Simplify $2x + 3x$],
  solution: [],  // Shows placeholder
)

#pagebreak()

== Part 3: With Correction Mode

#exo-setup(
  draft-mode: true,
  corr-display: "correction",  // Show corrections
  correction-placeholder: [_[Explanation to be written]_],
)

#exo(
  exercise: [Factor $x^2 - 4$],
  correction: [],  // Empty correction - shows placeholder
)

#exo(
  exercise: [What is $5 + 7$?],
  correction: [Add the two numbers to get 12.],  // Real correction
)

#exo(
  exercise: [Expand $(x+3)^2$],
  correction: [],  // Empty - shows placeholder
)
