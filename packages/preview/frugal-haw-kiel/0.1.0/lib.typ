#import "./translations.typ": translations
#import "./utility.typ": some
#import "@preview/glossarium:0.5.9": gls



#let thesis(
  // Language
  language: "de",
  region: "DE",
  // German
  title-de: "",
  keywords-de: none,
  abstract-de: none,
  // English
  title-en: none,
  keywords-en: none,
  abstract-en: none,
  // Basic fields
  author: "",
  faculty: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  logo: none,
  use-declaration-of-independent-processing: false,
  abbreviations: none,
  glossary: none,
  bib: none,
  before-content: none,
  after-content: none,
  body,
) = {
  import "@preview/glossarium:0.5.9": make-glossary, register-glossary, print-glossary
  show: make-glossary
  register-glossary(abbreviations)
  register-glossary(glossary)
  show math.equation: set text(font: "DejaVu Math TeX Gyre")

  let HEADING_EXTRA_TOP_MARGIN = 45pt
  let margin = (inside: 25mm, outside: 20mm, top: 40mm, bottom: 50mm)
  let title = title-de
  let keywords = keywords-de
  let abstract = abstract-de
  if language == "en" {
    title = title-en
    keywords = keywords-en
    abstract = abstract-en
  }
  
  set document(author: author, title: title, date: submission-date, description: abstract, keywords: keywords)
  set text(font: "STIX Two Text", size: 11pt, lang: language, region: region)
  // default of 0.65 will result in about 1.2 line spacing
  // 1em will result in about 1.5 line spacing
  // default (paragraph) spacing is 1.2
  set par(leading: 1em, spacing: 1.85em)

  set page(
    margin: margin, 
    numbering: "i", 
    binding: left, 
    header: context {
      let selector_before = selector(heading.where(level: 1)).before(here())
      let cur_level = int(counter(selector_before).display())
      let headings_before = query(selector_before)
      if cur_level == 0 {
        return
      }

      // this is before the first heading was called
      if headings_before.len() == 0 {
        return
      }

      let selector_after = selector(heading.where(level: 1)).after(here())
      let headings_after = query(selector_after)

      // In order to remove the header on pages with a new heading
      // you need to look for the next heading. But this fails if there are 
      // no more heading ahead.
      // The page will be resolved before the heading is resolved, that's why
      // the last heading is still removed even though it seems like there
      // should be no more headings_after
      if headings_after.len() != 0 {
        let next_heading = headings_after.first()

        if next_heading.location().page() == here().page() {
          return
        }
      }

      // Get current heading
      let cur_heading = headings_before.last()

      // actual header with headings
      set text(size: 11.5pt)
      grid(
        rows: 2,
        gutter: 5pt,
        if some(cur_heading.numbering) {
          emph(str(cur_level) + " " + cur_heading.body)
        } else {
          emph(cur_heading.body)
        },
        line(length: 100%, stroke: 0.7pt),
      )
    },
  )
  set heading(numbering: "1.1")

  // Configure headings
  let h1_size = 21pt
  let h1_top = 25pt
  let h1_bot = 45pt

  show heading.where(level: 1): set block(above: h1_top, below: h1_bot)
  show heading.where(level: 1): set text(size: h1_size, weight: 600)
  show heading.where(level: 1): it => {
    // New page if configured
    pagebreak(weak: true)
    it
  }

  // Configure h2
  let h2_size = 14pt
  let h2_top = 40pt
  let h2_bot = 25pt

  show heading.where(level: 2): set block(above: h2_top, below: h2_bot)
  show heading.where(level: 2): set text(size: h2_size, weight: 600)

  // Configure h3
  let h3_size= 12pt
  let h3_top = 30pt
  let h3_bot = 17pt

  show heading.where(level: 3): set block(above: h3_top, below: h3_bot)
  show heading.where(level: 3): set text(size: h3_size, weight: 600)

  import "pages/cover.typ": cover_page
  cover_page(
    title: title-de,
    author: author,
    faculty: faculty,
    study-course: study-course,
    supervisors: supervisors,
    submission-date: submission-date,
    margin: margin,
    logo: logo,
  )

  // Abstract
  if some(abstract-de) or some(abstract-en) {
    import "pages/abstract.typ": abstract_page
    abstract_page(
      author: author,
      title: title,
      keywords: keywords,
      abstract: abstract,
    )
  }

  // Table of contents
  include "pages/TOC.typ"

  // List of Figures
  include "pages/list_of_figures.typ"

  // List of Tables
  include "pages/list_of_tables.typ"

  // Listings
  include "pages/list_of_code.typ"

  if some(abbreviations) {
    pagebreak(weak: true)
    heading(translations.abbreviations, numbering: none)
    print-glossary(abbreviations, disable-back-references: false)
  }
  pagebreak(weak: true)
  before-content
  // Content
  {
    // Reset page numbering and set it to numbers
    set page(
      numbering: "1",
    )
    counter(page).update(1)

    set par(justify: true)

    body

    if some(glossary) {
      pagebreak(weak: true)
      heading(translations.glossary, numbering: none)
      print-glossary(glossary)
    }

    if some(bib) {
      bib
      set bibliography(style: "ieee")
    }

    after-content
    if use-declaration-of-independent-processing {
      include "pages/declaration_of_independent_processing.typ"
    }
  }

}

