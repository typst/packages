# Swiss QR Bill Generator for Typst

This package provides a simple way to generate Swiss QR bills in [Typst](https://typst.app/). The implementation follows the [Swiss Implementation Guidelines for the QR-bill (Version 2.3)](https://www.six-group.com/en/products-services/banking-services/payment-standardization/standards/qr-bill.html).

## Features

- Generate Swiss QR bills with full adherence to the official specifications
- Support for QR-IBAN and regular IBAN
- Support for structured references (QR reference or Creditor Reference)
- Automatic formatting of currency amounts
- Proper styling according to Swiss QR bill guidelines
- Cross in the QR code center as per specifications

## Installation

Add this package to your Typst project:

```
#import "@preview/payqr-swiss:0.1.0": swiss_qr_bill
```

## Usage

```typst
#import "@preview/payqr-swiss:0.1.0": swiss_qr_bill

#swiss_qr_bill(
  account: "CH4431999123000889012",
  creditor-name: "Max Muster & Söhne",
  creditor-street: "Musterstrasse",
  creditor-building: "123",
  creditor-postal-code: "8000",
  creditor-city: "Seldwyla",
  creditor-country: "CH",
  amount: 1949.75,
  currency: "CHF",
  debtor-name: "Simon Muster",
  debtor-street: "Musterstrasse",
  debtor-building: "1",
  debtor-postal-code: "8000",
  debtor-city: "Seldwyla",
  debtor-country: "CH",
  reference-type: "QRR",  // QRR, SCOR, or NON
  reference: "210000000003139471430009017",
  additional-info: "Bestellung vom 15.10.2020"
)
```

### Output

![Example Swiss QR Bill](./examples/example.png)

## Parameters

| Parameter              | Description                                      | Required    |
| ---------------------- | ------------------------------------------------ | ----------- |
| `account`              | IBAN or QR-IBAN of the creditor                  | Yes         |
| `creditor-name`        | Name of the creditor                             | Yes         |
| `creditor-street`      | Street of the creditor                           | Yes         |
| `creditor-building`    | Building number of the creditor                  | No          |
| `creditor-postal-code` | Postal code of the creditor                      | Yes         |
| `creditor-city`        | City of the creditor                             | Yes         |
| `creditor-country`     | Country code of the creditor (CH or LI)          | Yes         |
| `amount`               | Payment amount                                   | No          |
| `currency`             | Currency code (CHF or EUR)                       | Yes         |
| `debtor-name`          | Name of the debtor                               | No          |
| `debtor-street`        | Street of the debtor                             | No          |
| `debtor-building`      | Building number of the debtor                    | No          |
| `debtor-postal-code`   | Postal code of the debtor                        | No\*        |
| `debtor-city`          | City of the debtor                               | No\*        |
| `debtor-country`       | Country code of the debtor                       | No\*        |
| `reference-type`       | Type of reference (QRR, SCOR, or NON)            | Yes         |
| `reference`            | Payment reference                                | Depends\*\* |
| `additional-info`      | Additional information for the invoice recipient | No          |
| `billing-info`         | Structured billing information                   | No          |

\* Required if debtor information is provided  
\*\* Required for QRR and SCOR reference types, must be omitted for NON

## Reference Type Rules

- When using a QR-IBAN, you must use reference type `QRR` with a valid QR reference (27 characters)
- When using a regular IBAN, you must use either `SCOR` with a valid Creditor Reference (ISO 11649) or `NON` with no reference

## Examples

### Example 1: Basic QR bill with QR-IBAN

```typst
#swiss_qr_bill(
  account: "CH4431999123000889012",
  creditor-name: "Max Muster & Söhne",
  creditor-street: "Musterstrasse",
  creditor-building: "123",
  creditor-postal-code: "8000",
  creditor-city: "Seldwyla",
  creditor-country: "CH",
  amount: 1949.75,
  currency: "CHF",
  debtor-name: "Simon Muster",
  debtor-street: "Musterstrasse",
  debtor-building: "1",
  debtor-postal-code: "8000",
  debtor-city: "Seldwyla",
  debtor-country: "CH",
  reference-type: "QRR",
  reference: "210000000003139471430009017",
  additional-info: "Order from 15.10.2020"
)
```

### Example 2: QR bill with Creditor Reference

```typst
#swiss_qr_bill(
  account: "CH5800791123000889012",
  creditor-name: "Muster Krankenkasse",
  creditor-street: "Musterstrasse",
  creditor-building: "12",
  creditor-postal-code: "8000",
  creditor-city: "Seldwyla",
  creditor-country: "CH",
  amount: 211.00,
  currency: "CHF",
  debtor-name: "Sarah Beispiel",
  debtor-street: "Musterstrasse",
  debtor-building: "1",
  debtor-postal-code: "8000",
  debtor-city: "Seldwyla",
  debtor-country: "CH",
  reference-type: "SCOR",
  reference: "RF720191230100405JSH0438"
)
```

### Example 3: QR bill without amount (e.g., for donations)

```typst
#swiss_qr_bill(
  account: "CH5204835012345671000",
  creditor-name: "Muster Stiftung",
  creditor-street: "P.O. Box",
  creditor-postal-code: "3001",
  creditor-city: "Bern",
  creditor-country: "CH",
  currency: "CHF",
  reference-type: "NON"
)
```

## Disclaimer

This package is provided "as is", without warranty of any kind. It is not affiliated with, endorsed by, or connected to SIX Interbank Clearing Ltd or any financial institution. Users of this package are responsible for ensuring that the generated QR bills conform to their specific requirements and the latest standards published by SIX Interbank Clearing Ltd.

## License

[GNU LGPLv3 License](LICENSE)
