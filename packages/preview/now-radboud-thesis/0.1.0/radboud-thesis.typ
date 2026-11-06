#let radboud-thesis(
  title: [Title],
  subtitle: [Subtitle],
  author: (name: "Author", student-number: "s1234567"),
  supervisors: ((title: "Supervisor", name: "Dr. Dewey Duck"), (title: "Second reader", name: "Prof. Dr. Louie Duck")),
  abstract: [],
  thesis-type: "Bachelor/Master",
  study: "Computing Science",
  date: datetime.today(),
  body,
) = {
  set document(title: title, author: author.name)

  set par(justify: true)

  set heading(numbering: "1.1")
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    colbreak(weak: true)
    if it.numbering != none {
      v(3em)
      block(text(size: 20pt, [Chapter #counter(heading).display()]))
      v(1em)
    }
    block(text(size: 26pt, [#it.body]))
    v(1em)
  }

  show outline: it => {
    show heading: pad.with(bottom: 1.25em)
    it
  }

  // Level 1 outline entries are bold and there is no fill.
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set block(above: 1.35em)
  show outline.entry.where(level: 1): set text(weight: "bold")

  // Level 2 and 3 outline entries have a bigger gap and a dot fill.
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): set outline.entry(
    fill: repeat(justify: true, gap: 0.5em)[.],
  )

  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => link(
    it.element.location(),
    it.indented(
      gap: 1em,
      it.prefix(),
      it.body() + box(width: 1fr, inset: (left: 5pt), it.fill) + box(width: 1.5em, align(right, it.page())),
    ),
  )

  // Title Page
  align(center)[
    #text(size: 17pt)[#smallcaps[#thesis-type's Thesis\ #study]]
    #image("Logo_Radboud_University.svg", width: 25mm)
    #text(size: 14pt)[#smallcaps[Radboud University Nijmegen]]
    #v(2em)
    #line(length: 100%, stroke: 0.4mm)
    #v(.5em)
    #text(size: 24pt, weight: "bold")[#title]\
    #text(size: 14pt)[#smallcaps[#subtitle]]
    #v(.5em)
    #line(length: 100%, stroke: 0.4mm)
    #v(2em)
    #grid(
      columns: (45%, 45%),
      align(left)[
        _Author:_\
        #author.name\
        #author.student-number
      ],
      align(right)[
        #{
          for (title, name) in supervisors {
            [
              #text(title + ":", style: "italic")\
              #name
              #v(1em)
            ]
          }
        }
      ],
    )
    #v(1fr)
    #text(size: 12pt)[#date.display("[month repr:long] [day], [year]")]
  ]

  pagebreak()

  v(-8.5em)
  align(center + horizon)[
    #block([*Abstract*])
    #v(1em)
    #align(left, abstract)
  ]

  pagebreak()

  body
}

#let appendix(body) = {
  set heading(numbering: "A.1", supplement: [Appendix])
  show heading.where(level: 1): set heading(supplement: [Appendix])
  show heading.where(level: 1): it => {
    colbreak(weak: true)
    if it.numbering != none {
      v(3em)
      block(text(size: 20pt, [Appendix #counter(heading).display()]))
      v(1em)
    }
    block(text(size: 26pt, [#it.body]))
    v(1em)
  }
  counter(heading).update(0)
  body
}
