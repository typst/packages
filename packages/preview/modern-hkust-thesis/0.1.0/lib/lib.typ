#import "@preview/titleize:0.1.1": titlecase
#import "@preview/datify-core:1.0.0": get-month-name
#import "@preview/numbly:0.1.0": numbly
#import "abbr.typ"

#let title-page(
  title: none,
  author: none,
  previous-degrees: (),
  degree: none,
  program: none,
  campus: none,
  month: int,
  year: int,
) = [
  #set align(center + horizon)
  #set text(size: 15pt)
  #hide[#heading(level: 1)[Title Page]] #v(-1.2em)
  *#titlecase(title)*
  #set text(size: 12pt)
  #v(5em)
  by
  #v(1em)
  #author
  #v(5em)
  #let deg = degree
  #if degree == "Mphil" {
    let deg = "Master"
  } else if degree == "PhD" {
    let deg = "Doctor"
  }
  A Thesis Submitted to\
  The Hong Kong University of Science and Technology (Guangzhou)\
  in Partial Fulfillment of the Requirements for\
  the Degree of #deg of Philosophy \
  in #program
  #v(3em)
  #get-month-name(month) #year, Guangzhou
  #pagebreak()
]

#let abstract-page(
  title: none,
  program: none,
  school: none,
  author: none,
  keywords: (),
  it
) = [
  #set align(center)
  #hide[#heading(level: 1)[Abstract]] #v(-1.2em)
  #titlecase(title)
  #v(1em)
  by #author
  #v(1em)
  Thrust of #program \
  #school

  Abstract
  #set align(left)
  #set par(justify: true, leading: 1em, spacing: 2em)
  #it
  #v(1em)
  *Keywords:* #keywords.map(titlecase).join(", ")
  #pagebreak()
]

#let authorization-page(
  author: none, 
  year: int, 
  month: int, 
  day: int
) = [
  #hide[#heading(level: 1)[Authorization Page]] #v(-1.2em)
  #align(center)[#underline(offset: 2pt)[*Authorization Page*]]
  #v(1em)
  #h(2em)I hereby declare that I am the sole author of the thesis.
  #v(2em)
  #h(2em)I authorize the Hong Kong University of Science and Technology (Guangzhou) to lend this thesis to other institutions or individuals for the purpose of scholarly research.
  #v(2em)
  #h(2em)I further authorize the Hong Kong University of Science and Technology (Guangzhou) to reproduce the thesis by photocopying or by other means, in total or in part, at the request of other institutions or individuals for the purpose of scholarly research.

  #v(5em)
  #align(center)[#line(length: 8cm, stroke: 0.8pt)]
  #v(1em)
  #align(center, author)
  #align(center)[#day #get-month-name(month) #year]
  #pagebreak()
]

#let signature-page(
  title: none, 
  author: none,
  supervisor: none,
  co-supervisor: none,
  head: none,
  year: int, 
  month: int, 
  day: int,
  degree: none,
  program: none,
) = [
  #set align(center + horizon)
  #hide[#heading(level: 1)[Signature Page]] #v(-1.2em)
  #titlecase(title)
  #v(5em)
  by
  #v(1em)
  #author
  #v(2em)
  This is to certify that I have examined the above #degree thesis\
  and have found that it is complete and satisfactory in all respects, \
  and that any and all revisions required by \
  the thesis examination committee have been made.
  #v(4em)
  #line(length: 8cm, stroke: 0.8pt)
  Prof. #supervisor, Thesis Supervisor
  #v(3em)
  #if co-supervisor != none {
    line(length: 8cm, stroke: 0.8pt)
    [Prof. #co-supervisor, Thesis Co-supervisor]
    v(3em)
  }
  #line(length: 8cm, stroke: 0.8pt)
  Prof. #head, Head of Thrust
  #v(3em)
  Thrust of #program 

  #day #get-month-name(month) #year
  #pagebreak()
]

#let acknowledgement-page(it) = [
  #hide[#heading(level: 1)[Acknowledgements]]
  #v(-1.2em)
  #align(center)[*Acknowledgements*]
  #it
]

#let program-catalog = (
  AMAT: "Advanced Materials",
  MICS: "Microelectronics",
  EOAS: "Earth, Ocean and Atmospheric Sciences",
  SEE: "Sustainable Energy and Environment",
  AI: "Artificial Intelligence",
  CMA: "Computational Media and Arts",
  DSA: "Data Science and Analytics",
  IoT: "Internet of Things",
  BSBE: "Bioscience and Biomedical Engineering", 
  INTR: "Intelligent Transportation",
  ROAS: "Robotics and Autonomous Systems",
  SMMG: "Smart Manufacturing",
  FTEC: "Financial Technology",
  IPE: "Innovation, Policy and Entrepreneurship",
  UGOD: "Urban Governance and Design",
  CNCC: "Carbon Neutrality and Climate Change"
)

#let thesis(
  title: none,
  author: none,
  program: none,
  supervisor: none,
  co-supervisor: none,
  head: none,
  date: (int, int, int),
  bib-ref: none,
  abstract: none,
  keywords: (),
  acknowledgement: none,
  acronym: none,
  degree: none,
  draft: false,
  body
) = {
  let stamp = [
    #set text(80pt, font:"Arial", weight: 1000, fill: silver.lighten(60%))
    #set par(leading: 0.2em)
    DRAFT
    #set text(50pt)
    #datetime.today().display()
  ]
  set page(
    paper: "a4", 
    margin: (x: 2.5cm, y: 2.5cm), 
    numbering: "i",
    background: if draft {
      rotate(-12deg, stamp)
    } else {},
  )
  set text(font: "Times New Roman", size: 12pt
)
  set par(justify: true, leading: 1.2em, spacing: 2em)
  set par.line(numbering: "1", number-margin: left) if draft

  show heading.where(level: 1): set text(size: 12pt)

  title-page(
    title: title,
    author: author,
    degree: degree,
    program: program-catalog.at(program), 
    month: date.at(1),
    year: date.at(0),
  )

  abstract-page(
    title: title,
    program: program-catalog.at(program), 
    author: author,
    school: "The Hong Kong University of Science and Technology (Guangzhou)",
    keywords: keywords,
    abstract
  )

  authorization-page(
    author: author,
    year: date.at(0),
    month: date.at(1),
    day: date.at(2),
  )

  signature-page(
    title: title,
    author: author,
    supervisor: supervisor,
    co-supervisor: co-supervisor,
    head: head,
    year: date.at(0),
    month: date.at(1),
    day: date.at(2),
    degree: degree,
    program: program-catalog.at(program)
  )

  acknowledgement-page[
    #acknowledgement
    #pagebreak()
  ]

  hide[#heading(level: 1)[Table of Contents]]
  v(-2em)
  outline(
    title: [
      #upper("Table of Contents")
      #v(1em)
    ],
    indent: 1em,
  )

  context {
    let num-figures = query(
      figure.where(kind: image)
    ).len()

    if num-figures >= 5 {
      pagebreak()
      hide[#heading(level: 1)[List of Figures]]
      v(-2em)
      outline(
        title: [#upper("List of Figures")#v(1em)],
        target: figure.where(kind: image),
      )
    }

    let num-tables = query(
      figure.where(kind: table)
    ).len()

    if num-tables >= 3 {
      pagebreak()
      hide[#heading(level: 1)[List of Tables]]
      v(-2em)
      outline(
        title: [#upper("List of Tables")#v(1em)],
        target: figure.where(kind: table),
      )
    }
  }

  if acronym != none {
    acronym
    pagebreak()
    show heading: it => {
      upper(it)
      v(1.2em)
    }
    let style(short) = { short }
    abbr.config(style: style)
    show table: set table(inset: (left: 0pt, right: 20pt, y: 7pt))
    
    abbr.list(title: [List of Abbreviations], col: 2)
  }

  set page(numbering: "1")
  counter(page).update(1)
  context{
    set heading(numbering: numbly("CHAPTER {1}", "{1}.{2}", "{1}.{2}.{3}"))
    show heading.where(level: 1): it => [
      #set align(center)
      #set text(size: 16pt)
      #let threshold = 100%
      #block(breakable: false, height: threshold)
      #v(-threshold, weak: true)
      #counter(figure.where(kind: image)).update(0)
      #counter(figure.where(kind: table)).update(0)
      #counter(heading).display(it.numbering)

      #upper(it.body)
      #v(1em)
    ]

    show heading.where(level: 2): it => [
      #set text(size: 14pt)
      #it
    ]

    show heading.where(level: 3): it => [
      #set text(size: 12pt)
      #it
    ]
    show heading: set block(above: 2em, below: 2em)

    set figure(numbering: (..num) =>
      numbering("1.1", counter(heading).get().first(), num.pos().first())
    )
    set figure.caption(separator: [#h(1em)])
    show figure.caption: strong
    show figure.where(kind: table): set figure.caption(position: top)

    import "@preview/booktabs:0.0.4": *
    show: booktabs-default-table-style

    body
  }

  if bib-ref != none {
    pagebreak()

    hide[#heading(level: 1)[References]]
    v(-1.2em)
    strong[#upper("References")]
    v(0.2em)
    show bibliography: set par(spacing: 1.2em, leading: 1em)
    set bibliography(title: none)
    bib-ref 
  }
}
