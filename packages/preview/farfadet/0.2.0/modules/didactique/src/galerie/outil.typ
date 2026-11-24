// outil.typ — skin intégré « outil » (la boîte à outils), pour tous les environnements de
// farfadet-didactique.
//
// Concept : un résultat est un outil qu'on sort pour résoudre un problème. Une petite icône (une roue dentée
//   par défaut) précède le nom ; le corps est rangé dans un compartiment de boîte à outils : cadre fin sur
//   trois côtés, trait épais en bas. Le fond du corps est BLANC : la couleur ne va qu'à l'icône, au nom, au
//   filet et au trait du bas. En-tête sur une seule ligne, nom en petites capitales.
// Origine : gagnant du concours Propriété (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "roue") : nom d'une icône du jeu commun, fonction `couleur => contenu`, contenu ou `none` ;
//   - `epaisseur` (défaut 2.6pt) : trait épais du bas.
//   Les clés `couleur`, `colback` (fond du corps, blanc par défaut), `colframe` (cadre), `coltitle` (encre du
//   nom et du titre) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Propriete", rendu: "outil")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, options-skin

#let skin(d) = {
  let o = options-skin(d, "outil", (icone: "roue", epaisseur: 2.6pt))
  // teinte légèrement assombrie : le cadre reste visible avec une teinte claire (palette ocean)
  let c = if d.cadre == auto { d.couleur.darken(15%) } else { d.cadre }
  // encre plus sombre que la teinte : le titre reste lisible sur un cyan ou un jaune pâles
  let encre = if d.couleur-titre == auto { c.darken(55%) } else { d.couleur-titre }
  // fond du corps : blanc (aucune teinte sous le texte), sauf si l'utilisateur règle `colback`
  let fond = if d.fond == auto { none } else { d.fond }
  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1.2em } else { d.avant },
    below: if d.apres == auto { 1.2em } else { d.apres },
    fill: fond,
    radius: 2pt,
    // côtés fins, trait épais en bas : la case de boîte à outils
    stroke: (top: 0.7pt + c, left: 0.7pt + c, right: 0.7pt + c, bottom: o.epaisseur + c),
    inset: (x: 0.8em, top: 0.5em, bottom: 0.6em),
    {
      // ligne de tête : icône, nom en petites capitales, numéro, titre en gras.
      // Accolades : l'interlignage serré ne vaut que pour la tête, pas pour le corps.
      {
        set par(leading: 0.55em)
        text(fill: encre, {
          let marque = choisir-icone(d, "roue", taille: 0.95em, couleur: c.darken(25%))
          if marque != none { marque + h(0.35em) }
          if d.nom != none { text(weight: "bold", size: 1.05em, smallcaps(d.nom)) }
          if d.numero != none { h(0.3em) + text(weight: "bold", d.numero) }
          if d.titre != none {
            // le joint de mots (U+2060) interdit de couper entre le tiret et le titre
            [ #h(0.1em)—#sym.wj#h(0.35em)]
            text(weight: "bold", d.titre)
          }
        })
      }
      parbreak()
      d.corps
    },
  )
}
