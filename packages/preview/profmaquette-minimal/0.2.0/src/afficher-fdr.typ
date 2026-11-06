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

// Schéma de la feuille de route.

#import "interne/etats.typ": *
#import "interne/utils.typ": *
#import "interne/dessins.typ": icone

// Découpe les exercices en tronçons (fin après chaque `stop`, et à la fin) et
// les range en colonnes, comme \BuildRouteTikz : exercices sur la route en bas,
// les autres en haut, la ligne la plus courte complétée par des vides (none),
// puis une colonne « coche ». Un élément par tronçon :
//   bas, haut  : une case par colonne — un exercice, none ou "coche"
//   hors-route : le tronçon a-t-il des exercices hors route ?
#let colonnes-fdr(exos) = {
  let troncons = ((),)
  for ex in exos {
    troncons.last().push(ex)
    if ex.stop { troncons.push(()) }
  }
  if troncons.last() == () and troncons.len() > 1 { let _ = troncons.pop() }
  troncons.map(t => {
    let sur-route = t.filter(ex => ex.route)
    let hors-route = t.filter(ex => not ex.route)
    let n = calc.max(sur-route.len(), hors-route.len())
    (
      bas: sur-route + (none,) * (n - sur-route.len()) + ("coche",),
      haut: hors-route + (none,) * (n - hors-route.len()) + ("coche",),
      hors-route: hors-route.len() > 0,
    )
  })
}

// Schéma de la feuille de route (clé FdR, \AfficheFdR), à placer dans la
// maquette, en général avant le premier exercice. Contenu, pas une fonction :
// s'écrit `#afficher-fdr`, sans parenthèses.
//
// Disques pleins : exercices sur la route (ligne du bas) ; disques blancs : hors
// route (ligne du haut). Chaque disque est un lien vers son exercice. Chaque
// `thematique` place une coche après le dernier exercice qui la précède (aucune
// avant le premier exercice) ; `exercice(stop: true)` en ajoute une à la main.
#let afficher-fdr = protege(_ => context {
  // Exercices de la maquette : entre les deux bornes qui entourent le schéma.
  let avant = query(selector(repere-borne).before(here()))
  let apres = query(selector(repere-borne).after(here()))
  let sel = selector(repere-exercice)
  if avant.len() > 0 { sel = sel.after(avant.last().location()) }
  if apres.len() > 0 { sel = sel.before(apres.first().location()) }
  let exos = query(sel).map(m => m.value + (lieu: m.location()))
  if exos.len() == 0 { return }
  let reglages = etat-fdr.get()

  // Coches des thématiques : l'exercice qui précède le premier exercice suivant
  // chaque thématique reçoit une coche.
  let themes = selector(repere-thematique)
  if avant.len() > 0 { themes = themes.after(avant.last().location()) }
  if apres.len() > 0 { themes = themes.before(apres.first().location()) }
  for theme in query(themes) {
    let suivants = query(selector(repere-exercice).after(theme.location()))
    if suivants.len() == 0 { continue }
    let i = exos.position(ex => ex.lieu == suivants.first().location())
    if i != none and i > 0 { exos.at(i - 1).stop = true }
  }

  let couleur = reglages.couleur
  // Dimensions voisines de celles de ProfMaquette (clés Ecart, Rayon, Hauteur).
  let e = echelle()
  let ecart = 7.5mm * e
  let rayon = 2.6mm * e
  let hauteur = 1cm * e

  let troncons = colonnes-fdr(exos)
  let n = troncons.map(t => t.bas.len()).sum()
  // Abscisse de la colonne i de toute la route (0 : départ, 1 à n : cases).
  let x(i) = i * ecart + rayon
  let y-haut = rayon
  let y-bas = hauteur + rayon
  let trait(x1, y1, x2, y2, epaisseur: .6pt) = place(
    line(start: (x1, y1), end: (x2, y2), stroke: epaisseur + couleur),
  )
  let pastille(x0, y, contenu) = place(
    dx: x0 - rayon,
    dy: y - rayon,
    circle(radius: rayon, fill: fond(), stroke: none, inset: 0pt, outset: 0pt, align(center + horizon, contenu)),
  )
  let disque(x0, y, ex, plein) = place(
    dx: x0 - rayon,
    dy: y - rayon,
    link(ex.lieu, circle(
      radius: rayon,
      fill: if plein { couleur } else { fond() },
      stroke: .6pt + couleur,
      inset: 0pt,
      outset: 0pt,
      align(center + horizon, text(
        size: 7pt * e,
        weight: "bold",
        fill: if plein { fond() } else { couleur },
        str(ex.numero),
      )),
    )),
  )

  // Un dessin par tronçon, séparés par une espace de largeur nulle : la route
  // passe à la ligne entre deux tronçons si elle est plus large que la page.
  let dessins = ()
  let debut = 0 // colonnes des tronçons précédents
  for (k, t) in troncons.enumerate() {
    let m = t.bas.len()
    let premier = k == 0
    let dernier = k == troncons.len() - 1
    let gauche = if premier { 0pt } else { x(debut + 1) - ecart / 2 }
    let droite = if dernier { x(n + 1) + rayon } else { x(debut + m) + ecart / 2 }
    let X(j) = x(debut + j) - gauche // abscisse de la j-ième case du tronçon
    dessins.push(boite-neutre(width: droite - gauche, height: y-bas + rayon, {
      // Ligne du haut, puis descente vers la coche.
      if t.hors-route {
        trait(X(1), y-haut, X(m), y-haut)
        trait(X(m), y-haut, X(m), y-bas)
      }
      // Route du bas, terminée par une flèche au dernier tronçon.
      let fin = if dernier { x(n + 1) - 2mm * e - gauche } else { droite - gauche }
      trait(if premier { x(0) } else { 0pt }, y-bas, fin, y-bas, epaisseur: 1.2pt)
      if dernier {
        place(dx: x(n + 1) - 2.4mm * e - gauche, dy: y-bas - 1.3mm * e, polygon(
          fill: couleur,
          stroke: none,
          (0mm, 0mm), (2.4mm * e, 1.3mm * e), (0mm, 2.6mm * e),
        ))
      }
      for (j, case) in t.bas.enumerate(start: 1) {
        if case == "coche" { pastille(X(j), y-bas, icone("check", 9pt * e, couleur)) }
        else if case != none { disque(X(j), y-bas, case, true) }
      }
      for (j, case) in t.haut.enumerate(start: 1) {
        if type(case) == dictionary { disque(X(j), y-haut, case, false) }
      }
    }))
    debut += m
  }
  {
    set par(justify: false, first-line-indent: 0pt, hanging-indent: 0pt, leading: 4mm)
    set text(dir: ltr) // toujours de gauche à droite, même en arabe ou en hébreu
    bloc-neutre(dessins.join([#sym.zws]))
  }
})
