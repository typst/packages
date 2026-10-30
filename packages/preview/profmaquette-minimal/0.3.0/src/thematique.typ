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

// Fonction thematique, titre d'une partie de la fiche.

#import "interne/etats.typ": *
#import "interne/utils.typ": *
#import "interne/blocs-fin.typ": entrainements-thematique

// Titre d'une thématique de la fiche, en gras, jamais numéroté. Ce n'est pas un
// `heading` : insensible aux réglages de titres du document, absent de la table
// des matières. Sur la feuille de route, il termine la thématique précédente
// (coche après son dernier exercice). Présentation (titre seul ou bandeau
// coloré) : `maquette(style-thematique: …, couleur-thematique: …)`. Avec
// `maquette(position-qr: "thematique")`, les QR codes de la thématique
// précédente s'affichent juste avant ce titre.
//   alignement : left (défaut), center ou right
#let thematique(
  alignement: left,
  titre,
) = {
  entrainements-thematique()
  // Hors `context`, avec une fonction fixe : sinon, pas de convergence.
  etat-qr-attente.update(q => (..q, items: (), titre: titre))
  [#metadata(none) #repere-thematique]
  protege(rendre => {
    let (style, couleur) = etat-thematique.get()
    if style == "bandeau" {
      // Comme le `filet-horizontal` des fiches d'origine : fond coloré, texte
      // du corps en gras, noir ou blanc selon la clarté du fond.
      let fond = if couleur == auto { rgb("#c9c5c5") } else { couleur }
      let e = echelle()
      bloc-neutre(
        width: 100%,
        above: 1.4em,
        below: .9em,
        sticky: true,
        fill: fond,
        radius: 4pt * e,
        inset: (x: 6pt * e, y: 7pt * e),
        align(alignement, text(
          weight: "bold",
          fill: if luma(fond).components().first() < 55% { white } else { black },
          rendre(titre),
        )),
      )
    } else {
      bloc-neutre(
        width: 100%,
        above: 1.4em,
        below: .9em,
        sticky: true,
        align(alignement, text(
          size: 14pt * echelle(),
          weight: "bold",
          ..if couleur != auto { (fill: couleur) },
          rendre(titre),
        )),
      )
    }
  })
}
