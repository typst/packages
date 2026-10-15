// cahier.typ — skin intégré « cahier » (cahier d'élève annoté), pour tous les environnements de
// bfcours-didactique.
//
// Concept : une page de cahier relue au surligneur. Pas de cadre ni de bandeau : le nom du type est
//   surligné, le titre est surligné et souligné d'un trait ondulé, une icône marque l'importance et un
//   filet de stylo court à gauche du corps. Compact, sans élément décoratif superflu.
// Origine : gagnant du concours Définition (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "etoile5") : nom d'une icône du jeu commun, fonction `couleur => contenu`, contenu ou `none` ;
//   - `epaisseur` (défaut 1.3pt) : épaisseur du filet gauche.
//   Les clés `couleur`, `colback` (fond), `colframe` (filet), `coltitle` (encre) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Definition", rendu: "cahier")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, options-skin

// Surligneur : aplat translucide, en ligne, coupé avec le texte.
#let surligneur(contenu, coul) = highlight(
  fill: coul.transparentize(62%),
  top-edge: "ascender",
  bottom-edge: "descender",
  extent: 0.12em,
  radius: 2pt,
  contenu,
)

// Un motif d'ondulation de 7 pt de long, répété le long du soulignement. Le soulignement est un
// vrai attribut du texte : il reprend à chaque ligne et ne dépasse jamais de la colonne.
#let ondulation(coul) = tiling(
  size: (7pt, 2.4pt),
  curve(
    stroke: 0.8pt + coul,
    curve.move((0pt, 1.7pt)),
    curve.quad((1.75pt, 0.2pt), (3.5pt, 1.2pt)),
    curve.quad((5.25pt, 2.2pt), (7pt, 1.7pt)),
  ),
)

#let ondule(contenu, coul) = underline(
  stroke: (paint: ondulation(coul), thickness: 2.4pt),
  offset: 2.2pt,
  evade: false,
  contenu,
)

#let skin(d) = {
  let o = options-skin(d, "cahier", (icone: "etoile5", epaisseur: 1.3pt))
  let trait = if d.cadre == auto { d.couleur } else { d.cadre }
  let encre = if d.couleur-titre == auto { black } else { d.couleur-titre }
  let coul = d.couleur
  // trait ondulé : plus sombre que l'aplat, pour rester visible avec une teinte claire
  let plume = coul.darken(20%)
  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1.3em } else { d.avant },
    below: if d.apres == auto { 1.3em } else { d.apres },
    fill: if d.fond == auto { none } else { d.fond },
    // filet de stylo à gauche : pas de cadre fermé, seulement une marge marquée
    stroke: (left: o.epaisseur + trait),
    inset: (left: 1.0em, right: 0.3em, y: 0.25em),
    {
      set text(fill: encre)
      set par(justify: false)
      // ligne de tête : icône, nom surligné (avec numéro), titre surligné et souligné.
      // Tout est en ligne, dans un seul paragraphe : le titre long se coupe à la ligne suivante.
      {
        set par(leading: 0.78em)
        let marque = choisir-icone(d, "etoile5", taille: 0.85em, couleur: coul.darken(15%))
        if marque != none { marque + h(0.35em) }
        if d.nom != none { surligneur(text(weight: "bold", smallcaps(d.nom)), coul) }
        if d.numero != none { h(0.25em) + text(weight: "bold", d.numero) }
        if d.titre != none {
          // le joint de mots (U+2060) interdit la coupure entre le tiret et le premier mot du titre
          // (la seule coupure possible est AVANT le tiret, jamais après)
          [ #h(0.1em)—#sym.wj#h(0.35em)]
          ondule(surligneur(d.titre, coul), plume)
        }
      }
      parbreak()
      d.corps
    },
  )
}
