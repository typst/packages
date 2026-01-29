#import "../styling/tokens.typ": tokens
#import "../utils.typ": centered, ensure-array, today
#import "@preview/tieflang:0.1.0": pop-lang, push-lang, tr

#let render-abstract(lang-code, abstract-text, keywords, authors, title) = context {
  push-lang(lang-code)

  show: doc => centered(tr().abstract, doc)
  show grid.cell.where(x: 0): set text(weight: "bold")

  let authors = ensure-array(authors)
  let keywords = ensure-array(keywords)

  grid(
    columns: (2cm, 1fr),
    column-gutter: 0.4cm,
    row-gutter: 0.3cm,
    tr().title, title,
    (tr().author)(authors.len()), authors.join(", "),
    tr().date, today(),
    tr().institution, tr().institution_name,
  )

  v(0.5cm)
  abstract-text
  v(0.5cm)

  grid(
    columns: (auto, 1fr),
    column-gutter: 0.4cm,
    row-gutter: 0.3cm,
    tr().keywords, keywords.join(", "),
  )

  pop-lang()
}

#let abstract-page(
  en: none,
  de: none,
  keywords: none,
  authors: none,
  title: none,
) = {
  if en != none {
    render-abstract("en", en, keywords, authors, title)
  }
  if de != none {
    render-abstract("de", de, keywords, authors, title)
  }
}
