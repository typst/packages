// IBAN helpers (ISO 13616) shared by the bank details, the EPC-QR code and
// the e-invoice.

#import "text.typ": plain-text

// The pattern is compiled once: compiling a regex costs far more than
// matching it.
#let _iban-format = regex("^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$")

/// The electronic format of an IBAN: its plain text without whitespace, in
/// upper case. The printed IBAN, the EPC-QR code and the e-invoice (BT-84)
/// all derive from it. `none` becomes `""`.
///
/// -> str
#let normalize-iban(iban) = upper(
  // `split()` splits at every Unicode whitespace character, as the class
  // `\s` does, without a pattern: compiling `\s` when this module loads cost
  // every compile about 1 M instructions.
  plain-text(iban).split().join(default: ""),
)

/// The remainder of an alphanumeric text in upper case, read as a number
/// with the letters A to Z standing for 10 to 35, divided by 97: the check
/// of ISO 7064 MOD 97-10, which IBANs and SEPA creditor identifiers use. A
/// text with correct check digits has the remainder 1. The callers check
/// the format first, so every character is a digit or a letter from A to Z.
///
/// -> int
#let mod97(text) = {
  let remainder = 0
  for char in text.clusters() {
    // By code point, without a regular expression per character: "0" to
    // "9" are 48 to 57, "A" to "Z" are 65 to 90 and stand for 10 to 35.
    let code = str.to-unicode(char)
    remainder = if code <= 57 {
      calc.rem(remainder * 10 + code - 48, 97)
    } else {
      calc.rem(remainder * 100 + code - 55, 97)
    }
  }
  remainder
}

/// Whether an IBAN in electronic format (see `normalize-iban`) has the
/// structure of an IBAN (country code, check digits, up to 30 alphanumeric
/// characters) and correct check digits (ISO 7064 MOD 97-10).
///
/// -> bool
#let iban-valid(iban) = {
  if type(iban) != str { return false }
  if iban.match(_iban-format) == none {
    return false
  }
  mod97(iban.slice(4) + iban.slice(0, 4)) == 1
}

/// Formats an IBAN in electronic format for print: groups of four
/// characters separated by spaces (ISO 13616 paper format).
///
/// -> str
#let format-iban(iban) = (
  iban.clusters().chunks(4).map(chunk => chunk.join()).join(" ", default: "")
)
