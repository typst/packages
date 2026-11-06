#let mms = text()[Monash Motorsport]
#let mms-logo = image("/assets/images/mms_logo_blue.svg", width: 40%)
#let navy = rgb("006EB0")
#let light-blue = rgb("1d9eda")
#let dark-grey = rgb("48484a")
/**
 * Report Template
 * This template is for technical reports.
 * Think submissions to competition, or something that you would like looking like a research article.
 * */
#let report(
  doc,
  title: "Example Report",
  authors: ("Jane Doe", "John Doe"),
  department: "Skunk Works",
  heading-numbers: false,
  abstract: "",
) = {
  let authors = if type(authors) == str { (authors,) } else { authors }
  set document(title: title, author: authors)
  set text(size: 10pt, font: "New Computer Modern")
  show math.equation: set text(weight: "regular")
  show heading: set block(above: 1.4em, below: 1em)
  show figure: set block(spacing: 2em)
  set heading(numbering: if heading-numbers { "1.1" } else { none })
  set par(leading: 0.55em, spacing: 0.55em, justify: true)
  set page(
    paper: "a4",
    columns: 2,
    numbering: "1",
    header: context {
      if (counter(page).get().at(0) == 1) {
        align(center, mms-logo)
      } else [
        #pad(right: -1.6em)[
          #align(end, image("assets/images/mms_logo_blue.svg", width: page.width / 5))

        ]
        #line(length: 100%, stroke: 0.2pt)

      ]
    },
    footer: context {
      set text(size: 8pt)
      grid(
        columns: (1fr, 1fr, 1fr),
        [],
        align(center)[#mms],
        align(right)[
          #counter(page).display("1 of 1", both: true)
        ],
      )
    },
  )

  place(top + center, float: true, scope: "parent", clearance: 4em, {
    text(size: 20pt, fill: navy)[#par(justify: false)[ #title]]
    if department != none {
      text(size: 14pt, fill: dark-grey)[#department]
    }
    v(0.5em)
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 12pt,
      ..authors.map(author => [
        #author
      ])
    )

    if abstract != "" {
      v(2em)
      par(justify: false)[
        #text(weight: "bold")[Abstract]
        #linebreak()
      ]
      v(1em)
      text(weight: "medium")[#abstract]
    }
  })

  counter(page).update(1)
  doc
}

/**
 * Articles are longer generally more internal documents. They can be the culmination of a research project, or perhaps a manual of some variety.
 * They are generally intended as a place to conduct a thorough of a research topic.
 */
#let article(
  doc,
  title: "Example Article",
  authors: ("John Doe", "Jane Doe"),
  department: "Skunk Works",
  // Table of contents
  toc: false,
  heading-numbers: false,
) = {
  let authors = if type(authors) == str { (authors,) } else { authors }
  set document(title: title, author: authors)
  set text(size: 10pt)
  show math.equation: set text(weight: "regular")
  show heading: set block(above: 1.4em, below: 1em)
  show figure: set block(spacing: 2em)
  set heading(numbering: if heading-numbers { "1.1" } else { none })
  set par(leading: 0.55em, spacing: 0.55em, justify: true)

  align(center + horizon)[
    #mms-logo
    #text(size: 16pt)[#title]
    #if department != none [
      #v(1em)
      #text(size: 14pt, fill: navy)[#department]
    ]

    #let count = authors.len()
    #let ncols = calc.min(count, 3)
    #v(1em)
    #grid(
      columns: (1fr,) * ncols,
      row-gutter: 10pt,
      ..authors.map(author => [
        #author
      ])
    )
  ]

  set page(
    paper: "a4",
    margin: 1.2in,
    header: context {
      pad(right: -1.6em)[
        #align(end, image("assets/images/mms_logo_blue.svg", width: page.width / 5))

      ]
      line(length: 100%, stroke: 0.2pt)
    },
    footer: none,
  )
  outline()

  set page(
    numbering: "1",
    header: context {
      pad(right: -1.6em)[
        #align(end, image("assets/images/mms_logo_blue.svg", width: page.width / 5))

      ]
      line(length: 100%, stroke: 0.2pt)
    },
    footer: context {
      set text(size: 8pt)
      grid(
        columns: (1fr, 1fr, 1fr),
        [],
        align(center)[#mms],
        align(right)[
          #counter(page).display("1 of 1", both: true)
        ],
      )
    },
  )
  counter(page).update(1)

  doc
}
