// ============================================================
// thETS — Présentation des auteurs et affiliations d'un article
// intégré (mémoire ou thèse par articles, section 9d de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": month-year, tr
#import "state.typ": doc-lang

// Mentions de statut de publication.
#let article-submitted(date) = context {
  tr(doc-lang.get()).article-submitted + month-year(date, doc-lang.get()) + "."
}

#let article-accepted(journal, date) = context {
  let s = tr(doc-lang.get())
  s.article-accepted-before
  emph(journal)
  ", " + month-year(date, doc-lang.get()) + "."
}

#let article-published(journal, details) = context {
  let s = tr(doc-lang.get())
  s.article-published-before
  emph(journal)
  ", "
  details
  "."
}

// Bloc auteurs / affiliations / statut, centré et en interligne simple.
//
//   #article-authors(
//     authors: ([Prénom Nom#super[1]], [Prénom Nom#super[2]]),
//     affiliations: (
//       [#super[1] Département de génie mécanique, École de technologie supérieure,
//        1100 Notre-Dame Ouest, Montréal, Québec, Canada H3C 1K3],
//       [#super[2] HydroClimat TVT, Toulon, France],
//     ),
//     status: article-submitted(datetime(year: 2010, month: 9, day: 1)),
//   )
#let article-authors(authors: (), affiliations: (), status: none) = {
  block(width: 100%, {
    set align(center)
    set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
    authors.join(", ")
    v(cfg.baselineskip, weak: false)
    affiliations.join(linebreak())
    if status != none {
      v(cfg.baselineskip, weak: false)
      status
    }
  })
  v(0.5 * cfg.baselineskip, weak: false)
}
