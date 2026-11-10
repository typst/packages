// Example — compile with:  typst compile example.typ
// (or from anywhere:     typst compile example.typ /tmp/out.pdf --root .)
//
// Les figures ont des tailles naturelles très différentes (~1.7 cm à ~31 cm).
// `fit-scale` met chaque figure à l'échelle pour qu'elle tienne dans sa
// cellule, comme le fait l'atlas.
#import "@preview/figchild:0.1.0": *

#set page(width: 21cm, height: 29.7cm, margin: 1.5cm)

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

#align(center, text(size: 20pt, weight: "bold")[figchild — 561 figures])

#v(8pt)
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  row-gutter: 8pt,
  align(center, canvas(fc-owl-a(scale: fit-scale(fc-owl-a)))),
  align(center, canvas(fc-dino(scale: fit-scale(fc-dino)))),
  align(center, canvas(fc-pumpkin(scale: fit-scale(fc-pumpkin)))),
  align(center, canvas(fc-crown(scale: fit-scale(fc-crown)))),
  align(center, canvas(fc-caterpillar(scale: fit-scale(fc-caterpillar)))),
  align(center, canvas(fc-butterfly(scale: fit-scale(fc-butterfly)))),
  align(center, canvas(fc-turtle(scale: fit-scale(fc-turtle)))),
  align(center, canvas(fc-giraffe(scale: fit-scale(fc-giraffe)))),
  align(center, canvas(fc-ice-cream-a(scale: fit-scale(fc-ice-cream-a)))),
  align(center, canvas(fc-air-ballon(scale: fit-scale(fc-air-ballon)))),
  align(center, canvas(fc-bee(scale: fit-scale(fc-bee)))),
  align(center, canvas(fc-balloon(scale: fit-scale(fc-balloon)))),
)

#v(10pt)
#text(size: 13pt, weight: "bold")[Options à la TikZ]
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align(center, canvas(fc-owl-a(scale: fit-scale(fc-owl-a)))),
  align(center, canvas(fc-crown(scale: fit-scale(fc-crown), rotate: 25deg))),
  align(center, canvas(fc-apple(scale: fit-scale(fc-apple), fill: red))),
  align(center, canvas(fc-fish(scale: fit-scale(fc-fish), rotate: 90deg))),
)

#v(10pt)
#text(size: 13pt, weight: "bold")[Variante « fait main » (Scrawl)]
#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 8pt,
  align(center, scrawl(fc-owl-a(scale: fit-scale(fc-owl-a, size: 3.6cm)), seed: 1, margin: 0.1)),
  align(center, scrawl(fc-dino(scale: fit-scale(fc-dino, size: 3.6cm)), seed: 2, margin: 0.1)),
  align(center, scrawl(fc-pumpkin(scale: fit-scale(fc-pumpkin, size: 3.6cm)), seed: 3, margin: 0.1)),
  align(center, scrawl(fc-crown(scale: fit-scale(fc-crown, size: 3.6cm)), seed: 4, margin: 0.1)),
)

#v(10pt)
#text(fill: rgb("#666666"))[
  #figure-names.len() figures portées — #figure-names.first() … #figure-names.last()
]
