# invoice-pro
Modern Invoice Template for Typst

A professional, compliant, and automated invoice template for [Typst](https://typst.app). This package follows the German **DIN 5008** standard (Form A & B) and automates calculations, VAT handling, and payment details.

![Example Invoice](thumbnail.png)
## Features

* **DIN 5008 Compliant:** Supports both Form A and Form B layouts.
* **Automatic Calculations:** Handles line items, sub-totals, and VAT (MwSt) automatically.
* **EPC QR-Code (GiroCode):** Generates a scannable banking QR code for easy payment apps using `rustycure`.
* **Flexible Tax Settings:** * Supports standard VAT (Brutto/Netto modes).
    * **Kleinunternehmerregelung:** Built-in support for small business exemption (§ 19 UStG).
* **Customizable:** Easy configuration of sender, recipient, and bank details.

## Getting Started

### Installation

Import the package at the top of your Typst file:

```typ
#import "@preview/invoice-pro:0.1.0": *
````

### Basic Usage

Here is a minimal example of how to create an invoice:

```typ
#import "@preview/invoice-pro:0.1.0": *

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
  iban: "DE07100202005821158846",
  bic: "MUSTERBIC",
)

#signature(signature: block[Your Signature])
```

## Configuration

### `invoice` arguments

| Argument | Type | Description |
| :--- | :--- | :--- |
| `format` | string | "DIN-5008-A" or "DIN-5008-B" (Default: B). |
| `sender` | dict | Sender details (`name`, `address`, `city`, `extra`). |
| `recipient` | dict | Recipient details. |
| `vat` | float | Default VAT rate (e.g., `0.19` for 19%). |
| `vat-exempt-small-biz` | bool | If `true`, enables "Kleinunternehmer" mode (no VAT). |
| `show-gross-prices` | bool | If `true`, calculates B2C gross prices. Default is `false` (B2B/Net). |

### `invoice-line-items` function

| Argument | Type | Description |
| :--- | :--- | :--- |
| `vat-exemption` | `bool` \| `auto` | Overrides the global setting. `auto` inherits from `invoice`. |
| `show-quantity` | `bool` \| `auto` | Controls the quantity column. `auto` hides it if all quantities are 1. |
| `show-vat-per-item` | `bool` \| `auto` | Controls the VAT column. `auto` shows it only if VAT rates differ between items. |
| `currency` | `content` | The currency symbol to display (Default: `[€]`). |
| `show-gross-prices` | `bool` | Calculation mode: `false` (Default/B2B) for net prices, `true` (B2C) for gross prices (prevents rounding errors). |
| `..items` | `arguments` | A list of `item()` calls. |


### `item` function

| Argument | Type | Description |
| :--- | :--- | :--- |
| `description` | content | Description of the service/product. |
| `price` | float | Price per unit. |
| `quantity` | float | Amount (Default: 1). |
| `vat` | float | Specific VAT rate for this item (overrides default). |


```typst
#invoice-line-items(
  vat-exemption: true,
  item([Consulting Service], quantity: 4, unit: [hrs], price: 80),
  item([Software License], price: 150),
)
```
![Line Items with Vat Exemption](images/items-1.png)

```typst
#invoice-line-items(
  show-gross-prices: true,
  item([Fresh Mango], quantity: 4, unit: [pc.], vat: 0.07, price: 3.50),
  item([Döner Kebap to Go], unit: [pc.], price: 8),
)
```
![Line Items B2C relation](images/items-2.png)

```typst
#invoice-line-items(
  item([Ergonomic Office Chair "Modell Air"], quantity: 10, price: 250.00, gross-price: false, unit: [pc.]),
  item([Monitor Mount VESA 100], quantity: 20, unit: [pc.], gross-price: false, price: 45.50),
  item([Shipment], quantity: 1, gross-price: false, price: 89.90),
)
```
![Line Items B2B relation](images/items-3.png)

## Dependencies

This template relies on these amazing packages:

  * `letter-pro` for the DIN layout.
  * `rustycure` for QR-Code generation.
  * `ibanator` for IBAN formatting.

**Acknowledgements:**
* Special thanks to [classy-german-invoice](https://github.com/erictapen/typst-invoice) by Kerstin Humm, which served as inspiration and provided the logic for the EPC-QR-Code implementation.

## License

MIT
