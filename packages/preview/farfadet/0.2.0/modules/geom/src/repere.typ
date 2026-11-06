// repere.typ (farfadet-geom) — repère orthonormé (grille, graduations, axes fléchés) et courbe d'une fonction.

#import "@preview/cetz:0.5.3": draw as d
#import "rapide.typ" as _r
#import "base.typ": *

/// Nombre à la française dans une graduation : `-1`, `0,5`.
#let nombre-math(v) = {
  let s = str(calc.round(v, digits: 6)).replace("−", "-").replace(".", "\",\"")
  eval("$" + s + "$")
}

#let _deux(v, cmd, cle) = {
  let r = if type(v) == array { v } else { (v, v) }
  if r.len() != 2 or not r.all(x => est-nombre(x) and x > 0) {
    panic(cmd + " : « " + cle + " » attend un nombre positif ou un couple de deux nombres positifs ; reçu : " + repr(v) + ".")
  }
  r
}

#let _intervalle(v, cmd, cle) = {
  if type(v) != array or v.len() != 2 or not v.all(est-nombre) or v.at(0) >= v.at(1) {
    panic(cmd + " : « " + cle + " » attend un intervalle (min, max) avec min < max ; reçu : " + repr(v) + ".")
  }
  v
}

/// Multiples de `pas` contenus dans `[lo, hi]`.
#let _multiples(lo, hi, pas) = range(int(calc.ceil(lo / pas - 1e-9)), int(calc.floor(hi / pas + 1e-9)) + 1).map(k => k * pas)

/// Repère orthonormé : grille facultative, axes fléchés, graduations, origine et noms des axes. Il enregistre
/// aussi la fenêtre de la figure, dont se servent `droite`, `demi-droite`, `courbe` et `mediatrice`.
///
/// - x (array): intervalle des abscisses `(min, max)`. Défaut : `(-1, 5)`.
/// - y (array): intervalle des ordonnées `(min, max)`. Défaut : `(-1, 4)`.
/// - grille (bool): quadrillage au pas `pas`. Défaut : `true`.
/// - pas (int, float, array): pas du quadrillage, ou `(pas-x, pas-y)`. Défaut : `1`.
/// - graduations (bool): nombres sous l'axe des abscisses et à gauche de l'axe des ordonnées. Défaut : `true`.
/// - pas-graduation (auto, int, float, array): pas des graduations, ou `(pas-x, pas-y)`. Défaut : `auto` (le pas du quadrillage).
/// - origine (bool): écrit le nom de l'origine. Défaut : `true`.
/// - nom-origine (content): nom de l'origine. Défaut : `$O$`.
/// - noms (array): noms des axes `(nom-x, nom-y)`, ou `(none, none)`. Défaut : `($x$, $y$)`.
/// - couleur (auto, str, color): couleur des axes et des nombres. Défaut : `auto`.
#let repere(
  x: (-1, 5),
  y: (-1, 4),
  grille: true,
  pas: 1,
  graduations: true,
  pas-graduation: auto,
  origine: true,
  nom-origine: $O$,
  noms: ($x$, $y$),
  couleur: auto,
) = {
  let (x0, x1) = _intervalle(x, "repere", "x")
  let (y0, y1) = _intervalle(y, "repere", "y")
  let (px, py) = _deux(pas, "repere", "pas")
  let (gx, gy) = if pas-graduation == auto { (px, py) } else { _deux(pas-graduation, "repere", "pas-graduation") }
  if type(noms) != array or noms.len() != 2 {
    panic("repere : « noms » attend un couple (nom-x, nom-y) ; reçu : " + repr(noms) + ".")
  }
  d.set-ctx(c => {
    c.insert("bfgeom-fenetre", ((x0, y0), (x1, y1)))
    c
  }) + elem("repere", (g, ctx) => {
    let c = couleur-de(g, couleur, "repere")
    let ax = calc.clamp(0, x0, x1)
    let ay = calc.clamp(0, y0, y1)
    let ext = u(ctx, 0.45cm)
    let tic = u(ctx, 2.2pt)
    if grille {
      let st = (paint: g.couleur-grille, thickness: g.epaisseur-fine)
      // tout le quadrillage en un seul élément cetz (un tracé par trait, comme avant)
      _r.segments(
        _multiples(x0, x1, px).map(v => ((v, y0), (v, y1))) + _multiples(y0, y1, py).map(v => ((x0, v), (x1, v))),
        stroke: st,
      )
    }
    let st = (paint: c, thickness: g.epaisseur)
    _r.fleche((x0, ay), (x1 + ext, ay), stroke: st, mark: (end: g.fleche, fill: c))
    _r.fleche((ax, y0), (ax, y1 + ext), stroke: st, mark: (end: g.fleche, fill: c))
    if graduations {
      for v in _multiples(x0, x1, gx) {
        if calc.abs(v) > 1e-9 {
          _r.ligne((v, ay - tic), (v, ay + tic), stroke: st)
          _r.contenu((v, ay - tic), texte-geom(g, c, nombre-math(v)), anchor: "north", padding: 3pt)
        }
      }
      for v in _multiples(y0, y1, gy) {
        if calc.abs(v) > 1e-9 {
          _r.ligne((ax - tic, v), (ax + tic, v), stroke: st)
          _r.contenu((ax - tic, v), texte-geom(g, c, nombre-math(v)), anchor: "east", padding: 3pt)
        }
      }
    }
    if origine and nom-origine != none and x0 <= 0 and 0 <= x1 and y0 <= 0 and 0 <= y1 {
      _r.contenu((ax, ay), texte-geom(g, c, nom-origine), anchor: "north-east", padding: 3pt)
    }
    if noms.at(0) != none {
      _r.contenu((x1 + ext, ay), texte-geom(g, c, nom-math(noms.at(0), "repere")), anchor: "south", padding: 4pt)
    }
    if noms.at(1) != none {
      _r.contenu((ax, y1 + ext), texte-geom(g, c, nom-math(noms.at(1), "repere")), anchor: "west", padding: 4pt)
    }
  })
}

/// Courbe d'une fonction, par échantillonnage : une ligne brisée de `n` points (sans bibliothèque de tracé).
/// Les points hors de la fenêtre en ordonnée sont coupés au bord ; `coupures` interrompt la courbe aux
/// abscisses où la fonction n'est pas définie (par exemple `0` pour `1/x`).
///
/// - f (function): fonction `x => …` qui renvoie un nombre.
/// - x (auto, array): intervalle `(min, max)` du tracé. Défaut : `auto` (l'intervalle des abscisses du repère).
/// - n (int): nombre d'intervalles de l'échantillonnage. Défaut : `150`.
/// - coupures (array): abscisses où interrompre la courbe. Défaut : `()`.
/// - couleur (auto, str, color): couleur. Défaut : `"bleu"`.
/// - epaisseur (auto, length): épaisseur du trait. Défaut : `auto` (clé `epaisseur-forte`).
/// - style (str): style du trait. Défaut : `"plein"`.
#let courbe(f, x: auto, n: 150, coupures: (), couleur: "bleu", epaisseur: auto, style: "plein") = elem("courbe", (g, ctx) => {
  if type(f) != function { panic("courbe : le premier argument attend une fonction x => … ; reçu : " + repr(f) + ".") }
  if type(n) != int or n < 2 { panic("courbe : « n » attend un entier au moins égal à 2 ; reçu : " + repr(n) + ".") }
  if type(coupures) != array or not coupures.all(est-nombre) {
    panic("courbe : « coupures » attend un tableau de nombres ; reçu : " + repr(coupures) + ".")
  }
  let fen = fenetre-de(ctx)
  let (a, b) = if x == auto {
    if fen == none {
      panic("courbe : l'intervalle est inconnu ; donner x: (min, max) ou employer repere(…) avant la courbe.")
    }
    (fen.at(0).at(0), fen.at(1).at(0))
  } else { _intervalle(x, "courbe", "x") }
  let st = trait(g, "courbe", couleur: couleur, epaisseur: if epaisseur == auto { g.epaisseur-forte } else { epaisseur }, style: style)
  let bornes = (a,) + coupures.filter(c => c > a and c < b).sorted() + (b,)
  let eps = (b - a) * 1e-4
  // point d'ordonnée au bord de la fenêtre sur le segment [dedans, dehors]
  let croise(dedans, dehors) = {
    let yb = if dehors.at(1) > fen.at(1).at(1) { fen.at(1).at(1) } else { fen.at(0).at(1) }
    let t = (yb - dedans.at(1)) / (dehors.at(1) - dedans.at(1))
    (dedans.at(0) + t * (dehors.at(0) - dedans.at(0)), yb)
  }
  for i in range(bornes.len() - 1) {
    let lo = bornes.at(i) + if i > 0 { eps } else { 0 }
    let hi = bornes.at(i + 1) - if i < bornes.len() - 2 { eps } else { 0 }
    let k = calc.max(2, int(calc.round(n * (hi - lo) / (b - a))))
    let pts = range(k + 1).map(j => {
      let xx = lo + (hi - lo) * j / k
      (xx, f(xx))
    })
    let morceaux = ()
    let cur = ()
    if fen == none { morceaux.push(pts) } else {
      for (j, p) in pts.enumerate() {
        let dedans = fen.at(0).at(1) <= p.at(1) and p.at(1) <= fen.at(1).at(1)
        if dedans {
          if cur.len() == 0 and j > 0 { cur.push(croise(p, pts.at(j - 1))) }
          cur.push(p)
        } else if cur.len() > 0 {
          cur.push(croise(cur.last(), p))
          morceaux.push(cur)
          cur = ()
        }
      }
      if cur.len() > 0 { morceaux.push(cur) }
    }
    for m in morceaux {
      if m.len() >= 2 { _r.ligne(..m, stroke: st) }
    }
  }
})
