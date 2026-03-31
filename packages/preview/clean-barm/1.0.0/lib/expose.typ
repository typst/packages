#import "@preview/transl:0.2.0": transl
#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "/lib/base.typ": *

#let Expose(
  //Settings der Template
  title: "",
  author: "",
  keywords: (),
  description: "",
  studyGroup: "",
  contactDetails: (
    "",
    "",
    "",
  ),
  studentId: "",
  academicReviewer: "",
  companyReviewer: "",
  dateOfColloquium: "",
  submissionDate: "",
  logo: none,
  showListOfFigures: true,
  showListOfTables: true,
  showListOfCode: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  //Vorgeschriebene Texte
  restrictionNotice: transl("RestrictionNotice1")
    + transl("Paper")
    + transl("RestrictionNotice2"),
  foreword: none,
  genderingNote: transl("genderingNote"),
  body,
) = {
  baseProject(
    _type: "expose",
    title: title,
    authors: (
      (name: author, studentId: studentId),
    ),
    keywords: keywords,
    description: description,
    studyGroup: studyGroup,
    contactDetails: contactDetails,
    academicReviewer: academicReviewer,
    companyReviewer: companyReviewer,
    submissionDate: submissionDate,
    universityLogo: logo,
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
          submissionDate,
        ),
      )
      v(1.5fr)

      pad(
        top: 0.7em,
        grid(
          columns: (2fr, 2fr),
          gutter: 1em,
          [#transl("StudyGroup"): ], [#studyGroup],
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
          [#transl("AcademicReviewer"):], [#academicReviewer],
          [#transl("CompanyReviewer"):], [#companyReviewer],
          [#transl("SubmissionDate"):], [#submissionDate],
        ),
      )
      v(1.5fr)
      pagebreak(weak: true)
    },
    body,
  )
}
