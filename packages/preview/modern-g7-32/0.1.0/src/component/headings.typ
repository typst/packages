#let structural-heading-titles = (
  performers: [Список исполнителей],
  abstract: [Реферат],
  contents: [Содержание],
  terms: [Термины и определения],
  abbreviations: [Перечень сокращений и обозначений],
  intro: [Введение],
  conclusion: [Заключение],
  references: [Список использованных источников],
)

#let structure-heading-style = it => {  
  align(center)[#upper(it)]
}

#let structure-heading(body) = {
  structure-heading-style(heading(numbering: none)[#body])
}

#let headings(text-size, indent) = body => {
  show heading: set text(size: text-size)
  set heading(numbering: "1.1")

  show heading: it => {
    if it.body not in structural-heading-titles.values() {
      pad(it, left: indent)
    } else {
      it
    }
  }

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  let structural-heading = structural-heading-titles.values().fold(selector, (acc, i) => acc.or(heading.where(body: i, level: 1)))

  show structural-heading: set heading(numbering: none)
  show structural-heading: it => {
    pagebreak(weak: true)
    structure-heading-style(it)
  }

  show heading: set block(below: 2em, above: 2em)
  
  body
}
