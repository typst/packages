// Two-column layouts - exercise-bank
// exo-columns puts a block of exercises on two columns with a vertical rule;
// corr-columns does the same for the corrections collected at the chapter end

#import "@preview/exercise-bank:0.6.4": *

#set page(width: 13cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 9.5pt)
#set par(justify: true)

#exo-setup(
  exercise-label: "Exercice",
  correction-label: "Corrigé",
  badge-style: "filled-rect",
  badge-color: rgb("#1a5276"),
  corr-display: "correction",
  corr-loc: "end-section",
  // The collected corrections get their own two columns, with the same rule
  corr-columns: 2,
  corr-columns-gutter: 0.7cm,
  corr-columns-rule: 0.5pt + luma(160),
)

#exo-columns(count: 2, gutter: 0.7cm, rule: 0.5pt + luma(160))[
  #exo(
    exercise: [Trouver deux sous-ensembles $A$ et $B$ de $ZZ$ tels que
      $A union B = {0; 1; 2}$ et $A inter B = emptyset$.],
    correction: [$A = {0}$ et $B = {1; 2}$, par exemple.],
  )
  #exo(
    exercise: [Résoudre $x^2 - 5x + 6 = 0$.],
    correction: [$Delta = 1$, donc $S = {2; 3}$.],
  )
  #exo(
    exercise: [Écrire $[-1; 4[ inter [2; +oo[$ sous forme d'intervalle.],
    correction: [$[2; 4[$.],
  )
  #exo(
    exercise: [Résoudre $sqrt(x + 4) = x - 2$, sans oublier de vérifier les
      solutions trouvées.],
    correction: [$x = 5$ ($x = 0$ est parasite).],
  )
]

#exo-section-end()
