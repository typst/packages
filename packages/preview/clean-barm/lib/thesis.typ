#import "/lib/import.typ": *
#import "/lib/common.typ": *
#import "@preview/transl:0.2.0"
#import "/lib/base.typ": *

#let Thesis(
  //Settings der Template
  language: "de",
  title: "",
  author: "",
  keywords: "",
  description: "",
  degreeProgram: "",
  studyGroup: "",
  studentId: "",
  contactDetails: ("", "", ""),
  academicReviewer: "",
  companyReviewer: "",
  submissionDate: "31.07.2025",
  headerLogo: none,
  companyLogo: none,
  showListOfFigures: true,
  showListOfTables: true,
  showListOfCode: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  restrictionNotice: transl("RestrictionNotice1")
    + transl("Paper")
    + transl("RestrictionNotice2"),
  foreword: [],
  genderingNote: transl("GenderingNote"),
  body,
) = {
  baseProject(
    _type: "thesis",
    language: language,
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
    companyLogo: companyLogo,
    showListOfFigures: showListOfFigures,
    showListOfCode: showListOfCode,
    acronyms: acronyms,
    appendix: appendix,
    glossary: glossary,
    bibliography: bibliography,
    restrictionNotice: restrictionNotice,
    foreword: foreword,
    genderingNote: genderingNote,
    {
      set page(
        background: if headerLogo != none {
          align(top, headerLogo)
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
      if companyLogo != none {
        align(center, companyLogo)
      }
      v(1fr)
      align(center, [
        #transl("Thesis") \
        #transl("forDegree") \
        Bachelor of Science \ \
        Im Studiengang #degreeProgram \
        an der Berufsakademie Rhein-Main

      ])
      v(2fr, weak: true)
      pad(top: 0.7em, grid(
        columns: (2fr, 2fr),
        gutter: 1em,
        [#transl("SubmittedBy"):], [#author],
        [#transl("StudyGroup"): ], [#studyGroup],
        [#transl("StudentId"):], [#studentId],
        [#transl("ContactDetails"):], [#contactDetails.at(0)],
        [], [#contactDetails.at(1)],
        [], [#contactDetails.at(2)],
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
        [#transl("AcademicReviewer"):], [#academicReviewer],
        [#transl("CompanyReviewer"):], [#companyReviewer],
        [], [],
        [#transl("SubmissionDate"):], [#submissionDate],
      ))
      pagebreak()
    },
    body,
  )
}
