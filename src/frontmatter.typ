// frontmatter.typ: Frontmatter show rule for USAF memorandum
//
// This module implements the frontmatter (heading section) of a USAF memorandum
// per AFH 33-337 Chapter 14 "The Heading Section". It handles:
// - Page setup with proper margins
// - Letterhead rendering
// - Date, MEMORANDUM FOR, FROM, SUBJECT, and References placement
// - Classification markings in headers/footers

#import "primitives.typ": *

#let frontmatter(
  subject: none,
  memo_for: none,
  memo_from: none,
  date: none,
  references: none,

  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead_seal: none,
  letterhead_font: DEFAULT_LETTERHEAD_FONTS,

  body_font: DEFAULT_BODY_FONTS,
  font_size: 12pt,
  memo_for_cols: 3,

  classification_level: none,
  footer_tag_line: none,
  it
) = {
  assert(subject != none, message: "subject is required")
  assert(memo_for != none, message: "memo_for is required")
  assert(memo_from != none, message: "memo_from is required")

  let actual_date = if date == none { datetime.today() } else { date }
  let classification_color = get-classification-level-color(classification_level)

  configure(body_font, font-size: font_size, {
    set page(
      paper: "us-letter",
      // AFH 33-337 §4: "Use 1-inch margins on the left, right and bottom"
      margin: (
        left: spacing.margin,
        right: spacing.margin,
        top: spacing.margin,
        bottom: spacing.margin
      ),
      header: context {
        // AFH 33-337 "Page numbering" §12: "The first page of a memorandum is never numbered.
        // Number the succeeding pages starting with page 2. Place page numbers 0.5-inch from
        // the top of the page, flush with the right margin."
        if counter(page).get().first() > 1 {
          place(
            dy: +.5in,
            block(
              width: 100%,
              align(right,
                text(12pt)[#counter(page).display()]
              )
            )
          )
        }

        if classification_level != none {
          place(
            top + center,
            dy: 0.375in,
            text(12pt, font: DEFAULT_BODY_FONTS, fill: classification_color)[#strong(classification_level)]
          )
        }
      },
      footer: context {
        place(
          bottom + center,
          dy: -.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification_color)[#strong(classification_level)]
        )

        if not falsey(footer_tag_line) {
          place(
            bottom + center,
            dy: -0.625in,
            align(center)[
              #text(fill: LETTERHEAD_COLOR, font: "cinzel", size: 15pt)[#footer_tag_line]
            ]
          )
        }
      }
    )

    paragraph-config.block-indent-state.update(false)

    render-letterhead(letterhead_title, letterhead_caption, letterhead_seal, letterhead_font)

    // AFH 33-337 "Date": "Place the date 1 inch from the right edge, 1.75 inches from the top"
    // Since we have a 1-inch top margin, we need (1.75in - margin) vertical space
    v(1.75in - spacing.margin)
    context {
      render-date-section(actual_date)
    }
    render-for-section(memo_for, memo_for_cols)
    render-from-section(memo_from)
    render-subject-section(subject)
    render-references-section(references)

    metadata((
      subject: subject,
      original_date: actual_date,
      original_from: first-or-value(memo_from),
      body_font: body_font,
      font_size: font_size,
    ))

    it
  })
}
