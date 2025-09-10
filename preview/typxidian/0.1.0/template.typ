#let template(
  title: none,
  subtitle: none,
  description: none,
  abstract: none,
  faculty: none,
  department: none,
  university: none,
  academic-year: none,
  degree: none,
  logo: none,
  citation: none,
  keywords: (),
  authors: (),
  supervisors: (),
  lang: "en",
  font: "Bitstream Charter",
  citation-style: "alphanumeric",
  bib-file: "bibliography.bib",
  binding: left,
  body-size: 12pt,
  before-content: none,
  after-content: none,
  is-thesis: false,
  include-credits: true,
  doc,
) = {
  set document(title: title, description: description, author: authors)
  set text(lang: lang, font: font)

  /*** PREAMBLE - General styles ***/
  import "dependencies.typ": booktabs-default-table-style, dependent-numbering, reset-counter
  show: booktabs-default-table-style

  let blankpage() = {
    set page(numbering: none, header: none)
    pagebreak()
    // context counter(page).update(counter(page).at(here()).at(0) - 1)
    pagebreak()
  }

  // Color palette
  let purple = rgb("7952ee")
  let darkgray = rgb("#6d6e6d")
  let cyan = rgb("53dfdd")
  let red = rgb("fb464c")
  let orange = rgb("e9973f")
  let green = rgb("44cf6e")

  // Font sizes
  let chapter-size = body-size * 2
  let decrement-size = 6pt

  let calc-font-size(base-size, level, decrement) = {
    if level > 4 {
      level = 4
    }
    return base-size - (level - 1) * decrement
  }
  
  let paragraph-counter = counter("paragraph")

  // Citations, Links and References styling
  set cite(style: citation-style)
  show cite: set text(fill: purple)
  show ref: set text(fill: purple)
 
  // Custom ref for heading from 4 and above 
  show ref: it => context {
    let el = it.element
    if el != none and el.func() == heading and el.level >= 4{
      [Paragraph #paragraph-counter.display(dependent-numbering("1.1"))]
    } else {
      it
    }
  }

  show link: it => {
    if type(it.dest) == str {
      // ext link
      text(fill: blue)[#underline(it.body)]
    } else {
      // text(fill: purple, it.body)
      it.body
    }
  }

  // Page layout
  set page(binding: binding, margin: (
    top: 12%,
    bottom: 12%,
    inside: 12%,
    outside: 15%,
  ))

  show heading: hd => {
    let font-size = calc-font-size(chapter-size, hd.level, decrement-size)

    let prev-headers = query(
      selector(heading.where(level: 1)).before(here()),
    )
    let prev-header = prev-headers.at(prev-headers.len() - 2)
    let next-header = query(
      selector(heading.where(level: 1)).after(here()),
    ).first()
    let next-counter = counter(heading.where(level: 1))
      .at(next-header.location())
      .first()
    let prev-counter = counter(heading).at(prev-header.location()).first()
    let curr-counter = counter(heading).get().first()

    if hd.level == 1 {
      blankpage()

      block(text(size: font-size, weight: "bold")[
        #if (
          (prev-counter != curr-counter and curr-counter > 0)
            or curr-counter == 1
        ) {
          [#curr-counter]
          h(1em)
          box(baseline: 8pt, line(
            length: 1.25em,
            stroke: 1.25pt + darkgray,
            angle: 90deg,
          ))
          h(1em)
        }
        #hd.body
        #v(1.75em)
      ])
    } else if hd.level < 4 {
      text(size: font-size, weight: "bold")[#hd]
      v(0.35em)
    } else {
      // treat other headers as paragraphs
      linebreak()
      box(block([#hd.body. #h(0.35em) #paragraph-counter.step()]))
    }
  }

  set par(
    spacing: 0.70em,
    first-line-indent: 0.75em,
    justify: true,
  )

  // Figures, Tables & Equations
  show figure.caption: cp => {
    v(0.65em)
    cp
  }
  show figure: set block(above: 1.75em, below: 2em)
  show math.equation: set block(above: 1.75em, below: 2em)
  show math.equation.where(block: false): math.display

  /*** FRONT MATTER ***/

  // Cover page

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

  if citation != none {
    blankpage()
    set text(16pt)
    set page(margin: (right: 7em, left: 7em))
    align(center + horizon, [
      #citation
    ])
  }

  set page(numbering: "i")
  counter(page).update(0)

  if abstract != none {
    set align(center)
    heading(level: 1, "Abstract")
    abstract
  }
  
  if before-content != none {
    before-content
  }
  
  // Toc
  include "pages/toc.typ"

  // Glossary
  include "pages/glossary.typ"

  /*** MAIN MATTER ***/

  // Customize figures and equations to make counters depend on the current chapter number
  set heading(numbering: "1.1")
  set figure(numbering: dependent-numbering("1.1", levels: 1))
  set math.equation(numbering: dependent-numbering("(1.1)", levels: 1))
  
  show heading.where(level: 4): set heading(numbering: dependent-numbering("1.1", levels: 1))
    
  show heading: reset-counter(paragraph-counter, levels: 1)
  show heading: reset-counter(counter(figure))
  show heading: reset-counter(counter(math.equation))

  {
    set page(
      numbering: "1",
      header-ascent: 45%,
      header: context {
        // mimic header style from 'Alice in a Differentiable Wonderland' by S.Scardapane
        let curr-page = counter(page).get().first()
        // check if there is a one-level heading on the same page, if so dont's display the
        // header
        let next-h1 = query(
          selector(heading.where(level: 1)).after(here()),
        ).first()
        let next-h1-page = counter(page).at(next-h1.location()).first()

        if curr-page > 1 and next-h1-page > 1 and next-h1-page != curr-page {
          set text(fill: darkgray)

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
      },
    )
    counter(page).update(0)

    doc
  }

  /*** BACK MATTER ***/

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
            #v(0.35em)
          ],
        ))
      rows.join()
    }
    bib
  }

  set page(numbering: "1")
  bibliography(bib-file)

  if after-content != none {
    after-content
  }

  if include-credits != none {
    set page(numbering: none)
    pagebreak()
    set page(margin: (top: 15em))

    align(center + horizon, [
      *This document was written using _TypXidian_*,
      a Typst template inspired by Obsidian. \ If you'd
      like to contribute to the project, please open
      an issue or a pull request on our github repository.

      #v(0.75em)
      #link("https://github.com/angelonazzaro/typxidian")[Github Repository.]
    ])
  }
}
