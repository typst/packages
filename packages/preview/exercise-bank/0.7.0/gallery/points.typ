// Points of an exercise - exercise-bank
// A short test: the scale on the right, a blank for the mark

#import "@preview/exercise-bank:0.7.0": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt, lang: "fr")

#exo-setup(
  display: "ex",
  badge-style: "underline",
  exercise-label: "Exercice",
  points-position: "right",    // right end of the header line
  points-format: "score",      // "...... / 4 pts", the mark is left blank
)

#exo(
  title: [Théorème de Pythagore],
  points: 4,
  exercise: [Dans le triangle $A B C$ rectangle en $B$, $A B = 3$ et $B C = 4$.
    Calculer $A C$.],
)

#exo(
  title: [Puissances],
  points: 2,
  exercise: [Simplifier $e^3 times e^4$.],
)

#exo-setup(badge-style: "box", points-position: "below", points-format: auto)

#exo(
  points: 1.5,
  exercise: [Calculer $2^3 + 3^2$.],
)
