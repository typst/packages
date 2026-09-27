// The currency of an invoice (`invoice(currency: ..)`): the ISO 4217 code
// the e-invoice states (BT-5), and the symbol and the decimals the amounts
// are printed and rounded with.

// The symbols of currencies whose symbol is unambiguous and in every common
// font. Any other currency is printed with its code (e.g. "CHF", "SEK",
// "CAD"), which cannot be mistaken for another one.
#let _symbols = (
  CZK: "Kč",
  EUR: "€",
  GBP: "£",
  HUF: "Ft",
  JPY: "¥",
  PLN: "zł",
  USD: "$",
)

// The decimals (minor units) of the ISO 4217 currencies that do not have
// two.
#let _decimals = (
  BHD: 3,
  BIF: 0,
  CLF: 4,
  CLP: 0,
  DJF: 0,
  GNF: 0,
  IQD: 3,
  ISK: 0,
  JOD: 3,
  JPY: 0,
  KMF: 0,
  KRW: 0,
  KWD: 3,
  LYD: 3,
  OMR: 3,
  PYG: 0,
  RWF: 0,
  TND: 3,
  UGX: 0,
  UYI: 0,
  UYW: 4,
  VND: 0,
  VUV: 0,
  XAF: 0,
  XOF: 0,
  XPF: 0,
)

#let _code-pattern = regex("^[A-Za-z]{3}$")

/// The currency of an ISO 4217 code (e.g. `"usd"`): `(code, symbol,
/// decimals)` with the code in upper case, its symbol (the code itself if it
/// has none in `_symbols`) and its decimals.
///
/// -> dictionary
#let currency-of(code) = {
  if type(code) != str or code.trim().match(_code-pattern) == none {
    panic(
      "invoice::currency must be an ISO 4217 currency code such as \"EUR\" or \"USD\", got "
        + repr(code)
        + ".",
    )
  }
  let code = upper(code.trim())
  (
    code: code,
    symbol: _symbols.at(code, default: code),
    decimals: _decimals.at(code, default: 2),
  )
}

/// A locale (as `invoice` evaluates it) that invoices in the currency
/// `code`: its currency (code, symbol and decimals), the formatters of
/// amounts and unit prices (`format.currency`, `format.currency-fine`, with
/// the number format and the position of the symbol of the locale) and, if
/// the decimals differ, the rounding of amounts (`normalize.money`,
/// `normalize.money-fine`). A locale in this currency already is returned
/// as it is, with its own symbol and formatters.
///
/// -> dictionary
#let with-currency(locale, code) = {
  let target = currency-of(code)
  let current = locale.at("currency", default: (:))
  let current-code = current.at("code", default: none)
  if type(current-code) == str and upper(current-code) == target.code {
    return locale
  }

  let decimals-fine = calc.max(
    target.decimals,
    current.at("decimals-fine", default: 4),
  )
  let currency = current + target + (decimals-fine: decimals-fine)
  locale.currency = currency

  // The formatters of the locale for another currency (see
  // `make-formatters`); a locale without them keeps its own, which the
  // e-invoice checks against the currency (IP-PRINT-02).
  let format = locale.at("format", default: (:))
  let rebuild = format.at("currency-formatters", default: none)
  if type(rebuild) == function {
    let formatters = rebuild(currency)
    format.currency = formatters.currency
    format.currency-fine = formatters.currency-fine
    locale.format = format
  }

  let normalize = locale.at("normalize", default: (:))
  if target.decimals != current.at("decimals", default: 2) {
    normalize.money = x => calc.round(x, digits: target.decimals)
  }
  if decimals-fine != current.at("decimals-fine", default: 4) {
    normalize.money-fine = x => calc.round(x, digits: decimals-fine)
  }
  locale.normalize = normalize
  locale
}
