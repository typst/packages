/// The base region serves as the 'Master Schema' for all regional configurations.
/// Every regional file (e.g., DE.typ, US.typ) should mirror this structure.
#let base-region = {
  import "../../data/tax.typ"
  import "../../utils/format.typ"

  let numeric-format = (
    decimal-sign: ",",
    thousand-separators: ".",
    padding: false,
    accuracy: 4,
  )

  let currency-meta = (
    /// The 3-letter ISO 4217 currency code (e.g., "EUR", "CHF").
    /// Required for EPC-QR payloads and ZUGFeRD.
    code: "EUR",

    /// The visual symbol of the currency (e.g., "€", "CHF ").
    symbol: "€",

    /// The standard number of subunits/decimal places for financial totals (e.g., 2).
    decimals: 2,

    /// The allowed number of decimal places for singular unit prices.
    /// EN 16931 allows up to 4 decimal places for unit prices (BT-146).
    decimals-fine: 4,
  )

  (
    meta: (
      /// The 2-letter (lower-case) ISO 3166-1 alpha-2 country code (e.g., "de", "ch").
      /// Required for ZUGFeRD compliance (Buyer/Seller country codes).
      /// -> str
      region: "base",
    ),

    /// Metadata for the primary currency used in the region.
    currency: currency-meta,

    normalize: (
      /// Rounds a numerical value to the standard decimal precision of the region's currency.
      /// Used for final totals and line item sums.
      /// -> (int | float | decimal) => (int | float | decimal)
      money: x => calc.round(x, digits: currency-meta.decimals),

      /// Rounds a value to the precision required for unit prices or internal calculations.
      /// Useful for high-precision items (e.g., fuel prices or bulk commodities).
      /// -> (int | float | decimal) => (int | float | decimal)
      money-fine: x => calc.round(x, digits: currency-meta.decimals-fine),

      /// A function that interprets a raw tax value (usually a percentage or ratio)
      /// and maps it to a structured regional tax object.
      /// -> (ratio | float | decimal | int) => tax
      infer-tax: x => panic("Can't infer tax for region:`base`!"),
    ),

    format: (
      /// Converts a ratio (0.19) or number into a localized percentage string ("19%").
      /// -> (ratio | float | decimal | int) => str
      percent: x => {
        let p = float(x) * 100
        str(calc.round(p, digits: 1)).replace(".", ",") + "%"
      },

      /// Formats a single date or a range (start, end) into a human-readable string.
      /// Handles both `datetime` objects and arrays of two `datetime` objects.
      /// -> (datetime | (datetime, datetime)) => str
      date: x => if type(x) == array {
        x.first().display("[day].[month].[year]")
        " "
        sym.dash.em
        " "
        x.last().display("[day].[month].[year]")
      } else if type(x) == datetime {
        x.display("[day].[month].[year]")
      },

      /// Formats a time object into a localized string (e.g., 24h or AM/PM).
      /// -> datetime => str
      time: x => x.display("[hour repr:24]:[minute padding:zero]"),

      // Dynamically injects `number`, `currency`, and `currency-fine`
    )
      + format.make-formatters(numeric-format, currency-meta),
    tax: (
      /// The standard VAT/Sales Tax rate applied when no specific rate is provided.
      /// -> tax
      default-vat: tax.vat(21%),

      /// The legal tax object/exemption text used for small businesses or
      /// "Kleinunternehmer" schemes where VAT is not collected.
      /// -> tax
      small-enterprise-special-scheme: tax.outside-scope(),
    ),
  )
}
