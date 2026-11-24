// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Petits schémas pour des probabilités continues, d'après \LoiNormaleGraphe
// et \LoiExpoGraphe du paquet LaTeX ProfLycee (Cédric Pierquet, §54 de sa
// documentation) : la courbe de la densité, l'aire de P(a <= X <= b) grisée.
//
// Commandes :
//
//   #loi-normale-graphe(m, s, a, b, clés)   -> schéma pour N(m ; s), s écart type ;
//   #loi-expo-graphe(l, a, b, clés)         -> schéma pour E(l) ;
//   loi-normale-graphe-dessin(m, s, a, b, clés),
//   loi-expo-graphe-dessin(l, a, b, clés)   -> les éléments seuls, à placer
//                                              dans son propre #canvas({ ... })
//                                              (pas dans ProfLycee).
//
// Borne `none` (ou "*", comme dans ProfLycee) : pas de borne de ce côté.
//
// Clés (entre parenthèses : équivalent ProfLycee, puis défaut) :
//
//   couleur-aire     (CouleurAire)    couleur de l'aire sous la courbe .. rgb("#d3d3d3")
//   couleur-courbe   (CouleurCourbe)  couleur de la courbe .............. red
//   largeur          (Largeur)        largeur du schéma, en cm .......... 2
//   hauteur          (Hauteur)        hauteur du schéma, en cm .......... 1
//   affiche-m        (AfficheM)       moyenne en pointillés, avec sa
//                                     valeur sous l'axe ................. true
//   affiche-cadre    (AfficheCadre)   cadre autour du schéma ............ true
//   baseline         (<baseline=…> TikZ, versions autonomes seulement)
//                                     ligne de base du schéma : une
//                                     longueur depuis le bas, 50 % pour le
//                                     centrer, "axe" pour poser l'axe des
//                                     abscisses sur la ligne de texte ... 0pt
//
// Exemples :
//   #loi-normale-graphe(1000, 100, 950, none, affiche-m: false, couleur-courbe: blue, couleur-aire: aqua, baseline: "axe")
//   #loi-expo-graphe(0.00025, 5000, none, largeur: 4, hauteur: 2)
#import "../deps.typ": cetz
#import "../outils.typ": _grouper

// Hauteur de l'axe des abscisses au-dessus du bas du schéma (cm) : place
// pour la valeur de la moyenne.
#let _axe = 0.2

// Nombre en écriture française (12,5 ; 13 500).
#let _nombre(x) = {
  let (entier, ..decimales) = str(calc.abs(x)).split(".")
  let s = _grouper(entier) + decimales.map(d => "," + d).join(default: "")
  if x < 0 { $-#s$ } else { $#s$ }
}

// Fabrique d'un schéma : à partir de la densité (à une constante près), de
// l'intervalle représenté et de la moyenne, la commande `(a, b, clés)`.
#let _graphe(densite, x-min, x-max, moyenne, axe-vertical: false) = (
  a,
  b,
  couleur-aire: rgb("#d3d3d3"),
  couleur-courbe: red,
  largeur: 2,
  hauteur: 1,
  affiche-m: true,
  affiche-cadre: true,
) => {
  import cetz.draw: *

  let (L, H) = (largeur, hauteur)
  // abscisses du canvas : marge à gauche pour l'axe vertical éventuel
  let gauche = if axe-vertical { 0.08 * L } else { 0.05 * L }
  let X(x) = gauche + (x - x-min) / (x-max - x-min) * (0.95 * L - gauche)
  let f-max = calc.max(densite(moyenne), densite(x-min))
  let Y(x) = _axe + densite(x) / f-max * (H - _axe - 0.12)
  let courbe(u, v) = range(61).map(i => u + (v - u) * i / 60).map(x => (X(x), Y(x)))

  let a = if a in (none, "*") { x-min } else { calc.max(a, x-min) }
  let b = if b in (none, "*") { x-max } else { calc.min(b, x-max) }
  let mince = 0.4pt

  // le cadre fixe toujours la taille du schéma, même invisible
  rect((0, 0), (L, H), stroke: if affiche-cadre { mince } else { none })
  if a < b {
    line((X(a), _axe), ..courbe(a, b), (X(b), _axe), close: true, fill: couleur-aire, stroke: none)
    if a > x-min { line((X(a), _axe), (X(a), Y(a)), stroke: mince) }
    if b < x-max { line((X(b), _axe), (X(b), Y(b)), stroke: mince) }
  }
  if affiche-m {
    line((X(moyenne), _axe), (X(moyenne), Y(moyenne)), stroke: (thickness: mince, dash: "dotted"))
    content((X(moyenne), _axe), text(size: 0.45em, _nombre(moyenne)), anchor: "north", padding: 0.03)
  }
  line(..courbe(x-min, x-max), stroke: couleur-courbe + 0.7pt)
  let fleche = (end: "stealth", fill: black, scale: 0.5)
  line((0.02 * L, _axe), (0.98 * L, _axe), stroke: mince, mark: fleche)
  if axe-vertical { line((X(x-min), _axe - 0.05), (X(x-min), H - 0.05), stroke: mince, mark: fleche) }
}

#let loi-normale-graphe-dessin(m, s, a, b, ..cles) = _graphe(
  x => calc.exp(-calc.pow((x - m) / s, 2) / 2),
  m - 4 * s,
  m + 4 * s,
  m,
)(a, b, ..cles)

#let loi-expo-graphe-dessin(l, a, b, ..cles) = _graphe(
  x => calc.exp(-l * x),
  0,
  4 / l,
  1 / l,
  axe-vertical: true,
)(a, b, ..cles)

// Fabrique de la version autonome (canvas dans une boîte, avec sa ligne de base).
#let _autonome(dessin) = (..args, baseline: 0pt) => box(
  baseline: if baseline == "axe" { _axe * 1cm } else { baseline },
  cetz.canvas(length: 1cm, dessin(..args)),
)

#let loi-normale-graphe = _autonome(loi-normale-graphe-dessin)
#let loi-expo-graphe = _autonome(loi-expo-graphe-dessin)
