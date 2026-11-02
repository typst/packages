// What the printed invoice shows besides the components, for the checks of
// an e-invoice that the printed invoice states what the XML states: the
// seller's tax number or VAT ID (IP-PRINT-03) and the date of the supply
// (IP-PERIOD-03).
//
// Invoice-pro knows where a theme prints these details from its layout: the
// parts its areas host (`prints-of` of `theming/prints.typ`). A theme whose
// areas host no references prints none of them, the document does: then
// nothing is known, and nothing is reported.

#import "../utils/text.typ": plain-text

/// What the root context knows about the printed invoice while it builds the
/// e-invoice: whether the theme prints the reference signs (`known`), the
/// printed references, the name and address lines of the sender and the
/// recipient (which every invoice prints, and which may carry e.g. the
/// sender's VAT ID), the sender's VAT ID and tax number if the theme prints
/// its registration details, the `extra` details of the parties the theme
/// prints, whether the theme prints content of its own on every page (e.g. a
/// footer it cannot read), and the drawn body, whose text is searched only
/// when needed.
///
/// `prints` says what the theme prints (see `prints-of` of
/// `theming/prints.typ`): `references`, `sender-extra` and `recipient-extra`
/// (or `party-extra` for both), `registration` and `page-content`, each
/// `false` unless set.
///
/// -> dictionary
#let printed-record(prints, references, sender, recipient, body) = {
  let party-extra = prints.at("party-extra", default: false)
  let lines = ()
  for party in (sender, recipient) {
    for key in ("name", "address", "city") {
      lines.push(party.at(key, default: none))
    }
  }
  if prints.at("registration", default: false) == true {
    for key in ("vat-id", "tax-nr") {
      lines.push(sender.at(key, default: none))
    }
  }
  let extra = ()
  if prints.at("sender-extra", default: party-extra) == true {
    extra.push(sender.at("extra", default: ()))
  }
  if prints.at("recipient-extra", default: party-extra) == true {
    extra.push(recipient.at("extra", default: ()))
  }
  (
    known: prints.at("references", default: false) == true,
    references: references,
    lines: lines,
    extra: extra,
    page-content: prints.at("page-content", default: false) == true,
    body: body,
  )
}

// A plain text as it is compared: without spaces (`plain-text` collapses
// any whitespace to one), in upper case, with en and em dashes as "-" (as
// `plain-text` sets other hyphens), so that "DE 123 456 789" shows
// "DE123456789" and "01.06.2026 - 30.06.2026" shows "01.06.2026 – 30.06.2026".
#let _compact(text) = (
  upper(text).replace(" ", "").replace("\u{2013}", "-").replace("\u{2014}", "-")
)

// Whether the compact plain text of `value` contains one of `wanted`.
#let _shows(value, wanted) = {
  let text = _compact(plain-text(value))
  if text == "" { return false }
  for part in wanted {
    if text.contains(part) { return true }
  }
  false
}

// Whether the printed reference signs (except those titled one of
// `except`), the name and address lines or the `extra` details of the
// parties or the text of the invoice show one of `wanted` (compact texts).
#let _search(printed, wanted, except: ()) = {
  for reference in printed.at("references", default: ()) {
    if type(reference) != array or reference.len() != 2 { continue }
    if except.len() > 0 and plain-text(reference.first()) in except {
      continue
    }
    if _shows(reference.last(), wanted) { return true }
  }
  for line in printed.at("lines", default: ()) {
    if _shows(line, wanted) { return true }
  }
  for extra in printed.at("extra", default: ()) {
    let values = if type(extra) == dictionary { extra.values() } else if (
      type(extra) == array
    ) {
      extra.map(entry => if type(entry) == array { entry.last() } else {
        entry
      })
    } else { (extra,) }
    for value in values {
      if _shows(value, wanted) { return true }
    }
  }
  // The text of the invoice, e.g. `#info.sender.vat-id` in a closing note.
  _shows(printed.at("body", default: none), wanted)
}

// The compact texts of `values` that are not empty.
#let _wanted(values) = {
  let wanted = ()
  for value in values {
    if value == none { continue }
    let text = _compact(plain-text(value))
    if text != "" { wanted.push(text) }
  }
  wanted
}

// Whether invoice-pro knows what the theme prints (`printed-record`).
#let _known(printed) = (
  type(printed) == dictionary and printed.at("known", default: false)
)

/// Whether the printed invoice shows one of `identifiers` (e.g. the seller's
/// VAT ID and tax number, compared without spaces and in upper case) in the
/// reference signs, the `extra` of the parties or the text of the invoice:
/// `true` or `false`, or `none` if it cannot be known. That is the case when
/// the theme does not say that it prints the reference signs (`printed.known`)
/// or prints content of its own on every page (e.g. a footer), which may
/// show them.
///
/// -> none | bool
#let shows-identifier(printed, identifiers) = {
  if not _known(printed) { return none }
  let wanted = _wanted(identifiers)
  if wanted.len() == 0 { return none }
  if _search(printed, wanted) { return true }
  if printed.at("page-content", default: false) { return none }
  false
}

/// Whether the printed invoice shows `value` (e.g. the date of the supply as
/// the e-invoice states it, compared without spaces) in a reference sign
/// whose title is not one of `except` (e.g. the invoice date), the `extra` of
/// the parties or the text of the invoice: `true` or `false`, or `none` if
/// it cannot be known, as the theme does not say that it prints the
/// reference signs.
///
/// -> none | bool
#let shows-text(printed, value, except: ()) = {
  if not _known(printed) { return none }
  let wanted = _wanted((value,))
  if wanted.len() == 0 { return none }
  _search(printed, wanted, except: except)
}
