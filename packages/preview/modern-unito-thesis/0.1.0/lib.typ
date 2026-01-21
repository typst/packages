// Official declaration of originality, both in English and Italian
// taken directly from Paola Gatti's email
#let declaration-of-originality = (
  "en": [
    I declare to be responsible for the content I'm presenting in order to obtain the final degree, not to have plagiarized in all or part of, the work produced by others and having cited original sources in consistent way with current plagiarism regulations and copyright. I am also aware that in case of false declaration, I could incur in law penalties and my admission to final exam could be denied
  ],
  "it": [
    Dichiaro di essere responsabile del contenuto dell'elaborato che presento al fine del conseguimento del titolo, di non avere plagiato in tutto o in parte il lavoro prodotto da altri e di aver citato le fonti originali in modo congruente alle normative vigenti in materia di plagio e di diritto d'autore. Sono inoltre consapevole che nel caso la mia dichiarazione risultasse mendace, potrei incorrere nelle sanzioni previste dalla legge e la mia ammissione alla prova finale potrebbe essere negata.
  ]
)

// FIXME: workaround for the lack of `std` scope
#let std-bibliography = bibliography

#let template(
  // Your thesis title
  title: [Thesis Title],

  // The academic year you're graduating in
  academic-year: [2023/2024],

  // Your thesis subtitle, should be something along the lines of
  // "Bachelor's Thesis", "Tesi di Laurea Triennale" etc.
  subtitle: [Bachelor's Thesis],

  // The paper size, refer to https://typst.app/docs/reference/layout/page/#parameters-paper for all the available options
  paper-size: "a4",

  // Candidate's informations. You should specify a `name` key and
  // `matricola` key
  candidate: (),

  // The thesis' supervisor (relatore)
  supervisor: "",

  // An array of the thesis' co-supervisors (correlatori).
  // Set to `none` if not needed
  co-supervisor: (),

  // An affiliation dictionary, you should specify a `university`
  // keyword, `school` keyword and a `degree` keyword
  affiliation: (),

  // Set to "it" for the italian template
  lang: "en",

  // The thesis' bibliography, should be passed as a call to the
  // `bibliography` function or `none` if you don't need
  // to include a bibliography
  bibliography: none,

  // The university's logo, should be passed as a call to the `image`
  // function or `none` if you don't need to include a logo
  logo: none,

  // Abstract of the thesis, set to none if not needed
  abstract: none,

  // Acknowledgments, set to none if not needed
  acknowledgments: none,

  // The thesis' keywords, can be left empty if not needed
  keywords: none,

  // The thesis' content
  body
) = {
  // Set document matadata.
  set document(title: title, author: candidate.name)

  // Set the body font, "New Computer Modern" gives a LaTeX-like look
  set text(font: "New Computer Modern", lang: lang, size: 12pt)

  // Configure the page
  set page(
    paper: paper-size,

    // Margins are taken from the university's guidelines
    margin: (right: 3cm, left: 3.5cm, top: 3.5cm, bottom: 3.5cm)
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure raw text/code blocks
  show raw.where(block: true): set text(size: 0.8em, font: "Fira Code")
  show raw.where(block: true): set par(justify: false)
  show raw.where(block: true): block.with(
    fill: gradient.linear(luma(240), luma(245), angle: 270deg),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )
  show raw.where(block: false): box.with(
    fill: gradient.linear(luma(240), luma(245), angle: 270deg),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Configure figure's captions
  show figure.caption: set text(size: 0.8em)

  // Configure lists and enumerations.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt, marker: ([•], [--]))

  // Configure headings
  set heading(numbering: "1.a.I")
  show heading.where(level: 1): it => {
    if it.body not in ([References], [Riferimenti]) {
      block(width: 100%, height: 20%)[
        #set align(center + horizon)
        #set text(1.3em, weight: "bold")
        #smallcaps(it)
      ]
    } else {
      block(width: 100%, height: 10%)[
        #set align(center + horizon)
        #set text(1.1em, weight: "bold")
        #smallcaps(it)
      ]
    
    }
  }
  show heading.where(level: 2): it => block(width: 100%)[
    #set align(center)
    #set text(1.1em, weight: "bold")
    #smallcaps(it)
  ]
  show heading.where(level: 3): it => block(width: 100%)[
    #set align(left)
    #set text(1em, weight: "bold")
    #smallcaps(it)
  ]

  // Title page
  set align(center)
  
  block[
    #let jb = linebreak(justify: true)
  
    #text(1.5em, weight: "bold", affiliation.university) #jb
    #text(1.2em, [
      #smallcaps(affiliation.school) #jb
      #affiliation.degree #jb
    ])
  ]

  v(3fr)
  if logo != none {
    logo
  }
  v(3fr)

  text(1.5em, subtitle)
  v(1fr, weak: true)
  text(2em, weight: 700, title)

  v(4fr)

  grid(
    columns: 2,
    align: left,
    grid.cell(
      inset: (right: 40pt)
    )[
      #if lang == "en" {
        smallcaps("supervisor")
      } else {
        smallcaps("relatore")
      }\
      *#supervisor*

      #if co-supervisor != none {
        if lang == "en" {
          smallcaps("co-supervisor")
        } else {
          smallcaps("correlatore")
        }
        linebreak()
        co-supervisor.map(it => [
          *#it*
        ]).join(linebreak())
      }
    ],
    grid.cell(
      inset: (left: 40pt)
    )[
      \ \ \

      #if lang == "en" {
        smallcaps("candidate")
      } else {
        smallcaps("candidato")
      }\
      *#candidate.name* \
      #candidate.matricola
    ]
  )

  v(5fr)

  text(1.2em, [
    #if lang == "en" {
      "Academic Year "
    } else {
      "Anno Accademico "
    }
    #academic-year
  ])

  pagebreak(to: "odd")
  set par(justify: true, first-line-indent: 1em)
  set align(center + horizon)

  // Declaration of originality, prints in English or Italian
  // depending on the `lang` parameter
  heading(
    level: 2,
    numbering: none,
    outlined: false,
    if lang == "en" {
      "Declaration of Originality"
    } else {
      "Dichiarazione di Originalità"
    }
  )
  text(style: "italic", declaration-of-originality.at(lang))

  pagebreak(weak: true)

  // Acknowledgments
  if acknowledgments != none {
    heading(
      level: 2,
      numbering: none,
      outlined: false,
      if lang == "en" {
        "Acknowledgments"
      } else {
        "Ringraziamenti"
      }
    )
    acknowledgments

    pagebreak(weak: true)
  }

  // Abstract
  if abstract != none {
    heading(
      level: 2,
      numbering: none,
      outlined: false,
      "Abstract"
    )
    abstract
  }

  // Keywords
  if keywords != none {
    heading(
      level: 2,
      numbering: none,
      outlined: false,
      if lang == "en" {
        "Keywords"
      } else {
        "Parole chiave"
      }
    )
    keywords
  }

  pagebreak(weak: true, to: "odd")

  // Table of contents
  // Outline customization
  show outline.entry.where(level: 1): it => {
    if it.body != [References] {
    v(12pt, weak: true)
    link(it.element.location(), strong({
      it.body
      h(1fr)
      it.page
    }))}
    else {
      text(size: 1em, it)
    }
  }
  show outline.entry.where(level: 3): it => {
    text(size: 0.8em, it)
  }
  
  outline(depth: 3, indent: true)

  pagebreak(to: "odd")

  // Main body

  show link: underline
  set page(numbering: "1")
  set align(top + left)
  counter(page).update(1)

  body

  pagebreak(to: "odd")

  // Bibliography
  if bibliography != none {
    heading(
      level: 1,
      numbering: none,
      if lang == "en" {
        "References"
      } else {
        "Riferimenti"
      }
    )
    show std-bibliography: set text(size: 0.9em)
    set std-bibliography(title: none)
    bibliography
  }
}