// pastille.typ — skin intégré « pastille » (pastille et pointillés), pour tous les environnements de
// farfadet-didactique.
//
// Concept : une pastille ronde pleine, de la teinte de l'environnement, porte une icône blanche (le signe ⇒
//   par défaut : une règle qu'on applique). Le nom et le titre suivent la pastille sur la même ligne ; un
//   titre long revient en retrait, aligné sur le nom. Un fin cadre en pointillés arrondi entoure le corps,
//   comme une zone « à retenir ». Fond du corps blanc, pas de bandeau, rien ne dépasse de la colonne.
// Origine : second du concours Propriété (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "implique") : nom d'une icône du jeu commun (toujours dessinée en blanc dans la pastille),
//     fonction `couleur => contenu`, contenu ou `none` (pastille vide) ;
//   - `epaisseur` (défaut 0.9pt) : trait des pointillés.
//   Les clés `couleur`, `colback` (fond du corps, blanc par défaut), `colframe` (pointillés), `coltitle`
//   (encre du nom) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Propriete", rendu: "pastille")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, options-skin

#let skin(d) = {
  let o = options-skin(d, "pastille", (icone: "implique", epaisseur: 0.9pt))
  // trait et encre légèrement assombris : lisibles même avec une teinte claire (palette ocean)
  let trait = if d.cadre == auto { d.couleur.darken(15%) } else { d.cadre }
  let encre = if d.couleur-titre == auto { d.couleur.darken(40%) } else { d.couleur-titre }
  // la pastille : disque plein de la teinte assombrie, icône blanche (sans icône : disque seul)
  let pastille = {
    let choix = d.options.at("icone", default: auto)
    let sans = d.icone == none and choix == none
    if sans {
      box(circle(radius: 0.62em, fill: d.couleur.darken(30%), stroke: none))
    } else {
      choisir-icone(d, "implique", taille: 1.24em, couleur: d.couleur, pastille: true)
    }
  }
  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1.2em } else { d.avant },
    below: if d.apres == auto { 1.2em } else { d.apres },
    {
      // ligne de tête : pastille, nom (et numéro), titre éventuel, tous sur la même ligne
      // (sans justification : un titre long qui passe à la ligne ne s'étire pas)
      set par(justify: false)
      // grille : la pastille reste à gauche, et un titre qui passe à la ligne revient en retrait
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        align: top,
        pastille,
        {
          if d.nom != none { text(fill: encre, weight: "bold", smallcaps(d.nom)) }
          if d.numero != none { h(0.3em) + text(fill: encre, weight: "bold", d.numero) }
          // le joint de mots (U+2060) interdit de couper entre le tiret et le premier mot du titre
          if d.titre != none { [#h(0.2em)—#sym.wj#h(0.3em)] + text(weight: "bold", d.titre) }
        },
      )
      v(0.35em, weak: true)
      // cadre fin en pointillés arrondi autour du seul corps
      block(
        width: 100%,
        breakable: d.breakable,
        radius: 5pt,
        fill: if d.fond == auto { none } else { d.fond },
        stroke: (paint: trait, thickness: o.epaisseur, dash: "dotted"),
        inset: (x: 0.9em, top: 0.6em, bottom: 0.6em),
        d.corps,
      )
    },
  )
}
