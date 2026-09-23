// atlas.typ — toutes les 561 figures du portage figchild, en pages A4
// Chaque figure est automatiquement mise à l'échelle pour tenir dans sa
// cellule (les tailles naturelles vont de ~1.7 cm à ~31 cm).
#import "figchild.typ" as figchild
#import "figures.typ": *

#set page(width: 21cm, height: 29.7cm, margin: 0.8cm)
#set text(size: 6pt, fill: rgb("#444444"))

// Échelle qui fait tenir la figure dans une boîte de `size` × `size·0.92`
// (sans dépasser 4× pour ne pas gonfler excessivement les mini-figures).
#let fit-scale(f, size: 4.35cm) = {
  let (x0, y0, x1, y1) = f().bbox
  let w = calc.max(0.1, x1 - x0)
  let h = calc.max(0.1, y1 - y0)
  calc.min(
    (size - 0.1cm) / (w * 1cm),
    (size * 0.92 - 0.1cm) / (h * 1cm),
    4.0,
  )
}

#let figcell(f) = {
  let fig = f()
  let name = fig.name
  let s = fit-scale(f)
  block(width: 100%, {
    align(center, figchild.canvas(f(scale: s), padding: 0.04cm))
    v(1.5pt)
    align(center, text(size: 5.5pt, name))
  })
}

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 4pt,
  row-gutter: 6pt,
  ..all-figures.map(figcell),
)
