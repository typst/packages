// Typed identifiers of parties: one constructor per identification scheme.
//
// Every constructor returns a dictionary
//
//   (scheme: "0009", id: "12345678200010", kind: "legal", problems: ())
//
// - `scheme`: the code of the identification scheme, an ISO/IEC 6523 ICD code
//   (e.g. "0088" for a GLN) or, for the Leitweg-ID, an electronic address
//   scheme (EAS) code; `none` for a register number, which has none.
// - `id`: the identifier as the e-invoice states it, without the spaces,
//   dots and hyphens it is often grouped with.
// - `kind`: what the identifier identifies: `"party"` (a company or a
//   location, e.g. a GLN), `"legal"` (a legal registration, e.g. a SIRET),
//   `"routing"` (where a public buyer receives invoices, the Leitweg-ID) or
//   `"custom"` (`id.custom`).
// - `problems`: what is wrong with the identifier (its length, its check
//   digit), as messages. A constructor never stops the compilation: an
//   e-invoice reports the problems as errors (IP-ID-01), naming the input,
//   and `id.custom` takes an identifier without checking it.
//
// The dictionary is accepted wherever a party identifier with a scheme is:
// `id`, `global-id`, `legal-id` and `electronic-address` of the parties, and
// the Leitweg-ID as `leitweg-id` or `buyer-reference` of the recipient.
//
// The module is loaded for every invoice, so it compiles its patterns only
// when an identifier is created, and never loads the e-invoice code lists:
// whether a scheme fits the business term it is given for is checked with
// the e-invoice.

#import "../utils/text.typ": plain-text

// The patterns, compiled once on first use (most invoices create no typed
// identifier).
#let _patterns() = (
  // Whitespace and invisible format characters (zero width space, byte
  // order mark, soft hyphen, ...), which copied identifiers often carry.
  blank: regex("[\\s\\p{Cf}]+"),
  // Invisible format characters only, and the spaces left around one of
  // them (`plain-text` has collapsed all other whitespace).
  invisible: regex("\\p{Cf}"),
  spaces: regex(" {2,}"),
  // What numbers are grouped with: spaces, dots, hyphens and slashes.
  separators: regex("[\\s\\p{Cf}./-]+"),
  digits: regex("^[0-9]+$"),
  // "CHE" and the 9 digits of a Swiss UID, and the suffixes it is written
  // with: "MWST", "TVA" or "IVA" for a VAT number, "HR" or "RC" for an entry
  // in the commercial register, also several of them ("MWST/TVA/IVA").
  uid-ch: regex("^CHE[0-9]{9}$"),
  uid-ch-suffix: regex("(MWST|TVA|IVA|HR|RC)+$"),
  // Grobadressierung (2 to 12 digits), an optional Feinadressierung (up to
  // 30 capital letters and digits) and 2 check digits, separated by "-".
  leitweg: regex("^[0-9]{2,12}(-[0-9A-Z]{1,30})?-[0-9]{2}$"),
  lower: regex("[a-z]"),
)

#let _quoted(text) = "\"" + text + "\""

// The text of an identifier: a string, content or a number; "" for `none`
// or `auto`, and `none` for a value that is no identifier at all.
#let _text(value) = {
  if value == none or value == auto { return "" }
  if type(value) in (str, content, symbol, int) { return plain-text(value) }
  none
}

#let _result(scheme, id, kind, problems) = (
  scheme: scheme,
  id: id,
  kind: kind,
  problems: problems,
)

// The problem of a value that is neither text nor a number.
#let _type-problem(name, value) = (
  "The "
    + name
    + " must be given as text, e.g. `\"..\"`, but it is "
    + repr(type(value))
    + "."
)

// --- Check digits -----------------------------------------------------------

// Luhn (ISO/IEC 7812-1) of a string of digits: every second digit from the
// right is doubled.
#let _luhn(digits) = {
  let total = 0
  let double = false
  for digit in digits.codepoints().rev() {
    let value = int(digit)
    if double {
      value *= 2
      if value > 9 { value -= 9 }
    }
    total += value
    double = not double
  }
  calc.rem(total, 10) == 0
}

// The GS1 check digit of a GLN or GTIN: the digits in front of it, weighted
// 3 and 1 from the right, add up with it to a multiple of 10.
#let _gs1(digits) = {
  let values = digits.codepoints()
  let total = 0
  let weight = 3
  for digit in values.slice(0, -1).rev() {
    total += int(digit) * weight
    weight = 4 - weight
  }
  calc.rem(10 - calc.rem(total, 10), 10) == int(values.last())
}

// The SIRET check: Luhn, except for the establishments of La Poste (SIREN
// 356 000 000), whose digits add up to a multiple of 5 instead.
#let _siret-check(digits) = {
  if _luhn(digits) { return true }
  if not digits.starts-with("356000000") { return false }
  let total = 0
  for digit in digits.codepoints() { total += int(digit) }
  calc.rem(total, 5) == 0
}

// The check digit of a Swiss UID ("CHE" and 9 digits): modulo 11 of the
// first 8 digits weighted 5, 4, 3, 2, 7, 6, 5, 4 (eCH-0097); a remainder
// that would need the check digit 10 is never assigned.
#let _uid-ch-check(id) = {
  let digits = id.slice(3).codepoints()
  let total = 0
  for (digit, weight) in digits.slice(0, 8).zip((5, 4, 3, 2, 7, 6, 5, 4)) {
    total += int(digit) * weight
  }
  let rest = calc.rem(total, 11)
  let check = if rest == 0 { 0 } else { 11 - rest }
  check != 10 and check == int(digits.last())
}

// ISO/IEC 7064 MOD 97-10 of a text of digits and capital letters (A = 10 ..
// Z = 35), as for an IBAN; the text with its check digits leaves 1.
#let _mod97(text) = {
  let rest = 0
  for character in text.codepoints() {
    if character in "0123456789" {
      rest = calc.rem(rest * 10 + int(character), 97)
    } else {
      rest = calc.rem(rest * 100 + str.to-unicode(character) - 55, 97)
    }
  }
  rest
}

// --- Numeric identifiers --------------------------------------------------

// An identifier of `length` digits, grouped with any separators, and its
// check (`none`: no check digit).
#let _numeric(value, scheme, kind, name, length, example, check) = {
  let text = _text(value)
  if text == none {
    return _result(scheme, "", kind, (_type-problem(name, value),))
  }
  let patterns = _patterns()
  let id = text.replace(patterns.separators, "")
  let problems = ()
  if id == "" {
    problems.push("The " + name + " is empty.")
  } else if id.match(patterns.digits) == none or id.len() != length {
    problems.push(
      "The "
        + name
        + " "
        + _quoted(text)
        + " must have "
        + str(length)
        + " digits, e.g. "
        + _quoted(example)
        + ".",
    )
  } else if check != none and not check(id) {
    problems.push(
      "The check digit of the " + name + " " + _quoted(text) + " is wrong.",
    )
  }
  _result(scheme, id, kind, problems)
}

/// A Global Location Number (GLN) of GS1, which identifies a company or a
/// location: 13 digits with a GS1 check digit. ISO/IEC 6523 scheme `0088`.
///
/// ```typst
/// id.gln("4000001123452")
/// ```
///
/// -> dictionary
#let gln(
  /// The GLN, e.g. `"4000001123452"`; spaces are ignored.
  /// -> str | content | int
  value,
) = _numeric(value, "0088", "party", "GLN", 13, "4000001123452", _gs1)

/// A D-U-N-S number of Dun & Bradstreet, which identifies a company: 9
/// digits, often written as "15-048-3782". ISO/IEC 6523 scheme `0060`.
///
/// -> dictionary
#let duns(
  /// The D-U-N-S number, e.g. `"150483782"`; hyphens and spaces are ignored.
  /// -> str | content | int
  value,
) = _numeric(value, "0060", "party", "D-U-N-S number", 9, "150483782", none)

/// The SIREN of a French company, its number in the SIRENE register of
/// INSEE: 9 digits with a Luhn check digit. ISO/IEC 6523 scheme `0002`.
///
/// -> dictionary
#let siren(
  /// The SIREN, e.g. `"123 456 782"`; spaces are ignored.
  /// -> str | content | int
  value,
) = _numeric(value, "0002", "legal", "SIREN", 9, "123456782", _luhn)

/// The SIRET of a French establishment: its SIREN and 5 digits, 14 digits
/// with a Luhn check digit (the establishments of La Poste have their own
/// check). ISO/IEC 6523 scheme `0009`.
///
/// -> dictionary
#let siret(
  /// The SIRET, e.g. `"123 456 782 00010"`; spaces are ignored.
  /// -> str | content | int
  value,
) = _numeric(
  value,
  "0009",
  "legal",
  "SIRET",
  14,
  "12345678200010",
  _siret-check,
)

/// The Swiss enterprise identification number (UID): "CHE" and 9 digits
/// with a check digit, e.g. "CHE-123.456.788". The suffix of a Swiss VAT
/// number ("MWST", "TVA", "IVA") or of an entry in the commercial register
/// ("HR", "RC") is dropped: the UID is the same. ISO/IEC 6523 scheme `0183`.
///
/// -> dictionary
#let uid-ch(
  /// The UID, e.g. `"CHE-123.456.788"`; dots, hyphens and spaces are
  /// ignored.
  /// -> str | content
  value,
) = {
  let name = "Swiss UID"
  let text = _text(value)
  if text == none {
    return _result("0183", "", "legal", (_type-problem(name, value),))
  }
  let patterns = _patterns()
  let id = upper(text.replace(patterns.separators, "")).replace(
    patterns.uid-ch-suffix,
    "",
  )
  let problems = ()
  if id == "" {
    problems.push("The " + name + " is empty.")
  } else if id.match(patterns.uid-ch) == none {
    problems.push(
      "The "
        + name
        + " "
        + _quoted(text)
        + " must be \"CHE\" followed by 9 digits, e.g. \"CHE-123.456.788\".",
    )
  } else if not _uid-ch-check(id) {
    problems.push(
      "The check digit of the " + name + " " + _quoted(text) + " is wrong.",
    )
  }
  _result("0183", id, "legal", problems)
}

/// A number in a commercial or trade register that has no ISO/IEC 6523
/// scheme, e.g. "HRB 4711" of the German Handelsregister. The e-invoice
/// states it without a scheme; `court`, the register court or authority, is
/// written in front of it, as the number is unique only within its register:
/// `id.register("HRB 4711", court: "Amtsgericht München")` states
/// "Amtsgericht München, HRB 4711".
///
/// -> dictionary
#let register(
  /// The register number, e.g. `"HRB 4711"`.
  /// -> str | content | int
  value,
  /// The court or authority that keeps the register, e.g.
  /// `"Amtsgericht München"`.
  /// -> none | str | content
  court: none,
) = {
  let name = "register number"
  let number = _text(value)
  let court-text = _text(court)
  let problems = ()
  if number == none {
    problems.push(_type-problem(name, value))
    number = ""
  }
  if court-text == none {
    problems.push(_type-problem("register court", court))
    court-text = ""
  }
  let patterns = _patterns()
  let visible(text) = (
    text.replace(patterns.invisible, "").replace(patterns.spaces, " ").trim()
  )
  number = visible(number)
  court-text = visible(court-text)
  if number == "" and problems == () {
    problems.push("The " + name + " is empty.")
  }
  let id = if court-text == "" { number } else if number == "" {
    court-text
  } else { court-text + ", " + number }
  _result(none, id, "legal", problems)
}

/// The Leitweg-ID of a German public buyer: where it receives e-invoices.
/// XRechnung states it as the buyer reference (BT-10, `leitweg-id` or
/// `buyer-reference` of the recipient) and, as the electronic address of a
/// buyer reached by it, with the scheme `0204` (`electronic-address`). It
/// consists of up to 12 digits, optionally up to 30 capital letters and
/// digits, and 2 check digits (ISO/IEC 7064, MOD 97-10), separated by "-",
/// e.g. "04011000-1234512345-06".
///
/// -> dictionary
#let leitweg(
  /// The Leitweg-ID, e.g. `"04011000-1234512345-06"`; spaces are ignored.
  /// -> str | content
  value,
) = {
  let name = "Leitweg-ID"
  let text = _text(value)
  if text == none {
    return _result("0204", "", "routing", (_type-problem(name, value),))
  }
  let patterns = _patterns()
  let id = text.replace(patterns.blank, "")
  let problems = ()
  if id == "" {
    problems.push("The " + name + " is empty.")
  } else if id.match(patterns.leitweg) == none {
    problems.push(
      "The "
        + name
        + " "
        + _quoted(text)
        + " must consist of up to 12 digits, optionally up to 30 "
        + if id.contains(patterns.lower) { "capital " } else { "" }
        + "letters and digits, and 2 check digits, separated by \"-\", e.g. \"04011000-1234512345-06\".",
    )
  } else if _mod97(id.replace("-", "")) != 1 {
    problems.push(
      "The check digits of the " + name + " " + _quoted(text) + " are wrong.",
    )
  }
  _result("0204", id, "routing", problems)
}

/// An identifier with the code of its scheme, for the schemes without a
/// constructor of their own, e.g. `id.custom("0208", "0123456749")` for a
/// Belgian enterprise number. Use an ISO/IEC 6523 ICD code for a party
/// identifier or a legal registration identifier, and an EAS code for an
/// electronic address; the e-invoice checks the scheme against the code
/// list of the business term it is given for. The identifier itself is not
/// checked, so `id.custom` also takes an identifier whose check digit
/// invoice-pro rejects although it is correct.
///
/// -> dictionary
#let custom(
  /// The code of the scheme, e.g. `"0208"`.
  /// -> str | content
  scheme,
  /// The identifier; spaces are ignored.
  /// -> str | content | int
  id,
) = {
  let patterns = _patterns()
  let scheme-text = _text(scheme)
  let id-text = _text(id)
  let problems = ()
  if scheme-text == none {
    problems.push(_type-problem("scheme of the identifier", scheme))
    scheme-text = ""
  }
  if id-text == none {
    problems.push(_type-problem("identifier", id))
    id-text = ""
  }
  let scheme-code = upper(scheme-text.replace(patterns.blank, ""))
  let value = id-text.replace(patterns.blank, "")
  if scheme-code == "" and problems == () {
    problems.push(
      "The identifier "
        + _quoted(id-text)
        + " has no scheme: `id.custom` takes the code of the scheme first, e.g. `id.custom(\"0208\", \"0123456749\")`.",
    )
  }
  if value == "" and problems == () {
    problems.push(
      "The identifier of the scheme " + _quoted(scheme-code) + " is empty.",
    )
  }
  _result(
    if scheme-code == "" { none } else { scheme-code },
    value,
    "custom",
    problems,
  )
}
