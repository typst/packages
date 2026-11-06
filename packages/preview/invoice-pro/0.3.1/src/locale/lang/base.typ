/// The Base-Language Dictionary serves as the structural template (schema) for all
/// other language files (e.g., de.typ, fr.typ).
/// It contains exclusively linguistic strings and formatting text.
#let base-language = (
  meta: (
    /// The ISO 639-1 language code of the file (e.g., "en", "de").
    lang: "base",
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
    ) => [All items are #tax-text #rate #vat-tax],
    unit: "Unit for all items:",
    quantity: "Quantity for all items:",
    date: "Service date for all items:",
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
