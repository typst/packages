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

// Bloc « Automatismes » : les QR codes d'entraînement de la fiche. Flotte en bas
// de la dernière page (ou de la suivante) ; au-delà des trois quarts d'une page,
// il suit simplement la fiche et peut se couper.
//   colonnes  : QR codes par ligne
//   taille-qr : côté commun des QR codes (agrandi si l'URL est trop longue
//               pour rester lisible)
//   titre-qr  : titre du bloc (auto = « Automatismes », ou sa traduction)
#let liste-entrainements(colonnes: 3, taille-qr: 2cm, titre-qr: auto) = protege(_ => context {
  assert(
    type(colonnes) == int and colonnes >= 1,
    message: "Automatismes : le nombre de colonnes doit être un entier supérieur ou égal à 1.",
  )
  if etat-blocs-fin.get().entrainements { return }
  let items = etat-historique.get().enumerate()
    .filter(((i, ex)) => ex.entrainement != none)
    .map(((i, ex)) => (numero: i + 1, titre: ex.titre, url: ex.entrainement))
  // Côté minimal lisible à l'impression : 0,4 mm par module. Nombre de modules
  // = 17 + 4 × version, la version dépendant de la longueur de l'URL
  // (capacités en octets des versions 1 à 30, correction d'erreurs M).
  let capacites = (14, 26, 42, 62, 84, 106, 122, 152, 180, 213, 251, 287, 331, 362, 412,
    450, 504, 560, 624, 666, 711, 779, 857, 911, 997, 1059, 1125, 1190, 1264, 1370)
  let cote-minimal(url) = {
    let version = capacites.position(c => c >= url.len())
    (17 + 4 * (if version == none { 30 } else { version + 1 })) * .4mm
  }
  if items.len() > 0 {
    let lignes = calc.ceil(items.len() / colonnes)
    let hauteur-estimee = lignes * (taille-qr.to-absolute() + 30pt) + 50pt
    let flottant = type(page.height) == length and hauteur-estimee < .75 * page.height
    let titre = if titre-qr == auto { terme("automatismes") } else { titre-qr }
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
              width: calc.min(calc.max(taille-qr.to-absolute(), cote-minimal(it.url)), case.width),
            )))
          ])
        )
      ]
    if flottant { place(bottom, float: true, clearance: 1.5em, bloc) } else { bloc }
    etat-blocs-fin.update(b => b + (entrainements: true))
  }
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
