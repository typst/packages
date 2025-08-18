// ============================
// CONFIGURATION
// ============================

#let report(
  title: none,
  authors: none,
  student-info: none,
  lab-description: none,
  body,
) = {
  // Check if all mandatory variables are defined.
  if title == none {
    panic("The `title` variable must be defined. It should be a string representing the title of the report.")
  }

  if authors == none {
    panic(
      "The `authors` variable must be defined. It should be a list of strings representing the authors of the report.",
    )
  }

  if student-info == none {
    panic("The `student-info` variable must be defined. It should be a string with the student's information.")
  }

  if labDescription == none {
    panic("The `labDescription` variable must be defined. It should be a string describing the lab.")
  }

  set document(author: authors, title: title)

  set page(paper: "a4", margin: auto, number-align: center)

  // if "weak: true", the page break is skipped if the current page is already empty
  set pagebreak(weak: true)

  set text(font: "New Computer Modern", size: 10pt, lang: "fr", region: "fr")
  // for English: lang: 'en' and region: 'us'
  // For other languages/regions, refer to this page:
  // lang: https://en.wikipedia.org/wiki/ISO_639
  // region: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

  // Display links in blue.
  show link: set text(fill: blue.darken(40%))

  set heading(numbering: "I.1.a.")
  show heading: set text(hyphenate: false)
  show heading: set par(justify: false)

  // Config. of the spacing after headings
  show heading.where(level: 1): set block(spacing: 1.5em)
  show heading.where(level: 2): set block(spacing: 1.25em)
  show heading.where(level: 3): set block(spacing: 1em)

  show heading: it => [
    #underline()[#it]
  ]

  show underline: set underline(stroke: 1pt, offset: 2pt)
  set list(indent: 15pt, marker: [--]) // config. of lists

  set math.equation(numbering: "(1)")

  show figure.where(kind: image): set figure(supplement: "Figure")

  // Configure the figure caption alignment:
  // if figure caption has more than one line,
  // it makes it left-aligned
  show figure.caption: it => {
    layout(size => [
      #let text-size = measure(it.supplement + it.separator + it.body)
      #let my-align
      #if text-size.width < size.width {
        my-align = center
      } else {
        my-align = left
      }
      #align(my-align, text(size: 8pt)[#emph(it)])
    ])
  }

  // Configure the raw block properties
  show raw.where(block: true): set par(justify: false)

  // // From the INSA Typst Template by SkytAsul:
  // // https://github.com/SkytAsul/INSA-Typst-Template
  // show raw.line: it => if it.count > 1 {
  //   text(fill: luma(150), str(it.number)) + h(2em) + it.body
  // } else { it }

  // First page configuration
  align(center + horizon)[
    #block(text(weight: 700, size: 22pt, [*ENSEA*]))

    #block(
      text(
        weight: 700,
        size: 16pt,
        [*École Nationale Supérieure de l'Électronique et de ses Applications*],
      ),
    )

    #linebreak()
    #stack(
      dir: ltr, // left-to-right
      spacing: 5em, // space between contents
      image("assets/logo-ENSEA.png", height: 40mm),
    )

    #linebreak()
    #block(text(weight: 700, size: 22pt, title))

    #linebreak()
    #block(
      text(
        weight: 700,
        size: 16pt,
        [#(
          authors.map(strong).join(", ", last: " et ")
        )],
      ),
    )

    #block(text(weight: 400, size: 14pt, student-info))

    #align(left)[
      #linebreak()
      #block(
        text(
          weight: 400,
          size: 12pt,
          [#underline[*Objectifs*] : #labDescription],
        ),
      )
    ]
  ]

  pagebreak()
  set par(justify: true)

  // Definition of the following pages with different margins
  set page(
    margin: (top: 70pt, bottom: 1.5cm),
    numbering: "1/1",
    header-ascent: 10pt,
    footer-descent: 10pt,
    header: context [
      #stack(
        dir: ltr,

        align(left + horizon, image("assets/logo-ENSEA.png", height: 12mm)),

        align(right + bottom)[
          #text(size: 8pt)[
            #box(width: 88%)[
              #title
            ]]
        ],
      )
      #box(width: 100%, height: 1pt, fill: black)
    ],

    footer: context [
      #place(top + left, dy: -5pt, box(width: 100%, height: 1pt, fill: black))
      #stack(
        dir: ltr,

        align(left + top)[#text(size: 8pt)[
          #box(width: 85%)[#(
            authors.join(", ", last: " et ")
          )]]],

        align(right + top)[#text(size: 8pt)[
          #box(width: 8%)[
            #counter(page).display(both: true)
          ]
        ]],
      )
    ],
  )
  counter(page).update(1)
  body
}
