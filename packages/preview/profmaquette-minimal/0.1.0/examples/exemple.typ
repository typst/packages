// Exemple complet du paquet profmaquette-minimal : une petite fiche d'exercices avec
// feuille de route, entraînement en ligne, exercices hors route et corrigés en fin
// de fiche.
//
// Pour essayer d'autres réglages, modifiez seulement les paramètres de `maquette` :
//   liste-corriges: ()               → fiche élève, sans corrigé
//   position-corriges: "apres" → corrigé sous chaque énoncé
//   liste-corriges: "1,3"            → seulement les corrigés des exercices 1 et 3
//   liste-corriges: "pas-route"      → seulement les corrigés des exercices hors route
//   couleur-externe: blue, couleur-interne: green.darken(20%)  → autres couleurs
//   style-exercice: "bandeau"   → autre style de cadre ("etiquette-encadree", "etiquette-pleine"…)

#import "@preview/profmaquette-minimal:0.1.0": maquette, exercice, corrige, afficher-fdr, thematique

#set page(paper: "a4", margin: 1.5cm)
#set text(lang: "fr", size: 11pt)
#set enum(numbering: "1.a)")

#align(center, text(size: 16pt, weight: "bold")[Fiche d'exercices : second degré])
#v(1em)

#maquette(
  position-corriges: "fin",
  liste-corriges: auto,
  vers-corrige: true,
  nombre-qr: 4,
)[

  // Feuille de route : exercices sur la route en bas, hors route en haut, coche
  // à la fin de chaque thématique (chaque #thematique ferme la précédente).
  #align(center, afficher-fdr)

  #thematique[Factoriser, résoudre]

  #exercice(
    titre: "Identités remarquables",
    entrainement: "https://typst.app/universe",
    source: "Calculs 30.1 ; 30.2",
  )[
    Factoriser les expressions suivantes.
    + $A(x) = x^2 - 9$
    + $B(x) = 4x^2 + 12x + 9$
  ]
  #corrige[
    + $A(x) = x^2 - 3^2 = (x - 3)(x + 3)$.
    + $B(x) = (2x)^2 + 2 times 2x times 3 + 3^2 = (2x + 3)^2$.
  ]

  #exercice(titre: "Pour aller plus loin", route: false)[
    Résoudre dans $RR$ l'équation $x^2 - 9 = 0$.
  ]
  #corrige[
    D'après l'exercice 1, $x^2 - 9 = (x - 3)(x + 3)$ : les solutions sont $-3$ et $3$.
  ]

  #thematique[Forme canonique]

  #exercice(titre: "Forme canonique", titre-complement: "méthode")[
    Écrire $f(x) = x^2 + 6x + 5$ sous forme canonique.
  ]
  #corrige[
    $f(x) = (x + 3)^2 - 9 + 5 = (x + 3)^2 - 4$.
  ]

  #exercice(titre: "Sans corrigé", pas-corrige: true)[
    Inventer un trinôme dont les racines sont $1$ et $5$.
  ]
  #corrige[
    Ce corrigé n'apparaît pas (`pas-corrige: true`).
  ]
]
