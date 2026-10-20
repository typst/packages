// Page corner - exercise-bank
// A worksheet with a QR code next to its title: the title rule, the exercise
// headers and the first statement all keep clear of it

#import "@preview/exercise-bank:0.8.0": *
#import "@preview/tiaoma:0.3.0": qrcode
#import "@preview/taskize:0.2.10": tasks

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 11pt, lang: "fr")

#exo-setup(display: "ex", badge-style: "underline", exercise-label: "Exercice")

#exo-corner(box(width: 2cm, qrcode("https://typst.app/universe/package/exercise-bank", width: 100%)))
#exo-corner-fit[
  #text(size: 1.5em, weight: "bold")[Fiche d'exercices]
  #v(-3pt)
  #line(length: 100%, stroke: 1.2pt)
]

#exo(exercise: [Calculer.
  #tasks(columns: "auto-fit")[
    + $2 times 3$
    + $4 times 5$
    + $6 times 7$
    + $8 times 9$
    + $12 times 3$
    + $15 times 4$
  ]
])

#exo(exercise: [Simplifier $3x + 2x - x$.])

#exo-setup(badge-style: "box")
