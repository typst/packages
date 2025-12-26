#import "lib.typ": *
#import "dependencies.typ": *

#let template(
  title: none,
  title-size: sizes.chapter,
  subtitle: none,
  authors: (),
  supervisors: (),
  abstract: none,
  abstract-alignment: center,
  quote: none,
  acknowledgments: none,
  introduction: none,
  description: none,
  keywords: (),
  abbreviations: (),
  abbr-title: "List of Abbreviations",
  university: none,
  academic-year: none,
  course: none,
  department: none,
  logo: none,
  logo-width: 110pt,
  is-thesis: false,
  thesis-type: none,
  paper: "a4",
  binding: left,
  margin: (inside: 2.54cm, outside: 3.04cm),
  page-numbering: "1",
  font: "New Computer Modern",
  math-font: "New Computer Modern Math",
  font-sizes: sizes,
  citation-style: "alphanumeric",
  cite-color: colors.purple,
  ref-color: colors.purple,
  link-color: blue,
  chapter-supplement: "Chapter",
  chapter-alignment: right,
  chapter-style: "basic",
  chapter-color: colors.purple.darken(30%),
  lang: "en",
  bib: none,
  bib-title: "Bibliography",
  before-content: none,
  after-content: none,
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
    // author: authors,
    description: description,
    keywords: keywords,
  )

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
  show list: set block(inset: (top: 1em, bottom: 1em))

  set enum(indent: 2.5em, spacing: 1.2em)
  show enum: set block(inset: (top: 1em, bottom: 1em))

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

  // caption is aligned to center if its widht is smaller than text width, otherwise it is
  // aligned to the left
  show figure.caption: it => context {
    v(0.25em)
    layout(size => {
      let (width, height) = measure(it)
      let alignment = if width <= size.width { center } else { left }
      align(alignment, it)
    })
  }

  // COVER
  import "pages/cover.typ": cover

  cover(
    title: title,
    subtitle: subtitle,
    authors: authors,
    supervisors: supervisors,
    course: course,
    department: department,
    university: university,
    academic-year: academic-year,
    logo: logo,
    logo-width: logo-width,
    title-size: title-size,
    is-thesis: is-thesis,
    thesis-type: thesis-type,
  )

  if quote != none {
    pagebreak()
    counter(page).update(n => n - 1)
    set text(size: font-sizes.subsubsection)
    set page(margin: (right: 7em, left: 7em))
    align(center + horizon, [#quote])
  }

  set page(numbering: "i", margin: margin)
  counter(page).update(1)

  if abstract != none {
    blankpage()
    counter(page).update(n => n - 1)
    align(abstract-alignment, text(size: font-sizes.chapter, weight: "bold")[
      #heading(
        "Abstract",
        level: 1,
        numbering: none,
      )
    ])
    v(3em)
    abstract
  }

  if before-content != none {
    before-content
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
  }

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

    let currpage = counter(page).get().first()

    if currpage > 1 or it.supplement == [toc] {
      pagebreak()
      {
        set page(numbering: none, header: none)
        let currpage = counter(page).get().first()
        pagebreak(to: "odd")
      }
    }

    align(chapter-alignment, content)
  }

  show heading.where(level: 2).or(heading.where(level: 3)).or(heading.where(level: 4)): it => {
    let text-size = if it.level == 2 {
      font-sizes.section
    } else if it.level == 3 {
      font-sizes.subsection
    } else if it.level == 4 {
      font-sizes.subsubsection
    }

    text(size: text-size)[#block([#context counter(heading).display() #h(0.35em)  #it.body])]
    v(0.75em)
  }

  // TOC
  include "pages/toc.typ"


  // Acronyms
  init-acronyms(abbreviations)
  print-index(
    sorted: "up",
    row-gutter: 20pt,
    title: abbr-title,
    outlined: true,
    used-only: true,
  )

  // BODY
  set page(
    numbering: page-numbering,
    header-ascent: 35%,
    header: context {
      set text(fill: colors.darkgray)
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
  counter(page).update(0)

  blankpage(single: true)

  doc

  // BIBLIOGRAPHY

  show bibliography: set par(spacing: 1.2em)

  if type(bib) == content {
    bib
  } else if bib != none {
    bibliography(bib, title: bib-title)
  }

  if after-content != none {
    after-content
  }
}
