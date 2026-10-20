# invoice-pro

Modern Invoice Template for Typst

A professional, compliant, and automated invoice template for [Typst](https://typst.app). This package follows the German **DIN 5008** standard (Form A & B) and automates calculations, VAT handling, and payment details.

![Example Invoice](thumbnail.png)

## Features

- **Internationalization (i18n) (New in v0.3.0):** Built-in support for English and German out of the box, plus a highly flexible `locale` API to inject custom translations for any language.
- **DIN 5008 Compliant:** Supports both Form A and Form B layouts natively via the flexible Theming API.
- **Block-based API:** Clean, scoped, and declarative data structure using `#line-items`, `#item`, and `#bundle`—inspired by CeTZ, keeping your document clutter-free.
- **Automatic Calculations:** Effortlessly handles line items, nested bundles, sub-totals, and calculates taxes automatically.
- **EPC QR-Code (GiroCode):** Automatically generates a scannable banking QR code for quick and easy payments using banking apps.
- **Advanced Modifiers:** Apply specific discounts, surcharges, and custom tax rates at the item, bundle, or global level.
- **Highly Customizable:** Easy configuration of sender, recipient, payment goals, bank details, and visual themes to match your corporate identity.

## Documentation

For comprehensive guides, API references, theming instructions, and advanced examples, please visit our official documentation:

👉 **[Read the Full Documentation Here](https://leonieziechmann.github.io/invoice-pro/)**

## Getting Started

### Installation

Import the package at the top of your Typst file:

```typst
#import "@preview/invoice-pro:0.3.0": *
```

### Basic Usage

Here is an example of how to create an invoice using the new v0.3.0 API:

```typst
#import "@preview/invoice-pro:0.3.0": *

#show: invoice.with(
  theme: themes.DIN-5008(form: "A"), // or form: "B"
  locale: locale.en-de,
  sender: (
    name: "Your Company / Name",
    address: "1 Example Street",
    city: "12345 Example City",
  ),
  recipient: (
    name: "Customer Name",
    address: "5 Customer Street",
    city: "98765 Customer City",
  ),
  invoice-nr: "2026-01",
  tax-nr: "123/456/789",
)

// Add Invoice Items inside a scoped block
#line-items[
  #item(
    [Consulting & Concept],
    price: 85.00,
    quantity: 5,
    unit: "hrs"
  )

  #item(
    [Web Design Layout (Flat Rate)],
    price: 1200.00,
  )

  #item(
    [Stock Licenses (Images)],
    price: 25.00,
    quantity: 4,
  )

  #discount([Project Discount (Regular Customer)], amount: 10%)
]

// Payment Terms
#payment-goal(days: 14)

// Bank Details with QR Code
#bank-details(
  bank: "Example Bank",
  iban: "DE07100202005821158846",
  bic: "EXAMPLEBIC",
)

#signature()
```

## API Stability

With the major refactoring introduced in version 0.2.0, the package structure is solidifying. Here is the current stability status of the various API components:

- **Invoice Header (`invoice` arguments):** **Mostly Stable**. The core invoice configuration is established. Future updates to the header will be non-breaking and will primarily consist of adding new optional fields.
- **Data Model (`#line-items`, `#bundle`, `#item`):** **Stable**. The new block-based data model is considered almost finished and safe to use.
  - _Exception:_ The `unit` argument in `#item` and `#bundle` will change in a future release to strictly comply with the standardized unit formats and codes required for upcoming ZUGFeRD e-invoicing support.
- **Theming (`theme`):** **Under Construction**. The theming engine is still evolving and will most likely experience breaking changes in the next updates as we refine customization capabilities.
- **Localization (`locale`):** **Under Construction**. The localization and internationalization systems are actively being worked on and are subject to change.

## Dependencies

This template relies on these amazing packages:

- `letter-pro` for the DIN layout.
- `sepay` for EPC-QR-Code generation.
- `ibanator` for IBAN formatting.
- `loom` for reactive document rendering.

**Acknowledgements:**

- Special thanks to [classy-german-invoice](https://github.com/erictapen/typst-invoice) by Kerstin Humm, which served as inspiration and provided the logic for the EPC-QR-Code implementation.

## License

MIT
