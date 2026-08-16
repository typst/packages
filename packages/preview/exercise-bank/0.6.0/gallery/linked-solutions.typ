// Clickable exercise <-> correction links - exercise-bank
// When corrections are deferred (end-chapter, end-section, pagebreak), an
// arrow icon on the exercise jumps to its correction, and the correction
// carries a back-link to the statement

#import "@preview/exercise-bank:0.6.0": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt)

#exo-setup(
  corr-loc: "end-chapter",
  link-solutions: true,
  exercise-label: "Exercice",
  solution-label: "Corrigé",
)

#show: exo-auto-chapter

= Exercices

#exo(
  exercise: [L'icône flèche à côté du badge est cliquable : elle mène au corrigé
    en fin de chapitre. Résoudre $x^2 - 5x + 6 = 0$.],
  solution: [On factorise : $(x-2)(x-3) = 0$, donc $x in {2, 3}$.
    L'icône retour ramène à l'énoncé.],
)

#exo(
  exercise: [Calculer $integral_0^1 x^2 dif x$.],
  solution: [$integral_0^1 x^2 dif x = [x^3 / 3]_0^1 = 1/3$.],
)

== Style manuel scolaire

Avec `link-style: "page"`, l'icône est remplacée par une référence
« Corrigé p. N » cliquable en haut à droite de l'énoncé :

#exo-setup(
  link-style: "page",
  badge-style: "filled-rect",
  badge-color: rgb("#1a4d8f"),
)

#exo(
  exercise: [Esquisser le graphe d'une primitive de la fonction $f$.],
  solution: [Toute primitive $F$ vérifie $F' = f$ : on lit la pente de $F$
    sur le graphe de $f$.],
)
