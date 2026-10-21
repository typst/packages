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

// The key of the VAT group (rate and category) a tax belongs to. The rate may
// be a ratio (`19%`) or decimal-like (`0.19`), as in a hand-built dictionary.
#let to-tax-key(tax) = {
  return str(coercion.to-ratio(tax.rate)) + "-" + tax.category
}

/// Creates a tax of any UNTDID 5305 category, for cases the constructors below
/// do not cover.
///
/// -> dictionary
#let new(
  /// The tax rate, e.g. `19%` or `0%`.
  /// -> ratio | int | float | decimal | str
  rate: 0%,
  /// The UNTDID 5305 tax category code, e.g. `"S"` or `"E"`.
  /// -> str
  category: "",
  /// A human-readable identifier of the tax type.
  /// -> str | content
  label: "",
  /// The legal reason of an exemption or a 0% rate.
  /// -> str | content | none
  grounds: none,
  /// The VAT exemption reason code of the CEF VATEX code list (BT-121 of
  /// the e-invoice), e.g. `"VATEX-EU-132-1A"`, next to the `grounds` the
  /// invoice prints. Only a tax that is exempt or not charged has one.
  /// -> none | str
  code: none,
) = {
  if code != none and type(code) != str {
    assert(
      false,
      message: "tax: `code` must be a VAT exemption reason code of the VATEX code list such as \"VATEX-EU-132-1A\", got "
        + repr(code)
        + ".",
    )
  }
  (
    rate: coercion.to-ratio(rate),
    category: category,
    label: label,
    grounds: grounds,
    // Only a tax with a code carries the key, so that the tax of most items
    // stays as small as before.
    ..if code != none { (code: code) },
  )
}

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
#let reverse-charge(grounds: "Reverse charge", code: none) = new(
  rate: 0%,
  category: "AE",
  label: "reverse-charge",
  grounds: grounds,
  code: code,
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
#let exempt(grounds: none, code: none) = new(
  rate: 0%,
  category: "E",
  label: "exempt",
  grounds: grounds,
  code: code,
)

// F: Value Added Tax (VAT) margin scheme - second-hand goods
#let margin-second-hand(rate, grounds: none) = new(
  rate: rate,
  category: "F",
  label: "margin-second-hand",
  grounds: grounds,
)

// G: Free export item, tax not charged
#let export(grounds: none, code: none) = new(
  rate: 0%,
  category: "G",
  label: "export",
  grounds: grounds,
  code: code,
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
#let intra-community(grounds: none, code: none) = new(
  rate: 0%,
  category: "K",
  label: "intra-community",
  grounds: grounds,
  code: code,
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
#let outside-scope(grounds: none, code: none) = new(
  rate: 0%,
  category: "O",
  label: "outside-scope",
  grounds: grounds,
  code: code,
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

// The tax of an item for which no tax is set anywhere (`tax: none` on the
// invoice). The printed invoice treats it as zero rated (Z), but "no tax" does
// not say which of the 0% categories (Z, E, O, ...) applies, so it is marked
// `implicit` and an e-invoice must not declare it as a zero rated supply.
#let implicit-zero() = (..zero(), label: "implicit-zero", implicit: true)

// A tax for messages, e.g. "19% S".
#let describe(tax) = (
  str(calc.round(float(coercion.to-ratio(tax.rate)) * 100, digits: 2))
    + "% "
    + tax.category
)

// Whether a tax is the placeholder of `implicit-zero`.
#let is-implicit(tax) = (
  type(tax) == dictionary and tax.at("implicit", default: false) == true
)

// A hand-built tax dictionary, normalized like the constructors: the rate
// becomes a decimal ratio and missing keys get their defaults. Other keys
// (such as `implicit`) are kept.
#let normalize(value) = (
  value
    + new(
      rate: value.at("rate", default: 0%),
      category: value.at("category", default: ""),
      label: value.at("label", default: ""),
      grounds: value.at("grounds", default: none),
      code: value.at("code", default: none),
    )
)

#let to-tax(value) = {
  if type(value) == ratio {
    vat(value)
  } else if type(value) == dictionary {
    normalize(value)
  } else if value == "exempt" {
    exempt()
  } else if value == "reverse-charge" {
    reverse-charge()
  } else if value == auto {
    auto
  } else if value == none {
    implicit-zero()
  } else {
    panic("Invalid Tax Type!")
  }
}

// Resolves the tax input of a component (`name` is used in error messages):
// a ratio is mapped to a tax by the region of the locale, a dictionary is
// normalized, `none` becomes `implicit-zero` and `auto` stays `auto`.
#let resolve(ctx, value, name) = {
  if type(value) == ratio {
    let infer-tax = (
      ctx
        .at("locale", default: (:))
        .at("normalize", default: (:))
        .at("infer-tax", default: (..) => panic(
          name + "::tax can not be of type `ratio`.",
        ))
    )
    infer-tax(value)
  } else {
    to-tax(value)
  }
}

// --- Exemption grounds ---

// Whether exemption grounds carry any text.
#let has-grounds(grounds) = grounds not in (none, "", [], [ ])

// The text an exemption ground is compared by, so that the same reason given
// as a string and as content is listed once.
#let grounds-key(grounds) = {
  let text = coercion.to-string(grounds)
  if type(text) == str { text.trim() } else { repr(grounds) }
}

// The distinct exemption grounds of a tax. The virtual item of a bundle can
// carry several (`grounds-list`), every other tax at most one (`grounds`).
#let grounds-of(tax) = {
  let list = tax.at("grounds-list", default: none)
  if type(list) == array { return list }
  let grounds = tax.at("grounds", default: none)
  if has-grounds(grounds) { (grounds,) } else { () }
}

// Adds the grounds of `more` that are not in `list` yet (compared by text).
#let merge-grounds(list, more) = {
  let keys = list.map(grounds-key)
  for grounds in more {
    let key = grounds-key(grounds)
    if key not in keys {
      list.push(grounds)
      keys.push(key)
    }
  }
  list
}

// The note of the language strings (`tax-exemption`) for a VAT category that
// needs an exemption reason (BR-AE-10, BR-IC-10, BR-G-10, BR-O-10) when its
// items give no grounds, or `none` for the other categories (and without a
// category).
#let default-grounds(category, strings) = {
  if type(category) != str { return none }
  let key = (
    AE: "reverse-charge",
    K: "intra-community",
    G: "export",
    O: "outside-scope",
  ).at(category, default: none)
  if key == none { return none }
  strings.at("tax-exemption", default: (:)).at(key, default: none)
}

// The distinct VAT exemption reason codes of a tax (BT-121): the virtual item
// of a bundle and a VAT group can carry several (`codes`), every other tax at
// most one (`code`).
#let codes-of(tax) = {
  let list = tax.at("codes", default: none)
  if type(list) == array { return list }
  let code = tax.at("code", default: none)
  if code == none { () } else { (code,) }
}

// Adds the codes of `more` that are not in `list` yet.
#let merge-codes(list, more) = {
  for code in more {
    if code not in list { list.push(code) }
  }
  list
}

// All exemption grounds of a VAT category as one value: `none`, the single
// ground, or every distinct ground joined with "; " (EN 16931 allows one
// exemption reason, BT-120, per VAT category).
#let join-grounds(list) = {
  if list.len() == 0 { none } else if list.len() == 1 { list.first() } else {
    list.join("; ")
  }
}
