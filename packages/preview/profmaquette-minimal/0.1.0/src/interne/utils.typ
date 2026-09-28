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

// Outils (sélection des corrigés, langues, mise en page).
// Petits outils, sans rendu graphique propre.

#import "etats.typ": *

// ─── Sélection des corrigés ──────────────────────────────────────────────────

// Convertit une sélection en tableau trié d'entiers, en `auto` (tous) ou en
// mot-clé. Formes acceptées : auto · 4 · "1-6,9,12" · (1, 2, "5-8") · "route"
// · "pas-route".
#let parser-plage(sel) = {
  if sel == auto { return auto }
  if type(sel) == str and sel.trim() in ("route", "pas-route") { return sel.trim() }
  if type(sel) == int { return (sel,) }
  if sel == () { return () } // aucun corrigé
  if type(sel) == array { sel = sel.map(str).join(",") }
  assert(
    type(sel) == str,
    message: "Sélection de corrigés invalide : auto, un entier, \"1-6,9,12\" ou un tableau.",
  )
  let res = ()
  let entier(t) = {
    assert(
      t.trim().match(regex("^\\d+$")) != none,
      message: "Sélection de corrigés invalide : « " + sel + " ». Formes acceptées : auto, 4, \"1-6,9,12\", \"route\", \"pas-route\".",
    )
    int(t.trim())
  }
  for morceau in sel.split(",") {
    let m = morceau.trim()
    if m == "" { continue }
    if m.contains("-") {
      let bornes = m.split("-").map(entier)
      assert(bornes.len() == 2 and bornes.at(0) <= bornes.at(1), message: "Plage invalide : " + m)
      res += range(bornes.at(0), bornes.at(1) + 1)
    } else {
      res.push(entier(m))
    }
  }
  res.dedup().sorted()
}

#let est-selectionne(numero, route, sel) = {
  if sel == auto { true }
  else if sel == "route" { route }
  else if sel == "pas-route" { not route }
  else { numero in sel }
}

// Infos de l'exercice courant (le dernier de l'historique), dans un `context` :
// numero, id (unique dans le document, pour les liens), corrige (son corrigé
// doit-il apparaître ?), titre-complement.
#let infos-exercice() = {
  let hist = etat-historique.get()
  let numero = hist.len()
  let ex = hist.last()
  (
    numero: numero,
    id: str(etat-serie.get()) + "-" + str(numero),
    corrige: not ex.pas-corrige and est-selectionne(numero, ex.route, etat-selection.get().corriges),
    titre-complement: ex.titre-complement,
  )
}

// ─── Langues ─────────────────────────────────────────────────────────────────

#let termes = (
  fr: (exercice: "Exercice", correction: "Correction", automatismes: "Automatismes", exo: "Exo", titre-corriges: "Corrigé de l'exercice", corrige: "Corrigé", nom: "Nom", prenom: "Prénom", classe: "Classe", point: "pt", points: "pts", separateur-decimal: ",", pluriel-des-deux: true, point-total: "point", points-total: "points"),
  en: (exercice: "Exercise", correction: "Solutions", automatismes: "Practice", exo: "Ex.", titre-corriges: "Solution to exercise", corrige: "Solution", nom: "Last name", prenom: "First name", classe: "Class", point: "pt", points: "pts", separateur-decimal: ".", pluriel-des-deux: false, point-total: "point", points-total: "points"),
  de: (exercice: "Aufgabe", correction: "Lösungen", automatismes: "Übungen", exo: "Aufg.", titre-corriges: "Lösung zu Aufgabe", corrige: "Lösung", nom: "Name", prenom: "Vorname", classe: "Klasse", point: "P.", points: "P.", separateur-decimal: ",", pluriel-des-deux: false, point-total: "Punkt", points-total: "Punkte"),
  es: (exercice: "Ejercicio", correction: "Soluciones", automatismes: "Práctica", exo: "Ej.", titre-corriges: "Solución del ejercicio", corrige: "Solución", nom: "Apellido", prenom: "Nombre", classe: "Clase", point: "pto", points: "ptos", separateur-decimal: ",", pluriel-des-deux: false, point-total: "punto", points-total: "puntos"),
  it: (exercice: "Esercizio", correction: "Soluzioni", automatismes: "Allenamento", exo: "Es.", titre-corriges: "Soluzione dell'esercizio", corrige: "Soluzione", nom: "Cognome", prenom: "Nome", classe: "Classe", point: "pt", points: "pt", separateur-decimal: ",", pluriel-des-deux: false, point-total: "punto", points-total: "punti"),
)

// Mot du paquet dans la langue choisie, dans un `context`. Avec `auto`, suit la
// langue du document, sauf l'anglais : c'est la langue par défaut de Typst,
// indiscernable d'un document où rien n'est réglé (→ français).
#let terme(cle) = {
  let langue = etat-langue.get()
  if langue == auto { langue = if text.lang == "en" { "fr" } else { text.lang } }
  termes.at(langue, default: termes.fr).at(cle)
}

// ─── Mise en page ────────────────────────────────────────────────────────────

// Facteur d'agrandissement des éléments de taille fixe (icônes, feuille de
// route, titres) : ils suivent le texte au-delà de 11 pt, sans jamais rapetisser.
// Dans un `context`.
#let echelle() = calc.max(1, text.size / 11pt)

// Couleur du fond de la page, pour que les étiquettes posées sur un filet le
// masquent proprement. Dans un `context`.
#let fond() = if type(page.fill) == color { page.fill } else { white }

// Blocs et boîtes du paquet, protégés des `set block(…)`/`set box(…)` de
// l'utilisateur : une valeur explicite l'emporte sur un `set`.
#let bloc-neutre = block.with(stroke: none, inset: 0pt, outset: 0pt, fill: none, radius: 0pt, clip: false)
#let boite-neutre = box.with(stroke: none, inset: 0pt, outset: 0pt, fill: none, radius: 0pt, clip: false)

// Les blocs créés par Typst lui-même (`layout`, contenu d'un cercle…) ne
// peuvent pas recevoir de valeurs explicites : `protege` neutralise donc
// `block` et `box` pour tout ce que construit le paquet, et fournit
// `rendre(contenu)`, qui rend au contenu de l'utilisateur ses propres réglages.
//   protege(rendre => … rendre(body) …)
#let protege(construire) = context {
  let du-bloc = (
    stroke: block.stroke, inset: block.inset, outset: block.outset,
    fill: block.fill, radius: block.radius, clip: block.clip,
  )
  let de-la-boite = (
    stroke: box.stroke, inset: box.inset, outset: box.outset,
    fill: box.fill, radius: box.radius, clip: box.clip,
  )
  let rendre(contenu) = {
    set block(..du-bloc)
    set box(..de-la-boite)
    contenu
  }
  set block(stroke: none, inset: 0pt, outset: 0pt, fill: none, radius: 0pt, clip: false)
  set box(stroke: none, inset: 0pt, outset: 0pt, fill: none, radius: 0pt, clip: false)
  construire(rendre)
}
