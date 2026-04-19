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
#import "body.typ": *

#let indorsement(
  from: none,
  to: none,
  signature_block: none,
  signature_blank_lines: 4,
  attachments: none,
  cc: none,
  date: none,
  // Format of indorsement: "standard" (same page), "informal" (no header), or "separate_page" (starts on new page)
  format: "standard",
  // Approval action: none (default, no action line displayed), "undecided", "approve", or "disapprove".
  // When set to "undecided", the action line is displayed with neither option circled.
  // When set to "approve" or "disapprove", the action line is displayed with the selected option circled.
  action: none,
  content,
) = {
  // Validate format parameter
  assert(
    format in ("standard", "informal", "separate_page"),
    message: "format must be \"standard\", \"informal\", or \"separate_page\"",
  )

  if format != "informal" {
    assert(from != none, message: "from is required")
    assert(to != none, message: "to is required")
  }


  let actual_date = if date == none { datetime.today() } else { date }
  let ind_from = first-or-value(from)
  let ind_for = to

  if format != "informal" {
    // Step the counter BEFORE the context block to avoid read-then-update loop
    counters.indorsement.step()

    context {
      let config = query(metadata).last().value
      let memo-style = config.at("memo_style", default: "usaf")
      let original_subject = config.subject
      let original_date = config.original_date
      let original_from = config.original_from

      // Read the counter value (already stepped above)
      let indorsement_number = counters.indorsement.get().at(0, default: 1)
      let indorsement_label = format-indorsement-number(indorsement_number)

      if format == "separate_page" {
        pagebreak()
        [#indorsement_label to #original_from, #display-date(original_date, memo-style: memo-style), #original_subject]

        blank-line()
        grid(
          columns: (auto, 1fr),
          ind_from, align(right)[#display-date(actual_date, memo-style: memo-style)],
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
          [#indorsement_label, #ind_from], align(right)[#display-date(actual_date, memo-style: memo-style)],
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

  // Show action line only when an action decision is set (not `none`)
  if action != none {
    render-action-line(action)
  }

  context {
    let memo-style = {
      let items = query(metadata)
      if items.len() > 0 { items.last().value.at("memo_style", default: "usaf") } else { "usaf" }
    }
    render-body(content, memo-style: memo-style)
  }

  render-signature-block(signature_block, signature-blank-lines: signature_blank_lines)

  render-backmatter-sections(attachments: attachments, cc: cc)
}
