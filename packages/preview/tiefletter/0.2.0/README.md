# TiefLetter: Invoice and Offer Template for Typst

Tiefletter is a template for easily and modularly creating invoices and offers.
It primarily focuses on creating a neat, consistent portfolio in few steps that
are also easily automatable using typst.

Tiefletter is developed by Lena Tauchner (Tiefseetauchner) for her own personal
use, but it has applications outside that.

## Usage

To use TiefLetter with the Typst web app, choose "Start from template" and select
TiefLetter. You will also need to include or install the Cormorant Garamond Fonts.

To import the package manually in your Typst project, use:

```typst
#import "@preview/tiefletter:0.2.0": invoice, offer
```

Choose the appropriate document type here, or import letter preset for a simple
letter with custom content. This however is not supported and not adviced, you'll
have to do almost everything manually, including the closing.

Alternatively, you can download the `lib.typ` file and use:

```typst
#import "lib.typ": invoice, offer
```

### Invoice Example

The invoice is the primary template of TiefLetter. It contains an introduction with
a invoice Nr. and a table of the positions including

- Description of the item
- Quantity of the item
- Individual price
- (Optional) VAT Rate per item, defaulting to 20% (can be disabled with is-kleinunternehmer: true)
- (Optional) Total VAT (can be disabled with is-kleinunternehmer: true)
- Total of items including VAT

After the table follows an automatic calculation of the total excluding VAT, the
total VAT charged and the Total including VAT.

Then an optional text, some disclaimers like the Kleinunternehmerregelung as well as a delivery date
(Lieferdatum/Lieferzeitraum) disclaimer. After those, the payment request, including a (quite handy)
payment QR code.

```typst
#import "@preview/tiefletter:0.2.0": invoice

#invoice(
  invoice-number: "2025-001",
  invoice-date: "07.04.2025",
  seller: (
    name: "Tiefseetauchner",
    address: "Schottenring 12\n1010, Wien",
    uid: "ATUxxxxxxx",
    email: "email-address@example.com",
    tel: "+43 123 456 789",
    is-kleinunternehmer: false,
  ),
  iban: "AT92 1234 1412 1245 3928",
  bic: "XXXXXXXXXXX",
  client: (
    gender-marker: "O",
    full-name: "Muster GesmbH",
    short-name: "Aron Schlosser",
    address: "Liselottenstraße 42c\n6049, Gamsagadorf",
  ),
  items: (
    (quantity: 2, description: "Beispiel 1", unit-price: 400.0),
    (quantity: 1, description: "Beispiel 2", unit-price: 300.0),
    (quantity: 1, description: "Beispiel 3", unit-price: 50.0, vat-rate: 10),
  ),
  payment-due-date: "21.04.2025",
)
```

### Offer Example

The offer is a handy tool to make a consistent public appearance. But simply due to the complexities
of writing offers, it isn't run of the mill, it has to be customized quite heavily.

An offer starts with the usual greeting and introduction, followed by a free text. Then, the same table
as with the invoice (offer does not yet support Kleinunternehmerregelungen), as well as an optional
pre-payment amount. There is also a clause for the validity of the offer, which is generally 30 days,
but can be set to a certain date.

Closing statement and that's pretty much it.

```typst
#import "@preview/tiefletter:0.2.0": offer

#offer(
  offer-number: "2025-004",
  offer-date: "05.04.2025",
  offer-valid-until: "30.04.2025",
  seller: (
    name: "Tiefseetauchner",
    address: "Schottenring 12\n1010, Wien",
    uid: "ATUxxxxxxx",
    email: "email-address@example.com",
    tel: "+43 123 456 789",
  ),
  client: (
    gender-marker: "F",
    full-name: "Beispiel Kundin",
    short-name: "Maria Musterfrau",
    address: "Beispielstraße 11\n1020, Wien",
  ),
  items: (
    (quantity: 1, description: "Dienstleistung A", unit-price: 500.0),
    (quantity: 2, description: "Beratungseinheit", unit-price: 150.0),
  ),
  offer-text: [Die Dienstleistung A umfasst ......

  Außerdem bieten wir eine Beratungseinheit zu ......],
  pre-payment-amount: 20,
)
```

### Usage notes on other document types

The library builds on two internal functions: `letter-preset` and `document-preset`.
One could conceivably use either of these to generate documents, however, it is not
recommended as their interfaces may change.

## Configuration Options

Tiefletter has a lot of customization options. Importantly, a lot of it is
shared between template types.

### Shared

Shared between the templates are the following parameters:

```typst
  lang: none, // Supported: "en-at", "en-de", "en-us", "de-at", "de-de"
  seller: (
    name: none,
    address: none,
    uid: none, // Optional
    tel: none,
    email: none,
    signature: false, // Shows a signature line at the end of the letter
  ),
  // The left footer is automatically generated from the seller name, tel and email.
  footer-middle: none, // Optional
  footer-right: none, // Optional
  banner-image: none, // Optional, a typst element. For example, image("header.svg")
  client: (
    gender-marker: none, // Decides the greeting, "f" for female, "m" for male, "o" for neutral
    full-name: none, // The name to be written in the letter head
    short-name: none, // The name used for the greeting
    address: none,
    uid: none, // Optional, important for large orders > 10.000€
    signature: false, // Shows a signature line at the end of the letter
  ),
```

### Invoice

Invoice takes the following additional arguments:

```typst
  invoice-number: none,
  invoice-date: none,
  delivery-date: none, // Optional, defaults to clause to equal it to invoice date
  seller: (
    is-kleinunternehmer: false, // Optional, disables the VAT features
  ),
  items: none, // Shown in a table, has to be a dictionary as shown in the example
  after-table-text: none, // Text displayed before the payment information
  payment-due-date: none, // Optional, defaults to 14 days
  iban: none,
  bic: none,
```

### Offer

Offer takes the following additional arguments:

```typst
  seller: (
    is-kleinunternehmer: false, // Optional, disables the VAT features
  ),
  offer-number: none,
  offer-date: none,
  offer-valid-until: none, // Optional, defaults to 30 days
  offer-text: none, // The elaboration on the offer, a free text input. Look at example for details
  items: none, // Shown in a table, has to be a dictionary as shown in the example
  pre-payment-amount: 20, // A percentage of prepayment to be made. Otherwise, only a proforma invoice will be offered.
```

## Internationalization

- Language codes: `en-at` (default), `en-de`, `en-us`, `de-at`, `de-de`.
- The language is selected per document via the `lang` argument shown above.
- Kleinunternehmer text reflects the locale: `§ 6 Abs. 1 Z 27 UStG` for Austria, `§ 19 UStG` for Germany.

## Testing

Doc tests live in `doc_tests/` and are rendered for each configured language. The test runner auto-generates `doc_tests/meta.teco.typ` listing the languages to iterate over.

```bash
./run_tests.sh           # render all doc tests for en-at, de-at, de-de
./run_tests.sh --check   # faster dry run, no PDF kept
./run_tests.sh --langs "en-de,de-de"  # limit languages
./run_tests.sh --filter invoice       # run only invoice test
```

## License and Contributions

TiefLetter is currently under active development. Feedback, bug reports, and
suggestions are welcome. Please open an issue or contribute via pull requests
if you have ideas for improvement.

This package is released under the MIT License.
