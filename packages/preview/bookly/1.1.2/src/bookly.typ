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
  lang: "en",
  fonts: default-fonts,
  colors: default-colors,
  title-page: default-title-page,
  config-options: default-config-options,
  body
) = context {
  // Document's properties
  set document(author: author, title: title)
  states.author.update(author)
  states.title.update(title)
  states.tufte.update(tufte)

  // Book colors
  let book-colors = default-colors + colors
  states.colors.update(book-colors)

  // Configuration options
  let book-options = default-config-options + config-options
  states.part-numbering.update(book-options.part-numbering)

  // Fonts
  set text(font: fonts.body, lang: lang, size: text-size, ligatures: false)

  // Math font
  show math.equation: set text(font: fonts.math, stylistic-set: 1)
  // Unnumbered equations
  show selector(<nonum-eq>): set math.equation(numbering: none)

  // Equations
  show: equate.with(breakable: true, sub-numbering: true)

  // Paragraphs
  set par(justify: true)

  // Localization
  let bookly-lang = if default-language.contains(lang) {
    lang
  } else {
    "en"
  }
  states.localization.update(json("resources/i18n/" + bookly-lang + ".json"))


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
  // Unnumbered sections - Thanks to @bluss (Typst universe: How to have headings without numbers in a fluent way?)
  show selector(<nonum-sec>): set heading(numbering: none)

  body
}
