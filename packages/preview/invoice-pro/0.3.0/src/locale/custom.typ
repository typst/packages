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

/// Customizes the document type designations.
/// - invoice (auto, str): e.g., "Invoice", "Rechnung", "Proforma"
/// -> dictionary
#let document(invoice: auto) = (
  {
    let payload = _clean-auto((invoice: invoice))
    return (strings: (document: payload))
  },
)

/// Customizes the address-related labels.
/// - recipient (auto, str): e.g., "Bill To", "Empfänger"
/// - sender (auto, str): e.g., "From", "Absender"
/// -> dictionary
#let address(recipient: auto, sender: auto) = (
  {
    let payload = _clean-auto((recipient: recipient, sender: sender))
    return (strings: (address: payload))
  },
)

/// Customizes the metadata and reference numbers labels.
/// - tax-number (auto, str): e.g., "Tax ID", "Steuernummer"
/// - invoice-number (auto, str): e.g., "Invoice Number", "Rechnungsnummer"
/// -> dictionary
#let reference(tax-number: auto, invoice-number: auto) = (
  {
    let payload = _clean-auto((
      tax-number: tax-number,
      invoice-number: invoice-number,
    ))
    return (strings: (reference: payload))
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
/// - vat (auto, str): e.g., "Tax", "MwSt."
/// - net (auto, str): e.g., "net", "netto"
/// - gross (auto, str): e.g., "gross", "brutto"
/// - discount (auto, str): e.g., "Discount", "Rabatt"
/// - surcharge (auto, str): e.g., "Surcharge", "Zuschlag"
/// - subtotal (auto, str): e.g., "Subtotal", "Zwischensumme"
/// -> dictionary
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
    ))

    return (strings: (line-items: payload))
  },
)

/// Customizes the summary and total labels at the bottom of the table.
/// - sum (auto, str): e.g., "Subtotal", "Summe"
/// - vat-tax (auto, str): e.g., "Tax", "Mehrwertsteuer"
/// - total (auto, str): e.g., "Total Due", "Gesamtbetrag"
/// - including (auto, str): e.g., "incl.", "inkl."
/// - excluding (auto, str): e.g., "excl.", "zzgl."
/// -> dictionary
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
    return (strings: (summary: payload))
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
    return (strings: (global-info: payload))
  },
)

/// Customizes the bank detail labels.
/// - account-holder (auto, str): e.g., "Account Holder", "Kontoinhaber"
/// - bank (auto, str): e.g., "Bank", "Kreditinstitut"
/// - iban (auto, str): e.g., "IBAN"
/// - bic (auto, str): e.g., "BIC"
/// - reference (auto, str): e.g., "Reference", "Verwendungszweck"
/// -> dictionary
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
    return (strings: (bank-details: payload))
  },
)

/// Customizes the payment instructions and deadline texts.
/// - text (auto, fn): Function generating the main sentence: (sum, currency, deadline) => content
/// - deadline-date (auto, fn): Function formatting a fixed date: (date) => str
/// - deadline-days (auto, fn): Function formatting relative days: (days) => str
/// - deadline-soon (auto, str): Text for immediate payment: e.g., "upon receipt"
/// -> dictionary
#let payment(
  text: auto,
  deadline-date: auto,
  deadline-days: auto,
  deadline-soon: auto,
) = (
  {
    let payload = _clean-auto((
      text: text,
      deadline-date: deadline-date,
      deadline-days: deadline-days,
      deadline-soon: deadline-soon,
    ))
    return (strings: (payment: payload))
  },
)

/// Customizes the signature and closing area.
/// - closing (auto, str): e.g., "Sincerely,", "Mit freundlichen Grüßen"
/// -> dictionary
#let signature(closing: auto) = (
  {
    let payload = _clean-auto((closing: closing))
    return (strings: (signature: payload))
  },
)

/// Customizes standard legal texts.
/// - vat-exemption (auto, str): Legal text for small business tax exemptions.
/// -> dictionary
#let legal(vat-exemption: auto) = (
  {
    let payload = _clean-auto((vat-exemption: vat-exemption))
    return (strings: (legal: payload))
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
    return (strings: (errors: payload))
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
/// -> dictionary
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
    return (region: (normalize: payload))
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
/// -> dictionary
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
    return (region: (format: payload))
  },
)

/// Customizes the legal tax objects applied within the region.
/// Useful for overriding default rates or providing custom exemption grounds.
/// - default-vat (auto, tax): Standard VAT tax object.
/// - small-enterprise-special-scheme (auto, tax): Tax object for small business exemptions.
/// -> dictionary
#let tax(
  default-vat: auto,
  small-enterprise-special-scheme: auto,
) = (
  {
    let payload = _clean-auto((
      default-vat: default-vat,
      small-enterprise-special-scheme: small-enterprise-special-scheme,
    ))
    return (region: (tax: payload))
  },
)
