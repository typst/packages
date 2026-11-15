// What a resolved theme prints of the invoice data besides the components:
// the `prints` of `logic/printed.typ`, for the checks of an e-invoice that the
// printed invoice states what the XML states (the seller's tax number or VAT
// ID, IP-PRINT-03, and the date of the supply, IP-PERIOD-03).
//
// The page frame is layout data, so it is read from the layout: which parts
// the areas host that are printed. A part prints what its name says (the
// part contract), also when a look or the user replaced or wrapped its
// renderer; content that invoice-pro cannot read (content and function cells,
// replaced and wrapped renderers, custom parts, stationery) counts as page
// content of its own, which may show a detail the checks look for.

/// The `prints` of a resolved theme (see `logic/printed.typ`):
/// - `references`: an area hosts `references` or `reference-list`,
/// - `sender-extra`: an area hosts `sender-details` or `contact`, which
///   print the sender's `extra`,
/// - `recipient-extra`: an area hosts `recipient` or `return-address`, which
///   print the recipient's `extra`,
/// - `registration`: an area hosts `registration`, which prints the sender's
///   VAT ID and tax number,
/// - `page-content`: the page shows content that invoice-pro cannot read.
///
/// -> dictionary
#let prints-of(theme) = {
  let layout = theme.layout
  let builtin = theme.base.parts
  let replaced = theme.spec.replaced
  // Stationery other than `none` drops the areas that belong to it: the
  // paper prints them, and whatever else it shows.
  let stationery = layout.stationery != none
  let hosted = ()
  let unreadable = stationery
  for area in layout.areas.values() {
    if area == none or (stationery and area.stationery) { continue }
    for part in area.parts {
      if type(part) != str {
        unreadable = true
        continue
      }
      let renderer = theme.parts.at(part, default: none)
      // A part switched off prints nothing.
      if renderer == none { continue }
      hosted.push(part)
      if (
        part in replaced or part not in builtin or renderer != builtin.at(part)
      ) { unreadable = true }
    }
  }
  let hosts(..names) = names.pos().any(name => name in hosted)
  (
    references: hosts("references", "reference-list"),
    sender-extra: hosts("sender-details", "contact"),
    recipient-extra: hosts("recipient", "return-address"),
    registration: hosts("registration"),
    page-content: unreadable,
  )
}
