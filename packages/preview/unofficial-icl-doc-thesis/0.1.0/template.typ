// Imperial College London - Individual Project Template (Typst)
// Ported from the LaTeX template by Marc Deisenroth (2015)

// ─── THEME REFERENCE ──────────────────────────────────────────────────────────
// Imperial Blue:       #003E74  (primary brand colour)
// Imperial Light Blue: #D4EFFC  (accent / highlight)
// Imperial Navy:       #002147  (dark variant)
// Imperial Teal:       #009CBC
// Imperial Green:      #02893B
// Imperial Lime:       #BBCE00
// Imperial Orange:     #D24000
// Imperial Red:        #DD2501
// Imperial Berry:      #8F1444
// Imperial Violet:     #653098
// Imperial Grey:       #9C9FA4
// ─────────────────────────────────────────────────────────────────────────────

#let _default-theme = (
  // Fonts
  // Default: Times New Roman (universally available).
  // For Imperial branding, set body-font/heading-font in theme: and compile with --font-path fonts/
  body-font:    ("Times New Roman", "Linux Libertine", "Times", "serif"),
  heading-font: ("Times New Roman", "Linux Libertine", "Times", "serif"),
  code-font:    ("Courier New", "Courier", "monospace"),
  body-size:    12pt,

  // Colors
  primary:   rgb("#003E74"),  // Imperial Blue
  secondary: rgb("#D4EFFC"),  // Imperial Light Blue
  text:      black,
  link:      rgb("#003E74"),

  // Layout
  line-spacing:      0.65em,
  paragraph-spacing: 0.8em,

  // Chapter labels
  show-chapter-label: true,
  chapter-label:      "Chapter",
)

#let project(
  title:                "Project Title",
  author:               "Your Name",
  supervisor:           "Supervisor Name",
  report-type:          "MEng Individual Project",
  degree:               "Master of Engineering",
  date:                 datetime.today(),
  abstract:             [],
  acknowledgements:     none,
  logo:                 "figures/placeholder-logo.svg",
  logo-width:           4cm,
  show-acknowledgements: true,
  toc-depth:            3,
  department:           "Department of Computing",
  institution:          "Imperial College of Science, Technology and Medicine",
  // header-side: "twoside" | "left" | "right"
  header-side:          "twoside",
  theme:                (:),
  body,
) = {
  // Merge user-supplied theme overrides with defaults
  let t = _default-theme
  for (k, v) in theme {
    t.insert(k, v)
  }

  // Document settings
  set document(title: title, author: author)
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
    numbering: none,
  )
  set text(font: t.body-font, size: t.body-size, fill: t.text, ligatures: false, discretionary-ligatures: false)
  set par(justify: true, leading: t.line-spacing, spacing: t.paragraph-spacing)

  // Links
  show link: set text(fill: t.link)

  // Inline code
  show raw.where(block: false): set text(font: t.code-font)

  // Code blocks
  show raw.where(block: true): it => {
    set text(font: t.code-font, size: 0.9em)
    block(
      fill: t.secondary,
      inset: 0.8em,
      radius: 4pt,
      width: 100%,
      it,
    )
  }

  // Chapter counter for "CHAPTER X" label
  let chapter-counter = counter("chapter")
  // State: false until main body begins (after TOC)
  let body-started = state("body-started", false)
  // State: true when in back matter (no chapter numbers, no pagebreak)
  let back-matter-state = state("back-matter", false)

  // Headings use heading font in primary colour
  show heading.where(level: 1): it => {
    context {
      if body-started.get() and not back-matter-state.get() {
        // Main body chapter heading — with CHAPTER X label and pagebreak
        pagebreak(weak: true)
        chapter-counter.step()
        set text(font: t.heading-font, fill: t.primary)
        if t.show-chapter-label {
          v(1cm)
          text(
            font: t.heading-font,
            size: 11pt,
            fill: t.primary,
            weight: "bold",
            smallcaps(upper(t.chapter-label) + " " + context chapter-counter.display()),
          )
          v(0.3cm)
        }
        text(font: t.heading-font, size: 22pt, weight: "bold", fill: t.primary, it.body)
        v(0.5cm)
      } else if back-matter-state.get() {
        // Back matter heading — new page, but no CHAPTER X label
        pagebreak(weak: true)
        set text(font: t.heading-font, fill: t.primary)
        v(1cm)
        text(font: t.heading-font, size: 22pt, weight: "bold", fill: t.primary, it.body)
        v(0.5cm)
      } else {
        // Front matter heading — plain, no chapter number, no forced pagebreak
        set text(font: t.heading-font, fill: t.primary)
        text(font: t.heading-font, size: 22pt, weight: "bold", fill: t.primary, it.body)
        v(0.5cm)
      }
    }
  }
  show heading.where(level: 2): it => {
    set text(font: t.heading-font, fill: t.primary)
    it
  }
  show heading.where(level: 3): it => {
    set text(font: t.heading-font, fill: t.primary)
    it
  }
  set heading(numbering: "1.1")

  // ─── Title Page ───────────────────────────────────────────────
  page(numbering: none)[
    #align(center)[
      #image(logo, width: logo-width)
      #v(1cm)

      #text(
        font: t.heading-font,
        size: 18pt,
        weight: "bold",
        fill: t.primary,
        smallcaps(report-type),
      )
      #v(1cm)
      #text(font: t.heading-font, size: 14pt, fill: t.primary, smallcaps(department))
      #v(0.4cm)
      #text(font: t.body-font, size: 11pt, smallcaps(institution))
      #v(1cm)

      #line(length: 100%, stroke: 0.5pt + t.primary)
      #v(0.5cm)
      #text(font: t.heading-font, size: 22pt, weight: "bold", fill: t.primary, title)
      #v(0.5cm)
      #line(length: 100%, stroke: 0.5pt + t.primary)
      #v(1.5cm)

      #grid(
        columns: (1fr, 1fr),
        align(left)[
          #text(style: "italic")[Author:] \
          #author
        ],
        align(right)[
          #text(style: "italic")[Supervisor:] \
          #supervisor
        ],
      )

      #v(4cm)
      #text(size: 12pt, date.display("[day] [month repr:long] [year]"))
      #v(1cm)
      #text(size: 11pt)[
        Submitted in partial fulfillment of the requirements for the \
        #degree of Imperial College London
      ]
    ]
  ]

  // ─── Roman numerals for front matter ─────────────────────────
  set page(numbering: "i", number-align: center)
  counter(page).update(1)

  // Abstract
  if abstract != [] {
    pagebreak(weak: true)
    align(center)[
      #text(font: t.heading-font, size: 18pt, weight: "bold", fill: t.primary)[Abstract]
      #v(0.3cm)
      #line(length: 60%, stroke: 0.5pt + t.primary)
    ]
    v(0.8cm)
    align(center, block(width: 85%, align(left, abstract)))
  }

  // Acknowledgements (optional)
  if show-acknowledgements and acknowledgements != none {
    pagebreak(weak: true)
    heading(outlined: false, numbering: none, "Acknowledgements")
    acknowledgements
  }

  // Table of Contents
  pagebreak(weak: true)
  outline(depth: toc-depth, indent: 1em)

  // ─── Arabic numerals for main body ───────────────────────────
  pagebreak(weak: true)
  set page(numbering: "1", number-align: center)
  counter(page).update(1)

  // Page header — shows current chapter title
  set page(header: context {
    // Find the heading that is AT or BEFORE the current position on this page
    // Use after(here()) trick: get the first heading on/after page start,
    // fall back to last heading before current position.
    let before = query(selector(heading.where(level: 1)).before(here()))
    let after  = query(selector(heading.where(level: 1)).after(here()))

    // On a chapter-start page, the heading appears after `here()` in the
    // document flow but is visually on this page. Check if the next heading
    // starts on the same page.
    let current-page = here().page()
    let h = none

    // Prefer: a heading that begins on this page (even if after cursor)
    for item in after {
      if item.location().page() == current-page {
        h = item
        break
      }
    }
    // Fallback: last heading from before cursor
    if h == none and before.len() > 0 {
      h = before.last()
    }

    if h != none {
      let chapter-text = text(
        font: t.body-font,
        size: 10pt,
        style: "italic",
        h.body,
      )
      let page-num = counter(page).get().first()
      let show-right = (
        header-side == "right" or
        (header-side == "twoside" and calc.odd(page-num))
      )
      let show-left = (
        header-side == "left" or
        (header-side == "twoside" and calc.even(page-num))
      )
      if show-right {
        align(right, chapter-text)
      } else if show-left {
        align(left, chapter-text)
      }
      line(length: 100%, stroke: 0.3pt + t.primary)
    }
  })

  body-started.update(true)
  body
}

/// Call this before bibliography / abbr-list to suppress chapter numbering.
/// Example:
///   #back-matter()
///   #abbr-list()
///   #bibliography("references.bib", style: "elsevier-vancouver")
#let back-matter() = state("back-matter", false).update(true)
