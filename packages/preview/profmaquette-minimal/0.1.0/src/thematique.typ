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

// Titre d'une thématique de la fiche, en gras, jamais numéroté. Ce n'est pas un
// `heading` : insensible aux réglages de titres du document, absent de la table
// des matières. Sur la feuille de route, il termine la thématique précédente
// (coche après son dernier exercice).
//   alignement : left (défaut), center ou right
#let thematique(alignement: left, titre) = {
  [#metadata(none) #repere-thematique]
  protege(rendre => bloc-neutre(width: 100%, above: 1.4em, below: .9em, sticky: true, align(
    alignement,
    text(size: 14pt * echelle(), weight: "bold", rendre(titre)),
  )))
}
