// Exported packages
#import "@preview/equate:0.3.2": *
// Internals
#import "bookly-environments.typ": *
#import "bookly-outlines.typ": *
#import "bookly-components.typ": *
#import "bookly-helper.typ": *
#import "bookly-tufte.typ": *
#import "bookly-themes.typ": *

// Template
#let bookly(
  title: "Title",
  author: "Author Name",
  theme: fancy,
  tufte: false,
  logo: none,
  lang: "fr",
  fonts: default-fonts,
  colors: default-colors,
  title-page: default-title-page,
  body
) = context {
  // Document's properties
  set document(author: author, title: title)
  states.author.update(author)
  states.title.update(title)
  states.tufte.update(tufte)

  let book-colors = default-colors + colors
  states.colors.update(book-colors)

  // Fonts
  set text(font: fonts.body, lang: lang, size: text-size, ligatures: false)

  // Math font
  show math.equation: set text(font: fonts.math, stylistic-set: 1)

  // Equations
  show: equate.with(breakable: true, sub-numbering: true)

  // Paragraphs
  set par(justify: true)

  // Localization
  let localization = json("resources/i18n/fr.json")
  if lang.contains("en") {
    localization = json("resources/i18n/en.json")
  }
  states.localization.update(localization)


  // References
  set ref(supplement: it => none)

  // Citations
  show cite: it => {
    show regex("\[|\]"): it => text(fill: black)[#it]
    it
  }

  // Outline entries
  set outline(depth: 3)

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

  set figure.caption(position: top) if tufte
  show: show-if(tufte, it => {
    show figure.caption: content => margin-note({
        text(size: 0.9em, content)
      }
    )
    it
  })
  show figure: set figure.caption(separator: [ -- ])

  // Equations
  let numbering-eq = (..n) => {
    let h1 = counter(heading).get().first()
    numbering(states.num-pattern-eq.get(), h1, ..n)
  }

  set math.equation(numbering: numbering-eq)

  // Tables
  show figure.where(kind: table): set figure(
    numbering: numbering-fig,
  )

  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }

  // Lists
  set list(marker: [#text(fill:colors.primary, size: 1.75em)[#sym.bullet]])
  set enum(numbering: n => text(fill:book-colors.primary)[#n.])

  // Title page
  if title-page != none {
    title-page
  } else {
    default-title-page
  }

  // Page properties for tufte layout
  set-page-properties()
  if tufte {
    set-margin-note-defaults(
      stroke: none,
      side: right,
      margin-right: 5.5cm,
      margin-left: -1.5cm,
    )
  } else {
    set-margin-note-defaults(stroke: none)
  }

  set page(
    margin: (
      left: 1.47cm,
      right: 6.93cm
    )
  ) if tufte

  // Headings
  show: theme.with(colors: book-colors)
  show: headings-on-odd-page

  body
}
