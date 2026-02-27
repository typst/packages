# arabib

A lightweight wrapper around [citrus](https://typst.app/universe/package/citrus) that makes it easy to produce Arabic-ready bibliographies in Typst. It ships with bundled IEEE and MLA CSL styles, an Arabic locale file, and automatic Arabic numeral/punctuation conversion.

## Features

- Full Arabic numeral (٠–٩) and punctuation (،  ؛) conversion in citations and the bibliography.
- Bundled **IEEE** and **MLA** CSL styles — no external files needed.
- Automatic percent-decoding of URLs for clean Arabic-friendly link display.
- Seamless integration with [citrus](https://typst.app/universe/package/citrus) — any citation syntax it supports works with arabib.

## Quick Start

```typst
#import "@preview/arabib:0.1.0": init-arabib, arabib-bibliography

#set text(lang: "ar", dir: rtl)

#show: init-arabib.with(
  read("refs.bib"),
  style: "ieee",   // or "mla"
  lang: "ar",      // or "en" for English
)

يُشار إلى التدوين الرياضي العربي في @al-tadween-al-riyadi-al-arabi.

#arabib-bibliography(title: [المراجع])
```

## Usage

### Initialization

Apply `init-arabib` as a show rule. It takes three arguments:

| Parameter  | Type     | Description                                |
|------------|----------|--------------------------------------------|
| `bib-data` | `string` | Raw `.bib` content (use `read("file.bib")`) |
| `style`    | `string` | `"ieee"` or `"mla"`                        |
| `lang`     | `string` | `"ar"` (Arabic) or `"en"` (English)        |

### Rendering the bibliography

Call `arabib-bibliography()` where you want the reference list. All keyword arguments are forwarded to the underlying CSL renderer (e.g. `title: none` to suppress the heading).

## Examples

### IEEE style (Arabic)

```typst
#import "@preview/arabib:0.1.0": init-arabib, arabib-bibliography

#set text(lang: "ar", dir: rtl)
#show: init-arabib.with(read("cites.bib"), style: "ieee", lang: "ar")

يُشار إلى التدوين الرياضي العربي في @al-tadween-al-riyadi-al-arabi.

#arabib-bibliography(title: [المراجع])
```

To use MLA, just change `style: "mla"`.

## Arabic Documentation and Examples

See the [github project](https://github.com/MazenAmria/arabib) for a documentation in Arabic, and some rendered examples. You're welcome to create issues or contribute to that repository.

## License

The package code is licensed under **MIT**.

The bundled CSL styles and locale file (`assets/`) are licensed under [CC-BY-SA-3.0](https://creativecommons.org/licenses/by-sa/3.0/) by the [Citation Style Language](https://citationstyles.org/) project.

See [LICENSE](LICENSE) for full details.

