// minimal.typ — skin intégré « minimal » (étiquette et titre, rien d'autre), pour tous les environnements de
// farfadet-didactique.
//
// Concept : aucun filet, aucun cadre, aucune icône. La première ligne porte le nom du type (et son numéro) en
//   gras, de la couleur de l'environnement, puis le titre en gras (noir par défaut) ; le corps suit en dessous,
//   sans retrait. C'est le rendu le plus discret de la galerie : celui des collègues qui ne veulent que
//   l'étiquette et le titre.
// Sécable : un simple bloc, sans `layout`.
// Options (clé `skin:`) :
//   - `icone` (défaut `none`, c'est-à-dire aucune icône) : nom d'une icône du jeu commun, fonction
//     `couleur => contenu` ou contenu, pour la remettre devant le nom.
//   Les clés `couleur` (encre du nom et du numéro), `coltitle` (encre du titre, noir par défaut), `colback`
//   (fond du corps ; sans fond par défaut) sont honorées. `colframe` et `embleme` n'ont pas d'effet : il n'y a
//   ni cadre ni icône par défaut.
// Emploi : #setbfenvironments(pour: "Definition", rendu: "minimal")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": options-skin

#let skin(d) = {
  let o = options-skin(d, "minimal", (icone: none))
  let encre = if d.couleur-titre == auto { black } else { d.couleur-titre }
  let fond = if d.fond == auto { none } else { d.fond }
  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1em } else { d.avant },
    below: if d.apres == auto { 0.9em } else { d.apres },
    fill: fond,
    inset: if fond == none { 0pt } else { (x: 0.8em, y: 0.6em) },
    {
      {
        let marque = if o.icone == none { none } else { (d.outils.icone)(o.icone, taille: 0.95em, couleur: d.couleur) }
        if marque != none { marque; h(0.35em) }
        if d.nom != none {
          text(fill: d.couleur, weight: "bold", d.nom)
          if d.numero != none { text(fill: d.couleur, weight: "bold", " " + d.numero) }
        } else if d.numero != none {
          text(fill: d.couleur, weight: "bold", d.numero)
        }
        if d.titre != none {
          if d.nom != none or d.numero != none { text(fill: d.couleur, weight: "bold", [ — ]) }
          text(fill: encre, weight: "bold", d.titre)
        }
      }
      parbreak()
      d.corps
    },
  )
}
