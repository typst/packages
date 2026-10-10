// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Moteur commun des arbres (non exporté) : arbre-probas, arbre-div.
//
// Arbre homogène à K niveaux : `branchements` = (b1, …, bK), nombre
// d'enfants de chaque nœud du niveau k – 1. Les nœuds d'un niveau sont
// numérotés de haut en bas à partir de 0 ; le nœud i du niveau k a pour
// parent le nœud quo(i, bk) du niveau k – 1, et son « chemin » est la liste
// des rangs (0 ≤ rang < bj) choisis à chaque niveau depuis la racine.
//
// Nœuds CeTZ créés : "R" (racine), puis "A" + niveau + numéro à partir de 1
// ("A11", "A12", …, "A21", …), comme EnvArbreProbasTikz de ProfLycee.
#import "deps.typ": cetz

// Fonctions à fournir :
//   etiquette(k, i, chemin)  -> contenu du nœud i du niveau k ;
//   proba(k, i, chemin)      -> none, ou (contenu, position) pour la branche
//                               qui arrive au nœud : position "dessus",
//                               "dessous", "sur", ou none (= "sur").
#let _arbre-dessin(
  branchements,
  etiquette,
  proba: (k, i, chemin) => none,
  racine: none,
  espace-niveau: 3.25,
  espace-feuille: 1,
  fleche: false,
  trait: (paint: black, thickness: 0.6pt),
  police: x => x,
  police-probas: x => x,
  couleur-noeuds: black,
  couleur-probas: black,
  incline-probas: true,
  position-probas: none,
) = {
  import cetz.draw: *

  let K = branchements.len()
  let produit(t) = t.fold(1, (a, b) => a * b)
  // nombre de nœuds au niveau k, et de feuilles sous un nœud du niveau k
  let nb(k) = produit(branchements.slice(0, k))
  let sous(k) = produit(branchements.slice(k))
  let chemin(k, i) = range(k).map(j => calc.rem(calc.quo(i, sous(j + 1) / sous(k)), branchements.at(j)))

  // Feuilles régulièrement espacées, centrées sur la racine ; chaque nœud à
  // mi-hauteur de ses feuilles.
  let y-feuille(j) = ((nb(K) - 1) / 2 - j) * espace-feuille
  let pos(k, i) = (k * espace-niveau, (y-feuille(i * sous(k)) + y-feuille((i + 1) * sous(k) - 1)) / 2)
  let nom(k, i) = if k == 0 { "R" } else { "A" + str(k) + str(i + 1) }
  let noeud(x) = text(fill: couleur-noeuds, police(x))

  content(pos(0, 0), noeud(if racine == none { [] } else { racine }), name: "R", padding: 0.1)
  for k in range(1, K + 1) {
    for i in range(nb(k)) {
      let c = chemin(k, i)
      let parent = calc.quo(i, branchements.at(k - 1))
      content(pos(k, i), noeud(etiquette(k, i, c)), name: nom(k, i), padding: 0.1)
      line(
        nom(k - 1, parent) + ".east",
        nom(k, i) + ".west",
        stroke: trait,
        mark: if fleche { (end: "stealth", fill: trait.at("paint", default: black)) },
      )

      let p = proba(k, i, c)
      if p == none or p.first() == none { continue }
      let ((x0, y0), (x1, y1)) = (pos(k - 1, parent), pos(k, i))
      let position = if position-probas == "auto" {
        if y1 >= y0 { "dessus" } else { "dessous" }
      } else if position-probas != none { position-probas } else if p.at(1) == none { "sur" } else {
        (above: "dessus", below: "dessous").at(p.at(1), default: p.at(1))
      }
      let angle = if incline-probas { calc.atan2(x1 - x0, y1 - y0) } else { 0deg }
      let texte = text(fill: couleur-probas, police-probas(p.first()))
      let milieu = ((x0 + x1) / 2, (y0 + y1) / 2)
      if position == "dessus" {
        content(milieu, texte, angle: angle, anchor: "south", padding: 0.08)
      } else if position == "dessous" {
        content(milieu, texte, angle: angle, anchor: "north", padding: 0.08)
      } else {
        // sur la branche : fond blanc pour masquer le trait
        content(milieu, texte, angle: angle, padding: 0.05, frame: "rect", fill: white, stroke: none)
      }
    }
  }
}
