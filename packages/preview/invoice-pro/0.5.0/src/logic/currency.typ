// The invoice currency (BT-5 of EN 16931) as every part of the invoice reads
// it: the printed invoice (SEPA direct debits, the EPC-QR code, the name of
// the payment method) and the e-invoice.

#import "../utils/text.typ": plain-text

// Invisible format characters (Unicode category Cf, e.g. a zero width space
// of a copied code). The pattern is compiled once, on first use, and only
// for a code that is not plain ASCII.
#let _invisible() = regex("\\p{Cf}")

/// The ISO 4217 code of the invoice currency: the `currency.code` of the
/// locale, which `invoice(currency: ..)` sets, without whitespace and
/// invisible characters and in upper case, as the e-invoice states it
/// (BT-5); `none` if the locale has none.
///
/// -> none | str
#let currency-code(locale) = {
  let code = plain-text(
    locale.at("currency", default: (:)).at("code", default: none),
  ).replace(" ", "")
  if code.len() != code.codepoints().len() {
    code = code.replace(_invisible(), "")
  }
  if code == "" { none } else { upper(code) }
}
