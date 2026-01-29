#import "utils.typ": deep-merge
#import "styling/tokens.typ": tokens
#import "pages/title.typ": title-page
#import "pages/abstract.typ": abstract-page
#import "pages/acknowledgements.typ": acknowledgements-page
#import "pages/originality.typ": declaration-of-originality-page
#import "styling/math-and-code.typ": code-styles
#import "styling/glossary.typ": init-glossary, styled-glossary
#import "styling/text.typ": text-styles
#import "styling/figures.typ": figure-styles
#import "styling/table.typ": table-styles
#import "styling/page-header.typ": page-header-styles
#import "styling/page-border.typ": page-border-styles
#import "translations.typ": languages, setup-language

#let zhaw-thesis(
  language: languages.de,
  cover: (
    school: none,
    institute: none,
    work-type: none,
    title: none,
    authors: none,
    supervisors: none,
    industry-partner: none,
    study-program: none,
    override: none,
  ),
  abstract: (
    keywords: none,
    en: none,
    de: none,
    override: none,
  ),
  acknowledgements: (
    text: none,
    override: none,
  ),
  declaration-of-originality: (
    location: none,
    text: none,
    override: none,
  ),
  glossary-entries: none,
  biblio: (
    file: none,
    style: "ieee",
  ),
  appendix: none,
  page-border: true,
  hide-frontmatter: false,
  print-mode: false,
  doc,
) = {
  // Apply deep-merge to nested structures with defaults
  let cover-defaults = (
    school: none,
    institute: none,
    work-type: none,
    title: none,
    authors: none,
    supervisors: none,
    co-supervisors: none,
    industry-partner: none,
    study-program: none,
    override: none,
  )
  let cover = deep-merge(cover-defaults, cover)

  let abstract-defaults = (
    keywords: none,
    en: none,
    de: none,
    override: none,
  )
  let abstract = deep-merge(abstract-defaults, abstract)

  let acknowledgements-defaults = (
    text: none,
    override: none,
  )
  let acknowledgements = deep-merge(acknowledgements-defaults, acknowledgements)

  let declaration-defaults = (
    location: none,
    text: none,
    override: none,
  )

  let declaration-of-originality = deep-merge(declaration-defaults, declaration-of-originality)

  let biblio-defaults = (
    file: none,
    style: "ieee",
  )
  let biblio = deep-merge(biblio-defaults, biblio)

  set enum(numbering: "1.i.1.i.")

  show: setup-language.with(language)
  show: init-glossary.with(glossary-entries, term-links: true)


  show outline.entry.where(
    level: 1,
  ): it => {
    set block(above: 0.5cm)
    set text(font: tokens.font-families.headers, weight: "bold")
    it
  }
  show: text-styles
  show: page-header-styles
  show: figure-styles
  show: table-styles
  show: code-styles
  show ref: set text(fill: tokens.colour.main)
  show link: set text(fill: tokens.colour.main)
  show: page-border-styles.with(page-border) // Keep after table styles!!

  // context is neeeded for the tr() calls inside the page functions
  context {
    if (not hide-frontmatter) {
      if (cover.override == none) {
        title-page(
          school: cover.school,
          institute: cover.institute,
          work_type: cover.work-type,
          title: cover.title,
          authors: cover.authors,
          supervisors: cover.supervisors,
          co-supervisors: cover.co-supervisors,
          industry-partner: cover.industry-partner,
          print-mode: print-mode,
        )
      } else {
        cover.override
      }

      set page(numbering: "i")
      counter(page).update(1)

      if (abstract.override == none) {
        if (abstract.de == none) {
          panic("ZHAW requires a German abstract even for English works.")
        }

        abstract-page(
          en: abstract.en,
          de: abstract.de,
          keywords: abstract.keywords,
          authors: cover.authors,
          title: cover.title,
        )
      } else {
        abstract.override
      }

      if (acknowledgements.override == none) {
        acknowledgements-page(
          acknowledgements: acknowledgements.text,
          supervisors: cover.supervisors,
          co-supervisors: cover.co-supervisors,
          authors: cover.authors,
        )
      } else {
        acknowledgements.override
      }

      if (declaration-of-originality.override == none) {
        declaration-of-originality-page(
          declaration_of_originality: declaration-of-originality.text,
          location: declaration-of-originality.location,
          authors: cover.authors,
        )
      } else {
        declaration-of-originality.override
      }

      outline(title: "Table of Contents", depth: 3)
    }

    set page(numbering: "1")
    counter(page).update(1)

    doc

    styled-glossary

    if biblio.file != none {
      bibliography(
        biblio.file,
        style: biblio.style,
      )
    }

    if appendix != none {
      set heading(numbering: none, supplement: [Appendix])
      counter(heading).update(1)

      [= Appendix<appendix>]

      set heading(numbering: "1.1.1")

      appendix
    }
  }
}


#import "@preview/colorful-boxes:1.4.3": *

#let callout(title, text) = colorbox(
  title: title,
  color: (
    fill: tokens.colour.lightest,
    stroke: tokens.colour.main,
    title: tokens.colour.main,
  ),
  radius: tokens.radius,
  width: auto,
  inset: 10pt,
)[
  #text
]
