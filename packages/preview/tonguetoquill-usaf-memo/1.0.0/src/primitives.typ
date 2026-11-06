// primitives.typ: Reusable rendering primitives for USAF memorandum sections
//
// This module implements the visual rendering functions that produce AFH 33-337
// compliant formatting for all sections of a USAF memorandum. Each function
// corresponds to specific placement and formatting requirements from Chapter 14.

#import "config.typ": *
#import "utils.typ": *

// =============================================================================
// LETTERHEAD RENDERING
// =============================================================================
// AFH 33-337 §1: "Use printed letterhead, computer-generated letterhead, or plain bond paper"
// Letterhead placement is not explicitly specified in AFH 33-337, but follows
// standard USAF memo formatting conventions

#let render-letterhead(title, caption, letterhead-seal, font) = {
  font = ensure-array(font)
  caption = ensure-string(caption)

  place(
    dy: 0.625in - spacing.margin,
    box(
      width: 100%,
      fill: none,
      stroke: none,
      [
        #place(
          center + top,
          align(center)[
            #text(12pt, font: font, fill: LETTERHEAD_COLOR)[#title]\
            #text(10.5pt, font: font, fill: LETTERHEAD_COLOR)[#caption]
          ],
        )
      ],
    ),
  )

  if letterhead-seal != none {
    place(
      left + top,
      dx: -0.5in,
      dy: -.5in,
      block[
        #fit-box(width: 2in, height: 1in)[#letterhead-seal]
      ],
    )
  }
}

// =============================================================================
// HEADER SECTIONS
// =============================================================================
// AFH 33-337 "The Heading Section" specifies exact placement and format for:
// - Date: 1 inch from right edge, 1.75 inches from top
// - MEMORANDUM FOR: Second line below date
// - FROM: Second line below MEMORANDUM FOR
// - SUBJECT: Second line below FROM

// AFH 33-337 "Date": "Place the date 1 inch from the right edge, 1.75 inches from the top"
#let render-date-section(date) = {
  align(right)[#display-date(date)]
}

// AFH 33-337 "MEMORANDUM FOR": "Place 'MEMORANDUM FOR' on the second line below the date"
#let render-for-section(recipients, cols) = {
  blank-line()
  grid(
    columns: (auto, auto, 1fr),
    "MEMORANDUM FOR",
    "  ",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients, column-gutter: spacing.tab, cols: cols)
      } else {
        recipients
      }
    ],
  )
}

// AFH 33-337 "FROM:": "Place 'FROM:' in uppercase, flush with the left margin,
// on the second line below the last line of the MEMORANDUM FOR element"
#let render-from-section(from-info) = {
  blank-line()
  from-info = ensure-string(from-info)

  grid(
    columns: (auto, auto, 1fr),
    "FROM:", "  ", align(left)[#from-info],
  )
}

// AFH 33-337 "SUBJECT:": "In all uppercase letters place 'SUBJECT:', flush with the
// left margin, on the second line below the last line of the FROM element"
#let render-subject-section(subject-text) = {
  blank-line()
  grid(
    columns: (auto, auto, 1fr),
    "SUBJECT:", "  ", [#subject-text],
  )
}

#let render-references-section(references) = {
  if not falsey(references) {
    blank-line()
    grid(
      columns: (auto, auto, 1fr),
      "References:", "  ", enum(..references, numbering: "(a)"),
    )
  }
}

// =============================================================================
// SIGNATURE BLOCK
// =============================================================================
// AFH 33-337 "Signature Block": "Start the signature block on the fifth line below
// the last line of text and 4.5 inches from the left edge of the page"
// AFH 33-337 "Do not place the signature element on a continuation page by itself"

#let render-signature-block(signature-lines, signature-blank-lines: 4) = {
  // AFH 33-337: "The signature block is never on a page by itself"
  // Note: Perfect enforcement isn't feasible without over-engineering
  // We use weak: false spacing and breakable: false to discourage orphaning
  // AFH 33-337: "fifth line below" = 4 blank lines between text and signature block
  blank-lines(signature-blank-lines, weak: false)
  block(breakable: false)[
    #align(left)[
      // AFH 33-337: "4.5 inches from the left edge of the page"
      // We use (4.5in - margin) because Typst's pad() is relative to the text area, not page edge
      #pad(left: 4.5in - spacing.margin)[
        #text(hyphenate: false)[
          #signature-lines.join(linebreak())
        ]
      ]
    ]
  ]
}

// =============================================================================
// BACKMATTER SECTIONS
// =============================================================================
// AFH 33-337 "Attachment or Attachments": "Place 'Attachment:' (for a single attachment)
// or '# Attachments:' (for two or more attachments) at the left margin, on the third
// line below the signature element"
// AFH 33-337 "Courtesy Copy Element": "place 'cc:' flush with the left margin, on the
// second line below the attachment element"

#let render-backmatter-section(
  content,
  section-label,
  numbering-style: none,
  continuation-label: none
) = {
  let formatted-content = {
    // Use text() wrapper to prevent section label from being treated as a paragraph
    text()[#section-label]
    linebreak()
    if numbering-style != none {
      let items = ensure-array(content)
      enum(..items, numbering: numbering-style)
    } else {
      ensure-string(content)
    }
  }

  context {
    let available-space = page.height - here().position().y - 1in
    if measure(formatted-content).height > available-space {
      let continuation-text = if continuation-label != none {
        text()[#continuation-label]
      } else {
        text()[#section-label + " (listed on next page):"]
      }
      continuation-text
      pagebreak()
    }
    formatted-content
  }
}

#let calculate-backmatter-spacing(is-first-section) = {
  context {
    let line_count = if is-first-section { 2 } else { 1 }
    blank-lines(line_count)
  }
}

#let render-backmatter-sections(
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = {
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )

  if leading-pagebreak and has-backmatter {
    pagebreak(weak: true)
  }

  if attachments != none and attachments.len() > 0 {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (
      (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
        + " (listed on next page):"
    )
    render-backmatter-section(attachments, section-label, numbering-style: "1.", continuation-label: continuation-label)
  }

  if cc != none and cc.len() > 0 {
    calculate-backmatter-spacing(attachments == none or attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }

  if distribution != none and distribution.len() > 0 {
    calculate-backmatter-spacing((attachments == none or attachments.len() == 0) and (cc == none or cc.len() == 0))
    render-backmatter-section(distribution, "DISTRIBUTION:")
  }
}

// =============================================================================
// PARAGRAPH BODY RENDERING
// =============================================================================
// AFH 33-337 "The Text of the Official Memorandum" §1-12 specifies:
// - Single-space text, double-space between paragraphs
// - Number and letter each paragraph and subparagraph
// - "A single paragraph is not numbered" (§2)
// - First paragraph flush left, never indented
// - Indent sub-paragraphs to align with first character of parent paragraph text

#let render-paragraph-body(content) = {
  // Initialize base level counter
  counter("par-counter-0").update(1)

  // AFH 33-337: "Number and letter each paragraph and subparagraph. A single
  // paragraph is not numbered."
  // Count paragraphs using repr() introspection
  let content-str = repr(content)

  // Detect multiple paragraphs by looking for parbreak() between content elements
  // Pattern: content, parbreak(), content
  // This matches parbreak() BETWEEN content, not trailing parbreaks
  let has-multiple-pars = (
    content-str.contains("parbreak(),")
      and content-str.matches(regex("(\\]|\\)),\\s*parbreak\\(\\),\\s*(\\[|[a-zA-Z_][a-zA-Z0-9_]*\\()")).len() > 0
  )

  // Render with paragraph numbering based on detection
  context {
    let should-number = has-multiple-pars

    // Track nesting level for enum/list items
    let enum-level = state("enum-level", 1)

    // State to track pending heading text that should be prepended to next paragraph
    let pending-heading = state("pending-heading", none)

    // Suppress default enum/list rendering - we'll handle it via nested paragraphs
    show enum.item: _enum_item => {}
    show list.item: _list_item => {}

    // Intercept enum items to set nesting level
    show enum.item: _enum_item => context {
      enum-level.update(l => l + 1)
      SET_LEVEL(enum-level.get())

      // Don't render the enum marker - render body content as nested paragraphs instead
      v(0em, weak: true)
      _enum_item.body

      // Reset level after nested content
      SET_LEVEL(0)
      enum-level.update(l => l - 1)
    }

    // Intercept list items to set nesting level
    show list.item: list_item => context {
      enum-level.update(l => l + 1)
      SET_LEVEL(enum-level.get())

      // Don't render the list marker - render body content as nested paragraphs instead
      v(0em, weak: true)
      list_item.body

      // Reset level after nested content
      SET_LEVEL(0)
      enum-level.update(l => l - 1)
    }

    // Intercept headings to render as bold paragraph headings
    // AFH 33-337: Headings within memo body should be rendered as bold text
    // prepended to the following paragraph, not as standalone heading elements.
    // Store heading in state to be consumed by the next paragraph.
    show heading: it => context {
      // Store heading text in state to prepend to next paragraph
      pending-heading.update(it.body)
      // Return empty content - heading will be rendered with the paragraph
      v(0em, weak: true)
    }

    // Intercept paragraphs for numbering
    show par: it => context {
      // Check if we're in backmatter - if so, don't number paragraphs
      if IN_BACKMATTER_STATE.get() {
        it
      } else {
        // Check if there's a pending heading to prepend
        let heading-text = pending-heading.get()

        // Build paragraph content with optional heading prefix
        let paragraph-content = if heading-text != none {
          // Clear the pending heading
          pending-heading.update(none)
          // Prepend bold heading text with period and space to paragraph body
          [*#heading-text.* #it.body]
        } else {
          it.body
        }

        blank-line()
        if should-number {
          // Apply paragraph numbering per AFH 33-337 §2
          let paragraph = memo-par(paragraph-content)
          // AFH 33-337 "Continuation Pages" §11: "Type at least two lines of the text on each page.
          // Avoid dividing a paragraph of less than four lines between two pages."
          // We use Typst's orphan cost control to discourage single-line orphans
          set text(costs: (orphan: 0%))
          block(breakable: true)[#paragraph]
        } else {
          // AFH 33-337 §2: "A single paragraph is not numbered"
          // Return body content wrapped in block (like numbered case, but without numbering)
          set text(costs: (orphan: 0%))
          block(breakable: true)[#paragraph-content]
        }
      }
    }

    // Reset to base level and render content
    SET_LEVEL(0)
    content
  }
}
