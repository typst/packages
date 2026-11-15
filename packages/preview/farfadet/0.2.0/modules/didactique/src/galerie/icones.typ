// icones.typ (farfadet-didactique) — jeu d'icônes DESSINÉES commun aux skins.
//
// Chaque icône est une forme Typst (courbes, polygones) tracée dans un carré de côté `taille` : aucun
// glyphe de police, donc rien qui dépende de la machine. Toutes sont de la même famille : aplats pleins
// d'une seule teinte, coins arrondis, évidements transparents (le fond de la page reste visible dans le
// trou de la roue ou de la clé).
//
// Les skins reçoivent cette fonction dans `d.outils.icone` (teinte par défaut : `d.couleur`) :
//
//   (d.outils.icone)("cle")                         // une icône du jeu, à la teinte de l'environnement
//   (d.outils.icone)("etoile", taille: 1.2em)       // plus grande
//   (d.outils.icone)("roue", couleur: red)          // d'une autre teinte
//   (d.outils.icone)("fanion", pastille: true)      // en blanc dans un disque plein
//   (d.outils.icone)(none)                          // rien
//
// Contrat et liste des noms : skins/CONTRAT.md.

/// Constante des arcs de cercle en courbes de Bézier cubiques.
#let _kappa = 0.5523

/// Point du carré unité, à l'échelle `s`.
#let _pt(s, x, y) = (s * x, s * y)

/// Point en coordonnées polaires autour de (cx, cy) ; angle en degrés (nombre).
#let _pol(cx, cy, r, a) = (cx + r * calc.cos(a * 1deg), cy + r * calc.sin(a * 1deg))

/// Sous-chemin fermé d'un polygone (composants de `curve`).
#let _poly(s, pts) = {
  let p = pts.map(((x, y)) => _pt(s, x, y))
  (curve.move(p.first()),) + p.slice(1).map(q => curve.line(q)) + (curve.close(),)
}

/// Sous-chemin fermé d'un cercle (quatre arcs de Bézier).
#let _cercle(s, cx, cy, r) = {
  let k = _kappa * r
  (
    curve.move(_pt(s, cx + r, cy)),
    curve.cubic(_pt(s, cx + r, cy + k), _pt(s, cx + k, cy + r), _pt(s, cx, cy + r)),
    curve.cubic(_pt(s, cx - k, cy + r), _pt(s, cx - r, cy + k), _pt(s, cx - r, cy)),
    curve.cubic(_pt(s, cx - r, cy - k), _pt(s, cx - k, cy - r), _pt(s, cx, cy - r)),
    curve.cubic(_pt(s, cx + k, cy - r), _pt(s, cx + r, cy - k), _pt(s, cx + r, cy)),
    curve.close(),
  )
}

/// Aplat plein, contour de même teinte très fin (arrondit les coins), trous par la règle pair-impair.
#let _plein(c, s, ..parts) = curve(
  fill: c,
  fill-rule: "even-odd",
  stroke: (paint: c, thickness: 0.03 * s, join: "round"),
  ..parts,
)

/// Trait épais à bouts ronds.
#let _trait(c, s, epaisseur, ..parts) = curve(
  stroke: (paint: c, thickness: epaisseur * s, cap: "round", join: "round"),
  ..parts,
)

// ---------------------------------------------------------------------------------------------------
// Les glyphes : (couleur, taille) -> curve, dans le carré (0, 0)–(taille, taille).
// ---------------------------------------------------------------------------------------------------

/// Coche ✓.
#let _g-coche(c, s) = _trait(
  c, s, 0.11,
  curve.move(_pt(s, 0.24, 0.52)), curve.line(_pt(s, 0.43, 0.70)), curve.line(_pt(s, 0.76, 0.30)),
)

/// Étoile à quatre branches, pointes effilées.
#let _g-etoile(c, s) = {
  let h = 0.5
  let k = 0.12
  _plein(
    c, s,
    curve.move(_pt(s, h, 0)),
    curve.quad(_pt(s, h + k, h - k), _pt(s, 1, h)),
    curve.quad(_pt(s, h + k, h + k), _pt(s, h, 1)),
    curve.quad(_pt(s, h - k, h + k), _pt(s, 0, h)),
    curve.quad(_pt(s, h - k, h - k), _pt(s, h, 0)),
    // pas de curve.close() : le dernier arc finit déjà au point de départ ; un segment de fermeture de
    // longueur nulle ferait saillir un filament sous le joint rond du contour, au sommet.
  )
}

/// Cœur : deux lobes arrondis et une pointe basse, aplat plein, contour de même teinte.
#let _g-coeur(c, s) = _plein(
  c, s,
  curve.move(_pt(s, 0.5, 0.94)),
  curve.cubic(_pt(s, 0.34, 0.82), _pt(s, 0.03, 0.60), _pt(s, 0.03, 0.31)),
  curve.cubic(_pt(s, 0.03, 0.14), _pt(s, 0.15, 0.05), _pt(s, 0.29, 0.05)),
  curve.cubic(_pt(s, 0.40, 0.05), _pt(s, 0.47, 0.12), _pt(s, 0.5, 0.23)),
  curve.cubic(_pt(s, 0.53, 0.12), _pt(s, 0.60, 0.05), _pt(s, 0.71, 0.05)),
  curve.cubic(_pt(s, 0.85, 0.05), _pt(s, 0.97, 0.14), _pt(s, 0.97, 0.31)),
  curve.cubic(_pt(s, 0.97, 0.60), _pt(s, 0.66, 0.82), _pt(s, 0.5, 0.94)),
)

/// Étoile à cinq branches.
#let _g-etoile5(c, s) = _plein(
  c, s,
  .._poly(s, range(10).map(k => _pol(0.5, 0.55, if calc.rem(k, 2) == 0 { 0.5 } else { 0.21 }, -90 + k * 36))),
)

/// Clé : anneau évidé et tige à deux dents.
#let _g-cle(c, s) = _plein(
  c, s,
  .._cercle(s, 0.27, 0.5, 0.27),
  .._cercle(s, 0.27, 0.5, 0.11),
  .._poly(s, ((0.5, 0.42), (1, 0.42), (1, 0.78), (0.88, 0.78), (0.88, 0.58), (0.82, 0.58), (0.82, 0.72), (0.72, 0.72), (0.72, 0.58), (0.5, 0.58))),
)

/// Roue dentée : huit dents trapézoïdales et un trou central.
#let _g-roue(c, s) = {
  let pts = ()
  for i in range(8) {
    let a = i * 45
    pts += (_pol(0.5, 0.5, 0.35, a - 14), _pol(0.5, 0.5, 0.5, a - 9), _pol(0.5, 0.5, 0.5, a + 9), _pol(0.5, 0.5, 0.35, a + 14), _pol(0.5, 0.5, 0.35, a + 22.5))
  }
  _plein(c, s, .._poly(s, pts), .._cercle(s, 0.5, 0.5, 0.15))
}

/// Implication ⇒ : double tige et pointe.
#let _g-implique(c, s) = _trait(
  c, s, 0.085,
  curve.move(_pt(s, 0.22, 0.43)), curve.line(_pt(s, 0.60, 0.43)),
  curve.move(_pt(s, 0.22, 0.57)), curve.line(_pt(s, 0.60, 0.57)),
  curve.move(_pt(s, 0.54, 0.27)), curve.line(_pt(s, 0.77, 0.50)), curve.line(_pt(s, 0.54, 0.73)),
)

/// Fanion : hampe et pavillon triangulaire.
#let _g-fanion(c, s) = _plein(
  c, s,
  .._poly(s, ((0.17, 0.97), (0.17, 0.04), (0.25, 0.04), (0.25, 0.08), (0.95, 0.30), (0.25, 0.52), (0.25, 0.97))),
)

/// Équerre de dessin : triangle rectangle évidé, angle droit en bas à gauche.
#let _g-equerre(c, s) = _plein(
  c, s,
  .._poly(s, ((0.04, 0.05), (0.04, 0.96), (0.95, 0.96))),
  .._poly(s, ((0.2, 0.42), (0.2, 0.8), (0.58, 0.8))),
)

/// Attention : triangle à coins arrondis et point d'exclamation évidé.
#let _g-attention(c, s) = _plein(
  c, s,
  .._poly(s, ((0.5, 0.05), (0.97, 0.92), (0.03, 0.92))),
  .._poly(s, ((0.455, 0.36), (0.545, 0.36), (0.53, 0.66), (0.47, 0.66))),
  .._poly(s, ((0.46, 0.72), (0.54, 0.72), (0.54, 0.80), (0.46, 0.80))),
)

/// Loupe : anneau et manche.
#let _g-loupe(c, s) = box(width: s, height: s, {
  place(top + left, _plein(c, s, .._cercle(s, 0.42, 0.42, 0.36), .._cercle(s, 0.42, 0.42, 0.23)))
  place(top + left, _trait(c, s, 0.13, curve.move(_pt(s, 0.68, 0.68)), curve.line(_pt(s, 0.9, 0.9))))
})

/// Flèche →.
#let _g-fleche(c, s) = _plein(
  c, s,
  .._poly(s, ((0.04, 0.4), (0.54, 0.4), (0.54, 0.14), (0.96, 0.5), (0.54, 0.86), (0.54, 0.6), (0.04, 0.6))),
)

/// Registre : nom -> (glyphe, disque, echelle).
/// - `disque` : `true` si l'icône se dessine par défaut dans un disque plein (glyphe blanc) ;
/// - `echelle` : taille du glyphe dans le disque, en fraction du disque (quand `pastille: true`).
#let _registre = (
  coche: (glyphe: _g-coche, disque: true, echelle: 1),
  etoile: (glyphe: _g-etoile, disque: false, echelle: 0.7),
  etoile5: (glyphe: _g-etoile5, disque: false, echelle: 0.66),
  coeur: (glyphe: _g-coeur, disque: false, echelle: 0.62),
  cle: (glyphe: _g-cle, disque: false, echelle: 0.72),
  roue: (glyphe: _g-roue, disque: false, echelle: 0.68),
  implique: (glyphe: _g-implique, disque: true, echelle: 1),
  fanion: (glyphe: _g-fanion, disque: false, echelle: 0.62),
  equerre: (glyphe: _g-equerre, disque: false, echelle: 0.6),
  attention: (glyphe: _g-attention, disque: false, echelle: 0.62),
  loupe: (glyphe: _g-loupe, disque: false, echelle: 0.66),
  fleche: (glyphe: _g-fleche, disque: false, echelle: 0.66),
)

/// Noms des icônes du jeu.
#let noms-icones = _registre.keys()

/// Pose un contenu dans le carré de l'icône (la boîte repose légèrement sous la ligne d'écriture).
#let _boite(s, contenu) = box(width: s, height: s, baseline: 0.12 * s, contenu)

/// Dessine l'icône `nom` : un nom du jeu commun, une fonction `couleur => contenu`, un contenu, ou `none`.
///
/// - nom (str, function, content, none): nom d'une icône du jeu (`noms-icones`), ou fonction qui reçoit la teinte et rend un contenu, ou contenu déjà prêt, ou `none` (rien). Un nom inconnu arrête la compilation et liste les noms possibles.
/// - taille (length): côté du carré de l'icône (`1em` : la hauteur d'une ligne).
/// - couleur (color): teinte de l'icône.
/// - pastille (auto, bool): `auto` laisse chaque icône à son dessin naturel (`coche` et `implique` dans un disque plein, les autres en aplat) ; `true` pose le glyphe, en blanc, dans un disque plein de la teinte assombrie ; `false` le dessine seul, à la teinte.
/// -> content
#let icone(nom, taille: 1em, couleur: black, pastille: auto) = {
  if nom == none { return none }
  if type(pastille) != bool and pastille != auto {
    panic("icone : « pastille » attend true, false ou auto ; reçu : " + repr(pastille) + ".")
  }
  let s = taille
  // disque plein, glyphe centré à la fraction `e` du disque
  let dans-disque(e, glyphe) = _boite(s, {
    place(top + left, circle(radius: s / 2, fill: couleur.darken(30%), stroke: none, inset: 0pt))
    place(center + horizon, glyphe(white, s * e))
  })
  if type(nom) == str {
    if nom not in _registre {
      panic(
        "icone : icône inconnue « " + nom + " ». Icônes possibles : " + noms-icones.join(", ")
          + " (ou une fonction couleur => contenu, un contenu, ou none).",
      )
    }
    let e = _registre.at(nom)
    let g(c, t) = box(width: t, height: t, place(top + left, (e.glyphe)(c, t)))
    let disque = if pastille == auto { e.disque } else { pastille }
    if disque { dans-disque(if e.disque { 1 } else { e.echelle }, g) } else { _boite(s, g(couleur, s)) }
  } else if type(nom) == function {
    if pastille == true { dans-disque(0.7, (c, t) => box(width: t, height: t, align(center + horizon, nom(c)))) } else { nom(couleur) }
  } else {
    if pastille == true { dans-disque(0.7, (c, t) => box(width: t, height: t, align(center + horizon, text(fill: c, nom)))) } else { nom }
  }
}
