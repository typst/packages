# German invoice template

A template for writing invoices, inspired by the [beautiful LaTeX template by @mrzool.](https://github.com/mrzool/invoice-boilerplate/)

```typ
#import "@preview/classy-german-invoice:0.3.0": invoice

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
      price: 150.2
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
)
```

![](thumbnail.png)



## Scope

This template should work well for freelancers and small companies in the german market, that don't have an existing system in place for order tracking. Or to put it the other way round; This template is for people that mostly have to fulfill outside requirements with their invoices and don't so much benefit from extensive tracking themselfes.


## Features

- [X] multiple invoice items
- [X] configurable VAT
- [X] configurable § 19 UStG (Kleinunternehmerregelung) note
- [X] configurable signature from PNG file
- [X] employs both lining and old-style number types, depending on the application
- [X] [EPC QR Code](https://en.wikipedia.org/wiki/EPC_QR_code) for easier banking transactions
- [ ] recipient address is guaranteed to fit in a windowed envolope (DIN 5008)


## Disclaimer

This template doesn't constitute legal advice. Please check for yourself wether it fulfills your legal requirements!
