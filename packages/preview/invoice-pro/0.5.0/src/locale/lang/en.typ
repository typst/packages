/// English language overrides.
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

#let en = (
  meta: (
    lang: "en",
    resolve-plural: resolve-plural,
  ),

  document: (
    invoice: "Invoice",
    credit-note: "Credit Note",
    corrected: "Corrected Invoice",
    prepayment: "Prepayment Invoice",
    self-billed: "Self-Billing Invoice",
  ),

  address: (
    recipient: "Bill To",
    sender: "From",
  ),

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
    payee: "Payee",
  ),

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
    conjunction: "and",
    origin: "Country of origin",
  ),

  summary: (
    sum: "Subtotal",
    vat-tax: "Tax",
    total: "Total",
    including: "incl.",
    excluding: "excl.",
    prepayment: "Prepayment",
    amount-due: "Amount Due",
  ),

  global-info: (
    tax-statement: (
      tax-text,
      rate,
      vat-tax,
    ) => [All items are #tax-text #rate #vat-tax.],
    unit: "Unit for all items:",
    quantity: "Quantity for all items:",
    date: "Service date for all items:",
  ),

  units: (
    piece: (singular: "piece", plural: "pieces"),
    "set": (singular: "set", plural: "sets"),
    pair: (singular: "pair", plural: "pairs"),
    "lump-sum": (singular: "lump sum", plural: "lump sums"),
    hour: (singular: "hour", plural: "hours"),
    day: (singular: "day", plural: "days"),
    month: (singular: "month", plural: "months"),
    year: (singular: "year", plural: "years"),
    kilogram: (singular: "kilogram", plural: "kilograms"),
    gram: (singular: "gram", plural: "grams"),
    tonne: (singular: "tonne", plural: "tonnes"),
    metre: (singular: "metre", plural: "metres"),
    "square-metre": (singular: "square metre", plural: "square metres"),
    millimetre: (singular: "millimetre", plural: "millimetres"),
    centimetre: (singular: "centimetre", plural: "centimetres"),
    kilometre: (singular: "kilometre", plural: "kilometres"),
    litre: (singular: "litre", plural: "litres"),
    "cubic-metre": (singular: "cubic metre", plural: "cubic metres"),
  ),

  bank-details: (
    account-holder: "Account Holder",
    bank: "Bank",
    iban: "IBAN",
    bic: "BIC",
    reference: "Reference",
  ),

  payment-means: (
    method: "Payment method",
    transfer: "Bank transfer",
    direct-debit: "Direct debit",
    sepa-direct-debit: "SEPA direct debit",
    card: "Card payment",
    credit-card: "Credit card",
    debit-card: "Debit card",
    cash: "Cash",
    cheque: "Cheque",
    online: "Online payment",
    mandate: "Mandate reference",
    creditor-id: "Creditor identifier",
    debtor-iban: "Your IBAN",
    card-number: "Card number",
    card-holder: "Cardholder",
    paid: (
      sum,
      date,
    ) => if date
      == none [The total amount of *#sum* has been paid.] else [The total amount of *#sum* was paid on #date.],
    paid-due: (
      sum,
      date,
    ) => if date
      == none [The amount due of *#sum* has been paid.] else [The amount due of *#sum* was paid on #date.],
    paid-credit: (
      sum,
      date,
    ) => if date
      == none [We have paid the amount of *#sum* to you.] else [We paid the amount of *#sum* to you on #date.],
  ),

  payment: (
    text: (
      sum,
      deadline,
    ) => [Please transfer the total amount of *#sum* #deadline to the account listed below.],
    text-due: (
      sum,
      deadline,
    ) => [Please transfer the amount due of *#sum* #deadline to the account listed below.],
    text-direct-debit: (
      sum,
      deadline,
    ) => [The total amount of *#sum* will be collected from your account by direct debit #deadline.],
    text-direct-debit-due: (
      sum,
      deadline,
    ) => [The amount due of *#sum* will be collected from your account by direct debit #deadline.],
    text-card: (
      sum,
      deadline,
    ) => [The total amount of *#sum* will be charged to your card #deadline.],
    text-card-due: (
      sum,
      deadline,
    ) => [The amount due of *#sum* will be charged to your card #deadline.],
    cash-discount: (
      percent,
      deadline,
      basis,
    ) => [For payment #deadline, a cash discount of #percent#if basis != none [ on #basis] is granted.],
    deadline-date: date => ("no later than", date).join(" "),
    deadline-days: days => (
      "within",
      str(days),
      "days",
    ).join(" "),
    deadline-soon: "upon receipt",
    text-credit: (
      sum,
      deadline,
    ) => [We will transfer the amount of *#sum* #deadline to the account listed below.],
    deadline-soon-credit: "promptly",
  ),

  signature: (
    closing: "Sincerely,",
  ),

  legal: (
    vat-exemption: "No VAT is charged due to small business exemption.",
  ),

  errors: (
    name-missing: "Name is missing!",
    address-missing: "Address is missing!",
    city-missing: "City is missing!",
    ambiguous-tax: "Ambiguous 0% tax rate detected.",
    invalid-tax: "Invalid tax rate detected: ",
  ),
)
