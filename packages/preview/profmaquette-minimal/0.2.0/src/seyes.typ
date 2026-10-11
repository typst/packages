// Copyright 2026 Arthur Meyer
//
// This work may be distributed and/or modified under the
// conditions of the LaTeX Project Public License, either version 1.3c
// of this license or (at your option) any later version.
// The latest version of this license is in
//   https://www.latex-project.org/lppl.txt
// and version 1.3c or later is part of all distributions of LaTeX
// version 2008 or later.
//
// This work has the LPPL maintenance status `maintained'.
// The Current Maintainer of this work is Arthur Meyer.
//
// This work consists of all the .typ files in the src/ directory
// and its subdirectories.

// Fonction seyes, une zone de réponse quadrillée.

#import "interne/etats.typ": *
#import "interne/utils.typ": *
#import "interne/dessins.typ": rendu-reponse, icone

// Réglures (reprises du paquet LaTeX WriteOnGrid de C. Pierquet) : épaisseur et
// couleur des lignes principales (tous les carreaux) et fines (interlignes).
#let styles-seyes = (
  seyes: (ep: .6pt, c: rgb("#E6B8E6"), ep-fine: .4pt, c-fine: rgb("#D7E2EE")),
  sobre: (ep: .6pt, c: black, ep-fine: .4pt, c-fine: rgb("#cccccc")),
  bleu: (ep: .65pt, c: rgb("#5b6b8c"), ep-fine: .12pt, c-fine: rgb("#a9b8d6")),
)

// Motif d'un carreau : trois interlignes fines, puis la ligne principale en
// haut (et à gauche si `vertical`).
#let motif-seyes(carreau, style, vertical) = {
  let r = styles-seyes.at(style)
  tiling(size: (carreau, carreau))[
    #for i in range(1, 4) {
      place(line(start: (0%, 25% * i), end: (100%, 25% * i), stroke: r.ep-fine + r.c-fine))
    }
    #place(line(start: (0%, 0%), end: (100%, 0%), stroke: r.ep + r.c))
    #if vertical { place(line(start: (0%, 0%), end: (0%, 100%), stroke: r.ep + r.c)) }
  ]
}

// Réponse affichée hors maquette : bandeau vert d'eau, crayon et « Corrigé
// (rempli en classe) », sur 99 % de la largeur. À appeler dans un `context`.
#let couleur-corrige-classe = rgb("#0a7d6b")
#let rendu-reponse-classe(reponse) = block(
  width: 99%,
  fill: couleur-corrige-classe.lighten(92%),
  stroke: (left: 3pt + couleur-corrige-classe),
  inset: 10pt,
)[
  #text(fill: couleur-corrige-classe.darken(20%), weight: "bold", size: 9pt)[
    #box(icone("pencil", 1em, couleur-corrige-classe.darken(20%))) #h(0.4em) #terme("corrige-classe")
  ]
  #v(0.4em)
  #reponse
]

// Zone de réponse sur papier Seyes, pleine largeur.
//   hauteur  : nombre de carreaux (4 → 4 × 8 mm) ou longueur (3cm)
//   reponse  : contenu facultatif, après la hauteur : #seyes(3)[la réponse]
//   carreau  : côté d'un carreau
//   style    : "seyes" (rose et bleu pâle), "sobre" (noir et gris) ou "bleu"
//   vertical : false = réglure Seyes pure, sans lignes verticales
//   afficher : true = la réponse à la place de la grille (version
//              « rattrapable », corrigé fait en classe) ; false = la grille,
//              la réponse reste cachée
// Dans une maquette, la réponse prend le cadre d'un corrigé (couleur-interne) ;
// hors maquette, un bandeau vert d'eau « ✎ Corrigé (rempli en classe) ».
// Avec `position-corriges: "apres-question"` (mode interro), le k-ième
// `#corrige` qui suit un exercice prend la place de son k-ième seyes.
// `afficher: true` passe avant : la zone compte quand même dans ce rang.
#let seyes(hauteur, ..reponse, carreau: 8mm, style: "seyes", vertical: true, afficher: false) = {
  let positive(l) = type(l) == length and l.abs >= 0pt and l.em >= 0 and l != 0pt
  assert(
    (type(hauteur) in (int, float) and hauteur > 0) or positive(hauteur),
    message: "seyes : la hauteur est un nombre de carreaux (4) ou une longueur (3cm), strictement positifs, pas " + repr(hauteur) + ".",
  )
  assert(
    positive(carreau),
    message: "seyes : carreau doit être une longueur strictement positive (8mm, 5mm…), pas " + repr(carreau) + ".",
  )
  assert(
    style in styles-seyes,
    message: "seyes : style doit valoir " + styles-seyes.keys().map(s => "\"" + s + "\"").join(", ", last: " ou ") + ", pas " + repr(style) + ".",
  )
  assert(
    reponse.pos().len() <= 1 and reponse.named().len() == 0,
    message: "seyes : après la hauteur, une seule réponse entre crochets (#seyes(3)[…]), pas " + repr(reponse) + ".",
  )
  assert(type(afficher) == bool, message: "seyes : afficher vaut true ou false, pas " + repr(afficher) + ".")
  let reponse = reponse.pos().at(0, default: none)
  let hauteur = if type(hauteur) == length { hauteur } else { hauteur * carreau }
  // Plus haute que la page : peut se couper (sinon, elle en déborderait).
  let grille = protege(_ => layout(dispo => bloc-neutre(
    width: 100%,
    height: hauteur,
    breakable: hauteur.to-absolute() > dispo.height,
    stroke: .5pt + gray,
    fill: motif-seyes(carreau, style, vertical),
  )))
  let recherche = protege(rendre => context {
    // etat-profondeur n'est lu qu'ici, pour une réponse affichée : lu par
    // chaque seyes, cet état (qui change en fin de maquette) empêche la
    // convergence d'un exercice plus haut qu'une page (test 226).
    if afficher and reponse != none {
      let hors-maquette = etat-profondeur.get() == 0
      return if hors-maquette { rendu-reponse-classe(reponse) } else { rendu-reponse(reponse, rendre: rendre) }
    }
    if etat-reglages-corriges.get().mode == "apres-question" and etat-historique.get().len() > 0 {
      let infos = infos-exercice()
      if infos.corrige {
        let cle = infos.id + "-" + str(etat-nb-seyes.get())
        let reponse = query(repere-reponse).filter(m => m.value.cle == cle)
        if reponse.len() > 0 { return rendu-reponse(reponse.first().value.body, rendre: rendre) }
      }
    }
    grille
  })
  // La grille en tête, en `metadata`, pour `rendu-reponse` (cf. repere-seyes).
  // Compteur hors `context`, avec une valeur fixe : sinon, pas de convergence.
  [#(metadata(grille) + etat-nb-seyes.update(n => n + 1) + recherche)#repere-seyes]
}
