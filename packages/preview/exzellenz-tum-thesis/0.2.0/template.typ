#import "cover.typ": *
#import "titlepage.typ": *
#import "disclaimer.typ": *
#import "acknowledgement.typ": *
#import "abstract.typ": *


#let exzellenz-tum-thesis(
  degree: "The Degree",
  program: "The Program",
  school: "The School",
  examiner: "Your Supervisor",
  supervisors: ("The first supervisor", "The second supervisor"),
  author: "The Author",
  titleEn: "English Title",
  titleDe: "German Title",
  abstractText: none,
  acknowledgements: none,
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
    examiner: examiner,
    supervisors: supervisors,
    author: author,
    submissionDate: draft_string + submissionDate
  )

  disclaimer(
    title: titleEn,
    degree: degree,
    author: author,
    submissionDate: submissionDate
  )
  if acknowledgements != none {
    acknowledgement(acknowledgements)
  }

  abstract(abstractText)

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