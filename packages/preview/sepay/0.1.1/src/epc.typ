/// EPC QR Code Generator for SEPA Credit Transfers
///
/// This module generates EPC QR codes (also known as GiroCode) according to
/// the EPC069-12 specification for SEPA credit transfers.
///
/// Specification: https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation
/// Wikipedia: https://en.wikipedia.org/wiki/EPC_QR_code

#import "@preview/rustycure:0.2.0"
#import "@preview/ibanator:0.1.0"
#import "./helper.typ": format-amount, validate-epc-params

/// Generates a QR code payload string according to the EPC069-12 standard for SEPA Credit Transfer:
/// https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation
///
/// - beneficiary (str): Beneficiary name (required, max 70 characters).
/// - iban (str): Beneficiary IBAN (required, spaces are removed automatically).
/// - bic (str | none): BIC of the beneficiary's bank (optional, may be required for international transfers).
/// - amount (float | int | none): Transfer amount in EUR (0.01–999999999.99). If `none`, creates an open amount QR code.
/// - purpose (str | none): ISO 20022 purpose code (max 4 characters).
/// - reference (str | none): Structured remittance reference (max 35 characters). Mutually exclusive with `text`.
/// - text (str | none): Unstructured remittance text (max 140 characters). Mutually exclusive with `reference`.
/// - information (str | none): Beneficiary to originator information (max 70 characters).
///
/// -> str
#let epc-payload(
  beneficiary,
  iban,
  bic: none,
  amount: none,
  purpose: none,
  reference: none,
  text: none,
  information: none,
) = {
  // Validate IBAN with ibanator
  // ibanator.iban() expects no spaces and returns without spaces
  let iban-validated = ibanator.iban(iban.replace(" ", ""), validate: true)
  let iban-clean = iban-validated.replace(" ", "")

  // Validate all parameters
  validate-epc-params(
    beneficiary,
    iban-clean,
    bic,
    amount,
    purpose,
    reference,
    text,
    information,
  )

  // EPC QR Code format (EPC069-12)
  // Each line represents a specific field in the SEPA credit transfer data structure
  let lines = (
    // Line 1: Service Tag
    "BCD",
    // Line 2: Version
    "002",
    // Line 3: Character Set (UTF-8)
    "1",
    // Line 4: Identification (SEPA Credit Transfer)
    "SCT",
    // Line 5: BIC of beneficiary bank
    bic,
    // Line 6: Beneficiary name
    beneficiary,
    // Line 7: IBAN of beneficiary
    iban-clean,
    // Line 8: Amount in EUR (empty if no amount specified)
    if amount != none { "EUR" + format-amount(amount) },
    // Line 9: Purpose code (ISO 20022)
    purpose,
    // Line 10: Structured remittance reference
    reference,
    // Line 11: Unstructured remittance text
    text,
    // Line 12: Beneficiary to originator information
    information,
  )

  let payload = lines.join("\n")
  assert(
    bytes(payload).len() <= 331,
    message: "EPC payload exceeds maximum length of 331 bytes",
  )
  payload
}

/// Generates an EPC QR code image for SEPA credit transfers.
///
/// This function creates a scannable QR code that can be used by banking apps
/// to initiate a SEPA credit transfer with pre-filled payment details.
///
/// Example:
/// ```typ
/// #epc-qr-code(
///   "Max Mustermann",
///   "DE89 3704 0044 0532 0130 00",
///   amount: 123.45,
///   reference: "INV-2024-001",
/// )
/// ```
///
/// - beneficiary (str): Beneficiary name (required, max 70 characters).
/// - iban (str): Beneficiary IBAN (required, spaces are removed automatically).
/// - bic (str | none): BIC of the beneficiary's bank (optional, may be required for international transfers).
/// - amount (float | int | none): Transfer amount in EUR (0.01–999999999.99). If `none`, creates an open amount QR code.
/// - purpose (str | none): ISO 20022 purpose code (max 4 characters).
/// - reference (str | none): Structured remittance reference (max 35 characters). Mutually exclusive with `text`.
/// - text (str | none): Unstructured remittance text (max 140 characters). Mutually exclusive with `reference`.
/// - information (str | none): Beneficiary to originator information (max 70 characters).
/// - width (length | auto): Width of the QR code image.
/// - height (length | auto): Height of the QR code image.
/// - quiet-zone (bool): Whether to include a quiet zone (white border) around the QR code. Default is true.
/// - dark-color (color): Color of the QR code modules (dark squares). Default is black.
/// - light-color (color): Background color of the QR code. Default is white.
/// - alt (str | auto): Alt text for accessibility. Default is auto-generated.
/// - fit (str): Image fit mode. Default is "cover".
///
/// -> content
#let epc-qr-code(
  beneficiary,
  iban,
  bic: none,
  amount: none,
  purpose: none,
  reference: none,
  text: none,
  information: none,
  width: auto,
  height: auto,
  quiet-zone: true,
  dark-color: black,
  light-color: white,
  alt: auto,
  fit: "cover",
) = {
  let payload-str = epc-payload(
    beneficiary,
    iban,
    bic: bic,
    amount: amount,
    purpose: purpose,
    reference: reference,
    text: text,
    information: information,
  )

  rustycure.qr-code(
    payload-str,
    quiet-zone: quiet-zone,
    dark-color: dark-color,
    light-color: light-color,
    width: width,
    height: height,
    alt: alt,
    fit: fit,
  )
}
