// Reuses letter address components (absender/empfaenger/geschaeftszeile)
#import "../letter/components.typ": absender_block, empfaenger_block, geschaeftszeile_block

// Import invoice-specific components
#import "components.typ": posten_table, bank_qr_block, kleinunternehmer_notice, build_epc_string

/// A German invoice — with a QR code for tap-to-pay.
///
/// It tallies your line items, shows your bank details,
/// and adds a scannable QR code if you want. Banking apps
/// pick up the IBAN, amount, and reference straight from it.
/// Reuses the letter's address block and ref line.
///
/// - absender (dictionary): your billing details
///   - name (str): your name or company
///   - zusatz (str, none): extra line (e.g. c/o)
///   - strasse (str): street and number
///   - plz_ort (str): zip and city
///   - steuernummer (str): tax number
///   - iban (str): your IBAN
///   - bic (str): BIC (optional)
///   - bank (str): bank name
///   - kontoinhaber (str): account holder — defaults to your name
/// - empfaenger (dictionary): who pays
///   - name (str): name or company
///   - zusatz (str, none): extra line (e.g. c/o)
///   - strasse (str): street and number
///   - plz_ort (str): zip and city
///   - land (str): country (optional)
/// - datum (str): invoice date — defaults to today
/// - rechnungsnummer (str): invoice number
/// - leistungsdatum (str): when you did the work
/// - betreff (str): subject — defaults to "Rechnung"
/// - posten (array): line items as (("What you did", qty, price), ...)
/// - qr (bool): add the QR code?
/// - qr-betrag (none, float): force a QR amount. None = add up the items
/// - qr-verwendungszweck (str): payment note in the QR code
/// - font (str): body font — "Inter" by default
/// - kleinunternehmer (bool): show the § 19 VAT-free note?
/// - body (content): your letter text
#let rechnung(
  absender: (
    name: "Musterfirma GmbH",
    zusatz: none,
    strasse: "Musterstraße 1",
    plz_ort: "12345 Musterstadt",
    steuernummer: "000/000/00000",
    iban: "DE00 0000 0000 0000 0000 00",
    bic: "",
    bank: "Musterbank",
    kontoinhaber: none,
    logo: none,
  ),
  empfaenger: (name: "", zusatz: none, strasse: "", plz_ort: "", land: ""),
  datum: datetime.today().display("[day].[month].[year]"),
  rechnungsnummer: "",
  leistungsdatum: "",
  betreff: "Rechnung",
  posten: (),
  qr: true,
  qr-betrag: none,
  qr-verwendungszweck: "",
  font: "Inter",
  kleinunternehmer: false,
  body
) = {
  let zeilenabstand = 0.65em

  // Ensure optional keys exist in absender and empfaenger (callers may omit them)
  let absender = (telefon: "", email: "", bic: "", zusatz: none, ..absender)
  let empfaenger = (zusatz: none, land: "", ..empfaenger)

  // --- Global styles ---
  set text(font: font, size: 11pt, lang: "de", hyphenate: false, weight: "regular")
  set page(
    "a4",
    margin: (left: 25mm, right: 20mm, top: 25mm, bottom: 25mm),
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
  set par(leading: zeilenabstand, justify: true)
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
    #set text(weight: "bold", size: 11pt)
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
