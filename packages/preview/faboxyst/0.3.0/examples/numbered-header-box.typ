// Fused rounded title band, trapezoid tab, circle badge, and normal body.
#import "@preview/faboxyst:0.3.0": numbered-header-box
#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "DejaVu Sans", size: 11pt)

#numbered-header-box(
  title: [Concept essentiel],
)[
  Une courte définition pour un concept essentiel.
]

#v(0.45cm)
#numbered-header-box(
  title: [Exemple personnalisé],
  number: 8,
  width: 10cm,
  inset: (0.55cm, 0.40cm),
  direction: ltr,
)[
  La largeur, le numéro et les marges intérieures peuvent être réglés.
]
