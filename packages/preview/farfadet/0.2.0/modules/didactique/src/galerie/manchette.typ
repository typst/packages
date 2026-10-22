// manchette.typ — skin intégré « manchette » (titre en manchette), pour tous les environnements de
// farfadet-didactique.
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

#import "commun.typ": choisir-icone, options-skin
#import "../../../socle/lib.typ": interne as _socle

/// En-tête de la manchette : le nom, puis le titre en gras à la ligne.
#let _tete-gauche(nom, titre) = {
  set par(justify: false)
  nom
  if titre != none {
    linebreak()
    text(weight: "bold", titre)
  }
}

/// Cotes de la manchette dans une boîte de largeur `L` : (largeur de la colonne gauche, repli pour un
/// titre trop long). Fonction à part, qui ne dépend ni du corps ni de l'emplacement : Typst mémoïse ses
/// appels, si bien que la mesure mot à mot du titre ne se fait qu'une fois par (nom, titre, largeur), et
/// plus à chaque tour de mise en page.
/// Largeur adaptative : au moins `largeur-min`, et au moins le mot le plus long du titre (ou le nom sur
/// une ligne), plafonnée à 45 % de la boîte pour ne pas manger le corps. Les phrases se coupent toujours
/// entre les mots : on n'élargit que jusqu'au mot le plus long.
/// Mots du titre (texte brut). Fonction pure, sans mesure : mémoïsée d'un tour de mise en page à l'autre
/// (les fonctions qui mesurent sont réévaluées au deuxième tour, leur mesure dépendant de l'introspection).
#let _blancs = regex("\s+")
#let _mots(titre) = if titre == none { () } else {
  _socle.bf-brut(titre).split(_blancs).filter(x => x != "")
}

#let _cotes(nom, titre, largeur-min, lignes-max, L) = {
  let mots = _mots(titre)
  // UNE mesure pour le nom et tous les mots : la largeur d'une pile de boîtes est celle de la plus large
  // (même longueur, au bit près, que le maximum des mesures mot à mot)
  let mot-max = measure(stack(box(nom), ..mots.map(x => box(text(weight: "bold", x))))).width
  let largeur = calc.min(calc.max(largeur-min, mot-max + (0.9em).to-absolute()), 0.45 * L)
  let largeur = calc.max(largeur, largeur-min)
  let colonne = largeur - 0.7em
  let haut = measure(block(width: colonne, _tete-gauche(nom, titre))).height
  (largeur, haut > (lignes-max * 1.35em).to-absolute())
}

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
      layout(taille => {
        let largeur-ici() = taille.width
        // la manchette tient-elle ? Largeur de la boîte, et nombre de lignes de son en-tête (`_cotes`,
        // mémoïsée : mesurée une fois par nom, titre et largeur)
        let (largeur, trop-long) = _cotes(nom, d.titre, o.largeur, o.lignes-max, largeur-ici())
        let tete-gauche = _tete-gauche(nom, d.titre)
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
            columns: (largeur, 1fr),
            column-gutter: 0.9em,
            grid.cell(
              stroke: (right: o.epaisseur + trait),
              inset: (right: 0.7em, top: 0pt, bottom: 0pt, left: 0pt),
              align(left, tete-gauche),
            ),
            grid.cell(
              inset: 0pt,
              d.corps,
            ),
          )
        }
      })
    },
  )
}
