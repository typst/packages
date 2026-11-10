// Direct control of the interline spacing in plankbox.
#import "@preview/faboxyst:0.3.0": plankbox

#set page(paper: "a4", margin: 1.4cm)
#set text(size: 12pt)

#plankbox(
  leading: 0.85em,
  tilt: 0deg,
)[
  Première ligne de texte. \
  Deuxième ligne de texte. \
  Troisième ligne de texte.
]
