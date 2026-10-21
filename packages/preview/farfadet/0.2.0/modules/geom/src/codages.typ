// codages.typ (farfadet-geom) — codages de figure : égalité de longueurs, angle droit, angle marqué, parallèles.
// Chaque codage existe en deux versions : un constructeur `_…` (appelé aussi par les constructions) et la macro publique.

#import "@preview/cetz:0.5.3": draw as d
#import "rapide.typ" as _r
#import "base.typ": *

#let _ecart-codage = 2.4pt

/// Traits de codage au milieu de `[a b]` (égalité de longueurs).
#let _codage-segment(g, ctx, a, b, n, c) = {
  let m = milieu(a, b)
  let v = unitaire(retrancher(b, a), cmd: "codage-segment")
  let nv = perpendiculaire(v)
  let demi = u(ctx, g.taille-codage)
  let ecart = u(ctx, _ecart-codage)
  for k in range(n) {
    let p = ajouter(m, multiplier(v, (k - (n - 1) / 2) * ecart))
    _r.ligne(
      ajouter(p, multiplier(nv, demi)),
      retrancher(p, multiplier(nv, demi)),
      stroke: (paint: c, thickness: g.epaisseur),
    )
  }
}

/// Carré d'angle droit en `s` entre les directions `s→a` et `s→b`.
#let _angle-droit(g, ctx, s, a, b, c, taille, cmd) = {
  let t = u(ctx, if taille == auto { g.taille-angle-droit } else { taille })
  let u1 = unitaire(retrancher(a, s), cmd: cmd)
  let u2 = unitaire(retrancher(b, s), cmd: cmd)
  if calc.abs(produit-scalaire(u1, u2)) > 0.05 {
    panic(cmd + " : les directions (sommet, a) et (sommet, b) ne sont pas perpendiculaires : l'angle n'est pas droit.")
  }
  _r.ligne(
    ajouter(s, multiplier(u1, t)),
    ajouter(s, multiplier(ajouter(u1, u2), t)),
    ajouter(s, multiplier(u2, t)),
    stroke: (paint: c, thickness: g.epaisseur),
  )
}

/// Arc(s) d'angle marqué en `s` entre `s→a` et `s→b` (angle géométrique, de 0° à 180°).
#let _angle-marque(g, ctx, s, a, b, n, valeur, rayon, c, cmd) = {
  let a0 = angle-du-vecteur(unitaire(retrancher(a, s), cmd: cmd)) / 1deg
  let a1 = angle-du-vecteur(unitaire(retrancher(b, s), cmd: cmd)) / 1deg
  let delta = calc.rem-euclid(a1 - a0, 360)
  if delta > 180 {
    a0 = a1
    delta = 360 - delta
  }
  let r = u(ctx, if rayon == auto { g.rayon-angle } else { rayon })
  let ecart = u(ctx, _ecart-codage + 0.8pt)
  for k in range(n) {
    let rk = r + k * ecart
    d.arc(
      ajouter(s, multiplier(direction-angle(a0 * 1deg), rk)),
      start: a0 * 1deg,
      delta: delta * 1deg,
      radius: rk,
      stroke: (paint: c, thickness: g.epaisseur),
    )
  }
  if valeur != none {
    let am = (a0 + delta / 2) * 1deg
    let rv = r + (n - 1) * ecart
    _r.contenu(
      ajouter(s, multiplier(direction-angle(am), rv)),
      texte-geom(g, c, valeur),
      anchor: ancre-de(am, cmd),
      padding: g.espace-etiquette / 2,
    )
  }
}

/// Chevrons « >> » de parallélisme au milieu de `[a b]`, dans le sens `a → b`.
#let _codage-parallele(g, ctx, a, b, n, c) = {
  let m = milieu(a, b)
  let v = unitaire(retrancher(b, a), cmd: "codage-parallele")
  let nv = perpendiculaire(v)
  let h = u(ctx, g.taille-codage * 1.3)
  let ecart = u(ctx, _ecart-codage + 2.5pt)
  for k in range(n) {
    let pointe = ajouter(m, multiplier(v, (k - (n - 1) / 2) * ecart + h / 2))
    _r.ligne(
      ajouter(retrancher(pointe, multiplier(v, h)), multiplier(nv, h)),
      pointe,
      retrancher(retrancher(pointe, multiplier(v, h)), multiplier(nv, h)),
      stroke: (paint: c, thickness: g.epaisseur),
    )
  }
}

// ---------- Macros publiques ----------

/// Traits de codage au milieu d'un segment : 1, 2 ou 3 traits pour distinguer des longueurs égales.
///
/// - a (array): première extrémité `(x, y)`.
/// - b (array): seconde extrémité `(x, y)`.
/// - n (int): nombre de traits (1, 2 ou 3). Défaut : `1`.
/// - couleur (auto, str, color): couleur du codage. Défaut : `auto` (couleur principale).
#let codage-segment(a, b, n: 1, couleur: auto) = elem("codage-segment", (g, ctx) => {
  verifier-point(a, "codage-segment", "a")
  verifier-point(b, "codage-segment", "b")
  verifier-codage(n, "codage-segment")
  _codage-segment(g, ctx, a, b, n, couleur-de(g, couleur, "codage-segment"))
})

/// Marque d'angle droit (petit carré) au sommet, entre les deux côtés `sommet→a` et `sommet→b`.
///
/// - sommet (array): sommet de l'angle.
/// - a (array): un point du premier côté.
/// - b (array): un point du second côté.
/// - taille (auto, length): côté du carré. Défaut : `auto` (clé `taille-angle-droit`).
/// - couleur (auto, str, color): couleur du codage.
#let angle-droit(sommet, a, b, taille: auto, couleur: auto) = elem("angle-droit", (g, ctx) => {
  verifier-point(sommet, "angle-droit", "sommet")
  verifier-point(a, "angle-droit", "a")
  verifier-point(b, "angle-droit", "b")
  _angle-droit(g, ctx, sommet, a, b, couleur-de(g, couleur, "angle-droit"), taille, "angle-droit")
})

/// Angle marqué par un arc (simple, double ou triple), avec une valeur facultative.
///
/// - sommet (array): sommet de l'angle.
/// - a (array): un point du premier côté.
/// - b (array): un point du second côté.
/// - n (int): nombre d'arcs (1, 2 ou 3). Défaut : `1`.
/// - valeur (none, content): texte écrit à côté de l'arc, par exemple `$60°$`. Défaut : `none`.
/// - rayon (auto, length, int, float): rayon de l'arc intérieur. Défaut : `auto` (clé `rayon-angle`).
/// - couleur (auto, str, color): couleur de l'arc.
#let angle-marque(sommet, a, b, n: 1, valeur: none, rayon: auto, couleur: auto) = elem("angle-marque", (g, ctx) => {
  verifier-point(sommet, "angle-marque", "sommet")
  verifier-point(a, "angle-marque", "a")
  verifier-point(b, "angle-marque", "b")
  verifier-codage(n, "angle-marque")
  _angle-marque(g, ctx, sommet, a, b, n, valeur, rayon, couleur-de(g, couleur, "angle-marque"), "angle-marque")
})

/// Chevrons de parallélisme sur un segment : un segment par famille de parallèles (1, 2 ou 3 chevrons).
///
/// - a (array): première extrémité, qui donne le sens des chevrons.
/// - b (array): seconde extrémité.
/// - n (int): nombre de chevrons (1, 2 ou 3). Défaut : `1`.
/// - couleur (auto, str, color): couleur du codage.
#let codage-parallele(a, b, n: 1, couleur: auto) = elem("codage-parallele", (g, ctx) => {
  verifier-point(a, "codage-parallele", "a")
  verifier-point(b, "codage-parallele", "b")
  verifier-codage(n, "codage-parallele")
  _codage-parallele(g, ctx, a, b, n, couleur-de(g, couleur, "codage-parallele"))
})
