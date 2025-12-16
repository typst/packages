# German invoice template

A template for minimalistic invoice for freelancers based in Germany. Fork of [typst-invoice](https://github.com/erictapen/typst-invoice) with some added FX functionality.

## Quick Start

No installation needed: open [typst.app](https://typst.app), create a new project, and add `#import "@preview/german-invoice:0.1.0": invoice` at the top of your document.

```typ
#import "@preview/german-invoice:0.1.0": invoice

#show: invoice(
  // Invoice number
  "2023-001",
  // Invoice date
  datetime(year: 2024, month: 09, day: 03),
  // Items
  (
    (
      description: "The first service provided. The first service provided. The first service provided",
      price: 200,
    ),
    (
      description: "The second service provided",
      price: 150
    ),
  ),
  // Author
  (
    name: "Kerstin Humm",
    street: "Straße der Privatsphäre und Stille 1",
    zip: "54321",
    city: "Potsdam",
    tax_nr: "12345/67890",
    // optional signature, can be omitted
    signature: image("example_signature.png", width: 5em)
  ),
  // Recipient
  (
    name: "Erika Mustermann",
    street: "Musterallee",
    zip: "12345",
    city: "Musterstadt",
  ),
  // Bank account
  (
    name: "Todd Name",
    bank: "Deutsche Postbank AG",
    iban: "DE89370400440532013000",
    bic: "PBNKDEFF",
    // There is currently only one gendered term in this template.
    // You can overwrite it, or omit it and just choose the default.
    gender: (account_holder: "Kontoinhaberin")
  ),
  // Umsatzsteuersatz (VAT)
  vat: 0.19,
  kleinunternehmer: true,
  includes-vat: false
)
```

![](./template/example.png)

### Foreign Currency Example (USD)

For invoicing in foreign currencies while maintaining German tax compliance:

```typ
#show: invoice(
  "2024-001",
  datetime(year: 2024, month: 12, day: 15),
  (
    (description: "Consulting services", price: 5000),
  ),
  // Author...
  // Recipient...
  // Bank account...
  // Invoice in USD with EUR equivalent for German accounting
  currency: "USD",
  fx-rate: 0.93,  // ECB exchange rate on invoice date
  // QR code will use EUR equivalent amount
  show-qr: true,
)
```

The template will:

- Display prices with the appropriate currency symbol ($, £, etc.)
- Use dot as decimal separator for non-EUR currencies
- Show EUR equivalent amount based on ECB exchange rate
- Generate EPC QR code with EUR amount (SEPA standard requires EUR)

![](thumbnail.png)


## Scope

This template should work well for freelancers and small companies in the german market, that don't have an existing system in place for order tracking. Or to put it the other way round; This template is for people that mostly have to fulfill outside requirements with their invoices and don't so much benefit from extensive tracking themselves.

## Features

- [x] multiple invoice items
- [x] configurable VAT
- [x] configurable § 19 UStG (Kleinunternehmerregelung) note
- [x] reverse-charge for EU B2B customers (§13b UStG)
- [x] configurable signature from PNG file
- [x] employs both lining and old-style number types, depending on the application
- [x] [EPC QR Code](https://en.wikipedia.org/wiki/EPC_QR_code) for easier banking transactions
- [x] currency exchange (USD, GBP, etc. with EUR equivalent for German accounting)
- [ ] recipient address is guaranteed to fit in a windowed envelope (DIN 5008)

## Disclaimer

This template doesn't constitute legal advice. Please check for yourself whether it fulfills your legal requirements!
