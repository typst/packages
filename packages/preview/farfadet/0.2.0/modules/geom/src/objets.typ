// objets.typ (farfadet-geom) — objets de base : point, segment, droite, demi-droite, vecteur, cercle, arc, polygone, triangle.

#import "@preview/cetz:0.5.3": draw as d
#import "rapide.typ" as _r
#import "base.typ": *
#import "codages.typ": _angle-droit, _codage-parallele, _codage-segment

// ---------- Points ----------

/// Point marqué d'une croix (ou d'un disque), avec son nom placé autour. Le nom est le second argument
/// (positionnel) ou la clé `nom`. Une chaîne `"A"` est écrite en maths (`$A$`).
///
/// - p (array): coordonnées `(x, y)`.
/// - ..nom (str, content): nom du point (facultatif, positionnel).
/// - pos (str, angle): où se place le nom autour du point : `"n"`, `"s"`, `"e"`, `"o"`, `"ne"`, `"no"`, `"se"`, `"so"` ou un angle. Défaut : `"ne"`.
/// - forme (auto, str): `"croix"` ou `"disque"`. Défaut : `auto` (clé `forme-point`).
/// - taille (auto, length): demi-diagonale de la croix, ou rayon du disque. Défaut : `auto` (clé `taille-point`).
/// - couleur (auto, str, color): couleur du point et de son nom (`"rouge"`, `"rose"`…). Défaut : `auto`.
/// - nom (none, str, content): nom du point, comme second argument positionnel.
#let point(p, ..autres, nom: none, pos: "ne", forme: auto, taille: auto, couleur: auto) = elem("point", (g, ctx) => {
  verifier-point(p, "point", "p")
  if autres.pos().len() > 1 { panic("point : un seul nom positionnel est attendu ; reçu : " + repr(autres.pos()) + ".") }
  let nom = if autres.pos().len() == 1 { autres.pos().first() } else { nom }
  let c = couleur-de(g, couleur, "point")
  let forme = if forme == auto { g.forme-point } else { forme }
  if forme not in ("croix", "disque") {
    panic("point : forme inconnue " + repr(forme) + ". Formes possibles : « croix », « disque ».")
  }
  let t = u(ctx, if taille == auto { g.taille-point } else { taille })
  if forme == "croix" {
    let st = (paint: c, thickness: g.epaisseur)
    _r.ligne(ajouter(p, (-t, -t)), ajouter(p, (t, t)), stroke: st)
    _r.ligne(ajouter(p, (-t, t)), ajouter(p, (t, -t)), stroke: st)
  } else {
    d.circle(p, radius: t * 0.8, fill: c, stroke: none)
  }
  if nom != none { etiquette(g, p, nom, pos, c, "point") }
})

// ---------- Segments, droites ----------

/// Segment `[a b]`, avec codages facultatifs (traits de longueur égale, chevrons de parallélisme).
///
/// - a (array): première extrémité `(x, y)`.
/// - b (array): seconde extrémité `(x, y)`.
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto` (clé `epaisseur`).
/// - style (str): `"plein"`, `"tirets"`, `"pointilles"` ou `"mixte"`. Défaut : `"plein"`.
/// - codage (none, int): 1, 2 ou 3 traits au milieu. Défaut : `none`.
/// - parallele (none, int): 1, 2 ou 3 chevrons au milieu. Défaut : `none`.
#let segment(a, b, couleur: auto, epaisseur: auto, style: "plein", codage: none, parallele: none) = elem("segment", (g, ctx) => {
  verifier-point(a, "segment", "a")
  verifier-point(b, "segment", "b")
  let st = trait(g, "segment", couleur: couleur, epaisseur: epaisseur, style: style)
  _r.ligne(a, b, stroke: st)
  if codage != none { _codage-segment(g, ctx, a, b, codage-valide(codage, "segment"), st.paint) }
  if parallele != none { _codage-parallele(g, ctx, a, b, codage-valide(parallele, "segment"), st.paint) }
})

#let _fenetre-requise(ctx, fenetre, cmd) = {
  let f = if fenetre == auto { fenetre-de(ctx) } else { fenetre }
  if f == none {
    panic(cmd + " : la fenêtre de la figure est inconnue ; donner fenetre: ((xmin, ymin), (xmax, ymax)) à geo(…), à repere(…) ou à " + cmd + "(…).")
  }
  fenetre-valide(f, cmd)
}

/// Droite `(a b)` prolongée jusqu'aux bords de la fenêtre de la figure.
///
/// - a (array): un point de la droite.
/// - b (array): un autre point de la droite.
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): `"plein"`, `"tirets"`, `"pointilles"` ou `"mixte"`. Défaut : `"plein"`.
/// - fenetre (auto, array): `((xmin, ymin), (xmax, ymax))` ; `auto` prend celle de `geo` ou de `repere`. Défaut : `auto`.
#let droite(a, b, couleur: auto, epaisseur: auto, style: "plein", fenetre: auto) = elem("droite", (g, ctx) => {
  verifier-point(a, "droite", "a")
  verifier-point(b, "droite", "b")
  let f = _fenetre-requise(ctx, fenetre, "droite")
  let morceau = couper(a, unitaire(retrancher(b, a), cmd: "droite"), f)
  if morceau != none {
    _r.ligne(..morceau, stroke: trait(g, "droite", couleur: couleur, epaisseur: epaisseur, style: style))
  }
})

/// Demi-droite `[a b)` d'origine `a`, prolongée jusqu'au bord de la fenêtre.
///
/// - a (array): origine.
/// - b (array): un autre point de la demi-droite.
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): `"plein"`, `"tirets"`, `"pointilles"` ou `"mixte"`. Défaut : `"plein"`.
/// - fenetre (auto, array): fenêtre `((xmin, ymin), (xmax, ymax))`. Défaut : `auto`.
#let demi-droite(a, b, couleur: auto, epaisseur: auto, style: "plein", fenetre: auto) = elem("demi-droite", (g, ctx) => {
  verifier-point(a, "demi-droite", "a")
  verifier-point(b, "demi-droite", "b")
  let f = _fenetre-requise(ctx, fenetre, "demi-droite")
  let morceau = couper(a, unitaire(retrancher(b, a), cmd: "demi-droite"), f, depuis-p: true)
  if morceau != none {
    _r.ligne(..morceau, stroke: trait(g, "demi-droite", couleur: couleur, epaisseur: epaisseur, style: style))
  }
})

// ---------- Vecteurs ----------

#let _vecteur(g, ctx, cmd, a, b, nom, pos, couleur, epaisseur, style) = {
  let st = trait(g, cmd, couleur: couleur, epaisseur: if epaisseur == auto { g.epaisseur-forte } else { epaisseur }, style: style)
  _r.fleche(a, b, stroke: st, mark: (end: g.fleche, fill: st.paint))
  if nom != none {
    let v = unitaire(retrancher(b, a), cmd: cmd)
    let cote = if pos == auto { angle-du-vecteur(perpendiculaire(v)) } else { pos }
    _r.contenu(
      milieu(a, b),
      texte-geom(g, st.paint, nom-vecteur(nom, cmd)),
      anchor: ancre-de(cote, cmd),
      padding: g.espace-etiquette + 3pt,
    )
  }
}

/// Vecteur de `a` vers `b` : flèche pleine et nom surmonté d'une flèche, placé au milieu.
///
/// - a (array): origine.
/// - b (array): extrémité.
/// - nom (none, str, content): nom du vecteur (`"u"`, `"A B"`) ; la flèche au-dessus est ajoutée. Défaut : `none`.
/// - pos (auto, str, angle): position du nom (comme pour `point`). Défaut : `auto` (à gauche du sens de la flèche).
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto` (clé `epaisseur-forte`).
/// - style (str): `"plein"`, `"tirets"`, `"pointilles"` ou `"mixte"`. Défaut : `"plein"`.
#let fleche(a, b, nom: none, pos: auto, couleur: auto, epaisseur: auto, style: "plein") = elem("vecteur", (g, ctx) => {
  verifier-point(a, "vecteur", "a")
  verifier-point(b, "vecteur", "b")
  _vecteur(g, ctx, "vecteur", a, b, nom, pos, couleur, epaisseur, style)
})

/// Vecteur de coordonnées `v` tracé à partir du point `a` (extrémité `a + v`).
///
/// - a (array): origine.
/// - v (array): coordonnées `(dx, dy)` du vecteur.
/// - nom (none, str, content): nom du vecteur. Défaut : `none`.
/// - pos (auto, str, angle): position du nom. Défaut : `auto`.
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): style du trait. Défaut : `"plein"`.
#let fleche-de(a, v, nom: none, pos: auto, couleur: auto, epaisseur: auto, style: "plein") = elem("vecteur-de", (g, ctx) => {
  verifier-point(a, "vecteur-de", "a")
  verifier-point(v, "vecteur-de", "v")
  _vecteur(g, ctx, "vecteur-de", a, ajouter(a, v), nom, pos, couleur, epaisseur, style)
})

// ---------- Cercles, arcs ----------

#let _rayon(ctx, c, r, cmd) = {
  if type(r) == array { distance(c, point-valide(r, cmd, "r")) } else if type(r) == length { u(ctx, r) } else if est-nombre(r) and r > 0 { r } else {
    panic(cmd + " : le rayon attend un nombre positif, une longueur ou un point du cercle ; reçu : " + repr(r) + ".")
  }
}

/// Cercle de centre `c` et de rayon `r`.
///
/// - c (array): centre `(x, y)`.
/// - r (int, float, length, array): rayon (en unités de la figure), ou point du cercle.
/// - remplissage (none, str, color): fond (un nom de couleur donne sa version claire). Défaut : `none`.
/// - couleur (auto, str, color): couleur du trait. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): style du trait. Défaut : `"plein"`.
#let cercle(c, r, remplissage: none, couleur: auto, epaisseur: auto, style: "plein") = elem("cercle", (g, ctx) => {
  verifier-point(c, "cercle", "c")
  d.circle(
    c,
    radius: _rayon(ctx, c, r, "cercle"),
    fill: fond-de(g, remplissage, "cercle"),
    stroke: trait(g, "cercle", couleur: couleur, epaisseur: epaisseur, style: style),
  )
})

/// Arc de cercle de centre `c`, de `debut` à `fin` (sens direct).
///
/// - c (array): centre `(x, y)`.
/// - r (int, float, length, array): rayon, ou point du cercle.
/// - debut (angle): angle de départ (`20deg`).
/// - fin (angle): angle d'arrivée (`110deg`).
/// - couleur (auto, str, color): couleur du trait. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): style du trait. Défaut : `"plein"`.
#let arc(c, r, debut, fin, couleur: auto, epaisseur: auto, style: "plein") = elem("arc", (g, ctx) => {
  verifier-point(c, "arc", "c")
  if type(debut) != angle or type(fin) != angle {
    panic("arc : « debut » et « fin » attendent des angles (30deg) ; reçu : " + repr(debut) + " et " + repr(fin) + ".")
  }
  let rr = _rayon(ctx, c, r, "arc")
  d.arc(
    ajouter(c, multiplier(direction-angle(debut), rr)),
    start: debut,
    stop: fin,
    radius: rr,
    stroke: trait(g, "arc", couleur: couleur, epaisseur: epaisseur, style: style),
  )
})

// ---------- Polygones ----------

/// Polygone fermé, avec noms des sommets placés vers l'extérieur et codages par côté ou par sommet.
///
/// - sommets (array): au moins trois points `(x, y)`, dans l'ordre.
/// - noms (none, array): noms des sommets (`("A", "B", "C")`), placés à l'opposé du centre. Défaut : `none`.
/// - pos-noms (auto, array): positions des noms (comme pour `point`), un par sommet ; `auto` les place vers l'extérieur. Défaut : `auto`.
/// - codages (none, array): par côté `[Si Si+1]`, 1, 2, 3 traits ou `none` (`(1, 2, 1, 2)` pour un parallélogramme). Défaut : `none`.
/// - paralleles (none, array): par côté, 1, 2, 3 chevrons ou `none`. Défaut : `none`.
/// - angles-droits (array): indices (à partir de 0) des sommets où figure un angle droit. Défaut : `()`.
/// - remplissage (none, str, color): fond. Défaut : `none`.
/// - couleur (auto, str, color): couleur du trait. Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): style du trait. Défaut : `"plein"`.
#let polygone(
  sommets,
  noms: none,
  pos-noms: auto,
  codages: none,
  paralleles: none,
  angles-droits: (),
  remplissage: none,
  couleur: auto,
  epaisseur: auto,
  style: "plein",
) = elem("polygone", (g, ctx) => {
  if type(sommets) != array or sommets.len() < 3 {
    panic("polygone : « sommets » attend au moins trois points (x, y) ; reçu : " + repr(sommets) + ".")
  }
  for (i, s) in sommets.enumerate() { verifier-point(s, "polygone", "sommets (point " + str(i) + ")") }
  let n = sommets.len()
  for (cle, v) in (("noms", noms), ("codages", codages), ("paralleles", paralleles)) {
    if v != none and (type(v) != array or v.len() != n) {
      panic("polygone : « " + cle + " » attend un tableau de " + str(n) + " éléments (un par " + if cle == "noms" { "sommet" } else { "côté" } + ") ; reçu : " + repr(v) + ".")
    }
  }
  let st = trait(g, "polygone", couleur: couleur, epaisseur: epaisseur, style: style)
  _r.ligne(..sommets, close: true, fill: fond-de(g, remplissage, "polygone"), stroke: st)
  if codages != none {
    for (i, k) in codages.enumerate() {
      if k != none { _codage-segment(g, ctx, sommets.at(i), sommets.at(calc.rem(i + 1, n)), codage-valide(k, "polygone"), st.paint) }
    }
  }
  if paralleles != none {
    for (i, k) in paralleles.enumerate() {
      if k != none { _codage-parallele(g, ctx, sommets.at(i), sommets.at(calc.rem(i + 1, n)), codage-valide(k, "polygone"), st.paint) }
    }
  }
  for i in angles-droits {
    if type(i) != int or i < 0 or i >= n {
      panic("polygone : « angles-droits » attend des indices de sommets entre 0 et " + str(n - 1) + " ; reçu : " + repr(i) + ".")
    }
    _angle-droit(
      g, ctx, sommets.at(i), sommets.at(calc.rem-euclid(i - 1, n)), sommets.at(calc.rem(i + 1, n)), st.paint, auto, "polygone",
    )
  }
  if noms != none {
    let centre = multiplier(sommets.fold((0, 0), (acc, s) => ajouter(acc, s)), 1 / n)
    for (i, s) in sommets.enumerate() {
      if noms.at(i) != none {
        let pos = if pos-noms == auto { angle-du-vecteur(retrancher(s, centre)) } else { pos-noms.at(i) }
        etiquette(g, s, noms.at(i), pos, g.couleur, "polygone")
      }
    }
  }
})

/// Triangle `a b c` : cas particulier de `polygone` à trois sommets (mêmes clés).
///
/// - a (array): premier sommet.
/// - b (array): deuxième sommet.
/// - c (array): troisième sommet.
/// - ..options: clés de `polygone` (`noms`, `codages`, `angles-droits`, `remplissage`, `couleur`…).
#let triangle(a, b, c, ..options) = {
  if options.pos().len() > 0 { panic("triangle : seuls trois sommets positionnels sont attendus ; reçu en plus : " + repr(options.pos()) + ".") }
  polygone((a, b, c), ..options.named())
}
