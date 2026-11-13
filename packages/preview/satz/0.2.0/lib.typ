// Satz public API — templates, shared document layout, and authoring components.

/// Satz document toolkit for Typst.
///
/// Templates share one deep-merged configuration system. Import the template
/// you need from this entry point, for example:
///
/// ```typst
/// #import "@preview/satz:0.2.0" as satz
/// #show: satz.report.with(config: (typography: (font: "EB Garamond"),))
/// = Introduction
/// ```
/// For the shared config fields and baseline values, hover `satz.defaults` in
/// the editor. The same import exposes templates such as `satz.report`.
///
/// English argument names are canonical. Some templates retain German
/// compatibility aliases; the letter interface uses English names. Covers are
/// optional components: pass shared `theme` and `config` explicitly when a
/// cover should match a document. Document templates default to the neutral
/// black-on-white palette; pass `theme: "slate"` to use the former blue-gray
/// shared palette, now available as a named theme.
#import "letter/template.typ": brief as _render-letter
/// A DIN 5008-style letter with optional postal and digital components.
///
/// English names are the canonical interface. The postal layout is the default;
/// for a screen-only PDF, combine `digital-sender`, `address-window: false`, and
/// `fold-marks: false`.
///
/// ```example
/// #show: letter.with(
///   sender: (name: "Alex Example", street: "Example Street 1", postal-code-city: "12345 Example City"),
///   recipient: (name: "Research Office", street: "Sample Road 2", postal-code-city: "54321 Sample City"),
///   date: "2026-10-27",
///   subject: "Appointment request",
///   language: "en",
/// )
/// Dear Research Office,
///
/// Could we arrange an appointment?
/// ```
///
/// - sender (dictionary): your details
///   - name (str): your name or company
///   - care-of (str, none): extra line such as c/o
///   - street (str): street and number
///   - postal-code-city (str): postal code and city
///   - phone (str): phone number; optional
///   - email (str): email address; optional
///   - website (str): website without `https://`; optional, digital sender only
///   - logo (none, content): logo content such as `image("logo.pdf", width: 3cm)`
/// - recipient (dictionary): who receives the letter; accepts `name`, `care-of`,
///   `street`, `postal-code-city`, and the optional `country`
/// - date (str, none): date text. Omitting it uses the compilation date formatted
///   as `YYYY-MM-DD`; set an explicit date for reproducible correspondence.
///   `none` does not hide the date—use `show-date: false` for that.
/// - show-date-label (bool): show the `Date`/`Datum` label above the date;
///   defaults to true
/// - subject (str): subject line; defaults to an empty line
/// - reference-line (array): one `(label, value)` pair or an array of pairs
/// - enclosure-list (array): enclosure names to print without embedding files
/// - attachments (array): PDF path strings to embed after the letter
/// - postal-mark (str): postal note such as "Registered mail"
/// - signature-addition (str): title or department below the signer name
/// - language (str): `"de"` (default) or `"en"`; controls labels and Typst language
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): appearance overrides for `page.paper`, `page.margin`,
///   `typography.font`, `size`, `leading`, `justify`, and `hyphenate`;
///   `colors.bg-paper`, `brand-primary`, and `text-main`; and `links.color` and
///   `url-color`. Unknown groups or keys are rejected. For example:
///   `config: (typography: (font: "STIX Two Text", size: 10pt), page: (paper: "a4"))`.
///   Defaults are A4, Inter 11pt, 0.65em leading, justified text, and the
///   neutral letter palette; the `config` argument accepts only the keys above.
/// - font (str): body font family; defaults to `"Inter"`
/// - signature (bool): include the signing rule and sender name; defaults to true
/// - fold-marks (bool): include two fold marks and one punch mark; defaults to true
/// - address-window (bool): use the window-envelope recipient field; defaults to true
/// - page-numbers (bool): show continuation-page numbers; defaults to true
/// - digital-sender (bool): use the compact digital sender header; defaults to false
/// - date-right (bool): use the standalone right-aligned date when no reference
///   fields exist; defaults to true
/// - justify (bool): justify body paragraphs; defaults to true
/// - show-sender (bool), show-recipient (bool), show-date (bool),
///   show-subject (bool): include those blocks; all default to true. Hiding the
///   date does not hide separately supplied reference-line fields.
/// - paper (str, dictionary): page size; defaults to `"a4"`. A dictionary with
///   `width` and `height` supplies a custom page size.
/// - margins (dictionary): page margins; partial overrides are allowed
/// - font-size (length): body text size; defaults to `11pt`
/// - line-spacing (length): body leading and the basis for default block gaps;
///   defaults to `0.65em`
/// - block-spacing (dictionary): overrides for `sender-recipient`,
///   `sender-date`, `sender-subject`, `sender-body`, `recipient-date`,
///   `recipient-subject`, `recipient-body`, `date-subject`, `subject-body`,
///   `date-body`, and `signature` gaps, including the matching gaps used when
///   earlier blocks are hidden
/// - subject-size (length): subject text size; defaults to `11.5pt`
/// - digital-sender-height (length): reserved digital header height; defaults to `19mm`
/// - body (content): the letter text, including salutation and closing
///
#let letter(
  body,
  sender: none,
  recipient: none,
  date: none,
  show-date-label: none,
  reference-line: none,
  subject: none,
  enclosure-list: none,
  attachments: none,
  signature-addition: none,
  postal-mark: none,
  language: none,
  signature: none,
  fold-marks: none,
  address-window: none,
  page-numbers: none,
  digital-sender: none,
  date-right: none,
  justify: none,
  show-sender: none,
  show-recipient: none,
  show-date: none,
  show-subject: none,
  paper: none,
  margins: none,
  font-size: none,
  line-spacing: none,
  block-spacing: none,
  subject-size: none,
  digital-sender-height: none,
  theme: "neutral",
  config: (:),
  font: "Inter",
) = {
  for (record, forbidden) in (
    (sender, ("zusatz", "strasse", "plz_ort", "telefon")),
    (recipient, ("zusatz", "strasse", "plz_ort", "land")),
    (block-spacing, ("absender_empfaenger", "absender_datum", "absender_betreff", "absender_text", "empfaenger_datum", "empfaenger_betreff", "empfaenger_text", "datum_betreff", "betreff_text", "datum_text", "signatur")),
  ) {
    if type(record) == dictionary {
      assert(not forbidden.any(key => key in record),
        message: "Letter records and spacing use English field names; see the letter documentation.")
    }
  }
  _render-letter(
    sender: sender,
    recipient: recipient,
    date: date,
    show-date-label: show-date-label,
    reference-line: reference-line,
    subject: subject,
    enclosure-list: enclosure-list,
    attachments: attachments,
    signature-addition: signature-addition,
    postal-mark: postal-mark,
    language: language,
    signature: signature,
    fold-marks: fold-marks,
    address-window: address-window,
    page-numbers: page-numbers,
    digital-sender: digital-sender,
    date-right: date-right,
    justify: justify,
    show-sender: show-sender,
    show-recipient: show-recipient,
    show-date: show-date,
    show-subject: show-subject,
    paper: paper,
    margins: margins,
    font-size: font-size,
    line-spacing: line-spacing,
    block-spacing: block-spacing,
    subject-size: subject-size,
    digital-sender-height: digital-sender-height,
    theme: theme,
    config: config,
    font: font,
    body,
  )
}
#import "invoice/rechnung.typ": rechnung
/// A German invoice with an optional EPC QR code for bank transfers.
///
/// English names are the canonical interface; German argument names remain as
/// compatibility aliases. The rendered invoice stays German.
///
/// It totals line items, prints your bank details, and optionally adds a
/// scannable EPC QR code. Banking apps read the IBAN, amount, and payment
/// reference from that code. The letter's postal address components and
/// reference-line layout are reused.
///
/// ```example
/// #show: invoice.with(
///   sender: (
///     name: "Example Studio",
///     street: "Example Street 1",
///     postal-code-city: "12345 Example City",
///     tax-number: "000/000/00000",
///     iban: "DE00 0000 0000 0000 0000 00",
///     bank: "Example Bank",
///   ),
///   recipient: (
///     name: "Sample Client",
///     street: "Sample Road 2",
///     postal-code-city: "54321 Sample City",
///   ),
///   date: "2026-10-27",
///   invoice-number: "2026-001",
///   service-date: "2026-10-20",
///   items: (("Example service", 1, 500)),
///   qr-purpose: "Invoice 2026-001",
/// )
/// ```
///
/// - sender (dictionary): billing details
///   - name (str): your name or company
///   - care-of (str, none): extra line such as c/o
///   - street (str): street and number
///   - postal-code-city (str): postal code and city
///   - tax-number (str): German tax number (`steuernummer`)
///   - iban (str): account IBAN
///   - bic (str): BIC; optional, defaults to empty
///   - bank (str): bank name
///   - account-holder (str, none): account holder; defaults to `name`
/// - recipient (dictionary): who pays; accepts `name`, `care-of`, `street`,
///   `postal-code-city`, and the optional `country`
/// - date (str, none): invoice date. Omitting it uses the compilation date as
///   `DD.MM.YYYY`; set an explicit date for reproducible invoices
/// - invoice-number (str): invoice number; defaults to empty
/// - service-date (str): date the service was performed; defaults to empty
/// - subject (str): subject line; defaults to `"Rechnung"`
/// - items (array): tuples `(description, quantity, unit-price)` or records
///   with `description`, `quantity`, and `unit-price` keys
/// - qr (bool): show the EPC QR code; defaults to true
/// - qr-amount (int, float, none): override the QR amount; `none` totals the items
/// - qr-purpose (str): payment reference shown in the QR code; defaults to empty
/// - small-business (bool): show the § 19 small-business VAT note; defaults to false
/// - font (str): body font family; defaults to `"Inter"`
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): appearance overrides for `page.paper`, `page.margin`,
///   core `typography`, `colors`, and `links`; unknown groups or keys are rejected.
///   For example, `config: (typography: (font: "STIX Two Text", size: 10pt),
///   colors: (brand-primary: blue))`. Defaults are A4, Inter 11pt, and the
///   neutral invoice palette. Use `typography.font` for text; math-font is not
///   supported by this postal template's restricted appearance config.
/// - body (content): introductory invoice text before the line-item table
///
/// German aliases: `absender`, `empfaenger`, `datum`, `rechnungsnummer`,
/// `leistungsdatum`, `betreff`, `posten`, `qr-betrag`, `qr-verwendungszweck`,
/// and `kleinunternehmer`. German nested sender fields are `zusatz`, `strasse`,
/// `plz_ort`, `steuernummer`, and `kontoinhaber`. Supplying both spellings of
/// the same value produces a field-specific conflict error.
#let invoice = rechnung
#import "dfg-proposal/dfg.typ": dfg-proposal, dfg-supplement, dfg-publications
#import "proposal/template.typ": research-proposal, project-proposal
#import "proposal/components.typ": proposal-budget
#import "proposal/planning.typ": proposal-gantt, work-package
#import "proposal/citations.typ": proposal-citations, proposal-publications
#import "legal-complaint/template.typ": klageschrift
/// A German civil complaint (*Klageschrift*) for the Amtsgericht.
///
/// English names are the canonical interface; German argument names remain as
/// compatibility aliases. The rendered complaint stays German. It provides the
/// Rubrum, Streitwert, a place for your claims and reasoning, the signature
/// block, and the exhibit list. The layout uses a wider right margin for the
/// court file.
///
/// ```example
/// #show: complaint.with(
///   court: "Amtsgericht Musterstadt",
///   court-address: "Gerichtsstraße 1, 12345 Musterstadt",
///   plaintiff: "Alex Example",
///   plaintiff-street: "Example Street 1",
///   plaintiff-postal-code-city: "12345 Example City",
///   defendant: "Robin Sample",
///   defendant-street: "Sample Road 2",
///   defendant-postal-code-city: "54321 Sample City",
///   amount-in-dispute: "1.000,00 EUR",
///   exhibits: ("Exhibit K 1: Contract",),
/// )
/// = Anträge
/// ...
/// ```
///
/// - court (str): court name; defaults to `"Amtsgericht"`
/// - court-address (str): court street and postal code; defaults to empty
/// - plaintiff (str): party bringing the claim; defaults to empty
/// - plaintiff-street (str): plaintiff street and number; defaults to empty
/// - plaintiff-postal-code-city (str): plaintiff postal code and city; defaults to empty
/// - defendant (str): party being sued; defaults to empty
/// - defendant-street (str): defendant street and number; defaults to empty
/// - defendant-postal-code-city (str): defendant postal code and city; defaults to empty
/// - amount-in-dispute (str): Streitwert as display text, e.g. `"600,00 EUR"`; defaults to empty
/// - exhibits (array of str): exhibit labels for the Anlagenverzeichnis; defaults to empty
/// - exhibits-pdf (str, none): PDF to append after the complaint; `none` skips it
/// - exhibit-page-limit (int): maximum PDF pages to append; defaults to 30. This
///   is not a truncation limit, so it must not exceed the PDF's actual page count
/// - date (str, none): filing date. Omitting it uses the compilation date as
///   `DD.MM.YYYY`; set it explicitly for a reproducible filing
/// - plaintiff-designation (str): signature-block role; defaults to `"Kläger/in"`
/// - font (str): body font family; defaults to `"Inter"`
/// - body (content): claims and reasoning after the Anträge heading
///
/// German aliases: `gericht`, `gericht_ort`, `klagername`, `klagerin_str`,
/// `klagerin_plz`, `beklagter`, `beklagter_str`, `beklagter_plz`, `streitwert`,
/// `anlagen`, `anlagen_pdf_path`, `anlagen_max_pages`, and `datum`. Supplying
/// both spellings of the same value produces a field-specific conflict error.
#let complaint = klageschrift
#import "gastspielvertrag/template.typ": gastspielvertrag
/// A German guest-performance contract with fill-in fields.
///
/// English names are the canonical interface; German argument names remain as
/// compatibility aliases. The rendered contract stays German.
///
/// `document-type` chooses the form:
/// - `"vertrag"`: full contract with all §§ and signature lines
/// - `"angebot"`: offer without signatures, titled "Kostenvoranschlag"
/// - `"rechnung"`: invoice title only; no §§, fee table, signature lines, or
///   `body`. Use `invoice()` from Satz for a real invoice.
///
/// Empty fields render as underlines for handwriting or a PDF editor. The
/// default artist details are placeholders and should always be replaced.
///
/// ```example
/// #show: gastspielvertrag.with(
///   document-type: "vertrag",
///   artist: "Alex Example",
///   artist-representative: "Alex Example",
///   artist-address: "Example Street 1, 12345 Example City",
///   event: "Example concert",
///   venue: "Example Hall",
///   date: "15.03.2026",
///   fixed-fee: 800,
///   travel-km: 120,
/// )
/// ```
///
/// - document-type (str): `"vertrag"`, `"angebot"`, or `"rechnung"`; defaults to `"vertrag"`
/// - artist (str): artist or band name
/// - artist-representative (str): person signing for the artist
/// - artist-address (str): artist postal address
/// - event (str): event description; defaults to empty
/// - venue (str): venue name and city; defaults to empty
/// - date (str): performance date as display text; defaults to empty
/// - performance-time (str): stage time; defaults to empty
/// - performance-duration (str): set length; defaults to empty
/// - doors (str): door-opening time; defaults to empty
/// - curfew (str): latest permitted end time; defaults to empty
/// - musicians (int): number of musicians; defaults to 4
/// - technician (bool): whether a technician is included; defaults to true
/// - photographer (bool): whether a photographer is included; defaults to false
/// - fee-type (str): `"fest"` for a fixed fee or `"prozent"` for a percentage;
///   defaults to `"fest"`
/// - fixed-fee (int): fixed fee in EUR, used only when `fee-type` is `"fest"`;
///   defaults to 0
/// - percentage (int): artist share of ticket sales, 0–100; defaults to 80
/// - minimum-fee (int): guaranteed minimum fee in EUR; defaults to 0
/// - small-business (bool): show the § 19 small-business VAT note. Defaults to
///   true; set false when you charge VAT.
/// - travel-km (int): one-way travel distance in km; 0 disables travel costs.
///   The calculated fee uses the round trip (`km × rate × 2`).
/// - travel-rate (int, float): EUR per km; defaults to 0.30
/// - technician-fee (int): technician fee in EUR; 0 disables it
/// - accommodation (int): accommodation cost in EUR; 0 disables it
/// - other-description (str): label for an additional cost
/// - other-amount (int): amount for that additional cost in EUR
/// - buyout-per-person (int): hospitality buy-out in EUR per person; defaults to 15
/// - font (str): body font family; defaults to `"Inter"`
/// - body (content): extra clauses after § 8; ignored in `"rechnung"` mode
///
/// German aliases: `dokument`, `kuenstler`, `kuenstler_vertreter`,
/// `kuenstler_anschrift`, `veranstaltung`, `datum`, `auftrittszeit`,
/// `auftrittsdauer`, `einlass`, `musiker`, `techniker`, `fotograf`,
/// `gage_typ`, `festgage`, `prozentsatz`, `mindestgage`, `kleinunternehmer`,
/// `transport_km`, `transport_satz`, `techniker_honorar`, `uebernachtung`,
/// `sonstiges_text`, `sonstiges_betrag`, and `buyout_pro_person`.
/// `venue` is the English name for `location`. Supplying both spellings of the
/// same value produces a field-specific conflict error.
#let guest-contract = gastspielvertrag
#import "journal/template.typ": journal-entry, journal-index, remember, question
#import "defaults.typ": defaults, merge
#import "report/template.typ": report
#import "article/template.typ": article
#import "book/template.typ": book, book-contents, book-mainmatter, book-appendix, book-backmatter, book-index
#import "book/components.typ": exercise, worked-example, analysis-note, answer-grid
#import "cover.typ": cover-page, cover-themes, research-cover, minimal-cover
#import "themes.typ": document-themes, theme-config
#import "class.typ": custom, satz-figure
#import "citation.typ": citepre
#import "figures.typ": placeholder
// Optional author-facing glossary API; setup stays explicit in the document.
#import "@preview/glossarium:0.5.10"
#import "tables.typ": scientific-table, scientific-tables
#import "callouts.typ": callout
#import "chapter-numbering.typ": chapter-numbering
#import "headings.typ": unnumbered-heading

#import "nwo-proposal/template.typ": nwo-proposal
#import "nwo-proposal/profiles.typ": nwo-profile
#import "nwo-proposal/components.typ": nwo-text, nwo-key-output, nwo-page-budget
