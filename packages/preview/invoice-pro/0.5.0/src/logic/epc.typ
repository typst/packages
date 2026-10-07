// The EPC-QR code (GiroCode) of the bank details: the fields it carries and
// the reasons it cannot be generated (EPC069-12, SEPA Credit Transfer).
//
// `bank-details` prepares these data for the theme, which only draws the code
// from its payload (with `sepay`) or a placeholder naming its problems.

#import "../utils/bic.typ": bic-valid
#import "../utils/iban.typ": format-iban, iban-valid
#import "../utils/text.typ": plain-text

// The message for a field that is longer than the EPC-QR code allows.
#let _too-long(what, value, limit) = (
  what
    + " \""
    + value
    + "\" is too long for the EPC-QR code (at most "
    + str(limit)
    + " bytes, non-ASCII characters count twice or more)"
)

/// Why an EPC-QR code cannot be generated from its fields, as a list of
/// `(short: .., message: ..)`: `short` names the problem in a few words (for
/// a placeholder in the document), `message` explains it (for an error
/// message). The list is empty if the code can be generated.
///
/// The fields are plain text, as `qr-code` prepares them. `sepay` counts the
/// length limits in bytes (UTF-8), so umlauts and other non-ASCII characters
/// count twice or more.
///
/// -> array
#let problems(
  /// The account holder (beneficiary).
  /// -> str
  beneficiary,
  /// The IBAN in electronic format (see `normalize-iban`).
  /// -> str
  iban,
  /// The BIC in electronic format (see `normalize-bic`).
  /// -> none | str
  bic,
  /// The structured payment reference (EPC-QR line 10).
  /// -> none | str
  reference,
  /// The unstructured remittance text (EPC-QR line 11).
  /// -> none | str
  text,
) = {
  let found = ()
  if iban == "" {
    found.push((short: "IBAN missing", message: "the IBAN is missing"))
  } else if not iban-valid(iban) {
    found.push((
      short: "invalid IBAN",
      message: "the IBAN \"" + format-iban(iban) + "\" is not valid",
    ))
  }
  if beneficiary == "" or beneficiary.starts-with("#sender.") {
    found.push((
      short: "account holder missing",
      message: "the account holder name is missing (set `name` on `bank-details`)",
    ))
  } else if beneficiary.len() > 70 {
    found.push((
      short: "account holder too long",
      message: _too-long("the account holder name", beneficiary, 70)
        + "; set the account name as registered at the bank with `name` on `bank-details`",
    ))
  }
  if bic != none and not bic-valid(bic) {
    found.push((
      short: "invalid BIC",
      message: "the BIC \""
        + bic
        + "\" is not valid (8 or 11 letters and digits)",
    ))
  }
  if reference != none and reference.len() > 35 {
    found.push((
      short: "reference too long",
      message: _too-long("the payment reference", reference, 35)
        + "; use `text` on `bank-details` for a longer, unstructured reference",
    ))
  }
  if text != none and text.len() > 140 {
    found.push((
      short: "reference text too long",
      message: _too-long("the payment reference text", text, 140),
    ))
  }
  found
}

/// The EPC-QR code of a bank transfer, as `(payload: .., problems: ..)`.
///
/// `payload` holds the fields of the code, in plain text, as the
/// `epc-qr-code` function of `sepay` takes them: `beneficiary` and `iban`
/// (its positional arguments), `bic`, `amount` (a float), `reference` and
/// `text` (each `none` if not set). They are the values the invoice prints
/// and the e-invoice carries. `payload` is `none` if the code cannot be
/// generated; `problems` then says why (see `problems`).
///
/// -> dictionary
#let qr-code(
  /// The account holder (beneficiary), as printed.
  /// -> str | content
  holder,
  /// The IBAN in electronic format (see `normalize-iban`).
  /// -> str
  iban,
  /// The BIC in electronic format (see `normalize-bic`); `""` or `none` if
  /// there is none.
  /// -> none | str
  bic: none,
  /// The structured payment reference (EPC-QR line 10).
  /// -> none | str | content
  reference: none,
  /// The unstructured remittance text (EPC-QR line 11). The code carries
  /// either a reference or a text, so the text takes precedence.
  /// -> none | str | content
  text: none,
  /// The amount to pay. The code carries amounts from 0.01 to
  /// 999 999 999.99 (EUR); for any other amount, the payer enters it.
  /// -> none | decimal | float | int
  amount: none,
) = {
  let beneficiary = plain-text(holder)
  let reference = if text == none and reference != none {
    plain-text(reference)
  }
  let text = if text != none { plain-text(text) }
  if reference == "" { reference = none }
  if text == "" { text = none }
  if bic == "" { bic = none }

  let found = problems(beneficiary, iban, bic, reference, text)
  if found.len() > 0 { return (payload: none, problems: found) }

  let amount = if amount != none { float(amount) }
  (
    payload: (
      beneficiary: beneficiary,
      iban: iban,
      bic: bic,
      amount: if (
        amount != none and amount >= 0.01 and amount <= 999999999.99
      ) { amount },
      reference: reference,
      text: text,
    ),
    problems: (),
  )
}
