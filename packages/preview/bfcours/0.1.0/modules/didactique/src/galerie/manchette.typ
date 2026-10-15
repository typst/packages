// manchette.typ — skin intégré « manchette » (titre en manchette), pour tous les environnements de
// bfcours-didactique.
//
// Concept : colonne gauche étroite (3 cm) qui porte l'icône, le nom et le titre, alignés à droite contre un
//   filet vertical fin ; le corps occupe la colonne droite et commence sur la ligne du nom. Pas de ligne
//   d'en-tête, pas de fond, pas de double filet.
// Repli : dans une colonne étroite (moins de `repli`), ou quand l'en-tête de la manchette dépasserait
//   `lignes-max` lignes (titre très long), l'en-tête passe AU-DESSUS du corps, sur des lignes pleines, et un
//   filet vertical fin à gauche borde toute la boîte : le repère reste visible.
// Sécable : aucun `layout` (la largeur vient de la sonde de commun.typ), la boîte se coupe entre deux pages.
// Origine : gagnant du concours Théorème (10/10/2026), rendu générique : aucun texte propre à un type.
// Options (clé `skin:`) :
//   - `icone` (défaut "equerre") : nom d'une icône du jeu commun, fonction `couleur => contenu`, contenu ou `none` ;
//   - `largeur` (défaut 3cm) : largeur de la manchette ;
//   - `repli` (défaut 10cm) : largeur de boîte en dessous de laquelle on replie l'en-tête ;
//   - `lignes-max` (défaut 5) : nombre de lignes de la manchette (nom compris) au-delà duquel on replie ;
//   - `epaisseur` (défaut 0.6pt) : filet vertical.
//   Les clés `couleur`, `colback` (fond), `colframe` (filet), `coltitle` (encre du nom) et `icone` sont honorées.
// Emploi : #setbfenvironments(pour: "Definition", rendu: "manchette")
// Contrat : ../../skins/CONTRAT.md.

#import "commun.typ": choisir-icone, largeur-ici, options-skin, sonde-largeur

#let skin(d) = {
  let o = options-skin(d, "manchette", (icone: "equerre", largeur: 3cm, repli: 10cm, lignes-max: 5, epaisseur: 0.6pt))
  let trait = if d.cadre == auto { d.couleur } else { d.cadre }
  let encre = if d.couleur-titre == auto { d.couleur } else { d.couleur-titre }

  // Le nom : icône, nom en petites capitales, numéro (collé au nom par une espace insécable).
  let nom = {
    let marque = choisir-icone(d, "equerre", taille: 0.8em, couleur: encre)
    if marque != none { marque + h(0.3em) }
    text(size: 0.84em, fill: encre, weight: "bold", {
      if d.nom != none { smallcaps(d.nom) }
      if d.numero != none { sym.space.nobreak + d.numero }
    })
  }

  block(
    width: 100%,
    breakable: d.breakable,
    above: if d.avant == auto { 1.2em } else { d.avant },
    below: if d.apres == auto { 1.2em } else { d.apres },
    // fond seulement si l'utilisateur l'a réglé (colback) : jamais de teinte par défaut sous le texte
    fill: if d.fond == auto { none } else { d.fond },
    {
      sonde-largeur()
      context {
        // la manchette tient-elle ? Largeur de la boîte, et nombre de lignes de son en-tête.
        let colonne = o.largeur - 0.7em
        let tete-gauche = {
          set par(justify: false)
          nom
          if d.titre != none {
            linebreak()
            text(weight: "bold", d.titre)
          }
        }
        let haut = measure(block(width: colonne, tete-gauche)).height
        let trop-long = haut > (o.lignes-max * 1.35em).to-absolute()
        if largeur-ici() < o.repli or trop-long {
          // Repli : en-tête au-dessus du corps, filet vertical fin à gauche de toute la boîte.
          block(
            width: 100%,
            breakable: d.breakable,
            stroke: (left: o.epaisseur + trait),
            inset: (left: 0.75em, y: 0.1em),
            {
              set par(justify: false)
              nom
              if d.titre != none { [ #h(0.4em) #text(weight: "bold", d.titre)] }
              parbreak()
              d.corps
            },
          )
        } else {
          // Manchette : la colonne gauche porte le nom et le titre, le corps démarre sur la même ligne.
          grid(
            columns: (o.largeur, 1fr),
            column-gutter: 0.9em,
            grid.cell(
              stroke: (right: o.epaisseur + trait),
              inset: (right: 0.7em, top: 0pt, bottom: 0pt, left: 0pt),
              align(right, tete-gauche),
            ),
            grid.cell(
              inset: 0pt,
              d.corps,
            ),
          )
        }
      }
    },
  )
}
