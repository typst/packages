// Inline solutions + deferred corrections - exercise-bank
// The short answer stays with the statement (epigraph-like rule), while the
// full correction goes to the end of the chapter

#import "@preview/exercise-bank:0.6.0": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt)

#exo-setup(
  corr-display: "correction",  // show both the correction and the solution
  sol-loc: "after",            // ... the solution right below the statement
  corr-loc: "end-chapter",     // ... the correction at the end of the chapter
  solution-style: "inline",    // epigraph-like: short rule, no badge
  exercise-label: "Exercice",
  correction-label: "Corrigé",
)

#show: exo-auto-chapter

= Exercices

#exo(
  exercise: [Résoudre $x^2 - 5x + 6 = 0$.],
  solution: [$x in {2, 3}$],
  correction: [On cherche deux nombres de somme $5$ et de produit $6$ : ce sont
    $2$ et $3$. Donc $x^2 - 5x + 6 = (x - 2)(x - 3)$ et les solutions sont
    $x = 2$ et $x = 3$.],
)

#exo(
  exercise: [Déterminer la dérivée de $f(x) = x^3 - 3x$.],
  solution: [$f'(x) = 3x^2 - 3$],
  correction: [On dérive terme à terme : $(x^3)' = 3x^2$ et $(3x)' = 3$, d'où
    $f'(x) = 3x^2 - 3 = 3(x^2 - 1) = 3(x-1)(x+1)$.],
)
