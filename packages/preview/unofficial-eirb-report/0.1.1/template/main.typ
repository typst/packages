#import "@preview/unofficial-eirb-report:0.1.1": template

// ==========================================================================
//        Template
// ==========================================================================

#show: template.with(
  sector: "Filière Informatique",
  document-type: "Rapport de Projet",

  title: "Implémentation d'un modèle de rapport académique",

  authors: (
    (name: "Alexandrine Mercier", email: "alexandrine.mercier@enseirb.fr"),
    (name: "Narcisse Fay", email: "narcisse.fay@enseirb.fr"),
    (name: "Johanne Reyer", email: "johanne.reyer@enseirb.fr"),
    (name: "Modestine Lapointe", email: "modestine.lapointe@enseirb.fr"),
  ),
  author-columns: 2,

  advisers: ((name: "Adelphe Félix", email: "adelphe.felix@enseirb.fr"),),
  adviser-columns: 1,

  date: "Mai 2025",
  abstract: include "sections/0-abstract.typ",
)

// ==========================================================================
//        Sections
// ==========================================================================

#include "sections/1-introduction.typ"
#include "sections/2-analyse.typ"
#include "sections/3-modelisation.typ"
#include "sections/4-implementation.typ"
#include "sections/5-tests.typ"
#include "sections/6-conclusion.typ"

// ==========================================================================
//        End of Document
// ==========================================================================

#set page(header: none)

#pagebreak(weak: true)

= Bibliographie
#bibliography(
  "bib.yaml",
  style: "ieee",
  title: none,
  full: true,
)
