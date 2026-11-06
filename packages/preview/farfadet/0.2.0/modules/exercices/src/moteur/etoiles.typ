// etoiles.typ (farfadet-exo) — \rdexostars[options]{niveau}{total} (rdexo.sty l. 2090-2194).
//
// Étoiles TikZ (star points=5, star point ratio=2.25, inner sep=0.15em) espacées de 1 em ; une étoile
// partielle est remplie sur la fraction de sa largeur (mode horizontal) ou de son aire (mode vertical,
// approximation polynomiale de rdexo). Réglages : registre « rdexostars » (`setrdexo(pour: "rdexostars", …)`,
// ancien \setrdexostars). Une épaisseur de filet nulle supprime le contour (rdexo.sty, septembre 2026).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": bf-etoiles-registre, bf-exo-couleur

/// Dessin brut des étoiles. `em` : quad de la police courante (une longueur absolue).
/// Les couleurs sont des couleurs Typst ; `p` : réglages résolus de rdexostars.
#let _dessin-etoiles(niveau, total, em, p, couleur, fond, filet) = {
  let lw = p.line-width
  let echelle = p.scale
  let r = 0.4525 * em * echelle // rayon extérieur (5,95 pt pour em = 13,15 pt)
  let pas = em * echelle
  let vertical = p.display-mode == "vertical"
  let larg-etoile = 1.902 * r
  let haut-etoile = 1.809 * r
  let l = if vertical { larg-etoile + lw } else { (total - 1) * pas + larg-etoile + lw }
  let h = if vertical { (total - 1) * pas + haut-etoile + lw } else { haut-etoile + lw }
  // étoile i (0 = première) : coin haut-gauche de sa boîte englobante
  let origine(i) = if vertical { (lw / 2, h - lw / 2 - haut-etoile - i * pas) } else { (lw / 2 + i * pas, lw / 2) }
  let etoile(remplissage) = {
    let pts = range(10).map(k => {
      let a = 90deg + k * 36deg
      let rr = if calc.even(k) { r } else { r / 2.25 }
      (0.951 * r + rr * calc.cos(a), r - rr * calc.sin(a))
    })
    polygon(fill: remplissage, stroke: if lw > 0pt { lw + filet } else { none }, ..pts)
  }
  box(width: l, height: h, baseline: lw / 2 - p.raise, {
    for i in range(total) {
      let (x, y) = origine(i)
      let part = calc.min(calc.max(niveau - i, 0), 1)
      place(top + left, dx: x, dy: y, etoile(if part >= 1 { couleur } else { fond }))
      if part > 0 and part < 1 {
        if vertical {
          // rdexo : fraction de hauteur qui donne à peu près la fraction d'aire voulue
          let f = 15.7 * calc.pow(part, 5) - 36.7 * calc.pow(part, 4) + 31.15 * calc.pow(part, 3) - 11.9 * calc.pow(part, 2) + 2.7 * part
          let hv = f * haut-etoile
          place(top + left, dx: x, dy: y + haut-etoile - hv, box(width: larg-etoile, height: hv, clip: true, {
            place(top + left, dy: -(haut-etoile - hv), etoile(couleur))
          }))
        } else {
          place(top + left, dx: x, box(width: part * larg-etoile, height: h, clip: true, {
            place(top + left, dy: y, etoile(couleur))
          }))
        }
      }
    }
  })
}

/// \rdexostars[options]{niveau}{total}. `em` : auto = quad de la police courante.
/// Les clés locales sont celles de setrdexostars. À appeler hors `context` (il en ouvre un).
#let bf-rdexostars(niveau, total, em: auto, ..cles) = context {
  let p = reglages-resoudre(bf-etoiles-registre, local: cles.named(), commande: "rdexostars")
  let em = if em == auto { bf-quad().to-absolute() } else { em }
  let dessin = _dessin-etoiles(
    niveau,
    total,
    em,
    p,
    bf-exo-couleur(p.star-color),
    bf-exo-couleur(p.star-background),
    bf-exo-couleur(p.line-color),
  )
  if not p.show-bg { return dessin }
  // show bg : \tcbox[blankest, nobeforeafter, on line, background]
  let b = p.background + p.background-app
  let fond = bf-exo-couleur(b.at("colback", default: none))
  let fond = if b.at("opacityback", default: 1) == 0 { none } else { fond }
  let cadre = bf-exo-couleur(b.at("colframe", default: none))
  let trait = b.at("boxrule", default: 0pt)
  box(
    fill: fond,
    stroke: if cadre != none and trait > 0pt { trait + cadre } else { none },
    radius: b.at("arc", default: 0pt),
    inset: b.at("boxsep", default: 0pt),
    baseline: -p.raise,
    dessin,
  )
}
