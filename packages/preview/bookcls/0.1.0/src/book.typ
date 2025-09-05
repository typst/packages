// Exported packages
#import "@preview/equate:0.3.2": *
// Internals
#import "book-environments.typ": *
#import "book-outlines.typ": *
#import "book-components.typ": *
#import "book-theming.typ": *
#import "book-helper.typ": *

// Template
#let book(
  title: "Title",
  author: "Author Name",
  book-config: default-book-config,
  body
) = context {
  // Document's properties
  set document(author: author, title: title)
  states.author.update(author)
  states.title.update(title)

  let config-book = default-book-config + book-config
  states.theme.update(config-book.theme)

  let book-colors = default-book-config.colors + config-book.colors
  states.colors.update(book-colors)

  let book-fonts = default-book-config.fonts + config-book.fonts

  // Fonts
  set text(font: book-fonts.body, lang: config-book.lang, size: text-size, ligatures: false)

  // Math font
  show math.equation: set text(font: book-fonts.math, stylistic-set: 1)

  // Equations
  show: equate.with(breakable: true, sub-numbering: true)

  // Paragraphs
  set par(justify: true)

  // Localization
  let localization = json("resources/i18n/fr.json")
  if config-book.lang.contains("en") {
    localization = json("resources/i18n/en.json")
  }
  states.localization.update(localization)

  // Headings
  show: heading-level1
  show: heading-level2
  show: heading-level3
  show: headings-on-odd-page

  // References
  set ref(supplement: it => none)
  show ref: set text(fill: book-colors.primary) if config-book.theme.contains("fancy") or config-book.theme.contains("modern")

  // Citations
  show cite: it => {
    show regex("\[|\]"): it => text(fill: black)[#it]
    it
  }

  // Outline entries
  set outline(depth: 3)
  show: outline-entry

  // Figures
  let numbering-fig = n => {
      let h1 = counter(heading).get().first()
      numbering(states.num-pattern-fig.get(), h1, n)
  }

  show figure.where(kind: image): set figure(
      supplement: fig-supplement,
      numbering: numbering-fig,
      gap: 1.5em
    )

  show figure: set figure.caption(separator: [ -- ])

  // Equations
  let numbering-eq = (..n) => {
    let h1 = counter(heading).get().first()
    numbering(states.num-pattern-eq.get(), h1, ..n)
  }

  set math.equation(numbering: numbering-eq)

  // Table customizations
  show: show-if(config-book.theme.contains("fancy"), it => {
    show table.cell.where(y: 0): set text(weight: "bold", fill: white)
    set table(
    fill: (_, y) => if y == 0 {book-colors.primary} else if calc.odd(y) { book-colors.secondary.lighten(60%)},
    stroke: (x, y) => (
      left: if x == 0 or y > 0 { (thickness: 1pt, paint: book-colors.secondary) } else { (thickness: 1pt, paint: book-colors.primary) },
      right: (thickness: 1pt, paint: book-colors.secondary),
      top: if y <= 1 { (thickness: 1pt, paint: book-colors.secondary) } else { 0pt },
      bottom: (thickness: 1pt, paint: book-colors.secondary),
    )
  ); it})

  show: show-if(config-book.theme.contains("modern"), it => {
    show table.cell.where(y: 0): set text(weight: "bold", fill: white)
    set table(
    fill: (_, y) => if y == 0 {book-colors.primary} else if calc.odd(y) { book-colors.secondary.lighten(60%)},
    stroke: none
  ); it})


  // Tables
  show figure.where(kind: table): set figure(
    numbering: numbering-fig,
    // gap: 1em
  )
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }

  // Lists
  set list(marker: [#text(fill:book-colors.primary, size: 1.75em)[#sym.bullet]])
  set enum(numbering: n => text(fill:book-colors.primary)[#n.])

  // Title page
  if config-book.title-page != none {
    config-book.title-page
  } else {
    default-title-page
  }

  // Page layout
  set page(
    paper: paper-size,
    header: page-header,
    footer: page-footer
  ) if config-book.theme.contains("modern")

  set page(
    paper: paper-size,
    header: page-header,
  ) if config-book.theme.contains("fancy") or config-book.theme.contains("classic")

  body
}
