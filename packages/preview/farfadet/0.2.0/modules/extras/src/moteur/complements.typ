// complements.typ (moteur de farfadet-extras) — habillage de figures (wrap-it) et icônes (ficons).
//
// MOTEUR : noms STABLES (`habiller`, `icone`), exportés par ../../interne.typ. Les paramètres sont déjà
// résolus (couleurs Typst, longueurs) : les réglages, les clés `auto` et la validation se font dans les
// façades (../habillage.typ, ../icones.typ). `debord` : la figure déborde dans la marge ; `decalage` :
// hauteur d'ancrage des icônes.
//
// Tout ce qui n'est pas un nom public commence par « _ ».

#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/ficons:0.1.0" as _ficons

/// Place une figure sur un côté et fait couler le texte autour (wrap-it).
///
/// - figure (content): ce qui est posé sur le côté.
/// - texte (content): le texte qui l'habille.
/// - cote (str): `"droite"` ou `"gauche"`.
/// - haut (bool): figure en haut (`true`) ou en bas (`false`) du texte.
/// - ecart (length): distance entre la figure et le texte.
/// - largeur (auto, length, relative, fraction): largeur réservée à la colonne de la figure.
/// - debord (length): la figure déborde de cette longueur dans la marge (`\wrapoverhang`).
/// -> content
#let habiller(figure, texte, cote: "droite", haut: true, ecart: 1em, largeur: auto, debord: 0pt) = {
  assert(cote in ("droite", "gauche"), message: "habiller : `cote` doit valoir \"droite\" ou \"gauche\".")
  let horizontal = if cote == "droite" { right } else { left }
  let vertical = if haut { top } else { bottom }
  let options = (column-gutter: ecart)
  if largeur != auto {
    // la colonne de la figure garde la largeur demandée
    options += (columns: if cote == "droite" { (1fr, largeur) } else { (largeur, 1fr) })
  }
  let figure = if debord == 0pt { figure } else if cote == "droite" {
    pad(right: -debord, figure)
  } else { pad(left: -debord, figure) }
  wrap-content(figure, texte, align: vertical + horizontal, ..options)
}

/// Icône Feather en ligne.
///
/// - nom (str): nom de l'icône (liste sur feathericons.com).
/// - couleur (color, none): couleur du trait (`none` : noir).
/// - taille (length): hauteur de l'icône.
/// - epaisseur (int, float): épaisseur du trait (2 par défaut).
/// - decalage (int, float): remontée de l'icône sous la ligne de base, en fraction de `taille` (0,2).
/// -> content
#let icone(nom, couleur: none, taille: 1em, epaisseur: 2, decalage: 0.2) = {
  let sources = _ficons.svg-icons
  assert(nom in sources, message: "icone : l'icône « " + nom + " » n'existe pas (voir feathericons.com).")
  let svg = sources.at(nom)
  if couleur != none {
    svg = svg.replace("stroke=\"currentColor\"", "stroke=\"" + couleur.to-hex() + "\"")
  }
  if epaisseur != 2 {
    svg = svg.replace("stroke-width=\"2\"", "stroke-width=\"" + str(epaisseur) + "\"")
  }
  box(image(bytes(svg), format: "svg"), height: taille, baseline: decalage * taille)
}
