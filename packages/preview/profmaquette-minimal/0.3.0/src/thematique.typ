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

// Titre d'une thématique de la fiche, jamais numéroté, présenté comme le
// `filet-horizontal` des cours : petite barre noire, titre en gras, trait gris
// jusqu'à la marge. Ce n'est pas un `heading` : insensible aux réglages de
// titres du document, absent de la table des matières. Sur la feuille de route,
// il termine la thématique précédente (coche après son dernier exercice).
// Couleur du trait : `maquette(couleur-thematique: …)`. Avec
// `maquette(position-qr: "thematique")`, les QR codes de la thématique
// précédente s'affichent juste avant ce titre.
//   alignement : left (défaut), center ou right ; le titre glisse le long du
//                trait, la barre reste à gauche
#let thematique(
  alignement: left,
  titre,
) = {
  entrainements-thematique()
  // Hors `context`, avec une fonction fixe : sinon, pas de convergence.
  etat-qr-attente.update(q => (..q, items: (), titre: titre))
  [#metadata(none) #repere-thematique]
  protege(rendre => {
    let couleur = etat-thematique.get()
    let trait = boite-neutre(
      width: 1fr,
      baseline: -.3em,
      line(length: 100%, stroke: .8pt + if couleur == auto { rgb("#8a8a8a") } else { couleur }),
    )
    let texte = strong(rendre(titre))
    let barre = boite-neutre(width: .45cm, height: 1em, baseline: .2em, fill: black)
    // Espaces comprises autour des `h`, comme dans le balisage du filet.
    bloc-neutre(width: 100%, above: 2.2em, below: 1.1em, sticky: true, if alignement == left {
      [#barre #h(.4em) #texte #h(.4em) #trait]
    } else if alignement == center {
      [#barre #h(.4em) #trait #h(.4em) #texte #h(.4em) #trait]
    } else {
      [#barre #h(.4em) #trait #h(.4em) #texte]
    })
  })
}
