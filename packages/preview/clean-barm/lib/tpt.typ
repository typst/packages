#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "/lib/base.typ": *

#let TPT(
  //Settings der Template
  title: "",
  preThesis: true,
  authors: (),
  keywords: (),
  description: "",
  studyGroup: "",
  date: "01.01.2024",
  logo: none,
  module: [Theorie-Praxis-Anwendung II],
  showListOfFigures: true,
  showListOfTables: true,
  showListOfCode: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  //Vorgeschriebene e
  restrictionNotice: transl("RestrictionNotice1")
    + transl("Paper")
    + transl("RestrictionNotice2"),
  foreword: [],
  genderingNote: transl("GenderingNote"),
  body,
) = {
  baseProject(
    _type: "tpt",
    title: title,
    authors: authors,
    keywords: keywords,
    description: description,
    studyGroup: studyGroup,
    submissionDate: date,
    universityLogo: logo,
    module: module,
    showListOfFigures: showListOfFigures,
    showListOfTables: showListOfTables,
    showListOfCode: showListOfCode,
    acronyms: acronyms,
    appendix: appendix,
    glossary: glossary,
    bibliography: bibliography,
    restrictionNotice: restrictionNotice,
    foreword: foreword,
    genderingNote: genderingNote,
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
            if preThesis { transl("PracticalDocs") } else {
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
            [#author.name (#author.studentId)],
          ))),
        ),
      )
      v(1.5fr)

      //Beschreibung
      align(center, text(
        font: "Noto Sans",
        transl("PracticalPaper"),
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
