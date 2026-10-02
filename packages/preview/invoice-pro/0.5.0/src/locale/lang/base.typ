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
  ),

  /// Address-related designations
  address: (
    recipient: "Bill To",
    sender: "From",
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

    /// The note of a cash discount (`payment-goal(discount: ..)`), printed
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
)
