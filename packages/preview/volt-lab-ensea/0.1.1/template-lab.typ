// Global variables
#let HEADING-LVL-1-SPACING = 1.5em
#let HEADING-LVL-2-SPACING = 1.25em
#let HEADING-LVL-3-SPACING = 1em

// ============================
// MAIN CONFIGURATION
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
    panic(
      "The `title` variable must be defined. It should be a string representing the title of the report.",
    )
  }

  if authors == none {
    panic(
      "The `authors` variable must be defined. It should be a list of strings representing the authors of the report.",
    )
  }

  if student-info == none {
    panic(
      "The `student-info` variable must be defined. It should be a string with the student's information.",
    )
  }

  if lab-description == none {
    panic(
      "The `lab-description` variable must be defined. It should be a string describing the lab.",
    )
  }

  set document(author: authors, title: title)

  set page(paper: "a4", margin: auto)

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
  show heading.where(level: 1): set block(below: HEADING-LVL-1-SPACING)
  show heading.where(level: 2): set block(below: HEADING-LVL-2-SPACING)
  show heading.where(level: 3): set block(below: HEADING-LVL-3-SPACING)

  // Config. of the spacing after the outline
  show outline: it => {
    show heading: it => it + v(HEADING-LVL-1-SPACING, weak: true)
    it
  }

  show heading: it => [
    #underline()[#it]
  ]

  show underline: set underline(stroke: 1pt, offset: 2pt)

  set list(indent: 15pt, marker: [--]) // config. of lists

  set math.equation(
    numbering: n => { strong(numbering("(1)", n)) },
  )

  show figure.where(kind: image): set figure(supplement: "Figure")

  show figure.caption: it => if not (it.numbering == none) {
    context text(
      [*#it.supplement #it.counter.display()* -- #it.body],
    )
  } else {
    context text(
      [#it.body],
    )
  }

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
      #align(my-align, text(size: 8pt)[#it])
    ])
  }

  // Configure the raw block properties
  show raw.where(block: true): set par(justify: false)

  // // From the INSA Typst Template by SkytAsul:
  // // https://github.com/SkytAsul/INSA-Typst-Template
  // show raw.line: it => if it.count > 1 {
  //   text(fill: luma(150), str(it.number)) + h(2em) + it.body
  // } else { it }

  // Contents configuration
  show outline.entry.where(
    level: 1,
  ): it => {
    // make level 1 headings bold
    if it.element.func() == heading {
      v(1em, weak: true)
      strong(it)
    } // make figure prefix bold
    else {
      v(1em, weak: true)
      it
    }
  }

  show outline.entry: set text(hyphenate: false)
  show outline: set par(justify: false)

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
          [#underline[*Objectifs*] : #lab-description],
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
      #line(length: 100%)
    ],

    footer: context [
      #place(top, dy: -5pt, line(length: 100%))
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
