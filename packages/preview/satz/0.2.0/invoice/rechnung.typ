// Reuses letter address components (absender/empfaenger/geschaeftszeile)
#import "../letter/components.typ": absender_block, empfaenger_block, geschaeftszeile_block
#import "../input.typ": normalize-record, normalize-invoice-items, select-alias, validate-postal-record
#import "../defaults.typ": defaults as shared-defaults, merge
#import "../appearance.typ": resolve-postal-appearance

// Import invoice-specific components
#import "components.typ": posten_table, bank_qr_block, kleinunternehmer_notice, build_epc_string

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
#let rechnung(
  absender: none,
  empfaenger: none,
  datum: none,
  rechnungsnummer: none,
  leistungsdatum: none,
  betreff: none,
  posten: none,
  sender: none,
  recipient: none,
  date: none,
  invoice-number: none,
  service-date: none,
  subject: none,
  items: none,
  qr: true,
  qr-betrag: none,
  qr-amount: none,
  qr-verwendungszweck: none,
  qr-purpose: none,
  font: "Inter",
  kleinunternehmer: none,
  small-business: none,
  theme: "neutral",
  config: (:),
  body
) = {
  assert(type(config) == dictionary, message: "Invoice config must be a dictionary.")
  let absender = normalize-record(
    absender,
    sender,
    (name: "name", care-of: "zusatz", street: "strasse", postal-code-city: "plz_ort", phone: "telefon", tax-number: "steuernummer", account-holder: "kontoinhaber"),
    (name: "Musterfirma GmbH", zusatz: none, strasse: "Musterstraße 1", plz_ort: "12345 Musterstadt", steuernummer: "000/000/00000", iban: "DE00 0000 0000 0000 0000 00", bic: "", bank: "Musterbank", kontoinhaber: none, logo: none),
    "sender",
  )
  let empfaenger = normalize-record(
    empfaenger,
    recipient,
    (name: "name", care-of: "zusatz", street: "strasse", postal-code-city: "plz_ort", country: "land"),
    (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
    "recipient",
  )
  validate-postal-record(absender, "Sender", ("name", "strasse", "plz_ort", "steuernummer", "iban", "bic", "bank"), nullable-fields: ("zusatz", "kontoinhaber"), content-fields: ("logo",))
  validate-postal-record(empfaenger, "Recipient", ("name", "strasse", "plz_ort", "land"), nullable-fields: ("zusatz",))
  let datum = select-alias(datum, date, "datum", "date", datetime.today().display("[day].[month].[year]"))
  let rechnungsnummer = select-alias(rechnungsnummer, invoice-number, "rechnungsnummer", "invoice-number", "")
  let leistungsdatum = select-alias(leistungsdatum, service-date, "leistungsdatum", "service-date", "")
  let betreff = select-alias(betreff, subject, "betreff", "subject", "Rechnung")
  let posten = normalize-invoice-items(select-alias(posten, items, "posten", "items", ()))
  let qr-betrag = select-alias(qr-betrag, qr-amount, "qr-betrag", "qr-amount", none)
  let qr-verwendungszweck = select-alias(qr-verwendungszweck, qr-purpose, "qr-verwendungszweck", "qr-purpose", "")
  let kleinunternehmer = select-alias(kleinunternehmer, small-business, "kleinunternehmer", "small-business", false)
  assert(type(datum) == str and type(rechnungsnummer) == str and type(leistungsdatum) == str and type(betreff) == str,
    message: "Invoice date, invoice-number, service-date and subject fields must be strings.")
  assert(type(qr) == bool, message: "Invoice qr option must be a boolean.")
  assert(type(kleinunternehmer) == bool, message: "Invoice small-business option must be a boolean.")
  assert(qr-betrag == none or ((type(qr-betrag) == int or type(qr-betrag) == float) and qr-betrag >= 0),
    message: "Invoice qr-amount must be a nonnegative number or none.")
  assert(type(qr-verwendungszweck) == str, message: "Invoice qr-purpose must be a string.")
  let appearance-defaults = merge(shared-defaults, (
    page: (paper: "a4", margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm)),
    typography: (font: "Inter", size: 11pt, leading: 0.65em, justify: true, hyphenate: false),
    colors: (brand-primary: black, text-main: black),
  ))
  let c = resolve-postal-appearance(
    appearance-defaults,
    theme,
    (typography: (font: font)),
    config,
  )
  let zeilenabstand = c.typography.leading

  // --- Global styles ---
  set text(font: c.typography.font, size: c.typography.size, lang: "de", hyphenate: c.typography.hyphenate, fill: c.colors.text-main, weight: "regular")
  set par(leading: c.typography.leading, justify: c.typography.justify)
  set page(
    c.page.paper,
    margin: c.page.margin,
    fill: c.colors.bg-paper,
    background: context {
      if counter(page).get().first() == 1 [
        #place(top + left, dx: 0mm, dy: 0mm)[
          #place(top + left, dx: 2.5mm, dy: 105mm)[#line(length: 5mm, stroke: 0.25pt + black)]
          #place(top + left, dx: 2.5mm, dy: 148.5mm)[#line(length: 7mm, stroke: 0.25pt + black)]
          #place(top + left, dx: 2.5mm, dy: 210mm)[#line(length: 5mm, stroke: 0.25pt + black)]
        ]
      ]
    },
  )
  show link: it => text(fill: if type(it.dest) == str { c.links.url-color } else { c.links.color }, underline(it))
  set par(leading: zeilenabstand, justify: c.typography.justify)
  set list(spacing: zeilenabstand)

  // --- Sender block (top-right) ---
  absender_block(absender, zeilenabstand, (tel: "Tel.", email: "E-Mail"))
  v(3 * zeilenabstand)

  // --- Recipient (window envelope field, shared with letter) ---
  // The letter's empfaenger_block takes (absender, empfaenger, postvermerk, strings).
  // Invoice: no postal remark, no i18n — pass empty postvermerk and dummy strings.
  empfaenger_block(absender, empfaenger, "", (:))
  v(4 * zeilenabstand)

  // --- Business reference line (shared with letter) ---
  geschaeftszeile_block(
    (
      ("Rechnungsnummer", rechnungsnummer),
      ("Leistungsdatum", leistungsdatum),
      ("Steuernummer", absender.steuernummer),
    ),
    datum,
    zeilenabstand,
    (datum: "Datum"),
  )
  v(2 * zeilenabstand)

  // --- Subject ---
  block(width: 100%)[
    #set text(weight: "bold", size: c.typography.size, fill: c.colors.brand-primary)
    #betreff
  ]
  v(2 * zeilenabstand)

  // --- Body ---
  body
  v(2 * zeilenabstand)

  // --- Line item table ---
  posten_table(posten)

  // --- Kleinunternehmer notice ---
  if kleinunternehmer {
    kleinunternehmer_notice(zeilenabstand)
  }

  // --- Bank details + QR code ---
  let qr-amount = if qr-betrag != none {
    qr-betrag
  } else if posten.len() > 0 {
    posten.map(p => p.at(1) * p.at(2)).sum()
  } else {
    0
  }
  let kontoinhaber = if absender.at("kontoinhaber", default: none) != none {
    absender.kontoinhaber
  } else {
    absender.name
  }
  let epc-string = build_epc_string(kontoinhaber, absender.at("bic", default: ""), absender.iban, qr-amount, qr-verwendungszweck)
  bank_qr_block(absender, qr, epc-string, zeilenabstand)

  [Mit freundlichen Grüßen]
  v(-1*zeilenabstand)
  absender.name

}
