#import "../loom-wrapper.typ": loom
#import "../data/tax.typ"
#import "../utils/format.typ" as m-format
#import "../utils/coercion.typ"

#let format-datetime(date) = date.display("[day].[month].[year]")
#let numeric-format = (
  decimal-sign: ",",
  thousand-separators: ".",
  padding: false,
  accuracy: 4,
)
#let currency-format = (currency: "€", location: end)

#let infer-tax-de(rate) = {
  if rate == 19% { return tax.vat(19%) } else if rate == 7% {
    return tax.lower-rate(7%)
  } else if rate == 0% {
    panic(
      "Ambiguous 0% tax rate detected! You must explicitly define the 0% category for legal compliance. "
        + "Please use one of the explicit constructors instead of a raw 0%:"
        + "`tax.reverse-charge()` -> B2B Reverse Charge (§13b UStG)"
        + "`tax.intra-community()` -> EU B2B Delivery (§4 Nr. 1b UStG)"
        + "`tax.export()` -> Non-EU Export (§4 Nr. 1a UStG)"
        + "`tax.exempt()` -> VAT Exemptions (§4 UStG)"
        + "`tax.outside-scope()` -> Small Business/Kleinunternehmer (§19 UStG) or out of scope.",
    )
  } else {
    panic(
      "Invalid German VAT rate detected: "
        + repr(rate)
        + ". Expected 19%, 7%, or a specific tax constructor.",
    )
  }
}

#let de(
  normalize: (:),
  format: (:),
  variables: (:),
) = {
  loom.collection.merge-deep(
    (
      lang: "de",

      normalize: (
        money: x => calc.round(coercion.to-decimal(x), digits: 2),
        money-fine: x => calc.round(coercion.to-decimal(x), digits: 4),
        infer-tax: infer-tax-de,
      ),

      variables: (
        small-biz-tax-exemption-code: tax.outside-scope(
          grounds: "Kleinunternehmen nach §19 UStG",
        ),
        vat: tax.vat(19%),
      ),

      format: (
        percent: x => str(calc.round(x * 100)) + "%",
        number: m-format.number.with(..numeric-format),
        currency: m-format.currency.with(
          ..currency-format,
          number-format: numeric-format + (accuracy: 2, padding: true),
        ),
        currency-fine: x => {
          let accuracy = if (
            calc.round(x, digits: 2) == calc.round(x, digits: 4)
          ) { 2 } else { 4 }
          m-format.currency(
            x,
            ..currency-format,
            number-format: numeric-format + (accuracy: accuracy, padding: true),
          )
        },
        date: date => {
          if type(date) == datetime { format-datetime(date) } else if (
            type(date) == array
          ) {
            (
              format-datetime(date.first())
                + " "
                + sym.dash.em
                + " "
                + format-datetime(date.last())
            )
          } else { none }
        },
      ),
    ),
    (
      normalize: normalize,
      format: format,
      variables: variables,
    ),
  )
}
