// indorsement.typ: Indorsement rendering for USAF memorandum
//
// This module implements indorsements (endorsements) per AFH 33-337 Chapter 14.
// Indorsements are used to forward memorandums with additional commentary.
// They follow the format: "1st Ind", "2d Ind", "3d Ind", etc.
// Each indorsement includes its own body text and signature block.
//
// Note: When using #show: indorsement.with(...), the indorsement wraps the
// entire remainder of the document. This works for a single indorsement at
// the end of a file. For multiple indorsements, use the function call syntax:
// #indorsement(...)[Body text...]

#import "primitives.typ": *

#let indorsement(
  from: none,
  to: none,
  signature_block: none,
  signature_blank_lines: 4,
  attachments: none,
  cc: none,
  new_page: false,
  date: none,
  informal: false,
  content
) = {
  if not informal {
    assert(from != none, message: "from is required")
    assert(to != none, message: "to is required")
  }
  assert(signature_block != none, message: "signature_block is required")

  let actual_date = if date == none { datetime.today() } else { date }
  let ind_from = first-or-value(from)
  let ind_for = to

  if not informal {
    // Step the counter BEFORE the context block to avoid read-then-update loop
    counters.indorsement.step()
    
    context {
    let config = query(metadata).last().value
    let original_subject = config.subject
    let original_date = config.original_date
    let original_from = config.original_from

    // Read the counter value (already stepped above)
    let indorsement_number = counters.indorsement.get().at(0, default: 1)
    let indorsement_label = format-indorsement-number(indorsement_number)

    if new_page {
      pagebreak()
      [#indorsement_label to #original_from, #display-date(original_date), #original_subject]

      blank-line()
      grid(
        columns: (auto, 1fr),
        ind_from, align(right)[#display-date(actual_date)],
      )

      blank-line()
      grid(
        columns: (auto, auto, 1fr),
        "MEMORANDUM FOR", "  ", ind_for,
      )
    } else {
      blank-line()
      grid(
        columns: (auto, 1fr),
        [#indorsement_label, #ind_from], align(right)[#display-date(actual_date)],
      )

      blank-line()
      grid(
        columns: (auto, auto, 1fr),
        "MEMORANDUM FOR", "  ", ind_for,
      )
    }
    }
    blank-line()
  }

  // Enable paragraph numbering for indorsement body (same as mainmatter)
  IN_BACKMATTER_STATE.update(false)
  render-paragraph-body(content)
  

  // Disable paragraph numbering for indorsement backmatter sections
  IN_BACKMATTER_STATE.update(true)
  render-signature-block(signature_block, signature-blank-lines: signature_blank_lines)

  if not falsey(attachments) {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (
      (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
        + " (listed on next page):"
    )
    render-backmatter-section(attachments, section-label, numbering-style: "1.", continuation-label: continuation-label)
  }

  if not falsey(cc) {
    calculate-backmatter-spacing(falsey(attachments))
    render-backmatter-section(cc, "cc:")
  }
}
