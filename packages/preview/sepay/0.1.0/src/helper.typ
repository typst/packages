/// Formats a number as a currency string with exactly 2 decimal places.
///
/// According to the EPC069-12 specification, the amount field must use a
/// dot (.) as the decimal separator, regardless of locale. This is a
/// standardized, locale-independent format (e.g., "123.45" not "123,45").
///
/// - amount (float | int): The amount to format.
///
/// -> str
#let format-amount(amount) = {
  let rounded = calc.round(amount, digits: 2)
  let integer-part = calc.floor(rounded)
  let decimal-part = calc.round((rounded - integer-part) * 100)
  let decimal-str = if decimal-part < 10 {
    "0" + str(int(decimal-part))
  } else {
    str(int(decimal-part))
  }
  str(integer-part) + "." + decimal-str
}

/// Checks if a value is set (not none and not empty string).
#let is-set(value) = value != none and value != ""

/// Validates EPC payload parameters according to EPC069-12 specification.
///
/// Collects all validation errors and panics with a comprehensive list if any issues are found.
#let validate-epc-params(
  name,
  iban,
  bic,
  amount,
  purpose,
  reference,
  text,
  information,
) = {
  let errors = ()

  // Validate required fields
  if not is-set(name) {
    errors.push("Beneficiary name is required")
  }
  if not is-set(iban) {
    errors.push("Beneficiary IBAN is required")
  }

  // Validate BIC format (8 or 11 alphanumeric characters)
  if is-set(bic) {
    let bic-len = bic.len()
    if bic-len != 8 and bic-len != 11 {
      errors.push(
        "BIC must be 8 or 11 characters (got " + str(bic-len) + ")",
      )
    }
    // Check for alphanumeric characters only
    let bic-valid = bic.match(regex("^[A-Za-z0-9]+$")) != none
    if not bic-valid {
      errors.push("BIC must contain only alphanumeric characters")
    }
  }

  // Validate field lengths
  if is-set(name) and name.len() > 70 {
    errors.push(
      "Beneficiary name exceeds 70 characters (got " + str(name.len()) + ")",
    )
  }

  if is-set(purpose) and purpose.len() > 4 {
    errors.push(
      "Purpose code exceeds 4 characters (got " + str(purpose.len()) + ")",
    )
  }

  if is-set(reference) and reference.len() > 35 {
    errors.push(
      "Structured remittance reference exceeds 35 characters (got "
        + str(reference.len())
        + ")",
    )
  }

  if is-set(text) and text.len() > 140 {
    errors.push(
      "Unstructured remittance text exceeds 140 characters (got "
        + str(text.len())
        + ")",
    )
  }

  if is-set(information) and information.len() > 70 {
    errors.push(
      "Beneficiary to originator information exceeds 70 characters (got "
        + str(information.len())
        + ")",
    )
  }

  // Validate mutually exclusive fields
  if is-set(reference) and is-set(text) {
    errors.push(
      "Cannot specify both 'reference' and 'text'. Use one or the other.",
    )
  }

  // Validate amount range (only if amount is provided)
  if amount != none {
    if amount < 0.01 {
      errors.push("Amount must be >= 0.01 (got " + str(amount) + ")")
    }
    if amount > 999999999.99 {
      errors.push(
        "Amount exceeds maximum of 999999999.99 (got " + str(amount) + ")",
      )
    }
  }

  // Panic with all collected errors
  if errors.len() > 0 {
    let error-list = errors
      .enumerate()
      .map(((i, err)) => {
        str(i + 1) + ". " + err
      })
      .join("\n")

    panic(
      "EPC payload validation failed with "
        + str(errors.len())
        + " error(s):\n"
        + error-list,
    )
  }
}
