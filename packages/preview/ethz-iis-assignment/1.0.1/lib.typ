// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// An IIS Assignment Template for Typst

#import "appendix.typ": appendix
#import "shared/utils.typ": current-semester, eth-header, fieldpar

// The possible thesis types
#let thesis-types = ("group", "semester", "bachelor", "master")

// Helper function to return duration of a thesis.
// Note: duration does not accept months, and master thesis
// is calculated as 6 x 4 weeks
#let thesis-duration(projecttype) = {
  if lower(projecttype) == "master" {
    duration(weeks: 24)
  } else {
    duration(weeks: 14)
  }
}

// The actual assignment template
#let assignment(
  // The title of the thesis
  title: none,
  // The name of the student
  student: none,
  // The mail of the student(s)
  email: none,
  // The type of project : "group" | "semester" | "bachelor" | "master"
  projecttype: none,
  // The semester it takes place
  semester: current-semester(),
  // Array of (name, office, email)
  advisors: none,
  // Array of (name, office, email)
  professors: none,
  //ritable
  handoutdate: datetime.today(),
  // Defaults to handoutdate + thesis-duration(type), but overwritable
  duedate: none,
  // Bibliography content, e.g. bibliography("references.bib", style: "ieee", full: true)
  bibliography: none,
  // The actual body of the assignment
  body,
) = {
  // Resolve missing parameters
  let title = if title != none { title } else { fieldpar[title] }
  let student = if student != none { student } else { fieldpar[student name] }
  let advisors = if advisors != none { advisors } else {
    ((name: fieldpar[Advisor], office: "", mail: ""),)
  }
  if professors == none {
    professors = ((name: fieldpar[Professor], office: "", mail: ""),)
  }

  // Validate that project type is valid...
  if projecttype != none {
    assert(projecttype in thesis-types)
  }
  // ... or notify user
  if projecttype == none {
    projecttype = fieldpar[project type]
  }

  // If due date is not specified, calculate it
  if duedate == none and projecttype != none {
    duedate = handoutdate + thesis-duration(projecttype)
  }

  // General page, typography settings
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 25mm, left: 30mm, right: 30mm),
  )
  set text(size: 12pt, lang: "en")
  set par(justify: true)
  // Indent all list items slightly
  set list(indent: 1em)

  // Color all links as blue (e.g. email addresses)
  show link: set text(fill: blue)

  // Heading styles
  set heading(numbering: "1.1")
  show heading.where(level: 1): set text(size: 20pt, weight: "bold")
  show heading.where(level: 2): set text(size: 16pt, weight: "bold")
  // Level 3: paragraph heading — bold inline text followed by em-space
  show heading.where(level: 3): it => {
    text(weight: "bold", it.body)
    h(1em)
  }

  // The cover page of the assignment
  page(
    header: eth-header,
    {
      v(10%)

      // Center align the description text in smallcaps
      align(center, smallcaps(text(size: 14pt)[
        Assignment for a\
        #text(size: 24pt)[#projecttype thesis]\
        at the Integrated Systems Laboratory\
        #v(1em)
        #semester
      ]))

      v(1fr)
      // Name of the student
      align(center, text(size: 18pt, student))
      v(3em)
      // The title of the thesis
      align(center, text(size: 24pt, weight: "bold", title))
      v(3em)
      // The current date
      align(center, text(
        size: 12pt,
        datetime.today().display("[month repr:long] [day], [year]"),
      ))
      v(1fr)

      // List all the advisors
      [Advisors:]

      for advisor in advisors [
        #let adv-content = (
          advisor.name
            + ", "
            + advisor.office
            + ", "
            + link("mailto:" + advisor.mail)[#raw(advisor.mail)]
        )
        - #adv-content
      ]

      // List the professor(s)
      // List the professor(s)
      [Professor:]
      for professor in professors [
        - #professor.name, #link("mailto:" + professor.mail)[#raw(professor.mail)]
      ]

      // List the handout and due date
      [Handout: #handoutdate.display("[day].[month].[year repr:last_two]")]
      linebreak()
      [Due Date: #duedate.display("[day].[month].[year repr:last_two]")]

      v(3mm)

      text(size: 12pt)[
        The final report is to be submitted electronically.
        All copies remain property of the Integrated Systems Laboratory.
      ]
    },
  )

  // The actual body of the assignment
  body

  // The appendix with general guidelines and information about
  // the project realization, meetings, reports, etc.
  appendix(projecttype)

  // Print the bibliography (if provided)
  if bibliography != none {
    bibliography
  }

  v(3em)

  // The professor "signature" of the assignment, with the date and location
  table(
    columns: (65%, 35%),
    stroke: none,
    align: left,
    [Zurich, #datetime.today().display("[month repr:long] [day], [year]")],
    for professor in professors {
      professor.name
    },
  )
}
