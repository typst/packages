#import "@preview/gb7714-bilingual:0.2.3": init-gb7714, multicite
#import "src/constant.typ": font-size, font-type, thesis-type
#import "src/cover.typ": cover
#import "src/abstract.typ": abstract, abstract-en
#import "src/outlines.typ": heading-outline, image-outline, table-outline
#import "src/header-footer.typ": append-header, leading-footer, main-footer, main-header
#import "src/main-format.typ": show-main, sub-fig
#import "src/utils.typ": disable-heading-number, heading-numbering, reset-page
#import "src/algorithm.typ": *
#import "src/achievement.typ": achievement-papers, achievement-patents, achievement-projects, blind-review-state
#import "src/appendix.typ": append-render

#let abstract-render(abstract: [], abstract-en: []) = {
  if abstract != [] {
    abstract
    pagebreak()
  }

  if abstract-en != [] {
    abstract-en
    pagebreak()
  }
}

#let outlines-render() = {
  heading-outline()
  pagebreak()

  context {
    if query(figure.where(kind: image)).len() > 0 {
      image-outline()
      pagebreak()
    }
  }

  context {
    if query(figure.where(kind: table)).len() > 0 {
      table-outline()
      pagebreak()
    }
  }
}

#let thesis(
  type: "master",
  title: (zh: [], en: []),
  author: (zh: [], en: []),
  teacher: (zh: [], en: []),
  teacher-degree: (zh: [], en: []),
  college: (zh: [], en: []),
  major: (
    discipline: [],
    direction: [],
    discipline-first: [],
    discipline-direction: [],
  ),
  date: (
    start: [],
    end: [],
    summit: [],
    defense: [],
  ),
  degree: (zh: [], en: []),
  lib-number: [],
  stu-id: [],
  abstract: [],
  abstract-en: [],
  conclusion: [],
  bibliography: none,
  achievement: [],
  acknowledgements: [],
  cv: [],
  is-print: false,
  blind-review: false,
  body,
) = {
  if type not in thesis-type.values() {
    panic("Invalid thesis type: " + type)
  }

  blind-review-state.update(blind-review)

  set text(size: font-size.small-four, font: font-type.sun, lang: "zh")
  set par(leading: 1.25em, spacing: 1.25em, justify: true)

  cover(
    type: type,
    title: title,
    author: author,
    teacher: teacher,
    teacher-degree: teacher-degree,
    college: college,
    major: major,
    date: date,
    degree: degree,
    lib-number: lib-number,
    stu-id: stu-id,
    is-print: is-print,
    blind-review: blind-review,
  )

  reset-page()

  show: page.with(footer: leading-footer())

  abstract-render(abstract: abstract, abstract-en: abstract-en)

  outlines-render()

  reset-page()

  show: page.with(header: main-header(type: type), footer: main-footer())

  [
    #show: show-main

    #if bibliography != none {
      show: init-gb7714.with(bibliography, style: "numeric", version: "2015")
      body
    } else {
      body
    }

    #disable-heading-number()

    #if conclusion != [] {
      [= 总结与展望 <chap:conclusion>]

      conclusion
      pagebreak()
    }

    #show: page.with(header: append-header())

    #append-render(
      type: type,
      bibliography: bibliography,
      achievement: achievement,
      acknowledgements: acknowledgements,
      cv: cv,
      blind-review: blind-review,
    )
  ]
}
