// ============================================================================
// ClassicThesis Style for Typst
// An Homage to The Elements of Typographic Style
//
// Inspired by André Miede's ClassicThesis LaTeX template
// https://ctan.org/pkg/classicthesis
//
// Copyright (c) 2025 Adwiteey Mauriya
// Licensed under MIT License
// ============================================================================

// ----------------------------------------------------------------------------
// Colors (matching ClassicThesis)
// ----------------------------------------------------------------------------

/// Semi-transparent gray for chapter numbers
#let halfgray = luma(140)

/// Maroon for part titles
#let maroon = rgb("#800000")

/// Royal blue for links
#let royalblue = rgb("#4169E1")

/// Green for citations
#let webgreen = rgb("#008000")

/// Brown for URLs
#let webbrown = rgb("#996600")

// ----------------------------------------------------------------------------
// Font Configuration
// ----------------------------------------------------------------------------

#let ct-fonts = (
  // TeX Gyre Pagella is a Palatino clone - the authentic ClassicThesis look
  // Falls back to other serif fonts if not available
  main: ("TeX Gyre Pagella", "Libertinus Serif", "EB Garamond 12", "New Computer Modern"),
  mono: ("Fira Code", "JetBrains Mono", "DejaVu Sans Mono"),
)

// ----------------------------------------------------------------------------
// Spaced Small Caps (key ClassicThesis feature)
// ----------------------------------------------------------------------------

/// Apply letter-spaced small caps to content
#let spaced-smallcaps(content) = {
  text(tracking: 0.1em, smallcaps(content))
}

/// Apply letter-spaced all caps to content
#let spaced-allcaps(content) = {
  text(tracking: 0.15em, upper(content))
}

// ----------------------------------------------------------------------------
// Margin Notes (Graffito)
// ----------------------------------------------------------------------------

/// Add a side note in the margin
#let sidenote(content) = {
  place(
    right,
    dx: 1.5em,
    float: false,
    text(
      size: 0.85em,
      style: "italic",
      fill: luma(80),
      content
    )
  )
}

// ----------------------------------------------------------------------------
// Theorem Environments
// ----------------------------------------------------------------------------

#let _theorem-counter = counter("classicthesis-theorem")
#let _definition-counter = counter("classicthesis-definition")
#let _example-counter = counter("classicthesis-example")

/// A theorem block with automatic numbering
/// - title (content): Optional title for the theorem
/// - body (content): The theorem content
#let theorem(title: none, body) = {
  _theorem-counter.step()
  block(
    width: 100%,
    inset: (left: 1em, top: 0.5em, bottom: 0.5em),
    stroke: (left: 2pt + halfgray),
  )[
    #text(weight: "bold")[Theorem #context _theorem-counter.display()]
    #if title != none [ (#title)]
    #text[.] #body
  ]
}

/// A definition block with automatic numbering
/// - title (content): Optional title for the definition
/// - body (content): The definition content
#let definition(title: none, body) = {
  _definition-counter.step()
  block(
    width: 100%,
    inset: (left: 1em, top: 0.5em, bottom: 0.5em),
    stroke: (left: 2pt + maroon),
  )[
    #text(weight: "bold")[Definition #context _definition-counter.display()]
    #if title != none [ (#title)]
    #text[.] #body
  ]
}

/// An example block with automatic numbering
/// - title (content): Optional title for the example
/// - body (content): The example content
#let example(title: none, body) = {
  _example-counter.step()
  block(
    width: 100%,
    inset: (left: 1em, top: 0.5em, bottom: 0.5em),
    fill: luma(245),
  )[
    #text(style: "italic")[Example #context _example-counter.display()]
    #if title != none [ — #title]
    #text[.] #body
  ]
}

/// A remark block (unnumbered)
/// - body (content): The remark content
#let remark(body) = {
  block(
    width: 100%,
    inset: (left: 1em, top: 0.5em, bottom: 0.5em),
    stroke: (left: 2pt + webgreen),
  )[
    #text(style: "italic")[Remark.] #body
  ]
}

/// A note block with border
/// - body (content): The note content
#let note(body) = {
  block(
    width: 100%,
    inset: 1em,
    stroke: 0.5pt + halfgray,
    radius: 2pt,
  )[
    #text(weight: "bold")[Note:] #body
  ]
}

// ----------------------------------------------------------------------------
// Part Page
// ----------------------------------------------------------------------------

/// Create a part divider page
/// - title (string): The part title
/// - preamble (content): Optional descriptive text for the part
#let part(title, preamble: none) = {
  pagebreak(weak: true, to: "odd")
  [
    #set page(header: none, footer: none)
    #v(1fr)
    #align(center)[
      #text(size: 1.1em, tracking: 0.1em)[PART]
      #v(0.5em)
      #text(size: 2.2em, fill: maroon, tracking: 0.12em, smallcaps(title))
      #if preamble != none {
        v(2em)
        block(width: 75%)[
          #set par(justify: true)
          #text(size: 0.95em, preamble)
        ]
      }
    ]
    #v(1fr)
  ]
  pagebreak(weak: true)
}

// ----------------------------------------------------------------------------
// Main Template Function
// ----------------------------------------------------------------------------

/// Apply the ClassicThesis style to a document
///
/// - title (string): The document title
/// - subtitle (string): Optional subtitle
/// - author (string): Author name
/// - date (string): Publication date
/// - paper (string): Paper size (default: "a4")
/// - lang (string): Document language (default: "en")
/// - dedication (content): Optional dedication page content
/// - abstract (content): Optional abstract content
/// - body (content): The document body
#let classicthesis(
  title: "Book Title",
  subtitle: none,
  author: "Author Name",
  date: datetime.today().display("[year]"),
  paper: "a4",
  lang: "en",
  dedication: none,
  abstract: none,
  body
) = {
  // Document metadata
  set document(title: title, author: author)

  // Page setup
  set page(
    paper: paper,
    margin: (
      inside: 3.5cm,
      outside: 2.5cm,
      top: 2.5cm,
      bottom: 3cm,
    ),
    header: context {
      if counter(page).get().first() > 4 {
        let chapters = query(selector(heading.where(level: 1)).before(here()))
        if chapters.len() > 0 {
          let title-text = chapters.last().body
          set text(size: 0.9em)
          if calc.odd(counter(page).get().first()) {
            h(1fr)
            spaced-smallcaps(title-text)
            h(2em)
            counter(page).display()
          } else {
            counter(page).display()
            h(2em)
            spaced-smallcaps(title-text)
            h(1fr)
          }
        }
      }
    },
    footer: none,
  )

  // Typography
  set text(
    font: ct-fonts.main,
    size: 11pt,
    lang: lang,
  )

  // Paragraph settings
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1.5em,
  )

  // No indent after headings
  show heading: it => {
    it
    par(text(size: 0pt, ""))
  }

  // Chapter headings (level 1)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(3em)
    block[
      #text(
        size: 1.6em,
        tracking: 0.1em,
        smallcaps(it.body)
      )
    ]
    v(0.8em)
    line(length: 100%, stroke: 0.5pt + black)
    v(1.5em)
  }

  // Section headings (level 2)
  show heading.where(level: 2): it => {
    v(1.5em)
    block[#text(tracking: 0.08em, smallcaps(it.body))]
    v(1em)
  }

  // Subsection headings (level 3)
  show heading.where(level: 3): it => {
    v(1.25em)
    block[#text(style: "italic", it.body)]
    v(0.75em)
  }

  // Paragraph headings (level 4)
  show heading.where(level: 4): it => {
    v(1em)
    text(style: "italic", it.body)
    h(0.5em)
  }

  // Link styling
  show link: it => text(fill: royalblue, it)

  // Inline code
  show raw.where(block: false): it => {
    box(
      fill: luma(245),
      inset: (x: 0.3em),
      radius: 2pt,
      text(font: ct-fonts.mono, size: 0.9em, it)
    )
  }

  // Code blocks
  show raw.where(block: true): it => {
    block(
      width: 100%,
      fill: luma(248),
      inset: 1em,
      radius: 2pt,
      text(font: ct-fonts.mono, size: 0.85em, it)
    )
  }

  // Figure captions
  show figure.caption: it => {
    text(size: 0.9em)[
      #text(weight: "regular")[#it.supplement #it.counter.display()]
      #it.separator
      #it.body
    ]
  }

  // Table styling
  set table(stroke: none, inset: 0.7em)
  show table: set text(size: 0.95em)

  // Footnotes
  set footnote.entry(
    separator: line(length: 30%, stroke: 0.5pt),
    indent: 0em,
  )

  // =========================================================================
  // Front Matter
  // =========================================================================

  // Title Page
  page(
    margin: (x: 2.5cm, y: 2.5cm),
    header: none,
    footer: none,
  )[
    #v(1fr)
    #align(center)[
      #text(size: 2.5em, tracking: 0.15em, upper(title))
      #if subtitle != none {
        v(1em)
        text(size: 1.3em, style: "italic", subtitle)
      }
      #v(3em)
      #text(size: 1.2em, spaced-smallcaps(author))
      #v(2em)
      #text(size: 1em, date)
    ]
    #v(1fr)
  ]

  // Back of title page (blank)
  pagebreak()
  page(header: none, footer: none)[]

  // Dedication (if provided)
  if dedication != none {
    page(header: none, footer: none)[
      #v(1fr)
      #align(right)[
        #text(style: "italic", dedication)
      ]
      #v(1fr)
    ]
    pagebreak()
  }

  // Abstract (if provided)
  if abstract != none {
    page(header: none)[
      #heading(outlined: false, numbering: none)[Abstract]
      #v(1em)
      #abstract
    ]
    pagebreak()
  }

  // Table of Contents
  page(header: none)[
    #heading(outlined: false, numbering: none)[Contents]
    #v(1em)
    #outline(title: none, indent: 1.5em)
  ]
  pagebreak()

  // =========================================================================
  // Main Content
  // =========================================================================
  counter(page).update(1)
  body
}
