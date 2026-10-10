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

// Fonction maquette, qui englobe et règle toute la fiche.

#import "interne/etats.typ": *
#import "interne/utils.typ": *
#import "interne/cartouche.typ": cartouche-titre, modes-maquette, styles-cartouche
#import "interne/blocs-fin.typ": bloc-corriges, liste-entrainements
#import "interne/bareme.typ": modes-bareme

// ─── Réglages (internes, appelés par `maquette` seule) ───────────────────────

// auto = couleur inchangée.
#let reglages-couleurs(couleur-externe: auto, couleur-interne: auto) = etat-couleurs.update(c => (
  externe: if couleur-externe == auto { c.externe } else { couleur-externe },
  interne: if couleur-interne == auto { c.interne } else { couleur-interne },
))

// Équivalent des clés de l'environnement Maquette de ProfMaquette.
//   mode             : "apres" (CorrigeApres) | "fin" (CorrigeFin) |
//                      "apres-question" (à la place des `seyes`) | none (aucun
//                      corrigé : seulement pour "apres-question" hors interro ;
//                      sinon, « aucun corrigé » passe par `liste-corriges: ()`)
//   vers-corrige     : clé cliquable exercice ↔ corrigé (VersSolution)
//   titre-corriges   : début du titre de chaque corrigé (TitreCorrige)
//   nouvelle-page    : la Correction commence sur une nouvelle page
//   page-par-corrige : chaque corrigé sur sa propre page
// Les deux derniers sont incompatibles avec `columns(…)` ou un cadre
// (pagebreak interdit dans un conteneur).
#let reglages-corriges(
  mode: "fin",
  vers-corrige: true,
  titre-corriges: auto,
  nouvelle-page: true,
  page-par-corrige: false,
) = {
  assert(
    mode in (none, "apres", "fin", "apres-question"),
    message: "reglages-corriges : mode doit valoir none, \"apres\", \"fin\" ou \"apres-question\".",
  )
  etat-reglages-corriges.update((
    mode: mode,
    vers-corrige: vers-corrige,
    titre-corriges: titre-corriges,
    nouvelle-page: nouvelle-page,
    page-par-corrige: page-par-corrige,
  ))
}

#let couleur-exercices-route(couleur) = etat-couleur-route.update(couleur)

#let style-exercices(style) = {
  assert(
    style in styles-exercice,
    message: "style-exercice doit valoir " + styles-exercice.map(s => "\"" + s + "\"").join(", ", last: " ou ") + ", pas " + repr(style) + ".",
  )
  etat-style.update(style)
}

// ─── maquette ────────────────────────────────────────────────────────────────

// Englobe toute la fiche et la règle en un seul endroit (environnement
// Maquette). Chaque maquette repart de zéro (exercice 1, couleurs par défaut…)
// et ajoute à la fin les blocs « Automatismes » puis « Correction ».
//
//   #maquette(position-corriges: "fin", liste-corriges: "1-6,9,12")[ … ]
//   ou, en tête de fiche : #show: maquette.with(…)
//
//   position-corriges      : "apres" (sous chaque énoncé) | "fin"/true (en fin
//                            de fiche) | "apres-question" (en mode interro
//                            seulement : chaque corrigé prend la place d'un
//                            `seyes` de l'exercice ; hors interro, aucun
//                            corrigé). Règle la position, jamais le nombre :
//                            pour aucun corrigé, liste-corriges: ()
//   liste-corriges         : auto (tous), 4, "1-6,9,12", (1, "3-5"), "route",
//                            "pas-route" ou () (aucun). Les énoncés sont
//                            toujours tous affichés
//   vers-corrige           : clé cliquable exercice ↔ corrigé (VersSolution)
//   couleur-externe        : liens extérieurs (haltère, QR, source)
//   couleur-interne        : navigation (clé, titres des corrigés)
//   titre-corriges         : début du titre de chaque corrigé (auto = « Corrigé
//                            de l'exercice », ou sa traduction)
//   nouvelle-page-corriges : la Correction commence sur une nouvelle page
//                            (false indispensable dans `columns(…)` ou un cadre)
//   page-par-corrige       : chaque corrigé sur sa propre page (même limite)
//   couleur-route          : exercices sur la route (auto = noir)
//   style-exercice         : "fond-blanc" (défaut), "etiquette-encadree",
//                            "bandeau" ou "etiquette-pleine"
//   nombre-qr              : QR codes par ligne dans « Automatismes »
//   taille-qr              : côté des QR codes
//   titre-qr               : titre du bloc « Automatismes » (auto = traduit)
//   couleur-fdr            : couleur du schéma `afficher-fdr` (noir par défaut)
//   langue                 : "fr", "en", "de", "es", "it" ; auto = celle du
//                            document, sauf l'anglais (défaut de Typst) → "fr"
//   mode-maquette          : "exercices" (défaut) ou "interro" (zone Nom /
//                            Prénom / Classe)
//   titre-maquette         : cartouche de titre, dictionnaire aux clés
//                            facultatives gauche / centre / droite
//   style-cartouche        : présentation du cartouche : "onglet" (seul style)
//   couleur-titre          : accent du cartouche (onglet, contour) ; le niveau
//                            (à droite) reste noir. Noir par défaut
//   afficher-brm           : barème, en mode "interro" seulement (sans effet
//                            sinon) : none (défaut), "partiel" (total de chaque
//                            exercice sur son filet) ou "complet" (et note de
//                            chaque question), d'après `exercice(brm: …)`
//   largeur-cartouche      : part de la largeur prise par le cartouche en mode
//                            "interro", à côté de la zone Nom / Prénom /
//                            Classe (65 % par défaut). Sans effet sinon
#let maquette(
  position-corriges: "fin",
  liste-corriges: auto,
  vers-corrige: true,
  couleur-externe: auto,
  couleur-interne: auto,
  titre-corriges: auto,
  nouvelle-page-corriges: true,
  page-par-corrige: false,
  couleur-route: auto,
  style-exercice: "fond-blanc",
  nombre-qr: 3,
  taille-qr: 2cm,
  titre-qr: auto,
  couleur-fdr: black,
  langue: auto,
  mode-maquette: "exercices",
  titre-maquette: (:),
  style-cartouche: "onglet",
  couleur-titre: auto,
  largeur-cartouche: 65%,
  afficher-brm: none,
  body,
) = {
  // Réglages invalides : message clair plutôt qu'une erreur de Typst plus loin.
  let est-couleur(c) = type(c) in (color, gradient, tiling)
  for (nom, valeur) in (
    couleur-externe: couleur-externe,
    couleur-interne: couleur-interne,
    couleur-route: couleur-route,
    couleur-fdr: couleur-fdr,
    couleur-titre: couleur-titre,
  ) {
    assert(
      valeur == auto or est-couleur(valeur),
      message: "maquette : " + nom + " doit être une couleur (blue, rgb(\"#0090C8\")…), pas " + repr(valeur) + ".",
    )
  }
  assert(type(taille-qr) == length, message: "maquette : taille-qr doit être une longueur (2cm, 15mm…).")
  assert(
    mode-maquette in modes-maquette,
    message: "maquette : mode-maquette doit valoir " + modes-maquette.map(m => "\"" + m + "\"").join(", ", last: " ou ") + ", pas " + repr(mode-maquette) + ".",
  )
  assert(
    style-cartouche in styles-cartouche,
    message: "maquette : style-cartouche doit valoir " + styles-cartouche.map(s => "\"" + s + "\"").join(", ", last: " ou ") + ", pas " + repr(style-cartouche) + ".",
  )
  assert(
    afficher-brm == none or afficher-brm in modes-bareme,
    message: "maquette : afficher-brm doit valoir none, " + modes-bareme.map(m => "\"" + m + "\"").join(" ou ") + ", pas " + repr(afficher-brm) + ".",
  )
  assert(
    type(largeur-cartouche) == ratio and largeur-cartouche > 0% and largeur-cartouche < 100%,
    message: "maquette : largeur-cartouche doit être un pourcentage strictement entre 0% et 100% (65%, 70%…), pas " + repr(largeur-cartouche) + ".",
  )
  for cle in titre-maquette.keys() {
    assert(
      cle in ("gauche", "centre", "droite"),
      message: "maquette : titre-maquette n'accepte que les clés gauche, centre et droite, pas " + repr(cle) + ".",
    )
  }
  // auto = couleurs par défaut, pas celles d'une maquette précédente.
  reglages-couleurs(
    couleur-externe: if couleur-externe == auto { couleurs-defaut.externe } else { couleur-externe },
    couleur-interne: if couleur-interne == auto { couleurs-defaut.interne } else { couleur-interne },
  )
  assert(
    position-corriges == true or position-corriges in ("apres", "fin", "apres-question"),
    message: "maquette : position-corriges doit valoir \"apres\", \"fin\", \"apres-question\" ou true (jamais none/false : pour n'afficher aucun corrigé, utiliser liste-corriges: () plutôt que ce réglage), pas " + repr(position-corriges) + ".",
  )
  // "apres-question" n'a de sens qu'en interro (réponses dans les `seyes`).
  let mode = if position-corriges == true { "fin" }
    else if position-corriges == "apres-question" and mode-maquette != "interro" { none }
    else { position-corriges }
  reglages-corriges(
    mode: mode,
    vers-corrige: vers-corrige,
    titre-corriges: titre-corriges,
    nouvelle-page: nouvelle-page-corriges,
    page-par-corrige: page-par-corrige,
  )
  couleur-exercices-route(if couleur-route == auto { black } else { couleur-route })
  style-exercices(style-exercice)
  etat-selection.update((corriges: parser-plage(liste-corriges)))
  etat-fdr.update((couleur: couleur-fdr))
  etat-afficher-brm.update(if mode-maquette == "interro" { afficher-brm } else { none })
  etat-langue.update(langue)
  etat-historique.update(())
  etat-serie.update(n => n + 1)
  etat-corriges.update(())
  etat-blocs-fin.update((entrainements: false, corriges: false))
  etat-corrige-deja-affiche.update(false)
  etat-nb-seyes.update(0)
  etat-nb-reponses.update(0)
  etat-profondeur.update(n => n + 1)
  context assert(
    etat-profondeur.get() == 1,
    message: "maquette : une maquette ne peut pas en contenir une autre. Pour plusieurs fiches dans un même document, placer les maquettes l'une après l'autre.",
  )
  protege(_ => cartouche-titre(mode-maquette, titre-maquette, style-cartouche, if couleur-titre == auto { black } else { couleur-titre }, largeur: largeur-cartouche))
  [#metadata(none) #repere-borne]
  body
  [#metadata(none) #repere-borne]
  liste-entrainements(colonnes: nombre-qr, taille-qr: taille-qr, titre-qr: titre-qr)
  bloc-corriges()
  etat-profondeur.update(n => n - 1)
}
