/*
This copy of the resume formatting template is provided in the template download in case
you'd like to make your preferred edits to the template directly.

If you'd like to use this copy instead of the package, you'll need to update the #import
statement in your resume.typ file to reference this file directly.

Have you made edits or bug fixes to this template that you feel would help out others?
It would be fantastic if you submitted a pull request to the template repository at
https://github.com/chaoticgoodcomputing/typst-resume-starter !
*/

/*
Core formatting for the template document type. Establishes general document-wide formatting,
and creates the header and footer for the resume.
*/
#let resume(
  author: "",
  location: "",
  contacts: (),
  body
) = {

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    font: "New Computer Modern",
    size: 11pt,
    lang: "en"
  )

  set page(
    margin: (
      top: 1.25cm,
      bottom: 0cm,
      left: 1.5cm,
      right: 1.5cm
    ),
  )

  show link: set text(
    fill: rgb("#0645AD")
  )
  
  // Header parameters, including author and contact information.
  show heading: it => [
    #pad(top: 0pt, bottom: -15pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]

  // Author
  align(center)[
    #block(text(weight: 700, 2.5em, [#smallcaps(author)]))
  ]

  // Contact
  pad(
    top: 0.25em,
    align(center)[
      #smallcaps[#contacts.join("  |  ")]
    ],
  )

  // Location
  if location != "" {
    align(center)[
      #smallcaps[#location]
    ]
  }

  // Main body.
  set par(justify: true)

  body
}

/*
Allows hiding or showing full resume dynamically using global variable. This can
be helpful for creating a single document that can be rendered differently depending on
the desired output, for cases where you'd like to simultaneously render both a full copy
and a single-page instance of only the most important or vital information.
*/
#let hide(should-hide, content) = {
  if not should-hide {
    content
  }
}

/*
Education section formatting, allowing enumeration of degrees and GPA
*/
#let edu(
  institution: "",
  date: "",
  degrees: (),
  gpa: "",
  location: ""
) = {
  pad(
    bottom: 10%,
    grid(
      columns: (auto, 1fr),
      align(left)[
        #strong[#institution]
        #{
          if gpa != "" [
            | #emph[GPA: #gpa]
          ]
        }
        \ #{
          for degree in degrees [
            #strong[#degree.at(0)] | #emph[#degree.at(1)] \
          ]
        }
      ],
      align(right)[
        #emph[#date]
        #{
          if location != "" [
            \ #emph[#location]
          ]
        }
      ]
    )
  )
}

/*
Skills section formatting, responsible for collapsing individual entries into
a single list.
*/
#let skills(areas) = {
  for area in areas {
    strong[#area.at(0): ]
    area.at(1).join(" | ")
    linebreak()
  }
}

/*
Experience section formatting logic.
*/
#let exp(
  role: "",
  project: "",
  date: "",
  location: "",
  summary: "",
  details: []
) = {
  pad(
    bottom: 10%,
    grid(
      columns: (auto, 1fr),
      align(left)[
        #strong[#role] | #emph[#project]
        #{
          if summary != "" [
            \ #emph[#summary]
          ]
        }
      ],
      align(right)[
        #emph[#date]
        #{
          if location != "" [
            \ #emph[#location]
          ]
        }
      ]
    )
  )
  details
}