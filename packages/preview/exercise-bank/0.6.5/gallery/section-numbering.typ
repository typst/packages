// Per-section numbering and corrections - exercise-bank
// number-prefix "section" + exo-auto-chapter: nothing to call by hand

#import "@preview/exercise-bank:0.6.5": *

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt, lang: "fr")
#set heading(numbering: "1.1")

#show: exo-auto-chapter
#exo-setup(
  number-prefix: "section",    // 1.2.1 = exercise 1 of section 1.2
  corr-loc: "end-section",     // solutions before the next section
  exercise-label: "Exercice",
  label-font-size: 10pt,
)

= Équations
== Premier degré
#exo(exercise: [Résoudre $2x + 3 = 7$.], solution: [$x = 2$])
#exo(exercise: [Résoudre $5 - x = 1$.], solution: [$x = 4$])

== Second degré
#exo(exercise: [Résoudre $x^2 = 9$.], solution: [$x in {-3, 3}$])
