#let general-styles = rest => {
  show heading.where(level: 1): set heading(supplement: "Chapter")
  show heading.where(level: 2): set heading(supplement: "Section")
  show heading.where(level: 3): set heading(supplement: "Subsection")
  show heading.where(level: 4): set heading(supplement: "§")

  show heading: set text(hyphenate: false)
  show heading.where(level: 1): set align(right)

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
  show figure.where(kind: "algorithm"): set figure(supplement: "Algorithm")

  set list(
      indent: 2em
  )
  set enum(
      indent: 2em
  )

  set par(justify: true)

  show smallcaps: set text(font: "Latin Modern Roman Caps")
  show emph: it => {
    text(it, spacing: 4pt)
  }
  show link: underline

  rest
}
