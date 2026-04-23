
#import "../template/src/settings/name.typ": *

// -----------------------------------------------------------------------------
// 1. GESTION DU CODE (Affichage style "GitHub" avec numéros de ligne)
// -----------------------------------------------------------------------------

#let mon_code(contenu) = {
  // Création du bloc gris conteneur
  block(
    fill: rgb("#f4f4f4"), // Fond gris clair
    stroke: 0.5pt + luma(180), // Bordure grise fine
    radius: 4pt, // Coins arrondis
    inset: 10pt, // Marge intérieure
    width: 100%, // Largeur max

    // Grille : Colonne 1 (Numéros) | Colonne 2 (Code)
    grid(
      columns: (auto, 1fr),
      gutter: 10pt,

      // Colonne des numéros de ligne (alignée à droite, en gris)
      align(right, text(fill: luma(150), size: 0.8em, font: "New Computer Modern")[
        #let n = contenu.text.split("\n").len()
        #for i in range(n) [
          #(i + 1) \
        ]
      ]),

      // Colonne du code (alignée à gauche)
      align(left, contenu),
    ),
  )
}




// Affiche un extrait de code avec numéros de ligne
#let mon_code_fichier(
  contenu,
  debut: 1,
  fin: none,
  lang: "python",
) = {
  // Split en lignes
  let lignes = contenu.split("\n")
  let total = lignes.len()

  // Calculer les indices (1-basé vers 0-basé)
  let fin_index = if fin == none { total } else { calc.min(fin, total) }
  let debut_index = calc.max(1, debut) - 1

  // Extraire les lignes demandées
  let lignes_extraites = ()
  for i in range(debut_index, fin_index) {
    if i < total {
      lignes_extraites.push(lignes.at(i))
    }
  }

  let code_extrait = lignes_extraites.join("\n")
  let premier_numero = debut

  // Affichage
  block(
    fill: rgb("#f4f4f4"),
    stroke: 0.5pt + luma(180),
    radius: 4pt,
    inset: 10pt,
    width: 100%,
    grid(
      columns: (auto, 1fr),
      gutter: 10pt,

      // Colonne numéros
      align(right, text(fill: luma(150), size: 0.8em, font: "New Computer Modern")[
        #for i in range(lignes_extraites.len()) [
          #(premier_numero + i) \
        ]
      ]),

      // Colonne code
      align(left, raw(code_extrait, lang: lang, block: true)),
    ),
  )
}




// Box

#let ma_bulle(couleur, icone, contenu) = block(
  fill: couleur.lighten(90%),
  stroke: (left: 4pt + couleur),
  radius: 2pt,
  inset: 12pt,
  width: 100%,

  grid(
    columns: (auto, 1fr),
    gutter: 15pt,
    align: horizon,
    text(size: 16pt, icone), contenu,
  ),
)

// --- LES RACCOURCIS À UTILISER DANS VOS DOCUMENTS ---

// Boîte Bleue (Information)
#let info_box(body) = ma_bulle(rgb("#0074D9"), "ℹ️", body)

// Boîte Orange (Attention/Danger)
#let danger_box(body) = ma_bulle(rgb("#FF851B"), "⚠️", body)

// Boîte Verte (Validation/Succès)
#let valid_box(body) = ma_bulle(rgb("#2ECC40"), "✅", body)

// Boîte Rouge (Erreur critique/Feu)
#let feu_box(body) = ma_bulle(rgb("#FF4136"), "🔥", body)

// Boîte Violette (Idée/Astuce)
#let idea_box(body) = ma_bulle(rgb("#B10DC9"), "💡", body)



// Box Todo


#let todo_box(body) = {
  let couleur = rgb("#FF5C5C") // La couleur rouge/rosé de ton image

  // Un block conteneur global pour éviter que l'étiquette ne tape dans le texte au-dessus
  block(width: 100%, above: 1.8em, below: 1em)[
    #block(
      width: 100%,
      fill: couleur.lighten(90%),
      stroke: 1pt + couleur, // Bordure tout autour
      radius: 4pt, // Coins arrondis
      inset: (top: 14pt, bottom: 12pt, left: 12pt, right: 12pt),
    )[
      // L'étiquette flottante "TODO"
      #place(top + left, dy: -23pt, dx: 8pt)[
        #block(
          fill: white, // Fond blanc obligatoire pour cacher la ligne en dessous
          stroke: 1pt + couleur,
          radius: 10pt, // Bords très arrondis (effet "pilule")
          inset: (x: 8pt, y: 3pt),
        )[
          #text(fill: couleur, weight: "bold")[TODO]
        ]
      ]

      // Le texte à l'intérieur
      #body
    ]
  ]
}



// bloc stabilo
#let stabilo(corps, couleur: yellow, opacite: 65%) = {
  let couleur-transparente = couleur.transparentize(100% - opacite)
  highlight(fill: couleur-transparente)[#corps]
}

#let photo(largeur: 15%, nom: none) = {
  align(center)[
    #image("../template/src/assets/picture/logo_photo.png", width: largeur)

    #if nom != none {
      v(-5pt)
      text(fill: luma(0), size: 1em)[#nom]
    }
  ]
}



