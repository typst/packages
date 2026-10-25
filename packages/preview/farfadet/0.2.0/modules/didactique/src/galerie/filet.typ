// filet.typ — skin intégré « filet » (légende dans le filet), pour tous les environnements de
// farfadet-didactique.
//
// Concept : un cadre fin à coins arrondis. L'icône, le nom, le numéro et le titre sont logés dans une
//   interruption du filet supérieur, à gauche, comme la légende d'un fieldset HTML : le filet s'arrête avant
//   l'icône et reprend après la fin du texte de la première ligne. L'en-tête ne prend aucune ligne en plus.
//   Une légende sur deux lignes se prolonge DANS le cadre, en retrait suspendu : seul le texte de la
//   première ligne masque le filet.
// Sécable : aucun `layout` (la largeur vient de la sonde de commun.typ). La place de la légende est réservée
//   dans le corps, donc sur le premier morceau seulement : une suite de page n'a aucun vide en haut.
// Origine : gagnant du concours Théorème (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "etoile") : nom d'une icône du jeu commun, fonction `couleur => contenu`, contenu ou `none` ;
//   - `epaisseur` (défaut 0.7pt) : filet du cadre ;
//   - `rayon` (défaut 5pt) : coins arrondis.
//   Les clés `couleur`, `colback` (fond), `colframe` (filet), `coltitle` (encre du titre) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Theoreme", rendu: "filet")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, options-skin

#let skin(d) = {
  let o = options-skin(d, "filet", (icone: "etoile", epaisseur: 0.7pt, rayon: 5pt))
  let trait = if d.cadre == auto { d.couleur } else { d.cadre }
  let encre = if d.couleur-titre == auto { black } else { d.couleur-titre }
  let fond-legende = if d.fond == auto { white } else { d.fond }
  // `avec-fond` : couche du dessous. L'icône n'est pas du texte, donc `highlight` ne la masque pas : on la
  // pose sur un fond opaque (outset) pour que le filet ne la traverse jamais (loupe, clé, etc.).
  let contenu(avec-fond) = {
    let marque = choisir-icone(d, "etoile", taille: 0.9em, couleur: trait)
    if marque != none {
      if avec-fond { box(fill: fond-legende, outset: (x: 0.25em, y: 0.2em), marque) } else { marque }
      h(0.35em)
    }
    if d.nom != none { text(fill: trait, weight: "bold", smallcaps(d.nom)) }
    if d.numero != none { text(fill: trait, weight: "bold", " " + d.numero) }
    if d.titre != none { text(fill: encre, weight: "bold", size: 1.05em, [ — #d.titre]) }
  }
  // Légende : retrait suspendu (une légende sur deux lignes reste alignée sur le titre). Deux couches
  // superposées, de coupure identique : dessous, le texte sur son fond blanc (`highlight` ne masque le filet
  // que là où il y a du texte, mais le fond d'un morceau déborde de `extent` sur son voisin) ; dessus, le
  // même texte seul, qui reste net.
  let legende(avec-fond) = par(hanging-indent: 1.2em, if avec-fond {
    highlight(fill: fond-legende, extent: 0.25em, contenu(true))
  } else { contenu(false) })

  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1em } else { d.avant },
    below: if d.apres == auto { 0.9em } else { d.apres },
    fill: if d.fond == auto { none } else { d.fond },
    stroke: o.epaisseur + trait,
    radius: o.rayon,
    inset: (x: 1.1em, top: 0.55em, bottom: 0.9em),
    {
      layout(taille => {
        let em = 1em.to-absolute()
        let lw = taille.width
        let h1 = measure(text("Ag")).height          // hauteur d'une ligne : le filet passe en son milieu
        let hauteur = calc.max(h1, measure(block(width: lw, legende(false))).height)
        // la légende déborde d'une demi-ligne au-dessus du filet ; le reste (lignes suivantes) est dans le
        // cadre : la place est réservée dans le corps (premier morceau seulement)
        let reserve = calc.max(0pt, hauteur - h1 / 2 + 0.5 * em - 0.55 * em)
        place(top + left, dx: -0.2 * em, dy: -(0.55 * em + h1 / 2), block(width: lw, legende(true)))
        place(top + left, dx: -0.2 * em, dy: -(0.55 * em + h1 / 2), block(width: lw, legende(false)))
        v(reserve)
        d.corps
      })
    },
  )
}
