# SEPAY

Generate [EPC QR codes](https://en.wikipedia.org/wiki/EPC_QR_code) for SEPA credit transfers.

> **Etymology:** The name *SEPAY* is a portmanteau of **SEPA** (Single Euro Payments Area) and **pay**, reflecting the package's focus on generating payment-enabled QR codes for the European payment ecosystem.

![Usage Examples](gallery/basics.png)

![Customization Options](gallery/options.png)

## Features

- Generate scannable QR codes for banking apps
- Compliant with [EPC069-12 standard](https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation)
- Automatic IBAN validation and formatting
- Support for both structured references and free-text remittance
- Customizable QR code appearance (colors, size, quiet zone)

## Usage

```typ
#import "@preview/sepay:0.1.1": epc-qr-code

#epc-qr-code(
  "Max Mustermann",
  "DE89 3704 0044 0532 0130 00",
  amount: 123.45,
  bic: "COBADEFFXXX",
  reference: "INV-2024-001",
  width: 4cm,
  height: 4cm,
)
```

### Minimal Example

Only required fields:

```typ
#epc-qr-code(
  "Max Mustermann",
  "DE89370400440532013000",
  amount: 50,
)
```

### Open Amount (e.g., for Donations)

```typ
#epc-qr-code(
  "Charity Organization",
  "DE89370400440532013000",
  text: "Donation",
)
```

### Customized Appearance

```typ
#epc-qr-code(
  "Charity Organization",
  "DE89370400440532013000",
  amount: 25.00,
  text: "Donation",
  width: 5cm,
  height: 5cm,
  quiet-zone: false,
  dark-color: rgb("#1a365d"),
  light-color: rgb("#ebf8ff"),
)
```

## API

### `epc-qr-code`

Generates an EPC QR code image for SEPA credit transfers.

#### Payment Parameters

| Parameter     | Type           | Required | Description                                                                                                                                                         |
| ------------- | -------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `beneficiary` | `str`          | Yes      | Beneficiary name (max 70 characters, positional)                                                                                                                    |
| `iban`        | `str`          | Yes      | Beneficiary IBAN (spaces are automatically removed, positional)                                                                                                     |
| `bic`         | `str`          | No       | BIC of the beneficiary's bank (8 or 11 characters)                                                                                                                  |
| `amount`      | `float \| int` | No       | Amount in EUR (0.01–999999999.99), or `none` for open amount                                                                                                        |
| `purpose`     | `str`          | No       | [ISO 20022 purpose code](https://www.iso20022.org/catalogue-messages/additional-content-messages/external-code-sets) (max 4 characters, e.g., `"CHAR"` for charity) |
| `reference`   | `str`          | No       | Structured remittance reference (max 35 characters)                                                                                                                 |
| `text`        | `str`          | No       | Unstructured remittance text (max 140 characters)                                                                                                                   |
| `information` | `str`          | No       | Beneficiary to originator info (max 70 characters)                                                                                                                  |

> **Note:** You cannot specify both `reference` and `text` at the same time.

#### QR Code Options

| Parameter     | Type     | Default         | Description                         |
| ------------- | -------- | --------------- | ----------------------------------- |
| `width`       | `length` | `auto`          | Width of the QR code                |
| `height`      | `length` | `auto`          | Height of the QR code               |
| `quiet-zone`  | `bool`   | `true`          | Include white border around QR code |
| `dark-color`  | `color`  | `black`         | Color of QR code modules            |
| `light-color` | `color`  | `white`         | Background color                    |
| `alt`         | `str`    | `"EPC QR Code"` | Alt text for accessibility          |
| `fit`         | `str`    | `"cover"`       | Image fit mode                      |

### `epc-payload`

Returns the raw EPC QR code payload string (useful for debugging or custom QR code rendering).

```typ
#import "@preview/sepay:0.1.1": epc-payload

#let payload-string = epc-payload(
  "Max Mustermann",
  "DE89370400440532013000",
  amount: 10.00,
)
```

## License

MIT
