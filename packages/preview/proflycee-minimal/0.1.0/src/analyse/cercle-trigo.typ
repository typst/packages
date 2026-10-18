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
//
// Clés de ProfLycee : rayon, epaisseur, marge, taille-valeurs, taille-angles,
// couleur-fond, decal, moins-pi, aff-angles, aff-traits, valeurs-tan,
// aff-valeurs, equation-cos, equation-sin, cos, sin, aff-traits-eq,
// couleur-sol, point, nom-point, nom-angle.
//
// Clés absentes de ProfLycee (par défaut : rendu de \CercleTrigo inchangé).
//
// Angles : partout un nombre de degrés (45) ou un angle Typst (45deg,
// calc.pi / 4 * 1rad). Seule exception, l'abscisse x d'un enroulement, qui
// est un réel (une longueur sur la droite réelle).
//
//   Ce qui est affiché (booléens)
//   aff-remarquables: true  false : ni valeurs, ni angles, ni traits de
//                           ProfLycee (le cercle et les axes seuls)
//   aff-points: auto        points des angles remarquables (auto : avec les
//                           angles et les traits ; true : même sans les
//                           angles, pour un gabarit vierge)
//   aff-axes: true          axes (false : cercle seul)
//   aff-origine: false      nom O de l'origine
//   aff-graduations: false  graduations ±1 sur les axes
//   aff-vecteurs: false     vecteurs i et j (les axes perdent leur flèche)
//   aff-sens: false         flèche rouge « + » du sens direct
//   aff-axe-reel: false     droite réelle tangente en I(1 ; 0)
//
//   Apparence
//   couleur-cercle: black   couleur du cercle
//   taille-noms: 9pt        taille des noms des éléments ajoutés ci-dessous
//
//   Éléments ajoutés : listes de dictionnaires, champs communs angle / de /
//   a (angles), nom, couleur, epaisseur, fleche. Les noms sont placés à
//   l'extérieur du cercle, jamais à cheval sur un axe. Un champ inconnu est
//   une erreur.
//   points: ()              (angle, nom, couleur: black, ancre: auto)
//   rayons: ()              segment ou vecteur de O au cercle :
//                           (angle, nom: none, couleur: black,
//                           epaisseur: 1pt, fleche: false, etiquette: none,
//                           copie: none, nom-copie: none) ; etiquette : au
//                           milieu (une longueur…) ; copie : origine (x, y),
//                           en rayons, d'un représentant du même vecteur
//   arcs: ()                arc du cercle : (de, a, nom: none, couleur: red,
//                           epaisseur: 2pt, fleche: false)
//   angles: ()              angle au centre : (de, a, nom: none,
//                           couleur: purple, rayon: 0.4, fond: none) ;
//                           rayon en rayons du cercle, fond : couleur du
//                           secteur
//   enroulements: ()        réel x enroulé sur le cercle : (x, nom: none,
//                           couleur: rgb("#228B22"), segment: true,
//                           arc: true) : segment de I à M(1 ; x), arc de I
//                           à N (sur un tour), spirale de M vers N
//   intervalles: ()         segment de la droite réelle : (de, a,
//                           couleur: red, epaisseur: 2pt) ; de et a réels
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

// Angle en degrés (nombre), qu'on le donne en degrés ou en angle Typst.
#let _deg(a) = if type(a) == angle { a.deg() } else { a }

// Complète les dictionnaires d'une liste d'éléments par les valeurs par
// défaut ; un champ inconnu ou obligatoire manquant est une erreur.
#let _elements(liste, quoi, defauts, obligatoires) = liste.map(e => {
  assert(type(e) == dictionary, message: "cercle-trigo : " + quoi + " attend des dictionnaires, par exemple (" + obligatoires.map(c => c + ": …").join(", ") + ")")
  let permis = obligatoires + defauts.keys()
  for c in e.keys() {
    assert(c in permis, message: "cercle-trigo : champ « " + c + " » inconnu dans " + quoi + " (champs : " + permis.join(", ") + ")")
  }
  for c in obligatoires {
    assert(c in e, message: "cercle-trigo : champ « " + c + " » manquant dans " + quoi)
  }
  defauts + e
})

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
  aff-remarquables: true,
  aff-points: auto,
  aff-axes: true,
  aff-origine: false,
  aff-graduations: false,
  aff-vecteurs: false,
  aff-sens: false,
  aff-axe-reel: false,
  couleur-cercle: black,
  taille-noms: 9pt,
  points: (),
  rayons: (),
  arcs: (),
  angles: (),
  enroulements: (),
  intervalles: (),
) = {
  import cetz.draw: *

  // un seul interrupteur pour les valeurs, angles et traits de ProfLycee
  let (aff-valeurs, aff-angles, aff-traits) = if aff-remarquables {
    (aff-valeurs, aff-angles, aff-traits)
  } else { (false, false, false) }
  // angles en degrés, donnés en nombre ou en angle Typst
  let (point, cos, sin) = (if point == none { none } else { _deg(point) }, _deg(cos), _deg(sin))
  let points = _elements(points, "points", (couleur: black, ancre: auto), ("angle", "nom"))
  let rayons = _elements(rayons, "rayons", (nom: none, couleur: black, epaisseur: epaisseur, fleche: false, etiquette: none, copie: none, nom-copie: none), ("angle",))
  let arcs = _elements(arcs, "arcs", (nom: none, couleur: red, epaisseur: 2pt, fleche: false), ("de", "a"))
  let intervalles = _elements(intervalles, "intervalles", (couleur: red, epaisseur: 2pt), ("de", "a"))
  let angles = _elements(angles, "angles", (nom: none, couleur: purple, rayon: 0.4, fond: none), ("de", "a"))
  let enroulements = _elements(enroulements, "enroulements", (nom: none, couleur: rgb("#228B22"), segment: true, arc: true), ("x",))

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
  // nom d'un élément ajouté, et point marqué (même taille partout)
  let nom(corps, couleur) = text(size: taille-noms, fill: couleur, corps)
  let marque(p, couleur: black) = circle(p, radius: 0.05, fill: couleur, stroke: none)

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
  // avec les vecteurs i et j, les axes n'ont pas de flèche (une seule
  // orientation affichée)
  let (fleche, bout) = if aff-vecteurs { (none, 0) } else { ((end: "stealth", fill: black), 0.15) }
  if aff-axes {
    line(
      (-R - marge, 0),
      (R + marge + bout, 0),
      stroke: black + epaisseur,
      mark: fleche,
    )
    line(
      (0, -ymax),
      (0, ymax + bout),
      stroke: black + epaisseur,
      mark: fleche,
    )
  }
  circle((0, 0), radius: R, stroke: couleur-cercle + epaisseur)

  // --- Repère : O, graduations ±1, vecteurs i et j (hors ProfLycee) ----
  if aff-origine and not aff-valeurs {
    content((0, 0), val($O$), anchor: "north-east", padding: 0.04)
  }
  if aff-graduations {
    let g = 0.06
    for s in (1, -1) {
      line((s * R, -g), (s * R, g), stroke: black + epaisseur)
      line((-g, s * R), (g, s * R), stroke: black + epaisseur)
    }
    // sous l'axe des abscisses, à gauche de l'axe des ordonnées : les noms
    // des points (à l'extérieur du cercle, dans leur direction) restent libres
    content((R, 0), val($1$), anchor: "north", padding: 0.06)
    content((-R, 0), val($-1$), anchor: "north", padding: 0.06)
    content((0, R), val($1$), anchor: "east", padding: 0.06)
    content((0, -R), val($-1$), anchor: "east", padding: 0.06)
  }
  if aff-vecteurs {
    let fleche = (end: "stealth", fill: black)
    line((0, 0), (R, 0), stroke: black + 1.5 * epaisseur, mark: fleche)
    line((0, 0), (0, R), stroke: black + 1.5 * epaisseur, mark: fleche)
    content((R / 2, 0), val($arrow(i)$), anchor: "north", padding: 0.06)
    content((0, R / 2), val($arrow(j)$), anchor: "east", padding: 0.06)
  }

  // --- Sens direct (hors ProfLycee) ------------------------------------
  if aff-sens {
    let rs = 1.3 * R
    arc(
      (rs * calc.cos(20deg), rs * calc.sin(20deg)),
      start: 20deg,
      stop: 70deg,
      radius: rs,
      stroke: red + epaisseur,
      mark: (end: "stealth", fill: red),
    )
    content((rs * calc.cos(45deg), rs * calc.sin(45deg)), text(fill: red, size: taille-angles, $+$), anchor: "south-west", padding: 0.06)
  }

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
  let aff-pts = if aff-points == auto { aff-angles and aff-traits } else { aff-points }
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
      if aff-pts { circle(pt(a), radius: 0.03, fill: black, stroke: none) }
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
  } else if aff-pts {
    for (a, _) in _angles-moins-pi { circle(pt(a), radius: 0.03, fill: black, stroke: none) }
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

  // --- Angles au centre, arcs, rayons (hors ProfLycee) ----------------
  for e in angles {
    let (de, a) = (_deg(e.de), _deg(e.a))
    let r = e.rayon * R
    if e.fond != none {
      line((0, 0), .._arc(de, a, r), close: true, fill: e.fond, stroke: none)
    }
    line(.._arc(de, a, r), stroke: e.couleur + 0.7pt, mark: (end: "stealth", fill: e.couleur))
    if e.nom != none {
      let m = (de + a) / 2
      content(((r + 0.1) * calc.cos(m * 1deg), (r + 0.1) * calc.sin(m * 1deg)), nom(e.nom, e.couleur), anchor: _ancre-ext(m))
    }
  }
  for e in arcs {
    let (de, a) = (_deg(e.de), _deg(e.a))
    let fl = if e.fleche { (end: "stealth", fill: e.couleur) } else { none }
    line(.._arc(de, a, R), stroke: e.couleur + e.epaisseur, mark: fl)
    if e.nom != none { content(pt((de + a) / 2), nom(e.nom, e.couleur), anchor: _ancre-ext((de + a) / 2), padding: 0.1) }
  }
  for e in rayons {
    let a = _deg(e.angle)
    let fl = if e.fleche { (end: "stealth", fill: e.couleur) } else { none }
    line((0, 0), pt(a), stroke: e.couleur + e.epaisseur, mark: fl)
    if e.nom != none {
      content(pt(a), nom(e.nom, e.couleur), anchor: _ancre-ext(a), padding: 0.08)
    }
    // étiquette au milieu, du côté horaire du rayon (sous un rayon horizontal)
    if e.etiquette != none {
      content(pt(a).map(c => c / 2), nom(e.etiquette, e.couleur), anchor: _ancre-ext(a - 90), padding: 0.06)
    }
    // représentant du même vecteur, d'origine donnée (en rayons)
    if e.copie != none {
      let o = e.copie.map(c => c * R)
      let b = (o.at(0) + pt(a).at(0), o.at(1) + pt(a).at(1))
      line(o, b, stroke: e.couleur + e.epaisseur, mark: (end: "stealth", fill: e.couleur))
      if e.nom-copie != none {
        // nom à gauche du vecteur (côté direct), décalé perpendiculairement
        let n = calc.cos((a + 90) * 1deg) * 0.25
        let m = calc.sin((a + 90) * 1deg) * 0.25
        content(((o.at(0) + b.at(0)) / 2 + n, (o.at(1) + b.at(1)) / 2 + m), nom(e.nom-copie, e.couleur))
      }
    }
  }

  // --- Enroulement de la droite réelle (hors ProfLycee) ----------------
  if aff-axe-reel {
    let hauts = enroulements.map(e => e.x * R)
    let (bas, haut) = (calc.min(-0.6 * R, ..hauts) - 0.1, calc.max(1.2 * R, ..hauts) + 0.3 * R)
    line((R, bas), (R, haut), stroke: black + 0.5 * epaisseur, mark: (end: "stealth", fill: black))
    content((R, haut), val[axe réel], anchor: "west", padding: 0.1)
    marque((R, 0))
    content((R, 0), val($I$), anchor: "north-west", padding: 0.06)
  }
  for e in enroulements {
    let (x, coul) = (e.x, e.couleur)
    let deg = x * 180 / calc.pi
    if e.segment { line((R, 0), (R, x * R), stroke: coul + 1.3pt) }
    if e.arc and calc.rem(deg, 360) != 0 { line(.._arc(0, calc.rem(deg, 360), R), stroke: coul + 1.3pt) }
    // spirale de M(1 ; x) vers N : rayon et angle varient ensemble
    let (rm, am) = (R * calc.sqrt(1 + x * x), calc.atan2(1, x) / 1deg)
    line(
      ..range(61).map(i => {
        let t = i / 60
        let (r, a) = ((1 - t) * rm + t * R, ((1 - t) * am + t * deg) * 1deg)
        (r * calc.cos(a), r * calc.sin(a))
      }),
      stroke: (paint: coul, dash: "densely-dashed", thickness: 0.6pt),
    )
    marque((R, x * R), couleur: coul)
    // nom à droite de la droite réelle, sans la chevaucher
    if e.nom != none { content((R, x * R), nom(e.nom, coul), anchor: "west", padding: 0.08) }
    marque(pt(deg))
  }

  for e in intervalles {
    line((R, e.de * R), (R, e.a * R), stroke: e.couleur + e.epaisseur)
  }

  // --- Points nommés (hors ProfLycee) ----------------------------------
  for e in points {
    let a = _deg(e.angle)
    marque(pt(a), couleur: e.couleur)
    let ancre = if e.ancre == auto { _ancre-ext(a) } else { e.ancre }
    content(pt(a), nom(e.nom, e.couleur), anchor: ancre, padding: 0.08)
  }
}

#let cercle-trigo(..cles) = cetz.canvas(length: 1cm, cercle-trigo-dessin(..cles))
