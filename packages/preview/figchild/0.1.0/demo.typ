// figchild-port — démonstration du portage Typst du package LaTeX figchild 3.1.2
#import "@preview/figchild:0.1.0" as figchild
#import "@preview/figchild:0.1.0": *

#set page(width: 21cm, height: 29.7cm, margin: 1.5cm)
#set text(font: "Libertinus Serif", size: 11pt)

// Mise à l'échelle automatique pour que chaque figure tienne dans sa cellule
// (les tailles naturelles vont de ~1.7 cm à ~31 cm).
#let fit-scale(f, size: 4.0cm) = {
  let (x0, y0, x1, y1) = f().bbox
  let w = calc.max(0.1, x1 - x0)
  let h = calc.max(0.1, y1 - y0)
  calc.min(
    (size - 0.1cm) / (w * 1cm),
    (size * 0.95 - 0.1cm) / (h * 1cm),
    2.5,
  )
}

#align(center)[
  #text(size: 24pt, weight: "bold")[figchild — portage Typst]
  #v(2pt)
  #text(size: 11pt, fill: rgb("#666666"))[Reproduction fidèle des 561 figures du package LaTeX `figchild` v3.1.2 (F. de Souza Bastos, UFV) — moteur CeTZ 0.5.2 / Scrawl 0.1.0]
  #v(6pt)
  #line(length: 100%, stroke: 0.6pt + rgb("#999999"))
]

#v(10pt)
#text(size: 13pt, weight: "bold")[Rendu exact (CeTZ 0.5.2)]
#v(6pt)

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  align(center, figchild.canvas(fc-owl-a(scale: fit-scale(fc-owl-a)))),
  align(center, figchild.canvas(fc-dino(scale: fit-scale(fc-dino)))),
  align(center, figchild.canvas(fc-pumpkin(scale: fit-scale(fc-pumpkin)))),
  align(center, figchild.canvas(fc-crown(scale: fit-scale(fc-crown)))),
  align(center, figchild.canvas(fc-caterpillar(scale: fit-scale(fc-caterpillar)))),
  align(center, figchild.canvas(fc-butterfly(scale: fit-scale(fc-butterfly)))),
  align(center, figchild.canvas(fc-turtle(scale: fit-scale(fc-turtle)))),
  align(center, figchild.canvas(fc-giraffe(scale: fit-scale(fc-giraffe)))),
  align(center, figchild.canvas(fc-ice-cream-a(scale: fit-scale(fc-ice-cream-a)))),
  align(center, figchild.canvas(fc-air-ballon(scale: fit-scale(fc-air-ballon)))),
  align(center, figchild.canvas(fc-bee(scale: fit-scale(fc-bee)))),
  align(center, figchild.canvas(fc-balloon(scale: fit-scale(fc-balloon)))),
)

#v(12pt)
#text(size: 13pt, weight: "bold")[Variante « fait main » (Scrawl 0.1.0)]
#v(6pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  align(center, figchild.scrawl(fc-owl-a(scale: fit-scale(fc-owl-a, size: 3.6cm)), seed: 1, margin: 0.1)),
  align(center, figchild.scrawl(fc-dino(scale: fit-scale(fc-dino, size: 3.6cm)), seed: 2, margin: 0.1)),
  align(center, figchild.scrawl(fc-pumpkin(scale: fit-scale(fc-pumpkin, size: 3.6cm)), seed: 3, margin: 0.1)),
  align(center, figchild.scrawl(fc-crown(scale: fit-scale(fc-crown, size: 3.6cm)), seed: 4, margin: 0.1)),
  align(center, figchild.scrawl(fc-turtle(scale: fit-scale(fc-turtle, size: 3.6cm)), seed: 5, margin: 0.1)),
  align(center, figchild.scrawl(fc-bee(scale: fit-scale(fc-bee, size: 3.6cm)), seed: 6, margin: 0.1)),
  align(center, figchild.scrawl(fc-balloon(scale: fit-scale(fc-balloon, size: 3.6cm)), seed: 7, margin: 0.1)),
  align(center, figchild.scrawl(fc-caterpillar(scale: fit-scale(fc-caterpillar, size: 3.6cm)), seed: 8, margin: 0.1)),
)

#v(12pt)
#text(size: 13pt, weight: "bold")[Options à la TikZ : #raw("scale: 0.6"), #raw("rotate: 25deg"), #raw("fill: red")]
#v(6pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  align(center, figchild.canvas(fc-owl-a(scale: fit-scale(fc-owl-a), rotate: 0deg))),
  align(center, figchild.canvas(fc-crown(scale: fit-scale(fc-crown), rotate: 25deg))),
  align(center, figchild.canvas(fc-apple(scale: fit-scale(fc-apple), fill: red))),
  align(center, figchild.canvas(fc-fish(scale: fit-scale(fc-fish), rotate: 90deg))),
)

#v(12pt)
#text(size: 11pt, fill: rgb("#666666"))[
  Usage : #raw("#figchild.canvas(fc-owl-a())") — #raw("#figchild.canvas(fc-dino(scale: 0.5, rotate: 10deg))") — #raw("#figchild.scrawl(fc-owl-a(), seed: 7)").
  Toutes les figures : #raw("#import \"figures.typ\": *") — #raw("fc-…"), 561 fonctions.
]
