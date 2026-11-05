// BIC helpers (ISO 9362) for the bank details and the EPC-QR code.

#import "text.typ": plain-text

#let _bic-format = regex("^[A-Z0-9]{8}([A-Z0-9]{3})?$")

/// The electronic format of a BIC: its plain text without whitespace, in
/// upper case. The bank details print it and the EPC-QR code carries it, in
/// the form the e-invoice writes (BT-86). `none` becomes `""`.
///
/// -> str
#let normalize-bic(bic) = upper(
  // `split()` splits at every Unicode whitespace character, as the class
  // `\s` does, without a pattern: compiling `\s` when this module loads cost
  // every compile about 1 M instructions.
  plain-text(bic).split().join(default: ""),
)

/// Whether a BIC in electronic format (see `normalize-bic`) has 8 or 11
/// letters and digits, as the EPC-QR code requires. This is the length and
/// character check only, not the full ISO 9362 structure.
///
/// -> bool
#let bic-valid(bic) = type(bic) == str and bic.match(_bic-format) != none
