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

// Barème des interros (`maquette(afficher-brm: …)`, `exercice(brm: …)`).
// Tout est à appeler dans un `context`, sauf `bareme-valide` et `total-points`.

#import "etats.typ": *
#import "utils.typ": *

// Réglages de `afficher-brm` : "partiel" = total de l'exercice sur son filet ;
// "complet" = total, et note de chaque question à sa droite.
#let modes-bareme = ("partiel", "complet")

// Barème d'un exercice : un nombre positif, ou un tableau (éventuellement
// imbriqué) qui suit la structure des questions numérotées (`+`) :
//   (2, (1, 1.5), 3) → 1. sur 2 ; 2.a) sur 1 ; 2.b) sur 1,5 ; 3. sur 3.
#let bareme-valide(p) = {
  if type(p) in (int, float) { p >= 0 }
  else if type(p) == array { p.len() > 0 and p.all(bareme-valide) }
  else { false }
}

#let total-points(p) = if type(p) == array { p.map(total-points).sum() } else { p }

// « 1,5 pt », « 2 pts » (ou, avec `entier: true`, « 1,5 point », « 6 points »,
// pour le total) : séparateur décimal, mot et accord selon la langue (pluriel à
// partir de 2 en français, dès que ce n'est pas 1 ailleurs).
#let texte-points(p, entier: false) = {
  let n = calc.round(p, digits: 2)
  let chiffres = str(n)
  if terme("separateur-decimal") != "." { chiffres = chiffres.replace(".", terme("separateur-decimal")) }
  let pluriel = if terme("pluriel-des-deux") { n >= 2 } else { n != 1 }
  let (singulier, pluriel-mot) = if entier { ("point-total", "points-total") } else { ("point", "points") }
  chiffres + " " + terme(if pluriel { pluriel-mot } else { singulier })
}

// Note d'une question, grisée, à droite de la ligne (à l'intérieur du cadre).
#let note-question(p) = text(fill: luma(45%), size: .85em)[(#texte-points(p))]

// Pose la note de chaque question numérotée (`enum.item`) du contenu, en suivant
// le barème. Renvoie (contenu, nombre de questions consommées). Une question à
// sous-questions reçoit un tableau ; ses sous-questions, les notes. Le texte de
// la question s'arrête avant la note, pour ne jamais passer dessous ; ses zones
// de réponse (`seyes`, ou le corrigé qui les remplace) gardent toute la largeur.
#let marquer-questions(c, p, i: 0) = {
  let f = c.func()
  if f == enum.item {
    if i >= p.len() { return (c, i) }
    let note = p.at(i)
    let corps = if type(note) == array {
      marquer-questions(c.body, note).at(0)
    } else {
      let etiquette = note-question(note)
      let largeur = measure(etiquette).width
      let marge = largeur + .6em
      // Blocs neutres (et non `pad`) : les `set block(…)` de l'utilisateur ne
      // doivent ni les remplir ni masquer la note.
      [#place(top + right, etiquette)#bloc-neutre(width: 100%, inset: (right: marge), {
        show repere-seyes: it => bloc-neutre(width: 100% + marge, it)
        c.body
      })]
    }
    let item = if "number" in c.fields() { enum.item(c.number, corps) } else { enum.item(corps) }
    return (item, i + 1)
  }
  if f == enum {
    let enfants = ()
    for e in c.children {
      let (e2, j) = marquer-questions(e, p, i: i)
      enfants.push(e2)
      i = j
    }
    let reglages = c.fields()
    let _ = reglages.remove("children")
    return (enum(..reglages, ..enfants), i)
  }
  if f == [].func() {
    let enfants = ()
    for e in c.children {
      let (e2, j) = marquer-questions(e, p, i: i)
      enfants.push(e2)
      i = j
    }
    return (enfants.join(), i)
  }
  (c, i)
}
