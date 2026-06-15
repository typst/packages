#import "covers.typ": front-cover, back-cover
#import "front-matter.typ": title-page, imprint, abstract-page, abstract, acknowledgments-page, abbreviations-list, nomenclature-list, preface-page
#import "utils.typ": tr, pagebreak-recto, small, large, Large, huge, heading-style

#let in-outline = state("in-outline", false)
#let caption(long, short) = context if in-outline.get() { short } else { long }

#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: heading-style(tr("Bilaga ", "Appendix "), "A.1", in-outline))  
  
  set figure(numbering: n => {
    let h = counter(heading).get().at(0)
    let appendix-letter = numbering("A", h)
    [#appendix-letter#n]
  })
  
  show heading.where(level: 1): it => {
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    it
  }
  
  body
} 

#let cth-thesis(
  title: "[title]",
  subtitle: "",
  authors: ("[authors's name]", ),
  program: "[program]",
  department: "[department]",
  abstracts: (
    en: "",
    sv: "",
  ),
  keywords: (),
  supervisors: ("[supervisor's name]", ),
  examiner: "[examiners's name]",
  advisor: "",
  co-examiner: "",
  cover: (
    image: [],
    description: "",
  ),
  preface: "",
  acknowledgments: "",
  gu: false,
  year: datetime.today().year(),
  type: "B",
  print: false, 
  abbreviations: (),
  nomenclature: (),
  body
) = {
  // Metadata
  set document(
    title: title,
    author: authors.join(", "),
    description: abstracts.en,
    keywords: keywords,
    date: auto,
  )

  [
    #metadata(type) <thesis-type>
    #metadata(gu) <gu-collaboration>
  ]
  
  // Global styling
  set page(
    "a4", 
    number-align: center,
    margin: 2.5cm,
  )
  set par(
    spacing: 0.5cm,
    justify: true,
    linebreaks: "optimized"
  )
  show figure.where(kind: table): set par(justify: false)
  //show bibliography: set par(justify: false)
  set text(
    font: "New Computer Modern",
    size: 12pt,
    fallback: false,
    style: "normal",
    stretch: 100%,
    tracking: 0pt,
    spacing: 100%,
    baseline: 0pt,
    overhang: true,
    hyphenate: true,
    kerning: true,
    ligatures: true,
    number-width: "proportional",
  )
  set figure(gap: 1em)
  show figure: set text(font: "New Computer Modern Mono")
  show figure.where(kind: table): set text(font: "New Computer Modern")
  show figure.caption: set text(font: "New Computer Modern")
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }
  let pagebreak() = if print { pagebreak-recto() } else { std.pagebreak(weak: true) }
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 {
      let loc = el.location()
      let num-values = counter(heading).at(loc)
      let is-appendix = numbering("A", ..num-values) != numbering("1", ..num-values)
      
      link(loc, context {
        if is-appendix {
          [#tr("Bilaga", "Appendix") #numbering("A", ..num-values)]
        } else {
          [#tr("Kapitel", "Chapter") #numbering("1", ..num-values)]
        }
      })
    } else {
      it
    }
  }
  
  // Frontmatter
  front-cover(
    title: title,
    subtitle: subtitle,
    image: cover.image,
    program: program,
    authors: authors,
    department: department,
    year: year,
    gu: gu,
  )

  pagebreak()
  
  title-page(
    title: title,
    subtitle: subtitle,
    authors: authors,
    department: department,
    year: year,
    gu: gu
  )

  set page(numbering: "i")
  counter(page).update(1)

  imprint(
    title: title,
    subtitle: subtitle,
    program: program,
    authors: authors,
    supervisors: supervisors,
    advisor: advisor,
    examiner: examiner,
    co-examiner: co-examiner,
    department: department,
    cover-description: cover.description,
    year: year,
    gu: gu
  )
  
  abstract-page(
    title: title,
    subtitle: subtitle,
    authors: authors,
    department: department,
    body: abstracts.en,
    keywords: keywords,
    gu: gu,
  )
  pagebreak()
  
  if "sv" in abstracts {
    abstract(abstracts.sv, "sv")
    pagebreak()
  }

  if preface != "" {
    preface-page(body: preface)
    pagebreak()
  }
  
  if acknowledgments != "" {
    acknowledgments-page(
      body: acknowledgments,
      authors: authors,
    )
    pagebreak()
  }

  if abbreviations.len() > 0 {
    abbreviations-list(abbreviations)
    pagebreak()
  }

  if nomenclature.len() > 0 {
    nomenclature-list(nomenclature)
    pagebreak()
  }

  outline() 
  pagebreak()
  
  show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.inner()),
  )
  
  context {
    let figures = query(figure.where(kind: image))
    if figures.len() > 0 {
      outline(
        title: tr("Bilagor", "List of Figures"),
        target: figure.where(kind: image)
      )
      pagebreak()
    }
  }

  context {
    let tables = query(figure.where(kind: table))
    if tables.len() > 0 {
      outline(
        title: tr("Tabeller", "List of Tables"),
        target: figure.where(kind: table),
      )
    }
    pagebreak()
  }
  
  // Main content
  set page(numbering: "1")
  counter(page).update(1)
  set heading(numbering: heading-style(tr("Kapitel ", "Chapter "), "1.1", in-outline))
  show heading.where(level: 1): it => [
    #pagebreak()
    #align(center)[#large[#it]]
    #v(0.5em)
  ]
  
  body
  
  // Backmatter
  if print { std.pagebreak(to: "even") }
  back-cover(
    department: department,
    gu: gu,
  )
}