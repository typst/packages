#import "lib.typ": *
#import "dependencies.typ": *
#import "components/wideTable.typ": *
#import "pages/cover.typ": cover
#import "pages/appendixAi.typ": appendix-ai as appendix-ai-page

#let template(
  title: none,
  title-size: sizes.chapter,
  subtitle: none,
  authors: (),
  supervisors: (),
  abstract: none,
  abstract-alignment: center,
  quote: none,
  quote-alignment: center + horizon,
  acknowledgments: none,
  acknowledgments-alignment: left + horizon,
  introduction: none,
  description: none,
  declaration-signature: "../figures/signature.png",
  show-declaration: true,
  keywords: (),
  abbreviations: (),
  abbr-title: "List of Abbreviations",
  university: none,
  date: datetime.today(),
  course-code: none,
  course: none,
  department: none,
  logo: none,
  logo-width: 150pt,
  is-thesis: false,
  thesis-type: none,
  paper: "a4",
  binding: left,
  margin: (inside: 2.54cm, outside: 3.04cm),
  page-numbering: "1",
  font: "New Computer Modern",
  math-font: "New Computer Modern Math",
  font-sizes: sizes,
  citation-style: "ieee",
  cite-color: colors.primary,
  ref-color: colors.secondary,
  link-color: blue,
  chapter-supplement: "Chapter",
  chapter-alignment: right,
  chapter-style: "basic",
  chapter-color: colors.secondary,
  lang: "en",
  bib: none,
  bib-title: "Bibliography",
  before-content: none,
  after-content: none,
  appendix-ai: none,
  doc,
) = {

  set page(
    paper: paper,
    binding: binding,
    numbering: none,
    number-align: center,
  )

  set document(
    title: title,
    // TODO: if authors is a list of dict, convert it to a list of strings getting only the name
    // author:,
    description: description,
    keywords: keywords,
  )

  // Init Codly
  show: codly-init.with()
  codly(languages: codly-languages)

  set text(lang: lang, font: font)
  show math.equation: set text(font: math-font)

  set cite(style: citation-style)
  show cite: set text(fill: cite-color)
  show ref: set text(fill: ref-color)

  show link: it => {
    if type(it.dest) == str {
      // external link
      text(fill: link-color)[#underline(it.body)]
    } else {
      it
    }
  }

  set par(
    first-line-indent: (amount: 1em, all: true),
    spacing: 0.65em,
    justify: true,
  )

  set list(indent: 2.5em, spacing: 1.2em, marker: ([•], [--]))
  show list: set block(inset: (top: 0.25em, bottom: 0.25em))

  set enum(indent: 2.5em, spacing: 1.2em)
  show enum: set block(inset: (top: 0.25em, bottom: 0.25em))

  // numbering for figures and equations depending on 1st level heading
  set heading(numbering: "1.1")

  set figure(numbering: (..nums) => {
    let section = counter(heading).get().first()
    numbering("1.1", section, ..nums)
  })

  set math.equation(numbering: (..nums) => {
    let section = counter(heading).get().first()
    numbering("(1.1)", section, ..nums)
  })

  show figure: set block(above: 1.5em, below: 1.5em)
  show math.equation: set block(above: 1.5em, below: 1.5em)

  show ref: it => {
    let el = it.element
    // https://forum.typst.app/t/how-to-counter-display-at-location-or-get-remote-context/5096/2
    if el != none and el.func() == math.equation {
      [#el.supplement #counter(heading.where(level: 1)).display().#counter(el.func()).at(el.location()).first()]
    } else {
      it
    }
  }

  // display counter under images and tables even if caption is none
  // figures outside the main body are not affected by this
  show figure: it => context {
    if it.kind != image and it.kind != table {
      it
    } else {
      if it.caption == none and counter(figure.where(kind: it.kind)).get().first() > 0 {
        it.body
        v(0.25em)
        [#it.supplement~#counter(figure.where(kind: it.kind)).display()]
      } else {
        it
      }
    }
  }

  // caption is aligned to center if its width is smaller than text width, otherwise it is
  // aligned to the left
  show figure.caption: it => context {
    v(0.25em)
    layout(size => {
      let (width, height) = measure(it)
      let alignment = if width <= size.width { center } else { left }
      align(alignment, it)
    })
  }

  if abbreviations.len() > 0 {
    // Populate acronym state once so #acr(...) and the index can read/update it safely.
    init-acronyms(abbreviations)
  }

  cover(
    title: title,
    subtitle: subtitle,
    authors: authors,
    supervisors: supervisors,
    course-code: course-code,
    course: course,
    department: department,
    university: university,
    date: date,
    logo: logo,
    logo-width: logo-width,
    title-size: title-size,
    is-thesis: is-thesis,
    thesis-type: thesis-type,
  )

  pagebreak(weak: true)

  if quote != none {
    counter(page).update(n => n - 1)
    set text(size: font-sizes.subsubsection)
    set page(margin: (right: 7em, left: 7em))
    align(center + horizon, [#quote])
    pagebreak(weak: true)
  }

  set page(numbering: "i", margin: margin)
  counter(page).update(2)

  if abstract != none {
    counter(page).update(n => n - 1)
    align(abstract-alignment, text(size: font-sizes.chapter, weight: "bold")[
      #heading(
        "Abstract",
        level: 1,
        numbering: none
      )
    ])
    v(3em)

    align(abstract-alignment, text(size: font-sizes.body)[#abstract])
    pagebreak(weak: true)
  }

  if acknowledgments != none {
    align(abstract-alignment, text(size: font-sizes.chapter, weight: "bold")[
      #heading(
        "Acknowledgments",
        level: 1,
        numbering: none
      )
    ])
    v(3em)

    align(abstract-alignment, text(size: font-sizes.body)[#acknowledgments])
    pagebreak(weak: true)
  }

  if show-declaration {
    align(abstract-alignment, text(size: font-sizes.chapter, weight: "bold")[
      #heading(
        "Declaration",
        level: 1,
        numbering: none
      )
    ])
    v(3em)

    text(size: font-sizes.body)[
      I hereby declare that the work described in this dissertation is, except where otherwise stated, entirely my own work and has not been submitted as an exercise for a degree at this or any other university.
      \
      \
      Signed:
      \
      #v(2em)

      // I'm the goat lol
      #table(
        image(declaration-signature, width: 100pt),
        stroke: (
          bottom: 1pt + colors.secondary,
          left: none,
          right: none,
          top: none,
        )
        )
      \
      #authors.map(author => author.name).join(", ")
      \
      Date: #date.display("[day]/[month]/[year]")
    ]
    pagebreak(weak: true)
  }

  if before-content != none {
    context {
      show heading: set heading(supplement: "extra-content")
      before-content
    }
  }

  if introduction != none {
    blankpage()
    counter(page).update(n => n - 1)
    align(abstract-alignment, text(size: font-sizes.chapter, weight: "bold")[
      #heading(
        "Introduction",
        level: 1,
        numbering: none,
      )
    ])
    v(3em)
    introduction
    pagebreak(weak: true)
  }

  show heading.where(level: 1): set heading(supplement: chapter-supplement)

  show heading.where(level: 1): it => context {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "par")).update(0)
    counter(figure.where(kind: "callout")).update(0)
    counter(figure.where(kind: "callout")).update(0)
    counter(figure.where(kind: "info")).update(0)
    counter(figure.where(kind: "faq")).update(0)
    counter(figure.where(kind: "danger")).update(0)
    counter(figure.where(kind: "tip")).update(0)
    counter(figure.where(kind: "success")).update(0)
    counter(figure.where(kind: "definition")).update(0)
    counter(figure.where(kind: "theorem")).update(0)
    counter(figure.where(kind: "proof")).update(0)
    counter(math.equation).update(0)

    let content = [#text(size: font-sizes.chapter)[#it]]

    if it.numbering != none {
      if chapter-style == "wonderland" {
        content = [
          #align(left, text(size: sizes.chapter, [
            #stack(
              spacing: 1em,
              line(length: 100%, stroke: 1pt + black),
              box([
                #counter(heading).get().first()
                #h(0.75em)
                #box(
                  line(stroke: 1pt + black, angle: 90deg, length: 30pt),
                  baseline: 6pt,
                )
                #h(0.75em)
                #it.body
              ]),
              line(length: 100%, stroke: 1pt + black),
            )
            #v(0.75em)
          ]))]
      } else {
        content = align(chapter-alignment, [
          #text(size: font-sizes.subsection, fill: chapter-color)[#upper(chapter-supplement) #(
              counter(heading).get().first()
            )]
          #linebreak()
          #v(0.35em)
          #text(size: font-sizes.chapter)[#it.body]
        ])
      }
    }

    content += [#v(2em)]

    if chapter-style == "wonderland" {
      content = block(width: 100%, content)
    } else {
      content = block(width: 90%, content)
    }

    align(abstract-alignment, content)
  }

  show heading.where(level: 2).or(heading.where(level: 3)).or(heading.where(level: 4)): it => {
    let text-size = if it.level == 2 {
      font-sizes.section
    } else if it.level == 3 {
      font-sizes.subsection
    } else if it.level == 4 {
      font-sizes.subsubsection
    }

    text(size: text-size)[
      #block([
        #if it.numbering != none {
          context counter(heading).display()
          h(0.35em)
        }
        #it.body
      ])
    ]
    v(0.75em)
  }

  // TOC
  include "pages/toc.typ"

  // BODY
  set page(
    numbering: page-numbering,
    header-ascent: 35%,
    header: context {
      set text(fill: colors.darkgrey)
      let curr-page = counter(page).get().first()
      let next-chp = query(selector(heading.where(level: 1)).after(here()))

      // we are in a blank page
      if next-chp == none or next-chp.len() == 0 {
        return
      }

      next-chp = next-chp.first()
      let next-chp-page = counter(page).at(next-chp.location()).first()

      // check if there is 1st level heading on this page, if there is do not display the header
      if curr-page == 1 or next-chp-page == 1 or curr-page == next-chp-page {
        return
      }

      let alignment = none
      let body = none

      if calc.even(curr-page) {
        alignment = right
        let header-title = query(selector(heading).before(here())).last().body
        body = [#curr-page #h(1fr) #header-title]
      } else {
        alignment = left
        let header-title = query(selector(heading.where(level: 1)).before(here())).last().body
        body = [#chapter-supplement #counter(heading.where(level: 1)).display(): #header-title
          #h(1fr) #curr-page]
      }

      align(alignment, [
        #block(inset: 0pt, spacing: 0pt, body)
        #v(0.75em)
        #line(length: 100%, stroke: 0.2pt)
      ])
    },
  )
  set text(size: font-sizes.body)
  counter(page).update(1)

  doc

  set page(numbering: "a", header: none)
  counter(page).update(1)

  // BIBLIOGRAPHY

  show bibliography: set par(spacing: 1.2em)

  if type(bib) == content {
    bib
    pagebreak(weak: true)
  } else {
    bibliography(bib, title: bib-title)
    pagebreak(weak: true)
  }


  // AI Appendix (if provided)
  if appendix-ai != none {
    pagebreak()
    context {
      show heading: set heading(supplement: "Appendix")

      if type(appendix-ai) == dictionary {
        appendix-ai-page(..appendix-ai)
      } else {
        appendix-ai
      }
    }
  }

  if after-content != none {
    context {
      show heading: set heading(supplement: "extra-content")
      after-content
    }
  }

  // Tables
  // dynamic LOF, LOT, LOD, displayed only if necessary
  let dynamic-list-off(title, kind) = context {
    if query(figure.where(kind: kind)).len() > 0 {
      pagebreak()
      heading(title, level: 1, numbering: none)
      outline(title: none, indent: auto, target: figure.where(kind: kind))
    }
  }

  if abbreviations.len() > 0 {
    // Acronyms
    print-index(
      sorted: "up",
      row-gutter: 20pt,
      title: abbr-title,
      outlined: true,
      used-only: true,
    )
  }

  dynamic-list-off("List of Figures", image)
  dynamic-list-off("List of Tables", table)
  dynamic-list-off("List of Definitions", "definition")
  dynamic-list-off("List of Theorems", "theorem")
}