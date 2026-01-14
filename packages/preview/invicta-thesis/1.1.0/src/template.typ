// INVICTA THESIS TEMPLATE
// Main template function and document setup

#import "covers.typ": make-committee-page, make-cover
#import "toc.typ": make-toc
#import "utils.typ": set-config

// Main template function
#let invicta-thesis(
  // Document metadata
  title: "<DISSERTATION-TITLE>",
  author: "<FULL-NAME>",
  degree: "<DEGREE>",
  supervisor: "<SUPERVISOR>",
  second-supervisor: none,
  // Dates and copyright
  thesis-date: none, // If none, current date will be used
  copyright-notice: none,
  // Visual elements
  additional-front-text: none,
  // Committee information
  committee-text: none, // Put text if final version
  committee-members: (),
  signature: false, // true if handwritten signature
  dedication-text: none, // Optional dedication
  // Configuration options
  stage: none, // none, "jury", "final"
  language: "en", // "en", "pt"
  on-paper: false, // if true, links are not shown (for paper versions)
  // Document body
  body,
) = {
  // Create configuration object
  let config = (
    title: title,
    author: author,
    degree: degree,
    supervisor: supervisor,
    second-supervisor: second-supervisor,
    thesis-date: thesis-date,
    copyright-notice: copyright-notice,
    additional-front-text: additional-front-text,
    committee-text: committee-text,
    committee-members: committee-members,
    signature: signature,
    stage: stage,
    language: language,
    on-paper: on-paper,
  )

  // Document setup
  set document(
    title: title,
    author: author,
    date: datetime.today(),
  )

  // Page setup
  set page(
    paper: "a4",
    margin: (
      top: 2.5cm,
      bottom: 2.5cm,
      left: 4.5cm,
      right: 3.5cm,
    ),
    numbering: "1",
    number-align: top + right,
  )

  // Text formatting
  set text(
    size: 12pt,
    lang: language,
    font: "Nimbus Roman",
  )

  // Paragraph formatting
  set par(
    justify: true,
    first-line-indent: (amount: 1.5em, all: false),
    spacing: 1.2em,
  )

  set heading(numbering: "1.1")

  // Heading formatting
  show heading: it => [

    #let heading_size = if it.level == 1 {
      22pt
    } else if it.level == 2 {
      18pt
    } else if it.level == 3 {
      15pt
    } else {
      14pt
    }

    #if it.level > 1 {
      v(1em)
      block(
        text(counter(heading).display() + h(0.4cm) + it.body, size: heading_size)
      )
      v(1em)
    } else {
      pagebreak(weak: true)
      v(6.3em)
      if it.numbering != none {
        let chapter_num = counter(heading).get().first()

        // Check if this is an appendix by looking at the numbering pattern
        if it.numbering == "A.1" {
          // Convert number to letter (1=A, 2=B, etc.)
          let appendix_letter = str.from-unicode(65 + chapter_num - 1) // 65 is ASCII for 'A'
          block(
            text(size: 24pt, weight: "bold", [Appendix #appendix_letter]),
          )
        } else {
          block(
            text(size: 24pt, weight: "bold", [Chapter #chapter_num]),
          )
        }
      }
      v(1em)
      block(
        text(size: 28pt, weight: "bold", it.body),
      )
      v(2em)}
    
  ]

  // Figure and table formatting
  set figure(
    gap: 1em,
    supplement: [Figure],
  )

  set table(
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { gray.lighten(80%) },
  )

  // Link formatting
  show link: it => text(
    fill: if on-paper { blue } else { black },
    it,
  )

  // Generate the document
  // Main document structure
  make-cover(config)

  // Preliminary materials
  make-committee-page(config)

  // Store config temporarily for main-content access
  set-config(config)

  body
}

// Function to set up main content with headers and page numbering
#let main-content(config, body) = {
  set par.line(numbering: n => if config.stage == "jury" and calc.rem(n, 2) == 0 { n })

  set page(
    numbering: none, // Disable automatic numbering since we handle it in header
    number-align: top + right,
    header: context {
      let current-page = here().page()
      let page-number = counter(page).at(here()).first()

      // Don't show header on chapter start pages
      let all-headings = query(heading)

      // Check if current page is a chapter start and skip header if so
      for h in all-headings {
        if h.level == 1 and h.location().page() == current-page {
          return none
        }
      }

      // Get current chapter and section
      let chapter-headings = all-headings.filter(h => (
        h.level == 1 and h.location().page() <= current-page
      ))
      let section-headings = all-headings.filter(h => (
        h.level == 2 and h.location().page() <= current-page
      ))

      let header-content = none
      if chapter-headings.len() > 0 {
        let current-chapter = chapter-headings.last()
        let chapter-counter = counter(heading).at(current-chapter.location())
        let chapter-num = chapter-counter.first()

        // Check if this is odd or even page
        if calc.odd(page-number) {
          // Odd pages: show current subsection (if any)
          if section-headings.len() > 0 {
            let current-section = section-headings.last()
            let section-counter = counter(heading).at(
              current-section.location(),
            )
            header-content = text(size: 12pt, style: "italic")[
              #section-counter.first().#section-counter.at(1) #current-section.body
            ]
          } else {
            // If no subsection, show chapter
            header-content = text(size: 12pt, style: "italic")[
              #current-chapter.body
            ]
          }
        } else {
          // Even pages: show current chapter
          header-content = text(size: 12pt, style: "italic")[
            #current-chapter.body
          ]
        }
      }

      // Create header with content on left and page number on right
      pad(
        left: -1cm,
        right: -0.7cm,
        grid(
          columns: (1fr, auto),
          align: (left, right),
          header-content, text(size: 11pt)[#page-number],
        )
      )
    },
    footer: context {
      let current-page = here().page()
      let page-number = counter(page).at(here()).first()

      // Show footer page number only on chapter start pages
      let all-headings = query(heading)

      for h in all-headings {
        if h.level == 1 and h.location().page() == current-page {
          return align(center)[#text(size: 11pt)[#page-number]]
        }
      }

      return none // No footer on regular pages
    },
  )
  counter(page).update(1)
  body
}
