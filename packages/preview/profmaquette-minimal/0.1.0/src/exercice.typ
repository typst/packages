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

// Fonction exercice, un énoncé numéroté automatiquement.

#import "interne/etats.typ": *
#import "interne/utils.typ": *
#import "interne/dessins.typ": boite-exercice, etiquette-source, icone-corrige, icone-entrainement
#import "interne/bareme.typ": bareme-valide, marquer-questions, texte-points, total-points

// Un exercice, numéroté automatiquement.
//   titre            : titre affiché après « Exercice N : » (none : pas de titre)
//   entrainement     : URL d'un entraînement en ligne → haltère sur le filet droit
//                      et QR code dans le bloc « Automatismes » (clé AEntretenir)
//   source           : texte libre sur le filet bas (clé Source)
//   route            : true = couleur de la route, ligne du bas de la feuille de
//                      route ; false = gris, ligne du haut (clés Route / Stop)
//   pas-corrige      : true = jamais de corrigé, même si un `#corrige` suit
//   titre-complement : complément du titre du corrigé (clé TitreSolution)
//   stop             : true = coche après cet exercice sur la feuille de route
//                      (rarement utile : `thematique` en place déjà une)
//   calculatrice     : false = calculatrice barrée dans le titre
//   brm              : barème (affiché en mode "interro" avec
//                      `maquette(afficher-brm: …)`) : un nombre, ou un tableau
//                      qui suit les questions numérotées (`+`), imbriqué pour
//                      les sous-questions : (2, (1, 1.5), 3)
#let exercice(
  titre: none,
  entrainement: none,
  source: none,
  route: true,
  pas-corrige: false,
  titre-complement: none,
  stop: false,
  calculatrice: true,
  brm: none,
  body,
) = {
  assert(
    brm == none or bareme-valide(brm),
    message: "exercice : brm doit être un nombre positif ou un tableau (éventuellement imbriqué) de nombres positifs, comme (2, (1, 1.5), 3), pas " + repr(brm) + ".",
  )
  // Hors `context`, avec des valeurs fixes : sinon, pas de convergence.
  etat-historique.update(h => h + ((
    route: route,
    pas-corrige: pas-corrige,
    titre-complement: titre-complement,
    titre: titre,
    entrainement: entrainement,
  ),))
  etat-nb-seyes.update(0)
  etat-nb-reponses.update(0)
  protege(rendre => bloc-neutre(width: 100%)[
    #context {
      let infos = infos-exercice()
      let numero = infos.numero
      // Barème : total sur le filet ; en "complet", note de chaque question.
      let affichage = etat-afficher-brm.get()
      let total = if affichage != none and brm != none { texte-points(total-points(brm), entier: true) }
      let body = if affichage == "complet" and type(brm) == array { marquer-questions(body, brm).at(0) } else { body }
      let boite = boite-exercice(numero: numero, titre: titre, route: route, calculatrice: calculatrice, total: total, rendre(body))

      // La mise en page dépend de `cle-possible`, jamais du résultat de la
      // requête : sinon, pas de convergence.
      let reglages = etat-reglages-corriges.get()
      // En mode "apres-question", le corrigé est dans l'énoncé : pas de clé.
      let cle-possible = reglages.vers-corrige and reglages.mode not in (none, "apres-question") and infos.corrige
      let cible = query(metadata.where(value: "corrige-" + infos.id))
      let avec-cle = cle-possible and cible.len() > 0
      [#metadata("exercice-" + infos.id)]
      [#metadata((numero: numero, route: route, stop: stop)) #repere-exercice]

      // Les icônes sont à cheval sur le filet droit, ou à l'intérieur si la
      // marge ne peut pas contenir leur moitié.
      let x-gauche = here().position().x
      if entrainement != none or source != none or cle-possible { layout(dispo => {
        let marge-droite = if type(page.width) == length { page.width - x-gauche - dispo.width } else { 1cm }
        let decalage(icone) = {
          let largeur = measure(icone).width
          if marge-droite >= largeur / 2 + 1pt { largeur / 2 } else { -3pt }
        }
        let hauteur-boite = measure(bloc-neutre(width: dispo.width)[#boite]).height
        // Exercice plus haut qu'une page : la boîte se coupe et ne peut plus être
        // mesurée d'un tenant. Icônes en haut du filet, source en fin d'énoncé.
        if hauteur-boite > dispo.height {
          let icones = ()
          if avec-cle { icones.push(link(cible.first().location(), icone-corrige())) }
          if entrainement != none { icones.push(icone-entrainement(entrainement)) }
          let corps = rendre(body) + if source != none { align(right, etiquette-source(source)) }
          return bloc-neutre(width: 100%, {
            for (k, icone) in icones.enumerate() {
              let taille = measure(icone)
              place(top + right, dx: decalage(icone), dy: 1.5cm + k * 1cm - taille.height / 2, icone)
            }
            boite-exercice(numero: numero, titre: titre, route: route, calculatrice: calculatrice, total: total, corps)
          })
        }
        boite-neutre(height: hauteur-boite, width: 100%)[
          #boite
          // Une icône : centrée verticalement. Clé + haltère : à 1/3 et 2/3.
          #let a-droite(icone, fraction) = {
            let taille = measure(icone)
            place(top + right, dx: decalage(icone), dy: hauteur-boite * fraction - taille.height / 2, icone)
          }
          #if avec-cle {
            let fraction = if entrainement != none { 1 / 3 } else { 1 / 2 }
            a-droite(link(cible.first().location(), icone-corrige()), fraction)
          }
          #if entrainement != none {
            let fraction = if avec-cle { 2 / 3 } else { 1 / 2 }
            a-droite(icone-entrainement(entrainement), fraction)
          }
          // Source : à cheval sur le filet bas, à droite, sur 60 % de la largeur au plus.
          #if source != none [
            #context {
              let etiquette = etiquette-source(source)
              let largeur = calc.min(measure(etiquette).width, dispo.width * 60%)
              let etiquette = bloc-neutre(width: largeur, align(right, etiquette))
              let hauteur-etiquette = measure(etiquette).height
              place(bottom + right, dx: -10pt, dy: hauteur-etiquette / 2, etiquette)
            }
          ]
        ]
      }) } else {
        boite
      }
    }
  ])
}
