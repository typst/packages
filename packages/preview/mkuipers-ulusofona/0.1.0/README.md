# mkuipers-ulusofona

An **unofficial** Typst template for academic documents at Universidade
Lusófona, based on the university's official Word template and adapted
from the excellent [orange-book](https://github.com/albcunha/orange-book)
template.

This is not an official Universidade Lusófona package; it's a personal
project that reproduces the university's cover-page style so students can
write their documents in Typst instead of Word. It provides two functions
that share the same underlying engine (page layout, header/footer, theorem
environments, outline/glossary machinery), so fixes and styling
improvements apply to both automatically:

- **`ulthesis`** — for theses and dissertations.
- **`ulreport`** — for lab and course reports.

## Which one should I use?

| | `ulthesis` | `ulreport` |
| --- | --- | --- |
| Use for | Theses, dissertations, final projects | Lab reports, course reports, lab notebooks |
| Cover fields | Supervisors ("Orientador"/"Co-orientador"), external entity | Unidade Curricular, Grupo, "Professor de UC" |
| Front matter | Acknowledgements, abstracts (PT/EN), lists of figures/tables | None of these — minimal front matter |
| Glossary position | Front matter, before chapter 1 | Back matter, after the bibliography and appendices |
| Default language | English (`lang: "en"`) | Portuguese (`lang: "pt"`) |

If you're not sure: a document with a defended, examined final deliverable
(dissertation, thesis, final project report evaluated by a jury) is
`ulthesis`; a shorter, recurring piece of coursework for a specific
Unidade Curricular is `ulreport`.

## Image rights

The cover-page background (`cover_image.jpg`) reproduces Universidade
Lusófona's own branding and is © Universidade Lusófona. It is included here
so the template can be used freely to write documents for the university;
it is not licensed for other uses. The Lisbon illustration used in the
example chapters (`chapters/images/lisbon.jpg`) is an AI-generated,
royalty-free placeholder image used only to demonstrate figure/image
inclusion.

## Getting started

```sh
typst init @preview/mkuipers-ulusofona:0.1.0 my-document
```

This creates a new folder `my-document` with:

- `main.typ` — a working `ulthesis` example (the previewed/default file).
- `main-report.typ` — a working `ulreport` example, with its own sample
  chapter (`chapters/showcase.typ`, demonstrating formulas, images,
  tables, and a block diagram).
- `chapters/` — sample chapters for both.
- `bibliography.yaml` and `glossary.yaml` — sample data for both.

Keep the file for the document type you need and delete (or just ignore)
the other — e.g. for a report, delete `main.typ`, rename `main-report.typ`
to `main.typ`, and remove the unused `chapters/chapter_0*.typ` files.
Compile right away:

```sh
cd my-document
typst compile main.typ
```

Or start from the template directly on
[Typst Universe](https://typst.app/universe/package/mkuipers-ulusofona)
using the "Start from template" button.

## Usage: `ulthesis`

```typ
#import "@preview/mkuipers-ulusofona:0.1.0": *

#show: ulthesis.with(
  title: "My Thesis Title",
  subtitle: "Optional Subtitle",
  type: "Dissertação de Mestrado",
  subtype: "Engenharia Informática",
  date: "2025",
  authors: (
    (name: "João Silva", number: "20201234", course: "Engenharia Informática"),
  ),
  supervisors: (
    "Prof. Doutor Nome do Orientador",
    "Prof. Doutor Nome do Co-orientador",
  ),
  external: "Empresa XYZ", // Optional
  acknowledgements: [Acknowledgement text here],
  abstract-pt: [Resumo em Português],
  abstract-en: [Abstract in English],
  glossary-data: yaml("glossary.yaml"), // Optional — set to none to omit
  list-of-figures: true,
  list-of-tables: true,
  list-of-acronyms: true,
  lowercase-references: false,
  lang: "pt",
)

= My First Chapter
```

| Parameter              | Description                                                    |
| ---------------------- | -------------------------------------------------------------- |
| `title`                | Main title of the thesis                                       |
| `subtitle`             | Optional subtitle                                              |
| `type`                 | Thesis type, e.g. "Dissertação de Mestrado"                    |
| `subtype`              | Field of study or course name                                  |
| `date`                 | Date to be displayed on the cover page                          |
| `authors`              | List of authors: name, number, course                          |
| `supervisors`          | List of supervisors and co-supervisors                          |
| `external`             | Optional external entity (e.g., company)                       |
| `department`           | The department, default: "Departamento de Engenharia Informática e Sistemas de Informação" |
| `acknowledgements`     | Acknowledgements content                                       |
| `abstract-en`          | Abstract (English)                                             |
| `abstract-pt`          | Resumo (Portuguese)                                            |
| `glossary-data`        | Loaded glossary data, e.g. `yaml("glossary.yaml")`; set to `none` to omit |
| `list-of-figures`      | Show list of figures (default: `true`)                          |
| `list-of-tables`       | Show list of tables (default: `true`)                           |
| `list-of-acronyms`     | Show glossary/acronyms section                                  |
| `lang`                 | Document language: `"pt"` or `"en"` (default: `"en"`)          |

## Usage: `ulreport`

```typ
#import "@preview/mkuipers-ulusofona:0.1.0": *

#show: ulreport.with(
  title: "Relatório de Laboratório 3",
  subtitle: "Optional Subtitle",
  date: "2025",
  authors: (
    (name: "João Silva", number: "20201234", course: "Engenharia Informática"),
  ),
  course-unit: "Sistemas Operativos",
  group: "3",
  professors: ("Prof. Doutor Nome do Professor",),
  glossary-data: yaml("glossary.yaml"), // Optional — set to none to omit
  lang: "pt",
)

= My First Chapter
```

| Parameter              | Description                                                    |
| ---------------------- | -------------------------------------------------------------- |
| `title`                | Main title of the report                                       |
| `subtitle`             | Optional subtitle                                              |
| `type`                 | Report type, default: "Relatório de Laboratório"                |
| `date`                 | Date to be displayed on the cover page                          |
| `authors`              | List of authors: name, number, course                          |
| `course-unit`          | Unidade Curricular name, shown on the cover page                |
| `group`                | Group name/number, shown on the cover page                      |
| `professors`           | List of course-unit professors (labeled "Professor de UC")      |
| `external`             | Optional external entity (e.g., company)                       |
| `department`           | The department, default: "Departamento de Engenharia Informática e Sistemas de Informação" |
| `glossary-data`        | Loaded glossary data, e.g. `yaml("glossary.yaml")`; printed at the end of the document, after the bibliography and appendices; set to `none` to omit |
| `list-of-acronyms`     | Show glossary/acronyms section                                 |
| `lang`                 | Document language: `"pt"` or `"en"` (default: `"pt"`)          |

## Chapters, theorems, and cross-references

Shared by both `ulthesis` and `ulreport`:

- `#chapter("Title")` — start a new chapter (equivalent to a level-1 heading, with the numbering and page-break behavior this template expects).
- `#theorem`, `#definition`, `#corollary`, `#proposition`, `#notation`, `#exercise`, `#example`, `#problem`, `#vocabulary`, `#remark` — theorem-like environments; e.g. `#theorem(name: "My theorem")[...]`.
- `#thmref(<label>)` — cross-reference a theorem-like environment by label.
- `#part("Part title")` — start a new part, grouping several chapters.
- `#appendices("Appendices")` shown as a show rule, followed by `#chapter(...)`, switches to appendix numbering (A, B, …) for what follows.
- `#my-bibliography(bibliography("refs.yaml"))` — print the bibliography with this template's styling.
- Acronyms: define them in a YAML file (see the bundled `glossary.yaml` for the format) and reference them in text with `#acr("KEY")`.

## License

Code: [MIT](LICENSE). See "Image rights" above for the cover image.
