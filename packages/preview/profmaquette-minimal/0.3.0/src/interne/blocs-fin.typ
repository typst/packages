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

// Blocs « Automatismes » et « Correction » de fin de fiche.
// Ajoutés automatiquement par `maquette`, dans cet ordre (comme ProfMaquette).

#import "../deps.typ": tiaoma
#import "etats.typ": *
#import "utils.typ": *
#import "dessins.typ": boite-etiquette, rendu-corrige

// Côté minimal lisible à l'impression : 0,4 mm par module. Nombre de modules
// = 17 + 4 × version, la version dépendant de la longueur de l'URL
// (capacités en octets des versions 1 à 30, correction d'erreurs M).
#let capacites-qr = (14, 26, 42, 62, 84, 106, 122, 152, 180, 213, 251, 287, 331, 362, 412,
  450, 504, 560, 624, 666, 711, 779, 857, 911, 997, 1059, 1125, 1190, 1264, 1370)
#let cote-minimal-qr(url) = {
  let version = capacites-qr.position(c => c >= url.len())
  (17 + 4 * (if version == none { 30 } else { version + 1 })) * .4mm
}

// Cadre « Automatismes » contenant les QR codes `items` ((numero, titre, url)),
// selon les réglages `etat-qr`. À appeler dans un `context`, sous `protege`.
//   thematique : titre de la thématique ajouté au titre du cadre (none : aucun)
//   flottant   : le cadre peut flotter en bas de page s'il est assez petit
#let bloc-qr(items, thematique: none, flottant: false) = {
  let (colonnes, taille: taille-qr, titre, ..) = etat-qr.get()
  let lignes = calc.ceil(items.len() / colonnes)
  let hauteur-estimee = lignes * (taille-qr.to-absolute() + 30pt) + 50pt
  let flottant = flottant and type(page.height) == length and hauteur-estimee < .75 * page.height
  let titre = if titre == auto { terme("automatismes") } else { titre }
  let titre = if thematique == none { titre } else [#titre — #thematique]
  let bloc = boite-etiquette(couleur-externe(), titre)[
      #grid(
        columns: (1fr,) * colonnes,
        row-gutter: 18pt,
        column-gutter: 12pt,
        stroke: none,
        fill: none,
        inset: 0pt,
        align: center + top,
        // Une case ne se coupe pas, et son QR code ne dépasse jamais la colonne.
        ..items.map(it => bloc-neutre(breakable: false)[
          #text(weight: "bold")[#terme("exo") #it.numero]
          #v(4pt)
          #layout(case => link(it.url, tiaoma.qrcode(
            it.url,
            options: (fg-color: couleur-externe()),
            width: calc.min(calc.max(taille-qr.to-absolute(), cote-minimal-qr(it.url)), case.width),
          )))
        ])
      )
    ]
  if flottant { place(bottom, float: true, clearance: 1.5em, bloc) } else { bloc }
}

// Bloc « Automatismes » de fin de fiche. Position "fin" : tous les QR codes de
// la fiche ; flotte en bas de la dernière page (ou de la suivante) ; au-delà des
// trois quarts d'une page, il suit simplement la fiche et peut se couper.
// Position "thematique" : ceux de la dernière thématique, dans le fil du texte
// (les autres sont déjà affichés par `entrainements-thematique`).
#let liste-entrainements() = protege(_ => context {
  if etat-blocs-fin.get().entrainements { return }
  let reglages = etat-qr.get()
  assert(
    type(reglages.colonnes) == int and reglages.colonnes >= 1,
    message: "Automatismes : le nombre de colonnes doit être un entier supérieur ou égal à 1.",
  )
  if reglages.position == "thematique" {
    let (items, titre, ..) = etat-qr-attente.get()
    if items.len() > 0 {
      bloc-qr(items, thematique: titre)
      etat-blocs-fin.update(b => b + (entrainements: true))
    }
  } else {
    let items = etat-historique.get().enumerate()
      .filter(((i, ex)) => ex.entrainement != none)
      .map(((i, ex)) => (numero: i + 1, titre: ex.titre, url: ex.entrainement))
    if items.len() > 0 {
      bloc-qr(items, flottant: true)
      etat-blocs-fin.update(b => b + (entrainements: true))
    }
  }
})

// Position "thematique" : QR codes de la thématique qui se termine, affichés
// par `thematique` juste avant le titre de la suivante.
#let entrainements-thematique() = protege(_ => context {
  let reglages = etat-qr.get()
  if reglages.position != "thematique" { return }
  assert(
    type(reglages.colonnes) == int and reglages.colonnes >= 1,
    message: "Automatismes : le nombre de colonnes doit être un entier supérieur ou égal à 1.",
  )
  let (items, titre, ..) = etat-qr-attente.get()
  if items.len() > 0 { bloc-qr(items, thematique: titre) }
})

// Bloc « Correction » : les corrigés mis de côté en mode "fin".
#let bloc-corriges() = protege(rendre => context {
  let reglages = etat-reglages-corriges.get()
  let items = etat-corriges.get()
  if reglages.mode != "fin" or items.len() == 0 or etat-blocs-fin.get().corriges { return }
  if reglages.nouvelle-page { pagebreak(weak: true) }
  let couleur = couleur-interne()
  bloc-neutre(
    width: 100%,
    stroke: (top: none, x: none, bottom: 1.5pt + couleur),
    inset: (top: 0pt, x: 0pt, bottom: 0.6em),
    below: 1.2em,
  )[
    #text(size: 16pt * echelle(), weight: "bold", fill: couleur, terme("correction"))
  ]
  let rendus = items.map(it => rendu-corrige(it, reglages, rendre: rendre))
  if reglages.page-par-corrige { rendus.join(pagebreak(weak: true)) } else { rendus.join() }
  etat-blocs-fin.update(b => b + (corriges: true))
})
