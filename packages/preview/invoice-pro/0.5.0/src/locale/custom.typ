// Every function below returns its patch as an array of one dictionary, so
// that several of them in one code block join into a list of patches (two
// dictionaries would be merged, and the second `strings` would replace the
// first). `build-locale` applies the patches in their order.

/// Internal helper to remove unconfigured (`auto`) arguments.
/// This guarantees that we only patch fields the user explicitly defined,
/// preventing base translations from being overwritten by `auto`.
#let _clean-auto(d) = {
  let res = (:)
  for (k, v) in d {
    if v != auto { res.insert(k, v) }
  }
  return res
}


// -----------------------------------------------------------------------------
// LANGUAGE OVERRIDES (string.*)
// -----------------------------------------------------------------------------

/// Customizes the document type designations, the default titles of the
/// document types (`invoice(document-type: ..)`).
/// - invoice (auto, str): e.g., "Invoice", "Rechnung"
/// - credit-note (auto, str): e.g., "Credit Note", "Rechnungskorrektur"
/// - corrected (auto, str): e.g., "Corrected Invoice", "Korrigierte Rechnung"
/// - prepayment (auto, str): e.g., "Prepayment Invoice", "Anzahlungsrechnung"
/// - self-billed (auto, str): e.g., "Self-Billing Invoice", "Gutschrift"
/// -> array
#let document(
  invoice: auto,
  credit-note: auto,
  corrected: auto,
  prepayment: auto,
  self-billed: auto,
) = (
  {
    let payload = _clean-auto((
      invoice: invoice,
      credit-note: credit-note,
      corrected: corrected,
      prepayment: prepayment,
      self-billed: self-billed,
    ))
    (strings: (document: payload))
  },
)

/// Customizes the address-related labels.
/// - recipient (auto, str): e.g., "Bill To", "Empfänger"
/// - sender (auto, str): e.g., "From", "Absender"
/// -> array
#let address(recipient: auto, sender: auto) = (
  {
    let payload = _clean-auto((recipient: recipient, sender: sender))
    (strings: (address: payload))
  },
)

/// Customizes the metadata and reference numbers labels.
/// - tax-number (auto, str): e.g., "Tax ID", "Steuernummer"
/// - invoice-number (auto, str): e.g., "Invoice Number", "Rechnungsnummer"
/// - vat-id (auto, str): e.g., "VAT ID", "USt-IdNr."
/// - invoice-date (auto, str): e.g., "Invoice Date", "Rechnungsdatum"
/// - service-time (auto, str): e.g., "Period of Service", "Leistungszeitraum"
/// - customer-number (auto, str): e.g., "Customer No.", "Kundennummer"
/// - buyer-reference (auto, str): e.g., "Buyer Reference", "Leitweg-ID"
/// - recipient-vat-id (auto, str): e.g., "Buyer VAT ID", "Ihre USt-IdNr."
/// - recipient-tax-number (auto, str): e.g., "Buyer Tax ID", "Ihre Steuernummer"
/// - order-number (auto, str): e.g., "Order No.", "Bestellnummer"
/// - order-date (auto, str): e.g., "Order Date", "Bestelldatum"
/// - project (auto, str): e.g., "Project", "Projekt"
/// - contract-number (auto, str): e.g., "Contract No.", "Vertragsnummer"
/// - quote-number (auto, str): e.g., "Quote No.", "Angebotsnummer"
/// - delivery-note-number (auto, str): e.g., "Delivery Note No.", "Lieferschein-Nr."
/// - preceding-invoice-number (auto, str): e.g., "Preceding Invoice No.", "Vorherige Rechnungsnummer"
/// - preceding-invoice-date (auto, str): e.g., "Preceding Invoice Date", "Datum der vorherigen Rechnung"
/// - due-date (auto, str): e.g., "Due Date", "Zahlbar bis"
/// - payment-reference (auto, str): e.g., "Payment Reference", "Verwendungszweck"
/// - contact-person (auto, str): e.g., "Contact Person", "Ansprechpartner:in"
/// - contact-phone (auto, str): e.g., "Phone", "Telefon"
/// - contact-email (auto, str): e.g., "Email", "E-Mail"
/// - payee (auto, str): who receives the payment instead of the sender,
///   e.g., "Payee", "Zahlungsempfänger"
/// -> array
#let reference(
  tax-number: auto,
  invoice-number: auto,
  vat-id: auto,
  invoice-date: auto,
  service-time: auto,
  customer-number: auto,
  buyer-reference: auto,
  recipient-vat-id: auto,
  recipient-tax-number: auto,
  order-number: auto,
  order-date: auto,
  project: auto,
  contract-number: auto,
  quote-number: auto,
  delivery-note-number: auto,
  delivery-address: auto,
  preceding-invoice-number: auto,
  preceding-invoice-date: auto,
  due-date: auto,
  payment-reference: auto,
  contact-person: auto,
  contact-phone: auto,
  contact-email: auto,
  payee: auto,
) = (
  {
    let payload = _clean-auto((
      tax-number: tax-number,
      invoice-number: invoice-number,
      vat-id: vat-id,
      invoice-date: invoice-date,
      service-time: service-time,
      customer-number: customer-number,
      buyer-reference: buyer-reference,
      recipient-vat-id: recipient-vat-id,
      recipient-tax-number: recipient-tax-number,
      order-number: order-number,
      order-date: order-date,
      project: project,
      contract-number: contract-number,
      quote-number: quote-number,
      delivery-note-number: delivery-note-number,
      delivery-address: delivery-address,
      preceding-invoice-number: preceding-invoice-number,
      preceding-invoice-date: preceding-invoice-date,
      due-date: due-date,
      payment-reference: payment-reference,
      contact-person: contact-person,
      contact-phone: contact-phone,
      contact-email: contact-email,
      payee: payee,
    ))
    (strings: (reference: payload))
  },
)

/// Customizes the headers and labels used in the invoice line-items table.
///
/// - position (auto, str): e.g., "Pos", "Item", "No."
/// - description (auto, str): e.g., "Description", "Beschreibung"
/// - quantity (auto, str): e.g., "Qty", "Menge"
/// - unit-price (auto, str): e.g., "Unit Price", "Einzelpreis"
/// - price (auto, str): e.g., "Price", "Preis"
/// - total (auto, str): e.g., "Total", "Gesamt"
/// - vat (auto, str): e.g., "Tax", "USt."
/// - net (auto, str): e.g., "net", "netto"
/// - gross (auto, str): e.g., "gross", "brutto"
/// - discount (auto, str): e.g., "Discount", "Rabatt"
/// - surcharge (auto, str): e.g., "Surcharge", "Zuschlag"
/// - subtotal (auto, str): e.g., "Subtotal", "Zwischensumme"
/// - conjunction (auto, str): joins the last two item names of an automatic
///   bundle description, e.g., "and", "und"
/// - origin (auto, str): label of the country of origin of an item, e.g.,
///   "Country of origin", "Ursprungsland"
/// -> array
#let line-items(
  position: auto,
  description: auto,
  quantity: auto,
  unit-price: auto,
  price: auto,
  total: auto,
  vat: auto,
  net: auto,
  gross: auto,
  discount: auto,
  surcharge: auto,
  subtotal: auto,
  conjunction: auto,
  origin: auto,
) = (
  {
    let payload = _clean-auto((
      position: position,
      description: description,
      quantity: quantity,
      unit-price: unit-price,
      price: price,
      total: total,
      vat: vat,
      net: net,
      gross: gross,
      discount: discount,
      surcharge: surcharge,
      subtotal: subtotal,
      conjunction: conjunction,
      origin: origin,
    ))

    (strings: (line-items: payload))
  },
)

/// Customizes the summary and total labels at the bottom of the table.
/// - sum (auto, str): e.g., "Subtotal", "Summe"
/// - vat-tax (auto, str): e.g., "Tax", "Umsatzsteuer"
/// - total (auto, str): e.g., "Total", "Gesamtbetrag"
/// - including (auto, str): e.g., "incl.", "inkl."
/// - excluding (auto, str): e.g., "excl.", "zzgl."
/// -> array
#let summary(
  sum: auto,
  vat-tax: auto,
  total: auto,
  including: auto,
  excluding: auto,
) = (
  {
    let payload = _clean-auto((
      sum: sum,
      vat-tax: vat-tax,
      total: total,
      including: including,
      excluding: excluding,
    ))
    (strings: (summary: payload))
  },
)

/// Customizes global informational sentences.
/// - tax-statement (auto, fn): Function for tax rate sentence
/// - unit (auto, str): Unit label
/// - quantity (auto, str): Quantity label
/// - date (auto, str): Service date label
#let global-info(
  tax-statement: auto,
  unit: auto,
  quantity: auto,
  date: auto,
) = (
  {
    let payload = _clean-auto((
      tax-statement: tax-statement,
      unit: unit,
      quantity: quantity,
      date: date,
    ))
    (strings: (global-info: payload))
  },
)

/// Customizes the bank detail labels.
/// - account-holder (auto, str): e.g., "Account Holder", "Kontoinhaber"
/// - bank (auto, str): e.g., "Bank", "Kreditinstitut"
/// - iban (auto, str): e.g., "IBAN"
/// - bic (auto, str): e.g., "BIC"
/// - reference (auto, str): e.g., "Reference", "Verwendungszweck"
/// -> array
#let bank-details(
  account-holder: auto,
  bank: auto,
  iban: auto,
  bic: auto,
  reference: auto,
) = (
  {
    let payload = _clean-auto((
      account-holder: account-holder,
      bank: bank,
      iban: iban,
      bic: bic,
      reference: reference,
    ))
    (strings: (bank-details: payload))
  },
)

/// Customizes the texts of the payment means `direct-debit`, `card-payment`
/// and `paid`.
/// - method (auto, str): label of the payment method, e.g., "Payment method"
/// - transfer, direct-debit, sepa-direct-debit, card, credit-card,
///   debit-card, cash, cheque, online (auto, str): names of the payment
///   methods, e.g., "SEPA direct debit", "Barzahlung"
/// - mandate, creditor-id, debtor-iban, card-number, card-holder (auto,
///   str): labels of the details of a direct debit and a payment card
/// - paid (auto, fn): sentence of a paid invoice: (sum, date) => content,
///   `date` is `none` if not given
/// - paid-due (auto, fn): `paid` after prepayments: (sum, date) => content
/// - paid-credit (auto, fn): `paid` on a credit note or a self-billed
///   invoice, whose sender pays the amount: (sum, date) => content
/// -> array
#let payment-means(
  method: auto,
  transfer: auto,
  direct-debit: auto,
  sepa-direct-debit: auto,
  card: auto,
  credit-card: auto,
  debit-card: auto,
  cash: auto,
  cheque: auto,
  online: auto,
  mandate: auto,
  creditor-id: auto,
  debtor-iban: auto,
  card-number: auto,
  card-holder: auto,
  paid: auto,
  paid-due: auto,
  paid-credit: auto,
) = (
  {
    let payload = _clean-auto((
      method: method,
      transfer: transfer,
      direct-debit: direct-debit,
      sepa-direct-debit: sepa-direct-debit,
      card: card,
      credit-card: credit-card,
      debit-card: debit-card,
      cash: cash,
      cheque: cheque,
      online: online,
      mandate: mandate,
      creditor-id: creditor-id,
      debtor-iban: debtor-iban,
      card-number: card-number,
      card-holder: card-holder,
      paid: paid,
      paid-due: paid-due,
      paid-credit: paid-credit,
    ))
    (strings: (payment-means: payload))
  },
)

/// Customizes the payment instructions and deadline texts.
/// - text (auto, fn): Function generating the main sentence: (sum, deadline) => content
/// - text-due (auto, fn): Main sentence when prepayments reduce the payable amount: (sum, deadline) => content
/// - text-direct-debit, text-direct-debit-due (auto, fn): `text` and
///   `text-due` of an amount collected by `direct-debit`: (sum, deadline) => content
/// - text-card, text-card-due (auto, fn): `text` and `text-due` of an amount
///   charged to a `card-payment`: (sum, deadline) => content
/// - cash-discount (auto, fn): Note of a cash discount of the payment goal:
///   (percent, deadline, basis) => content, `basis` is `none` if not given
/// - deadline-date (auto, fn): Function formatting a fixed date: (date) => str
/// - deadline-days (auto, fn): Function formatting relative days: (days) => str
/// - deadline-soon (auto, str): Text for immediate payment: e.g., "upon receipt"
/// - text-credit (auto, fn): Main sentence of a credit note or a self-billed
///   invoice, whose sender pays the amount: (sum, deadline) => content
/// - deadline-soon-credit (auto, str): Text for immediate payment in
///   `text-credit`: e.g., "promptly"
/// -> array
#let payment(
  text: auto,
  text-due: auto,
  text-direct-debit: auto,
  text-direct-debit-due: auto,
  text-card: auto,
  text-card-due: auto,
  cash-discount: auto,
  deadline-date: auto,
  deadline-days: auto,
  deadline-soon: auto,
  text-credit: auto,
  deadline-soon-credit: auto,
) = (
  {
    let payload = _clean-auto((
      text: text,
      text-due: text-due,
      text-direct-debit: text-direct-debit,
      text-direct-debit-due: text-direct-debit-due,
      text-card: text-card,
      text-card-due: text-card-due,
      cash-discount: cash-discount,
      deadline-date: deadline-date,
      deadline-days: deadline-days,
      deadline-soon: deadline-soon,
      text-credit: text-credit,
      deadline-soon-credit: deadline-soon-credit,
    ))
    (strings: (payment: payload))
  },
)

/// Customizes the signature and closing area.
/// - closing (auto, str): e.g., "Sincerely,", "Mit freundlichen Grüßen"
/// -> array
#let signature(closing: auto) = (
  {
    let payload = _clean-auto((closing: closing))
    (strings: (signature: payload))
  },
)

/// Customizes standard legal texts.
/// - vat-exemption (auto, str): Legal text for small business tax exemptions.
/// -> array
#let legal(vat-exemption: auto) = (
  {
    let payload = _clean-auto((vat-exemption: vat-exemption))
    (strings: (legal: payload))
  },
)

/// Customizes error and warning messages.
/// - name-missing (auto, str)
/// - address-missing (auto, str)
/// - city-missing (auto, str)
/// - ambiguous-tax (auto, str)
/// - invalid-tax (auto, str)
#let errors(
  name-missing: auto,
  address-missing: auto,
  city-missing: auto,
  ambiguous-tax: auto,
  invalid-tax: auto,
) = (
  {
    let payload = _clean-auto((
      name-missing: name-missing,
      address-missing: address-missing,
      city-missing: city-missing,
      ambiguous-tax: ambiguous-tax,
      invalid-tax: invalid-tax,
    ))
    (strings: (errors: payload))
  },
)

// -----------------------------------------------------------------------------
// REGION OVERRIDES (region.*)
// -----------------------------------------------------------------------------

/// Customizes regional normalization and calculation logic.
/// - money (auto, fn): Function to round standard currency totals.
/// -> (number) => number
/// - money-fine (auto, fn): Function to round high-precision items.
/// -> (number) => number
/// - infer-tax (auto, fn): Function that maps a raw rate to a tax object.
/// -> (number) => tax
/// -> array
#let normalize(
  money: auto,
  money-fine: auto,
  infer-tax: auto,
) = (
  {
    let payload = _clean-auto((
      money: money,
      money-fine: money-fine,
      infer-tax: infer-tax,
    ))
    (region: (normalize: payload))
  },
)

/// Customizes regional formatting behaviors without creating a new region file.
/// Highly useful for tweaking date patterns or currency symbols on the fly.
/// - percent (auto, fn): -> (number) => str
/// - number (auto, fn): -> (number) => str
/// - currency (auto, fn): -> (number) => str
/// - currency-fine (auto, fn): -> (number) => str
/// - date (auto, fn): -> (datetime | array) => str
/// - time (auto, fn): -> (datetime) => str
/// -> array
#let format(
  percent: auto,
  number: auto,
  currency: auto,
  currency-fine: auto,
  date: auto,
  time: auto,
) = (
  {
    let payload = _clean-auto((
      percent: percent,
      number: number,
      currency: currency,
      currency-fine: currency-fine,
      date: date,
      time: time,
    ))
    (region: (format: payload))
  },
)

/// Customizes the legal tax objects applied within the region.
/// Useful for overriding default rates or providing custom exemption grounds.
/// - default-vat (auto, tax): Standard VAT tax object.
/// - small-enterprise-special-scheme (auto, tax): Tax object for small business exemptions.
/// -> array
#let tax(
  default-vat: auto,
  small-enterprise-special-scheme: auto,
) = (
  {
    let payload = _clean-auto((
      default-vat: default-vat,
      small-enterprise-special-scheme: small-enterprise-special-scheme,
    ))
    (region: (tax: payload))
  },
)
