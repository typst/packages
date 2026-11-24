// Titles, worked examples and compact headers - exercise-bank
// Student version (display: "ex"): only the worked example keeps its solution

#import "@preview/exercise-bank:0.6.5": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt, lang: "fr")

#exo-setup(
  display: "ex",               // student version: solutions hidden...
  badge-style: "underline",
  exercise-label: "Exercice",
  header-rule-gap: 0.3em,      // tighter header
  header-body-gap: 0.6em,
)

#exo(
  title: [Exemple corrigé],
  worked: true,                // ...except for this worked example
  exercise: [Simplifier $e^3 times e^4$.],
  solution: [$e^3 times e^4 = e^(3+4) = e^7$],
)

#exo(
  title: [Calculer une longueur avec le théorème de Pythagore],
  exercise: [Dans le triangle $A B C$ rectangle en $B$, $A B = 3$ et $B C = 4$.
    Calculer $A C$.],
  solution: [$A C = sqrt(3^2 + 4^2) = 5$],
)
