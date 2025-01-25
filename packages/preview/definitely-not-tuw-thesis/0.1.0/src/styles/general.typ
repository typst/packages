#let general-styles = rest => {
  set par(justify: true)

  show emph: it => {
    text(it, spacing: 4pt)
  }

  show link: underline
  show heading.where(level: 1): it => {
    pagebreak()
    text(it, size: 1.6em)
    v(14pt)
  }

  show heading.where(level: 2): it => {
    text(it, size: 1.2em)
    v(6pt)
  }

  show figure: it => {
    it
    v(30pt)
  }

  rest
}