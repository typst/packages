/*
Core formatting for the template document type. Establishes general document-wide formatting, and creates the header for the resume.

Inspired by the template from the `guided-resume-starter-cgc` v2.0.0 package:
https://github.com/typst/packages/blob/2da94b0f21174ae8366834332a6e44fd966de4dd/packages/preview/guided-resume-starter-cgc/2.0.0/template/templates/resume.template.typ
*/

#let resume(
  author: "",
  location: "",
  contacts: (),
  summary: "",
  theme-color: rgb("#26428b"),
  font: "New Computer Modern",
  font-size: 11pt,
  lang: "en",
  margin: (
    top: 1cm,
    bottom: 0cm,
    left: 1cm,
    right: 1cm,
  ),
  body,
) = {

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    font: font,
    size: font-size,
    lang: lang,
    ligatures: false,  // Disable ligatures for better compatibility and readability
  )

  set page(
    margin: margin,
  )

  show link: set text(
    fill: rgb("#0645AD")
  )
  
  // Accent Color Styling
  show heading: set text(
    fill: rgb(theme-color),
  )

  // Header parameters, including author and contact information.
  show heading: it => [
    #pad(top: -0.3em, bottom: -0.8em, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]
  
  // Author
  align(center)[
    #block(text(weight: 700, 2.5em, [#smallcaps(author)]))
  ]

  // Contact Information
  align(center)[
    #[#contacts.join("  |  ")]
  ]

  // Location
  if location != "" {
    align(center)[
      #smallcaps[#location]
    ]
  }

  // Professional summary
  if summary != "" {
    pad(
      top: 0em,
      align(center)[
        #summary
      ]
    )
  }

  // Main body.
  set par(
    justify: true,
  )

  body
}

/*
Education section formatting, allowing enumeration of degrees and GPA. 
`hide` flag to allow for hiding individual Education entries.
*/
#let edu(
  institution: "",
  date: "",
  degrees: (),
  gpa: "",
  location: "",
  extra: "",
  hide: false,
  
) = {
  if hide {
    return
  }
  pad(
    bottom: -0em,
    grid(
      columns: (auto, 1fr),
      align(left)[
        #strong[#institution]
        #{
          if gpa != "" [
            | #emph[GPA: #gpa]
          ]
        }
        \ 
        #{
          for degree in degrees [
            #strong[#degree.at(0)] | #emph[#degree.at(1)] \
          ]
        }
        #{
          if extra != "" [
            #emph[#strong[#extra]]
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
    area.at(1).join(", ")
    linebreak()
  }
}

/*
Experience section formatting logic.
`hide` flag to allow for hiding individual Experience entries.
*/
#let exp(
  title: "",
  organization: "",
  date: "",
  location: "",
  details: [],
  hide: false,
) = {
  if hide {
    return
  }
  pad(
    bottom: -0.3em,
    grid(
      columns: (auto, 1fr),
      align(left)[
        #strong[#title] \
        #emph[#organization]
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

/*
Publication section formatting logic.
`hide` flag to allow for hiding individual Publication entries.
*/
#let pub(
  authors: (),
  bold-author: "",
  title: "",
  venue: "",
  year: "",
  doi-link: "",
  extra: "",
  hide: false,
) = {
  if hide {
    return
  }

  // Bold the specified author
  let fmt-authors = authors.map(
    a => if a == bold-author { 
      strong[#a] 
    } else { 
      a 
    }
  )

  // Link the doi or link to the publication title for the cv style
  let fmt-link = if doi-link != "" {
    link("https://" + doi-link)[#quote(title)]
  } else {
    quote(title)
  }

  // Citation formatting logic
  let citation = [
    #{
      fmt-authors.join(", ") + ", " + fmt-link + ", " + emph(venue) + ", " + year + "." + if extra != "" { " " + strong[#extra] }
    }
  ]

  pad(
    bottom: -0.3em,
    align(left)[
      #citation
    ]
  )
}

/*
Publication list section formatting logic based on a BibLaTeX .bib or a Hayagriva .yml file.
for style options, see: https://typst.app/docs/reference/model/bibliography/
*/
#let pub-list(
  bib: "", 
  style: "ieee", 
  ) = {
  let publicationStyle(str) = {
    text(str)
  }
  show bibliography: it => publicationStyle(it)
  set bibliography(title: none, style: style, full: true)
  bib
}
