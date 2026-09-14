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
  title-en: "English Title",
  title-de: "German Title",
  abstract-text: none,
  acknowledgements: none,
  submission-date: "(Handover Date)",
  show-title-in-header: true,
  draft: true,
  body,
) = {

  let draft_string = ""
  if draft{
    draft_string = "DRAFT - "
  }

  set document(author: author, title: draft_string + title-en)
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
    title: draft_string + title-en,
    degree: degree,
    program: program,
    author: author,
    school: school
  )

  titlepage(
    title: draft_string + title-en,
    title-de: title-de,
    degree: degree,
    program: program,
    school: school,
    examiner: examiner,
    supervisors: supervisors,
    author: author,
    submission-date: draft_string + submission-date
  )

  disclaimer(
    title: title-en,
    degree: degree,
    author: author,
    submission-date: submission-date
  )
  if acknowledgements != none {
    acknowledgement(acknowledgements)
  }

  abstract(abstract-text)

  set page(
    header: {
      set text(8pt)
      if show-title-in-header [
        #author - #title-en
      ]
      h(1fr)
      if draft [
        DRAFT
      ]
    },
  )

  body

}