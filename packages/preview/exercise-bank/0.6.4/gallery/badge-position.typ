// Badge position - exercise-bank
// badge-position: "above" frees the width the left badge column costs on every
// line, which matters most in a narrow measure and with enumerations

#import "@preview/exercise-bank:0.6.4": *

#set page(width: 9cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)
#set par(justify: true)

#let statement = [
  Lors d'une élection, il y avait 41751 inscrits, 22159 votants et M. X a
  obtenu 12826 voix.
  + Donner le résultat de M. X en pourcentage des votants, puis en pourcentage
    des inscrits.
  + Donner le pourcentage d'abstention.
]

#exo-setup(badge-style: "filled-circle", badge-color: rgb("#1a4f8a"))

*badge-position: "margin"* (défaut)

#exo(exercise: statement)

#v(0.5em)

*badge-position: "above"*

#exo-setup(badge-position: "above")

#exo(exercise: statement)
