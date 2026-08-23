#import "utils.typ": deep-merge, deep-merge-or-default
#import "frontmatter.typ": (
  zhaw-abstract-section, zhaw-acknowledgements-section, zhaw-cover-page, zhaw-declaration-section,
)
#import "styling/tokens.typ": tokens
#import "styling/math-and-code.typ": code-styles
#import "styling/glossary.typ": init-glossary, styled-glossary
#import "styling/text.typ": text-styles
#import "styling/figures.typ": figure-styles
#import "styling/table.typ": table-styles
#import "styling/page-header.typ": page-header-styles
#import "styling/page-border.typ": page-border-styles
#import "translations.typ": languages, setup-language
#import "@preview/tieflang:0.1.0": tr

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
  // Default `none` so callers may pass `biblio: none` (same as omitting: IEEE, no .bib file).
  biblio: none,
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
  let biblio = deep-merge-or-default(biblio-defaults, biblio)

  set enum(numbering: "1.i.1.i.")

  show: setup-language.with(language)
  show: doc => {
    if glossary-entries != none {
      init-glossary(glossary-entries, term-links: true, doc)
    } else {
      doc
    }
  }

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

  // context is needed for the tr() calls inside the page functions
  context {
    if (not hide-frontmatter) {
      zhaw-cover-page(cover, print-mode: print-mode)

      set page(numbering: "i")
      counter(page).update(1)

      zhaw-abstract-section(abstract, cover)
      zhaw-acknowledgements-section(acknowledgements, cover)
      zhaw-declaration-section(declaration-of-originality, cover)

      outline(title: tr().table_of_contents, depth: 3)
    }

    set page(numbering: "1")
    counter(page).update(1)

    doc

    if glossary-entries != none {
      styled-glossary
    }

    if biblio.file != none {
      bibliography(
        biblio.file,
        style: biblio.style,
      )
    }

    if appendix != none {
      set heading(numbering: none, supplement: tr().appendix)
      counter(heading).update(1)
      [
        #heading(level: 1)[#tr().appendix] <appendix>
      ]

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
