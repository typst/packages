#import "../lib.typ": invoice

#show: invoice(
  // Invoice ID
  "INVOICE-2025-001",
  // Invoice date
  datetime(year: 2025, month: 12, day: 15),
  (
    (
      description: "Service",
      price: 200,
    ),
    (
      description: "Other Service.",
      price: 200,
    ),
  ),
  // Author
  (
    name: "Your Name",
    street: "Your Street 123",
    zip: "12345",
    city: "Your City",
    tax_nr: "12345/67890",
    // vat_id: "DE123456789",
    // signature: image("example_signature.png", width: 5em)
  ),
  // Recipient
  (
    name: "Some LLC",
    street: "250 Little Falls Drive",
    zip: "19808",
    city: "Wilmington, Delaware",
  ),
  (
    name: "Your Name",
    bank: "Your Bank",
    iban: "DE89370400440532013000",
    bic: "YOURSWIFT",
    gender: (account_holder: "Kontoinhaber")
  ),
  invoice-title: "Rechnung",
  // Custom invoice text 
  invoice-text: "",
  reverse-charge: true,
  // No VAT for foreign customers
  vat: 0.0,
  kleinunternehmer: false,
  // QR code will use EUR equivalent amount
  show-qr: true,
  // USD as per grant agreement
  currency: "USD",
  // ECB exchange rate on invoice date (required for German accounting)
  // https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/eurofxref-graph-usd.en.html
  fx-rate: 0.86,

)
