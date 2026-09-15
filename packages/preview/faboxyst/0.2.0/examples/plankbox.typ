// faboxyst — plankbox / pancarte: a rustic wooden sign.
#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", margin: (x: 1.4cm, y: 1.4cm), fill: white)
#set text(size: 12pt)
#set text(font: "Caveat")
#show: faboxyst.with(theme: (lang: "fr", dir: ltr))

// The sign of the description: one light plank filling a centred frame,
// about 2.4 times as wide as high, very slightly leaning, faint shadow
// under the lower edge.
#align(center, block(width: 10cm)[#plankbox[Ma lettre de fin d'année]])

#v(0.7cm)

// Title on the upper plank, body on the lower one.
#plankbox(title: [Ma lettre], width: 80%)[de fin d'année]

#v(0.7cm)

// A longer body; the plank grows with the text.
#plankbox(title: [Récréation], width: 74%)[
  On range les cahiers, on chausse les baskets,
  et toute la cour sent l'herbe coupée de juin.
]

#v(0.7cm)

// Recoloured walnut, steeper lean.
#plankbox([Atelier menuiserie — salle 12],
  wood: rgb("#C89058"), streak: rgb("#8A5A2B"),
  tilt: 4deg, width: 58%)

#v(0.7cm)

// RTL: the sign leans the other way, details mirrored.
#pancarte(title: [رسالتنا], width: 64%, direction: rtl)[نهاية السنة الدراسية]
