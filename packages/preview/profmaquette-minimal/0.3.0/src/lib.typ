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

// Point d'entrée du paquet, exporte les 6 fonctions publiques.
//
// profmaquette-minimal : portage minimaliste, en Typst, du paquet LaTeX
// ProfMaquette (Christophe Poulain). Point d'entrée déclaré dans typst.toml :
// seules les six fonctions ci-dessous sont exportées.
//
// Organisation de src/ :
//   lib.typ                  ce fichier
//   deps.typ                 dépendances externes (tiaoma, pour les QR codes)
//   maquette.typ             une fonction publique par fichier
//   exercice.typ
//   corrige.typ
//   thematique.typ
//   afficher-fdr.typ
//   seyes.typ
//   interne/                 code partagé, jamais exporté :
//     etats.typ              états (`state`) partagés entre les fonctions
//     utils.typ              sélection des corrigés, langues, `protege`…
//     dessins.typ            icônes, cadres, rendu d'un corrigé
//     cartouche.typ          cartouche de titre de la fiche
//     blocs-fin.typ          blocs « Automatismes » et « Correction »
//     bareme.typ             barème des interros (total, note des questions)
//   icones/                  SVG Font Awesome Free (CC BY 4.0)
//
// Convergence : Typst recompile au plus 5 fois pour stabiliser les requêtes, et
// la chaîne « clé d'exercice → corrigé → mesure du cadre » est longue. Pour
// qu'elle converge :
//   • les `state.update(…)` se font hors `context`, avec des valeurs fixes ;
//   • la mise en page ne dépend jamais du résultat d'une `query` ;
//   • les cadres sont mesurés à la volée (`layout`, `measure`), sans compteur
//     ni état (ce qui empêchait showybox de converger avec plusieurs maquettes).

#import "maquette.typ": maquette
#import "exercice.typ": exercice
#import "corrige.typ": corrige
#import "thematique.typ": thematique
#import "afficher-fdr.typ": afficher-fdr
#import "seyes.typ": seyes
