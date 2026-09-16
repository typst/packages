# unofficial-hso-thesis

Typst template for Bachelor's, Master's theses and seminar reports at Hochschule Offenburg (University of Applied Sciences Offenburg). Supports multiple faculties and follows the official academic writing guidelines.

## Supported Faculties

| Key | Faculty |
| --- | ------- |
| `faculty.EMI` | Elektrotechnik, Medizintechnik und Informatik |
| `faculty.MV` | Maschinenbau & Verfahrenstechnik |
| `faculty.W` | Wirtschaft |

## Quick Start

Initialize a new project:

```bash
typst init @preview/unofficial-hso-thesis:0.1.0
```

This copies the template files into your project. Edit `main.typ` to fill in your metadata and start writing.

## Usage

```typst
#import "@preview/unofficial-hso-thesis:0.1.0": company, faculty, styles, supervisor, thesis, thesis-info, thesis-type

#let info = thesis-info(
  lang: "de",
  thesis-type: thesis-type.BACHELOR,
  title: "Haupttitel der Bachelorthesis",
  subtitle: "Untertitel",
  author: "Max Mustermann",
  degree: "Informatik",
  faculty: faculty.EMI,
  period: [01.01.2026 -- 30.06.2026],
  supervisors: (
    supervisor(name: "Prof. Dr. Max Mustermann", institution: "Hochschule Offenburg", gender: "m"),
    supervisor(name: "Maxi Musterfrau", institution: "Musterfirma"),
  ),
  companies: (
    company(name: "Musterfirma GmbH"),
  ),
  location: "Offenburg",
  copyright: true,
  ai-usage: 1, // 1: listed in appendix, 2: marked in text, 3: prohibited, none: disabled
  glossary: yaml("glossary.yaml"),
  bibliography: read("Bibliography.yaml", encoding: none),
  bibliography-style: read("ieee.csl", encoding: none),
)

#show: thesis.with(
  info: info,
  style: styles.emi,
  abstract: include "abstract.typ",
  appendix: include "appendix.typ"
)

#include "chapters/01_introduction.typ"
```

## Parameters

### `thesis-info`

Central metadata object for the thesis.

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `lang` | `str` | `"de"` or `"en"` |
| `thesis-type` | `thesis-type.*` | `BACHELOR`, `MASTER`, or `SEMINAR` |
| `title` | `str` | Main title |
| `subtitle` | `str` | Subtitle (optional) |
| `author` | `str` | Author's full name |
| `degree` | `str` | Degree programme |
| `faculty` | `faculty.*` | `EMI`, `MV`, or `W` |
| `period` | `content` | Processing period, e.g. `[01.01.2026 -- 30.06.2026]` |
| `supervisors` | `array` | Array of `supervisor()` objects |
| `companies` | `array` | Array of `company()` objects |
| `location` | `str` | City for the declaration signature |
| `copyright` | `bool` | Grant HSO right to use the work for teaching |
| `ai-usage` | `int` or `none` | AI usage declaration: `1` (list in appendix), `2` (marked in text), `3` (prohibited), `none` (disabled) |
| `glossary` | `dict` | Loaded YAML data for the glossary |
| `bibliography` | `bytes` | Bibliography file content via `read(..., encoding: none)` |
| `bibliography-style` | `bytes` | CSL file content via `read(..., encoding: none)` |

### `thesis` (main function)

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `info` | `dict` | The `thesis-info` object |
| `style` | `func` | Faculty style: `styles.emi`, `styles.mv`, or `styles.w` |
| `abstract` | `content` | Abstract content (optional) |
| `appendix` | `content` | Appendix content (optional) |
| `body` | `content` | Main document content |

### Helper functions

- `supervisor(name, institution, gender)` — creates a supervisor entry; `gender` is `"m"` or `"f"`.
- `company(name, logo)` — creates a company entry; `logo` is an optional `image()`.

## Fonts

This template uses **Arial** (body text) and **Courier New** (code/listings). Both are standard system fonts on Windows and macOS. On Linux, install the Microsoft core fonts:

```bash
# Debian/Ubuntu
sudo apt install ttf-mscorefonts-installer

# Arch
yay -S ttf-ms-fonts
```

Alternatively, compile with `--font-path /path/to/fonts` pointing to a directory containing `arial.ttf` and `cour.ttf`.

## License

- **`src/`** — [MIT License](LICENSE). Package source code.
- **`template/`** — [MIT-0 (No Attribution)](LICENSE). You can freely publish your thesis without including any copyright notice.
- **`assets/hso-logo.svg`** — property of Hochschule Offenburg, included with their permission. Not covered by the MIT/MIT-0 licenses.
