# arnoptical

Select the correct Arno Pro optical-size face from the current Typst text size.

Arno Pro ships as separate Caption, SmText, Regular, Subhead, and Display font
families. This package encodes those published optical-size ranges for Typst,
so the selected face is not a stylistic preference: it follows the typeface's
own specification.

This package does not include Arno Pro font files. Install Arno Pro separately
through Adobe Fonts or another license you are entitled to use.

## Usage

```typst
#import "@preview/arnoptical:0.1.0": arno-pro-optical-text

#set text(font: "Arno Pro", size: 11pt)
#show text: arno-pro-optical-text

Arno Pro body text uses the Regular optical-size face here.

#text(size: 8pt)[Caption text uses Arno Pro Caption.]
#text(size: 18pt)[Subhead text uses Arno Pro Subhead.]
```

Semibold requests are mapped to Arno Pro's `Smbd` font families:

```typst
#text(font: "Arno Pro", weight: "semibold", size: 10pt)[
  This uses Arno Pro Smbd SmText.
]
```

## API

### `arno-pro-optical-text`

Use this as a `text` show rule after setting `text.font` to an Arno Pro family.
It only changes text whose current font name contains `Arno Pro`; other fonts
pass through unchanged. If `text.font` is a fallback list, the Arno Pro entry is
replaced in place and the remaining fallback families are preserved.

```typst
#import "@preview/arnoptical:0.1.0": arno-pro-optical-text

#set text(font: "Arno Pro")
#show text: arno-pro-optical-text

Optically sized text.
```

Fallback font lists work as expected:

```typst
#import "@preview/arnoptical:0.1.0": arno-pro-optical-text

#set text(font: ("Arno Pro", "New Computer Modern"), size: 8pt)
#show text: arno-pro-optical-text

This uses Arno Pro Caption, with New Computer Modern still available as fallback.
```

### `arno-pro-optical-font`

Return the Arno Pro family name for a size. This is useful when you want to set
the font explicitly.

```typst
#import "@preview/arnoptical:0.1.0": arno-pro-optical-font

#set text(font: arno-pro-optical-font(21pt))
```

The encoded ranges are:

| Size                      | Regular family     | Semibold family         |
| ------------------------- | ------------------ | ----------------------- |
| `<= 8.5pt`                | `Arno Pro Caption` | `Arno Pro Smbd Caption` |
| `> 8.5pt` and `<= 10.9pt` | `Arno Pro SmText`  | `Arno Pro Smbd SmText`  |
| `> 10.9pt` and `<= 14pt`  | `Arno Pro`         | `Arno Pro Smbd`         |
| `> 14pt` and `<= 21.5pt`  | `Arno Pro Subhead` | `Arno Pro Smbd Subhead` |
| `> 21.5pt`                | `Arno Pro Display` | `Arno Pro Smbd Display` |

## Specification Source

Adobe Fonts describes Arno as an Adobe Originals family with five optical size
ranges. The point-size mapping used here follows the Arno Pro specimen/release
notes, including the copy mirrored at Scribd:
<https://www.scribd.com/document/1428217/Arno-Pro>.

Additional public references:

- <https://fonts.adobe.com/fonts/arno/details/arno-pro-caption>
- <https://docslib.org/doc/375755/arno-pro-release-notes>

## Local Development

Run the full quality-control suite:

```sh
make check
```

For CI-parity checks, install `typstyle`, `shellcheck`, `typst-package-check`,
`tt` from Tytanic, and `typos`, then run:

```sh
make strict-check
```

The local suite validates the package metadata, compiles every `tests/*/test.typ`
fixture, smoke-tests an `@preview/arnoptical:0.1.0` import from a
temporary package path, compiles every Typst code block in this README, and
audits rendered PDF font faces when Arno Pro and `pdffonts` are available.

Individual targets are also available:

```sh
make manifest
make test
make smoke
make font-audit
make fmt-check
make shellcheck
make package-check
make tytanic
make typos
```

See `PUBLISHING.md` for the final Typst Universe submission checklist.

To test package-style imports before publication, place the repository at:

```text
{package-path}/preview/arnoptical/0.1.0
```

Then import with:

```typst
#import "@preview/arnoptical:0.1.0": *
```
