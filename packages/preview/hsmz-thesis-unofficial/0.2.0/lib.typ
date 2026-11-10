// External package imports
#import "@preview/acrostiche:0.7.0": acr, acrf, acrfpl, acrpl, init-acronyms, print-index // Acronyms - https://typst.app/universe/package/acrostiche/

// static pages, locale and helper functions
#import "static-pages.typ": declaration-of-originality, restriction-notice, title-page
#import "locale.typ": LIST_OF_ABBREVIATIONS, LIST_OF_APPENDICES, LIST_OF_FIGURES, LIST_OF_TABLES
#import "check-attributes.typ": *

// outlined outline for figures, tables, etc. that itself is outlined in the table of contents
#let outlined-outline(..args) = {
  show outline: set heading(outlined: true)
  outline(..args)
}

// workaround for the lack of a std scope so that we can pass a bibliography object around from the template to here
#let std-bibliography = bibliography

// main entrypoint for this template
#let hsmz-thesis-unofficial(
  // thesis data
  thesis-type: none,
  title: none,
  faculty: none,
  degree-program: none,
  submission-date: none,
  confidentiality-period: none,
  ai-declaration-option: none,
  language: none,
  acronyms: none,
  bibliography: none,
  appendix: none,
  // people
  author: (:),
  company: none,
  supervisor: none,
  // settings
  font: "Calibri",
  citation-style: "apa",
  print-only-used-acronyms: true,
  show-full-bibliography: false,
  show-restriction-notice: true,
  body,
) = {
  check-attributes(
    thesis-type,
    title,
    faculty,
    degree-program,
    submission-date,
    confidentiality-period,
    ai-declaration-option,
    language,
    acronyms,
    bibliography,
    appendix,
    author,
    company,
    supervisor,
    font,
    citation-style,
    print-only-used-acronyms,
    show-full-bibliography,
    show-restriction-notice,
  )

  // global page and text settings
  set text(
    font: font,
    size: 11pt,
    lang: language,
  )
  set document(
    title: title,
    author: author.name,
  )
  set page(
    paper: "a4",
  )
  set par(
    leading: 1.5em,
    spacing: 2em,
    justify: true,
  )

  // pre-text
  if show-restriction-notice {
    restriction-notice(title, company, confidentiality-period)
  }

  title-page(
    thesis-type,
    title,
    faculty,
    degree-program,
    submission-date,
    supervisor,
    author,
    language,
  )

  declaration-of-originality(
    ai-declaration-option,
    author,
    title,
    degree-program,
    supervisor,
    submission-date,
  )

  // reset heading and page numbers for listings
  counter(heading).update(0)
  counter(page).update(0)

  // adjust page numbering and headings for the listings
  set page(
    numbering: "I",
  )
  set heading(
    numbering: none,
  )

  // page settings for the listings and content
  set page(
    margin: (top: 2cm, bottom: 2cm, left: 4.5cm, right: 1.5cm),
  )

  // Styling of individual elements
  // Margin for headings to make them more visually pleasing
  show heading.where(level: 1): set block(below: 1em)
  show heading.where(level: 2): set block(above: 1.5em, below: 1.5em)
  show heading.where(level: 3): set block(above: 1.5em, below: 1.5em)

  show table: set par(
    leading: 0.8em,
    justify: true,
  )
  set table(stroke: 0.5pt, align: left)
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    fill: (_, y) => if y == 0 { rgb("#e7e6e6") },
  )

  // listings
  outline()
  pagebreak()

  outlined-outline(
    title: [#LIST_OF_FIGURES.at(language)],
    target: figure.where(kind: image),
  )
  pagebreak()

  outlined-outline(
    title: [#LIST_OF_TABLES.at(language)],
    target: figure.where(kind: table),
  )
  pagebreak()

  init-acronyms(
    acronyms,
  )
  [
    #print-index(
      title: [#LIST_OF_ABBREVIATIONS.at(language)],
      outlined: true,
      used-only: print-only-used-acronyms,
      sorted: "up",
      row-gutter: 10pt,
    )  <list-of-abbreviations> // set label for page number retrieval later
  ]

  pagebreak()

  // reset counters and switch to numeric numbering for the content
  counter(heading).update(0)
  counter(page).update(1)
  set heading(
    numbering: "1.1",
  )
  set page(
    numbering: "1",
  )

  // content
  body

  // post-text

  // update counters and switch back to character numbering
  set heading(
    numbering: none,
  )

  set page(
    numbering: "I",
  )
  // retrieve last page before the content started from labels using context
  context [
    #counter(page).update(counter(page).at(<list-of-abbreviations>).first() + 1)
    #counter(heading).update(counter(heading).at(<list-of-abbreviations>).first() + 1)
  ]

  set std-bibliography(
    style: citation-style,
    full: show-full-bibliography,
  )
  bibliography

  // If appendix is provided, show it here
  if appendix != none {
    pagebreak()

    outlined-outline(
      title: [#LIST_OF_APPENDICES.at(language)],
      target: heading.where(supplement: [Appendix]),
    )

    pagebreak()

    set heading(numbering: "A", supplement: [Appendix])
    counter(heading).update(0)

    appendix
  }
}
