// Copyright (c) 2026 Arthur Meyer
// SPDX-License-Identifier: MIT
// Voir le fichier LICENSE à la racine du paquet.

// Cercle trigonométrique, d'après \CercleTrigo du paquet LaTeX ProfLycee
// (Cédric Pierquet).
//
//   #trig-circle(clés, ..éléments)       -> un canvas CeTZ autonome ;
//   trig-circle-draw(clés, ..éléments)   -> les éléments CeTZ seuls, à placer
//                                           dans son propre canvas.
//
// Les éléments (tc-point, tc-ray…, voir elements.typ) sont dessinés par
// sorte, toujours dans le même ordre (points en dernier, au-dessus), et dans
// l'ordre donné pour une même sorte.

#import "deps.typ": cetz
#import "outils.typ": _ancre-ext, _arc

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

// Marque d'un point p du cercle, d'angle a (en degrés) : forme (voir
// _marques), largeur t, couleur ; une marque creuse est remplie par le fond,
// pour que le cercle ne la traverse pas. Sur la couche 1 : au-dessus de tout
// le reste, même de ce que l'utilisateur dessine après dans son canvas.
#let _marque(p, forme, t, couleur, a, fond) = cetz.draw.on-layer(1, {
  import cetz.draw: *
  let (x, y) = p
  let h = t / 2
  let trait = couleur + 0.8pt
  let remplissage = if forme.ends-with("*") { couleur } else { fond }
  // polygone régulier de n sommets, le premier à l'angle a0, de rayon r
  let poly(n, r, a0, r2: none) = line(
    ..range(if r2 == none { n } else { 2 * n }).map(i => {
      let (pas, rr) = if r2 == none { (360 / n, r) } else { (180 / n, if calc.even(i) { r } else { r2 }) }
      let b = (a0 + i * pas) * 1deg
      (x + rr * calc.cos(b), y + rr * calc.sin(b))
    }),
    close: true, stroke: trait, fill: remplissage,
  )
  // segment de longueur t centré en p, de direction d (en degrés)
  let trait-dir(d) = line(
    (x - h * calc.cos(d * 1deg), y - h * calc.sin(d * 1deg)),
    (x + h * calc.cos(d * 1deg), y + h * calc.sin(d * 1deg)),
    stroke: trait,
  )
  if forme == "*" { circle(p, radius: h, fill: couleur, stroke: none) }
  else if forme == "o" { circle(p, radius: h, fill: fond, stroke: trait) }
  else if forme.starts-with("square") { poly(4, h * calc.sqrt(2), 45) }
  else if forme.starts-with("triangle") { poly(3, h * 1.15, 90) }
  else if forme.starts-with("diamond") { poly(4, h * 1.2, 0) }
  else if forme.starts-with("star") { poly(5, h * 1.3, 90, r2: h * 0.55) }
  else if forme == "+" { trait-dir(0); trait-dir(90) }
  else if forme == "x" { trait-dir(45); trait-dir(-45) }
  else if forme == "|" { trait-dir(a) }
  else if forme == "-" { trait-dir(a + 90) }
})

#let _sortes = ("point", "ray", "vector", "arc", "angle", "wind", "interval", "cos-eq", "sin-eq", "cos-sin")

#let trig-circle-draw(
  ..elements,
  radius: 3,
  thickness: 1pt,
  margin: 0.25,
  values-size: 7pt,
  angles-size: 8pt,
  names-size: 9pt,
  background: white,
  angles-offset: 10pt,
  minus-pi: true,
  remarkable: true,
  show-values: true,
  show-angles: true,
  show-lines: true,
  show-points: auto,
  show-tan: false,
  show-axes: true,
  show-origin: false,
  show-ticks: false,
  show-vectors: false,
  show-direction: false,
  show-real-line: auto,
  real-line-label: [real line],
  circle-color: black,
) = {
  import cetz.draw: *

  // --- Vérifications --------------------------------------------------
  let cles = elements.named().keys()
  if cles.len() > 0 { panic("trig-circle: unknown key " + repr(cles.first())) }
  let elements = elements.pos()
  for e in elements {
    if type(e) != dictionary or e.at("_ctz-trigo", default: none) not in _sortes {
      panic("trig-circle: expected elements made by tc-point, tc-ray, tc-vector, tc-arc, tc-angle, tc-wind, tc-interval, tc-cos-eq, tc-sin-eq or tc-cos-sin, not " + repr(e))
    }
  }
  if type(radius) not in (int, float) or radius <= 0 {
    panic("trig-circle: radius must be a positive number (in cm), not " + repr(radius))
  }
  let sorte(s) = elements.filter(e => e._ctz-trigo == s)

  // un seul interrupteur pour les valeurs, angles et traits de ProfLycee
  let (show-values, show-angles, show-lines) = if remarkable {
    (show-values, show-angles, show-lines)
  } else { (false, false, false) }
  let show-points = if show-points == auto { show-angles and show-lines } else { show-points }
  let show-real-line = if show-real-line == auto {
    sorte("wind").len() + sorte("interval").len() > 0
  } else { show-real-line }

  let R = radius
  let d = angles-offset / 1cm // décalage converti en unités du canvas (cm)
  let pt(a) = (R * calc.cos(a * 1deg), R * calc.sin(a * 1deg))
  let pointilles = (paint: gray.darken(20%), dash: "dotted", thickness: 0.6pt)
  let etiquette(taille, corps) = box(fill: background, inset: 1.2pt, text(size: taille, corps))
  let val(corps) = etiquette(values-size, corps)
  let ang(corps) = etiquette(angles-size, corps)
  // Éléments ajoutés (tc-*) et repère (O, graduations, i, j, I, droite
  // réelle, sens direct) : noms, points et pointes grandissent avec le
  // cercle au-delà d'un rayon de 1 cm, deux fois moins vite que lui (k = 2 au
  // rayon 3), et gardent leur taille en dessous. Les traits gardent leur
  // épaisseur ; valeurs et angles remarquables, axes et tangente (ProfLycee)
  // ne changent pas.
  let k = calc.max(1, (1 + R) / 2)
  let rep(corps) = etiquette(values-size * k, corps)
  let nom(corps, couleur) = text(size: names-size * k, fill: couleur, corps)
  // points marqués : sur la couche 1, comme _marque
  let marque(p, couleur: black, r: 0.05) = on-layer(1, circle(p, radius: r * k, fill: couleur, stroke: none))
  let pointe(couleur) = (end: "stealth", fill: couleur, scale: k)

  // Valeurs remarquables (cos = sin pour les angles de 30°, 45°, 60°)
  let remarquables = (
    (30, $sqrt(3)/2$, $1/2$),
    (45, $sqrt(2)/2$, $sqrt(2)/2$),
    (60, $1/2$, $sqrt(3)/2$),
  )

  // --- Traits de construction ---------------------------------------
  if show-lines {
    for (a, _, _) in remarquables {
      let (c, s) = pt(a)
      // rectangles reliant les points symétriques
      line((-c, s), (c, s), stroke: pointilles)
      line((-c, -s), (c, -s), stroke: pointilles)
      line((c, -s), (c, s), stroke: pointilles)
      line((-c, -s), (-c, s), stroke: pointilles)
      for b in (a, 180 - a, 180 + a, -a) {
        line((0, 0), pt(b), stroke: pointilles)
      }
    }
  }

  // --- Tangente ------------------------------------------------------
  let h-tan = if show-tan { calc.sqrt(3) * R } else { 0 }
  if show-tan {
    line((R, -h-tan - margin), (R, h-tan + margin), stroke: black + thickness)
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
  let ymax = calc.max(R, h-tan) + margin
  // avec les vecteurs i et j, les axes n'ont pas de flèche (une seule
  // orientation affichée)
  let (fleche, bout) = if show-vectors { (none, 0) } else { ((end: "stealth", fill: black), 0.15) }
  if show-axes {
    line((-R - margin, 0), (R + margin + bout, 0), stroke: black + thickness, mark: fleche)
    line((0, -ymax), (0, ymax + bout), stroke: black + thickness, mark: fleche)
  }
  circle((0, 0), radius: R, stroke: circle-color + thickness)

  // --- Repère : O, graduations ±1, vecteurs i et j -------------------
  if show-origin and not show-values {
    content((0, 0), rep($O$), anchor: "north-east", padding: 0.04 * k)
  }
  if show-ticks {
    let g = 0.06 * k
    for s in (1, -1) {
      line((s * R, -g), (s * R, g), stroke: black + thickness)
      line((-g, s * R), (g, s * R), stroke: black + thickness)
    }
    // sous l'axe des abscisses, à gauche de l'axe des ordonnées : les noms
    // des points (à l'extérieur du cercle, dans leur direction) restent libres
    content((R, 0), rep($1$), anchor: "north", padding: 0.06 * k)
    content((-R, 0), rep($-1$), anchor: "north", padding: 0.06 * k)
    content((0, R), rep($1$), anchor: "east", padding: 0.06 * k)
    content((0, -R), rep($-1$), anchor: "east", padding: 0.06 * k)
  }
  if show-vectors {
    line((0, 0), (R, 0), stroke: black + 1.5 * thickness, mark: pointe(black))
    line((0, 0), (0, R), stroke: black + 1.5 * thickness, mark: pointe(black))
    content((R / 2, 0), rep($arrow(i)$), anchor: "north", padding: 0.06 * k)
    content((0, R / 2), rep($arrow(j)$), anchor: "east", padding: 0.06 * k)
  }

  // --- Sens direct ----------------------------------------------------
  if show-direction {
    let rs = 1.3 * R
    arc(
      (rs * calc.cos(20deg), rs * calc.sin(20deg)),
      start: 20deg,
      stop: 70deg,
      radius: rs,
      stroke: red + thickness,
      mark: pointe(red),
    )
    content((rs * calc.cos(45deg), rs * calc.sin(45deg)), text(fill: red, size: angles-size * k, $+$), anchor: "south-west", padding: 0.06 * k)
  }

  // --- Valeurs remarquables -----------------------------------------
  if show-values {
    content((0, 0), val($0$), anchor: "north-east", padding: 0.04)
    for (a, vc, vs) in remarquables {
      let (c, s) = pt(a)
      // √2/2 de l'autre côté de l'axe, pour éviter les chevauchements
      let (ax, ay) = if a == 45 { ("south", "west") } else { ("north", "east") }
      content((c, 0), val(vc), anchor: ax, padding: 0.06)
      content((-c, 0), val($-#vc$), anchor: ax, padding: 0.06)
      content((0, s), val(vs), anchor: ay, padding: 0.06)
      content((0, -s), val($-#vs$), anchor: ay, padding: 0.06)
    }
  }

  // --- Angles remarquables --------------------------------------------
  if show-angles {
    let liste = if minus-pi { _angles-moins-pi } else { _angles-zero-deux-pi }
    for (a, lab) in liste {
      // les angles sur l'axe vertical sont décalés à droite de l'axe
      if calc.rem(a, 180) == 90 or calc.rem(a, 180) == -90 {
        let y = if calc.sin(a * 1deg) > 0 { R + d } else { -R - d }
        content((0.15, y), ang(lab), anchor: "west")
      } else {
        content(((R + d) * calc.cos(a * 1deg), (R + d) * calc.sin(a * 1deg)), ang(lab))
      }
      if show-points { circle(pt(a), radius: 0.03, fill: black, stroke: none) }
    }
    // angles sur l'axe horizontal : deux étiquettes, de part et d'autre de l'axe
    let (droite-haut, droite-bas, gauche-haut, gauche-bas) = if minus-pi {
      ($0$, none, $pi$, $-pi$)
    } else { ($0$, $2pi$, $pi$, none) }
    let xd = R + d
    content((xd, 0.05), ang(droite-haut), anchor: "south-west")
    if droite-bas != none { content((xd, -0.05), ang(droite-bas), anchor: "north-west") }
    content((-xd, 0.05), ang(gauche-haut), anchor: "south-east")
    if gauche-bas != none { content((-xd, -0.05), ang(gauche-bas), anchor: "north-east") }
  } else if show-points {
    for (a, _) in _angles-moins-pi { circle(pt(a), radius: 0.03, fill: black, stroke: none) }
  }

  // --- Équations cos x = cos α et sin x = sin α ------------------------
  // (c, s) : première solution, (sx, sy) : symétrie vers la seconde
  for e in sorte("cos-eq") + sorte("sin-eq") {
    let (c, s) = if e._ctz-trigo == "cos-eq" {
      (R * calc.cos(e.angle * 1deg), R * calc.abs(calc.sin(e.angle * 1deg)))
    } else {
      (R * calc.abs(calc.cos(e.angle * 1deg)), R * calc.sin(e.angle * 1deg))
    }
    let autre = if e._ctz-trigo == "cos-eq" { (c, -s) } else { (-c, s) }
    if e.lines {
      line((0, 0), (c, s), stroke: (paint: e.color, dash: "dashed", thickness: 0.6pt))
      line((0, 0), autre, stroke: (paint: e.color, dash: "dashed", thickness: 0.6pt))
    }
    line(autre, (c, s), stroke: e.color + 1.6pt)
    marque((c, s), couleur: e.color, r: 0.06)
    marque(autre, couleur: e.color, r: 0.06)
  }

  // --- Point M(cos θ ; sin θ) ----------------------------------------
  for e in sorte("cos-sin") {
    let a = e.angle
    let (c, s) = pt(a)
    let bleu = rgb("#0074D9")
    let rouge = rgb("#C2150C")
    let r-arc = R / 5
    // angle nul : pas d'arc à marquer (CeTZ refuse un arc de 0°)
    if a != 0 {
      arc((r-arc, 0), start: 0deg, stop: a * 1deg, radius: r-arc, stroke: purple + 1pt, mark: pointe(purple))
      content(
        ((r-arc + 0.18 * k) * calc.cos(a / 2 * 1deg), (r-arc + 0.18 * k) * calc.sin(a / 2 * 1deg)),
        text(fill: purple, size: angles-size * k, e.angle-name),
      )
    }
    line((0, 0), (c, s), stroke: black + thickness)
    line((c, s), (c, 0), stroke: (paint: bleu, dash: "dashed", thickness: 0.8pt))
    line((c, s), (0, s), stroke: (paint: rouge, dash: "dashed", thickness: 0.8pt))
    line((0, 0), (c, 0), stroke: bleu + 2.5pt)
    line((0, 0), (0, s), stroke: rouge + 2.5pt)
    let (anc, ans) = (
      if s >= 0 { "north" } else { "south" },
      if c >= 0 { "east" } else { "west" },
    )
    content((c, 0), text(fill: bleu, size: (values-size + 1pt) * k, $cos(#e.angle-name)$), anchor: anc, padding: 0.08 * k)
    content((0, s), text(fill: rouge, size: (values-size + 1pt) * k, $sin(#e.angle-name)$), anchor: ans, padding: 0.08 * k)
    marque((c, s))
    if e.name != none {
      content(
        (c, s),
        text(size: k * 1em, e.name),
        anchor: (if s >= 0 { "south" } else { "north" }) + "-" + (if c >= 0 { "west" } else { "east" }),
        padding: 0.08 * k,
      )
    }
  }

  // --- Angles au centre, arcs, rayons ---------------------------------
  for e in sorte("angle") {
    let r = e.radius * R
    if e.fill != none {
      line((0, 0), .._arc(e.from, e.to, r), close: true, fill: e.fill, stroke: none)
    }
    line(.._arc(e.from, e.to, r), stroke: e.color + 0.7pt, mark: pointe(e.color))
    if e.name != none {
      let m = (e.from + e.to) / 2
      content(((r + 0.1 * k) * calc.cos(m * 1deg), (r + 0.1 * k) * calc.sin(m * 1deg)), nom(e.name, e.color), anchor: _ancre-ext(m))
    }
  }
  for e in sorte("arc") {
    let fl = if e.arrow { pointe(e.color) } else { none }
    line(.._arc(e.from, e.to, R), stroke: e.color + e.thickness, mark: fl)
    let m = (e.from + e.to) / 2
    if e.name != none { content(pt(m), nom(e.name, e.color), anchor: _ancre-ext(m), padding: 0.1 * k) }
  }
  for e in sorte("vector") {
    let a = e.angle
    let o = e.origin.map(c => c * R)
    let l = e.length * R
    let b = (o.at(0) + l * calc.cos(a * 1deg), o.at(1) + l * calc.sin(a * 1deg))
    let ep = if e.thickness == auto { thickness } else { e.thickness }
    line(o, b, stroke: e.color + ep, mark: pointe(e.color))
    if e.name != none {
      // au milieu, du côté direct (à gauche en suivant le vecteur)
      let m = ((o.at(0) + b.at(0)) / 2, (o.at(1) + b.at(1)) / 2)
      content(m, nom(e.name, e.color), anchor: _ancre-ext(a + 90), padding: 0.08 * k)
    }
  }
  for e in sorte("ray") {
    let a = e.angle
    let ep = if e.thickness == auto { thickness } else { e.thickness }
    let fl = if e.arrow { pointe(e.color) } else { none }
    line((0, 0), pt(a), stroke: e.color + ep, mark: fl)
    if e.name != none {
      content(pt(a), nom(e.name, e.color), anchor: _ancre-ext(a), padding: 0.08 * k)
    }
    // étiquette au milieu, du côté horaire du rayon (sous un rayon horizontal)
    if e.label != none {
      content(pt(a).map(c => c / 2), nom(e.label, e.color), anchor: _ancre-ext(a - 90), padding: 0.06 * k)
    }
    // représentant du même vecteur, d'origine donnée (en rayons)
    if e.copy != none {
      let o = e.copy.map(c => c * R)
      let b = (o.at(0) + pt(a).at(0), o.at(1) + pt(a).at(1))
      line(o, b, stroke: e.color + ep, mark: pointe(e.color))
      if e.copy-name != none {
        // nom à gauche du vecteur (côté direct), décalé perpendiculairement
        let n = calc.cos((a + 90) * 1deg) * 0.25 * k
        let m = calc.sin((a + 90) * 1deg) * 0.25 * k
        content(((o.at(0) + b.at(0)) / 2 + n, (o.at(1) + b.at(1)) / 2 + m), nom(e.copy-name, e.color))
      }
    }
  }

  // --- Enroulement de la droite réelle --------------------------------
  if show-real-line {
    let hauts = (sorte("wind").map(e => e.x) + sorte("interval").map(e => e.from) + sorte("interval").map(e => e.to)).map(y => y * R)
    // au moins 0,5 cm au-dessus du dernier point : son nom et celui de la droite
    // ne se chevauchent pas
    let (bas, haut) = (calc.min(-0.6 * R, ..hauts) - 0.1, calc.max(1.2 * R, ..hauts) + calc.max(0.3 * R, 0.5))
    line((R, bas), (R, haut), stroke: black + 0.5 * thickness, mark: pointe(black))
    content((R, haut), rep(real-line-label), anchor: "west", padding: 0.1 * k)
    marque((R, 0))
    content((R, 0), rep($I$), anchor: "north-west", padding: 0.06 * k)
  }
  for e in sorte("wind") {
    let (x, coul) = (e.x, e.color)
    let deg = x * 180 / calc.pi
    if e.segment { line((R, 0), (R, x * R), stroke: coul + 1.3pt) }
    if e.arc and calc.rem(deg, 360) != 0 { line(.._arc(0, calc.rem(deg, 360), R), stroke: coul + 1.3pt) }
    // spirale de M(1 ; x) vers le point image : rayon et angle varient ensemble
    let (rm, am) = (R * calc.sqrt(1 + x * x), calc.atan2(1, x) / 1deg)
    line(
      ..range(61).map(i => {
        let t = i / 60
        let (r, a) = ((1 - t) * rm + t * R, ((1 - t) * am + t * deg) * 1deg)
        (r * calc.cos(a), r * calc.sin(a))
      }),
      stroke: (paint: coul, dash: "densely-dashed", thickness: 0.6pt),
    )
    // sur la droite réelle (verticale), la normale est horizontale : angle 0
    if e.mark != none { _marque((R, x * R), e.mark, e.mark-size * k, coul, 0, background) }
    // nom à droite de la droite réelle, sans la chevaucher
    if e.name != none { content((R, x * R), nom(e.name, coul), anchor: "west", padding: 0.08 * k) }
    if e.mark != none { _marque(pt(deg), e.mark, e.mark-size * k, black, deg, background) }
  }
  for e in sorte("interval") {
    line((R, e.from * R), (R, e.to * R), stroke: e.color + e.thickness)
  }

  // --- Points nommés ---------------------------------------------------
  for e in sorte("point") {
    if e.mark != none { _marque(pt(e.angle), e.mark, e.mark-size * k, e.color, e.angle, background) }
    let ancre = if e.anchor == auto { _ancre-ext(e.angle) } else { e.anchor }
    if e.name != none { content(pt(e.angle), nom(e.name, e.color), anchor: ancre, padding: 0.08 * k) }
  }
}

#let trig-circle(..args) = cetz.canvas(length: 1cm, trig-circle-draw(..args))
