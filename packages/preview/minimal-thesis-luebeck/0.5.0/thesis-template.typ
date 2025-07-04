#import "@preview/abbr:0.2.3":
#import "@preview/hydra:0.6.1": hydra
#import "utils/todo.typ": TODO
#import "utils/print-page-break.typ": print-page-break
#import "styles/acknowledgement.typ": *
#import "styles/abstract.typ": *
#import "styles/toc.typ": *
#import "styles/disclaimer.typ": *
#import "styles/titlepage.typ": *

#let thesis(
  title-english: none,
  title-german: none,
  language: "en",
  author: none,
  degree: none,
  submission-date: datetime.today(),
  institute: none,
  program: none,
  company: none,
  university: none,
  supervisor: none,
  advisor: none,
  place: none,
  top-left-img: none,
  top-right-img: none,
  slogan-img: none,
  acknowledgement-text: none,
  appendix: none,
  abstract-en: none,
  abstract-de: none,
  confidentiality-notice: none,
  abbreviations: none,
  bib-file: none,
  body-font: "Libertinus Serif",
  sans-font: "Source Sans Pro",
  dark-color: black,
  light-color: gray,
  is-print: false,
  make-list-of-figures: false,
  make-list-of-tables: false,
  body
) = {
  set document(title: title-english, author: author)

  // #############################################
  // ################# Settings ##################
  // #############################################
  set text(
    font: body-font, 
    size: 11pt, 
    lang: language
  )
  // Heading style
  show heading: set block(below: 0.85em, above: 1.75em)
  show heading: set text(font: sans-font, fill: dark-color)
  // Heading outline and numbers
  show heading.where(level: 1): set text(size: 22pt)
  show heading.where(level: 2): set text(size: 15pt)
  show heading.where(level: 3): set text(size: 13pt)
  show heading.where(level: 4): set heading(outlined: false, numbering: none)
  show heading.where(level: 5): set heading(outlined: false, numbering: none)
  show heading.where(level: 6): set heading(outlined: false, numbering: none)
  // Reference first-level headings as "chapters"
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 {
      if language == "de" {
        [Kapitel ]
      } else {
        [Chapter ]
      }
      numbering(
        el.numbering,
        ..counter(heading).at(el.location())
      )
    } else {
      it
    }
  }
  // Math
  show math.equation: set text(weight: 400)
  // Count headings and number equations
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }
  set math.equation(numbering: num =>
    numbering("(1.1)", counter(heading).get().first(), num)
  )
  // Adjust figure numbering
  set figure(numbering: num =>
    numbering("1.1", counter(heading).get().first(), num)
  )
  show figure.caption: it => {
    let pattern = "^[^:]+" + sym.space.nobreak + "[\d.]+"
    show regex(pattern): set text(weight: "bold", style: "normal")
    set align(left)
    text(it, style: "italic")
    v(.5cm)
  }
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }
  // Paragraphs
  set par(leading: 1em)
  // Figures
  show figure: set text(size: 11pt)
  // Links
  show link: underline
  // #############################################
  // ############## End of Settings ##############
  // #############################################

  // --- Title ---
  titlepage(
    top-left-img: top-left-img,
    top-right-img: top-right-img,
    title-english: title-english,
    title-german: title-german,
    degree: degree,
    institute: institute,
    program: program,
    university: university,
    company: company,
    author: author,
    supervisor: supervisor,
    advisor: advisor,
    place: place,
    submission-date: submission-date,
    slogan-img: slogan-img,
    dark-color: dark-color,
    light-color: light-color,
    sans-font: sans-font
  )
  print-page-break(print: is-print, to: "even")

  // --- Disclaimer ---
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: "i",
    number-align: center,
  )
  disclaimer(author, [
    Eidesstattliche Erklärung

    Ich erkläre hiermit an Eides statt, dass ich diese Arbeit selbständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe.
  ])
  print-page-break(print: is-print)

  // --- Confidentiality notice ---
  if confidentiality-notice != none {
    heading("Sperrvermerk", outlined: false, level: 2)
    confidentiality-notice
    print-page-break(print: is-print)
  }

  // --- Acknowledgement ---
  acknowledgement(dark-color: dark-color, acknowledgement-text)
  print-page-break(print: is-print)

  // --- Abstract ---
  v(0.5fr) // these insert fractions of vertical space
  context {
    let lang = text.lang
    if lang == "de" {
      abstract(title: "Zusammenfassung", dark-color: dark-color, abstract-de)
      v(1fr)
      abstract(title: "Abstract", dark-color: dark-color, abstract-en)
    } else {
      abstract(title: "Abstract", dark-color: dark-color, abstract-en)
      v(1fr)
      abstract(title: "Zusammenfassung", dark-color: dark-color, abstract-de)
    }
  }
  v(1fr)
  pagebreak()

  // --- Table of contents ---
  toc(body-font: body-font, sans-font: sans-font, dark-color: dark-color)
  pagebreak()

  // Turn off heading numbers and outline for now
  set heading(numbering: none, bookmarked: true, outlined: false)
  // --- List of figures ---
  if make-list-of-figures {
    context {
      let lang = text.lang
      let fig-title = ""
      if lang == "de" {
        fig-title = "Abbildungsverzeichnis"
      } else {
        fig-title = "List of Figures"
      }
      outline(
        title: text(fig-title, size: 15pt),
        target: figure.where(kind: image),
      )
    }
    pagebreak()
  }

  // --- List of tables ---
  if make-list-of-tables {
    context {
      let lang = text.lang
      let fig-title = ""
      if lang == "de" {
        fig-title = "Tabellenverzeichnis"
      } else {
        fig-title = "List of Tables"
      }
      outline(
        title: text(fig-title, size: 15pt),
        target: figure.where(kind: table),
      )
    }
    pagebreak()
  }

  // --- List of abbreviations ---
  if abbreviations != none {
    abbreviations
    pagebreak()
  }

  // --- Main body ---
  set par(justify: true, first-line-indent: 2em)
  set page(
    numbering: "1",
  )
  // start showing chapter in header
  set page(header: context {
    align(center, emph(hydra(1, skip-starting: false)))
  })
  // start at page 1 again
  counter(page).update(1)
  set heading(numbering: "1.1", bookmarked: true, outlined: true)

  body

  // --- Bibliography ---
  pagebreak()
  bib-file

  if appendix != none {
    // --- Appendix ---
    pagebreak()
    // Set numbering for mathematical equations
    let math-numbering(.., last) = "(A." + str(last) + ")"
    set math.equation(numbering: math-numbering)
    // Print the title
    counter(heading).update(0)
    set heading(numbering: "A.1.1")
    heading("Appendix")
    // Update numbering for appendix headings
    // Update figure numbering for appendix figures
    let fig-numbering(.., last) = "A." + str(last)
    set figure(numbering: fig-numbering)

    appendix
  }
}
