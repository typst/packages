#import "../utils/coercion.typ"

// UNTDID 5305
// https://vocabulary.uncefact.org/TaxCategoryCodeList
#let tax-category-db = (
  (code: "A", name: "Mixed tax rate"),
  (code: "AA", name: "Lower rate"),
  (code: "AB", name: "Exempt for resale"),
  (code: "AC", name: "Value Added Tax (VAT) not now due for payment"),
  (code: "AD", name: "Value Added Tax (VAT) due from a previous invoice"),
  (code: "AE", name: "VAT Reverse Charge"),
  (code: "B", name: "Transferred (VAT)"),
  (code: "C", name: "Duty paid by supplier"),
  (code: "D", name: "Value Added Tax (VAT) margin scheme - travel agents"),
  (code: "E", name: "Exempt from tax"),
  (code: "F", name: "Value Added Tax (VAT) margin scheme - second-hand goods"),
  (code: "G", name: "Free export item, tax not charged"),
  (code: "H", name: "Higher rate"),
  (
    code: "I",
    name: "Value Added Tax (VAT) margin scheme - works of art Margin scheme — Works of art",
  ),
  (
    code: "J",
    name: "Value Added Tax (VAT) margin scheme - collector’s items and antiques",
  ),
  (
    code: "K",
    name: "VAT exempt for EEA intra-community supply of goods and services",
  ),
  (code: "L", name: "Canary Islands general indirect tax"),
  (
    code: "M",
    name: "Tax for production, services and importation in Ceuta and Melilla",
  ),
  (code: "N", name: "standard rate additional VAT"),
  (code: "O", name: "Services outside scope of tax"),
  (code: "S", name: "Standard rate"),
  (code: "Z", name: "Zero rated goods"),
)

#let to-tax-key(tax) = {
  return str(coercion.to-decimal(tax.rate)) + "-" + tax.category
}

#let to-tax(value) = {
  if type(value) == ratio {
    vat(value)
  } else if type(value) == dictionary {
    value
  } else if value == "exempt" {
    exempt()
  } else if value == "reverse-charge" {
    reverse-charge()
  } else if value == auto {
    auto
  } else if value == none {
    zero()
  } else {
    panic("Invalid Tax Type!")
  }
}

#let new(
  rate: 0%,
  category: "",
  label: "",
  grounds: none,
) = (
  rate: coercion.to-ratio(rate),
  category: category,
  label: label,
  grounds: grounds,
)

// A: Mixed tax rate
#let mixed(rate, grounds: none) = new(
  rate: rate,
  category: "A",
  label: "mixed",
  grounds: grounds,
)

// AA: Lower rate
#let lower-rate(rate, grounds: none) = new(
  rate: rate,
  category: "AA",
  label: "lower-rate",
  grounds: grounds,
)

// AB: Exempt for resale
#let exempt-for-resale(grounds: none) = new(
  rate: 0%,
  category: "AB",
  label: "exempt-for-resale",
  grounds: grounds,
)

// AC: Value Added Tax (VAT) not now due for payment
#let vat-not-due(rate, grounds: none) = new(
  rate: rate,
  category: "AC",
  label: "vat-not-due",
  grounds: grounds,
)

// AD: Value Added Tax (VAT) due from a previous invoice
#let vat-previous(rate, grounds: none) = new(
  rate: rate,
  category: "AD",
  label: "vat-previous",
  grounds: grounds,
)

// AE: VAT Reverse Charge
#let reverse-charge(grounds: none) = new(
  rate: 0%,
  category: "AE",
  label: "reverse-charge",
  grounds: grounds,
)

// B: Transferred (VAT)
#let transferred(rate, grounds: none) = new(
  rate: rate,
  category: "B",
  label: "transferred",
  grounds: grounds,
)

// C: Duty paid by supplier
#let duty-paid(rate, grounds: none) = new(
  rate: rate,
  category: "C",
  label: "duty-paid",
  grounds: grounds,
)

// D: Value Added Tax (VAT) margin scheme - travel agents
#let margin-travel(rate, grounds: none) = new(
  rate: rate,
  category: "D",
  label: "margin-travel",
  grounds: grounds,
)

// E: Exempt from tax
#let exempt(grounds: none) = new(
  rate: 0%,
  category: "E",
  label: "exempt",
  grounds: grounds,
)

// F: Value Added Tax (VAT) margin scheme - second-hand goods
#let margin-second-hand(rate, grounds: none) = new(
  rate: rate,
  category: "F",
  label: "margin-second-hand",
  grounds: grounds,
)

// G: Free export item, tax not charged
#let export(grounds: none) = new(
  rate: 0%,
  category: "G",
  label: "export",
  grounds: grounds,
)

// H: Higher rate
#let higher-rate(rate, grounds: none) = new(
  rate: rate,
  category: "H",
  label: "higher-rate",
  grounds: grounds,
)

// I: Value Added Tax (VAT) margin scheme - works of art
#let margin-art(rate, grounds: none) = new(
  rate: rate,
  category: "I",
  label: "margin-art",
  grounds: grounds,
)

// J: Value Added Tax (VAT) margin scheme - collector’s items and antiques
#let margin-antiques(rate, grounds: none) = new(
  rate: rate,
  category: "J",
  label: "margin-antiques",
  grounds: grounds,
)

// K: VAT exempt for EEA intra-community supply of goods and services
#let intra-community(grounds: none) = new(
  rate: 0%,
  category: "K",
  label: "intra-community",
  grounds: grounds,
)

// L: Canary Islands general indirect tax (IGIC)
#let canary-islands(rate, grounds: none) = new(
  rate: rate,
  category: "L",
  label: "canary-islands",
  grounds: grounds,
)

// M: Tax for production, services and importation in Ceuta and Melilla (IPSI)
#let ceuta-melilla(rate, grounds: none) = new(
  rate: rate,
  category: "M",
  label: "ceuta-melilla",
  grounds: grounds,
)

// N: Standard rate additional VAT
#let standard-additional(rate, grounds: none) = new(
  rate: rate,
  category: "N",
  label: "standard-additional",
  grounds: grounds,
)

// O: Services outside scope of tax
#let outside-scope(grounds: none) = new(
  rate: 0%,
  category: "O",
  label: "outside-scope",
  grounds: grounds,
)

// S: Standard rate
#let vat(rate, grounds: none) = new(
  rate: rate,
  category: "S",
  label: "vat",
  grounds: grounds,
)

// Z: Zero rated goods
#let zero(grounds: none) = new(
  rate: 0%,
  category: "Z",
  label: "zero",
  grounds: grounds,
)
