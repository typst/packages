// traces.typ (farfadet-geom) — tracés libres : étiquette de texte, ligne brisée, quadrillage, axes.
// Chaque tracé est un élément court de rapide.typ (un seul élément cetz, sans d.line ni d.content).

#import "base.typ" as _b
#import "rapide.typ" as _r
#import "outils.typ": verifier-point

/// Texte libre placé sur un point ou autour de lui.
///
/// - p (array): coordonnées `(x, y)`.
/// - corps (content, str): texte de l'étiquette, écrit tel quel (pas de passage en maths).
/// - pos (auto, str, angle): où se place le texte autour du point : `"n"`, `"s"`, `"e"`, `"o"`, `"ne"`, `"no"`, `"se"`, `"so"` ou un angle. Défaut : `auto` (centré sur le point).
/// - couleur (auto, str, color): couleur du texte. Défaut : `auto`.
/// - taille (auto, length): taille du texte. Défaut : `auto` (clé `taille-texte`).
#let etiquette(p, corps, pos: auto, couleur: auto, taille: auto) = _b.elem("etiquette", (g, ctx) => {
  let c = _b.couleur-de(g, couleur, "etiquette")
  _r.contenu(
    p,
    if taille == auto { _b.texte-geom(g, c, corps) } else { text(fill: c, size: taille, corps) },
    anchor: if pos == auto { "center" } else { _b.ancre-de(pos, "etiquette") },
    padding: if pos == auto { 0pt } else { g.espace-etiquette },
  )
})

/// Ligne brisée par les points `pts`, ouverte ou fermée, éventuellement remplie.
///
/// - pts (array): au moins deux points `(x, y)`.
/// - ferme (bool): relie le dernier point au premier. Défaut : `false`.
/// - remplissage (none, str, color): fond (un nom de couleur donne sa version claire). Défaut : `none`.
/// - couleur (auto, none, str, color): couleur du trait ; `none` : pas de trait (fond seul). Défaut : `auto`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
/// - style (str): `"plein"`, `"tirets"`, `"pointilles"` ou `"mixte"`. Défaut : `"plein"`.
#let ligne-brisee(
  pts,
  ferme: false,
  remplissage: none,
  couleur: auto,
  epaisseur: auto,
  style: "plein",
) = _b.elem("ligne-brisee", (g, ctx) => {
  if type(pts) != array or pts.len() < 2 {
    panic("ligne-brisee : « pts » attend au moins deux points (x, y) ; reçu : " + repr(pts) + ".")
  }
  let st = if couleur == none { none } else {
    _b.trait(g, "ligne-brisee", couleur: couleur, epaisseur: epaisseur, style: style)
  }
  _r.ligne(..pts, close: ferme, fill: _b.fond-de(g, remplissage, "ligne-brisee"), stroke: st)
})

/// Quadrillage (sans axes) du rectangle `x` × `y`, aux multiples de `pas`.
///
/// - x (array): intervalle `(x0, x1)`.
/// - y (array): intervalle `(y0, y1)`.
/// - pas (int, float, array): écart entre deux traits, ou `(pas-x, pas-y)`. Défaut : `1`.
#let quadrillage(x: (-1, 5), y: (-1, 4), pas: 1) = _b.elem("quadrillage", (g, ctx) => {
  let (x0, x1) = x
  let (y0, y1) = y
  let (px, py) = if type(pas) == array { pas } else { (pas, pas) }
  let multiples(lo, hi, p) = range(int(calc.ceil(lo / p - 1e-9)), int(calc.floor(hi / p + 1e-9)) + 1).map(k => k * p)
  _r.segments(
    multiples(x0, x1, px).map(v => ((v, y0), (v, y1))) + multiples(y0, y1, py).map(v => ((x0, v), (x1, v))),
    stroke: (paint: g.couleur-grille, thickness: g.epaisseur-fine),
  )
})

#let _axe(g, a, b, couleur) = {
  let c = _b.couleur-de(g, couleur, "axe")
  _r.fleche(a, b, stroke: (paint: c, thickness: g.epaisseur), mark: (end: g.fleche, fill: c))
}

/// Axe : trait fléché de `a` vers `b`, à l'épaisseur et à la flèche des repères (droite graduée, axe oblique…).
///
/// - a (array): origine.
/// - b (array): extrémité (côté flèche).
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
#let axe(a, b, couleur: auto) = _b.elem("axe", (g, ctx) => {
  verifier-point(a, "axe", "a")
  verifier-point(b, "axe", "b")
  _axe(g, a, b, couleur)
})

/// Deux axes fléchés qui se coupent en (0, 0), sans graduations ni quadrillage (voir `repere`).
///
/// - x (array): intervalle `(x0, x1)` de l'axe horizontal.
/// - y (array): intervalle `(y0, y1)` de l'axe vertical.
/// - couleur (auto, str, color): couleur. Défaut : `auto`.
#let axes(x: (-1, 5), y: (-1, 4), couleur: auto) = _b.elem("axes", (g, ctx) => {
  _axe(g, (x.at(0), 0), (x.at(1), 0), couleur)
  _axe(g, (0, y.at(0)), (0, y.at(1)), couleur)
})
