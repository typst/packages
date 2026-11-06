#let template(
  is-thesis: true,
  is-master-thesis: false,
  is-bachelor-thesis: true,
  is-report: false,
  // Language
  language: "en",
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
  department: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  include-declaration-of-independent-processing: false,
  before-content: none,
  after-content: none,
  body,
) = {
  let THESIS_HEADING_EXTRA_TOP_MARGIN = 70pt
  let PAGE_MARGIN_TOP = 37mm

  let title = title-de
  if language == "en" {
    title = title-en
  }

  // Set the document's basic properties.
  set document(author: author, title: title, date: submission-date)
  set page(
    margin: (left: 31.5mm, right: 31.5mm, top: PAGE_MARGIN_TOP, bottom: 56mm),
    numbering: "i",
    number-align: right,
    binding: left,
    header-ascent: 24pt,
    header: context {
      // Before
      let selector_before = selector(heading.where(level: 1)).before(here())
      let level_before = int(counter(selector_before).display())
      let headings_before = query(selector_before)

      if headings_before.len() == 0 {
        return
      }

      // After
      let selector_after = selector(heading.where(level: 1)).after(here())
      let level_after = level_before + 1
      let headings_after = query(selector_after)

      if headings_after.len() == 0 {
        return
      }

      // Get headings
      let heading_before = headings_before.last()
      let heading_after = headings_after.first()

      // Decide on heading
      let heading = heading_before
      let level = level_before

      if heading_after.location().page() == here().page() {
        if (
          heading_after.location().position().y == (THESIS_HEADING_EXTRA_TOP_MARGIN + PAGE_MARGIN_TOP)
            or heading_after.location().position().y == PAGE_MARGIN_TOP
        ) {
          // Next header is first element of page
          return
        } else {
          heading = heading_after
          level = level_after
        }
      }

      set text(size: 11.5pt)
      grid(
        rows: 2,
        gutter: 5pt,
        if heading.numbering != none {
          emph(str(level) + " " + heading.body)
        } else {
          emph(heading.body)
        },
        line(length: 100%, stroke: 0.7pt),
      )
    },
  )
  set par(leading: 9pt)
  set text(font: "New Computer Modern", lang: language, size: 10.85pt)
  set heading(
    numbering: "1.1",
  )


  // Configure headings
  let font_size = 10pt
  let top_margin = 0pt
  let bottom_margin = 0pt

  // Configure h1
  if is-thesis {
    font_size = 21pt
    top_margin = 25pt
    bottom_margin = 45pt
  } else {
    font_size = 18pt
    top_margin = 30pt
    bottom_margin = 25pt
  }

  show heading.where(level: 1): set block(above: top_margin, below: bottom_margin)
  show heading.where(level: 1): set text(size: font_size, weight: 600)
  show heading.where(level: 1): it => {
    if is-thesis {
      // New page if configured
      pagebreak(weak: true)
      v(THESIS_HEADING_EXTRA_TOP_MARGIN)
      it
    } else {
      it
    }
  }

  // Configure h2
  if is-thesis {
    font_size = 14pt
    top_margin = 30pt
    bottom_margin = 25pt
  } else {
    font_size = 13pt
    top_margin = 30pt
    bottom_margin = 25pt
  }

  show heading.where(level: 2): set block(above: top_margin, below: bottom_margin)
  show heading.where(level: 2): set text(size: font_size)

  // Configure h3
  if is-thesis {
    font_size = 11pt
    top_margin = 20pt
    bottom_margin = 15pt
  } else {
    font_size = 11pt
    top_margin = 20pt
    bottom_margin = 15pt
  }

  show heading.where(level: 3): set block(above: top_margin, below: bottom_margin)
  show heading.where(level: 3): set text(size: font_size)

  // Cover
  import "pages/cover.typ": cover_page
  cover_page(
    is-thesis: is-thesis,
    is-master-thesis: is-master-thesis,
    is-bachelor-thesis: is-bachelor-thesis,
    is-report: is-report,

    title: title,
    author: author,
    faculty: faculty,
    department: department,
    study-course: study-course,
    supervisors: supervisors,
    submission-date: submission-date,
  )

  // Abstract
  if abstract-de != none or abstract-en != none {
    import "pages/abstract.typ": abstract_page
    if (language == "en") {
      abstract_page(
        language: "en",
        author: author,
        title: title-en,
        keywords: keywords-en,
        abstract: abstract-en,
      )
    }
    abstract_page(
      language: "de",
      author: author,
      title: title-de,
      keywords: keywords-de,
      abstract: abstract-de,
    )
  }

  // Table of contents.
  include "pages/outline.typ"

  // List of Figures
  if is-thesis {
    include "pages/list_of_figures.typ"
  }

  // List of Tables
  if is-thesis {
    include "pages/list_of_tables.typ"
  }

  // Listings
  if is-thesis {
    include "pages/listings.typ"
  }

  // Include before-content pages
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

    // Include after-content pages
    after-content
  }
}
