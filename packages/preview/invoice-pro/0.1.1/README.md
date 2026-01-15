# invoice-pro

Modern Invoice Template for Typst

A professional, compliant, and automated invoice template for [Typst](https://typst.app). This package follows the German **DIN 5008** standard (Form A & B) and automates calculations, VAT handling, and payment details.

![Example Invoice](thumbnail.png)

## Features

- **DIN 5008 Compliant:** Supports both Form A and Form B layouts.
- **Automatic Calculations:** Handles line items, sub-totals, and VAT (MwSt) automatically.
- **EPC QR-Code (GiroCode):** Generates a scannable banking QR code for easy payment apps using `rustycure`.
- **Flexible Tax Settings:** Supports standard VAT (Brutto/Netto modes).
  - **Kleinunternehmerregelung:** Built-in support for small business exemption (§ 19 UStG).
- **Customizable:** Easy configuration of sender, recipient, payment goals, and bank details.

## Getting Started

### Installation

Import the package at the top of your Typst file:

```typst
#import "@preview/invoice-pro:0.1.1": *
```

### Basic Usage

Here is a minimal example of how to create an invoice:

```typst
#import "@preview/invoice-pro:0.1.1": *

// Set language to German for correct date/number formatting
#set text(lang: "de")

#show: invoice.with(
  format: "DIN-5008-A", // or "DIN-5008-B"

  sender: (
    name: "Deine Firma / Name",
    address: "Musterstraße 1",
    city: "12345 Musterstadt",
    extra: (
      "Tel": [+49 123 4567890],
      "Web": [#link("https://www.example.com")[www.example.com]],
    )
  ),

  recipient: (
    name: "Kunden Name",
    address: "Kundenstraße 5",
    city: "98765 Kundenstadt"
  ),

  invoice-nr: "2024-001",
  date: datetime.today(),
  tax-nr: "123/456/789",
)

// Add Invoice Items
#invoice-line-items(
  item([Consulting Service], quantity: 4, unit: [hrs], price: 80),
  item([Software License], price: 150),
)

// Payment Terms
#payment-goal(days: 14)

// Bank Details with QR Code
#bank-details(
  bank: "Musterbank",
  iban: "DE07100202005821158847",
  bic: "MUSTERBIC",
)

#signature(signature: block[Your Signature])
```

## Configuration

### `invoice` arguments

| Argument               | Type   | Description                                                           |
| :--------------------- | :----- | :-------------------------------------------------------------------- |
| `format`               | string | "DIN-5008-A" or "DIN-5008-B" (Default: B).                            |
| `sender`               | dict   | Sender details (`name`, `address`, `city`, `extra`).                  |
| `recipient`            | dict   | Recipient details.                                                    |
| `vat`                  | float  | Default VAT rate (e.g., `0.19` for 19%).                              |
| `vat-exempt-small-biz` | bool   | If `true`, enables "Kleinunternehmer" mode (no VAT).                  |
| `show-gross-prices`    | bool   | If `true`, calculates B2C gross prices. Default is `false` (B2B/Net). |

### `invoice-line-items` function

| Argument            | Type             | Description                                                                                                       |
| :------------------ | :--------------- | :---------------------------------------------------------------------------------------------------------------- |
| `vat-exemption`     | `bool` \| `auto` | Overrides the global setting. `auto` inherits from `invoice`.                                                     |
| `show-quantity`     | `bool` \| `auto` | Controls the quantity column. `auto` hides it if all quantities are 1.                                            |
| `show-vat-per-item` | `bool` \| `auto` | Controls the VAT column. `auto` shows it only if VAT rates differ between items.                                  |
| `currency`          | `content`        | The currency symbol to display (Default: `[€]`).                                                                  |
| `show-gross-prices` | `bool`           | Calculation mode: `false` (Default/B2B) for net prices, `true` (B2C) for gross prices (prevents rounding errors). |
| `..items`           | `arguments`      | A list of `item()` calls.                                                                                         |

### `item` function

| Argument      | Type    | Description                                          |
| :------------ | :------ | :--------------------------------------------------- |
| `description` | content | Description of the service/product.                  |
| `price`       | float   | Price per unit.                                      |
| `quantity`    | float   | Amount (Default: 1).                                 |
| `vat`         | float   | Specific VAT rate for this item (overrides default). |

#### Line items with VAT exemption

```typst
#invoice-line-items(
  vat-exemption: true,
  item([Consulting Service], quantity: 4, unit: [hrs], price: 80),
  item([Software License], price: 150),
)
```

![Line items with VAT exemption](images/items-1.png)

#### Line items B2C relation

```typst
#invoice-line-items(
  show-gross-prices: true,
  item([Fresh Mango], quantity: 4, unit: [pc.], vat: 0.07, price: 3.50),
  item([Döner Kebap to Go], unit: [pc.], price: 8),
)
```

![Line items B2C relation](images/items-2.png)

#### Line items B2B relation

```typst
#invoice-line-items(
  item([Ergonomic Office Chair "Modell Air"], quantity: 10, price: 250.00, gross-price: false, unit: [pc.]),
  item([Monitor Mount VESA 100], quantity: 20, unit: [pc.], gross-price: false, price: 45.50),
  item([Shipment], quantity: 1, gross-price: false, price: 89.90),
)
```

![Line items B2B relation](images/items-3.png)

### `payment-goal` function

| Argument   | Type                        | Description                                      |
| :--------- | :-------------------------- | :----------------------------------------------- |
| `days`     | int \| none                 | The number of days until payment is due.         |
| `date`     | datetime \| content \| none | A date until payment is due.                     |
| `currency` | `content`                   | The currency symbol to display (Default: `[€]`). |

```typst
#payment-goal()
```

> Bitte überweisen Sie den Gesamtbetrag von **123,45€** zeitnah ohne Abzug auf das unten genannte Konto.

```typst
#payment-goal(days: 14)
```

> Bitte überweisen Sie den Gesamtbetrag von **123,45€** innerhalb von 14 Tagen ohne Abzug auf das unten genannte Konto.

```typst
#payment-goal(date: datetime(day: 1, month: 1, year: 2026))
```

> Bitte überweisen Sie den Gesamtbetrag von **123,45€** bis spätestens 01.01.2026 ohne Abzug auf das unten genannte Konto.

### `bank-details` function

Renders a block containing the bank details and an optional EPC-QR-Code (GiroCode) for easy mobile payment.

| Argument              | Type         | Description                                                                                        |
| --------------------- | ------------ | -------------------------------------------------------------------------------------------------- |
| `bank`                | `str`        | `content`                                                                                          |
| `iban`                | `str`        | **Required.** The IBAN (formatting is handled automatically).                                      |
| `bic`                 | `str`        | **Required.** The BIC (Bank Identifier Code).                                                      |
| `name`                | `auto`       | `str`                                                                                              |
| `reference`           | `str`        | `none`                                                                                             |
| `show-refernce`       | `bool`       | Toggles visibility of the reference line. (Note: Parameter is currently spelled `show-refernce`) . |
| `payment-amount`      | `float`      | `auto`                                                                                             |
| `account-holder-text` | `str`        | `content`                                                                                          |
| `qr-code`             | `dictionary` | Configuration for the QR code `(display: bool, size: length)`. Default size is `4em`.              |

```typst
// Standard usage with automatic total and reference
#bank-details(
  bank: "Sparkasse Musterstadt",
  iban: "DE00 1234 5678 9012 3456 78",
  bic: "SPKDE...",
)

// Customizing the QR code size and reference text
#bank-details(
  bank: "Neo Bank",
  iban: "DE99...",
  bic: "NEO...",
  reference: "Rechnungs-Nr. 2024-001 / Kundennummer 55",
  qr-code: (size: 3cm)
)

// Hiding the QR Code
#bank-details(
  bank: "Oldschool Bank",
  iban: "DE11...",
  bic: "OLD...",
  qr-code: (display: false)
)
```

## 🛠️ Development

This project uses **Nix** to provide a reproducible, sandboxed development environment. You do not need to install Typst, linters, or formatters globally—the flake provides everything.

### Quick Start

1. **Enter the environment:**

```bash
nix develop
# or if you use direnv:
direnv allow
```

This activates a shell containing `typst`, `typstyle`, `markdownlint`, and `prettier`.

2. **Automatic Package Linking:**
   The environment automatically links the current directory to a sandboxed local package registry (inside `.typst-data`). You can import the package in your test files immediately without manual installation:

```typst
// Use the @local namespace for development
#import "@preview/invoice-pro:0.1.1": *
```

3. **Quality Control (Pre-commit):**
   Git hooks are automatically configured to run before every commit. They ensure:

- **Formatting:** `.typ` files are formatted with `typstyle`, and `.md` files with `prettier`.
- **Linting:** Structure is checked with `markdownlint`.
- **Hygiene:** Trailing whitespace and Nix formatting are enforced.
  To run these checks manually:

```bash
pre-commit run --all-files
```

## 🗺️ Roadmap

I am actively working on improving this template. Here is what's planned for future releases:

- [ ] **Refactored API:** Moving away from global states to a more robust, scoped API (inspired by CeTZ) for better stability and flexibility.
- [ ] **Internationalization (i18n):** Built-in support for English and other languages (currently creates German invoices by default).
- [ ] **Theming Engine:** Allow easy customization of accent colors and fonts to match corporate identities.
- [ ] **Data Loading:** Helper functions to load invoice items directly from JSON, CSV, or YAML files.
- [ ] **ZUGFeRD Support:** (Long-term goal) Embedding XML data for fully compliant e-invoicing.

Have an idea? Feel free to open an issue or pull request!

## Dependencies

This template relies on these amazing packages:

- `letter-pro` for the DIN layout.
- `rustycure` for QR-Code generation.
- `ibanator` for IBAN formatting.

**Acknowledgements:**

- Special thanks to [classy-german-invoice](https://github.com/erictapen/typst-invoice) by Kerstin Humm, which served as inspiration and provided the logic for the EPC-QR-Code implementation.

## License

MIT
