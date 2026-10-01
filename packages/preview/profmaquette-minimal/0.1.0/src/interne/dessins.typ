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

// Filet arrondi autour d'un cadre. Un bloc coupé entre deux pages est redessiné
// sur chaque page, filets haut et bas compris : ceux-ci sont donc quasi
// transparents, pour marquer la coupure. Au tout début et à la toute fin, un
// bord arrondi plein de même géométrie les recouvre exactement (posé depuis le
// contenu, donc toujours sur la bonne page) : non coupé, le cadre est un simple
// cadre arrondi.
// Même dessin que le cadre soit coupé ou non : la décision « plus haut qu'une
// page » peut changer d'une passe à l'autre (corrigés qui remplacent les
// seyes), un dessin qui en dépendrait empêcherait la convergence. De même, une
// grille d'une cellule (qui ne trace rien à la coupure) ne convergeait pas.
#let rayon-cadre = 5pt
#let cadre(filet, contenu) = {
  let r = rayon-cadre
  let teinte = filet.paint
  // Opaque (mêlé au fond) : avec une couleur transparente sur un seul côté,
  // Typst trace tout le contour avec ce trait.
  let pale = (
    thickness: filet.thickness,
    paint: if type(teinte) == color { color.mix((teinte, 20%), (fond(), 80%)) } else { luma(85%) },
  )
  // Bord plein : moitié haute ou basse d'un cadre arrondi au trait uniforme
  // (deux traits différents laisseraient une jointure visible dans l'arrondi).
  let e = filet.thickness
  let bord(haut) = bloc-neutre(width: 100% + e, height: 2 * r + e / 2, clip: true, place(
    (if haut { top } else { bottom }) + left,
    dx: e / 2,
    dy: if haut { e / 2 } else { -e / 2 },
    bloc-neutre(width: 100% - e, height: 4 * r, stroke: filet, radius: r),
  ))
  bloc-neutre(width: 100%, spacing: 0pt, stroke: (x: filet, top: pale, bottom: pale), radius: r, {
    place(top + left, dx: -e / 2, dy: -e / 2, bord(true))
    contenu
    place(bottom + left, dx: -e / 2, dy: e / 2, bord(false))
  })
}

// Cadre à titre (exercices, bloc « Automatismes ») dans le style de la fiche :
//   "fond-blanc"         titre sur le fond de la page, qui coupe le filet haut
//   "etiquette-encadree" titre dans un petit cadre à cheval sur le filet
//   "bandeau"            titre en haut du cadre, séparé de l'énoncé par un filet
//   "etiquette-pleine"   titre dans une étiquette remplie, à cheval sur le filet
// Le cadre ne se coupe pas entre deux pages, sauf s'il est plus haut qu'une page.
// `couleur-titre` : auto = couleur du filet.
// `droite` : étiquette facultative, en haut à droite (total du barème), dans le
// même style que le titre.
#let boite-etiquette(couleur, titre, couleur-titre: auto, droite: none, body) = layout(taille => {
  let style = etat-style.get()
  let filet = .12em + couleur
  let teinte = if couleur-titre == auto { couleur } else { couleur-titre }
  let contenu = if style == "bandeau" {
    cadre(filet, {
      bloc-neutre(width: 100%, spacing: 0pt, inset: (x: 1em, y: .6em), text(fill: teinte, weight: "bold", {
        titre
        if droite != none { h(1fr) + droite }
      }))
      // Séparateur à part : bord haut de l'énoncé, il serait redessiné en haut
      // de chaque page si le cadre se coupe.
      bloc-neutre(width: 100%, height: 0pt, spacing: 0pt, stroke: (top: filet))
      bloc-neutre(width: 100%, spacing: 0pt, inset: (x: 1.2em, top: .6em, bottom: 1.2em), body)
    })
  } else {
    let etiquette-de(texte) = if style == "fond-blanc" {
      bloc-neutre(spacing: 0pt, fill: fond(), inset: (x: .4em, y: .5em), text(fill: teinte, weight: "bold", texte))
    } else if style == "etiquette-pleine" {
      bloc-neutre(spacing: 0pt, fill: teinte, radius: 3pt, inset: (x: .8em, y: .5em), text(fill: fond(), weight: "bold", texte))
    } else {
      bloc-neutre(spacing: 0pt, fill: fond(), stroke: filet, radius: 3pt, inset: (x: .8em, y: .5em), text(fill: teinte, weight: "bold", texte))
    }
    let etiquette = etiquette-de(titre)
    let etiquette-droite = if droite != none { etiquette-de(droite) }
    // Le titre s'arrête avant l'étiquette de droite.
    let place-droite = if droite != none { measure(etiquette-droite).width + 1em } else { 0pt }
    let largeur-etiquette = taille.width - 2em - place-droite
    // Place réservée au-dessus et au-dessous du filet.
    let demi = measure(etiquette, width: largeur-etiquette).height / 2
    {
      v(demi)
      cadre(filet, {
        v(demi)
        place(top + left, dx: 1em, dy: -demi, bloc-neutre(width: largeur-etiquette, etiquette))
        if droite != none {
          place(top + right, dx: -1em, dy: -measure(etiquette-droite).height / 2, etiquette-droite)
        }
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
#let boite-exercice(numero: none, titre: none, route: true, calculatrice: true, total: none, body) = {
  let couleur = etat-couleur-route.get()
  let etiquette-pleine = etat-style.get() == "etiquette-pleine"
  let gris-titre = if etiquette-pleine { luma(60%) } else { luma(35%) }
  let couleur-titre = if route { couleur } else { gris-titre }
  // Sur une étiquette pleine, le titre est écrit dans la couleur du fond.
  let couleur-icone = if etiquette-pleine { fond() } else { couleur-titre }
  boite-etiquette(
    if route { couleur } else { luma(82%) },
    couleur-titre: couleur-titre,
    droite: total,
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

// Corrigé d'une question (mode "apres-question"), à la place de son `seyes` :
// filet à gauche et fond pâle dans la couleur interne, sous l'étiquette « Corrigé ».
// Un seyes du corrigé lui-même n'y est qu'une grille : sans compteur (il
// décalerait les seyes suivants) ni recherche (il retrouverait ce corrigé).
// Une règle `show` et non un état : elle vaut aussi dans les `measure`.
#let rendu-reponse(body, rendre: c => c) = {
  let couleur = couleur-interne()
  bloc-neutre(
    width: 100%,
    above: .8em,
    below: .8em,
    fill: if type(couleur) == color { couleur.lighten(93%) } else { none },
    stroke: (left: 3pt + couleur),
    inset: (left: 10pt, rest: 8pt),
  )[
    #text(fill: couleur, weight: "bold", size: .8em, terme("corrige"))
    #show repere-seyes: it => it.children.find(c => c.func() == metadata).value
    #bloc-neutre(width: 100%, above: .5em, below: 0pt, rendre(body))
  ]
}
