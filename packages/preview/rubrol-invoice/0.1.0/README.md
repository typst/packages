# rubrol-invoice

A clean, modern B2B invoice template for Typst designed for European e-invoicing compliance (EN 16931, Factur-X 1.0, and ZUGFeRD 2.2).

Developed by the team behind [Rubrol](https://github.com/maxcomperatore/rubrol) — the high-performance document generation sidecar and PDF/A-3b compiler.

## Features
- **Deterministic A4 layout** with automated pagination and subtotal / tax calculations.
- **European compliance-ready:** Dedicated fields for Seller/Buyer VAT identifiers, SIREN/SIRET, Leitweg-ID, and ISO 6523 schemes.
- **Bank payment details block:** Clean formatting for IBAN, BIC, and payment reference numbers.
- **Sub-15ms rendering:** Designed to compile cleanly and rapidly in memory.

## Usage

```typst
#import "@preview/rubrol-invoice:0.1.0": invoice

#show: invoice.with(
  invoice_number: "FA-2026-0842",
  issued_date: "2026-09-17",
  due_date: "2026-10-17",
  currency_symbol: "€",
  status: "PAID",
  seller: (
    name: "Acme Cloud SAS",
    vat_id: "FR12345678901",
    address: "15 Rue de la Paix",
    city: "75002 Paris, France",
    email: "billing@acme.com"
  ),
  buyer: (
    name: "Deutsche Software GmbH",
    vat_id: "DE987654321",
    address: "Friedrichstraße 42",
    city: "10117 Berlin, Germany"
  ),
  items: (
    (name: "Dedicated Node Subscription (Monthly)", qty: 1, unit_price: 490.00),
    (name: "Priority Support SLA", qty: 1, unit_price: 200.00),
  ),
  tax_rate: 0.20,
  payment_details: (
    bank: "BNP Paribas",
    iban: "FR76 3000 4000 5000 6000 7000 123",
    bic: "BNPAFR2X"
  ),
  notes: [
    *Note:* Reverse charge mechanism applies if cross-border B2B supply within EU.
  ]
)
```

## License
Apache 2.0. Maintained by [Max Comperatore](https://github.com/maxcomperatore).
