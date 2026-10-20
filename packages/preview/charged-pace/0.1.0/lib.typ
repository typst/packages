/// Declare a new thesis or dissertation
#let manuscript(
  /// The title of your paper -> content | str
  title: [Title of the paper],
  /// The name of the author, i.e., your name -> content | str
  author: [Forename Surname],
  /// The month and year wherein your paper will be submitted -> dictionary
  date: (
    /// The month this paper will be submitted -> "Januaray" | "February" | "March" | "April" | "May" | "June" | "July" | "August" | "September" | "November" | "December"
    month: "May",
    /// The year this paper will be submitted -> int
    year: 2026,
  ),
  /// The degree which you are pursuing -> "Master's" | "PhD"
  degree: none,
  /// A bibliography declaration -> [bib]
  bibliography-decl: none,
  /// The text of the paper's abstract -> content | str
  abstract: [Abstract],
  content,
) = {
  assert(degree == "Master's" or degree == "PhD", message: "Degree must be one of \"Master's\" or \"PhD\"")

  let figure-supplement = [Fig.]
  let equation-supplement = [Eq.]

  let report_type(lower: false) = {
    if lower {
      if degree == "Master's" [thesis]
      if degree == "PhD" [dissertation]
    } else {
      if degree == "Master's" [Thesis]
      if degree == "PhD" [Dissertation]
    }
  }

  let sig_ln(position_title, position) = [
    #box[#line(length: 80%)]-#box[#line(length: 19%)]
    Name of #position_title #h(1fr) Date \
    #position
  ]

  let preamble(degree) = [
    Submitted in partial fulfillment \
    of the requirements for the degree of \
    #degree in Computer Science
  ]

  show heading.where(level: 1): set align(center + top)

  set align(center + horizon)
  set page(paper: "us-letter")
  // Uses Tex Gyre Terms which is the latex clone of times new roman that includes smallcaps
  set text(1em, font: "Tex Gyre Termes")
  text(weight: "bold")[#title]
  v(4em)
  [by]
  v(1em)
  author
  v(4em)
  preamble(degree)
  v(2em)
  [at]
  v(2em)
  [Seidenberg School of Computer Science and Information Systems]
  v(2em)
  [Pace University]
  v(2em)
  [#date.month #date.year]
  pagebreak()

  set align(left + top)
  [We hereby certify that this #report_type(lower: true), submitted by #author,
    satisfies the dissertation requirements for the degree of _#degree in
    Computer Science_ and has been approved.]
  v(4em)
  sig_ln(box[#report_type() Supervisor], box[Chairperson of #report_type() Committee])
  v(2em)
  sig_ln("Committee Member 1", box[#report_type() Committee Member])
  v(2em)
  sig_ln("Committee Member 2", box[#report_type() Committee Member])
  v(4em)
  [Seidenberg School of Computer Science and Information Systems \
    Pace University #date.year]
  pagebreak()

  set page(numbering: "i.")
  set align(center + top)
  [= Abstract]
  v(1em)
  title
  v(1em)
  [by]
  v(0.5em, weak: true)
  author
  v(1em)
  preamble(degree)
  v(1em)
  [#date.month #date.year]
  v(2em)
  set align(left + top)
  abstract
  pagebreak()

  [= Acknowledgment]
  v(2em)
  [This Typst template was created by Éloïse Zappala during her 2026 candidacy, for all Master's and PhD students. \ \ The acknowledgment body should list any external help you received in researching and writing this #report_type(lower: true).]
  pagebreak()


  set heading(numbering: "1.1", supplement: [Chapter])

  let heading-prefix(it) = {
    if it.numbering != none [
      #counter(heading).display(it.numbering)
      #h(0.5em, weak: true)
    ]
  }

  show heading.where(level: 1): set align(center)

  show heading.where(level: 1): it => pagebreak()
  show heading.where(level: 1): it => block(
    above: 1.25em,
    below: 1.2em,
    sticky: true,
  )[
    #it.supplement
    #heading-prefix(it)
    #linebreak()
    #smallcaps(it.body)
  ]

  show heading.where(level: 2): it => block(
    above: 2em,
    below: 1.2em,
  )[
    #heading-prefix(it)
    #text(style: "italic")[#it.body]
  ]

  show heading.where(level: 3): it => block[
    #heading-prefix(it)
    #emph(it.body)
  ]

  show heading.where(level: 4): it => block[
    #heading-prefix(it)
    #emph(it.body)
  ]

  let maybe-outline(title, target) = context {
    let items = query(target)
    if items.len() > 0 {
      pagebreak()
      outline(title: title, target: target)
    }
  }

  show outline: set heading(numbering: none, supplement: none)
  outline(title: "Table of Contents")

  maybe-outline("List of Tables", figure.where(kind: table))
  maybe-outline("List of Figures", figure.where(kind: image))
  maybe-outline("List of Equations", math.equation)

  set page(numbering: "1.", margin: (left: 9em, rest: auto))
  set par(leading: 1.3em, spacing: 1.95em, first-line-indent: (amount: 4em, all: true))

  // Enumerator numbering
  set enum(numbering: "1)a)i)")

  // Tables & figures
  show figure: set block(spacing: 2em)
  show figure: set place(clearance: 2em)
  show figure.where(kind: table): set figure.caption(position: top, separator: [\ ])
  show figure.where(kind: table): set text(size: 1em)
  show figure.where(kind: table): set figure(numbering: "I")
  show figure.where(kind: image): set figure(supplement: figure-supplement, numbering: "1")
  show figure.caption: set text(size: 1em)
  show figure.caption: set align(start)
  show figure.caption.where(kind: table): set align(center)

  // Adapt supplement in caption independently from supplement used for
  // references.
  set figure.caption(separator: [. ])
  show figure: fig => {
    let prefix = (
      if fig.kind == table [TABLE] else if fig.kind == image [Fig.] else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    // Wrap figure captions in block to prevent the creation of paragraphs. In
    // particular, this means `par.first-line-indent` does not apply.
    // See https://github.com/typst/templates/pull/73#discussion_r2112947947.
    show figure.caption: it => block[#prefix~#numbers#it.separator#it.body]
    show figure.caption.where(kind: table): smallcaps
    fig
  }


  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)", supplement: equation-supplement)
  show math.equation: set block(spacing: 1.2em)
  show math.equation: eq => {
    let prefix = (
      [#eq.supplement]
    )
    let numbers = numbering(eq.numbering, ..counter(math.equation).at(eq.location()))
    eq
  }

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location()),
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 1em, body-indent: 0.9pt)
  set list(indent: 1em, body-indent: 0.9em)

  content
  pagebreak()


  show std.bibliography: set text(1em)
  show std.bibliography: set block(spacing: 1em)
  show std.bibliography: set heading(numbering: none, supplement: none)
  set std.bibliography(title: text(1em)[References], style: "ieee")
  bibliography-decl
}
#let thesis(..args) = manuscript(..args)
#let dissertation(..args) = manuscript(..args)

