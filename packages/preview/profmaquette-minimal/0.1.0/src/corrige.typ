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

// Fonction corrige, le corrigé de l'exercice qui précède.

#import "interne/etats.typ": *
#import "interne/utils.typ": *
#import "interne/dessins.typ": rendu-corrige, rendu-reponse

// Corrigé de l'exercice qui précède (environnement Solution). Ignoré si
// l'exercice porte `pas-corrige: true` ou s'il est hors de `liste-corriges`.
// Le contenu peut venir d'un fichier séparé :
//   #import "CH_01_EXO_01.typ" as exo01
//   #corrige(exo01.corrige)
// En mode "apres-question", le k-ième corrigé qui suit un exercice prend la
// place de son k-ième `seyes` (ou s'affiche ici, en rouge, s'il n'y en a pas).
//   titre-complement : complément du titre du corrigé, après « : » (clé
//                      TitreSolution) ; sans effet en mode "apres-question"
#let corrige(titre-complement: none, body) = {
  // Hors `context`, avec une valeur fixe : sinon, pas de convergence.
  etat-nb-reponses.update(n => n + 1)
  protege(rendre => context {
    let reglages = etat-reglages-corriges.get()
    if reglages.mode == none or etat-historique.get().len() == 0 { return }
    let infos = infos-exercice()
    if not infos.corrige { return }
    let item = (numero: infos.numero, id: infos.id, titre: titre-complement, body: body)
    if reglages.mode == "apres-question" {
      let k = etat-nb-reponses.get()
      if k <= etat-nb-seyes.get() {
        [#metadata((cle: infos.id + "-" + str(k), body: body)) #repere-reponse]
      } else {
        rendu-reponse(body, rendre: rendre)
      }
    } else if reglages.mode == "apres" {
      if reglages.page-par-corrige and etat-corrige-deja-affiche.get() { pagebreak(weak: true) }
      rendu-corrige(item, reglages, rendre: rendre)
      etat-corrige-deja-affiche.update(true)
    } else {
      etat-corriges.update(lst => lst + (item,))
    }
  })
}
