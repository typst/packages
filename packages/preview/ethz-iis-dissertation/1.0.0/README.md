# ethz-iis-dissertation

ETH Zurich IIS PhD dissertation template for Typst.

This template follows the [ETH Zurich doctoral regulations](https://ethz.ch/en/doctorate.html)
and the house style of the [Integrated Systems Laboratory (IIS)](https://iis.ee.ethz.ch).

## Usage

Initialize a new dissertation project with:

```sh
typst init @preview/ethz-iis-dissertation
```

Or add it to an existing project:

```typst
#import "@preview/ethz-iis-dissertation:1.0.0": dissertation, chapter-short

#show: dissertation.with(
  title: "Title of Your Dissertation",
  author: "Firstname Lastname",
  email: "username@iis.ee.ethz.ch",
  date-of-birth: "dd.mm.yyyy",
  supervisor: "Prof. Dr. Supervisor Name",
  co-examiners: ("Prof. Dr. Co-Examiner Name",),
  year: 2026,
  mode: "official",
  acknowledgements: include "chapters/acknowledgements.typ",
  abstracts: (
    include "chapters/abstract_en.typ",
    include "chapters/abstract_de.typ",
  ),
  acronyms: acronyms,
  bibliography: bibliography("references.bib", style: "ieee"),
  appendices: (
    include "appendices/appendix.typ",
  ),
  cv: include "cv.typ",
)

= Introduction

...
```

## Render modes

- `mode: "official"` — for submission to ETH (grey cover, no ISBN)
- `mode: "series"` — for the Hartung-Gorre publication copy (requires `volume`, `isbn`, `isbn-long`, `published`)

## Parameters

| Parameter | Type | Description |
|---|---|---|
| `title` | string | Dissertation title |
| `author` | string | Full name |
| `email` | string | Author email |
| `date-of-birth` | string | "dd.mm.yyyy" |
| `diss-number` | int or none | ETH dissertation number |
| `supervisor` | string | Main supervisor |
| `co-examiners` | array | Co-examiner names |
| `year` | int | Year of examination |
| `mode` | string | `"official"` or `"series"` |
| `acknowledgements` | content | Acknowledgements section |
| `abstracts` | array | English and German abstracts |
| `acronyms` | dict | Acronym definitions for acrostiche |
| `bibliography` | content | Bibliography element |
| `appendices` | array | Appendix chapters |
| `cv` | content | Curriculum Vitae content |

## Third-Party Assets

The ETH Zürich logo (`shared/figures/eth_logo_kurz_pos.svg`) is a trademark of
ETH Zürich and is **not** covered by the Apache-2.0 license. It is reproduced as
publicly available on [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:ETH_Z%C3%BCrich_Logo_black.svg).
Users must comply with [ETH Zürich's branding guidelines](https://ethz.ch/staffnet/en/service/communication/corporate-design/eth-logo.html).

## License

Apache-2.0 — Copyright 2026 ETH Zurich.
