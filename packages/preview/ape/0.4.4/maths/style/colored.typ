#import "../maths.typ": *


#let maths-block-colored-line(color, title, content) = context {
  
 
breakable-or-not(min-size: 60pt)[
#block(
sticky: true,
below: 0.5em,
text(fill: color.darken(35%), size: 1.1em, weight: "bold", font: "New Computer Modern Sans")[#title]
)
 
#block(
width: 100%,
stroke: (left: (paint: color.transparentize(20%), thickness: 1.5pt, cap: "round")),
inset: (left: 18pt, top: 4pt, bottom: 4pt), 
outset: (left: -8pt),
content
)
]
}

#let maths-block-colored(color, type, title, content) = context {
 
let header = if title == [] {
[#type #get-maths-count(type)]
} else {
[#type #get-maths-count(type) --- #title]
}
breakable-or-not(
block(
width: 100%,
fill: color.lighten(90%), // Fond léger
stroke: (left: (paint: color, thickness: 2pt), rest: 0pt), // Barre latérale forte
radius: (right: 4pt), // Arrondi uniquement à droite
inset: 12pt,
[
#block(
sticky: true,
below: 0.8em,
text(
fill: color.darken(35%),
weight: "bold",
size: 1.2em,
font: "New Computer Modern Sans"
)[#header]
)
#content
]
)
)
}
#let maths-block-colored-sidebar(color, type, title, content) = context { 
let header = if title == [] {
[#type #get-maths-count(type)]
} else {
[#type #get-maths-count(type) --- #title]
}
maths-block-colored-line(color, header, content)
}
#let def(title, content) = context maths-block-colored(green, "Définition", title, content)
#let prop(title, content) = context maths-block-colored(blue, "Proposition", title, content)
#let theorem(title, content) = context maths-block-colored(red, "Théorème", title, content)
#let corollaire(title, content) = context maths-block-colored(orange, "Corollaire", title, content)
#let lemme(title, content) = context maths-block-colored(purple, "Lemme", title, content)
#let exercice(title, content) = context maths-block-colored(black, "Exercice", title, content)
#let remarque(title, content) = context maths-block-colored-sidebar(black, "Remarque", title, content)
#let exemple(title, content) = context maths-block-colored-sidebar(gray, "Exemple", title, content)
#let rappel(title, content) = context maths-block-colored-sidebar(gray, "Rappel", title, content)
#let correction(content) = context maths-block-colored-line(black, "Correction", content)
#let demo(content) = context maths-block-colored-line(black, "Démonstration", content)



