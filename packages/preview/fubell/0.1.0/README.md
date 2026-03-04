# Fubell 🔔

An unofficial [Typst](https://typst.app) thesis template for **National Taiwan University** (國立臺灣大學).

Inspired by the [ntu-thesis](https://github.com/tzhuan/ntu-thesis) LaTeX template and follows the official formatting guidelines. The project is named after the iconic Fu Bell on campus.

## Quick Start

```bash
typst init @preview/fubell:0.1.0 my-thesis
cd my-thesis
typst compile main.typ
```

Or clone this repository and compile the example directly:

```bash
typst compile template/main.typ
```

## Typst Web App Usage

You can use Fubell directly on the Typst web app (no local CLI required):

1. Create a new project at <https://typst.app>.
2. In `main.typ`, import `@preview/fubell:0.1.0` and configure `#show: thesis.with(...)` (see the Usage snippet below).
3. Add files for any `include` paths you use, or replace those `include` lines with inline content.
4. Keep `watermark: none` (default), or upload your own `assets/watermark.png` and set that path.

## Project Structure

```text
fubell/
├── lib.typ                  # Package entrypoint (exports `thesis`)
├── src/
│   ├── config.typ           # Page geometry, fonts, spacing defaults
│   ├── cover.typ            # Cover page layout
│   ├── certification.typ    # Oral defense certification page
│   ├── front-matter-page.typ # Abstract & acknowledgement pages (zh/en)
│   └── outline-page.typ     # ToC, List of Figures/Tables
├── template/                # Scaffolded into user projects
│   ├── main.typ             # Thesis entry point (edit this)
│   ├── refs.bib             # Bibliography
│   └── content/
│       ├── abstract-zh.typ
│       ├── abstract-en.typ
│       ├── acknowledgement-zh.typ
│       ├── acknowledgement-en.typ
│       └── chapters/
│           └── introduction.typ
├── typst.toml               # Package manifest
├── ROADMAP.md               # Development roadmap
└── CHANGELOG.md
```

## Usage

```typst
#import "@preview/fubell:0.1.0": thesis

#show: thesis.with(
  university: (zh: "國立臺灣大學", en: "National Taiwan University"),
  college:    (zh: "電機資訊學院", en: "College of EECS"),
  institute:  (zh: "資訊工程學系", en: "Dept. of CSIE"),
  title: (
    zh: "論文中文標題",
    en: "Thesis English Title",
  ),
  author:  (zh: "王小明", en: "Xiao-Ming Wang"),
  advisor: (zh: "陳大文 博士", en: "Da-Wen Chen, Ph.D."),
  student-id: "R12345678",
  degree: "master", // or "phd"
  lang: "zh", // or "en" — controls outline titles and document language
  date: (year-zh: "113", year-en: "2024", month-zh: "6", month-en: "June"),
  keywords: (
    zh: ("關鍵字一", "關鍵字二"),
    en: ("keyword one", "keyword two"),
  ),

  abstract-zh: include "content/abstract-zh.typ",
  abstract-en: include "content/abstract-en.typ",
  acknowledgement-zh: include "content/acknowledgement-zh.typ", // optional
  acknowledgement-en: include "content/acknowledgement-en.typ", // optional

  bibliography-file: bibliography("refs.bib"),
  watermark: none, // optional: e.g. "assets/watermark.png" (user-provided)
)

#include "content/chapters/introduction.typ"
```

## Watermark (Optional)

The template defaults to `watermark: none`, so no watermark file is required.

If you want to add the NTU watermark:

1. Download it from the official source: <https://www.lib.ntu.edu.tw/doc/CL/watermark.pdf>
2. Convert it to PNG and place it in your project, for example `assets/watermark.png`
3. Set `watermark: "assets/watermark.png"` in `#show: thesis.with(...)`

## Language

The `lang` option (default `"zh"`) controls the document language and structural titles (Table of Contents, List of Figures, List of Tables). Set `lang: "en"` for English headings. Cover and certification pages remain bilingual regardless of this setting.

Line spacing follows NTU guidelines: 1.5 間距 for Chinese (`lang: "zh"`) and double spacing for English (`lang: "en"`).

## Fonts

The template uses **Times New Roman** for English text and **標楷體 (BiauKai)** for Chinese text, matching NTU's formatting requirements.

The font fallback chains are:

| Purpose | Fallback order |
|---------|---------------|
| English | Times New Roman → TeX Gyre Termes → STIX Two Text |
| Chinese | BiauKaiTC → DFKai-SB → TW-MOE-Std-Kai → Kaiti TC → Kaiti SC |

Currently bold/italic do not work for Chinese fonts, workarounds with `stroke` and `skew` are being considered.

### Caveats — Typst web app

Times New Roman and 標楷體 are proprietary fonts that are **not available** on the Typst web app. The template will automatically fall back to:

- **TeX Gyre Termes** for English — the closest open-source match to Times New Roman [(Typst Issue #416)](https://github.com/typst/typst/issues/416).
- **TW-MOE-Std-Kai** (教育部標準楷書) for Chinese — available natively on the Typst web app.

The output will look very similar but not byte-identical to a local build with the proprietary fonts installed. For official submission, it is recommended to **compile locally with Times New Roman and 標楷體 installed**.

If any fallback fonts are missing, you will likely see warnings during compilation. Please ignore them as long as the document renders correctly.

## Contributing

Issues and pull requests are welcome! If you spot a formatting bug, have a feature idea, or want to pick up something from the [roadmap](ROADMAP.md) — please go for it :)
Contributions that implement new features are especially appreciated.

## License

[MIT](LICENSE)
