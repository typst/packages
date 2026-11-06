// Global improts
// #import "@preview/glossarium:0.5.6": make-glossary, print-glossary, gls, glspl, register-glossary

// Global variables
#let fontys-purple-1 = rgb("663366")
#let fontys-purple-2 = rgb("B59DB5")
#let fontys-pink-1 = rgb("E5007D")
#let fontys-blue-1 = rgb("1F3763")
#let fontys-blue-2 = rgb("2F5496")

// Document function
#let fontys-paper(
  title: none,
  authors: none,
  authors-details: none,
  keywords: (),
  abstract: none,
  bibliography-file: none,
  citation-style: "ieee",
  date: datetime.today(),
  // terms-list: none,
  body,
) = {
  // Local imports
  import "@preview/cetz:0.3.4"

  if (type(authors) != type(authors-details) and authors-details != none) {
    panic("The list of authors should be of the same type as the list of author details (str | array)")
  }

  if ((type(authors) == array and type(authors-details) == array) and (authors.len() != authors-details.len())) {
    panic("The authors array should contain the same amount of elements as the authors details array")
  }

  let letter_array = (
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
  )

  // Set metadata
  set document(
    title: title,
    author: authors,
    description: abstract,
    keywords: keywords,
    date: date,
  )

  set text(size: 10pt)
  set heading(numbering: "I.A.")
  show heading: set text(size: 10pt, weight: "medium")
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): set text(size: 12pt)
  show heading.where(level: 2): set text(style: "italic", size: 11pt)

  // show: make-glossary
  // if terms-list != none {
  //   register-glossary(terms-list)
  // }

  set page(
    "a4",
    margin: (left: 1.5cm, right: 1.5cm),
    header: [
      #grid(
        columns: (1fr, 1fr),
        row-gutter: 10pt,
        grid.cell(align: left)[
          #context [
            #if (counter(page).get().at(0) != 1) {
              [
                #if (type(authors) == str) {
                  [#authors]
                } else {
                  [#authors.at(0)]
                  if ((type(authors) == str or (type(authors) == array and authors.len() == 1)) != true) {
                    [ et al.]
                  }
                }
              ]
            }
          ]
        ],
        grid.cell(align: right)[
          #context [
            #if (counter(page).get().at(0) != 1) {
              [#counter(page).get().at(0) of #counter(page).final().at(0)]
            }
          ]
        ],
        grid.cell(colspan: 2)[
          #context [
            #if (counter(page).get().at(0) != 1) {
              line(end: (100%, 0%), stroke: 0.4pt)
            }
          ]
        ],
      )
    ],
    background: [
      #context [
        #if (counter(page).get().at(0) == 1) {
          place(top + center)[
            #cetz.canvas({
              import cetz.draw: *
              merge-path(
                fill: gradient.linear(fontys-pink-1, fontys-purple-1, fontys-purple-1, fontys-purple-1),
                stroke: none,
                {
                  bezier((0, -1), (21, -2.5), (10, 0), (15, -2.5))
                  line((21, -2.5), (21, 0.25))
                  line((21, 0.25), (0, 0.25))
                  line((0, 0.25), (0, 0))
                },
              )
            })
          ]
          place(top + right, dx: -40pt, dy: 10pt)[
            #image("./assets/fontys_cut.png", height: 1.7cm)
          ]
        }
      ]
    ],
  )

  grid(
    columns: (1fr, 2.5fr),
    column-gutter: 3em,
    row-gutter: 1em,
    grid.cell(colspan: 2)[],
    grid.cell(
      colspan: 2,
      [
        #text(size: 18pt)[#strong[#title]
        ]
      ],
    ),
    grid.cell(colspan: 2)[],
    grid.cell(
      colspan: 2,
      [
        // Print authors
        #text(size: 10pt)[#strong[
            #if (type(authors) == str) {
              [#authors#super(letter_array.at(0))]
            } else {
              for index in range(authors.len()) {
                if (authors.at(index) == authors.at(authors.len() - 1)) {
                  [#authors.at(index)#if (authors-details != none) { [#super(letter_array.at(index))] }]
                } else {
                  [#authors.at(index)#if (authors-details != none) { [#super(letter_array.at(index))] }, ]
                }
              }
            }
          ]
        ]

        // Print authors' details
        #if (authors-details != none) {
          text(size: 8pt)[
            #if (type(authors-details) == str) {
              [#super(letter_array.at(0))#authors-details]
            } else {
              for index in range(authors-details.len()) {
                [#super(letter_array.at(index))#authors-details.at(index)#linebreak()]
              }
            }
          ]
        }
        #line(end: (100%, 0%), stroke: 0.4pt)
      ],
    ),
    [
      // Print keywords
      #text(tracking: 2pt, spacing: 200%)[ARTICLE INFO]
      #line(end: (100%, 0%), stroke: 0.4pt)
      #text(size: 8pt)[
        #emph[Keywords:]\
        #for value in keywords {
          [#value#linebreak()]
        }
      ]
    ],
    [
      // Print the abstract
      #text(tracking: 2pt)[ABSTRACT]
      #line(end: (100%, 0%), stroke: 0.4pt)
      #set par(
        justify: true,
        first-line-indent: (amount: 2em, all: true),
        spacing: 0.65em,
      )
      #abstract
    ],
    grid.cell(
      colspan: 2,
      [
        #line(end: (100%, 0%), stroke: 0.4pt)
      ],
    ),
  )

  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    spacing: 0.8em,
  )

  columns(2)[
    #body

    #if bibliography-file != none {
      set bibliography(title: "References", style: citation-style)
      bibliography-file
    }
  ]
}
