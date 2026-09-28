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

// Icônes, cadres et rendu des corrigés.
// Tous (sauf `icone`) sont à appeler dans un `context`.

#import "etats.typ": *
#import "utils.typ": *

// ─── Icônes ──────────────────────────────────────────────────────────────────

// Icône SVG de `icones/`, à l'échelle d'un texte de taille `taille` (comme un
// caractère Font Awesome : 1 em = 512 unités du dessin). Un SVG n'accepte
// qu'une couleur unie : un dégradé donne sa couleur du milieu, un motif du noir.
#let icone(nom, taille, couleur) = {
  let svg = read("../icones/" + nom + ".svg")
  let hauteur = float(svg.match(regex("viewBox=\"[^\"]* ([\d.]+)\"")).captures.first())
  let teinte = if type(couleur) == color { couleur } else if type(couleur) == gradient { couleur.sample(50%) } else { black }
  image(bytes(svg.replace("currentColor", teinte.to-hex())), format: "svg", height: taille * hauteur / 512)
}

// Haltère cliquable vers l'entraînement, inclinée à 45° comme dans ProfMaquette.
#let icone-entrainement(url) = link(url)[
  #boite-neutre(fill: fond(), inset: 3pt, radius: 2pt)[
    #rotate(45deg, reflow: true, icone("dumbbell", 14pt * echelle(), couleur-externe()))
  ]
]

// Clé menant au corrigé (VersSolution).
#let icone-corrige() = boite-neutre(fill: fond(), inset: 2pt, radius: 2pt)[
  #icone("key", 12pt * echelle(), couleur-interne())
]

// Calculatrice barrée (Calculatrice=false), placée dans le titre de l'exercice.
// Le trait déborde de l'icône ; baseline: 20% la recentre sur le texte.
#let icone-calculatrice-barree(couleur) = {
  let ic = icone("calculator", 1em, couleur)
  let dim = measure(ic)
  let debord-x = .08 * dim.width
  let debord-y = .08 * dim.height
  let largeur = dim.width + 2 * debord-x
  let hauteur = dim.height + 2 * debord-y
  box(width: largeur, height: hauteur, baseline: 20%)[
    #place(top + left, dx: debord-x, dy: debord-y, ic)
    #place(top + left, line(start: (0pt, hauteur), end: (largeur, 0pt), stroke: .11em + couleur))
  ]
}

// Étiquette « Source », posée sur le filet bas de l'exercice.
#let etiquette-source(texte) = boite-neutre(fill: fond(), inset: 2pt, radius: 2pt)[
  #text(size: 7pt * echelle(), fill: couleur-externe())[#texte]
]

// ─── Cadres ──────────────────────────────────────────────────────────────────

// Cadre à titre (exercices, bloc « Automatismes ») dans le style de la fiche :
//   "fond-blanc"         titre sur le fond de la page, qui coupe le filet haut
//   "etiquette-encadree" titre dans un petit cadre à cheval sur le filet
//   "bandeau"            titre en haut du cadre, séparé de l'énoncé par un filet
//   "etiquette-pleine"   titre dans une étiquette remplie, à cheval sur le filet
// Le cadre ne se coupe pas entre deux pages, sauf s'il est plus haut qu'une page.
// `couleur-titre` : auto = couleur du filet.
#let boite-etiquette(couleur, titre, couleur-titre: auto, body) = layout(taille => {
  let style = etat-style.get()
  let filet = .12em + couleur
  let teinte = if couleur-titre == auto { couleur } else { couleur-titre }
  let contenu = if style == "bandeau" {
    bloc-neutre(width: 100%, spacing: 0pt, stroke: filet, radius: 5pt, {
      bloc-neutre(width: 100%, spacing: 0pt, inset: (x: 1em, y: .6em), text(fill: teinte, weight: "bold", titre))
      bloc-neutre(
        width: 100%,
        spacing: 0pt,
        stroke: (top: filet, x: none, bottom: none),
        inset: (x: 1.2em, top: .6em, bottom: 1.2em),
        body,
      )
    })
  } else {
    let etiquette = if style == "fond-blanc" {
      bloc-neutre(spacing: 0pt, fill: fond(), inset: (x: .4em, y: .5em), text(fill: teinte, weight: "bold", titre))
    } else if style == "etiquette-pleine" {
      bloc-neutre(spacing: 0pt, fill: teinte, radius: 3pt, inset: (x: .8em, y: .5em), text(fill: fond(), weight: "bold", titre))
    } else {
      bloc-neutre(spacing: 0pt, fill: fond(), stroke: filet, radius: 3pt, inset: (x: .8em, y: .5em), text(fill: teinte, weight: "bold", titre))
    }
    let largeur-etiquette = taille.width - 2em
    // Place réservée au-dessus et au-dessous du filet.
    let demi = measure(etiquette, width: largeur-etiquette).height / 2
    {
      v(demi)
      bloc-neutre(width: 100%, spacing: 0pt, stroke: filet, radius: 5pt, {
        v(demi)
        place(top + left, dx: 1em, dy: -demi, bloc-neutre(width: largeur-etiquette, etiquette))
        bloc-neutre(width: 100%, spacing: 0pt, inset: (x: 1.2em, top: .6em, bottom: 1.2em), body)
      })
    }
  }
  let trop-haute = measure(contenu, width: taille.width).height > taille.height
  bloc-neutre(width: 100%, breakable: trop-haute, contenu)
})

// Cadre d'un exercice. Sur la route : couleur de la route. Hors route : filet
// gris clair, titre gris foncé (gris moyen sur une étiquette pleine, pour ne
// pas ressortir plus qu'un exercice sur la route).
#let boite-exercice(numero: none, titre: none, route: true, calculatrice: true, body) = {
  let couleur = etat-couleur-route.get()
  let etiquette-pleine = etat-style.get() == "etiquette-pleine"
  let gris-titre = if etiquette-pleine { luma(60%) } else { luma(35%) }
  let couleur-titre = if route { couleur } else { gris-titre }
  // Sur une étiquette pleine, le titre est écrit dans la couleur du fond.
  let couleur-icone = if etiquette-pleine { fond() } else { couleur-titre }
  boite-etiquette(
    if route { couleur } else { luma(82%) },
    couleur-titre: couleur-titre,
    [#terme("exercice") #numero#if titre != none [ : #titre]#if not calculatrice [#h(4pt)#"-"#h(4pt)#icone-calculatrice-barree(couleur-icone)]],
    body,
  )
}

// ─── Corrigés ────────────────────────────────────────────────────────────────

// Rendu d'un corrigé. Le `metadata` sert de cible à la clé de l'exercice ; le
// titre ramène à l'exercice.
#let rendu-corrige(item, reglages, rendre: c => c) = bloc-neutre(width: 100%, above: 1.4em, below: 1em)[
  #metadata("corrige-" + item.id)
  #let titre = text(weight: "bold", fill: couleur-interne())[
    #if reglages.titre-corriges == auto { terme("titre-corriges") } else { reglages.titre-corriges } #item.numero#if item.titre != none [ : #item.titre]
  ]
  // Titre dans son propre bloc, jamais laissé seul en bas de page (sticky).
  #bloc-neutre(width: 100%, below: .8em, sticky: true, context {
    let cible = query(metadata.where(value: "exercice-" + item.id))
    if reglages.vers-corrige and cible.len() > 0 { link(cible.first().location(), titre) } else { titre }
  })
  #rendre(item.body)
]
