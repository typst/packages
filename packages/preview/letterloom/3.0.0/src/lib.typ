/// letterloom Core Module
///
/// This module is the single public entry point for the letterloom package.
/// Its only job is orchestration: validate every parameter, apply document-wide
/// Typst settings (page geometry, typography, footnotes), then call the
/// construct-* functions from construct-outputs.typ in the correct order to
/// build the letter body. No layout logic lives here — that belongs in
/// construct-outputs.typ. No validation logic lives here — that belongs in
/// validate-inputs.typ.
#import "validate-inputs.typ": validate-inputs
#import "construct-outputs.typ": *

/// Generates a formatted letter according to the letterloom specification.
///
/// Parameters are grouped below by concern. All required-field parameters
/// default to none; validation will panic if a required field is absent unless
/// it has been removed from `required-fields`.
///
/// Letter content (required by default):
/// - from-name (none, str, or content): Sender's name.
/// - from-address (none, str, or content): Sender's address.
/// - to-name (none, str, or content): Recipient's name.
/// - to-address (none, str, or content): Recipient's address.
/// - date (none, str, or content): Letter date.
/// - salutation (none, str, or content): Opening greeting.
/// - subject (none, str, or content): Subject line.
/// - closing (none, str, or content): Closing phrase.
/// - signatures (none or array): One or more signatory dictionaries.
/// - doc (content): The letter body supplied by the show rule.
///
/// Optional letter elements:
/// - attn-name / attn-label / attn-position: Attention line configuration.
/// - cc / cc-label: Carbon copy recipients and label.
/// - enclosures / enclosures-label: Enclosure list and label.
/// - letterhead (none or dictionary): Letterhead image and layout options.
/// - footer (none or array): Custom footer elements.
///
/// Field requirement control:
/// - required-fields (array): Which of the nine standard fields are mandatory.
///   Remove a field name to make it optional. Defaults to all nine.
///
/// Typography and layout:
/// - signature-alignment (alignment): Alignment for single-signature rows.
/// - paper-size (str): Typst paper size string. Defaults to "a4".
/// - margins (auto or length or dictionary): Page margins. Defaults to auto.
/// - par-leading (length): Line spacing within paragraphs.
/// - par-spacing (length): Spacing between paragraphs.
/// - number-pages (bool): Show page numbers from page 2 onwards.
/// - main-font (str): Body text font family.
/// - main-font-size (length): Body text size.
/// - footer-font (str): Footer text font family.
/// - footer-font-size (length): Footer text size.
/// - footnote-font (str): Footnote text font family.
/// - footnote-font-size (length): Footnote text size.
/// - from-alignment (alignment): Horizontal alignment of the sender block.
/// - date-alignment (alignment): Horizontal alignment of the date.
/// - footnote-alignment (alignment): Alignment of the footnote separator line.
/// - link-color (color): Color applied to hyperlinks.
#let letterloom(
  from-name: none,
  from-address: none,
  to-name: none,
  to-address: none,
  date: none,
  salutation: none,
  subject: none,
  closing: none,
  signatures: none,
  required-fields: ("from-name", "from-address", "to-name", "to-address", "date", "salutation", "subject", "closing", "signatures"),
  signature-alignment: left,
  attn-name: none,
  attn-label: "Attn:",
  attn-position: "above",
  cc: none,
  cc-label: "cc:",
  enclosures: none,
  enclosures-label: "encl:",
  letterhead: none,
  footer: none,
  paper-size: "a4",
  margins: auto,
  par-leading: 0.8em,
  par-spacing: 1.8em,
  number-pages: false,
  main-font: "Libertinus Serif",
  main-font-size: 11pt,
  footer-font: "DejaVu Sans Mono",
  footer-font-size: 9pt,
  footnote-font: "Libertinus Serif",
  footnote-font-size: 7pt,
  from-alignment: right,
  date-alignment: right,
  footnote-alignment: left,
  link-color: blue,
  doc
) = {

  // =========================================================================
  // STEP 1 — VALIDATE INPUTS
  //
  // All parameters are checked before any content is produced. Panics here
  // are intentional: they surface misconfiguration early with a clear message
  // rather than producing a silently malformed letter.
  // =========================================================================
  validate-inputs(
    from-name: from-name,
    from-address: from-address,
    to-name: to-name,
    to-address: to-address,
    date: date,
    salutation: salutation,
    subject: subject,
    closing: closing,
    signatures: signatures,
    required-fields: required-fields,
    signature-alignment: signature-alignment,
    attn-name: attn-name,
    attn-label: attn-label,
    attn-position: attn-position,
    cc: cc,
    cc-label: cc-label,
    enclosures: enclosures,
    enclosures-label: enclosures-label,
    letterhead: letterhead,
    footer: footer,
    par-leading: par-leading,
    par-spacing: par-spacing,
    number-pages: number-pages,
    main-font-size: main-font-size,
    footer-font-size: footer-font-size,
    footnote-font-size: footnote-font-size,
    from-alignment: from-alignment,
    date-alignment: date-alignment,
    footnote-alignment: footnote-alignment,
    link-color: link-color,
  )

  // =========================================================================
  // STEP 2 — APPLY REQUIRED-FIELDS MASK
  //
  // Fields removed from required-fields are treated as absent for rendering
  // purposes, even when the caller supplies a value. Shadowing with none here
  // means every downstream construct-* guard (`if x != none`) naturally
  // suppresses the corresponding block without any special-case logic.
  // =========================================================================
  let opt(field, value) = if field in required-fields { value } else { none }

  let from-name      = opt("from-name",   from-name)
  let from-address   = opt("from-address", from-address)
  let to-name        = opt("to-name",      to-name)
  let to-address     = opt("to-address",   to-address)
  let date           = opt("date",         date)
  let salutation     = opt("salutation",   salutation)
  let subject        = opt("subject",      subject)
  let closing        = opt("closing",      closing)
  let signatures     = opt("signatures",   signatures)

  // =========================================================================
  // STEP 3 — BUILD FOOTER CONTENT
  //
  // The footer is built before the page set rule because Typst evaluates the
  // footer: argument at the point the set rule is applied. Both pieces are
  // combined into a single centred block so the page footer slot holds exactly
  // one content value regardless of which features are active.
  // =========================================================================
  let custom-footer  = construct-custom-footer(
    footer: footer,
    footer-font: footer-font,
    footer-font-size: footer-font-size,
    link-color: link-color,
  )
  let page-numbering = construct-page-numbering(number-pages: number-pages)

  // =========================================================================
  // STEP 4 — APPLY DOCUMENT-WIDE TYPST SETTINGS
  //
  // These set/show rules govern the entire document that follows. Order
  // matters: later rules can override earlier ones within the same scope.
  // =========================================================================

  // Page geometry and footer slot
  set page(
    paper: paper-size,
    margin: margins,
    footer: align(center, custom-footer + page-numbering),
  )

  // Body typeface and size
  set text(
    font: main-font,
    size: main-font-size,
  )

  // Paragraph rhythm — leading controls line spacing within a paragraph,
  // spacing controls the gap between consecutive paragraphs
  set par(
    leading: par-leading,
    spacing: par-spacing,
  )

  // Hyperlink color
  show link: set text(fill: link-color)

  // Footnote separator: a short rule aligned to footnote-alignment
  set footnote.entry(separator: align(footnote-alignment, line(length: 30% + 0pt, stroke: 0.5pt)))

  // Footnote body: apply the dedicated footnote typeface and size
  show footnote.entry: it => {
    set align(footnote-alignment)
    set text(font: footnote-font, size: footnote-font-size)
    it
  }

  // =========================================================================
  // STEP 5 — RENDER LETTER COMPONENTS IN ORDER
  //
  // construct-header decides internally whether the sender is embedded inside
  // the letterhead zone or placed in the normal document flow below the image.
  //
  // construct-date needs to know whether the sender was embedded so it can
  // skip width-matching against the sender block. When sender-position is
  // center the sender is placed absolutely and is not in the flow, so passing
  // none for from-name/from-address tells construct-date to align independently.
  //
  // doc (the letter body) sits between the opening block and the closing block
  // so user content flows naturally in the middle of the letter.
  // =========================================================================

  // Header: letterhead image + sender address (placement decided inside)
  construct-header(
    letterhead: letterhead,
    from-name: from-name,
    from-address: from-address,
    from-alignment: from-alignment,
  )

  // Date: conditionally width-matched to the sender block
  let lh-sender-pos = if letterhead != none { letterhead.at("sender-position", default: none) } else { none }
  let (date-from-name, date-from-address) = if lh-sender-pos == center { (none, none) } else { (from-name, from-address) }
  construct-date(
    date: date,
    date-alignment: date-alignment,
    from-alignment: from-alignment,
    from-name: date-from-name,
    from-address: date-from-address,
  )

  // Recipient block, salutation, and subject line
  construct-recipient(
    to-name: to-name,
    to-address: to-address,
    attn-name: attn-name,
    attn-label: attn-label,
    attn-position: attn-position,
  )
  construct-salutation(salutation: salutation)
  construct-subject(subject: subject)

  // Letter body supplied by the caller via the show rule
  doc

  // Closing, signatures, cc, and enclosures follow the body
  construct-closing(closing: closing)
  construct-signatures(signatures: signatures, signature-alignment: signature-alignment)
  construct-cc(cc: cc, cc-label: cc-label)
  construct-enclosures(enclosures: enclosures, enclosures-label: enclosures-label)
}
