# Laskutys

Laskutys is a template for making invoices satisfying (mostly) the [VAT invoice requirements](https://www.vero.fi/en/detailed-guidance/guidance/48090/vat-invoice-requirements/) by the Finnish Tax Administration.
Among other things, this template features:

- Finnish/English/Swedish translations
- VAT calculations by VAT base
- Optional [bank barcode](https://www.finanssiala.fi/wp-content/uploads/2021/03/Bank_bar_code_guide.pdf) (fi. Pankkiviivakoodi)
- Optional [EPC QR Code](https://www.finanssiala.fi/wp-content/uploads/2021/03/QR_code_in_credit_transfer_forms.pdf) (European Payment Council’s Quick Response Code)
- Invoice number generation from date
- [RF creditor reference](https://www.finanssiala.fi/wp-content/uploads/2024/04/structure-of-the-rf-creditor-reference-iso-11649.pdf) (ISO 11649) generation from invoice number
- Customizable colors

> [!NOTE]
> VAT-calculation might have rounding errors due to division.
> The errors are at most a few cents.

## Usage

See [API documentation](/docs/api.md) for all arguments.

```typst
#import "@preview/laskutys:1.0.0": invoice

#let data = yaml("data.yaml")

#invoice(
  /// Optional, defaults to today
  date: datetime(year: 2025, month: 09, day: 30),
  /// Optional logo, displayed as is
  logo: image("logo.svg", height: 4em),
  iban: "FI2112345600000785",
  bic: "NDEAFIHH",
  seller: (
    name: "Yritys Oy",
    business_id: "1234567-8",
    address: [Talousosasto\ PL 12\ 00100 Helsinki],
  ),
  /// Recipient can also have business_id
  recipient: (
    name: "Kuluttaja Nimi",
    address: [Kotikatu 1\ 00100 Helsinki],
  ),
  /// fi: Finnish
  /// en: English (default)
  /// sv: Swedish
  lang: "fi",
  footnotes: [Company Oy, Phone: +358 123 4567, Email: sales.person\@company.com],
  data,
)
```

YAML data of items:

```yaml
- description: Ruoka
  quantity: 10
  # Unit price including VAT
  unit_price: "2"
  vat_rate: "0.14"

- description: AA paristo
  quantity: 2
  unit_price: "1.99"
  vat_rate: "0.255"

- description: Sanomalehti
  quantity: 3
  unit_price: "9.99"
  vat_rate: "0.10"

- description: "!Phone"
  quantity: 1
  unit_price: "1000"

  # \_ is non breaking space
- description: "Sijoituskulta, AVL\_43\_a\_§"
  quantity: 3
  unit_price: "10"
  vat_rate: "0"

```

Output of the above code:
![Example generated invoice](/docs/images/thumbnail.webp)

> [!IMPORTANT]
> Pass `unit_price` and `vat_rate` as string, so that they can be converted to decimal without errors.
> This avoids rounding errors due to imprecision of floating-point numbers.

The data can also be defined directly in Typst as an array:

```typst
#let data = (
  (
    description: "Apple",
    quantity: 10,
    unit_price: "2",
    vat_rate: "0.14",
  ),
  (
    description: "Battery AA",
    quantity: 2,
    unit_price: "2",
    vat_rate: "0.255",
  ),
  (
    description: "Item with default VAT",
    quantity: 3,
    unit_price: "10",
  ),
),
```

You can also use other [loader functions](https://typst.app/docs/reference/data-loading/) if they can produce an array in the same format.

## Documentation

- [API](/docs/api.md)
- [Development](/docs/development.md)
- [Architecture](/docs/architecture.md)
- [Color presets](/docs/color_presets.md)

## Examples

### Customize colors

```typst
#import "@preview/laskutys:1.0.0": DEFAULT_COLORS, invoice

#let data = yaml("data.yaml")

#invoice(
  ...
  colors: (
    ..DEFAULT_COLORS
    active: blue,
    bg_passive: teal.lighten(85%),
    passive: teal,
  ),
  data,
)
```

[![Changing colors](/docs/images/example_customize_colors.svg)](/examples/customize_colors/main.typ)

> [!TIP]
> The `DEFAULT_COLORS` is needed if you don't want to override all colors.
> You can also override any other preset similarly.

See Typst [documentation](https://typst.app/docs/reference/visualize/color/) for more colors and [API documentation](/docs/api.md)  for configurable colors.
There are also some presets available, see [Color presets](/docs/color_presets.md).

### Change language

Pass ISO 639 language code as `lang`.
Supported languages are

- `en`: English (default)
- `fi`: Finnish
- `sv`: Swedish

```typst
#import "@preview/laskutys:1.0.0": invoice

#let data = yaml("data.yaml")

#invoice(
  ...
  lang: "fi",
  data,
)
```

### Read configuration from file

Using [spread](https://typst.app/docs/reference/foundations/arguments/) syntax, configurations can also be read from a file.
For instance, from a YAML file.

```typst
#import "@preview/laskutys:1.0.0": *

#let data = yaml("data.yaml")
#let config = yaml("config.yaml")

#invoice(
  ..config,
  data,
)
```

YAML config file

```yaml
iban: FI2112345600000785
bic: OKOYFIHH

seller:
  name: Company Oy
  business_id: 1234567-8
  address: "Street 123\n01234 City"

recipient:
  name: Recipient Name
  address: "Street 123\n01234 City"

footnotes: "Company Oy, Phone: +358 123 4567, Email: sales.person@company.com"
```

> [!NOTE]
> `date` and `logo` cannot be read from non-Typst file since Typst cannot convert them.
> Also, use quotes `"` for string containing newline `\n` or something that is converted incorrectly.

### Automated invoice generation

Typst CLI can pass [inputs](https://github.com/typst/typst/pull/2894) to Typst file using

```console
typst compile file.typ --input key1=val1`
```

The key value pairs can be accessed in Typst file using [`sys.inputs`](https://typst.app/docs/reference/foundations/sys/) as a dictionary.

```typst
#import "@preview/laskutys:1.0.0": *

#let data = yaml("data.yaml")
#let config = sys.inputs

#invoice(
  ..config,
  data,
)
```

Since all values are strings, some preprocessing is required.
For example, the values can be JSON strings which can be parsed using [`json`](https://typst.app/docs/reference/data-loading/json/#definitions-decode).

### Hide QR code or bank barcode

Set `qrcode` or `barcode` to `false`:

```typst
...

#invoice(
  ...
  qrcode: false,
  barcode: false,
)
```

- Bank barcode supports only Finnish IBAN, so disable it if non-Finnish IBAN is used.
- EPC QR code supports non-Finnish IBAN [^epc_qr]

## License

The project is licensed under [MIT-license](/LICENSE).
Licenses of libraries used in this project are listed in [/licenses](/licenses/).

[^epc_qr]: European Payments Council, Quick Response Code: Guidelines to Enable Data Capture for the Initiation of a SEPA Credit Transfer, https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation
