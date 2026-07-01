#import "@preview/zero:0.5.0": set-num
#import "@preview/swank-tex:0.1.0": *
#import "@preview/icu-datetime:0.2.0": fmt
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *


// Utility for formatting units in math
#let un(body) = $thin upright(body)$


// Appendix
// Thanks to the elsearticle template for the appendix implementation from which this is derived
#let appendix(supplement, body) = {
  set heading(numbering: "A.1.", supplement: supplement)
  // Reset heading counter
  counter(heading).update(0)

  // Equation numbering
  let numbering-eq = (..n) => {
    let h1 = counter(heading).get().first()
    numbering("(A.1a)", h1, ..n)
  }
  set math.equation(numbering: numbering-eq)

  // Figure, Table and Listing numbering
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("A.1", h1, n)
  }
  show figure.where(kind: image): set figure(numbering: numbering-fig)
  show figure.where(kind: table): set figure(numbering: numbering-fig)
  show figure.where(kind: raw): set figure(numbering: numbering-fig)

  body
}


// Utility function for printing out authors
#let write-authors(
  authors) = {
  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(
      columns: slice.len() * (1fr,),
      gutter: 12pt,
      ..slice.map(author => align(center, {
        text(size: 11pt, author.name)
        if "department" in author [
          \ #emph(author.department)
        ]
        if "organization" in author [
          \ #emph(author.organization)
        ]
        if "location" in author [
          \ #author.location
        ]
        if "email" in author {
          if type(author.email) == str [
            \ #link("mailto:" + author.email)
          ] else [
            \ #author.email
          ]
        }
      }))
    )
    if not is-last {
      v(16pt, weak: true)
    }
  }
}


// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
#let ntnu-report(
    length: "short", // One of: short, long
    watermark: none, // Any string, such as "DRAFT"
    title: none, // Required
    subtitle: none, // Optional
    authors: (), // Requires: name. Optional: department, organization, location, email
    group: none, // Optional, for use in subjects divied into groups
    front-image: none, // Image content for front page, only works if length is long
    date: datetime.today(), // Required, all reports should have a date
    abstract: none, // Optional content for abstract
    appendices: none, // Optional content for appendices
    bibfile: none, // Optional bibliography content, highly recommended
    bibstyle: "institute-of-electrical-and-electronics-engineers", // For example "american-psychological-association" or "institute-of-electrical-and-electronics-engineers"
    language: "bokmål", // One of: english, bokmål, nynorsk
    column-number: 1, // Should be 1 or 2
    number-headings: true, // Determines if headings are numbered
    show-toc: true, // Determines if table of content is printed, only relevant for long reports
    show-figure-index: false, // Determines if list of figures is printed, only relevant for long reports
    show-table-index: false, // Determines if list of indices is printed, only relevant for long reports
    show-listings-index: false, // Determines if list of listings is printed, only relevant for long reports
    body) = {


  // Basic sanity checks
  assert(title != none, message: "\"title\" is an obligatory field for this template.")
  assert(length in ("short", "long"), message: "Report length " + length + " is not implemented.")
  
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title, date: date)
  set text(font: "New Computer Modern", size: 11pt)

  
  // Formatting
  set enum(numbering: "1)a)i)")
  
  set math.equation(numbering: "(1)")
  show math.equation: set text(weight: 400)
  set math.mat(delim: "[")
  set math.vec(delim: "[")
  
  let heading-numbering = "1.1"
  if not number-headings { heading-numbering = none }
  set heading(numbering: heading-numbering)
  show selector(<nonumber>): set heading(numbering: none)
  show selector(<nonumber>): set math.equation(numbering: none)

  set bibliography(style: bibstyle)


  // Watermark
  set page(foreground: rotate(315deg, text(80pt, fill: rgb("FF000060"))[*#watermark*])) if watermark != none

  
  // Quality of life defaults
  show "LaTeX": LaTeX

  
  // Tables & figures
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set align(start)
  show figure.caption.where(kind: table): set align(center)


  // Listings
  show: codly-init.with()
  codly(languages: codly-languages)

  
  // Set language
  set text(lang: "en") if language == "english"
  set text(lang: "no") if language in ("bokmål", "nynorsk")
  
  let date-text
  let abstract-heading
  let heading-supplement
  let appendix-supplement
  let group-prefix
  let decimal-separator
  let bib-title
  let toc-title
  let lot-title
  let lof-title
  let lol-title
  let figure-supplement
  let table-supplement
  let listings-supplement
  if language == "english" {
    date-text = fmt(date, locale: "en", length: "long")
    abstract-heading = "Abstract"
    heading-supplement = "Section"
    appendix-supplement = "Appendix"
    group-prefix = "Group"
    decimal-separator = "."
    bib-title = "References"
    toc-title = "Contents"
    lot-title = "List of Tables"
    lof-title = "List of Figures"
    lol-title = "List of Listings"
    figure-supplement = "Figure"
    table-supplement = "Table"
    listings-supplement = "Listing"
  } else if language == "bokmål" {
    date-text = fmt(date, locale: "no", length: "long")
    abstract-heading = "Sammendrag"
    heading-supplement = "Avsnitt"
    appendix-supplement = "Appendiks"
    group-prefix = "Gruppe"
    decimal-separator = ","
    bib-title = "Kilder"
    toc-title = "Innholdsfortegnelse"
    lot-title = "Tabelliste"
    lof-title = "Figurliste"
    lol-title = "Kodeliste"
    figure-supplement = "Figur"
    table-supplement = "Tabell"
    listings-supplement = "Kodeblokk"
  } else if language == "nynorsk" {
    date-text = fmt(date, locale: "no", length: "long")
    abstract-heading = "Samandrag"
    heading-supplement = "Avsnitt"
    appendix-supplement = "Appendiks"
    group-prefix = "Gruppe"
    decimal-separator = ","
    bib-title = "Kilder"
    toc-title = "Innhaldsliste"
    lot-title = "Tabelliste"
    lof-title = "Figurliste"
    lol-title = "Kodeliste"
    figure-supplement = "Figur"
    table-supplement = "Tabell"
    listings-supplement = "Kodeblokk"
  } else { assert(false, message: "Language " + language + " is not supported by this template.") }
  
  set-num(decimal-separator: decimal-separator)
  set bibliography(title: bib-title)
  show figure.where(kind: image): set figure(supplement: figure-supplement)
  show figure.where(kind: table): set figure(supplement: table-supplement)
  show figure.where(kind: raw): set figure(supplement: listings-supplement)

  set heading(supplement: heading-supplement)
  

  // DOCUMENT CONTENT //
  
  

  // Display document
  // Long report
  if length == "long"{
    v(2cm)
    align(center)[
      #text(weight: 700, 1.75em, title)
      #if subtitle != none {text(weight: 600, 1.25em, linebreak() + subtitle)}
      #if group != none {
        if length == "long" {v(0.8cm)}
        [*#group-prefix #group*]
      }
    ]
  
    v(0.8cm, weak: true)
  
    write-authors(authors)
  
    v(0.8cm, weak: true)
    align(center)[*#date-text*]
  
    v(1fr)
    align(center, front-image)
    

    v(1fr)
    if abstract != none {
      set text(9pt, weight: 700)
      align(center)[= _#{abstract-heading}_ <nonumber>]
      abstract
    }

    set page(numbering: "I", number-align: center)
    counter(page).update(1)
    if show-toc {
      outline(title: toc-title)
      pagebreak()
    }
    if show-figure-index {
      outline(title: lof-title, target: figure.where(kind: image))
      pagebreak()
    }
    if show-table-index {
      outline(title: lot-title, target: figure.where(kind: table))
      pagebreak()
    }
    if show-listings-index {
      outline(title: lol-title, target: figure.where(kind: raw))
      pagebreak()
    }
    

    set page(numbering: "1", number-align: center)
    counter(page).update(1)
    
    set par(justify: true)
    set page(columns: column-number)

    body

    if bibfile != none {
      set page(columns: 1)
      bibfile
    }

    pagebreak()
    if appendices != none { show: appendix(appendix-supplement, appendices) }
    
  }
  // Short report
  else if length == "short"{
    set page(numbering: "1", number-align: center)
    set page(columns: column-number)

    place(top + center, scope: "parent", float: true, {
      v(0.8cm, weak: true)
  
      // Title row.
      if length == "long" {v(2cm)}
      text(weight: 700, 1.75em, title)
      if subtitle != none {text(weight: 600, 1.25em, linebreak() + subtitle)}
      if group != none {
        v(0.75cm)
        [*#group-prefix #group*]
      }
    
      v(0.8cm, weak: true)
    
      // Author information.set page(numbering: "1", number-align: center)
      write-authors(authors)
    
      v(0.8cm, weak: true)
      align(center)[*#date-text*]
    })
    
    set par(justify: true)
    
    if abstract != none {
      if column-number == 1 {line(length: 100%)}
      set text(9pt, weight: 700)
      [= #h(1em) _#{abstract-heading}_ <nonumber>]
      abstract
      if column-number == 1 {line(length: 100%)}
    }

    body

    if bibfile != none {
      bibfile
    }

    if appendices != none { show: appendix(appendix-supplement, appendices) }

  }
}
