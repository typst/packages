#let title-page(
  title: none,
  author: none,
  previous-degrees: (),
  degree: none,
  program: none,
  campus: none,
  month: none,
  year: none,
) = [
  #set align(center + horizon)

  #grid(
    rows: 1fr,
    gutter: (auto, 1fr, 1fr, auto),
    upper(title),
    [
      by

      #upper(author)

      #previous-degrees.map(degree => [
        #degree.abbr, #degree.institution, #degree.year \
      ]).join()
    ],
    [
      A DISSERTATION SUBMITTED IN PARTIAL FULFILLMENT OF \
      THE REQUIREMENTS FOR THE DEGREE OF

      #upper(degree)
      #v(1.5em)
      in
      #v(1.5em)
      THE FACULTY OF GRADUATE AND POSTDOCTORAL STUDIES

      (#program)
    ],
    [
      THE UNIVERSITY OF BRITISH COLUMBIA
      
      (#campus)
    ],
    [
      #month #year

      #sym.copyright #author, #year
    ]
  )
]

#let committee-page(
  title: none,
  author: none,
  degree: none,
  program: none,
  examining-committee: (),
  additional-committee: (),
) = [
  The following individuals certify that they have read, and recommend to the
  Faculty of Graduate and Postdoctoral Studies for acceptance, the dissertation
  entitled:

  #text(title, weight: "bold")

  submitted by #text(author, weight: "bold") in partial fulfilment of the
  requirements for the degree of #degree in #program.

  #v(1em)
  #text("Examining Committee:", weight: "bold")

  #examining-committee.map(member => [
    #text(member.name, weight: "bold"), #member.title, #member.department,
    #member.institution \
    #member.role
    #v(0.1em)
  ]).join()

  #if additional-committee.len() > 0 [
    #v(1em)
    #text("Additional Supervisory Committee Members:", weight: "bold")

    #additional-committee.map(member => [
      #text(member.name, weight: "bold"), #member.title, #member.department,
      #member.institution \
      #member.role
      #v(0.1em)
    ]).join()
  ]
]

// All arguments are named because there are too many of them.
// Typst makes named arguments optional, so I have filled all non-optional
// arguments with `lorem` text to make the user aware that they need to put
// their own content in there.
#let thesis(
  title: [Thesis Title],
  author: "Your Name",
  previous-degrees: (),
  degree: "Your Degree",
  program: "Your Graduate Program",
  campus: "Your Campus",
  month: "Month",
  year: "Year",

  examining-committee: (
    (
      name: "Jane Doe",
      title: "Unemployed",
      department: "Department of Blindly Copying and Pasting",
      institution: "Example University",
      role: "Supervisor",
    ),
  ),
  additional-committee: (),

  abstract: lorem(350),
  lay-summary: lorem(150),
  preface: lorem(300),
  list-of-symbols: none,
  glossary: none,
  acknowledgments: none,
  dedication: none,
  // Bibliography is not optional even though it is `none` here. See the comment
  // below.
  bibliography: none,
  appendices: none,

  body,
) = {
  set document(title: title, author: author)
  set page(width: 8.5in, height: 11in, number-align: right)
  set text(font: "Libertinus Serif", size: 12pt)
  show heading.where(level: 1): it => { pagebreak(weak: true); it }

  title-page(
    title: title,
    author: author,
    previous-degrees: previous-degrees,
    degree: degree,
    program: program,
    campus: campus,
    month: month,
    year: year,
  )

  set page(margin: (left: 1.25in, rest:1in), numbering: "i")
  set par(justify: true)

  committee-page(
    title: title,
    author: author,
    degree: degree,
    program: program,
    examining-committee: examining-committee,
    additional-committee: additional-committee,
  )

  heading("Abstract")
  abstract

  heading("Lay Summary")
  lay-summary

  heading("Preface")
  preface

  show outline: set heading(outlined: true)
  outline(title: "Table of Contents")

  context {
    let num-tables = query(
      figure.where(kind: table)
    ).len()

    if num-tables > 0 {
      outline(
        title: "List of Tables",
        target: figure.where(kind: table),
      )
    }

    let num-figures = query(
      figure.where(kind: image)
    ).len()

    if num-figures > 0 {
      outline(
        title: "List of Figures",
        target: figure.where(kind: image),
      )
    }
  }

  if list-of-symbols != none and list-of-symbols != [] {
    heading("List of Symbols")
    list-of-symbols
  }

  if glossary != none and glossary != [] {
    heading("Glossary")
    glossary
  }

  if acknowledgments != none and acknowledgments != [] {
    heading("Acknowledgments")
    acknowledgments
  }

  if dedication != none and dedication != [] {
    heading("Dedication")
    dedication
  }

  set page(numbering: "1")
  context counter(page).update(1)

  set heading(numbering: "1.")
  body

  // The bibliography is not optional, but using the same pattern as the other
  // non-optional sections (default to random refs to make users aware) would
  // require me to add an empty `refs.bib` file to the template, which I don't
  // want to do (and I don't know if it would work pulling from @preview
  // anyway).
  if bibliography == none or bibliography == [] {
    heading("Bibliography")
  }
  bibliography

  if appendices != none and appendices != [] {
    heading("Appendices", numbering: none)

    set heading(
      // Allow users to write each appendix as a level 1 heading, but then treat
      // them magically as level 2 under the "Appendices" (level 1) heading.
      offset: 1,
      // I would like to have numbering "A:" instead of "A", but it is also
      // showing the ":" when an appendix is referenced in the text.
      // If you know how to fix this, please send a PR.
      numbering: (_, ..rest) => "Appendix " + numbering("A", ..rest),
      supplement: [],
    )
    // Each appendix should start on a new page, but the first one should not
    // start with a pagebreak i.e. it should be right after the "Appendices"
    // heading.
    let s = state("after-first", false)
    show heading.where(level: 2): it => {
      if s.get() {
        pagebreak(weak: true)
      }
      it
      s.update(true)
    }

    appendices
  }
}
