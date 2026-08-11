#import "loom-wrapper.typ": loom, weave
#import "components/root.typ": root
#import "data/tax.typ"
#import "utils/types.typ"
#import "themes/themes.typ"
#import "locale/locale.typ"

/// The main entry point for creating an invoice document.
/// It orchestrates the theme, localization, and data calculation passes.
///
/// -> content
#let invoice(
  /// The visual theme to apply to the invoice.
  /// -> function
  theme: themes.DIN-5008(),
  /// The locale settings for language and number formatting.
  /// -> function
  locale: locale.de,

  /// A dictionary containing sender details (e.g., name, address).
  /// -> dictionary
  sender: (:),
  /// A dictionary containing recipient details (e.g., name, address).
  /// -> dictionary
  recipient: (:),

  /// The date of the invoice. Defaults to today.
  /// -> datetime
  date: datetime.today(),
  /// The subject line of the invoice.
  /// -> string | content
  subject: "Rechnung",
  /// Reference information for the document header (e.g., customer number).
  /// -> none | dictionary | array
  references: none,
  /// The unique identifier or number of the invoice.
  /// -> none | string | content
  invoice-nr: none,
  /// Your unique tax identifier
  /// -> none | string | content
  tax-nr: none,

  /// The default tax rate to apply if not specified elsewhere.
  /// If `auto`, it is inferred from the locale.
  /// -> auto | ratio | dictionary | none
  tax: auto,
  /// Determines if prices are handled as inclusive or exclusive of tax.
  /// -> "inclusive" | "exclusive"
  tax-mode: "exclusive",
  /// If true, applies small business tax exemption logic according to the locale.
  /// -> bool
  tax-exempt-small-biz: false,

  /// The content of the invoice, typically containing line-items and other components.
  /// -> content
  body,
) = {
  types.require(theme, "invoice::theme", function)
  types.require(locale, "invoice::locale", function)

  types.require(sender, "invoice::sender", dictionary)
  types.require(recipient, "invoice::recipient", dictionary)

  types.require(date, "invoice::date", datetime)
  types.require(subject, "invoice::subject", str, content)
  types.require(
    references,
    "invoice::references",
    none,
    loom.matcher.dict(types.text-like),
    loom.matcher.many((
      types.text-like,
      types.text-like,
    )),
  )
  types.require(invoice-nr, "invoice::invoice-nr", none, str, content)
  types.require(tax-nr, "invoice::tax-nr", none, str, content)

  types.require(tax, "invoice::tax", none, auto, types.tax-like)
  types.require(tax-mode, "invoice::tax-mode", "inclusive", "exclusive")
  types.require(tax-exempt-small-biz, "invoice::tax-exempt-small-biz", bool)

  /** Input Calculations **/
  let eval-theme = theme()
  let eval-locale = locale()

  let document-subject = (subject, invoice-nr).join(" ")
  let document-tax = if tax != auto { tax } else { eval-locale.variables.vat }

  if tax-exempt-small-biz {
    if tax != auto {
      panic(
        "If using invoice::tax-exempt-small-biz then the tax must be set to `auto`",
      )
    }
    document-tax = eval-locale.variables.small-biz-tax-exemption-code
  }

  let document-references = ()
  if tax-nr != none {
    document-references.push(("Steuernummer", tax-nr))
  }

  if type(references) == array { document-references = references } else if (
    type(references) == dictionary
  ) {
    document-references = references.pairs()
  }

  let inputs = (
    theme: eval-theme,
    locale: eval-locale,
    format: eval-locale.at("format", default: (:)),

    sender: sender,
    recipient: recipient,

    invoice-date: date,
    subject: document-subject,
    references: document-references,
    invoice-nr: invoice-nr,
    tax-nr: tax-nr,

    tax: document-tax,
    tax-mode: tax-mode,
    tax-exempt-small-biz: tax-exempt-small-biz,
  )

  /** Data Calculations **/
  let weaved-body = weave(
    max-passes: 2,
    inputs: inputs,
    injector: (ctx, payload) => {
      ctx + (global: payload.first(default: (:)).at("signal", default: (:)))
    },
    root(body),
  )

  weaved-body
}
