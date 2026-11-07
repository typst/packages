#let resolve-plural(v, n) = {
  if type(v) != dictionary { return v }
  if v.len() == 0 { return none }
  let num = if type(n) == decimal or type(n) == int or type(n) == float {
    float(n)
  } else if type(n) == str {
    float(n)
  } else {
    1.0
  }
  let fallback = v.pairs().first(default: (none, none)).last()
  if num == 1 {
    v.at("singular", default: fallback)
  } else {
    v.at("plural", default: fallback)
  }
}

/// The Base-Language Dictionary serves as the structural template (schema) for all
/// other language files (e.g., de.typ, fr.typ).
/// It contains exclusively linguistic strings and formatting text.
#let base-language = (
  meta: (
    /// The ISO 639-1 language code of the file (e.g., "en", "de").
    /// Sets the document language (`text.lang`); "base" resolves to "en".
    lang: "base",
    /// Plural resolution function for units and language strings.
    /// -> (any, int | float | decimal | str) => any
    resolve-plural: resolve-plural,
  ),

  /// Designations for document types: the default title of the document
  /// (`invoice(document-type: ..)`).
  document: (
    invoice: "Invoice",
    /// A credit note (381), which credits amounts to the buyer.
    credit-note: "Credit Note",
    /// A corrected invoice (384), which replaces the preceding invoice.
    corrected: "Corrected Invoice",
    /// A prepayment invoice (386) for an advance payment.
    prepayment: "Prepayment Invoice",
    /// A self-billed invoice (389), issued by the buyer. The VAT Directive
    /// (Art. 226 No. 10a) requires the mention "Self-billing" on it.
    self-billed: "Self-Billing Invoice",
    // Page label of the page-number part.
    // -> (int, int) => content
    page: (current, total) => [Page #current of #total],
    // Note at the foot of a page whose content continues.
    // -> (int) => content
    continued-on: page => [Continued on page #page],
  ),

  /// Address-related designations
  address: (
    recipient: "Bill To",
    sender: "From",
  ),

  /// Section headings a theme may print (PROVISIONAL group, 0.6.x): labels of page
  /// sections. The recipient block reuses `address.recipient`, due dates
  /// `reference.due-date`.
  sections: (
    details: "Invoice details",
    payment: "Payment",
    bank-details: "Bank details",
    how-to-pay: "How to pay",
  ),

  /// Designations for reference numbers and metadata
  reference: (
    tax-number: "Tax ID",
    invoice-number: "Invoice Number",
    vat-id: "VAT ID",
    invoice-date: "Invoice Date",
    service-time: "Period of Service",
    customer-number: "Customer No.",
    buyer-reference: "Buyer Reference",
    recipient-vat-id: "Buyer VAT ID",
    recipient-tax-number: "Buyer Tax ID",
    order-number: "Order No.",
    order-date: "Order Date",
    project: "Project",
    contract-number: "Contract No.",
    quote-number: "Quote No.",
    delivery-note-number: "Delivery Note No.",
    delivery-address: "Delivery Address",
    preceding-invoice-number: "Preceding Invoice No.",
    preceding-invoice-date: "Preceding Invoice Date",
    due-date: "Due Date",
    payment-reference: "Payment Reference",
    contact-person: "Contact Person",
    contact-phone: "Phone",
    contact-email: "Email",
    /// Who receives the payment instead of the sender, e.g. a factoring
    /// company (`invoice(payee: ..)`, BG-10 of the e-invoice).
    payee: "Payee",
  ),

  /// Column headers and labels for the line-items table
  line-items: (
    position: "Item",
    item-id: "Item No.",
    unit: "Unit",
    description: "Description",
    quantity: "Qty",
    unit-price: "Unit Price",
    price: "Price",
    total: "Total",
    vat: "Tax",
    net: "net",
    gross: "gross",
    discount: "Discount",
    surcharge: "Surcharge",
    subtotal: "Subtotal",
    prepayment: "Prepayment",
    /// Joins the last two item names of an automatic bundle description.
    conjunction: "and",
    /// Label of the country of origin of an item (`item(origin: ..)`).
    origin: "Country of origin",
  ),

  /// Labels for the summary section (footer of the table)
  summary: (
    sum: "Subtotal",
    vat-tax: "Tax",
    total: "Total",
    including: "incl.",
    excluding: "excl.",
    prepayment: "Prepayment",
    amount-due: "Amount Due",
  ),

  /// Global informational sentences (usually displayed below the line items)
  global-info: (
    /// Sentence specifying the universal tax rate applied
    /// -> (content|str, content|str, content|str) => content
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [All items are #tax-text #rate #vat-tax.],
    unit: "Unit for all items:",
    quantity: "Quantity for all items:",
    date: "Service date for all items:",
  ),

  /// Notes on why no VAT is charged, for the VAT categories that need one
  /// when their items give no `grounds` of their own. The note is printed
  /// below the line items and written as exemption reason (BT-120) into the
  /// e-invoice.
  tax-exemption: (
    /// Reverse charge (AE), e.g. `tax.new(category: "AE")` without grounds.
    reverse-charge: "Reverse charge",
    /// Intra-community supply (K), `tax.intra-community()`.
    intra-community: "Tax-exempt intra-community supply",
    /// Export outside the EU (G), `tax.export()`.
    export: "Tax-exempt export",
    /// Not subject to VAT (O), `tax.outside-scope()`.
    outside-scope: "Not subject to VAT",
  ),

  /// Designations for common units of measure
  units: (
    piece: "piece",
    "set": "set",
    pair: "pair",
    "lump-sum": "lump sum",
    hour: "hour",
    day: "day",
    month: "month",
    year: "year",
    kilogram: "kilogram",
    gram: "gram",
    tonne: "tonne",
    metre: "metre",
    "square-metre": "square metre",
    millimetre: "millimetre",
    centimetre: "centimetre",
    kilometre: "kilometre",
    litre: "litre",
    "cubic-metre": "cubic metre",
  ),

  /// Designations for bank and payment details
  bank-details: (
    account-holder: "Account Holder",
    bank: "Bank",
    iban: "IBAN",
    bic: "BIC",
    reference: "Reference",
  ),

  /// Texts of the payment means besides the bank details: `direct-debit`,
  /// `card-payment` and `paid`.
  payment-means: (
    /// Label of the payment method.
    method: "Payment method",
    /// Names of the payment methods.
    transfer: "Bank transfer",
    direct-debit: "Direct debit",
    sepa-direct-debit: "SEPA direct debit",
    card: "Card payment",
    credit-card: "Credit card",
    debit-card: "Debit card",
    cash: "Cash",
    cheque: "Cheque",
    online: "Online payment",
    /// Labels of the details of a direct debit and a payment card.
    mandate: "Mandate reference",
    creditor-id: "Creditor identifier",
    debtor-iban: "Your IBAN",
    card-number: "Card number",
    card-holder: "Cardholder",
    /// The sentence of an invoice that is paid already (`paid`): the paid
    /// amount and the date of the payment (`none` if not given).
    /// -> (content|str, none|content|str) => content
    paid: (
      sum,
      date,
    ) => if date
      == none [The total amount of *#sum* has been paid.] else [The total amount of *#sum* was paid on #date.],
    /// `paid` when prepayments reduced the payable amount, so `sum` is the
    /// remaining amount that was paid.
    /// -> (content|str, none|content|str) => content
    paid-due: (
      sum,
      date,
    ) => if date
      == none [The amount due of *#sum* has been paid.] else [The amount due of *#sum* was paid on #date.],
    /// `paid` on a credit note or a self-billed invoice, whose sender pays
    /// the amount to the recipient: the paid amount and the date of the
    /// payment (`none` if not given).
    /// -> (content|str, none|content|str) => content
    paid-credit: (
      sum,
      date,
    ) => if date
      == none [We have paid the amount of *#sum* to you.] else [We paid the amount of *#sum* to you on #date.],
  ),

  /// Text blocks for payment terms
  payment: (
    /// Generates the final payment instruction sentence.
    /// -> (content|str, content|str) => content
    text: (
      sum,
      deadline,
    ) => [Please transfer the total amount of *#sum* #deadline to the account listed below.],

    /// Generates the payment instruction sentence when prepayments reduce the
    /// payable amount. `sum` is then the remaining amount due.
    /// -> (content|str, content|str) => content
    text-due: (
      sum,
      deadline,
    ) => [Please transfer the amount due of *#sum* #deadline to the account listed below.],

    /// The payment sentence when the amount is collected by direct debit
    /// (`direct-debit`), in place of `text`.
    /// -> (content|str, content|str) => content
    text-direct-debit: (
      sum,
      deadline,
    ) => [The total amount of *#sum* will be collected from your account by direct debit #deadline.],

    /// `text-direct-debit` when prepayments reduce the payable amount.
    /// -> (content|str, content|str) => content
    text-direct-debit-due: (
      sum,
      deadline,
    ) => [The amount due of *#sum* will be collected from your account by direct debit #deadline.],

    /// The payment sentence when the amount is charged to a payment card
    /// (`card-payment`), in place of `text`.
    /// -> (content|str, content|str) => content
    text-card: (
      sum,
      deadline,
    ) => [The total amount of *#sum* will be charged to your card #deadline.],

    /// `text-card` when prepayments reduce the payable amount.
    /// -> (content|str, content|str) => content
    text-card-due: (
      sum,
      deadline,
    ) => [The amount due of *#sum* will be charged to your card #deadline.],

    /// The note of a cash discount (`payment-terms(discount: ..)`), printed
    /// after the payment sentence: the percentage, the deadline (as
    /// `deadline-days` words it) and the amount the discount applies to
    /// (`none` if not given).
    /// -> (str, str, none|content|str) => content
    cash-discount: (
      percent,
      deadline,
      basis,
    ) => [For payment #deadline, a cash discount of #percent#if basis != none [ on #basis] is granted.],

    /// Text for a fixed target date.
    /// -> (content|str) => str
    deadline-date: date => ("no later than", date).join(" "),

    /// Text for a relative target date (in X days).
    /// -> (int) => str
    deadline-days: days => (
      "within",
      str(days),
      "days",
    ).join(" "),

    /// Text for immediate/prompt payment.
    /// -> str
    deadline-soon: "upon receipt",

    /// The payment sentence of a document whose sender pays the amount to
    /// its recipient: a credit note or a self-billed invoice.
    /// -> (content|str, content|str) => content
    text-credit: (
      sum,
      deadline,
    ) => [We will transfer the amount of *#sum* #deadline to the account listed below.],

    /// Text for an immediate payment in `text-credit`.
    /// -> str
    deadline-soon-credit: "promptly",
  ),

  /// Greetings and signature area
  signature: (
    closing: "Sincerely,",
    thanks: "Thank you for your business.",
  ),

  /// Standard legal texts that depend on the language
  legal: (
    // The small business note in the invoice language. It is printed in front
    // of the legal grounds of the region's small business scheme when the
    // language differs from the region, and on its own when the scheme has no
    // grounds. It is used with every region, so it must not cite the law of
    // one country.
    vat-exemption: "No VAT is charged due to small business exemption.",
  ),

  /// Error and warning messages for developers or incorrect template usage
  errors: (
    name-missing: "Name is missing!",
    address-missing: "Address is missing!",
    city-missing: "City is missing!",
    ambiguous-tax: "Ambiguous 0% tax rate detected.",
    invalid-tax: "Invalid tax rate detected: ",
  ),

  /// Feedback of `invoice(validation: "draft")`: inline markers where required
  /// data is missing, a page badge, a watermark and the validation report page.
  validation: (
    /// Inline marker at the spot where required data is missing (real, tagged text).
    /// -> (content | str) => content
    marker: field => [‹missing: #field›],
    /// Problem text of a missing field in the report.
    /// -> (content | str) => content
    missing: field => [*Missing:* #field],
    /// Marker in place of a required part that rendered nothing.
    /// -> (str) => content
    part-empty: name => [‹#raw(name) rendered nothing›],
    /// Page badge.
    /// -> (int) => str
    badge: n => (
      "DRAFT · " + str(n) + if n == 1 { " problem" } else { " problems" }
    ),
    /// Watermark word.
    /// -> str
    watermark: "DRAFT",
    /// Badge suffix when the e-invoice XML was withheld.
    /// -> str
    e-invoice-short: "no e-invoice",
    /// Heading of the report page.
    /// -> str
    report-title: "Validation report",
    /// First paragraph of the report.
    /// -> (int) => content
    report-intro: n => [This document is *not ready to send*: invoice-pro found #n #if n == 1 [problem] else [problems]. The markers ‹…› show where data is missing. This page, the badge and the markers disappear as soon as everything is complete.],
    /// How to enforce completeness.
    /// -> content
    report-strict: [With `validation: "strict"` (or `--input invoice-pro-validation=strict`) the compilation stops on any problem instead. Use it for sending and in CI.],
    /// Notice when the e-invoice XML was withheld.
    /// -> (str) => content
    e-invoice-withheld: profile => [*The e-invoice (profile #profile) was not embedded*, because required data is missing. An incomplete data set would be processed automatically by the recipient's system.],
    /// Report column headers.
    /// -> str
    number: "No.",
    problem: "Problem",
    reference: "Legal basis",
    fix: "Fix",
    /// Joins alternative fixes.
    /// -> str
    fix-or: "or",
    /// Issue class labels.
    /// -> dictionary
    classes: (
      data: "Required data",
      theme: "Theme",
      lint: "Check",
    ),
    /// Labels of the checked fields.
    /// -> dictionary
    fields: (
      invoice-number: "invoice number",
      sender-name: "supplier name",
      sender-address: "supplier address",
      sender-tax-id: "supplier VAT ID or tax number",
      recipient-name: "recipient name",
      recipient-address: "recipient address",
      recipient-vat-id: "recipient VAT ID",
      line-items: "line items",
    ),
    /// Report texts of the theme and lint issues (and of data issues that are
    /// not a missing field), keyed by the issue's `key`; each a function of the
    /// issue's args. Identifiers stay code spans. A key a locale leaves out
    /// falls back to the English developer message.
    /// -> dictionary
    issues: (
      iban: a => [The IBAN #raw(a.iban) is not valid (ISO 13616 check digits).],
      iban-missing: a => [The IBAN of the bank details is missing.],
      epc-qr: a => [The EPC-QR code cannot be generated: #a.problems.],
      creditor-id: a => [The creditor identifier #raw(a.creditor-id) of the direct debit is not valid (check digits).],
      debtor-iban: a => [The IBAN #raw(a.iban) of the debited account (`debtor-iban`) is not valid (ISO 13616 check digits).],
      part-empty: a => [The part #raw(a.part) rendered nothing, but it carries legally required output.],
      part-none: a => [The part #raw(a.part) carries legally required output and cannot be `none`; wrap it or replace its renderer instead.],
      role: a => [The layout #raw(a.layout) must place #a.parts.map(raw).join[ or ] in #if a.exactly [exactly one] else [at least one] #if a.tagged [tagged area (first page or flow)] else [area drawn on page 1] (found: #a.found). It carries legally required output: #a.why. Restyle it by replacing its renderer, but keep it placed.],
      overprint: a => [The area #raw(a.area) is fixed on following pages (#raw("pages: \"" + a.pages + "\"")) and would overprint the body there; use `pages: "first"` or move it into the margins.],
      window: a => [The area #raw(a.area) overlaps the address window area #raw(a.window); move or shrink it, envelope windows must stay clear.],
      qr-bill-paper: a => [The layout #raw(a.layout) hosts `qr-bill`, which needs A4 portrait paper (SIX QR-bill: 210 × 105 mm payment part).],
      envelope: a => [The envelope #raw(a.envelope) does not take the folded sheet: packet #a.packet-w × #a.packet-h mm, envelope #a.envelope-w × #a.envelope-h mm. Check the paper, `marks.fold` or the envelope's `fold`.],
      fine-size: a => [The token `sizes.fine` (#raw(a.size)) must be an absolute length of at least 6 pt (DIN 5008 minimum for the return address and the legal footer).],
      logo-alt: a => [The logo image needs alt text, e.g. `image("logo.svg", alt: "ACME GmbH")`. PDF/UA-1 requires it; it is always checked, because a document cannot see `--pdf-standard`.],
      cmyk: a => [#raw(a.path) is a CMYK colour. Typst cannot embed a CMYK output profile, so PDF/A-3 (ZUGFeRD) rejects it; use `rgb()` or `oklch()`.],
      pdf-image-stationery: a => [The stationery for #raw(a.page) embeds a PDF image. PDF/A and PDF/UA exports cannot embed PDF images (Typst limitation); convert the letterhead to SVG.],
      pdf-image-logo: a => [The logo is a PDF image. PDF/A and PDF/UA exports cannot embed PDF images (Typst limitation); use SVG or PNG.],
      contrast: a => [#if a.bg-name == none [The colour pair #raw(a.fg-name)] else [#raw(a.fg-name) on #raw(a.bg-name)] (#a.fg on #a.bg) has a contrast of #a.ratio:1, below `checks.min-contrast` #a.min:1.],
      footer-fit: a => [The footer is #a.need mm tall, but the bottom margin leaves only #a.avail mm between `footer-descent` and the #a.clearance mm `footer-clearance`. Use the computed margin, raise `margin.bottom` or shorten the footer.],
      identity: a => [The invoice #if a.what == "number" [number] else [date] (#a.shown) does not appear in the first-page content; the area hosting `title` must render #raw(if a.what == "number" { "view.document.number" } else { "view.document.date.text" }).],
    ),
    /// What each required role carries (the `role` issue text).
    /// -> dictionary
    roles: (
      title: "document identity: invoice number and date",
      recipient: "recipient name and address",
      supplier: "supplier name and address",
      tax-id: "supplier VAT ID or tax number",
    ),
  ),
)
