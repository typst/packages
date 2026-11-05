// cases.typ (farfadet-qcm, moteur) — cases à cocher \rdmcqcb et boutons radio \rdmcqrb de rdmcq.
//
// Deux registres de réglages (mécanisme du socle) : « rdmcqcb » (setter LaTeX \setrdmcqcb) et
// « rdmcqrb » (\setrdmcqrb). Clés = options /rdmcqcb/ et /rdmcqrb/ (espaces → tirets).
// Dans une boîte de réponse, la case se coche d'elle-même quand la réponse est juste en mode
// correction (\ifmcqbr) : l'état `bf-mcq-br` le lui dit.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-resoudre-couleur, bf-nommee, reglages-paquet, reglages-resoudre, reglages-controles, reglages-ou, reglages-choix,
)

/// Vrai dans la boîte d'une réponse juste quand le mode correction est actif (\ifmcqbr).
#let bf-mcq-br = state("bf-mcq-br", false)

#let _c = reglages-controles
#let _fond = reglages-ou(_c.couleur, _c.texte, (v => v == none, "none"))
#let _symbole = reglages-ou((v => v == auto, "auto"), _c.contenu, reglages-choix("disc"))

#let _controles = (
  size: _c.longueur,
  color: reglages-ou(_c.couleur, _c.texte),
  raise: _c.longueur,
  check-symbol: _symbole,
  check-color: reglages-ou(_c.couleur, _c.texte),
  checked: _c.booleen,
  background-color: _fond,
)

/// Registre des cases à cocher (\setrdmcqcb) : défauts de rdmcq.sty, l. 1408-1433.
#let registre-rdmcqcb = reglages-paquet(
  "rdmcqcb",
  (
    size: 0.9em,
    color: bf-nommee("black"),
    raise: 0pt,
    check-symbol: auto, // \ding{51} : ✓
    check-color: bf-nommee("red"),
    checked: false,
    background-color: none, // « transparent »
  ),
  controles: _controles,
  commande: "setrdmcq",
)

/// Registre des boutons radio (\setrdmcqrb) : défauts de rdmcq.sty, l. 1478-1498.
#let registre-rdmcqrb = reglages-paquet(
  "rdmcqrb",
  (
    size: 1.3em,
    color: bf-nommee("black"),
    raise: 0pt,
    check-symbol: "disc",
    check-color: bf-nommee("red"),
    checked: false,
    background-color: none,
  ),
  controles: _controles,
  commande: "setrdmcq",
)

/// « transparent » (valeur LaTeX) = pas de fond.
#let _lire-fond(c) = if c == none or c == "transparent" { none } else { bf-resoudre-couleur(c) }

/// Dessin de la case à cocher (r : réglages résolus). À appeler dans un `context`.
/// Carré à filet fin, ombré en bas à droite (tracé de rdmcq.sty, l. 1450-1456), marque centrée.
#let mcq-dessin-cb(r, coche) = {
  let s = r.size.to-absolute()
  let ep = 0.04765886288 * s
  let dx = 0.18979933 * s
  let dy = 0.18812709 * s
  let couleur = bf-resoudre-couleur(r.color)
  let fond = _lire-fond(r.background-color)
  let symbole = if r.check-symbol == auto { "✓" } else { r.check-symbol }
  // origine TikZ (0,0) = coin inférieur gauche du carré ; ligne de base à 0,0477 s au-dessus
  box(width: s + dx, height: s + dy, baseline: ep + dy - r.raise, {
    // ombre : la réunion (carré, carré décalé) moins le carré
    place(top + left, curve(
      fill: couleur,
      stroke: none,
      curve.move((s, dy)),
      curve.line((s + dx, dy)),
      curve.line((s + dx, s + dy)),
      curve.line((dx, s + dy)),
      curve.line((dx, s)),
      curve.line((s, s)),
      curve.close(),
    ))
    // filet du carré, intérieur
    place(top + left, rect(width: s, height: s, fill: none, stroke: none))
    place(top + left, dx: ep / 2, dy: ep / 2, rect(width: s - ep, height: s - ep, fill: fond, stroke: ep + couleur))
    if coche {
      place(top + left, box(width: s, height: s, align(center + horizon, text(fill: bf-resoudre-couleur(r.check-color), symbole))))
    }
  })
}

/// Dessin du bouton radio (r : réglages résolus). À appeler dans un `context`.
/// Anneau (tracé « à main levée » de rdmcq.sty, l. 1512-1529 : rayon ≈ 0,55 taille), disque plein si coché.
#let mcq-dessin-rb(r, coche) = {
  let s = r.size.to-absolute()
  let u = 2 / 7 * s
  let couleur = bf-resoudre-couleur(r.color)
  let fond = _lire-fond(r.background-color)
  // boîte englobante TikZ : x ∈ [-1,82 ; 2,05] u, y ∈ [-2,29 ; 1,97] u ; ligne de base y = -0,34 s
  let (x0, x1, y0, y1) = (-1.82 * u, 2.05 * u, -2.29 * u, 1.97 * u)
  let cx(x) = x - x0
  let cy(y) = y1 - y
  let rayon = 1.94 * u
  let ep = 0.33 * u
  box(width: x1 - x0, height: y1 - y0, baseline: (-0.34 * s) - y0 - r.raise, {
    // centre légèrement décalé, comme le tracé original
    let (ox, oy) = (cx(0.12 * u), cy(-0.16 * u))
    place(top + left, dx: ox - rayon + ep / 2, dy: oy - rayon + ep / 2, circle(
      radius: rayon - ep / 2,
      fill: fond,
      stroke: ep + couleur,
    ))
    if coche {
      let marque = bf-resoudre-couleur(r.check-color)
      if r.check-symbol == "disc" {
        let rd = 1.2 * u
        place(top + left, dx: cx(0pt) - rd, dy: cy(0pt) - rd, circle(radius: rd, fill: marque, stroke: none))
      } else {
        place(top + left, dx: cx(0pt) - 2 * u, dy: cy(0pt) - 2 * u, box(width: 4 * u, height: 4 * u, align(
          center + horizon,
          text(fill: marque, if r.check-symbol == auto { "✓" } else { r.check-symbol }),
        )))
      }
    }
  })
}

/// Case à cocher avec les réglages `registre-rdmcqcb` + clés locales (dictionnaire). Coche automatique
/// dans la boîte d'une réponse juste en mode correction.
#let mcq-cb(local: (:), commande: "rdmcqcb") = context {
  let r = reglages-resoudre(registre-rdmcqcb, local: local, commande: commande)
  mcq-dessin-cb(r, r.checked or bf-mcq-br.get())
}

/// Bouton radio avec les réglages `registre-rdmcqrb` + clés locales.
#let mcq-rb(local: (:), commande: "rdmcqrb") = context {
  let r = reglages-resoudre(registre-rdmcqrb, local: local, commande: commande)
  mcq-dessin-rb(r, r.checked or bf-mcq-br.get())
}
