#import "loom-wrapper.typ": loom, weave
#import "components/root.typ": root
#import "data/tax.typ"
#import "utils/types.typ"
#import "themes/themes.typ"

#import "locale/locale.typ"
#import "locale/lang/base.typ": base-language
#import "locale/region/base.typ": base-region
#import "logic/country.typ": normalize-party, resolve-party-country
#import "logic/party-inputs.typ": check-identifiers, identifier-keys
#import "logic/document-type.typ": document-title, resolve-document-type
#import "logic/notes.typ": normalize-notes
#import "logic/references.typ" as reference-builders
#import "data/currency.typ": with-currency

// The title the e-invoice compares with the document type (IP-DOC-01): the
// subject the sender gives, else `none` when it cannot name another kind of
// document. The default subject is the title the language of the locale
// gives the document type, which names that type (tests/zugferd/
// document-type); only a locale that titles an invoice otherwise than its
// language (e.g. "Proforma") has it checked.
#let _title-to-check(given, subject, document-type, lang) = {
  if given != auto { return given }
  if document-type != auto { return none }
  // Imported here: a module a function refers to is hashed with it, and the
  // languages are large.
  import "locale/lang/lang.typ" as languages
  let own = dictionary(languages)
    .at(lang, default: (:))
    .at("document", default: (:))
    .at("invoice", default: none)
  if subject != own { subject }
}

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
  /// The currency of the invoice, an ISO 4217 code such as `"USD"`: the
  /// e-invoice states it (BT-5), and the amounts are printed with its symbol
  /// ("$", "£", ...) or, if it has no common symbol, its code ("CHF", "SEK",
  /// ...) in the number format of the locale. `auto` is the currency of the
  /// locale.
  /// -> auto | str
  currency: auto,

  /// A dictionary containing sender details (e.g., name, address).
  /// -> dictionary
  sender: (:),
  /// A dictionary containing recipient details (e.g., name, address).
  /// -> dictionary
  recipient: (:),
  /// Separate delivery or shipping address (e.g. if different from billing address).
  /// Can also be specified as `recipient.delivery-address`. Without a
  /// `country` of its own, it is in the recipient's country.
  /// -> none | dictionary
  delivery-address: none,
  /// Who receives the payment instead of the seller, e.g. a factoring
  /// company: `(name: .., id: .., global-id: .., legal-id: ..)`, of which
  /// only `name` is required. Written into the e-invoice as the payee
  /// (BG-10), printed by the default `references` and
  /// `references.payee()`, and, except on a credit note, the account holder
  /// of `bank-details` unless they name another one.
  /// -> none | dictionary
  payee: none,

  /// Your company's unique tax identifier / VAT ID (backwards compatibility).
  /// -> none | string | content (deprecated)
  tax-nr: none,

  /// The date of the invoice. Defaults to today.
  /// -> datetime
  date: datetime.today(),
  /// The date or period `(start, end)` of the supply, printed by
  /// `references.service-time()` (which the default `references` include if
  /// it is given, and for a seller in Germany always) and written to the
  /// e-invoice (BT-72 or BG-14). If `none`, the earliest to the latest date
  /// of the items, or the invoice date if no item has a date, except on a
  /// credit note, which amends an invoice, and a prepayment invoice, which
  /// precedes the supply: they then state no date.
  /// -> none | datetime | array
  service-period: none,
  /// The subject line of the invoice. If `auto`, the title of the
  /// `document-type` in the language of the locale, e.g. "Rechnung".
  /// -> string | content
  subject: auto,
  /// The type of the document (BT-3 of the e-invoice): `"invoice"` (380),
  /// `"credit-note"` (381, amounts credited to the buyer, stated as positive
  /// amounts), `"corrected"` (384, replaces `preceding-invoice-nr`),
  /// `"prepayment"` (386), `"self-billed"` (389, issued by the buyer: the
  /// sender is the buyer and the recipient the seller), or another code of
  /// UNTDID 1001 for invoices and credit notes, e.g. `"326"` for a partial
  /// invoice. `auto` is an invoice.
  /// -> auto | str | int
  document-type: auto,
  /// Reference information for the document header (e.g., customer number).
  /// If `auto`, what the law requires on the invoice, with net and gross
  /// prices alike: the seller's tax number and VAT ID (the recipient's on a
  /// self-billed invoice) and the buyer's VAT ID, the date of the supply (the
  /// `service-period`, for a seller in Germany always, else only if it is
  /// given), the `payee` and the `preceding-invoice-nr` and
  /// `preceding-invoice-date`, each if it is given.
  /// -> auto | none | dictionary | array | function
  references: auto,
  /// The unique identifier or number of the invoice.
  /// -> none | string | content
  invoice-nr: none,

  /// Customer number or client identifier.
  /// -> none | string | content
  customer-nr: none,
  /// Order / purchase order number (PO number).
  /// -> none | string | content
  order-nr: none,
  /// Order placement date.
  /// -> none | datetime | string | content
  order-date: none,
  /// Project name or reference code.
  /// -> none | string | content
  project: none,
  /// Contract or framework agreement number.
  /// -> none | string | content
  contract-nr: none,
  /// Quote or estimate reference number.
  /// -> none | string | content
  quote-nr: none,
  /// Delivery note / shipping advice number.
  /// -> none | string | content
  delivery-note-nr: none,
  /// Preceding invoice number (for credit notes / corrections).
  /// -> none | string | content
  preceding-invoice-nr: none,
  /// The date of the preceding invoice (BT-26 of the e-invoice), next to
  /// `preceding-invoice-nr`.
  /// -> none | datetime
  preceding-invoice-date: none,
  /// Explicit due date for payment.
  /// -> none | datetime | string | content
  due-date: none,
  /// Custom payment reference / purpose (Verwendungszweck).
  /// -> none | string | content
  payment-reference: none,
  /// Notes about the invoice as a whole: a text, or an array of texts and
  /// dictionaries `(text: .., subject-code: ..)` with a UNTDID 4451 subject
  /// code (e.g. `"AAI"`). They are printed below the line items and written
  /// into the e-invoice (BT-22, BT-21).
  /// -> none | str | content | array
  notes: none,

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
  /// `auto` chooses the richest profile the invoice satisfies: `"xrechnung"`
  /// for a buyer in Germany, otherwise `"en16931"`.
  /// -> none | auto | "minimum" | "basic-wl" | "basic" | "en16931" | "xrechnung"
  zugferd: none,
  /// What to do when the e-invoice data violates the rules of the profile.
  /// `"panic"` stops the compilation with a list of all problems, `"report"`
  /// lists them in the document instead and attaches the XML of an invoice
  /// with errors only as a draft (`invoice-draft.xml`), and `"ignore"`
  /// attaches the XML as usual anyway.
  /// -> "panic" | "report" | "ignore"
  zugferd-errors: "panic",

  /// The content of the invoice, typically containing line-items and other components.
  /// -> content
  body,
) = {
  types.require(theme, "invoice::theme", function)
  types.require(locale, "invoice::locale", function)
  types.require(currency, "invoice::currency", auto, str)

  types.require(sender, "invoice::sender", dictionary)
  types.require(recipient, "invoice::recipient", dictionary)
  types.require(
    delivery-address,
    "invoice::delivery-address",
    none,
    dictionary,
  )
  types.require(
    recipient.at("delivery-address", default: none),
    "invoice::recipient.delivery-address",
    none,
    dictionary,
  )
  types.require(payee, "invoice::payee", none, dictionary)
  types.require(
    sender.at("tax-representative", default: none),
    "invoice::sender.tax-representative",
    none,
    dictionary,
  )
  // An identifier that produces no text (e.g. `legal-id: id.siret` without
  // calling it) would be missing from the printed invoice and the e-invoice.
  check-identifiers(sender, "sender", identifier-keys.sender)
  check-identifiers(recipient, "recipient", identifier-keys.recipient)
  check-identifiers(
    delivery-address,
    "delivery-address",
    identifier-keys.delivery-address,
  )
  check-identifiers(
    recipient.at("delivery-address", default: none),
    "recipient.delivery-address",
    identifier-keys.delivery-address,
  )
  check-identifiers(payee, "payee", identifier-keys.payee)

  types.require(date, "invoice::date", datetime)
  types.require(
    service-period,
    "invoice::service-period",
    none,
    types.date-like,
  )
  // Every date names its day (not a time only).
  for (value, name) in (
    (date, "invoice::date"),
    (service-period, "invoice::service-period"),
    (order-date, "invoice::order-date"),
    (recipient.at("order-date", default: none), "recipient.order-date"),
    (preceding-invoice-date, "invoice::preceding-invoice-date"),
    (due-date, "invoice::due-date"),
  ) {
    if value != none { types.require-day(value, name) }
  }
  if (
    type(service-period) == array
      and service-period.last() < service-period.first()
  ) {
    panic(
      "invoice::service-period ends before it starts: "
        + service-period.first().display()
        + " to "
        + service-period.last().display()
        + ". Give it as `(start, end)`.",
    )
  }
  types.require(subject, "invoice::subject", auto, str, content)
  types.require(document-type, "invoice::document-type", auto, str, int)
  types.require(
    references,
    "invoice::references",
    auto,
    none,
    function,
    loom.matcher.dict(loom.matcher.choice(types.text-like, function)),
    loom.matcher.many(loom.matcher.choice(
      function,
      array,
      (types.text-like, types.text-like),
      (types.text-like, function),
    )),
  )
  types.require(invoice-nr, "invoice::invoice-nr", none, str, content)
  types.require(customer-nr, "invoice::customer-nr", none, str, content)
  types.require(order-nr, "invoice::order-nr", none, str, content)
  types.require(order-date, "invoice::order-date", none, datetime, str, content)
  types.require(project, "invoice::project", none, str, content)
  types.require(contract-nr, "invoice::contract-nr", none, str, content)
  types.require(quote-nr, "invoice::quote-nr", none, str, content)
  types.require(
    delivery-note-nr,
    "invoice::delivery-note-nr",
    none,
    str,
    content,
  )
  types.require(
    preceding-invoice-nr,
    "invoice::preceding-invoice-nr",
    none,
    str,
    content,
  )
  types.require(
    preceding-invoice-date,
    "invoice::preceding-invoice-date",
    none,
    datetime,
  )
  types.require(due-date, "invoice::due-date", none, datetime, str, content)
  types.require(
    payment-reference,
    "invoice::payment-reference",
    none,
    str,
    content,
  )
  types.require(tax-nr, "invoice::tax-nr", none, str, content)
  types.require(notes, "invoice::notes", none, str, content, array)

  types.require(tax, "invoice::tax", none, auto, types.tax-like)
  types.require(tax-mode, "invoice::tax-mode", "inclusive", "exclusive")
  types.require(tax-exempt-small-biz, "invoice::tax-exempt-small-biz", bool)
  types.require(
    zugferd,
    "invoice::zugferd",
    none,
    auto,
    "minimum",
    "basic-wl",
    "basic",
    "en16931",
    "xrechnung",
  )
  types.require(
    zugferd-errors,
    "invoice::zugferd-errors",
    "panic",
    "report",
    "ignore",
  )

  /** Input Calculations **/
  let eval-theme = theme()
  let eval-locale = locale(base-language, base-region)
  if currency != auto { eval-locale = with-currency(eval-locale, currency) }
  let document = resolve-document-type(document-type)

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

  let resolved-recipient-country = resolve-party-country(
    recipient,
    default-region,
    field: "recipient",
  ).country

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
  // The seller's tax representative has an address of its own; without a
  // `country`, it is in the country of the locale.
  let tax-representative = sender.at("tax-representative", default: none)
  if tax-representative != none {
    normalized-sender.insert("tax-representative", normalize-party(
      tax-representative,
      default-region,
      field: "sender.tax-representative",
    ))
  }

  let raw-delivery-address = if delivery-address != none {
    delivery-address
  } else if (
    "delivery-address" in recipient and recipient.delivery-address != none
  ) {
    recipient.delivery-address
  } else {
    none
  }
  // Without a country of its own, the delivery address is in the buyer's
  // country, not in the country of the locale: the recipient's, or the
  // sender's on a self-billed invoice, which the buyer issues.
  let normalized-delivery-address = if raw-delivery-address != none {
    normalize-party(
      raw-delivery-address,
      default-region,
      is-recipient: true,
      sender-country-code: normalized-sender.country.code,
      default-country: if document.self-billed {
        normalized-sender.country
      } else { normalized-recipient.country },
      field: if delivery-address != none { "delivery-address" } else {
        "recipient.delivery-address"
      },
    )
  } else {
    none
  }
  if normalized-delivery-address != none {
    normalized-recipient.insert("delivery-address", normalized-delivery-address)
  }

  let given-subject = subject
  if subject == auto { subject = document-title(document, eval-locale.strings) }

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
  if references == auto {
    // What the law requires on every invoice besides the parties and the
    // items, also with gross prices (B2C), and what the e-invoice states:
    // - the seller's tax number or VAT identification number (§ 14 Abs. 4
    //   Satz 1 Nr. 2 UStG, Art. 226 No. 3 of the VAT Directive; BT-31,
    //   BT-32), the recipient's on a self-billed invoice, and the buyer's
    //   VAT identification number (Art. 226 No. 4; BT-48). An invoice of up
    //   to 250 EUR may leave out the seller's (§ 33 UStDV), but the printed
    //   invoice then would not state what the e-invoice states;
    // - the date of the supply (BT-72, BG-14): the invoice's
    //   `service-period`, and for a seller in Germany in any case, as § 14
    //   Abs. 4 Satz 1 Nr. 6 UStG requires it also when it is the date of the
    //   invoice: the dates of the items or the invoice date, which the
    //   e-invoice states then. Elsewhere, only a date that differs from the
    //   invoice date is required (Art. 226 No. 7), which the dates of the
    //   items state where the items print them;
    // - the payee (BG-10), who receives the payment instead of the seller;
    // - the preceding invoice (BG-3) of a document that amends an invoice
    //   (Art. 219 of the VAT Directive).
    let seller = if document.self-billed { normalized-recipient } else {
      normalized-sender
    }
    let seller-country = seller.country.at("code", default: none)
    document-references = (
      reference-builders.seller-tax-nr(),
      reference-builders.seller-vat-id(),
      reference-builders.buyer-vat-id(),
    )
    if service-period != none or seller-country == "DE" {
      document-references.push(reference-builders.service-time())
    }
    if payee != none { document-references.push(reference-builders.payee()) }
    let labels = eval-locale.strings.reference
    if preceding-invoice-nr not in (none, "", []) {
      document-references.push((
        labels.preceding-invoice-number,
        preceding-invoice-nr,
      ))
    }
    if preceding-invoice-date != none {
      document-references.push((
        labels.preceding-invoice-date,
        (eval-locale.format.date)(preceding-invoice-date),
      ))
    }
  } else if type(references) == function {
    document-references = references
  } else if type(references) == array {
    document-references = references
  } else if type(references) == dictionary {
    document-references = references.pairs()
  }

  let inputs = (
    theme: eval-theme,
    locale: eval-locale,
    format: eval-locale.at("format", default: (:)),

    sender: normalized-sender,
    recipient: normalized-recipient,
    delivery-address: normalized-delivery-address,
    payee: payee,

    invoice-date: date,
    subject: document-subject,
    references: document-references,
    invoice-nr: invoice-nr,

    customer-nr: customer-nr,
    order-nr: order-nr,
    order-date: order-date,
    project: project,
    contract-nr: contract-nr,
    quote-nr: quote-nr,
    delivery-note-nr: delivery-note-nr,
    preceding-invoice-nr: preceding-invoice-nr,
    due-date: due-date,
    payment-reference: payment-reference,

    tax: document-tax,
    tax-mode: tax-mode,
    tax-exempt-small-biz: tax-exempt-small-biz,

    zugferd: zugferd,
    zugferd-errors: zugferd-errors,
  )
  // Document data most invoices leave out joins the context only if it is
  // given: the context reaches every component and call, and each value it
  // carries costs time on long invoices. It is read with a default.
  for (key, value) in (
    // The invoice's own `currency`, which `eval-locale` already invoices in.
    currency: currency,
    service-period: service-period,
    // The title of the document (the subject without the invoice number),
    // which the e-invoice compares with the document type (IP-DOC-01).
    title: if zugferd != none {
      _title-to-check(given-subject, subject, document-type, eval-locale.lang)
    },
    // The resolved `document-type`, see `resolve-document-type`.
    document-type: if document-type != auto { document },
    preceding-invoice-date: preceding-invoice-date,
    // `(text: .., subject-code: ..)` each, see `normalize-notes`.
    notes: normalize-notes(notes),
  ) {
    if value not in (none, auto, ()) { inputs.insert(key, value) }
  }

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
