// faboxyst — plank-pages / torn-pages / coil-pages: any of the three
// boxes as a frame on every page, after `ornate-pages`.
#import "@preview/faboxyst:0.2.0": *

#set text(size: 10.5pt)
#show: faboxyst.with(theme: (lang: "fr", dir: ltr))

#torn-pages(margin: 0.6cm, gap: 0.7cm)[
  = Une feuille déchirée en cadre

  Le texte coule dans la page pendant que la feuille déchirée s'imprime
  en fond, à chaque page, comme un cadre. La bordure fractale du bas
  reste visible sous le texte, et l'ombre décolle la feuille du papier.

  #lorem(120)
]

#pagebreak()

#plank-pages(margin: 0.7cm, gap: 0.8cm)[
  = Une pancarte en cadre

  Même principe avec la pancarte en bois : deux planches creuses bordent
  la page entière, le texte s'écrit entre les planches.

  #lorem(100)
]

#pagebreak()

#coil-pages(margin: 0.45cm, gap: 0.5cm)[
  = Un cahier en cadre

  Et le cahier à spirale rose borde la page : cadre arrondi, tranche
  perforée et ressort 3D sur toute la hauteur.

  #lorem(110)
]
