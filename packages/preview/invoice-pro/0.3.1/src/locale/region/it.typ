#import "../../data/tax.typ"

/// Italian regional configuration (IT).
#let it(lang) = {
  // --- Helper Functions ---
  let infer-tax-it(rate) = {
    if rate == 22% {
      return tax.vat(22%) // Standard IVA
    } else if rate == 10% {
      return tax.lower-rate(10%) // Reduced (e.g., hotels, restaurants, specific foods)
    } else if rate == 5% {
      return tax.lower-rate(5%) // Super-reduced (e.g., some health services, specific foods)
    } else if rate == 4% {
      return tax.lower-rate(4%) // Super-reduced (e.g., basic necessities, books)
    } else if rate == 0% {
      panic(
        lang.errors.ambiguous-tax
          + "\n"
          + "Ambiguous 0% tax rate in region 'it'. Please explicitly use one of the constructors:\n"
          + "`tax.reverse-charge()` -> Reverse Charge (Inversione contabile)\n"
          + "`tax.intra-community()` -> Cessione intracomunitaria\n"
          + "`tax.exempt()` -> Esente IVA (Art. 10 DPR 633/72)\n"
          + "`tax.outside-scope()` -> Regime forfettario (Art. 1 c. 54-89 L. 190/2014) or fuori campo IVA.",
      )
    } else {
      panic(
        lang.errors.invalid-tax
          + "\n"
          + "Invalid tax rate: "
          + repr(rate)
          + ". Expected 22%, 10%, 5%, 4%, or a specific tax constructor.",
      )
    }
  }

  // --- Regional Data ---
  return (
    meta: (
      region: "it",
    ),

    normalize: (
      infer-tax: infer-tax-it,
    ),

    tax: (
      default-vat: tax.vat(22%),

      // Exemption for small enterprises (Regime forfettario)
      small-enterprise-special-scheme: tax.outside-scope(
        grounds: "Operazione in franchigia da IVA ai sensi dell'art. 1, commi da 54 a 89, della Legge n. 190/2014.",
      ),
    ),
  )
}
