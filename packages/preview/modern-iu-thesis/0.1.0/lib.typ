#let thesis(
  title: none,
  author: none,
  dept: none,
  year: none,
  month: none,
  day: none,
  committee: (),
  dedication: none,
  acknowledgement: [],
  abstract: [],
  doc,
) = {
  set text(size: 11pt)
  set par(leading: 1.5em, first-line-indent: 1em, justify: true, spacing: 1.5em)
  set page(
    margin: (x: 1in, y: 1in),
    paper: "us-letter",
    footer: context {
      set align(center)
      if counter(page).get().at(0) != 1 {
        [#counter(page).display("i")]
      } else {
        []
      }
    },
  )
  show math.equation: it => {
    if it.has("label") {
      math.equation(
        block: true,
        numbering: it1 => (
          context {
            let count = counter(heading.where(level: 1)).get()
            numbering("(1.1)", count.at(0), it1)
          }
        ),
        it,
      )
    } else {
      it
    }
  }
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(
        el.location(),
        [Eq.~#context {
            let count = counter(heading.where(level: 1)).get()
            numbering("(1.1)", count.at(0), counter(math.equation).at(el.location()).at(0) + 1)
          }],
      )
    } else {
      it
    }
  }

  grid(
    columns: (1fr),
    rows: (1fr, 1fr, 1fr),
    align(center + horizon, text(16pt)[#smallcaps([#title])]),
    align(center + horizon)[#author],
    align(center + horizon)[Submitted to the Faculty of the Gradute School \ in partial fulfillment of the requirements \ for the degree \ Doctor of Philosophy \ in the Department of #dept, \ Indiana University \ #month #year],
  )

  pagebreak()

  align(center)[Accepted by the Graduate Faculty, Indiana University, in partial fulfillment of the requirements for the degree of Doctor of Philosophy.]

  v(2em)

  [Doctoral Committee]

  v(3em)

  for member in committee {
    [
      #align(right)[#line(length: 50%, stroke: 0.5pt)]
      #v(-0.75em)
      #align(right)[#member.name, #member.title]
      #v(3em)
    ]
  }

  v(1fr)

  align(left)[#day #month #year]

  pagebreak()

  align(center + horizon)[Copyright \u{00a9} #year \ #author]

  pagebreak()

  if dedication != none {
    align(center + horizon)[#emph[#dedication]]
    pagebreak()
  }

  text(15pt)[#align(center)[
      *Acknowlegements*
    ]]

  [#acknowledgement]

  pagebreak()

  align(center)[#author]


  align(center, text(16pt)[#smallcaps([#title])])


  [#abstract]

  pagebreak()

  show outline: set par(leading: 0.75em)

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    it
  }

  outline(indent: auto)

  pagebreak()

  outline(
    target: figure.where(kind: image),
    indent: auto,
    title: [List of Figures],
  )

  pagebreak()

  outline(
    target: figure.where(kind: table),
    indent: auto,
    title: [List of Tables],
  )

  pagebreak()

  set page(
    numbering: "1",
    footer: context [
      #set align(center)
      #counter(page).display()
    ],
  )
  set heading(numbering: "1.1.1")
  show heading: it => [
    #v(12pt)
    #it
    #v(12pt)
  ]
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    if it.body == [Bibliography] {
      it
    } else {
      pagebreak(weak: true)
      align(center)[Chapter
        #counter(heading).display(it.numbering):
        #it.body
        #v(12pt)
      ]
    }
  }
  show figure.caption: it => {
    set par(leading: 0.65em)
    set text(size: 11pt)
    emph(it)
  }

  doc
}

#let iuquote(body) = {
  set par(leading: 0.65em)
  pad(x: 30pt, y: 15pt, body)
}
