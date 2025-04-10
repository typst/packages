# TiefLetter: Invoice and Offer Template for Typst

TiefLetter is a Typst template for creating professional invoices and offers. It is designed with freelancers in mind and currently supports both English and German output, with Euro as the only supported currency.

It provides a modern and customizable layout, localized text, VAT support, and a payment QR code. TiefLetter is being developed by Lena Tauchner to streamline document generation for small businesses and solo entrepreneurs.

## Usage

To use TiefLetter with the Typst web app, choose "Start from template" and select TiefLetter. You will also need to include or install the Cormorant Garamond Fonts.

To import the package manually in your Typst project, use:

```typst
#import "@preview/tiefletter:0.1.0": invoice, offer
```

Alternatively, you can download the `lib.typ` file and use:

```typst
#import "lib.typ": invoice, offer
```

### Invoice Example

```typst
#import "@preview/tiefletter:0.1.0": invoice

#invoice(
  invoice_number: "2025-001",
  invoice_date: "07.04.2025",
  seller: (
    name: "Tiefseetauchner",
    address: "Schottenring 12\n1010, Wien",
    uid: "ATUxxxxxxx",
    email: "email-address@example.com",
    tel: "+43 123 456 789",
  ),
  iban: "AT92 1234 1412 1245 3928",
  bic: "XXXXXXXXXXX",
  client: (
    gender_marker: "O",
    full_name: "Muster GesmbH",
    short_name: "Aron Schlosser",
    address: "Liselottenstraße 42c\n6049, Gamsagadorf",
  ),
  items: (
    (quantity: 2, description: "Beispiel 1", unit_price: 400.0),
    (quantity: 1, description: "Beispiel 2", unit_price: 300.0),
    (quantity: 1, description: "Beispiel 3", unit_price: 50.0, vat_rate: 10),
  ),
  payment_due_date: "21.04.2025",
)
```

### Offer Example

```typst
#import "@preview/tiefletter:0.1.0": offer

#offer(
  offer_number: "2025-004",
  offer_date: "05.04.2025",
  offer_valid_until: "30.04.2025",
  seller: (
    name: "Tiefseetauchner",
    address: "Schottenring 12\n1010, Wien",
    uid: "ATUxxxxxxx",
    email: "email-address@example.com",
    tel: "+43 123 456 789",
  ),
  client: (
    gender_marker: "F",
    full_name: "Beispiel Kundin",
    short_name: "Maria Musterfrau",
    address: "Beispielstraße 11\n1020, Wien",
  ),
  items: (
    (quantity: 1, description: "Dienstleistung A", unit_price: 500.0),
    (quantity: 2, description: "Beratungseinheit", unit_price: 150.0),
  ),
  offer_text: [Die Dienstleistung A umfasst ......
  
  Außerdem bieten wir eine Beratungseinheit zu ......],
  pre_payment_amount: 20,
)
```

## Configuration Options

### Invoice Parameters

```typst
invoice_number: none,
invoice_date: none,
seller: (
name: none,
address: none,
uid: none,
tel: none,
email: none,
),
footer_middle: none,
footer_right: none,
banner-image: none,
client: (
gender_marker: none,
full_name: none,
short_name: none,
address: none,
),
items: none,
after_table_text: none,
payment_due_date: none,
iban: none,
bic: none,
lang: "en",
```

### Offer Parameters

```typst
offer_number: none,
offer_date: none,
offer_valid_until: none,
seller: (
name: none,
address: none,
uid: none,
tel: none,
email: none,
),
footer_middle: none,
footer_right: none,
banner-image: none,
client: (
gender_marker: none,
full_name: none,
short_name: none,
address: none,
),
items: none,
offer_text: none,
pre_payment_amount: 20,
lang: "en",
```

## License and Contributions

TiefLetter is currently under active development. Feedback, bug reports, and suggestions are welcome. Please open an issue or contribute via pull requests if you have ideas for improvement.

This package is released under the MIT License.

