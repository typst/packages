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
// This work consists of the files src/lib.typ and src/exercices.typ.

// Point d'entrée du paquet profmaquette-minimal (déclaré dans typst.toml).
//
// Seules les fonctions listées ici sont accessibles aux utilisateurs du paquet :
// tout le reste de `exercices.typ` (états, outils, éléments graphiques) reste interne.
// Le code et sa documentation détaillée sont dans `exercices.typ`.

#import "exercices.typ": (
  maquette,
  exercice,
  corrige,
  afficher-fdr,
  thematique,
)
