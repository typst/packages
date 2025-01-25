#import "cover.typ": *
#import "titlepage.typ": *
#import "disclaimer.typ": *
#import "acknowledgement.typ": *
#import "abstract.typ": *


#let exzellenz-tum-thesis(
  degree: "The degree",
  program: "The Program",
  school: "The School",
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

  set document(author: author, title: draft_string + titleEn)
  set page(
    numbering: "1",
    number-align: center,
    margin: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
    header: {
      set text(8pt)
      h(1fr)
      if draft [
        DRAFT
      ]
    },
  )

  set page(numbering: none)

  cover(
    title: draft_string + titleEn,
    degree: degree,
    program: program,
    author: author,
    school: school
  )

  titlepage(
    title: draft_string + titleEn,
    titleDe: titleDe,
    degree: degree,
    program: program,
    school: school,
    supervisor: supervisor,
    advisors: advisors,
    author: author,
    startDate: startDate,
    submissionDate: draft_string + submissionDate
  )

  disclaimer(
    title: titleEn,
    degree: degree,
    author: author,
    submissionDate: submissionDate
  )

  acknowledgement(acknowledgements)

  abstract(lang: "en")[#abstractEn]

  abstract(lang: "de")[#abstractDe]

  counter(page).update(1)


  set page(
    header: {
      set text(8pt)
      if showTitleInHeader [
        #author - #titleEn
      ]
      h(1fr)
      if draft [
        DRAFT
      ]
    },
  )

  body

}