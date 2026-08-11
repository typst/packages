# 🩲 Briefs

Briefs is a simple [Typst](https://typst.app/) template for letters (German: Briefe).
It is inspired by [DIN 5008](https://de.wikipedia.org/wiki/DIN_5008) and targets A4 paper.
The address box fits the window of a
[DIN lang](https://de.wikipedia.org/wiki/DIN_lang) envelope.

## Example
```typst
#import "@preview/briefs:0.2.0": letter

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

![example](img/example.png)

For more examples check out the folder
[`tests`](https://github.com/tndrle/briefs/tree/main/tests).

## Reference
### Document Structure
The image below shows the basic document structure. The address box contains
sender and recipient.
The information box contains additional information – the default is sender,
location, and date.
![structure](img/structure.png)

### API
```typst
letter(
  sender: (),
  sender-font-size: 8pt,
  sender-separator: ", ",
  recipient: [],
  recipient-top-margin: 12.7mm,
  address-box: (25mm, 50mm, 80mm, 40mm),
  information: auto,
  information-box: (125mm, 25mm, 75mm, 65mm),
  date: auto,
  date-format: auto,
  location: none,
  location-date-separator: ", ",
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

**`sender`** &emsp; `array of content` &emsp; *Default*: `()`<br>Sender's name and address. This address is shown in the address box with
font size `sender-font-size` and concatenated with separator
`sender-separator`. If `information` is `auto`, this address is also
shown at the top of the information box.

**`sender-font-size`** &emsp; `length` &emsp; *Default*: `8pt`<br>Font size of the sender's name and address in the address box

**`sender-separator`** &emsp; `content` &emsp; *Default*: `", "`<br>Separator between the sender's address parts in the address box

**`recipient`** &emsp; `content` &emsp; *Default*: `[]`<br>The recipient's name and address. Add line breaks manually.

**`recipient-top-margin`** &emsp; `length` &emsp; *Default*: `12.7mm`<br>The recipient's top margin in the address box

**`address-box`** &emsp; `array of length` &emsp; *Default*: `(25mm, 50mm, 80mm, 40mm)`<br>Absolute position and size of the address box: (x, y, width, height)

**`information`** &emsp; `auto` | `content` &emsp; *Default*: `auto`<br>Content of the information box. If this is `auto`, the sender, location,
and date are shown as a default.

**`information-box`** &emsp; `array of length` &emsp; *Default*: `(125mm, 25mm, 75mm, 65mm)`<br>Absolute position and size of the information box: (x, y, width, height)

**`date`** &emsp; `auto` | `datetime` | `content` &emsp; *Default*: `auto`<br>The date (only used, if `information` is `auto`). If this is
`auto`, the current date is shown. If `auto` or a value of type `datetime`
is provided, the date will be formatted with `date-format`.

**`date-format`** &emsp; `auto` | `str` &emsp; *Default*: `auto`<br>The date format pattern which is applied if `date` is `auto` or of type
`datetime`. If `date-format` is a string, it is directly passed to Typst's
`datetime.display()` function. If `date-format` is `auto`, the pattern
passed to `datetime.display()` is determined as follows:
* if `text.lang = "de"`: `"[day].[month].[year]"`
* if `text.lang = "en"`: `"[month repr:long] [day padding:none], [year]"`
* otherwise: `auto`


**`location`** &emsp; `none` | `content` &emsp; *Default*: `none`<br>The location (only used, if `information` is `auto`)

**`location-date-separator`** &emsp; `content` &emsp; *Default*: `", "`<br>The separator between location and date

**`subject`** &emsp; `none` | `content` &emsp; *Default*: `none`<br>The subject

**`folding-marks`** &emsp; `none` | `dictionary` &emsp; *Default*: `(:)`<br>Whether folding marks are shown and how. If `none`, no marks are shown.
Otherwise, a dictionary defines how the marks are shown. The dictionary
can have the following keys:
* **`pages`** &emsp; `str`<br>On which pages the marks are shown: `"both"`,
`"even"`, or `"odd"`
* **`length`** &emsp; `length`<br>The length of the marks
* **`stroke`** &emsp; `stroke`<br>The stroke of the marks
* **`xdist`** &emsp; `length`<br>The distance to the left edge of the page

All keys are optional. If provided, they overwrite their default value.<br>
The default is `(pages: "both", length: 5mm, stroke: 0.25pt, xdist: 5mm)`.

**`hole-punch-marks`** &emsp; `none` | `dictionary` &emsp; *Default*: `(:)`<br>Whether hole punch marks are shown and how. See `folding-marks` for
details.<br>
The default is `(pages: "both", length: 7mm, stroke: 0.25pt, xdist: 5mm)`.

**`background`** &emsp; `content` &emsp; *Default*: `[]`<br>Content for the page background. The folding marks and the hole punch
marks are placed on the page's background. If you want to add additional
content to the background, provide it here.

**`show-boxes`** &emsp; `bool` &emsp; *Default*: `false`<br>Whether address box and information box are framed. This is mainly for
debugging.

**`page-args`** &emsp; `any` (*variadic*)<br>Additional arguments for Typst's `page()` function.<br>
Default arguments (can be overwritten):
* `margin: (left: 25mm, rest: 20mm)`
* `number-align: bottom + right`
* `numbering: (i, t) => text(10pt, context (localized().page-number)(i, t))`


**`body`** &emsp; `content`<br>The letter content

