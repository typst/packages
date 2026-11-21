// points.typ (farfadet-socle) — machinerie des points (barème) : \tcbitempoint, \displayitempoints,
// totaux. Lu par farfadet-exo, farfadet-enum, farfadet-qcm
// (les points vivent dans le socle, le QCM reste indépendant des exercices).

#import "precoce.typ": bf-etat, bf-maj, bf-lire
#import "couleurs.typ": xcolor
#import "etat.typ": ptl
#import "mesures.typ": bf-largeur-ligne, bf-gauche-ligne, bf-marge-page, bf-largeur-texte, bf-conteneur-ici

/// Points cumulés : total du document et total de l'exercice en cours (remis à zéro par exo.typ).
#let bf-points = state("bf-points", (total: 0, exo: 0))

/// \displayitempointstrue / \displayitempointsfalse (faux par défaut, comme bfcours).
#let bf-afficher-points-p = bf-etat("bf-afficher-points", false)
#let bf-afficher-points = bf-afficher-points-p.etat
#let displayitempointstrue() = bf-maj(bf-afficher-points-p, true)
#let displayitempointsfalse() = bf-maj(bf-afficher-points-p, false)
#let displayitempoints(valeur) = bf-maj(bf-afficher-points-p, valeur)

/// Nombre à la française : 2.5 → « 2,5 », 3.0 → « 3 ».
#let bf-nombre(n) = {
  let s = str(n)
  if s.ends-with(".0") { s = s.slice(0, -2) }
  s.replace(".", ",").replace("-", "−")
}

/// Libellé « 1 pt », « 0,5 pt », « 2,5 pts » de \tcbitempoint.
#let bf-libelle-points(n) = {
  let unite = if n > 1 { "pts" } else { "pt" }
  // 4,22 pt mesurés sur Utopia 11 pt ; Erewhon est composée à 11,715 pt
  [#bf-nombre(n)#h(0.36em)#unite]
}

/// Boîte de points (nœud TikZ : draw=black, fill=purple!10, rounded corners, inner sep=3pt, minimum width=1cm).
#let _boite-points(n) = {
  let lib = bf-libelle-points(n)
  let haut = measure(text(top-edge: "bounds", bottom-edge: "baseline", lib)).height
  let t = text(top-edge: "bounds", bottom-edge: "bounds", lib)
  let m = measure(t)
  let l = calc.max(m.width + ptl(6), 1cm)
  let boite = box(
    width: l,
    height: m.height + ptl(6),
    fill: xcolor("purple!10"),
    stroke: ptl(0.4) + black,
    radius: ptl(4),
    align(center + horizon, t),
  )
  (boite: boite, largeur: l, haut: haut + ptl(3))
}

/// \tcbitempoint{n}[décalage vertical][décalage horizontal]
/// Ajoute n points au total et, si \displayitempointstrue, pose la boîte « n pts » en surimpression,
/// centrée à \linewidth − 1,6 cm − dx de la position courante (comme le nœud TikZ de bfcours).
/// Les deux espaces parasites de la macro LaTeX sont reproduits (espacement faible : absent en début de ligne).
///
/// La boîte se range dans le conteneur le plus proche (cellule de colonne, boîte, liste en colonnes),
/// ou, à défaut, dans la largeur du texte de la page : on mesure l'abscisse courante et celle du bord
/// gauche du conteneur, donc la boîte tombe au même endroit où que se trouve le `points(…)` dans la ligne.
/// `afficher` : `auto` suit \displayitempoints ; `true` ou `false` l'imposent pour ce seul appel.
/// `dys` (épurage du 07/10/2026 : ancien \dystcbitempoint) : variante DYS, décalée de 2 cm vers la
/// gauche ; `dx: auto` (défaut) vaut 0 cm, ou 2 cm si `dys` est vrai ; un `dx` explicite l'emporte.
#let tcbitempoint(points, dy: 0pt, dx: auto, dys: false, afficher: auto) = {
  let dx = if dx == auto { if dys { 2cm } else { 0cm } } else { dx }
  // deux espaces de 0,3 em (7 pt pour 11,7 pt) ; hors `context` et avant la mise à jour de l'état,
  // sinon l'espacement faible ne disparaît plus en début de paragraphe
  h(0.6em, weak: true)
  context {
    if if afficher == auto { bf-lire(bf-afficher-points-p) } else { afficher } {
      let (x0, largeur) = bf-conteneur-ici()
      let ici = here().position().x
      let b = _boite-points(points)
      box(width: 0pt, height: 0pt, place(
        top + left,
        dx: x0 + largeur - 1.6cm - dx - b.largeur / 2 - ici,
        dy: -b.haut - dy,
        b.boite,
      ))
    }
  }
  bf-points.update(p => p + (total: p.total + points, exo: p.exo + points))
}

/// Boîte « n pts » en ligne (sans placement), pour les QCM et les vrai-faux, où le contenu est déjà
/// dans une cellule de largeur connue. À appeler dans un `context`.
#let bf-boite-points-en-ligne(points) = _boite-points(points).boite

/// \getsavedtotalpoints : total des points du document (suivi d'un \phantom{A}).
/// (La macro LaTeX commence par un saut de ligne : d'où l'espace qui précède le nombre.)
#let getsavedtotalpoints() = context [ #bf-nombre(bf-points.final().total)#hide[A]]
