// cadre.typ (farfadet-geom) — le canevas : `geo` pose le style de farfadet-geom puis dessine ; `figure-geo` ajoute une légende.

#import "@preview/cetz:0.5.3": draw as d
#import "rendu.typ": canevas
#import "reglages.typ": reglages-geom
#import "outils.typ": est-nombre, verifier-fenetre

/// Canevas cetz aux couleurs de bfcours. Le corps appelle les macros du paquet (`repere`, `point`, `segment`…) ;
/// une instruction cetz (`d.line`, `d.content`…) y reste possible, avec `import cetz.draw`.
///
/// ```example
/// #geo({
///   repere(x: (-1, 4), y: (-1, 3))
///   segment((0, 0), (3, 2))
///   point((3, 2), "A", pos: "ne")
/// })
/// ```
///
/// - corps (content): suite de macros de dessin, dans un bloc de code `{ … }`.
/// - unite (length): longueur d'une unité du repère. Défaut : `1cm`.
/// - fenetre (none, array): `((xmin, ymin), (xmax, ymax))`, utilisée par `droite`, `demi-droite`, `courbe` si aucun repère n'est tracé. Défaut : `none`.
/// -> content
#let geo(corps, unite: 1cm, fenetre: none) = {
  if type(unite) != length { panic("geo : « unite » attend une longueur (1cm, 0.8cm…) ; reçu : " + repr(unite) + ".") }
  if fenetre != none { verifier-fenetre(fenetre, "geo") }
  context {
    let g = reglages-geom()
    canevas(length: unite, {
      d.set-ctx(c => {
        c.insert("bfgeom", g)
        c.insert("bfgeom-fenetre", fenetre)
        c
      })
      d.set-style(stroke: (paint: g.couleur, thickness: g.epaisseur), mark: (fill: g.couleur))
      // style de référence des éléments courts (rapide.typ) : un set-style ultérieur les renvoie à cetz
      d.set-ctx(c => {
        c.insert("bfgeom-style", c.style)
        c
      })
      corps
    })
  }
}

/// Figure légendée (`figure`) contenant un `geo`. Même arguments que `geo`, plus la légende.
///
/// - corps (content): suite de macros de dessin.
/// - legende (none, content): légende de la figure. Défaut : `none`.
/// - unite (length): longueur d'une unité du repère. Défaut : `1cm`.
/// - fenetre (none, array): fenêtre de la figure. Défaut : `none`.
/// -> content
#let figure-geo(corps, legende: none, unite: 1cm, fenetre: none) = figure(
  geo(corps, unite: unite, fenetre: fenetre),
  caption: legende,
)
