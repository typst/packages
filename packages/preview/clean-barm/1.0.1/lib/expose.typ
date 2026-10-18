#import "@preview/transl:0.2.0": transl
#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "/lib/base.typ": *

#let expose(
  //Settings der Template
  language: "de",
  sans-font: "Noto Sans",
  serif-font: "Times New Roman",
  title: "",
  author: "",
  keywords: (),
  description: "",
  study-group: "",
  contact-details: (
    "",
    "",
    "",
  ),
  student-id: "",
  academic-reviewer: "",
  company-reviewer: "",
  date-of-colloquium: "",
  submission-date: "",
  logo: none,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-list-of-code: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  restriction-notice: transl("RestrictionNotice1")
    + " "
    + transl("Paper")
    + " "
    + transl("RestrictionNotice2"),
  foreword: none,
  gendering-note: transl("gendering-note"),
  body,
) = {
  base-project(
    type: "expose",
    language: language,
    sans-font: sans-font,
    serif-font: serif-font,
    title: title,
    authors: (
      (name: author, student-id: studentId),
    ),
    keywords: keywords,
    description: description,
    study-group: study-group,
    contact-details: contact-details,
    academic-reviewer: academic-reviewer,
    company-reviewer: company-reviewer,
    submission-date: submission-date,
    university-logo: logo,
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
      // Title page.
      v(0.0fr)
      // Titel
      align(center, par(
        text(12pt, weight: 700, title, hyphenate: false),
        justify: false,
      ))
      v(2fr, weak: true)
      if logo != none {
        align(center, logo)
      }
      v(2fr)

      //Beschreibung
      align(
        center,
        text(
          size: 12pt,
          transl("exposeTitle") + ":",
        ),
      )
      v(1fr)
      align(
        center,
        text(
          size: 12pt,
          submission-date,
        ),
      )
      v(1.5fr)

      pad(
        top: 0.7em,
        grid(
          columns: (2fr, 2fr),
          gutter: 1em,
          [#transl("StudyGroup"): ], [#study-group],
          [#transl("SubmittedBy"):], [#author],
          [#transl("Wordcount"):],
          [#word-count-of(body, exclude: (
            heading,
            figure.caption,
            <no-wordcount>,
          )).words],

          [#transl("wordcountIncludingCites")], [],
          [#transl("Wordcount"):],
          [#word-count-of(body, exclude: (
            heading,
            figure.caption,
            cite,
            footnote,
            <no-wordcount>,
          )).words],

          [#transl("wordcountExcludingCites")], [],
          [#transl("AcademicReviewer"):], [#academic-reviewer],
          [#transl("CompanyReviewer"):], [#company-reviewer],
          [#transl("SubmissionDate"):], [#submission-date],
        ),
      )
      v(1.5fr)
      pagebreak(weak: true)
    },
    body,
  )
}
