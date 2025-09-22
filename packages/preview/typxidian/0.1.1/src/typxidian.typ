#import "dependencies.typ": *
#import "lib.typ": *

#let template(
  title: none,
  subtitle: none,
  authors: (),
  supervisors: (),
  abstract: none,
  quote: none,
  university: none,
  degree: none,
  faculty: none,
  department: none,
  academic-year: none,
  description: none,
  logo: none,
  is-thesis: true,
  keywords: (),
  paper-size: "a4",
  font: "Times New Roman",
  lang: "en",
  cite-color: colors.purple,
  ref-color: colors.purple,
  link-color: blue,
  image-supplement: [Figure],
  table-supplement: [Table],
  citation-style: "alphanumeric",
  bib: [],
  abbreviations: (),
  before-content: none,
  after-content: none,
  doc,
) = {
  set text(lang: lang, font: font)
  set document(title: title, author: authors, description: description, keywords: keywords)

  set cite(style: citation-style)

  show cite: set text(fill: cite-color)
  show ref: set text(fill: ref-color)

  show link: it => {
    if type(it.dest) == str {
      // ext link
      text(fill: link-color)[#underline(it.body)]
    } else {
      it
    }
  }

  set page(paper: paper-size, binding: left, margin: (inside: 2.54cm, outside: 3.04cm))

  set par(first-line-indent: 1em, spacing: 0.65em, justify: true, linebreaks: "optimized")
  set list(indent: 1em, spacing: 0.85em, marker: ([•], [--]))
  show list: set block(inset: (top: 0.35em, bottom: 0.35em))

  set heading(numbering: "1.1")
  set figure(numbering: dependent-numbering("1.1", levels: 1))
  set math.equation(numbering: dependent-numbering("(1.1)", levels: 1))

  show ref: it => {
    let el = it.element

    if el != none and el.func() == math.equation {
      [#el.supplement #counter(math.equation).display(dependent-numbering("1.1"))]
    } else {
      it
    }
  }

  show figure.where(kind: image): set figure(supplement: image-supplement)
  show figure.where(kind: table): set figure(supplement: table-supplement)
 
  show figure.caption.where(kind: "definition"): it => []
  show figure.caption.where(kind: "theorem"): it => []
  show figure.caption.where(kind: "proof"): it => []
  
  show: booktabs-default-table-style
  
  show figure.caption: cp => context {
    v(0.45em)
    cp
  }

  show figure: set block(above: 1.25em, below: 1.25em)
  show math.equation: set block(above: 1.25em, below: 1.25em)

  import "pages/cover.typ": coverpage

  coverpage(
    title: title,
    subtitle: subtitle,
    authors: authors,
    supervisors: supervisors,
    faculty: faculty,
    department: department,
    university: university,
    academic-year: academic-year,
    degree: degree,
    logo: logo,
    is-thesis: is-thesis,
  )

  set text(size: sizes.body)

  if quote != none {
    blankpage()
    set text(size: sizes.subsection)
    set page(margin: (right: 7em, left: 7em))
    align(center + horizon, emph(quote))
  }

  if before-content != none {
    before-content
  }

  counter(page).update(1)
  set page(numbering: "i")

  if abstract != none {
    blankpage()
    set align(center)

    text(size: sizes.chapter, heading(level: 1, "Abstract", numbering: none))
    v(1.5em)
    abstract
  }

  show heading: hd => context {
    if hd.level == 1 {
      blankpage()
      counter(figure).update(0)
      counter(math.equation).update(0)
      let hd-counter = counter(heading).get().first()

      align(left, text(size: sizes.chapter, [
        #stack(
          spacing: 1em,
          line(length: 100%, stroke: 1pt + black),
          box([
            #if hd.numbering != none {
              [#hd-counter]
              h(0.75em)
              box(line(stroke: 1pt + black, angle: 90deg, length: 30pt), baseline: 6pt)
              h(0.75em)
            }
            #hd.body]),
          line(length: 100%, stroke: 1pt + black),
        )
        #v(0.75em)
      ]))
    } else {
      set text(size: if hd.level == 1 { sizes.section } else { sizes.subsection })
      block(inset: (top: 0.5em, bottom: 0.5em), {
        context counter(heading).display()
        h(0.75em)
        hd.body
      })
    }
  }

  include "pages/toc.typ"

  init-acronyms(abbreviations)
  print-index(sorted: "up", row-gutter: 20pt, title: "List of Abbreviations", outlined: true, used-only: true)

  set page(numbering: "1", header-ascent: 35%, header: context {
    // mimic header style from 'Alice in a Differentiable Wonderland' by S.Scardapane
    let curr-page = counter(page).get().first()
    // check if there is a one-level heading on the same page, if so dont's display the
    // header
    let next-h1 = query(selector(heading.where(level: 1)).after(here()))
    
    // in blank page
    if next-h1 == none or next-h1.len() == 0{
     return; 
    }
    
    next-h1 = next-h1.first()
    
    let next-h1-page = counter(page).at(next-h1.location()).first()

    if curr-page > 1 and next-h1-page > 1 and next-h1-page != curr-page {
      set text(fill: colors.darkgray)

      let body = block(inset: 0pt, spacing: 0pt, width: 100%, [
        #if calc.even(curr-page) {
          let header-title = query(selector(heading.where(level: 1)).before(here())).last().body
          [#curr-page #h(1fr) #header-title]
        } else {
          let header = query(
            selector(heading.where(level: 1)).before(here()),
          ).last()

          [Chapter #counter(heading).at(header.location()).at(0): #header.body #h(1fr) #curr-page]
        }
      ])

      let alignment = if calc.even(curr-page) { right } else { left }
      align(alignment, box([#body #v(0.9em) #line(
          length: 100%,
          stroke: 0.2pt,
        )]))
    }
  })
  counter(page).update(1)
  doc

  show bibliography: bib => {
    show grid: g => {
      let rows = g
        .children
        .chunks(2) // each row = 2 cells (key + body)
        .map(row => block(
          width: 100%,
          [
            // key in a fixed-width box
            #box(width: 4.5em, baseline: -14.5pt, align(left)[#row.at(0).body])
            #h(0.75em)
            // body stretches and wraps
            #box(width: 1fr, align(left)[#row.at(1).body])
            #v(0.5em)
          ],
        ))
      rows.join()
    }
    bib
  }

  bib

  if after-content != none {
    after-content
  }
}
