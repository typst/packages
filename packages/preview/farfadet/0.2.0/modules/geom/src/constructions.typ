// constructions.typ (farfadet-geom) — constructions usuelles tracées : médiatrice, bissectrice, hauteur.
// Les calculs sans dessin (`milieu`, `projete`, `intersection`, `distance`) sont dans outils.typ.

#import "@preview/cetz:0.5.3": draw as d
#import "rapide.typ" as _r
#import "base.typ": *
#import "codages.typ": _angle-droit, _angle-marque, _codage-segment

/// Extrémités d'un trait de construction porté par `centre + t * dir` : demi-longueur `longueur`
/// (nombre en unités de la figure, longueur Typst, `auto` = `defaut`) ou `"fenetre"` (bords de la fenêtre).
#let _etendue(ctx, centre, dir, longueur, defaut, cmd) = {
  if longueur == "fenetre" {
    let f = fenetre-de(ctx)
    if f == none {
      panic(cmd + " : longueur: \"fenetre\" demande une fenêtre ; donner fenetre: ((xmin, ymin), (xmax, ymax)) à geo(…) ou employer repere(…).")
    }
    let m = couper(centre, dir, fenetre-valide(f, cmd))
    if m == none { (centre, centre) } else { m }
  } else {
    let l = if longueur == auto { defaut } else if type(longueur) == length { u(ctx, longueur) } else if est-nombre(longueur) and longueur > 0 { longueur } else {
      panic(cmd + " : « longueur » attend auto, \"fenetre\", un nombre positif ou une longueur ; reçu : " + repr(longueur) + ".")
    }
    (retrancher(centre, multiplier(dir, l)), ajouter(centre, multiplier(dir, l)))
  }
}

/// Médiatrice de `[a b]`, avec son codage (deux moitiés égales et angle droit au milieu).
///
/// - a (array): première extrémité.
/// - b (array): seconde extrémité.
/// - longueur (auto, int, float, length, str): demi-longueur du tracé de chaque côté du milieu ; `"fenetre"` prolonge jusqu'aux bords de la fenêtre. Défaut : `auto` (80 % de `[a b]`).
/// - codage (bool): trace les traits d'égalité et l'angle droit. Défaut : `true`.
/// - couleur (auto, str, color): couleur. Défaut : `"vert"`.
/// - style (str): style du trait. Défaut : `"tirets"`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
#let mediatrice(a, b, longueur: auto, codage: true, couleur: "vert", style: "tirets", epaisseur: auto) = elem("mediatrice", (g, ctx) => {
  verifier-point(a, "mediatrice", "a")
  verifier-point(b, "mediatrice", "b")
  let m = milieu(a, b)
  let v = unitaire(retrancher(b, a), cmd: "mediatrice")
  let nv = perpendiculaire(v)
  let (p0, p1) = _etendue(ctx, m, nv, longueur, 0.8 * distance(a, b), "mediatrice")
  let st = trait(g, "mediatrice", couleur: couleur, epaisseur: epaisseur, style: style)
  _r.ligne(p0, p1, stroke: st)
  if codage {
    let c = g.couleur
    _codage-segment(g, ctx, a, m, 1, c)
    _codage-segment(g, ctx, m, b, 1, c)
    _angle-droit(g, ctx, m, b, ajouter(m, nv), c, auto, "mediatrice")
  }
})

/// Bissectrice de l'angle `a sommet b`, tracée depuis le sommet, avec les deux angles marqués.
///
/// - sommet (array): sommet de l'angle.
/// - a (array): un point du premier côté.
/// - b (array): un point du second côté.
/// - longueur (auto, int, float, length): longueur de la demi-droite tracée. Défaut : `auto` (moyenne des deux côtés).
/// - codage (bool): marque les deux angles égaux par un arc. Défaut : `true`.
/// - couleur (auto, str, color): couleur. Défaut : `"bleu"`.
/// - style (str): style du trait. Défaut : `"tirets"`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
#let bissectrice(sommet, a, b, longueur: auto, codage: true, couleur: "bleu", style: "tirets", epaisseur: auto) = elem("bissectrice", (g, ctx) => {
  verifier-point(sommet, "bissectrice", "sommet")
  verifier-point(a, "bissectrice", "a")
  verifier-point(b, "bissectrice", "b")
  let u1 = unitaire(retrancher(a, sommet), cmd: "bissectrice")
  let u2 = unitaire(retrancher(b, sommet), cmd: "bissectrice")
  let somme = ajouter(u1, u2)
  let dir = if norme(somme) < 1e-9 { perpendiculaire(u1) } else { unitaire(somme, cmd: "bissectrice") }
  let l = if longueur == auto {
    (distance(sommet, a) + distance(sommet, b)) / 2
  } else if type(longueur) == length { u(ctx, longueur) } else if est-nombre(longueur) and longueur > 0 { longueur } else {
    panic("bissectrice : « longueur » attend auto, un nombre positif ou une longueur ; reçu : " + repr(longueur) + ".")
  }
  let fin = ajouter(sommet, multiplier(dir, l))
  let st = trait(g, "bissectrice", couleur: couleur, epaisseur: epaisseur, style: style)
  _r.ligne(sommet, fin, stroke: st)
  if codage {
    _angle-marque(g, ctx, sommet, a, fin, 1, none, auto, g.couleur, "bissectrice")
    _angle-marque(g, ctx, sommet, fin, b, 1, none, auto, g.couleur, "bissectrice")
  }
})

/// Hauteur issue de `a` dans le triangle `a b c` : segment de `a` à son projeté sur `(b c)`, avec l'angle droit
/// et, si le pied sort du segment `[b c]`, le prolongement de `(b c)` en pointillés.
///
/// - a (array): sommet d'où part la hauteur.
/// - b (array): première extrémité du côté opposé.
/// - c (array): seconde extrémité du côté opposé.
/// - codage (bool): trace l'angle droit au pied. Défaut : `true`.
/// - couleur (auto, str, color): couleur. Défaut : `"rouge"`.
/// - style (str): style du trait. Défaut : `"tirets"`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto`.
#let hauteur(a, b, c, codage: true, couleur: "rouge", style: "tirets", epaisseur: auto) = elem("hauteur", (g, ctx) => {
  verifier-point(a, "hauteur", "a")
  verifier-point(b, "hauteur", "b")
  verifier-point(c, "hauteur", "c")
  let pied = projete(a, b, c)
  let st = trait(g, "hauteur", couleur: couleur, epaisseur: epaisseur, style: style)
  _r.ligne(a, pied, stroke: st)
  let t = produit-scalaire(retrancher(pied, b), retrancher(c, b)) / calc.pow(distance(b, c), 2)
  if t < -1e-9 or t > 1 + 1e-9 {
    let proche = if t < 0 { b } else { c }
    _r.ligne(proche, pied, stroke: trait(g, "hauteur", couleur: "gris", epaisseur: g.epaisseur-fine, style: "pointilles"))
  }
  if codage and distance(a, pied) > 1e-9 {
    let loin = if distance(pied, b) > distance(pied, c) { b } else { c }
    _angle-droit(g, ctx, pied, a, loin, g.couleur, auto, "hauteur")
  }
})
