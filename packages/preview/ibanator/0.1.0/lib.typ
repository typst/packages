#let lib = plugin("typst_iban.wasm")

/// Validates the given IBAN, returning an ISO 13616-1 formatted string if the validation was successful.
/// If the validation was unsuccessful, the function panics with an error.
///
/// iban (string): The IBAN to format.
/// validate(boolean): If true, the IBAN will be validated before formatting.
/// -> string
#let iban(iban, validate: true) = {
  if validate {
    let res = lib.check_iban(bytes(iban))
    if res.at(0) != 1 {
      panic("Invalid IBAN")
    }
  }

  // Format the string by creating groups of 4 chars.
  let iban_len = iban.len()
  let result = ""
  for i in range(0, iban_len, step: 4) {
    result += iban.slice(i, calc.min(iban_len, i + 4)) + " "
  }

  return result.trim(at: end)
}
