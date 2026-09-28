// Copyright 2026 Arthur Meyer
//
// This work may be distributed and/or modified under the
// conditions of the LaTeX Project Public License, either version 1.3c
// of this license or (at your option) any later version.
// The latest version of this license is in
//   https://www.latex-project.org/lppl.txt
// and version 1.3c or later is part of all distributions of LaTeX
// version 2008 or later.
//
// This work has the LPPL maintenance status `maintained'.
// The Current Maintainer of this work is Arthur Meyer.
//
// This work consists of all the .typ files in the src/ directory
// and its subdirectories.

// Cartouche de titre de la fiche.
// Réglé par `maquette(titre-maquette: …)`, avec la zone Nom / Prénom / Classe
// du mode "interro". Tout est à appeler dans un `context`.

#import "utils.typ": *

// "exercices" : fiche d'exercices ; "interro" : ajoute une zone Nom / Prénom /
// Classe à remplir à la main (clé IE de ProfMaquette).
#let modes-maquette = ("exercices", "interro")

#let styles-maquette = ("onglet",)

// Un dessin par style : (gauche, centre, droite, couleur, hauteur) → contenu.
// `hauteur` : auto, ou la hauteur à atteindre pour égaler la zone Nom / Prénom
// / Classe posée à droite (mode "interro").
#let dessins-maquette = (
  // Onglet coloré posé sur un cadre arrondi (d'après `pretty-part`, thème
  // « pretty » du paquet bookly).
  onglet: (gauche, centre, droite, couleur, hauteur) => layout(taille => {
    let onglet = if gauche != none {
      bloc-neutre(fill: couleur, inset: (x: .9em, y: .45em), radius: (top: 8pt), text(fill: white, weight: "bold", size: 12pt * echelle(), gauche))
    } else { none }
    let hauteur-onglet = if onglet != none { measure(onglet).height } else { 0pt }
    let corps = grid(
      columns: (1fr, auto),
      column-gutter: .8em,
      align: (center + horizon, right + horizon),
      text(weight: "bold", size: 17pt * echelle(), if centre != none { centre } else { " " }),
      if droite != none { text(size: 10pt * echelle(), weight: "bold", droite) } else { [] },
    )
    let hauteur-cadre = if hauteur == auto {
      measure(corps, width: taille.width - 2.4em).height + 1.8em
    } else { hauteur - hauteur-onglet }
    stack(
      dir: ttb,
      spacing: 0pt,
      if onglet != none { pad(left: 1.2em, onglet) } else { [] },
      bloc-neutre(width: 100%, height: hauteur-cadre, stroke: 1.5pt + couleur, radius: 10pt, inset: (x: 1.2em, y: .9em), align(horizon, corps)),
    )
  }),
)

// Zone Nom / Prénom / Classe sur une ligne, pleine largeur (mode "interro"
// sans cartouche).
#let zone-nom-prenom-classe-pleine-largeur() = {
  let ligne(libelle) = boite-neutre(width: 100%, {
    text(weight: "bold", libelle)
    h(.4em)
    box(width: 1fr, repeat[.])
  })
  bloc-neutre(width: 100%, above: .8em, below: 0pt, grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1.5em,
    ligne(terme("nom") + " :"), ligne(terme("prenom") + " :"), ligne(terme("classe") + " :"),
  ))
}

// Même zone, empilée, à droite du cartouche.
#let zone-nom-prenom-classe-empilee(hauteur) = {
  let ligne(libelle) = boite-neutre(width: 100%, {
    text(weight: "bold", size: 10pt * echelle(), libelle)
    h(.4em)
    box(width: 1fr, repeat[.])
  })
  bloc-neutre(
    width: 100%,
    height: hauteur,
    inset: (x: .2em, y: .3em),
    align(horizon, stack(spacing: .9em, ligne(terme("nom") + " :"), ligne(terme("prenom") + " :"), ligne(terme("classe") + " :"))),
  )
}

// `titre` : dictionnaire (gauche, centre, droite), clés facultatives. Rien
// n'est dessiné s'il est vide, sauf en mode "interro" (zone pleine largeur).
// `largeur` : part du cartouche à côté de la zone Nom / Prénom / Classe (mode
// "interro" avec un titre seulement).
#let cartouche-titre(mode, titre, style, couleur, largeur: 65%) = {
  let gauche = titre.at("gauche", default: none)
  let centre = titre.at("centre", default: none)
  let droite = titre.at("droite", default: none)
  let vide = gauche == none and centre == none and droite == none
  let dessiner = dessins-maquette.at(style)
  if vide and mode != "interro" { return }
  if vide {
    zone-nom-prenom-classe-pleine-largeur()
  } else if mode == "interro" {
    layout(taille => {
      let largeur-cartouche = (taille.width - 1.5em) * largeur
      let largeur-zone = taille.width - 1.5em - largeur-cartouche
      let h = calc.max(
        measure(dessiner(gauche, centre, droite, couleur, auto), width: largeur-cartouche).height,
        measure(zone-nom-prenom-classe-empilee(auto), width: largeur-zone).height,
      )
      grid(
        columns: (largeur-cartouche, largeur-zone),
        column-gutter: 1.5em,
        dessiner(gauche, centre, droite, couleur, h),
        zone-nom-prenom-classe-empilee(h),
      )
    })
  } else {
    dessiner(gauche, centre, droite, couleur, auto)
  }
  v(1.2em)
}
