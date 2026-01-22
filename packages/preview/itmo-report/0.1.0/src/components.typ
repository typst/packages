#import "config.typ": config

#let field(label, value: none) = {
  pad(left: config.indent.field-label)[
    *#label:* #if value != none { value }
  ]
}

#let signature-line(label, line-width: 5em) = {
  [#label #box(width: line-width, line(length: 100%))]
}

#let vspace = (
  small: () => v(0.5em),
  medium: () => v(1em),
  large: () => v(1.5em),
  section: () => v(1.8cm),
)

#let header-block(
  ministry: config.institution.ministry,
  federal: config.institution.federal,
  university: config.institution.university,
  university-short: config.institution.university-short,
  ministry-size: 14pt,
  federal-size: 9pt,
  university-size: 16pt,
  university-short-size: 14pt,
  weight: "bold",
  federal-tracking: 0.5pt,
  university-leading: 1.10em,
) = {
  align(center)[
    #set text(weight: weight)
    #text(size: ministry-size)[#ministry]

    #text(size: federal-size, tracking: federal-tracking)[#federal]

    #set par(leading: university-leading)
    #text(size: university-size)[#university]

    #text(size: university-short-size)[#university-short]
  ]
}

#let title-page(
  title: none,
  student: none,
  faculty: none,
  program: none,
  supervisor: none,
  responsible: none,
  field-of-study: none,
  date: datetime.today(),
  year: datetime.today().year(),
) = {
  header-block()
  v(1.5em)

  field("Faculty", value: faculty)
  field("Educational program", value: program)
  field("Field of study (specialty)", value: field-of-study)

  v(1.8cm)

  align(center)[
    #text(size: 16pt)[REPORT]
    #v(-0.5em)
    of the research work
  ]

  v(0.9cm)

  [Name of the topic: #strong[#title]]
  linebreak()
  [Student: #strong[#student]]

  v(1.2cm)

  if (supervisor != none) or (responsible != none) {
      [Agreed:]

      if supervisor != none {
        [#linebreak()Thesis supervisor: ]
        strong[#supervisor]
      }

      if responsible != none {
        [#linebreak()Responsible for the research work: ]
        strong[#responsible]
      }

  }

  v(1.5cm)

  align(right)[
    Research work completed with a grade #signature-line("", line-width: 5em)
  ]

  v(0.8cm)

  align(right)[
    Date #h(0.5em) #strong[#date.display()]
  ]


  align(bottom + center)[
    #config.institution.city
    #v(0.3cm)
    #year
  ]
}

#let table-of-contents(title: "CONTENT") = {
  heading(level: 1, numbering: none, outlined: false)[#title]
  outline(title: none)
}
