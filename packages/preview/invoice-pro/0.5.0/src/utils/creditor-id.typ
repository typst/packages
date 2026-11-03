// SEPA creditor identifier helpers (EPC262-08) for direct debits: the
// identifier of the seller that collects the amount (BT-90).

#import "iban.typ": mod97, normalize-iban

// The structure of a creditor identifier: country code, check digits, the
// creditor business code (3 characters, often "ZZZ") and the national
// identifier. Compiled on first use, as invoices rarely use direct debits.
#let _creditor-id-format() = regex(
  "^[A-Z]{2}[0-9]{2}[A-Z0-9]{3}[A-Z0-9]{1,28}$",
)

/// The electronic format of a creditor identifier: its plain text without
/// whitespace, in upper case, as for an IBAN. `none` becomes `""`.
///
/// -> str
#let normalize-creditor-id(creditor-id) = normalize-iban(creditor-id)

/// Whether a creditor identifier in electronic format (see
/// `normalize-creditor-id`) has the structure of a SEPA creditor identifier
/// and correct check digits. The check digits (ISO 7064 MOD 97-10) are
/// computed over the national identifier and the country code; the creditor
/// business code is not part of them.
///
/// -> bool
#let creditor-id-valid(creditor-id) = {
  if type(creditor-id) != str { return false }
  if creditor-id.match(_creditor-id-format()) == none { return false }
  mod97(creditor-id.slice(7) + creditor-id.slice(0, 4)) == 1
}
