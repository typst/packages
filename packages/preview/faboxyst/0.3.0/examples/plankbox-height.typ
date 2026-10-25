// Local example for faboxyst 0.3.0 after the plankbox height fix.
// The relative import uses the package source in ../lib.typ.
#import "@preview/faboxyst:0.3.0": plankbox

#set page(paper: "a4", margin: 1.4cm)
#set text(size: 12pt)

#align(center)[
  #plankbox(
    // width: auto by default: it fits this line of text.
    height: 2cm,
    tilt: 0deg,
    inset: (x: 0.55cm, y: 0.15cm),
  )[Largeur automatique, hauteur extérieure fixée à 2 cm]
]
