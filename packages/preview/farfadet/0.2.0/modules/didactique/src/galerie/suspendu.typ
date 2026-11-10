// suspendu.typ — skin intégré « suspendu » (emblème suspendu), pour tous les environnements de
// farfadet-didactique.
//
// Concept : tout le bloc est en retrait (1,2 cm). Dans ce retrait, un emblème rond (un disque de la teinte
//   portant une icône blanche, à peu près deux lignes de haut) pend à la hauteur de la première ligne,
//   cap alignée. Un filet vertical, de la teinte assombrie, borde le retrait : il dit l'étendue du bloc.
//   Pas de cadre, pas de fond, pas de double filet. Le corps se coupe normalement entre deux pages.
// Origine : gagnant du concours Théorème (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "cle") : nom d'une icône du jeu commun (dessinée en blanc dans le disque), fonction
//     `couleur => contenu`, contenu ou `none` (disque seul) ;
//   - `epaisseur` (défaut 1pt) : filet vertical ;
//   - `retrait` (défaut 1.2cm) : largeur du retrait de l'emblème.
//   Les clés `couleur`, `colback` (fond), `colframe` (filet), `coltitle` (encre du titre) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Theoreme", rendu: "suspendu")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, options-skin

#let skin(d) = {
  let o = options-skin(d, "suspendu", (icone: "cle", epaisseur: 1pt, retrait: 1.2cm))
  let teinte = d.couleur
  let encre = if d.couleur-titre == auto { teinte.darken(10%) } else { d.couleur-titre }
  // filet assombri : bien visible, y compris avec une teinte claire
  let filet = if d.cadre == auto { teinte.darken(20%) } else { d.cadre }
  let rayon = 0.46cm

  // emblème : disque plein et icône blanche (sans icône : disque seul)
  let embleme = {
    let choix = d.options.at("icone", default: auto)
    if d.icone == none and choix == none {
      box(circle(radius: rayon, fill: teinte.darken(30%), stroke: none))
    } else {
      choisir-icone(d, "cle", taille: 2 * rayon, couleur: teinte, pastille: true)
    }
  }

  let tete = {
    if d.nom != none { text(fill: encre, weight: "bold", smallcaps(d.nom)) }
    if d.numero != none { text(fill: encre, weight: "bold", " " + d.numero) }
    if d.titre != none {
      if d.nom != none or d.numero != none { text(fill: encre, weight: "bold", " — ") }
      text(weight: "bold", size: 1.1em, d.titre)
    }
  }

  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1.2em } else { d.avant },
    below: if d.apres == auto { 1.2em } else { d.apres },
    fill: if d.fond == auto { none } else { d.fond },
    {
      grid(
        columns: (o.retrait - 0.2cm, 1fr),
        column-gutter: 0pt,
        // colonne du retrait : l'emblème en haut, le filet sur le bord droit de la colonne
        grid.cell(
          stroke: (right: o.epaisseur + filet),
          align(top + center, embleme),
        ),
        // colonne du texte : tête puis corps, décalés de 0,2 cm pour que le texte commence au retrait
        grid.cell(
          inset: (left: 0.2cm, right: 0pt, top: 0pt, bottom: 0pt),
          {
            tete
            parbreak()
            d.corps
          },
        ),
      )
    },
  )
}
