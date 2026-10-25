// rdgrid.typ (rdgrid, moteur) — grilles de triangles équilatéraux (equi), d'hexagones (hexa),
// d'hexagones tournés (rhexa) et isométriques (iso).
//
// On dessine ensuite par-dessus avec les coordonnées nommées des « pics » (`trg-1-3-north east`,
// `hexa-0-2-center`…), souvent copiées depuis le livret GeoGebra. La grille est un contenu ; le dessin
// ajouté passe par la clé `code-after` (fonction des points nommés), qui comprend aussi un chemin TikZ
// collé tel quel (`path`).
//
// Les coordonnées sont calculées en unités TikZ (cm, axe y vers le haut), puis converties dans le repère
// de Typst (origine en haut à gauche de la grille, y vers le bas).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: reglages-paquet, reglages-controles, reglages-choix, reglages-ou, lire-options, taille-latex
#import "commun.typ": *

// =====================================================================
// Réglages (`setrdgrid`)
// =====================================================================

#let _style = rd-controle-style
#let _nombre-ou-longueur = (v => type(v) in (int, float, length), "un nombre (en cm, comme TikZ) ou une longueur")

#let rdgrid-types = ("equi", "hexa", "rhexa", "iso")

#let rdgrid-reglages = reglages-paquet(
  "rdgrid",
  (
    width: 1,
    radius: auto,
    grid: 1,
    orientation: true,
    dot: false,
    dot-style: (shape: "circle", min-width: 1.5pt, fill: "gray"),
    dot-style-app: none,
    show-grid: true,
    show-num: false,
    num-style: (font: (family: ("Latin Modern Sans", "TeX Gyre Heros"), weight: "bold", size: "footnotesize")),
    only-dot: false,
    scope-style: (draw: "gray", line-width: 0.5pt),
    scope-style-app: none,
    frame: true,
    lines: true,
    // ajouts
    polygon-style: none, // style d'un polygone nommé
    code-after: none, // dessin ajouté par-dessus la grille
    line-join: "bevel", // jointure des traits du scope style
  ),
  controles: (
    width: _nombre-ou-longueur,
    radius: reglages-ou((v => v == auto, "auto"), _nombre-ou-longueur),
    grid: reglages-controles.entier,
    orientation: reglages-controles.booleen,
    dot: reglages-controles.booleen,
    dot-style: _style,
    dot-style-app: _style,
    show-grid: reglages-controles.booleen,
    show-num: reglages-controles.booleen,
    num-style: _style,
    only-dot: reglages-controles.booleen,
    scope-style: _style,
    scope-style-app: _style,
    frame: reglages-controles.booleen,
    lines: reglages-controles.booleen,
    polygon-style: (
      v => v == none or (type(v) == dictionary and v.values().all(x => x == none or type(x) in (dictionary, function, array))),
      "none ou un dictionnaire de styles indexés par nom de polygone, par exemple (\"hexa-0-0\": (fill: red))",
    ),
    code-after: (v => v == none or type(v) == function, "none ou une fonction (points) => contenu"),
    line-join: reglages-choix("miter", "round", "bevel"),
  ),
  // défauts propres à chaque type de grille
  types: (
    equi: (:),
    hexa: (width: 0.7),
    rhexa: (width: 0.7),
    iso: (:),
  ),
  commande: "setrdgrid",
)

// =====================================================================
// Géométrie (unités TikZ : cm, y vers le haut)
// =====================================================================

#let _c30 = 0.866025403
#let _pol(a, r) = (r * calc.cos(a * 1deg), r * calc.sin(a * 1deg))
#let _add(p, q) = (p.at(0) + q.at(0), p.at(1) + q.at(1))

/// Polygones de la grille : tableau de (nom, ancres: (nom-ancre: point), contour: (points…), ferme: bool).
#let rdgrid-polygones(genre, xmax, ymax, u, g) = {
  let res = ()
  if genre == "equi" {
    for j in range(ymax) {
      for i in range(xmax) {
        let o = (i * u / 2, j * u * calc.sqrt(3) / 2)
        let flag = g * calc.pow(-1, i + j)
        let h = u * calc.sqrt(3) / 2
        let a = if flag == -1 {
          (south: (u / 2, 0), north-east: (u, h), north-west: (0, h), center: (u / 2, h - h / 3))
        } else {
          (south-west: (0, 0), south-east: (u, 0), north: (u / 2, h), center: (u / 2, h / 3))
        }
        a = a.pairs().map(((k, p)) => (k, _add(o, p))).to-dict()
        let contour = if flag == -1 { (a.south, a.north-east, a.north-west) } else { (a.south-west, a.south-east, a.north) }
        res.push((nom: "trg-" + str(i) + "-" + str(j), ancres: a, contour: contour, ferme: true, i: i, j: j))
      }
    }
  } else if genre == "rhexa" or genre == "hexa" {
    let pointe = genre == "rhexa"
    let noms = if pointe {
      ((30, "north-east"), (90, "north"), (150, "north-west"), (210, "south-west"), (270, "south"), (330, "south-east"))
    } else {
      ((0, "east"), (60, "north-east"), (120, "north-west"), (180, "west"), (240, "south-west"), (300, "south-east"))
    }
    let centres = ()
    if pointe {
      let xs = u * _c30
      for j in range(ymax) {
        let (dx, n) = (0, xmax)
        if calc.odd(j) {
          if g == -1 { dx = -xs } else if g == 1 { dx = xs } else if g == 2 { (dx, n) = (-xs, xmax + 1) } else { (dx, n) = (xs, xmax - 1) }
        }
        for i in range(n) { centres.push((i, j, (2 * i * u * _c30 + dx, 1.5 * u * j))) }
      }
    } else {
      let (xs, ys) = (1.5 * u, _c30 * u)
      let sg = if g > 0 { 1 } else if g < 0 { -1 } else { 0 }
      for j in range(ymax) {
        for i in range(xmax) {
          let coef = if calc.odd(i) { sg } else { 0 }
          centres.push((i, j, (i * xs, 2 * j * ys + coef * ys)))
        }
      }
    }
    for (i, j, c) in centres {
      let a = (center: c)
      for (ang, nom) in noms { a.insert(nom, _add(c, _pol(ang, u))) }
      res.push((nom: "hexa-" + str(i) + "-" + str(j), ancres: a, contour: noms.map(((_, n)) => a.at(n)), ferme: true, i: i, j: j))
    }
  } else {
    // iso
    let (xs, ys) = (u * _c30, 0.5 * u)
    for j in range(ymax) {
      for i in range(xmax) {
        let o = (i * xs, j * ys)
        let flag = g * calc.pow(-1, i + j)
        let a = if flag == -1 {
          (south: (u * _c30, 0), west: (0, u / 2), north: (u * _c30, u), center: (u * _c30 * 2 / 3, u / 2))
        } else {
          (south: (0, 0), east: (u * _c30, u / 2), north: (0, u), center: (u * _c30 / 3, u / 2))
        }
        a = a.pairs().map(((k, p)) => (k, _add(o, p))).to-dict()
        let contour = if flag == -1 { (a.south, a.west, a.north) } else { (a.south, a.east, a.north) }
        res.push((nom: "trg-" + str(i) + "-" + str(j), ancres: a, contour: contour, ferme: false, i: i, j: j))
      }
    }
  }
  res
}

// =====================================================================
// Chemins TikZ collés (code GeoGebra) : « [opts] (trg-1-3-north east)--(…)--cycle; »
// =====================================================================

/// Style Typst (stroke, fill) d'options TikZ en chaîne : `color=red, line width=1.5pt, fill=blue!20, dashed`.
#let rdgrid-options-tikz(s, commande: "rdgrid") = {
  let o = lire-options(s)
  let st = (:)
  for (k, v) in o {
    if k in ("color", "draw") { st.draw = v } else if k == "fill" { st.fill = v } else if k == "line-width" {
      st.line-width = eval(v.replace(" ", ""))
    } else if k in ("dashed", "dotted", "densely-dashed", "loosely-dashed", "densely-dotted", "loosely-dotted") {
      st.dash = k
    } else if k == "opacity" { st.opacity = float(v) } else if k == "fill-opacity" { st.fill-opacity = float(v) } else if v == true and k.match(regex("^[A-Za-z!0-9.]+$")) != none {
      st.draw = k // couleur nue : [red]
    } else {
      panic(commande + " : option TikZ non reconnue « " + k + " » dans le chemin. Options possibles : color, draw, fill, line width, opacity, fill opacity, dashed, dotted, ou une couleur nue.")
    }
  }
  st
}

// =====================================================================
// Rendu (dans un `context`)
// =====================================================================

#let _cm(v) = if type(v) == length { v.to-absolute() } else { v * 1cm }

/// Rendu de \rdgrid : `r` = réglages résolus, `genre` = equi|hexa|rhexa|iso.
#let rdgrid-rendu(r, genre, xmax, ymax, commande: "rdgrid") = {
  let cmd = commande
  let u = if r.radius != auto { r.radius } else { r.width }
  let u = if type(u) == length { u.to-absolute() / 1cm } else { u }
  let show-grid = r.show-grid and not r.only-dot
  let dot = r.dot or r.only-dot
  let polys = rdgrid-polygones(genre, xmax, ymax, u, r.grid)
  // lignes et cadre (iso seulement)
  let (xs, ys) = (u * _c30, 0.5 * u)
  let (xc, yc) = (xmax * xs, (ymax + 1) * ys)
  let segments = ()
  if genre == "iso" {
    if r.lines and xmax > 1 { for i in range(1, xmax) { segments.push(((i * xs, 0), (i * xs, yc))) } }
    if r.frame { segments.push(((0, 0), (xc, 0), (xc, yc), (0, yc), (0, 0))) }
  }
  // boîte englobante (unités TikZ)
  let tous = polys.map(p => p.contour).flatten().chunks(2)
  for s in segments { tous += s }
  let xsv = tous.map(p => p.at(0))
  let ysv = tous.map(p => p.at(1))
  let st-dot = rd-style-fusion(r.dot-style, r.dot-style-app, commande: cmd)
  let rd = if dot { rd-abs(st-dot.cles.at("min-width", default: 1.5pt)) / 2 } else { 0pt }
  let (x0, x1, y0, y1) = (calc.min(..xsv) * 1cm - rd, calc.max(..xsv) * 1cm + rd, calc.min(..ysv) * 1cm - rd, calc.max(..ysv) * 1cm + rd)
  let T(p) = (p.at(0) * 1cm - x0, y1 - p.at(1) * 1cm)
  // style du scope
  let st-scope = rd-style-fusion(r.scope-style, r.scope-style-app, commande: cmd)
  let trait = rd-trait(st-scope, defaut: black, epaisseur: 0.4pt, commande: cmd)
  if trait != none { trait.join = r.line-join }
  let styles-poly = if r.polygon-style == none { (:) } else { r.polygon-style }
  let el = ()
  for p in polys {
    let sp = rd-style-fusion(st-scope, styles-poly.at(p.nom, default: none), commande: cmd)
    let fond = rd-fond(sp, commande: cmd)
    let tp = rd-trait(sp, defaut: black, epaisseur: 0.4pt, commande: cmd)
    if tp != none { tp.join = r.line-join }
    let pts = p.contour.map(T)
    if fond != none { el.push(place(top + left, polygon(fill: fond, stroke: none, ..pts))) }
    if show-grid and tp != none {
      if p.ferme { el.push(place(top + left, polygon(stroke: tp, ..pts))) } else {
        el.push(place(top + left, curve(stroke: tp, curve.move(pts.at(0)), ..pts.slice(1).map(q => curve.line(q)))))
      }
    }
    if dot {
      for q in p.contour {
        let n = rd-noeud(none, st-dot, commande: cmd)
        let (x, y) = T(q)
        el.push(place(top + left, dx: x - n.w / 2, dy: y - n.h / 2, n.corps))
      }
    }
    if r.show-num {
      let n = rd-noeud([#p.i\-#p.j], rd-style-fusion((inset: 0.3333em), r.num-style, commande: cmd), commande: cmd)
      let (x, y) = T(p.ancres.center)
      el.push(place(top + left, dx: x - n.w / 2, dy: y - n.h / 2, n.corps))
    }
  }
  for s in segments {
    if trait != none {
      let pts = s.map(T)
      el.push(place(top + left, curve(stroke: trait, curve.move(pts.at(0)), ..pts.slice(1).map(q => curve.line(q)))))
    }
  }
  // points nommés pour code-after
  if r.code-after != none {
    let points = (:)
    for p in polys {
      for (k, q) in p.ancres {
        let pt = T(q)
        points.insert(p.nom + "-" + k, pt)
        points.insert(p.nom + "-" + k.replace("-", " "), pt)
      }
    }
    let pt(nom) = {
      let n = nom.trim().trim("(").trim(")").trim()
      if n not in points {
        panic(cmd + " : point inconnu « " + n + " ». Exemples de points : « " + polys.at(0).nom + "-center », « " + polys.at(0).nom + "-" + polys.at(0).ancres.keys().at(0).replace("-", " ") + " ».")
      }
      points.at(n)
    }
    let xy(x, y) = T((x, y))
    let path(s, stroke: auto, fill: none) = {
      let s = s.trim().trim(";").trim()
      if s.starts-with("\\draw") { s = s.slice(5).trim() }
      if s.starts-with("\\fill") { s = s.slice(5).trim(); if fill == none { fill = black } }
      let st = (:)
      if s.starts-with("[") {
        let fin = s.position("]")
        st = rdgrid-options-tikz(s.slice(1, fin), commande: cmd)
        s = s.slice(fin + 1)
      }
      let morceaux = s.split("--").map(m => m.trim()).filter(m => m != "")
      let ferme = morceaux.last() == "cycle"
      if ferme { morceaux = morceaux.slice(0, -1) }
      let pts = morceaux.map(pt)
      let sn = rd-style(st, commande: cmd)
      let tr = if stroke != auto { stroke } else { rd-trait(sn, defaut: black, epaisseur: 0.4pt, commande: cmd) }
      let f = if fill != none { fill } else { rd-fond(sn, commande: cmd) }
      if ferme { place(top + left, polygon(stroke: tr, fill: f, ..pts)) } else {
        place(top + left, curve(stroke: tr, curve.move(pts.at(0)), ..pts.slice(1).map(q => curve.line(q))))
      }
    }
    let node(p, c) = rd-node-at(if type(p) == str { pt(p) } else { p }, c)
    el.push((r.code-after)((pt: pt, xy: xy, path: path, node: node, points: points)))
  }
  box(width: x1 - x0, height: y1 - y0, el.join())
}
