// cahier.typ — skin intégré « cahier » (cahier d'élève annoté), pour tous les environnements de
// farfadet-didactique.
//
// Concept : une page de cahier annotée au surligneur. Pas de cadre : le nom du type, le numéro et le
//   titre sont écrits en blanc sur un bandeau plein de la couleur de l'environnement (vert pour la
//   Définition, bleu pour la Propriété…), une icône marque l'importance et un filet de stylo court à
//   gauche du corps. Compact, sans élément décoratif superflu.
// Le bandeau épouse son texte ; un titre trop long pour la ligne passe à la ligne suivante dans un
//   bandeau qui occupe alors toute la largeur.
// Origine : gagnant du concours Définition (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "etoile5") : nom d'une icône du jeu commun, fonction `couleur => contenu`, contenu ou `none` ;
//   - `epaisseur` (défaut 1.3pt) : épaisseur du filet gauche.
//   Les clés `couleur` (teinte du bandeau et du filet), `colback` (fond), `colframe` (filet), `coltitle`
//   (encre du bandeau, blanc par défaut) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Definition", rendu: "cahier")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, options-skin

// Texte du bandeau : nom (petites capitales), numéro, tiret, titre.
#let texte-bandeau(d) = {
  if d.nom != none { smallcaps(d.nom) }
  if d.numero != none { h(0.25em) + d.numero }
  if d.titre != none {
    // le joint de mots (U+2060) interdit la coupure entre le tiret et le premier mot du titre
    // (la seule coupure possible est AVANT le tiret, jamais après)
    if d.nom != none or d.numero != none { [ #h(0.1em)—#sym.wj#h(0.35em)] }
    d.titre
  }
}

// Ligne de tête : icône, puis bandeau plein à texte blanc. Un bandeau qui tient sur la ligne épouse son
// texte (`box`) ; sinon il prend le reste de la largeur et le titre se coupe à l'intérieur (`block`).
#let entete(d, coul, encre) = layout(taille => {
  let marque = choisir-icone(d, "etoile5", taille: 0.85em, couleur: coul)
  let pose = if marque != none { marque + h(0.5em) } else { none }
  if d.nom == none and d.titre == none { return pose }
  let garni(contenu) = {
    set text(fill: encre, weight: "bold")
    set par(leading: 0.5em, justify: false)
    contenu
  }
  let rayon = 2pt
  let marge = (x: 0.45em, y: 0.28em)
  let corps = garni(texte-bandeau(d))
  let l-pose = measure(pose).width
  let nature = measure(box(inset: marge, corps)).width
  if l-pose + nature <= taille.width {
    pose + box(fill: coul, inset: marge, radius: rayon, corps)
  } else {
    grid(
      columns: (auto, 1fr),
      pose,
      block(width: 100%, fill: coul, inset: marge, radius: rayon, corps),
    )
  }
})

#let skin(d) = {
  let o = options-skin(d, "cahier", (icone: "etoile5", epaisseur: 1.3pt))
  let trait = if d.cadre == auto { d.couleur } else { d.cadre }
  let encre = if d.couleur-titre == auto { white } else { d.couleur-titre }
  let coul = d.couleur
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
      set par(justify: false)
      entete(d, coul, encre)
      parbreak()
      d.corps
    },
  )
}
