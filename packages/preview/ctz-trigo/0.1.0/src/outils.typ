// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Outils communs (non exportés).

// Marques des points, avec les noms de pgfplots (comme simple-plot) ; « * »
// final = pleine. Sur le cercle, « | » est radial et « - » tangent.
#let _marques = (
  "*", "o", "square", "square*", "triangle", "triangle*", "diamond", "diamond*",
  "star", "star*", "+", "x", "|", "-",
)

// Vrai pour un nombre (entier, flottant ou décimal).
#let _est-nombre(x) = type(x) in (int, float, decimal)

// Vérifie mark et mark-size d'un élément (`quoi`) et renvoie la taille ;
// auto : 0,1 pour le disque plein, 0,15 pour les autres formes, moins
// lisibles en petit.
#let _taille-marque(mark, mark-size, quoi) = {
  if mark != none and mark not in _marques {
    panic(quoi + ": mark must be none or one of " + _marques.map(repr).join(", ") + ", not " + repr(mark))
  }
  if mark-size == auto { return if mark == "*" { 0.1 } else { 0.15 } }
  if not _est-nombre(mark-size) or mark-size <= 0 {
    panic(quoi + ": mark-size must be auto or a positive number (in cm), not " + repr(mark-size))
  }
  mark-size
}

// Angle en degrés (nombre), qu'on le donne en degrés (45) ou en angle Typst
// (45deg, calc.pi / 4 * 1rad) ; `quoi` nomme la fonction dans l'erreur.
#let _deg(a, quoi) = {
  if type(a) == angle { a.deg() }
  else if _est-nombre(a) { float(a) }
  else { panic(quoi + ": an angle must be a number of degrees (45) or an angle (45deg, 1rad), not " + repr(a)) }
}

// Réel (abscisse sur la droite réelle).
#let _reel(x, quoi) = {
  if not _est-nombre(x) { panic(quoi + ": expected a real number, not " + repr(x)) }
  float(x)
}

// Nom facultatif donné en argument positionnel : `args` est le reste
// (..nom) d'une fonction-élément. Une clé nommée qui y arrive est une clé
// inconnue de la fonction.
#let _nom(args, quoi, defaut: none) = {
  let cles = args.named().keys()
  if cles.len() > 0 { panic(quoi + ": unknown key " + repr(cles.first())) }
  let pos = args.pos()
  if pos.len() > 1 { panic(quoi + ": too many arguments (only one name is allowed)") }
  let nom = pos.at(0, default: defaut)
  if nom != none and type(nom) not in (content, str, symbol) {
    panic(quoi + ": the name must be content ($A$, [text]) or none, not " + repr(nom))
  }
  nom
}

// Ancre d'un nom placé à l'extérieur du cercle, dans la direction de l'angle
// a (en degrés), mais jamais à cheval sur un axe : au-dessus de l'axe des
// abscisses, à côté de l'axe des ordonnées.
#let _ancre-ext(a) = {
  let (c, s) = (calc.cos(a * 1deg), calc.sin(a * 1deg))
  let v = if s < -0.38 { "north" } else { "south" }
  let h = if c < -0.01 { "east" } else { "west" }
  v + "-" + h
}

// Arc de cercle de centre O en ligne brisée, de a0 à a1 (en degrés, même
// plus d'un tour), pour les arcs, secteurs et flèches.
#let _arc(a0, a1, r, n: 40) = range(n + 1).map(i => {
  let t = (a0 + (a1 - a0) * i / n) * 1deg
  (r * calc.cos(t), r * calc.sin(t))
})
