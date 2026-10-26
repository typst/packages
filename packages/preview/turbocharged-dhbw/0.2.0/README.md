[🇩🇪 Deutsch](README.de.md) | 🇬🇧 English

# turbocharged-dhbw

Unofficial layout for practical reports, project reports, and theses at the DHBW (Duale Hochschule Baden-Württemberg), modeled on the common DHBW LaTeX template. It can be adapted for other universities.

This package is not affiliated with the DHBW.

## Usage

Create a project from the template:

```bash
typst init @preview/turbocharged-dhbw:0.2.0 my-report
cd my-report
typst watch main.typ
```

Or import it into an existing project:

```typst
#import "@preview/turbocharged-dhbw:0.2.0": report

#show: report.with(
  author: "Rudi Regentonne",
  title: "Coffee Consumption in the Home Office",
  document-type: "Praxisbericht",
  program: "Informatik",
  student-id: "1234567",
  course: "TINF25B1",
  city: "Karlsruhe",
  submission-date: "01.10.2026",
  confidential: false,
)

= Introduction
Your text.
```

Several authors share one place and one date. Each gets a signature line on the declaration. The title page lists the names separated by commas.

```typst
author: ("Rudi Regentonne", "John Smith"),
```

`lang` is `"de"` by default. Set `lang: "en"` for the English strings.

## Parameters

Passed to `report.with(...)`. Only `title`, `program`, and `document-type` need a real value; the rest have defaults.

| Parameter | Default | Description |
| --- | --- | --- |
| `author` | — | Name, or an array of names. |
| `title` | — | Title on the cover. |
| `document-type` | — | For example `Praxisbericht`, `Projektarbeit`, `Studienarbeit`, `Bachelorarbeit`. |
| `program` | — | Degree program. |
| `module` | `none` | Module name or exam number. |
| `submission-date` | `none` | Submission date, as you want it printed. |
| `duration` | `none` | Processing period. |
| `student-id` | `none` | Matriculation number, or an array. Each ID gets its own row on the title page. |
| `course` | `none` | Course, for example `TINF25B1`, or an array. Each course gets its own row on the title page. |
| `city` | `none` | Company location. Also printed on the declaration. |
| `company-name` | `none` | Training company. |
| `company-logo` | `none` | Company logo, as `image("path/to/logo.png")`. |
| `company-supervisor` | `none` | Supervisor at the company. |
| `university` | DHBW Karlsruhe | University name on the cover. |
| `university-logo` | DHBW logo | University logo. The bundled DHBW logo is used when this is `none`. |
| `university-supervisor` | `none` | Supervisor at the university. |
| `confidential` | `true` | Insert a confidentiality notice. |
| `confidential-text` | `none` | Custom confidentiality text. |
| `show-declaration` | `true` | Insert the declaration of authorship. |
| `show-ai-declaration` | `auto` | Append the AI-tools sentence to the declaration. `auto` adds it when `ai-tools` is set. `false` turns it off. |
| `declaration-title` | `none` | Custom declaration heading. |
| `declaration-text` | `none` | Custom declaration body. |
| `abstract-content` | `none` | Abstract, usually `include "content/abstract.typ"`. |
| `acronyms` | `()` | Dictionary or `yaml("abk.yml")` for the list of abbreviations. |
| `bibliography-content` | `none` | A `bibliography(...)` call. |
| `appendix-content` | `none` | Appendix, usually `include "content/anhang.typ"`. |
| `ai-tools` | `none` | Dictionary or `yaml("ai.yml")`. Rendered as a table in the appendix. |
| `cover-page` | `none` | Replaces the generated title page. |
| `lang` | `"de"` | `"de"` or `"en"`. |

Also exported: `code` for numbered listings, `small-todo` (a smaller `dashy-todo`), `ai-tools-table`, `ai-acknowledgement`, and `source`. Write `#source[...]` with no space before it. It stays on the caption line and is omitted from the list of figures. Own work: `#source[eigene Darstellung]` prints `(eigene Darstellung)`. A citation: `#source[@key]` prints the citation as-is, not `([1])`. Adapted figures: `#source[in Anlehnung an @key]`.

Do not pass `ai-tools` and also call `ai-tools-table` yourself, or the table appears twice.

Docs: <https://typst.app/docs/>
