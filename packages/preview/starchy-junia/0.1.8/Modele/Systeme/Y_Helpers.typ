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

// Fonction pour l'affichage de plusieurs page d'un PDF, pour les figures ou les annexes
#let f_afficher_pdf(
  // Chemin vers le PDF
  chemin: "",
  // Légende de la figure / annexe
  legende: [],
  // Première page du document à affiché
  premiere_page: 0,
  // Dernière page du document à affiché
  derniere_page: 1,
  // Largeur de la page
  largeur: 85%,
  // Tag de la figure
  tag : "",
) = {
  if tag != "" {
    assert(
      not tag.contains(" "),
      message: "Le tag ne doit pas contenir d'espaces : \"" + tag + "\""
    )
  }
  for nb_page in range((premiere_page + 1), (derniere_page + 1)) {
    align(horizon+center)[
      #figure(
        image(
          chemin,
          width: largeur,
          page: nb_page,
        ),
        caption: if (nb_page == premiere_page + 1) { legende } else { none },
        numbering: if (nb_page == premiere_page + 1) { "1" } else { none },
      )#if (tag != "" and nb_page == premiere_page + 1) { label(tag) }
    ]
  }
}