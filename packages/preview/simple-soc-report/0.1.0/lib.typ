#let render-maybe-list(value) = {
  if value == none {
    none
  } else if type(value) == array {
    list(..value)
  } else {
    list(value)
  }
}

#let render-inline(value) = {
  if value == none {
    none
  } else if type(value) == array {
    value.join(", ")
  } else {
    value
  }
}

#let frontmatter-details(
  subject-descriptors: none,
  keywords: none,
  implementation-software: none,
) = {
  if (
    subject-descriptors != none
      or keywords != none
      or implementation-software != none
  ) [
    #v(5mm)

    #if subject-descriptors != none [
      Subject Descriptors: \
      #render-maybe-list(subject-descriptors)
    ]

    #v(5mm)
    #if keywords != none [
      Keywords:

      #h(10mm)
      #render-inline(keywords)
    ]

    #v(5mm)
    #if implementation-software != none [
      Implementation Software: \
      #render-maybe-list(implementation-software)
    ]
  ]
}

#let unnumbered-section(title, body) = [
  #heading(level: 1, numbering: none)[#title]
  #body
  #pagebreak()
]

#let abstract-section(
  body,
  subject-descriptors: none,
  keywords: none,
  implementation-software: none,
) = [
  #align(center)[#text(size: 15pt, weight: "bold")[Abstract]]
  #v(0.75em)
  #body
  #v(0.75em)
  #frontmatter-details(
    subject-descriptors: subject-descriptors,
    keywords: keywords,
    implementation-software: implementation-software,
  )
  #pagebreak()
]

#let appendix-counter = counter("appendix")
#let appendix-section(title, body) = context [
  #appendix-counter.step()
  #let prefix = appendix-counter.display("A")

  #pagebreak()
  #counter(page).update(1)
  #set page(numbering: (..nums) => {
    let n = nums.at(0)
    prefix + "-" + str(n)
  })
  #heading(level: 1, numbering: none)[Appendix #prefix - #title]
  #body
]


#let outline-section(title, target: none, depth: 4) = [
  #heading(level: 1, numbering: none)[#title]
  #if target == none {
    outline(title: none, depth: depth, indent: 1em)
  } else {
    outline(title: none, target: target)
  }
  #pagebreak()
]

#let title-block(
  project-type,
  project-title,
  author-name,
  academic-year,
  department,
  school,
  university,
) = [
  #align(center)[
    #v(1fr)
    #text(size: 13pt)[#project-type]
    #v(1fr)
    #text(size: 18pt, weight: "bold")[#project-title]
    #v(2cm)
    #text(size: 13pt)[By \ #author-name]
    #v(1fr)
    #text(size: 11pt)[
      #department \
      #school \
      #university
    ]
    #v(1cm)
    #text(size: 11pt)[#academic-year]
    #v(1fr)
  ]
]

#let cover-page(
  project-type,
  project-title,
  author-name,
  academic-year,
  department,
  school,
  university,
) = {
  page(margin: 3cm, numbering: none)[
    #title-block(
      project-type,
      project-title,
      author-name,
      academic-year,
      department,
      school,
      university,
    )
  ]
}

#let title-page(
  project-type,
  project-title,
  author-name,
  academic-year,
  project-id,
  advisor,
  deliverables,
  department,
  school,
  university,
) = {
  page(margin: 3cm)[
    #title-block(
      project-type,
      project-title,
      author-name,
      academic-year,
      department,
      school,
      university,
    )

    #v(1cm)
    Project ID: #project-id \
    Advisor: #advisor

    #v(1cm)
    Deliverables:
    #list(..deliverables)
  ]
}




#let report(
  project-type: "",
  author-name: "",
  project-title: "",
  academic-year: "",
  project-id: "",
  advisor: "",
  deliverables: (),
  abstract-content: none,
  acknowledgement-content: none,
  department: "Department of Computer Science",
  school: "School of Computing",
  university: "National University of Singapore",
  subject-descriptors: none,
  keywords: none,
  implementation-software: none,
  bibliography: none,
  appendix-content: none,
  body,
) = {
  set document(title: project-title, author: author-name)
  set page(
    paper: "a4",
    margin: 1in,
    numbering: "i",
  )
  set text(region: "GB", font: "Nimbus Roman", size: 12pt, lang: "en")
  set par(leading: 1.5em, justify: true)
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    if it.numbering != none {
      pagebreak(weak: true)
      block(text(size: 16pt, weight: "bold")[
        #counter(heading).display(it.numbering)
        #h(0.5em)
        #it.body
      ])
    } else {
      align(center)[#text(weight: "bold")[#it.body]]
    }
  }

  show heading.where(level: 2): it => block(
    text(size: 14pt, weight: "bold")[
      #counter(heading).display(it.numbering)
      #h(0.5em)
      #it.body
    ],
  )

  show link: it => text(fill: black)[#it]
  show ref: it => text(fill: black)[#it]
  show figure.caption: it => text(size: 0.9em)[#it]

  cover-page(
    project-type,
    project-title,
    author-name,
    academic-year,
    department,
    school,
    university,
  )
  counter(page).update(1)

  title-page(
    project-type,
    project-title,
    author-name,
    academic-year,
    project-id,
    advisor,
    deliverables,
    department,
    school,
    university,
  )

  if abstract-content != none {
    abstract-section(
      abstract-content,
      subject-descriptors: subject-descriptors,
      keywords: keywords,
      implementation-software: implementation-software,
    )
  }

  if acknowledgement-content != none {
    unnumbered-section("Acknowledgements", acknowledgement-content)
  }

  outline-section("Table of Contents")
  outline-section("List of Figures", target: figure.where(kind: image))
  outline-section("List of Tables", target: figure.where(kind: table))

  set page(numbering: "1")
  counter(page).update(1)

  body

  if bibliography != none {
    pagebreak()
    bibliography
  }

  if appendix-content != none {
    appendix-content
  }
}

