#let make-title-page(
  title: (en: none, zh: none),
  author: (firstname: none, surname: none, firstname-zh: none, surname-zh: none),
  dept: (en: none, zh: none),
  degree: (en: none, zh: none, abbr: none),
  date: (en: none, zh: none),
) = {
  set page(
    margin: (top: 50mm, bottom: 50mm, left: 45mm, right: 45mm),
    numbering: none,
  )
  set par(leading: 0.3em)
  align(center)[
    #image("/assets/CityU_logo_2015.png", width: 50%)
    #v(0.3cm)
    #set text(size: 18pt)
    #text(font: "Times New Roman")[#upper[City University of Hong Kong]]\
    #text(font: "PMingLiU")[香港城市大學]

    #v(1fr)

    #text(font: "Times New Roman")[#title.en]\
    #text(font: "PMingLiU")[#title.zh]

    #v(1fr)

    #set text(size: 12pt)
    #text(font: "Times New Roman")[
      Submitted to\
      #dept.en
    ]\
    #text(font: "PMingLiU")[
      #dept.zh
    ]\
    #text(font: "Times New Roman")[
      in Partial Fulfillment of the Requirements\
      for the Degree of #degree.en
    ]\
    #text(font: "PMingLiU")[
      #degree.zh
    ]

    // #v(1fr)

    #text(font: "Times New Roman")[
      by
    ]

    #v(1fr)

    #text(font: "Times New Roman")[
      #upper(author.surname) #author.firstname
    ]\
    #text(font: "PMingLiU")[
      #author.surname-zh#author.firstname-zh
    ]

    #v(1fr)

    #text(font: "Times New Roman")[
      #date.en
    ]\
    #text(font: "PMingLiU")[
      #date.zh
    ]
  ]
  pagebreak()
}

#let make-abstract-page(
  body,
) = {
  set text(font: "Times New Roman", size: 12pt)
  set par(leading: 0.8em, justify: true, first-line-indent: 1.5em, spacing: 1em)
  v(7em)
  align(center)[ #heading[Abstract] ]
  v(3em)

  body
  pagebreak()
}

#let make-panel-page(
  author: (firstname: none, surname: none),
  degree: none,
  dept: none,
  supervisor: (title: none, firstname: none, surname: none, dept: none, university: none),
  panel-members: (),
  examiners: (),
) = {
  set page(margin: (top: 25mm, bottom: 25mm, left: 45mm, right: 45mm))
  set text(font: "Times New Roman", size: 12pt)
  set par(leading: 1em, justify: true)
  align(center)[
    #upper([*City University of Hong Kong*])
    #v(-0.4em)
    #show heading.where(level: 1): set text(size: 12pt)
    #heading[*Qualifying Panel and Examination Panel*]
  ]
  v(1em)
  set text(size: 11.5pt)

  table(
    columns: (40mm, 70mm),
    inset: (left: 0cm),
    stroke: none,
    [Surname:], [#upper(author.surname)],
    [First Name:], [#author.firstname],
    [Degree:], [#degree],
    [College/Department:], [#dept],
  )
  v(1em)

  text[The Qualifying Panel of the above student is composed of:]
  v(0.8em)

  text[_Supervisor(s)_]
  v(-0.5em)
  table(
    columns: (50mm, 70mm),
    inset: (left: 0cm),
    stroke: none,
    [#supervisor.title #upper(supervisor.surname) #supervisor.firstname],
    [
      #supervisor.dept\
      #supervisor.university
    ],
  )
  v(1em)

  text[_Qualifying Panel Member(s)_]
  v(-0.5em)
  table(
    columns: (50mm, 70mm),
    inset: (left: 0cm),
    row-gutter: 2em,
    stroke: none,
    ..panel-members
      .map(member => (
        [#member.title #upper(member.surname) #member.firstname],
        [
          #member.dept\
          #member.university
        ],
      ))
      .flatten(),
  )
  v(2.5em)

  text[This thesis has been examined and approved by the following examiners:]
  table(
    columns: (50mm, 70mm),
    inset: (left: 0cm),
    row-gutter: 2em,
    stroke: none,
    ..examiners
      .map(examiner => (
        [#examiner.title #upper(examiner.surname) #examiner.firstname],
        [
          #examiner.dept\
          #examiner.university
        ],
      ))
      .flatten(),
  )

  pagebreak()
}

#let make-ack-page(
  body,
) = {
  set text(font: "Times New Roman", size: 12pt)
  set par(leading: 0.8em, justify: true, first-line-indent: 1.5em, spacing: 1em)
  v(7em)
  align(center)[ #heading[Acknowledgements] ]
  v(3em)

  body
  pagebreak()
}

#let make-toc() = {
  set par(leading: 0.8em)
  show outline.entry: it => link(
    it.element.location(),
    {
      // it.fields()
      let head = it.element
      let number = if head.numbering != none {
        if head.func() == heading {
          numbering(head.numbering, ..counter(heading).at(head.location()))
        } else {
          numbering(head.numbering, ..counter(figure.where(kind: "chapter")).at(head.location()))
        }
      }
      let fill = box(
        width: 1fr,
        it.fill,
      ) // ensure the fill doesn't occupy the full page width, just the available space (1fr)
      // let indent = if it.level == 1 {
      //   0em
      // } else if it.level == 2 {
      //   1.4em
      // } else if it.level == 3 {
      //   3.8em
      // }
      let indent = if it.level == 1 {
        0em
      } else {
        range(1, 2 * (it.level - 1), step: 2).sum() * 0.4em + (it.level - 1) * 1em
      }
      [#h(indent) #number #h(1em, weak: true) #head.body #fill #it.page()\ ]
    },
  )

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): it => [
    #v(0.6em)
    *#it*
  ]
  show outline.entry.where(level: 2): it => [
    // #v(0.1em)
    #it
  ]
  outline(
    title: box(
      inset: (top: 5em, bottom: 2.8em, left: 0cm, right: 0cm),
      text(size: 25pt)[Table of contents],
    ),
    // indent: i => (0em, 1.5em, 3.6em).at(i),
    target: selector(heading).or(figure.where(kind: "chapter")),
  )

  pagebreak()
}

#let make-list-of-figures() = {
  box(
    inset: (top: 7em, bottom: 4em, left: 0cm, right: 0cm),
    text(size: 1.5em)[= List of figures],
  )
  let prev-heading-level = state("prev-heading-level", 1)
  show outline.entry: it => link(
    it.element.location(),
    context {
      let fig = it.element
      let chapter-number = counter(figure.where(kind: "chapter")).at(fig.location()).first()
      let fig-number = counter(figure.where(kind: image)).at(fig.location()).first()
      let number = [#chapter-number.#fig-number]
      let fill = box(
        width: 1fr,
        it.fill,
      )
      if prev-heading-level.get() != chapter-number {
        prev-heading-level.update(chapter-number)
        v(0.6em)
      }
      [#h(2em) #number #h(1em, weak: true) #fig.caption.body #fill #it.page()\ ]
    },
  )
  outline(
    title: none,
    target: figure.where(kind: image),
  )

  pagebreak()
}

#let make-list-of-tables() = {
  box(
    inset: (top: 7em, bottom: 4em, left: 0cm, right: 0cm),
    text(size: 1.5em)[= List of tables],
  )
  let prev-heading-level = state("prev-heading-level", 1)
  show outline.entry: it => link(
    it.element.location(),
    context {
      let tab = it.element
      let chapter-number = counter(figure.where(kind: "chapter")).at(tab.location()).first()
      let tab-number = counter(figure.where(kind: table)).at(tab.location()).first()
      let number = [#chapter-number.#tab-number]
      let fill = box(
        width: 1fr,
        it.fill,
      )
      if prev-heading-level.get() != chapter-number {
        prev-heading-level.update(chapter-number)
        v(0.6em)
      }
      [#h(2em) #number #h(1em, weak: true) #tab.caption.body #fill #it.page()\ ]
    },
  )
  outline(
    title: none,
    target: figure.where(kind: table),
  )

  pagebreak()
}

