#import "@preview/beautiframe:0.1.0": *

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[QED Symbol Options]]

#beautiframe-setup(style: "minimal")

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  [
    *Default (□):*
    #qed-square()
    #proof[Hollow square symbol.]
  ],
  [
    *Filled (■):*
    #qed-filled()
    #proof[Filled square symbol.]
  ],
  [
    *Tombstone (∎):*
    #qed-tombstone()
    #proof[Tombstone/halmos.]
  ],
  [
    *CQFD:*
    #qed-cqfd()
    #proof[French abbreviation.]
  ],
  [
    *Slashes:*
    #qed-slashes()
    #proof[Double slash ending.]
  ],
  [
    *Q.E.D.:*
    #qed-text()
    #proof[Latin abbreviation.]
  ],
)
