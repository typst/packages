#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "@preview/transl:0.2.0"
#import "/lib/base.typ": *

#let thesis(
  //Settings der Template
  language: "de",
  sans-font: "Noto Sans",
  serif-font: "Times New Roman",
  title: "",
  author: "",
  keywords: "",
  description: "",
  degree-program: "",
  bachelor-type: "Science",
  study-group: "",
  student-id: "",
  contact-details: ("", "", ""),
  academic-reviewer: "",
  company-reviewer: "",
  submission-date: "31.07.2025",
  header-logo: none,
  company-logo: none,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-list-of-code: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  restriction-notice: transl("RestrictionNotice1")
    + transl("paper")
    + transl("RestrictionNotice2"),
  foreword: [],
  gendering-note: transl("GenderingNote"),
  body,
) = {
  base-project(
    type: "thesis",
    language: language,
    sans-font: sans-font,
    serif-font: serif-font,
    title: title,
    authors: (
      (name: author, student-id: student-id),
    ),
    keywords: keywords,
    description: description,
    study-group: study-group,
    contact-details: contact-details,
    academic-reviewer: academic-reviewer,
    company-reviewer: company-reviewer,
    submission-date: submission-date,
    company-logo: company-logo,
    show-list-of-figures: show-list-of-figures,
    show-list-of-code: show-list-of-code,
    acronyms: acronyms,
    appendix: appendix,
    glossary: glossary,
    bibliography: bibliography,
    restriction-notice: restriction-notice,
    foreword: foreword,
    gendering-note: gendering-note,
    {
      set page(
        background: if header-logo != none {
          align(top, header-logo)
        } else { none },
        margin: (top: 45mm),
      )

      // Title page.
      v(0.0fr)
      // Title
      set par(leading: .7em)
      align(center, par(
        text(12pt, weight: 700, title, hyphenate: false),
        justify: false,
      ))
      v(2fr, weak: true)
      if company-logo != none {
        align(center, company-logo)
      }
      v(1fr)
      align(center, [
        #transl("Thesis") \
        #transl("forDegree") \
        Bachelor of #bachelor-type \ \
        Im Studiengang #degree-program \
        an der Berufsakademie Rhein-Main

      ])
      v(2fr, weak: true)
      pad(top: 0.7em, grid(
        columns: (2fr, 2fr),
        gutter: 1em,
        [#transl("SubmittedBy"):], [#author],
        [#transl("StudyGroup"): ], [#study-group],
        [#transl("StudentId"):], [#student-id],
        [#transl("ContactDetails"):], [#contact-details.at(0)],
        [], [#contact-details.at(1)],
        [], [#contact-details.at(2)],
        [], [],
        [#transl("Wordcount"):],
        [#word-count-of(body, exclude: (heading, figure)).words],

        [#transl("wordcountIncludingCites")], [],
        [#transl("Wordcount"):],
        [#word-count-of(body, exclude: (
          heading,
          figure,
          quote,
          cite,
          footnote,
        )).words],

        [(exkl. wörtliche Zitate / Fußnoten)], [],
        [], [],
        [#transl("AcademicReviewer"):], [#academic-reviewer],
        [#transl("CompanyReviewer"):], [#company-reviewer],
        [], [],
        [#transl("SubmissionDate"):], [#submission-date],
      ))
      pagebreak()
    },
    body,
  )
}
