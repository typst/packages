# 🩲 Briefs

Briefs is a simple [Typst](https://typst.app/) template for letters (German: Briefe).
It is inspired by [DIN 5008](https://de.wikipedia.org/wiki/DIN_5008) and targets A4 paper.
The address box aligns with the window of a
[DIN lang](https://de.wikipedia.org/wiki/DIN_lang) envelope.

## Example
```typst
#import "@preview/briefs:0.3.0": letter

#set text(lang: "de", font: "TeX Gyre Heros")
#show: letter.with(
  sender: (
    [Hilfsorganisation e.V.],
    [Spendengasse 12],
    [12345 Helfershausen]
  ),
  recipient: [
    Frau\
    Erika Mustermann\
    Rathausplatz 37\
    67890 Waldhausen
  ],
  location: "Helfershausen",
  subject: [*Vielen Dank für Ihre Spende*]
)

Sehr geehrte Frau Mustermann,

wir bedanken uns herzlich für Ihre großzügige Spende an unseren Verein.
Durch Ihre Unterstützung können wir weiterhin wichtige soziale Projekte
durchführen und Menschen in Not helfen.

Vielen Dank für Ihr Vertrauen und Ihre Mithilfe!

#v(0.5cm)
Mit freundlichen Grüßen

Hilfsorganisation e.V.
```

![An example letter generated with briefs](img/example.png)

Additional examples can be found in the
[`tests`](https://github.com/tndrle/briefs/tree/v0.3.0/tests) directory.

## Reference
### Document Structure
The image below shows the basic document structure. The address box contains
sender and recipient.
The information box contains supplementary information.
By default, it displays the sender, content in `information-extra`,
location, and date.
![The basic document structure of letter generated with briefs](img/structure.png)

### API
```typst
letter(
  sender: (),
  sender-font-size: 8pt,
  sender-separator: [, ],
  recipient: [],
  recipient-top-margin: 12.7mm,
  address-box: (25mm, 50mm, 80mm, 40mm),
  information: auto,
  information-box: (125mm, 25mm, 75mm, 65mm),
  information-extra: none,
  date: auto,
  date-format: auto,
  location: none,
  location-date-separator: [, ],
  subject: none,
  folding-marks: (:),
  hole-punch-marks: (:),
  background: [],
  show-boxes: false,
  ..page-args,
  body
)
```

**Arguments**

**`sender`** &emsp; `array of content` &emsp; *Default*: `()`<br>The sender's address. This address is shown in the address box
with font size `sender-font-size` and concatenated with separator
`sender-separator`. If `information` is `auto`, this address is also
shown at the top of the information box.

**`sender-font-size`** &emsp; `length` &emsp; *Default*: `8pt`<br>The font size for the sender's address in the address box

**`sender-separator`** &emsp; `content` &emsp; *Default*: `[, ]`<br>The separator between the sender's address parts in the address box

**`recipient`** &emsp; `content` &emsp; *Default*: `[]`<br>The recipient's address. Line breaks must be inserted manually.

**`recipient-top-margin`** &emsp; `length` &emsp; *Default*: `12.7mm`<br>The recipient's top margin in the address box

**`address-box`** &emsp; `array of length` &emsp; *Default*: `(25mm, 50mm, 80mm, 40mm)`<br>Absolute position and size of the address box in the form
`(x, y, width, height)`.

**`information`** &emsp; `auto` | `content` &emsp; *Default*: `auto`<br>The content of the information box. If this is `auto`, the sender,
optional content in `information-extra`, the location, and the date
are shown as a default.

**`information-box`** &emsp; `array of length` &emsp; *Default*: `(125mm, 25mm, 75mm, 65mm)`<br>Absolute position and size of the information box in the form
`(x, y, width, height)`.

**`information-extra`** &emsp; `none` | `content` &emsp; *Default*: `none`<br>Additional content for the information box (only used if `information`
is `auto`). This content is displayed after the sender and can be used,
for example, to show a phone number or email address.

**`date`** &emsp; `none` | `auto` | `datetime` | `content` &emsp; *Default*: `auto`<br>The date (only used if `information` is `auto`). If this is
`auto`, the current date is shown. If `auto` or a value of type `datetime`
is provided, the date will be formatted with `date-format`.

**`date-format`** &emsp; `auto` | `str` &emsp; *Default*: `auto`<br>The date format pattern which is applied if `date` is `auto` or of type
`datetime`. If `date-format` is a string, it is passed directly to Typst's
`datetime.display()` function. If `date-format` is `auto`, the pattern
passed to `datetime.display()` is determined as follows:
* if `text.lang = "de"`: `"[day].[month].[year]"`
* if `text.lang = "en"`: `"[month repr:long] [day padding:none], [year]"`
* otherwise: `auto`


**`location`** &emsp; `none` | `content` &emsp; *Default*: `none`<br>The location (only used if `information` is `auto`)

**`location-date-separator`** &emsp; `content` &emsp; *Default*: `[, ]`<br>The separator between location and date

**`subject`** &emsp; `none` | `content` &emsp; *Default*: `none`<br>The subject

**`folding-marks`** &emsp; `none` | `dictionary` &emsp; *Default*: `(:)`<br>Whether folding marks are displayed and how they are rendered.
If `none`, no marks are shown.
Otherwise, a dictionary defines how the marks are shown. The dictionary
can have the following keys:
* **`pages`** &emsp; `str`<br>On which pages the marks are shown: `"both"`,
`"even"`, or `"odd"`
* **`length`** &emsp; `length`<br>The length of the marks
* **`stroke`** &emsp; `stroke`<br>The stroke of the marks
* **`xdist`** &emsp; `length`<br>The distance to the left edge of the page

All keys are optional. If provided, they overwrite their default value.<br>
The default is `(pages: "both", length: 5mm, stroke: 0.25pt, xdist: 5mm)`.

**`hole-punch-marks`** &emsp; `none` | `dictionary` &emsp; *Default*: `(:)`<br>Whether hole punch marks are displayed and how they are rendered.
See `folding-marks` for details.<br>
The default is `(pages: "both", length: 7mm, stroke: 0.25pt, xdist: 5mm)`.

**`background`** &emsp; `content` &emsp; *Default*: `[]`<br>Content for the page background. The folding marks and the hole punch
marks are placed on the page's background. If you want to add additional
content to the background, provide it here.

**`show-boxes`** &emsp; `bool` &emsp; *Default*: `false`<br>Whether address box and information box are framed.
This is primarily intended for layout debugging.

**`page-args`** &emsp; `any` (*variadic*)<br>Additional arguments for Typst's `page()` function.<br>
Default arguments (can be overwritten):
* `margin: (left: 25mm, rest: 20mm)`
* `number-align: bottom + right`
* `numbering: (i, t) => text(10pt, context (localized().page-number)(i, t))`


**`body`** &emsp; `content`<br>The letter content

