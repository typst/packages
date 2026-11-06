// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Éléments ajoutés au cercle. Ces fonctions ne dessinent rien : elles
// vérifient leurs arguments et renvoient une fiche (dictionnaire) que
// trig-circle lira. Le champ `_ctz-trigo` donne la sorte d'élément.
//
// Angles : un nombre de degrés (45) ou un angle Typst (45deg, 1rad), convertis
// ici en degrés. Le nom, facultatif, est le seul argument positionnel après
// l'angle (ou les deux angles) : tc-point(80deg, $A$).

#import "outils.typ": _deg, _reel, _nom, _taille-marque, _est-nombre

// Point du cercle, marqué et nommé à l'extérieur du cercle ; mark : forme
// de la marque (voir _marques) ou none, mark-size : sa largeur en cm (pour
// un rayon jusqu'à 1, elle grandit ensuite avec le cercle ; voir
// _taille-marque).
#let tc-point(a, ..nom, color: black, anchor: auto, mark: "*", mark-size: auto) = {
  if anchor != auto and type(anchor) != str {
    panic("tc-point: anchor must be auto or a CeTZ anchor such as \"south-west\", not " + repr(anchor))
  }
  (
    _ctz-trigo: "point", angle: _deg(a, "tc-point"), name: _nom(nom, "tc-point"),
    color: color, anchor: anchor, mark: mark, mark-size: _taille-marque(mark, mark-size, "tc-point"),
  )
}

// Vecteur de direction donnée, d'origine quelconque : from est un point
// (x, y), en rayons, ou un angle (le point du cercle) ; length en rayons
// (1 : vecteur unitaire). Le nom est placé au milieu, du côté direct.
#let tc-vector(a, ..nom, from: (0, 0), length: 1, color: black, thickness: auto) = {
  let origine = if type(from) == array {
    if from.len() != 2 { panic("tc-vector: from must be a point (x, y), in radii, or an angle, not " + repr(from)) }
    from.map(c => _reel(c, "tc-vector"))
  } else if type(from) == angle or _est-nombre(from) {
    let b = _deg(from, "tc-vector") * 1deg
    (calc.cos(b), calc.sin(b))
  } else {
    panic("tc-vector: from must be a point (x, y), in radii, or an angle, not " + repr(from))
  }
  (
    _ctz-trigo: "vector", angle: _deg(a, "tc-vector"), name: _nom(nom, "tc-vector"),
    origin: origine, length: _reel(length, "tc-vector"), color: color, thickness: thickness,
  )
}

// Rayon de O au point du cercle (vecteur si arrow: true) ; label : texte au
// milieu ; copy : origine (x, y), en rayons, d'un représentant du même
// vecteur, nommé copy-name.
#let tc-ray(a, ..nom, color: black, thickness: auto, arrow: false, label: none, copy: none, copy-name: none) = {
  if copy != none and not (type(copy) == array and copy.len() == 2) {
    panic("tc-ray: copy must be none or a point (x, y), in radii, not " + repr(copy))
  }
  (
    _ctz-trigo: "ray", angle: _deg(a, "tc-ray"), name: _nom(nom, "tc-ray"),
    color: color, thickness: thickness, arrow: arrow, label: label,
    copy: if copy == none { none } else { copy.map(c => _reel(c, "tc-ray")) }, copy-name: copy-name,
  )
}

// Arc du cercle, de l'angle `de` à l'angle `a` (sens direct si a > de).
#let tc-arc(de, a, ..nom, color: red, thickness: 2pt, arrow: false) = (
  _ctz-trigo: "arc", from: _deg(de, "tc-arc"), to: _deg(a, "tc-arc"),
  name: _nom(nom, "tc-arc"), color: color, thickness: thickness, arrow: arrow,
)

// Angle au centre, marqué par un petit arc fléché ; radius en rayons du
// cercle, fill : couleur du secteur.
#let tc-angle(de, a, ..nom, color: purple, radius: 0.4, fill: none) = {
  (
    _ctz-trigo: "angle", from: _deg(de, "tc-angle"), to: _deg(a, "tc-angle"),
    name: _nom(nom, "tc-angle"), color: color, radius: _reel(radius, "tc-angle"), fill: fill,
  )
}

// Réel x enroulé sur le cercle : segment de I(1 ; 0) à M(1 ; x) sur la
// droite réelle, arc de I au point image (sur un tour), spirale de M vers
// ce point. x est un réel (une longueur), pas un angle. mark et mark-size
// (comme tc-point) marquent les deux points : M sur la droite réelle, son
// image sur le cercle.
#let tc-wind(x, ..nom, color: rgb("#228B22"), segment: true, arc: true, mark: "*", mark-size: auto) = (
  _ctz-trigo: "wind", x: _reel(x, "tc-wind"), name: _nom(nom, "tc-wind"),
  color: color, segment: segment, arc: arc,
  mark: mark, mark-size: _taille-marque(mark, mark-size, "tc-wind"),
)

// Segment [de ; a] de la droite réelle (de et a réels).
#let tc-interval(de, a, color: red, thickness: 2pt) = (
  _ctz-trigo: "interval", from: _reel(de, "tc-interval"), to: _reel(a, "tc-interval"),
  color: color, thickness: thickness,
)

// Solutions de cos x = cos α (segment vertical) et sin x = sin α (segment
// horizontal) ; lines : rayons en tirets vers les deux solutions.
#let tc-cos-eq(a, color: blue, lines: true) = (
  _ctz-trigo: "cos-eq", angle: _deg(a, "tc-cos-eq"), color: color, lines: lines,
)
#let tc-sin-eq(a, color: blue, lines: true) = (
  _ctz-trigo: "sin-eq", angle: _deg(a, "tc-sin-eq"), color: color, lines: lines,
)

// Point M(cos θ ; sin θ) avec ses projections sur les axes, l'angle θ et
// les noms cos(θ), sin(θ).
#let tc-cos-sin(a, ..nom, angle-name: $theta$) = (
  _ctz-trigo: "cos-sin", angle: _deg(a, "tc-cos-sin"),
  name: _nom(nom, "tc-cos-sin", defaut: $M$), angle-name: angle-name,
)
