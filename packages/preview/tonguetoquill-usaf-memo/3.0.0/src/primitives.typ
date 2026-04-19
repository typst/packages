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

#let render-letterhead(
  title,
  caption,
  font,
  letterhead-seal: none,
  letterhead-seal-subtitle: none,
) = {
  font = ensure-array(font)
  title = ensure-string(title)
  caption = ensure-string(caption)
  title = upper(title)
  caption = upper(caption)

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
            #set text(12pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
            #title\
            #text(10.5pt)[#caption]
          ],
        )
      ],
    ),
  )

  if letterhead-seal != none {
    let seal-body = if falsey(letterhead-seal-subtitle) {
      block[
        #fit-box(width: 2in, height: 1in)[#letterhead-seal]
      ]
    } else {
      // Isolate seal column from document `font_size`: stack `em` spacing and subtitle
      // must not scale with body text (see frontmatter `set text(size: font_size)`).
      block(width: 2in)[
        #set text(9pt, font: font, fill: LETTERHEAD_COLOR, weight: "bold")
        #align(left)[
          // Spacing applies between positional stack children only, not one `[…]` body.
          #stack(
            spacing: .8em,
            fit-box(width: 2in, height: 1in)[#letterhead-seal],
            upper(ensure-string(letterhead-seal-subtitle)),
          )
        ]
      ]
    }
    place(
      left + top,
      dx: -0.5in,
      dy: -.5in,
      seal-body,
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
#let render-date-section(date, memo-style: "usaf") = {
  align(right)[#display-date(date, memo-style: memo-style)]
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
      "References:", "  ", enum(..references, numbering: "(a) ", body-indent: 0pt),
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
  signature-lines = ensure-array(signature-lines)
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
          #for line in signature-lines {
            par(hanging-indent: 4 * 0.5em, line)
          }
        ]
      ]
    ]
  ]
}

// =============================================================================
// ACTION LINE RENDERING
// =============================================================================
// Renders the Approve / Disapprove action line for indorsement memos.
// action: "none" = no action line displayed (hidden), "undecided" = both options
// rendered plain (no circle), "approve" = Approve circled,
// "disapprove" = Disapprove circled. The action line is rendered when
// action is "undecided", "approve", or "disapprove".

#let render-action-line(action) = {
  assert(
    action in ("none", "undecided", "approve", "disapprove"),
    message: "action must be \"none\", \"undecided\", \"approve\", or \"disapprove\"",
  )
  blank-line()
  // Circle the selected option using a box with rounded corners
  // Use baseline parameter to maintain vertical text alignment
  let approve-text = if action == "approve" {
    box(stroke: 0.5pt + black, radius: 2pt, inset: 2pt, baseline: 2pt)[Approve]
  } else if action == "disapprove" {
    strike[Approve]
  } else {
    [Approve]
  }
  let disapprove-text = if action == "disapprove" {
    box(stroke: 0.5pt + black, radius: 2pt, inset: 2pt, baseline: 2pt)[Disapprove]
  } else if action == "approve" {
    strike[Disapprove]
  } else {
    [Disapprove]
  }
  // Keep the action line with the following content (body or signature block)
  // using the same sticky-block pattern that body.typ applies to the last
  // paragraph, per AFH 33-337 §11 orphan-prevention rules.
  block(sticky: true)[#approve-text / #disapprove-text]
}

// =============================================================================
// TABLE RENDERING
// =============================================================================
// AFH 33-337 does not specify table formatting, so we follow the general
// aesthetic principles of the standard: plain black borders, no decorative
// fills, and the body font inherited throughout.

/// Renders a table with USAF memorandum–consistent formatting.
///
/// Applies simple 0.5pt black cell borders and standard padding to any
/// Typst `table` element, keeping the visual style clean and formal.
/// Font and size are inherited from the surrounding body text.
///
/// - it (content): The table element to style and render
/// -> content
#let render-memo-table(it) = {
  // AFH 33-337 does not specify table formatting, so we follow the general
  // aesthetic principles of the standard: bold headers for clarity.
  show table.cell.where(y: 0): set text(weight: "bold")
  set table(
    stroke: 0.5pt + black,
    inset: (x: 0.5em, y: 0.4em),
  )
  it
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
  continuation-label: none,
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
      // Attachments pass continuation-label ("… (listed on next page):" per AFH 33-337).
      // cc: and DISTRIBUTION: use a neutral default — "listed" applies to attachment lists only.
      let continuation-text = if continuation-label != none {
        text()[#continuation-label]
      } else {
        text()[#(section-label + " (continued on next page)")]
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

