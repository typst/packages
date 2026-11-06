// End-of-chapter corrections - exercise-bank
// exo-auto-chapter prints the pending corrections before each new level-1
// heading and at the end of the document

#import "@preview/exercise-bank:0.6.0": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt)

#exo-setup(
  corr-loc: "end-chapter",
  counter-reset: "chapter",
  exercise-label: "Exercice",
  solution-label: "Corrigé",
)

#show: exo-auto-chapter

= Chapitre 1

#exo(
  exercise: [Résoudre $2x + 3 = 11$.],
  solution: [$2x = 8$, donc $x = 4$.],
)

#exo(
  exercise: [Factoriser $x^2 - 16$.],
  solution: [$x^2 - 16 = (x-4)(x+4)$.],
)

= Chapitre 2

Les corrigés du chapitre 1 apparaissent ci-dessus, juste avant ce titre.

#exo(
  exercise: [Résoudre $x^2 = 25$.],
  solution: [$x = 5$ ou $x = -5$.],
)
