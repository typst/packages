#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (left: 2cm, right: 4cm), fill: white)
#set text(16pt)

#let lab(body) = rect(stroke: silver, inset: 2pt, text(size: .7em, font: "DejaVu Sans Mono", body))
#let annot = annot.with(annot-inset: 0pt)

#grid(
  columns: 3,
  gutter: (4cm, 8cm),
  $
    markrect(integral x dif x, tag: #<1>, color: #red)

    #annot(<1>, pos: top, lab[top])
    #annot(<1>, pos: left, lab[left])
    #annot(<1>, pos: bottom, lab[bottom])
    #annot(<1>, pos: right, lab[right])
  $,
  $
    markrect(integral x dif x, tag: #<1>, color: #red)

    #annot(<1>, pos: top + left, lab[top + left])
    #annot(<1>, pos: top + right, lab[top + right])
    #annot(<1>, pos: bottom + left, lab[bottom + left])
    #annot(<1>, pos: bottom + right, lab[bottom + right])
  $,
  $
    markrect(integral x dif x, tag: #<1>, color: #red)

    #annot(<1>, pos: (top + left, bottom + right), lab[(top + left, bottom + right)])
    #annot(<1>, pos: (top + left, top + right), lab[(top + left, top + right)])
    #annot(<1>, pos: (top + left, bottom + left), lab[(top + left, bottom + left)])
    #annot(<1>, pos: (top + left, top + left), lab[(top + left, top + left)])
  $,
)
