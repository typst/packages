#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "/lib/base.typ": *

#let TPT(
  //Settings der Template
  title: "",
  pre-thesis: true,
  authors: (),
  keywords: (),
  description: "",
  study-group: "",
  date: "01.01.2024",
  logo: none,
  module: [Theorie-Praxis-Anwendung II],
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-list-of-code: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  //Vorgeschriebene e
  restriction-notice: transl("RestrictionNotice1")
    + transl("paper")
    + transl("RestrictionNotice2"),
  foreword: [],
  gendering-note: transl("GenderingNote"),
  body,
) = {
  base-project(
    type: "tpt",
    title: title,
    authors: authors,
    keywords: keywords,
    description: description,
    study-group: study-group,
    submission-date: date,
    university-logo: logo,
    module: module,
    show-list-of-figures: show-list-of-figures,
    show-list-of-tables: show-list-of-tables,
    show-list-of-code: show-list-of-code,
    acronyms: acronyms,
    appendix: appendix,
    glossary: glossary,
    bibliography: bibliography,
    restriction-notice: restriction-notice,
    foreword: foreword,
    gendering-note: gendering-note,
    {
      set page(header: none)
      set text(font: "Noto Sans")
      // Title page.
      v(0.6fr)
      // Titel
      align(center, par(
        text(
          38pt,
          weight: 700,
          fill: blue,
          (
            if pre-thesis { transl("PracticalDocs") } else {
              transl("PracticalDocs2")
            }
          )
            + " "
            + linebreak()
            + linebreak()
            + text(30pt, title),
          hyphenate: false,
        ),
        justify: false,
      ))
      v(1.2em, weak: true)
      if logo != none {
        align(center, logo)
      }
      v(2.6fr)

      set text(15pt)
      set par(leading: .8em)

      // Authoren.
      align(center, text(1.1em, weight: "bold", "Gruppen-Mitglieder"))
      pad(
        top: 0.7em,
        grid(
          columns: (1fr,),
          gutter: 1em,
          ..authors.map(author => align(center, text(
            weight: "bold",
            [#author.name (#author.student-id)],
          ))),
        ),
      )
      v(1.5fr)

      //Beschreibung
      align(center, text(
        font: "Noto Sans",
        transl("Practicalpaper"),
      ))
      align(center, text(module, weight: "bold"))
      v(1.5fr)

      align(center, transl("Wordcount") + ": " + [#word-count-of(body).words])

      //Datum
      align(center, text(
        1.1em,
        font: "Noto Sans",
        transl("Date") + ": " + date,
      ))
      v(2.4fr)
      pagebreak()
    },
    body,
  )
}
