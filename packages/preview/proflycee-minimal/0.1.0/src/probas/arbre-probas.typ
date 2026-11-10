// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Arbres de probabilités « classiques » (homogènes, à deux niveaux), d'après
// \ArbreProbasTikz et l'environnement EnvArbreProbasTikz du paquet LaTeX
// ProfLycee (Cédric Pierquet, §53 de sa documentation).
//
// Deux commandes :
//
//   #arbre-probas(donnees, clés)        -> un canvas CeTZ autonome ;
//   arbre-probas-dessin(donnees, clés)  -> les éléments seuls, à placer dans
//                                          son propre #canvas({ ... }) pour
//                                          compléter la figure (comme
//                                          EnvArbreProbasTikz).
//
// `donnees` : tableau de (sommet, proba) ou (sommet, proba, position), lu de
// gauche à droite puis de haut en bas (chaque nœud du 1er niveau suivi de ses
// enfants), comme les <sommet>/<proba>/<position> de ProfLycee. La proba
// peut valoir `none` (rien d'affiché) ; la position vaut "dessus", "dessous"
// ou "sur" (défaut, sur la branche) ; "above" et "below" sont acceptés.
//
//   #arbre-probas((
//     ($A$, $0,5$),
//       ($B$, $0,4$),
//       ($overline(B)$, $...$),
//     ($overline(A)$, $...$),
//       ($B$, $...$),
//       ($overline(B)$, $1/3$),
//   ))
//
// Nœuds CeTZ créés (pour compléter la figure) : "R" (racine), "A11", "A12", …
// (1er niveau, de haut en bas), "A21", "A22", … (2e niveau).
//
// Clés (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
//   unite            (Unite)           unité du canvas (arbre-probas seul) . 1cm
//   espace-niveau    (EspaceNiveau)    écart horizontal entre niveaux ..... 3.25
//   espace-feuille   (EspaceFeuille)   écart vertical entre feuilles ...... 1
//   type             (Type)            "2x2", "2x3", "3x2" ou "3x3" ....... "2x2"
//   police           (Police)          fonction appliquée aux nœuds ....... x => x
//   police-probas    (PoliceProbas)    fonction appliquée aux probas ...... text.with(size: 0.9em)
//   incline-probas   (InclineProbas)   probas inclinées selon la branche .. true
//   racine           (Racine)          étiquette de la racine ............. none
//   fleche           (Fleche)          flèche au bout des branches ........ false
//   style-trait      (StyleTrait)      pointillés (dash Typst : "dashed",
//                                      "densely-dashed", "dotted"…) ....... none
//   epaisseur-trait  (EpaisseurTrait)  épaisseur des branches ............. 0.6pt
//   position-probas  (PositionProbas)  position de toutes les probas :
//                                      "auto", "dessus", "dessous", "sur"
//                                      (none : celle de chaque donnée) .... none
//   couleur-traits   (CouleurTraits)   couleur des branches ............... black
//   couleur-noeuds   (CouleurNoeuds)   couleur des nœuds .................. black
//   couleur-probas   (CouleurProbas)   couleur des probas ................. black
//
// Le type peut être n'importe quel « pxq » (p branches puis q branches) :
// ProfLycee se limite à 2 ou 3.
#import "../deps.typ": cetz
#import "../arbre.typ": _arbre-dessin

#let arbre-probas-dessin(
  donnees,
  espace-niveau: 3.25,
  espace-feuille: 1,
  type: "2x2",
  police: x => x,
  police-probas: text.with(size: 0.9em),
  incline-probas: true,
  racine: none,
  fleche: false,
  style-trait: none,
  epaisseur-trait: 0.6pt,
  position-probas: none,
  couleur-traits: black,
  couleur-noeuds: black,
  couleur-probas: black,
) = {
  let (p, q) = type.split("x").map(int)
  assert(
    donnees.len() == p + p * q,
    message: "arbre-probas : " + str(p + p * q) + " données attendues pour le type " + type,
  )
  // place dans `donnees` du nœud i du niveau k : chaque nœud du 1er niveau
  // suivi de ses q enfants
  let donnee(k, i) = {
    let d = if k == 1 { donnees.at(i * (q + 1)) } else { donnees.at(calc.quo(i, q) * (q + 1) + 1 + calc.rem(i, q)) }
    (d.at(0), d.at(1), d.at(2, default: none))
  }
  _arbre-dessin(
    (p, q),
    (k, i, chemin) => donnee(k, i).at(0),
    proba: (k, i, chemin) => donnee(k, i).slice(1),
    racine: racine,
    espace-niveau: espace-niveau,
    espace-feuille: espace-feuille,
    fleche: fleche,
    trait: (paint: couleur-traits, thickness: epaisseur-trait, dash: style-trait),
    police: police,
    police-probas: police-probas,
    couleur-noeuds: couleur-noeuds,
    couleur-probas: couleur-probas,
    incline-probas: incline-probas,
    position-probas: position-probas,
  )
}

#let arbre-probas(donnees, unite: 1cm, ..cles) = cetz.canvas(length: unite, arbre-probas-dessin(donnees, ..cles))
