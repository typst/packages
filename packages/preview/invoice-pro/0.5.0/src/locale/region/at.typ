#import "../../data/tax.typ"

#let at(lang) = {
  // --- Helper Functions ---
  let infer-tax-at(rate) = {
    if rate == 20% { return tax.vat(20%) } else if rate == 13% {
      return tax.vat(13%)
    } else if rate == 10% {
      return tax.vat(10%)
    } else if rate == 0% {
      panic(
        lang.errors.ambiguous-tax
          + " You must explicitly define the 0% category for legal compliance. "
          + "Please use one of the explicit constructors instead of a raw 0%:\n"
          + "`tax.reverse-charge()` -> B2B Reverse Charge (§19 UStG)\n"
          + "`tax.intra-community()` -> EU B2B Delivery (Art. 7 UStG)\n"
          + "`tax.export()` -> Non-EU Export (§6 UStG)\n"
          + "`tax.exempt()` -> VAT Exemptions (§6 UStG)\n"
          + "`tax-exempt-small-biz: true` -> Small Business/Kleinunternehmer (§6 Abs. 1 Z 27 UStG)\n"
          + "`tax.outside-scope()` -> Not subject to VAT (nicht steuerbar).",
      )
    } else {
      panic(
        lang.errors.invalid-tax
          + repr(rate)
          + ". Expected 20%, 13%, 10%, or a specific tax constructor.",
      )
    }
  }

  // --- Regional Data ---
  return (
    meta: (
      region: "at",
    ),

    normalize: (
      infer-tax: infer-tax-at,
    ),

    tax: (
      default-vat: tax.vat(20%),
      // Kleinunternehmer: § 6 Abs. 1 Z 27 UStG exempts the turnover of small
      // businesses. The note is printed and is the exemption reason (BT-120)
      // of VAT category E in the e-invoice.
      small-enterprise-special-scheme: tax.exempt(
        grounds: "Umsatzsteuerfrei aufgrund der Kleinunternehmerregelung gem. § 6 Abs. 1 Z 27 UStG.",
      ),
    ),
  )
}
