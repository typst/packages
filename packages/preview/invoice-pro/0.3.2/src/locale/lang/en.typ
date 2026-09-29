/// English language overrides.
#let en = (
  meta: (
    /// The ISO 639-1 language code of the file.
    lang: "en",
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
    text: (
      sum,
      deadline,
    ) => [Please transfer the total amount of *#sum* #deadline to the account listed below.],

    /// Text for a fixed target date.
    deadline-date: date => ("no later than", date).join(" "),

    /// Text for a relative target date (in X days).
    deadline-days: days => (
      "within",
      str(days),
      "days",
    ).join(" "),

    /// Text for immediate/prompt payment.
    deadline-soon: "upon receipt",
  ),

  /// Greetings and signature area
  signature: (
    closing: "Sincerely,",
  ),

  /// Standard legal texts
  legal: (
    vat-exemption: "No VAT is charged due to small business exemption.",
  ),

  /// Error and warning messages for developers
  errors: (
    name-missing: "Name is missing!",
    address-missing: "Address is missing!",
    city-missing: "City is missing!",
    ambiguous-tax: "Ambiguous 0% tax rate detected.",
    invalid-tax: "Invalid tax rate detected: ",
  ),
)
