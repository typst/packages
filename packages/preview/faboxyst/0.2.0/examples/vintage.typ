// faboxyst — vintage frames: the eight scrollwork frames of the SVG sheet
// and the six bracket plaques of the EPS sheet, redrawn as Typst vectors.
#import "@preview/faboxyst:0.2.0": *

#set page(width: 17cm, height: 24cm, margin: 1.2cm, fill: rgb("#F4F6F8"))
#set text(size: 11pt, fill: rgb("#222222"))

#let cap(t) = text(size: 8pt, fill: rgb("#77808A"), t)

#align(center)[#text(size: 15pt, weight: "bold")[Cadres vintage — eight line-art frames]]
#v(0.5cm)

#for s in ("volutes", "curls", "loops", "petals", "fans", "waves", "hooks", "fleuron") {
  align(center, block(width: 9.5cm, vintageframe(style: s)[Titre de chapitre]))
  v(0.10cm)
  align(center, cap[#s])
  v(0.30cm)
}

#pagebreak()

#align(center)[#text(size: 15pt, weight: "bold")[Plaques vintage — six bracket plaques]]
#v(0.6cm)

#align(center, grid(
  columns: (auto, auto, auto),
  column-gutter: 14pt,
  row-gutter: 16pt,
  align(center, vintagebox(variant: "medaillon", width: 4cm, height: 4cm)[1900]),
  align(center, vintagebox(variant: "haut", width: 3.4cm, height: 5cm)[Menu]),
  align(center, vintagebox(variant: "colonne", width: 3cm, height: 8cm)[Chapitres]),
  align(center, vintagebox(variant: "carre", width: 3.6cm, height: 3.2cm)[N°]),
  align(center, vintagebox(variant: "ovale", width: 4.4cm, height: 3cm)[Prix]),
  align(center, vintagebox(variant: "banniere", width: 7cm, height: 2.6cm)[VINTAGE]),
))

#v(0.8cm)

#align(center, vintagebox(variant: "banniere", width: 12cm, height: 3cm,
  ink: rgb("#3E2F23"), shadow: rgb("#D8CFC2"))[#text(size: 14pt)[Maison Fergus — depuis 1902]])
