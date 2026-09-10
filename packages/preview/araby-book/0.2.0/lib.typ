// araby-book v0.2.0
// Copyright (c) 2026 Abdelaziz Islam Galal
// Licensed under the BSD 3-Clause License. See LICENSE for details.

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Convert Western Arabic digits (0-9) to Eastern Arabic digits (٠-٩)
/// Example: arabic-digits(123) → "١٢٣"
#let arabic-digits(n) = {
  let d = "٠١٢٣٤٥٦٧٨٩".clusters()
  str(n).clusters().map(c => d.at(int(c), default: c)).join()
}


/// Traditional Arabic poetry couplet (صدر وعجز)
/// - `first`  : first hemistich (right-aligned)
/// - `second` : second hemistich (left-aligned)
#let poetry(first, second) = {
  v(0.4em)
  grid(
    columns: (1fr, 2em, 1fr),
    align: (right + horizon, center + horizon, left + horizon),
    first, text(fill: gray.darken(20%), size: 0.8em)[❊❊❊], second,
  )
  v(0.4em)
}

/// Quranic / decorative verse callout (block)
/// - `body` : verse text
/// - `ref`  : optional reference (e.g., "البقرة")
/// - `color`: text color (default deep red)
#let verse(body, ref: none, color: rgb("#8b0000")) = {
  v(1em)
  align(center)[
    #block(
      width: 100%,
      breakable: false,
    )[
      #text(fill: color, weight: "medium", size: 1.05em)[﴿ #body ﴾]
      #if ref != none [
        #v(-0.2em)
        #align(left)[#text(size: 0.75em, fill: gray.darken(40%))[-- #ref]]
      ]
    ]
  ]
}

/// Inline verse (appears within a paragraph)
/// - `body` : verse text
/// - `ref`  : optional reference (e.g., "البقرة")
/// - `color`: text color (default deep red)
#let inline-verse(body, ref: none, color: rgb("#8b0000")) = {
  text(fill: color, weight: "medium", size: 0.95em)[﴿ #body ﴾]
  if ref != none [
    #text(size: 0.7em, fill: gray.darken(40%))[-- #ref --]
  ]
}

/// Inline quotation with optional footnote
/// - `body` : quotation text
/// - `ref`  : optional reference (e.g., "البقرة")
/// - `footnote_entry` : optional footnote entry
#let inline-quotation(body, ref: none, footnote_entry: none) = {
  text(style: "italic", weight: "medium", size: 0.95em)[« #body »]
  if footnote_entry != none [
    #footnote()[#footnote_entry]
  ]
  if ref != none [
    #text(size: 0.7em, fill: gray.darken(40%))[-- #ref --]
  ]
}

// ============================================================================
// Main template
// ============================================================================

/// The main book template.
///
/// Parameters:
/// - title            : Book title (required)
/// - subtitle         : Optional subtitle
/// - author           : Author name
/// - publisher        : Publisher name (displayed on title page)
/// - edition          : Edition string (e.g., "الطبعة الثالثة")
/// - date             : Publication date
/// - paper            : Paper size (e.g., "a5", "b5", "letter")
/// - font             : Font or list of fonts (Arabic-friendly)
/// - font-size        : Base font size
/// - primary-color    : Main color for headings and titles
/// - footnote-color   : Color for footnote numbers and markers
/// - eastern-digits   : Use Eastern Arabic digits for page numbers & footnotes
/// - dedication       : Dedication text (optional)
/// - show-toc         : Include table of contents
/// - toc-title        : Title for the table of contents
/// - chapter-label    : Word used before chapter numbers (e.g., "فصل")
/// - copyright        : Copyright notice (printed on verso of title page)
/// - verse-color      : Default color for verse callouts
/// - footnote-size    : Font size for footnote text (relative to base)
/// - header-separator : Stroke for header line
/// - body             : Content of the book
#let book(
  title: "",
  subtitle: none,
  author: "",
  publisher: none,
  edition: none,
  date: none,
  paper: "a5",
  font: ("Amiri", "Noto Naskh Arabic"),
  font-size: 11pt,
  primary-color: rgb("#000000"),
  footnote-color: rgb("#8b0000"), // Custom color for footnote numbers (e.g., deep red)
  eastern-digits: true,
  dedication: none,
  show-toc: true,
  toc-title: "الفهرس",
  chapter-label: "فصل",
  copyright: none,
  verse-color: rgb("#8b0000"),
  footnote-size: 0.85em,
  header-separator: 0.3pt + gray.lighten(50%),
  body,
) = {
  // Metadata
  set document(title: title, author: author)

  // Numbering format selector
  let num-fmt = if eastern-digits {
    (..nums) => arabic-digits(nums.pos().first())
  } else {
    (..nums) => str(nums.pos().first())
  }

  // Page Setup
  set page(
    paper: paper,
    margin: (inside: 2.2cm, outside: 1.6cm, top: 2.4cm, bottom: 2.2cm),
    numbering: num-fmt,
    number-align: center,
    header: context {
      // reset footnote counter per page
      counter(footnote).update(0)

      let page-num = counter(page).get().first()
      // Suppress header on page 1 (title page)
      if page-num == 1 { return }

      // Locate current chapter
      let headings = query(selector(heading.where(level: 1)))
      let current-heading = headings.filter(h => h.location().page() <= page-num).at(-1, default: none)

      // Suppress header on chapter start pages
      if current-heading != none and current-heading.location().page() == page-num {
        return
      }

      if current-heading != none {
        let h-text = current-heading.body
        // RTL: binding is on the right, so odd pages (recto) have outer margin on left,
        // even pages (verso) have outer margin on right.
        if calc.even(page-num) {
          // Even (left page) → align towards the right (outer)
          align(right)[#text(size: 8.5pt, fill: gray.darken(30%))[#h-text]]
        } else {
          // Odd (right page) → align towards the left (outer)
          align(left)[#text(size: 8.5pt, fill: gray.darken(30%))[#title]]
        }
        v(-0.4em)
        line(length: 100%, stroke: header-separator)
      }
    },
  )

  // Global Typography Setup
  set text(
    font: font,
    lang: "ar",
    region: "SA",
    dir: rtl,
    size: font-size,
  )
  set par(justify: true, first-line-indent: 1.4em, leading: 1.25em)

  // Arabic punctuation
  show ",": "،"
  show ";": "؛"
  show "\"": "\""

  // Custom footnote styling and coloring
  show footnote: it => {
    // Color the footnote number in the text (increased size for visibility)
    text(fill: footnote-color, size: 1em)[#super("(")#it#super(")")]
  }
  set footnote(numbering: num-fmt)

  set footnote.entry(
    // Separator line above footnotes
    separator: line(length: 70%, stroke: 0.4pt),
  )
  show footnote.entry: it => {
    // Custom footnote entry styling
    let loc = it.note.location()
    let num = counter(footnote).display(at: loc, "1")
    text([(#num-fmt(num)) ], fill: footnote-color, size: 0.7em)
    text(fill: gray.darken(30%), size: footnote-size)[#it.note.body]
  }

  // Level 1 heading (chapter) styling
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5cm)
    align(center)[
      #text(size: 9pt, tracking: 2.5pt, fill: primary-color)[* #chapter-label *]
      #v(0.2cm)
      #line(length: 25%, stroke: 0.5pt + primary-color)
      #v(0.4cm)
      #text(size: 20pt, weight: "bold", fill: primary-color)[#it.body]
    ]
    v(1.2cm)
  }

  // Level 2 heading (sections) styling
  show heading.where(level: 2): it => {
    v(1em)
    text(size: 13pt, weight: "extrabold", fill: primary-color)[#it.body]
    v(0.5em)
  }

  // numbering rule for level 3 and 4 only
  set heading(numbering: (..nums) => {
    let pos = nums.pos()

    if pos.len() == 3 {
      // Level 3: display Level 3 count only
      let l3 = numbering(num-fmt, pos.at(2))
      [#l3]
    } else if pos.len() == 4 {
      // Level 4: format Level 3 and Level 4 separately and combine
      let l3 = num-fmt(pos.at(2))
      let l4 = num-fmt(pos.at(3))
      [#l3.#l4]
    }
  })

  // Level 3 heading (subsections) styling
  show heading.where(level: 3): it => {
    v(0.8em)
    text(size: 11pt, weight: "bold", fill: primary-color)[
      #counter(heading).display() #it.body
    ]
    v(0.4em)
  }

  // Level 4 heading (sub-subsections) styling
  show heading.where(level: 4): it => {
    v(0.6em)
    text(size: 10pt, style: "italic", fill: primary-color)[
      #counter(heading).display() #it.body
    ]
    v(0.3em)
  }

  // Cover / Title Page
  align(center + horizon)[
    #v(1cm)
    #text(size: 24pt, weight: "bold", fill: primary-color)[#title]
    #if subtitle != none [
      #v(0.4cm)
      #text(size: 13pt, style: "italic", fill: gray.darken(40%))[#subtitle]
    ]
    #v(0.8cm)
    #line(length: 20%, stroke: 0.6pt + primary-color)
    #v(2.5cm)
    #text(size: 12pt, weight: "medium")[#author]
    #if publisher != none or edition != none or date != none [
      #v(0.4cm)
      #text(size: 9.5pt, fill: gray.darken(30%))[
        #if publisher != none [#publisher]
        #if publisher != none and (edition != none or date != none) [ -- ]
        #if edition != none [#edition]
        #if edition != none and date != none [ -- ]
        #if date != none [#date]
      ]
    ]
  ]

  pagebreak()

  // Copyright page (verso)
  if copyright != none {
    align(bottom)[
      #set par(first-line-indent: 0em, justify: true)
      #text(size: 8.5pt, fill: gray.darken(40%))[#copyright]
    ]
    pagebreak()
  }

  // Dedication Page
  if dedication != none {
    align(center + horizon)[
      #set par(leading: 1em)
      #text(size: 11pt, style: "italic")[#dedication]
    ]
    pagebreak()
  }

  // Table of Contents
  if show-toc {
    show outline.entry.where(level: 1): it => {
      v(0.4em)
      text(weight: "bold")[#it]
    }
    show outline.entry.where(level: 2): it => {
      v(0.2em)
      text()[#it]
    }
    show outline.entry.where(level: 3): it => {
      v(0.1em)
      text(style: "italic")[#it]
    }
    show outline.entry.where(level: 4): it => {
      v(0.1em)
      text(style: "italic", weight: "light")[#it]
    }
    outline(title: toc-title, indent: 1.2em)
    pagebreak()
  }

  // Render Document Body
  body
}
