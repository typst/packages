#import "../../data/tax.typ"
#import "../../utils/format.typ" as m-format

/// Swiss regional configuration (CH).
#let ch(lang) = {
  // --- Regional Settings ---
  let numeric-format = (
    decimal-sign: ".",
    thousand-separators: "'",
    padding: false,
    accuracy: 4,
  )

  let currency-meta = (
    code: "CHF",
    symbol: "CHF ",
    decimals: 2,
    decimals-fine: 4,
  )

  // --- Helper Functions ---
  let infer-tax-ch(rate) = {
    if rate == 8.1% {
      tax.vat(8.1%) // Standard rate
    } else if rate == 2.6% {
      tax.lower-rate(2.6%) // Reduced rate (e.g., food, books, medicine)
    } else if rate == 2.5% {
      tax.lower-rate(2.5%) // Special rate for accommodation/lodging
    } else if rate == 0% {
      panic(
        "Ambiguous 0% tax rate in region 'ch'. Please explicitly use tax.zero(), tax.exempt(), tax.export(), or tax.outside-scope() from tax.typ instead of passing 0%.",
      )
    } else {
      panic(
        "Invalid or unknown tax rate for region 'ch': "
          + repr(rate)
          + ". Valid rates are 8.1%, 2.6%, and 2.5%. If you need a custom rate, pass a full tax object.",
      )
    }
  }

  // --- Regional Data ---
  return (
    meta: (
      region: "ch",
    ),

    currency: currency-meta,

    normalize: (
      infer-tax: infer-tax-ch,
    ),

    format: (
      // Override the base percent formatter to use a dot for decimals instead of a comma
      percent: x => {
        let p = float(x) * 100
        str(calc.round(p, digits: 1)) + "%"
      },
    )
      + m-format.make-formatters(
        numeric-format,
        currency-meta,
        currency-location: start,
      ),

    tax: (
      default-vat: tax.vat(8.1%),
      small-enterprise-special-scheme: tax.outside-scope(
        grounds: "Nicht MWST-pflichtig / Non soumis à la TVA / Non assoggettato all'IVA",
      ),
    ),
  )
}
