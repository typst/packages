#import "../Configuration/universe.typ": *

// Note dans la marge, gestion des infos lors de l'écriture du document.
#let note-de-marge(contenu) = margin-note(
  block(width: 100%)[
    #set text(size: 9pt, style: "italic") // Style plus discret
    #set align(left)                     // Alignement à droite
    #set par(justify: true)               // Justification
    #contenu
  ]
)

// Note dans le texte, gestion des infos lors de l'écriture du document.
#let note-de-texte(contenu) = inline-note(
  fill: blue.lighten(90%),   // Couleur de fond
  par-break: true,
  stroke: (
      paint: blue,
      thickness: 0.5pt,
      join: "round",
      dash: "solid",
    ),      // Couleur de bordure
)[
  #set text(size: 9pt, fill: blue.darken(20%)) // Couleur du texte
  #set par(justify: true)
  #contenu
]

// Fonction pour l'affichage de plusieurs pages d'un PDF, pour les figures ou les annexes
#let f-afficher-pdf(
  // Chemin vers le PDF
  chemin: "",
  // Légende de la figure / annexe
  legende: [],
  // Première page du document à afficher
  premiere-page: 0,
  // Dernière page du document à afficher
  derniere-page: 1,
  // Largeur de la page
  largeur: 85%,
  // Tag de la figure
  tag: "",
) = {
  if tag != "" {
    assert(
      not tag.contains(" "),
      message: "Le tag ne doit pas contenir d'espaces : \"" + tag + "\""
    )
  }
  for nb-page in range((premiere-page + 1), (derniere-page + 1)) {
    align(horizon+center)[
      #figure(
        image(
          chemin,
          width: largeur,
          page: nb-page,
        ),
        caption: if (nb-page == premiere-page + 1) { legende } else { none },
        numbering: if (nb-page == premiere-page + 1) { "1" } else { none },
      )#if (tag != "" and nb-page == premiere-page + 1) { label(tag) }
    ]
  }
}
