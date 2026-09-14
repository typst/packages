#import "dependencies.typ": *
#import "lib.typ": *

#let template(
  title: none,
  subtitle: none,
  authors: (),
  supervisors: (),
  abstract: none,
  introduction: none,
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
  font: "New Computer Modern",
  math-font: "New Computer Modern Math",
  lang: "en",
  cite-color: colors.purple,
  ref-color: colors.purple,
  link-color: blue,
  image-supplement: [figure],
  table-supplement: [table],
  citation-style: "alphanumeric",
  bib: [],
  abbreviations: (),
  before-content: none,
  after-content: none,
  doc,
) = {
  set text(lang: lang, font: font)
  show math.equation: set text(font: math-font)
  set document(
    title: title,
    author: authors,
    description: description,
    keywords: keywords,
  )

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

  set page(paper: paper-size, binding: left, margin: (
    inside: 2.54cm,
    outside: 3.04cm,
  ))

  set par(
    first-line-indent: 1em,
    spacing: 0.65em,
    justify: true,
    linebreaks: "optimized",
  )
  set list(indent: 1em, spacing: 1.2em, marker: ([•], [--]))
  show list: set block(inset: (top: 0.35em, bottom: 0.35em))

  set enum(indent: 1em, spacing: 1.2em)
  show enum: set block(inset: (top: 0.35em, bottom: 0.35em))

  set heading(numbering: "1.1")
  set figure(numbering: dependent-numbering("1.1", levels: 1))
  set math.equation(numbering: dependent-numbering("(1.1)", levels: 1))

  show ref: it => {
    let el = it.element

    if el != none and el.func() == math.equation {
      [#el.supplement #counter(math.equation).display(
          dependent-numbering("1.1"),
        )]
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
    layout(size => {
      let (width, height) = measure(cp)
      let alignment = center

      if width > size.width {
        alignment = left
      }

      align(alignment, cp)
    })
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

  init-acronyms(abbreviations)

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

  if introduction != none {
    blankpage()
    set align(center)

    text(size: sizes.chapter, heading(
      level: 1,
      "introduction",
      numbering: none,
    ))
    v(1.5em)
    introduction
  }

  show heading: hd => context {
    if hd.level == 1 {
      blankpage()
      let hd-counter = counter(heading).get().first()

      align(left, text(size: sizes.chapter, [
        #stack(
          spacing: 1em,
          line(length: 100%, stroke: 1pt + black),
          box([
            #if hd.numbering != none {
              [#hd-counter]
              h(0.75em)
              box(
                line(stroke: 1pt + black, angle: 90deg, length: 30pt),
                baseline: 6pt,
              )
              h(0.75em)
            }
            #hd.body]),
          line(length: 100%, stroke: 1pt + black),
        )
        #v(0.75em)
      ]))
    } else {
      let text-size = if hd.level == 1 {
        sizes.section
      } else if hd.level == 2 {
        sizes.subsection
      } else if hd.level == 3 {
        sizes.subsubsection
      } else {
        sizes.subsubsubsection
      }
      set text(size: text-size)
      block(inset: (top: 0.5em, bottom: 0.5em), {
        context counter(heading).display()
        h(0.75em)
        hd.body
      })
    }
  }

  include "pages/toc.typ"

  print-index(
    sorted: "up",
    row-gutter: 20pt,
    title: "List of Abbreviations",
    outlined: true,
    used-only: true,
  )

  set page(numbering: "1", header-ascent: 35%, header: context {
    // mimic header style from 'Alice in a Differentiable Wonderland' by S.Scardapane
    let curr-page = counter(page).get().first()
    // check if there is a one-level heading on the same page, if so dont's display the
    // header
    let next-h1 = query(selector(heading.where(level: 1)).after(here()))

    // in blank page
    if next-h1 == none or next-h1.len() == 0 {
      return
    }

    next-h1 = next-h1.first()

    let next-h1-page = counter(page).at(next-h1.location()).first()

    if curr-page > 1 and next-h1-page > 1 and next-h1-page != curr-page {
      set text(fill: colors.darkgray)

      let body = block(inset: 0pt, spacing: 0pt, width: 100%, [
        #if calc.even(curr-page) {
          let header-title = query(
            selector(heading.where(level: 1)).before(here()),
          )
            .last()
            .body
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

  show heading: reset-counter(counter(figure.where(kind: image)), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: table)), levels: 1)
  show heading: reset-counter(
    counter(figure.where(kind: "paragraph")),
    levels: 1,
  )
  show heading: reset-counter(counter(figure.where(kind: "callout")), levels: 1)
  show heading: reset-counter(
    counter(figure.where(kind: "definition")),
    levels: 1,
  )
  show heading: reset-counter(counter(figure.where(kind: "theorem")), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: "proof")), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: "info")), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: "tip")), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: "success")), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: "danger")), levels: 1)
  show heading: reset-counter(counter(figure.where(kind: "faq")), levels: 1)
  show heading: reset-counter(counter(math.equation), levels: 1)
  doc

  show bibliography: set par(spacing: 1.2em)

  bib

  if after-content != none {
    after-content
  }
}
