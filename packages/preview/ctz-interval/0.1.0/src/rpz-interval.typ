// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.
 
// le paquet étant petit, tous les outils et dépendances servent là
#import "deps.typ": cetz
#import "outils.typ": _nombre, _infini, _est-nombre 

#let _types = ("CC", "CO", "OC", "OO")

// cette fonction permet de donner toutes les informations sur 
// l'intervalle à représenter. La fonction suivante lira ces 
// données pour représenter l'intervalle. 
// Cette partie sert aussi à faire afficher des messages 
// d'erreurs clairs

#let ctz-interval(
  inf,
  sup,
  color: red,
  type: "CC",
  level: 0,
  decor: none,
  show-values: false,
  pos-values: "above",
  label-inf: auto,
  label-sup: auto,
) = {
  if type not in _types {
    panic("ctz-interval: type must be \"CC\", \"CO\", \"OC\" or \"OO\", not " + repr(type))
  }
  for (nom, b) in (("inf", inf), ("sup", sup)) {
    if not (_infini(b) or _est-nombre(b)) {
      panic("ctz-interval: the " + nom + " bound must be a number, \"*\" or none, not " + repr(b))
    }
  }
  if not _infini(inf) and not _infini(sup) and inf >= sup {
    panic("ctz-interval: the inf bound (" + repr(inf) + ") must be less than the sup bound (" + repr(sup) + ")")
  }
  let angle = 45deg
  if decor != none {
    let morceaux = str(decor).split("/")
    if morceaux.at(0) not in ("fill", "zigzag", "hatch") or (morceaux.len() > 1 and morceaux.at(0) != "hatch") or morceaux.len() > 2 {
      panic("ctz-interval: decor must be none, \"fill\", \"zigzag\", \"hatch\" or \"hatch/<angle>\", not " + repr(decor))
    }
    if morceaux.len() == 2 {
      let a = float(morceaux.at(1))
      if calc.rem(a, 180) == 0 { panic("ctz-interval: hatching cannot be horizontal (angle " + morceaux.at(1) + ")") }
      angle = a * 1deg
    }
  }
  if pos-values not in ("above", "below") {
    panic("ctz-interval: pos-values must be \"above\" or \"below\", not " + repr(pos-values))
  }
  (
    objet: "intervalle",
    inf: if _infini(inf) { none } else { inf },
    sup: if _infini(sup) { none } else { sup },
    color: color, type: type, level: level,
    decor: if decor == none { none } else { str(decor).split("/").at(0) },
    angle: angle, show-values: show-values,
    pos-values: pos-values, label-inf: label-inf, label-sup: label-sup,
  )
}

// Segment de la droite p0–p1 compris dans la bande a ≤ x ≤ b (ou none).
#let _dans-bande(p0, p1, a, b) = {
  let dx = p1.at(0) - p0.at(0)
  if dx == 0 { return if a <= p0.at(0) and p0.at(0) <= b { (p0, p1) } else { none } }
  let s0 = calc.max(0, calc.min((a - p0.at(0)) / dx, (b - p0.at(0)) / dx))
  let s1 = calc.min(1, calc.max((a - p0.at(0)) / dx, (b - p0.at(0)) / dx))
  if s0 >= s1 { return none }
  let point(s) = (p0.at(0) + s * dx, p0.at(1) + s * (p1.at(1) - p0.at(1)))
  (point(s0), point(s1))
}

#let rpz-interval-draw(
  xmin: -8,
  xmax: 8,
  width: 12,
  unit: auto,
  thickness: 1pt,
  ticks: (),
  major-ticks: (),
  tick-height: 7pt,
  height: 12pt,
  values: (),
  text-style: (:),
  ..objets,
) = {
  if xmin >= xmax { panic("rpz-interval: xmin (" + repr(xmin) + ") must be less than xmax (" + repr(xmax) + ")") }
  if objets.named().len() > 0 { panic("rpz-interval: unknown key " + repr(objets.named().keys().first())) }
  for o in objets.pos() {
    if type(o) != dictionary or o.at("objet", default: none) != "intervalle" {
      panic("rpz-interval: only ctz-interval(…) can be drawn, not " + repr(o))
    }
  }
  let u = if unit == auto { width / (xmax - xmin) } else { unit / 1cm }
  let X(x) = x * u
  // l'axe dépasse de 5 % de chaque côté, pour la flèche et les bornes infinies
  let marge = 0.05 * (X(xmax) - X(xmin))
  let (gauche, droite) = (X(xmin) - marge, X(xmax) + marge)
  let h = height / 1cm
  let hg = tick-height / 1cm
  let ep = thickness
  let etiquette(c, couleur: black) = text(..text-style, fill: couleur, c)

  import cetz.draw: *

  // Axe, graduations, valeurs
  line((gauche, 0), (droite, 0), stroke: ep, mark: (end: "stealth", fill: black, scale: 0.8))
  for x in ticks { line((X(x), -hg / 2), (X(x), hg / 2), stroke: ep) }
  for x in major-ticks { line((X(x), -hg * 0.8), (X(x), hg * 0.8), stroke: ep) }
  // sous les graduations et sous les crochets, pour ne pas les chevaucher
  let y-valeurs = -calc.max(hg * 0.8, h / 2)
  for x in values {
    content((X(x), y-valeurs), anchor: "north", padding: 2pt, etiquette(_nombre(x)))
  }

  let intervalles = objets.pos()
  // Deux passes : les décorations d'abord, pour qu'aucune ne masque un trait.
  for passe in ("decor", "trait") {
    for it in intervalles {
      let c = it.color
      let y = it.level * h
      let a = if it.inf == none { gauche } else { X(it.inf) }
      let b = if it.sup == none { droite - 0.2 } else { X(it.sup) }
      let (bas, haut) = (y - h / 2, y + h / 2)

      if passe == "decor" {
        if it.decor == "fill" {
          rect((a, bas), (b, haut), fill: c.transparentize(70%), stroke: none)
        } else if it.decor == "zigzag" {
          let n = calc.max(2, int(calc.round((b - a) / (h * 0.6))))
          let pas = (b - a) / n
          line(..range(n + 1).map(k => (a + k * pas, if calc.odd(k) { haut } else { y })), stroke: c + ep)
        } else if it.decor == "hatch" {
          // hachures inclinées de `angle`, écartées de 0,4 hauteur, coupées à [a ; b]
          let dx = h / calc.tan(it.angle)       // décalage horizontal d'un bord à l'autre
          let pas = h * 0.4 / calc.abs(calc.sin(it.angle))
          let debut = calc.min(a, a - dx)
          let n = int(calc.ceil((b - debut + calc.abs(dx)) / pas))
          for k in range(n + 1) {
            let x0 = debut + k * pas
            let morceau = _dans-bande((x0, bas), (x0 + dx, haut), a, b)
            if morceau != none { line(..morceau, stroke: c + 0.5 * ep) }
          }
        }
      } else {
        line((a, y), (b, y), stroke: c + 2 * ep)
        // Un crochet fermé « regarde » l'intérieur de l'intervalle, un ouvert l'extérieur.
        let w = h * 0.3
        let crochet(x, sens) = line(
          (x + sens * w, y + h / 2), (x, y + h / 2), (x, y - h / 2), (x + sens * w, y - h / 2),
          stroke: c + 2 * ep,
        )
        if it.inf != none { crochet(a, if it.type.at(0) == "C" { 1 } else { -1 }) }
        if it.sup != none { crochet(b, if it.type.at(1) == "C" { -1 } else { 1 }) }

        if it.show-values {
          let (ordonnee, ancre) = if it.pos-values == "above" { (y + h / 2, "south") } else { (y - h / 2, "north") }
          for (borne, x, label) in ((it.inf, a, it.label-inf), (it.sup, b, it.label-sup)) {
            if borne == none { continue }
            let e = if label != auto { label } else { _nombre(borne) }
            content((x, ordonnee), anchor: ancre, padding: 2pt, etiquette(e, couleur: c))
          }
        }
      }
    }
  }
}

#let rpz-interval(..args) = (
  cetz.canvas(
    length: 1cm, 
    rpz-interval-draw(..args)
  )
)
 