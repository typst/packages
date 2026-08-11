/// Apply the cv layout to the document.
/// Sets up a header for the front page.
/// Additional sections should be created using other functions, such as `exp` and `edu`.
/// -> content
#let cv(
  /// The person to be listed at the top of the CV.
  /// This is probably where your name goes.
  /// -> content
  author: "",
  /// Your address, preferably in two-line format. -> str | content
  address: "",
  /// A list of contact information. Email, GitHub, and LinkedIn are all good things to put here. -> array
  contacts: (),
  /// Date updated. -> datetime | str
  updated: datetime.today(),
  /// The content of the cv. -> content
  body,
) = {
  // Sets document metadata
  set document(author: author, title: author, date: updated)

  // Document-wide formatting, including font and margins
  set text(
    size: 11pt,
    lang: "en",
  )

  set page(
    margin: (
      top: 1.25cm,
      bottom: 1.25cm,
      left: 1.5cm,
      right: 1.5cm,
    ),
    footer: [
      #align(center)[
        #author -- CV -- #context { counter(page).display("1 of 1", both: true) }
      ]
    ],
  )

  // shrink headings
  show heading: it => text(size: 12pt, it.body)
  show heading.where(level: 1): it => pad(bottom: 12pt, smallcaps(it))
  show heading.where(level: 2): it => pad(bottom: 0pt, it)

  // show heading.where(level: 1): it => [
  //   #pad(top: 0pt, bottom: -15pt, text(size: 12pt)[#smallcaps(it.body)])
  //   #line(length: 100%, stroke: 1pt)
  // ]
  //
  // show heading.where(level: 2): it => text(size: 12pt, it.body)

  // Author
  align(center)[
    #block(text(size: 14pt, weight: 700, [#smallcaps(author)]))
  ]

  // Contact
  pad(
    top: 2pt,
    align(center)[
      #smallcaps[#contacts.join("  |  ")]
    ],
  )

  // Location
  if location != none {
    align(center)[
      #smallcaps[#address]
    ]
  }

  // Main body.
  set par(justify: true)

  body
}


/// Create an education entry, suitable for one degree and accompanying information.
/// -> content
#let edu(
  /// Degree-granting institution. -> str | content
  institution: "",
  /// Date of graduation / attaining degree. -> str | datetime
  date: "",
  /// Degrees obtained.
  /// Majors are traditionally listed directly with the degree type.
  /// Minors might be listed as an additional entry in the array:
  /// `([Degree], [Minor: Basketweaving])`
  /// -> array
  degrees: (),
  /// Location of institution. -> str | content
  location: "",
  /// (optional) GPA and additional honors. -> str | content
  gpa: "",
  /// (optional) Additional details. -> str | content
  details: "",
) = {
  [#grid(
      columns: (auto, 1fr),
      align(left)[
        #{
          for degree in degrees [
            #strong[#degree] \
          ]
        }
        #institution
        \ #{
          if gpa != "" [
            GPA: #gpa
          ]
        }
      ],
      align(right)[
        #{ if location != "" { location } }
        #{
          if type(date) == datetime [
            // parse datatime variables into nicely formatted dates
            \ #date.display("[month repr:long] [year]")
          ] else [
            // or allow strings for cases like expected graduation date
            \ #date
          ]
        }
      ],
    )
    #{ if details != "" [#details] }
  ]
}


/// Create an entry detailing work experience.
/// -> content
#let exp(
  /// Role at the organization. -> str
  role: "",
  /// Organization that the work took place at. -> str
  org: "",
  /// Start date of employment. -> datetime | str | none
  start: "",
  /// End date of employment. -> datetime | str | none
  end: "",
  /// Location that the work took place at.
  /// List where you actually worked, rather than where the company's main office might be.
  /// -> str
  location: "",
  /// One-sentence summary of the work. -> str | none
  summary: "",
  /// Detailed description of the work, traditionally in bullet points.
  /// -> content | none
  details: [],
) = {
  [#grid(
      columns: (auto, 1fr),
      align(left)[
        #strong[#role]
        \ #org
        #{
          if summary != "" [
            \ #summary
          ]
        }
      ],
      align(right)[
        #{
          if location != "" [
            #location
          ]
        }
        #text[
          \ #{
            if type(start) == datetime {
              start.display("[month repr:long] [year]")
            } else { start }
          } #{
            if end != "" [
              #{
                if type(end) == datetime {
                  end.display("- [month repr:long] [year]")
                } else [\- #end]
              }
            ]
          }]
      ],
    ) #details]
}


/// Create an entry detailing service to the field.
/// -> content
#let ser(
  /// Role in which you served. -> str
  role: "",
  /// Organization that the service was done with. -> str | none
  org: "",
  /// Start date of work. -> datetime | str | none
  start: "",
  /// End date of work. -> datetime | str | none
  end: "",
  /// One-sentence summary of work. -> str | none
  summary: none,
) = {
  grid(
    columns: (auto, 1fr),
    align(left)[
      #org, #strong[#role]
      #{
        if summary != none [
          \ #summary
        ]
      }
    ],
    align(right)[
      #text[
        #{
          if type(start) == datetime {
            start.display("[month repr:long] [year]")
          } else { start }
        } #{
          if end != "" [
            #{
              if type(end) == datetime {
                end.display("- [month repr:long] [year]")
              } else [\- #end]
            }
          ]
        }]
    ],
  )
}


/// Creates an entry for an award, such as a scholarship or fellowship.
/// -> content
#let award(
  /// The name of the award. If it is a specific grant, the identifier can also go here. -> content | str | none
  name: "",
  /// Date the award was given. -> datetime | str | none
  date: "",
  /// Institution that granted the award. -> content | str | none
  from: "",
  /// (optional) Amount of the award. -> content | str | int | none
  amt: "",
  /// (optional) Detailed description of the award. -> content | str | none
  details: "",
) = {
  grid(
    columns: (3em, auto, 3em),
    align(left)[
      #{ if type(date) == datetime [#date.display("[year]")] else [#date] }
    ],
    align(left)[
      #strong[#name,] #text[#from. #details]
    ],
  )
}


/// Skills section formatting, responsible for collapsing individual entries into a single list.
/// -> content
#let skills(
  /// A list of skills in a particular area.
  /// -> array(str, array)
  areas,
) = {
  for area in areas {
    strong[#area.at(0): ]
    area.at(1).join(" | ")
    linebreak()
  }
}


