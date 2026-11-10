#import "loom-wrapper.typ": loom, weave
#import "components/root.typ": root
#import "data/tax.typ"
#import "utils/types.typ"
#import "themes/themes.typ"

#import "locale/locale.typ"
#import "locale/lang/base.typ": base-language
#import "locale/region/base.typ": base-region
#import "logic/country.typ": (
  normalize-party, normalize-region-to-string, resolve-country,
)

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
  locale: locale.de-de,

  /// A dictionary containing sender details (e.g., name, address).
  /// -> dictionary
  sender: (:),
  /// A dictionary containing recipient details (e.g., name, address).
  /// -> dictionary
  recipient: (:),

  /// Your company's unique tax identifier / VAT ID (backwards compatibility).
  /// -> none | string | content (deprecated)
  tax-nr: none,

  /// The date of the invoice. Defaults to today.
  /// -> datetime
  date: datetime.today(),
  /// The subject line of the invoice.
  /// -> string | content
  subject: auto,
  /// Reference information for the document header (e.g., customer number).
  /// -> none | dictionary | array
  references: none,
  /// The unique identifier or number of the invoice.
  /// -> none | string | content
  invoice-nr: none,

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

  /// ZUGFeRD / Factur-X profile for embedding machine-readable XML into the PDF.
  /// Requires exporting with PDF/A-3 (`typst compile --pdf-standard=a-3b`).
  /// -> none | "minimum" | "basic-wl" | "basic" | "en16931"
  zugferd: none,

  /// The content of the invoice, typically containing line-items and other components.
  /// -> content
  body,
) = {
  types.require(theme, "invoice::theme", function)
  types.require(locale, "invoice::locale", function)

  types.require(sender, "invoice::sender", dictionary)
  types.require(recipient, "invoice::recipient", dictionary)

  types.require(date, "invoice::date", datetime)
  types.require(subject, "invoice::subject", auto, str, content)
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
  types.require(
    zugferd,
    "invoice::zugferd",
    none,
    "minimum",
    "basic-wl",
    "basic",
    "en16931",
    "xrechnung",
  )

  /** Input Calculations **/
  let eval-theme = theme()
  let eval-locale = locale(base-language, base-region)

  let default-region = eval-locale.meta.region
  let sender = sender
  if tax-nr != none {
    if zugferd != none {
      panic(
        "Top-level 'tax-nr' is not allowed when 'zugferd' (e-invoicing) is enabled. Please specify 'tax-nr' inside the 'sender' dictionary instead.",
      )
    }
    if "tax-nr" in sender and sender.tax-nr != none {
      panic(
        "Both the top-level 'tax-nr' parameter and 'sender.tax-nr' are populated, but they are mutually exclusive.",
      )
    }
    sender.insert("tax-nr", tax-nr)
  }

  let recipient-region = normalize-region-to-string(
    recipient.at("region", default: none),
    default-region,
  )
  let resolved-recipient-country = resolve-country(
    recipient.at("country", default: auto),
    recipient-region,
  )

  let normalized-sender = normalize-party(
    sender,
    default-region,
    recipient-country-code: resolved-recipient-country.code,
  )
  let normalized-recipient = normalize-party(
    recipient,
    default-region,
    is-recipient: true,
    sender-country-code: normalized-sender.country.code,
  )

  if subject == auto { subject = eval-locale.strings.document.invoice }

  let document-subject = (subject, invoice-nr).join(" ")
  let document-tax = if tax != auto { tax } else { eval-locale.tax.default-vat }

  if tax-exempt-small-biz {
    if tax != auto {
      panic(
        "If using invoice::tax-exempt-small-biz then the tax must be set to `auto`",
      )
    }
    document-tax = eval-locale.tax.small-enterprise-special-scheme
  }

  let document-references = ()
  let sender-tax-nr = normalized-sender.tax-nr
  if sender-tax-nr != none and sender-tax-nr != "" {
    document-references.push((
      eval-locale.strings.reference.tax-number,
      sender-tax-nr,
    ))
  }
  let sender-vat-id = normalized-sender.vat-id
  if sender-vat-id != none and sender-vat-id != "" {
    document-references.push((
      eval-locale.strings.reference.vat-id,
      sender-vat-id,
    ))
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

    sender: normalized-sender,
    recipient: normalized-recipient,

    invoice-date: date,
    subject: document-subject,
    references: document-references,
    invoice-nr: invoice-nr,

    tax: document-tax,
    tax-mode: tax-mode,
    tax-exempt-small-biz: tax-exempt-small-biz,

    zugferd: zugferd,
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
