#import "../../data/tax.typ"
#import "../../utils/format.typ" as m-format

/// French regional configuration (FR).
#let fr(lang) = {
  // --- Regional Settings ---
  let numeric-format = (
    decimal-sign: ",",
    thousand-separators: sym.space.nobreak + "",
    padding: false,
    accuracy: 4,
  )

  let currency-meta = (
    code: "EUR",
    symbol: "€",
    decimals: 2,
    decimals-fine: 4,
  )

  // --- Helper Functions ---
  let infer-tax-fr(rate) = {
    if rate == 20% {
      return tax.vat(20%) // Taux normal
    } else if rate == 10% {
      return tax.lower-rate(10%) // Taux intermédiaire (restaurants, transport)
    } else if rate == 5.5% {
      return tax.lower-rate(5.5%) // Taux réduit (food, water, books)
    } else if rate == 2.1% {
      return tax.lower-rate(2.1%) // Taux particulier (press, specific medicines)
    } else if rate == 0% {
      panic(
        "Ambiguous 0% tax rate in region 'fr'. Please explicitly use tax.zero(), tax.exempt(), tax.export(), or tax.outside-scope() from tax.typ instead of passing 0%.\n"
          + "Examples:\n"
          + "`tax.reverse-charge()` -> Autoliquidation\n"
          + "`tax.intra-community()` -> Livraison intracommunautaire\n"
          + "`tax.outside-scope()` -> Franchise en base de TVA (art. 293 B du CGI)",
      )
    } else {
      panic(
        "Invalid or unknown tax rate for region 'fr': "
          + repr(rate)
          + ". Valid rates are 20%, 10%, 5.5%, and 2.1%. If you need a custom rate, pass a full tax object.",
      )
    }
  }

  // --- Regional Data ---
  return (
    meta: (
      region: "fr",
    ),

    currency: currency-meta,

    normalize: (
      infer-tax: infer-tax-fr,
    ),

    format: m-format.make-formatters(numeric-format, currency-meta),

    tax: (
      default-vat: tax.vat(20%),

      // Exemption for small enterprises (Auto-entrepreneur / Micro-entreprise)
      small-enterprise-special-scheme: tax.outside-scope(
        grounds: "TVA non applicable, art. 293 B du CGI.",
      ),
    ),
  )
}
