#import "cover.typ": *
#import "titlepage.typ": *
#import "disclaimer.typ": *
#import "acknowledgement.typ": *
#import "abstract.typ": *


#let exzellenz-tum-thesis(
  degree: "The degree",
  program: "The Program",
  supervisor: "Your Supervisor",
  advisors: ("The first advisor", "The second advisor"),
  author: "The Author",
  startDate: "The Startdate",
  titleEn: "English Title",
  titleDe: "German Title",
  abstractEn: [English Abstract],
  abstractDe: [German Abstract],
  acknowledgements: [The acknowledgements],
  submissionDate: "(Handover Date)",
  showTitleInHeader: true,
  draft: true,
  body,
) = {

  let draft_string = ""
  if draft{
    draft_string = "DRAFT - "
  }

  set document(author: author, title: draft_string + titleEnglish)
  set page(
    numbering: "1",
    number-align: center,
    margin: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
    header: [
      #set text(8pt)
      #if showTitleInHeader [
        #author - #titleEnglish
      ]
      #h(1fr)
      #if draft [
        DRAFT
      ]
    ],
  )

  set page(numbering: none)
  set text(font: "New Computer Modern Sans")

  cover(
    title: draft_string + titleEnglish,
    degree: degree,
    program: program,
    author: author,
  )

  titlepage(
    title: draft_string + titleEnglish,
    titleGerman: titleGerman,
    degree: degree,
    program: program,
    supervisor: supervisor,
    advisors: advisors,
    author: author,
    startDate: startDate,
    submissionDate: draft_string + submissionDate
  )

  disclaimer(
    title: titleEnglish,
    degree: degree,
    author: author,
    submissionDate: submissionDate
  )

  acknowledgement(acknowledgements)

  abstract(lang: "en")[#abstract_en]

  abstract(lang: "de")[#abstract_de]

  counter(page).update(1)

  body

}