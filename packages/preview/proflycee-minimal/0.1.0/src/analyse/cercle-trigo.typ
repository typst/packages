// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Cercle trigonométrique, d'après \CercleTrigo du paquet LaTeX ProfLycee
// (Cédric Pierquet, §26 de sa documentation).
//
// Deux commandes :
//
//   #cercle-trigo(clés)            -> un canvas CeTZ autonome ;
//   cercle-trigo-dessin(clés)      -> les éléments seuls, à placer dans son
//                                     propre #canvas({ ... }) pour compléter
//                                     la figure (comme le \CercleTrigo dans
//                                     un tikzpicture).
#import "../deps.typ": cetz

// Angles remarquables (en degrés) avec leur étiquette dans ]-π ; π] ...
#let _angles-moins-pi = (
  (30, $pi/6$),
  (45, $pi/4$),
  (60, $pi/3$),
  (90, $pi/2$),
  (120, $(2pi)/3$),
  (135, $(3pi)/4$),
  (150, $(5pi)/6$),
  (-30, $-pi/6$),
  (-45, $-pi/4$),
  (-60, $-pi/3$),
  (-90, $-pi/2$),
  (-120, $-(2pi)/3$),
  (-135, $-(3pi)/4$),
  (-150, $-(5pi)/6$),
)

// ... et dans [0 ; 2π[
#let _angles-zero-deux-pi = (
  (30, $pi/6$),
  (45, $pi/4$),
  (60, $pi/3$),
  (90, $pi/2$),
  (120, $(2pi)/3$),
  (135, $(3pi)/4$),
  (150, $(5pi)/6$),
  (210, $(7pi)/6$),
  (225, $(5pi)/4$),
  (240, $(4pi)/3$),
  (270, $(3pi)/2$),
  (300, $(5pi)/3$),
  (315, $(7pi)/4$),
  (330, $(11pi)/6$),
)

#let cercle-trigo-dessin(
  rayon: 3,
  epaisseur: 1pt,
  marge: 0.25,
  taille-valeurs: 7pt,
  taille-angles: 8pt,
  couleur-fond: white,
  decal: 10pt,
  moins-pi: true,
  aff-angles: true,
  aff-traits: true,
  valeurs-tan: false,
  aff-valeurs: true,
  equation-cos: false,
  equation-sin: false,
  cos: 45,
  sin: 30,
  aff-traits-eq: true,
  couleur-sol: blue,
  point: none,
  nom-point: $M$,
  nom-angle: $theta$,
) = {
  import cetz.draw: *

  let R = rayon
  let d = decal / 1cm // décalage converti en unités du canvas (cm)
  let pt(a) = (R * calc.cos(a * 1deg), R * calc.sin(a * 1deg))
  let pointilles = (paint: gray.darken(20%), dash: "dotted", thickness: 0.6pt)
  let etiquette(taille, corps) = box(
    fill: couleur-fond,
    inset: 1.2pt,
    text(size: taille, corps),
  )
  let val(corps) = etiquette(taille-valeurs, corps)
  let ang(corps) = etiquette(taille-angles, corps)

  // Valeurs remarquables (cos = sin pour les angles de 30°, 45°, 60°)
  let remarquables = (
    (30, $sqrt(3)/2$, $1/2$),
    (45, $sqrt(2)/2$, $sqrt(2)/2$),
    (60, $1/2$, $sqrt(3)/2$),
  )

  // --- Traits de construction ---------------------------------------
  if aff-traits {
    for (a, _, _) in remarquables {
      let (c, s) = (R * calc.cos(a * 1deg), R * calc.sin(a * 1deg))
      // rectangles reliant les points symétriques
      line((-c, s), (c, s), stroke: pointilles)
      line((-c, -s), (c, -s), stroke: pointilles)
      line((c, -s), (c, s), stroke: pointilles)
      line((-c, -s), (-c, s), stroke: pointilles)
      // rayons
      for b in (a, 180 - a, 180 + a, -a) {
        line((0, 0), pt(b), stroke: pointilles)
      }
    }
  }

  // --- Tangente ------------------------------------------------------
  let h-tan = if valeurs-tan { calc.sqrt(3) * R } else { 0 }
  if valeurs-tan {
    line((R, -h-tan - marge), (R, h-tan + marge), stroke: black + epaisseur)
    for (a, t) in ((30, $sqrt(3)/3$), (45, $1$), (60, $sqrt(3)$)) {
      let y = R * calc.tan(a * 1deg)
      for (signe, lab) in ((1, t), (-1, $-#t$)) {
        line((0, 0), (R, signe * y), stroke: pointilles)
        circle((R, signe * y), radius: 0.03, fill: black, stroke: none)
        content((R, signe * y), val(lab), anchor: "west", padding: 0.08)
      }
    }
  }

  // --- Axes et cercle ------------------------------------------------
  let ymax = calc.max(R, h-tan) + marge
  line(
    (-R - marge, 0),
    (R + marge + 0.15, 0),
    stroke: black + epaisseur,
    mark: (end: "stealth", fill: black),
  )
  line(
    (0, -ymax),
    (0, ymax + 0.15),
    stroke: black + epaisseur,
    mark: (end: "stealth", fill: black),
  )
  circle((0, 0), radius: R, stroke: black + epaisseur)

  // --- Valeurs remarquables -----------------------------------------
  if aff-valeurs {
    content((0, 0), val($0$), anchor: "north-east", padding: 0.04)
    for (a, vc, vs) in remarquables {
      let (c, s) = (R * calc.cos(a * 1deg), R * calc.sin(a * 1deg))
      // √2/2 de l'autre côté de l'axe, pour éviter les chevauchements
      let (ax, ay) = if a == 45 { ("south", "west") } else { ("north", "east") }
      content((c, 0), val(vc), anchor: ax, padding: 0.06)
      content((-c, 0), val($-#vc$), anchor: ax, padding: 0.06)
      content((0, s), val(vs), anchor: ay, padding: 0.06)
      content((0, -s), val($-#vs$), anchor: ay, padding: 0.06)
    }
  }

  // --- Angles ---------------------------------------------------------
  if aff-angles {
    let liste = if moins-pi { _angles-moins-pi } else { _angles-zero-deux-pi }
    for (a, lab) in liste {
      let p = (
        (R + d) * calc.cos(a * 1deg),
        (R + d) * calc.sin(a * 1deg),
      )
      // les angles sur l'axe vertical sont décalés à droite de l'axe
      if calc.rem(a, 180) == 90 or calc.rem(a, 180) == -90 {
        let y = if calc.sin(a * 1deg) > 0 { R + d } else { -R - d }
        content((0.15, y), ang(lab), anchor: "west")
      } else {
        content(p, ang(lab))
      }
      if aff-traits { circle(pt(a), radius: 0.03, fill: black, stroke: none) }
    }
    // angles sur l'axe horizontal : deux étiquettes, de part et d'autre de l'axe
    let (droite-haut, droite-bas, gauche-haut, gauche-bas) = if moins-pi {
      ($0$, none, $pi$, $-pi$)
    } else { ($0$, $2pi$, $pi$, none) }
    let xd = R + d
    content((xd, 0.05), ang(droite-haut), anchor: "south-west")
    if droite-bas != none { content((xd, -0.05), ang(droite-bas), anchor: "north-west") }
    content((-xd, 0.05), ang(gauche-haut), anchor: "south-east")
    if gauche-bas != none { content((-xd, -0.05), ang(gauche-bas), anchor: "north-east") }
  }

  // --- Équation cos(x) = cos(α) ------------------------------------
  if equation-cos {
    let (c, s) = (R * calc.cos(cos * 1deg), R * calc.abs(calc.sin(cos * 1deg)))
    if aff-traits-eq {
      line((0, 0), (c, s), stroke: (paint: couleur-sol, dash: "dashed", thickness: 0.6pt))
      line((0, 0), (c, -s), stroke: (paint: couleur-sol, dash: "dashed", thickness: 0.6pt))
    }
    line((c, -s), (c, s), stroke: couleur-sol + 1.6pt)
    circle((c, s), radius: 0.06, fill: couleur-sol, stroke: none)
    circle((c, -s), radius: 0.06, fill: couleur-sol, stroke: none)
  }

  // --- Équation sin(x) = sin(α) ------------------------------------
  if equation-sin {
    let (c, s) = (R * calc.abs(calc.cos(sin * 1deg)), R * calc.sin(sin * 1deg))
    if aff-traits-eq {
      line((0, 0), (c, s), stroke: (paint: couleur-sol, dash: "dashed", thickness: 0.6pt))
      line((0, 0), (-c, s), stroke: (paint: couleur-sol, dash: "dashed", thickness: 0.6pt))
    }
    line((-c, s), (c, s), stroke: couleur-sol + 1.6pt)
    circle((c, s), radius: 0.06, fill: couleur-sol, stroke: none)
    circle((-c, s), radius: 0.06, fill: couleur-sol, stroke: none)
  }

  // --- Point M(cos θ ; sin θ) ----------------------------------------
  if point != none {
    // NB : les clés cos et sin masquent les opérateurs, d'où math.cos / math.sin
    let (c, s) = pt(point)
    let bleu = rgb("#0074D9")
    let rouge = rgb("#C2150C")
    let r-arc = calc.min(0.5, R / 5)
    // angle nul : pas d'arc à marquer (CeTZ refuse un arc de 0°)
    if point != 0 {
      arc(
        (r-arc, 0),
        start: 0deg,
        stop: point * 1deg,
        radius: r-arc,
        stroke: purple + 1pt,
        mark: (end: "stealth", fill: purple),
      )
      content(
        ((r-arc + 0.18) * calc.cos(point / 2 * 1deg), (r-arc + 0.18) * calc.sin(point / 2 * 1deg)),
        text(fill: purple, size: taille-angles, nom-angle),
      )
    }
    line((0, 0), (c, s), stroke: black + epaisseur)
    line((c, s), (c, 0), stroke: (paint: bleu, dash: "dashed", thickness: 0.8pt))
    line((c, s), (0, s), stroke: (paint: rouge, dash: "dashed", thickness: 0.8pt))
    line((0, 0), (c, 0), stroke: bleu + 2.5pt)
    line((0, 0), (0, s), stroke: rouge + 2.5pt)
    let (anc, ans) = (
      if s >= 0 { "north" } else { "south" },
      if c >= 0 { "east" } else { "west" },
    )
    content((c, 0), text(fill: bleu, size: taille-valeurs + 1pt, $#math.cos (#nom-angle)$), anchor: anc, padding: 0.08)
    content((0, s), text(fill: rouge, size: taille-valeurs + 1pt, $#math.sin (#nom-angle)$), anchor: ans, padding: 0.08)
    circle((c, s), radius: 0.05, fill: black, stroke: none)
    content(
      (c, s),
      nom-point,
      anchor: (if s >= 0 { "south" } else { "north" }) + "-" + (if c >= 0 { "west" } else { "east" }),
      padding: 0.08,
    )
  }
}

#let cercle-trigo(..cles) = cetz.canvas(length: 1cm, cercle-trigo-dessin(..cles))
