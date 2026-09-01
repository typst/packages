#let school-color = rgb(165, 28, 48)

// A Contents entry for a front-matter page that carries no heading of its own.
// The heading is queried by the outline but renders nothing, so the page keeps
// its existing layout.
#let toc-entry(name) = [
  #show heading: none
  #heading(level: 1, numbering: none, outlined: true, supplement: [])[#name]
]

#let frontmatter(
  title: none,
  abstract: [],
  author: "John Harvard",
  advisor: "Dear Advisor",
  department: "Department of Physics",
  doctor-of: "Philosophy",
  major: "Physics",
  completion-date: datetime.today().display("[month repr:long] [year]"),
  creative-commons: true,
  doc,
) = {
  set page(
    paper: "us-letter",
    // margin is automatically 2.5/11 times the short side of us-letter
    // which is about 1.01 inch
    margin: (x: 1.375in, y: 1.375in),
    numbering: "i",
  )
  set text(font: "New Computer Modern", size: 12pt)

  set heading(numbering: "1.1")
  // Unnumbered level-1 headings -- a bibliography, an acknowledgements page --
  // get the same chapter opening without a number; printing the counter there
  // would repeat the number of the preceding chapter.
  show heading.where(
    level: 1,
    outlined: true,
  ): it => [
    #set align(right)
    #set text(20pt, weight: "regular")
    #pagebreak()
    #v(25%)
    #{
      if it.numbering == none {
        // reserve the space so the title keeps the height it has in a
        // numbered chapter
        hide(text(100pt, "0"))
      } else {
        text(100pt, school-color, counter(heading).display())
      }
      linebreak()
    }
    #text(24.88pt, it.body)
    #v(4em)
  ]
  show heading.where(level: 1): smallcaps
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }
  set heading(supplement: it => {
    if it.depth == 1 {
      "Chapter"
    } else {
      "Section"
    }
  })

  set math.equation(numbering: (..num) => numbering(
    "(1.1.1)",
    counter(heading).get().first(),
    ..num,
  ))
  set figure(numbering: (..num) => numbering(
    "1.1.1",
    counter(heading).get().first(),
    ..num,
  ))
  set page(numbering: "i", footer: none)
  set align(center + horizon)
  counter(page).update(1)
  toc-entry("Title Page")
  grid(
    [
      #text(school-color, 24.88pt)[#(title)]

      #v(100pt)
      #show: smallcaps

      A dissertation presented\
      by\
      #author\
      to\
      The #department\
      #v(12pt)
      in partial fulfillment of the requirements\
      for the degree of\
      Doctor of #doctor-of\
      in the subject of\
      #major
      #v(12pt)
      Harvard University\
      Cambridge, Massachusetts\
      #completion-date
    ],
  )

  pagebreak()
  toc-entry("Copyright")
  show link: it => {
    set text(fill: school-color)
    it
  }

  [
    #if creative-commons [
      This work is licensed via #underline[
        #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0]
      ]
    ]

    Copyright #sym.copyright #datetime.today().display("[year]") #author
  ]
  pagebreak()

  // "Preliminary pages (abstract, table of contents, list of tables, graphs, illustrations, and
  // preface) should use small Roman numerals"
  set page(numbering: "i", footer: auto)
  set align(top)
  toc-entry("Abstract")
  grid(
    columns: (auto, 1fr, auto),
    [Dissertation Advisor: #advisor], [], [#author],
  )

  v(5%)
  text(school-color, 17.28pt)[#(title)]
  v(7%)

  // to mimic Double Spacing
  // https://github.com/typst/typst/issues/106#issuecomment-2041051807
  set text(top-edge: 0.7em, bottom-edge: -0.4em)
  set par(justify: true, spacing: 1.8em, leading: 1em)


  [*Abstract*]

  set align(left)
  abstract
  pagebreak()

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  // Small caps for the chapter number and title, but not for the page number:
  // the preliminary pages are numbered in lowercase Roman numerals, and small
  // caps would render those as capitals. `prefix()` is passed through unchanged
  // when it is `none` so that unnumbered entries keep their flush-left position
  // instead of picking up the hanging indent. The link is rebuilt by hand and so
  // must opt out of the `show link` colouring installed for the copyright page.
  show outline.entry.where(level: 1): it => it.indented(
    if it.prefix() == none { none } else { smallcaps(it.prefix()) },
    link(
      it.element.location(),
      // the fill is set on the text element itself so that it wins over the
      // `show link` colouring installed for the copyright page above
      text(fill: black, smallcaps(it.body()) + h(1fr) + it.page()),
    ),
  )

  show ref: it => {
    set text(fill: school-color)
    it
  }
  show figure.caption: it => [
    #set text(size: 10pt)
    #set par(justify: true)
    #set align(left)
    #strong([#it.supplement
      #context it.counter.display(it.numbering):
    ]) #it.body
  ]

  toc-entry("Table of Contents")
  outline(
    title: grid(
      [
        #set text(23pt)
        #h(1fr)
        Contents
        #v(2em)
      ],
    ),
  )

  set page(numbering: none)
  counter(page).update(1)
  set page(numbering: "1")
  doc
}

#let appendix(
  doc,
) = {
  // Restart the chapter counter so that the first appendix is A, the second B,
  // and so on; sections within them become A.1, A.2, ...
  counter(heading).update(0)
  set heading(numbering: "A.1")
  set heading(supplement: it => {
    if it.depth == 1 {
      "Appendix"
    } else {
      "Section"
    }
  })
  show heading.where(
    level: 1,
    outlined: true,
  ): it => [
    #set align(right)
    #set text(20pt, weight: "regular")
    #pagebreak()
    #v(25%)
    #text(100pt, school-color, counter(heading).display("A"))\
    #text(24.88pt, it.body)
    #v(4em)
  ]
  show heading.where(level: 1): smallcaps

  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }

  // like in the main matter, but with the appendix letter in front
  set math.equation(numbering: (..num) => numbering(
    "(A.1.1)",
    counter(heading).get().first(),
    ..num,
  ))
  set figure(numbering: (..num) => numbering(
    "A.1.1",
    counter(heading).get().first(),
    ..num,
  ))
  doc
}
