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
    lang: "base",
    /// Plural resolution function for units and language strings.
    /// -> (any, int | float | decimal | str) => any
    resolve-plural: resolve-plural,
  ),

  /// Designations for document types
  document: (
    invoice: "Invoice",
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
    preceding-invoice-number: "Preceding Invoice No.",
    due-date: "Due Date",
    payment-reference: "Payment Reference",
    contact-person: "Contact Person",
    contact-phone: "Phone",
    contact-email: "Email",
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
  ),

  /// Labels for the summary section (footer of the table)
  summary: (
    sum: "Subtotal",
    vat-tax: "Tax",
    total: "Total Due",
    including: "incl.",
    excluding: "excl.",
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

  /// Text blocks for payment terms
  payment: (
    /// Generates the final payment instruction sentence.
    /// -> (content|str, content|str, content|str) => content
    text: (
      sum,
      deadline,
    ) => [Please transfer the total amount of *#sum* #deadline to the account listed below.],

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
  ),

  /// Greetings and signature area
  signature: (
    closing: "Sincerely,",
  ),

  /// Standard legal texts that depend on the language
  legal: (
    // This generic fallback text can be overridden by specific regional language files.
    // E.g., The DE.typ region will fetch `lang.legal.vat-exemption` for the §19 UStG clause.
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
