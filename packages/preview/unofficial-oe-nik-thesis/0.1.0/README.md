# unofficial-oe-nik-thesis

This is a template for theses at the John von Neumann Faculty of Informatics (Neumann János Informatikai Kar, NIK), Óbuda University.
It covers both the BSc, BProf and SZT thesis (szakdolgozat) and the MSc thesis work (diplomamunka), which can be written in English or Hungarian.

This template is unofficial, it isn't made or endorsed by the university.

## Usage

In the [web app](https://typst.app), choose "Start from template" and search for `unofficial-oe-nik-thesis`.

On the command line, create a project and compile it on every change:

```sh
typst init @preview/unofficial-oe-nik-thesis:0.1.0 thesis
cd thesis
typst watch main.typ
```

The new project is an example thesis that shows what the template can do, replace its content with your own.
The smallest thesis looks like this:

```typ
#import "@preview/unofficial-oe-nik-thesis:0.1.0": thesis-template

#show: thesis-template.with(
  lang: "en",
  degree: "BSc",
  year: 2026,
  title: "The title of the thesis",
  author: "Your Name",
  registration-number: "T/0012345/FI12904/N",
)

= Introduction

...
```

The parts that are still missing, like the abstracts or the signed forms, show up as red notes in the document.

## Fonts

The guide asks for Times New Roman and the cover page uses Arial, but the template uses their free alternatives: Nimbus Roman and Nimbus Sans.
Typst packages can't include fonts, so you need to get them yourself.
Download these files from the [URW base 35 fonts](https://github.com/ArtifexSoftware/urw-base35-fonts/tree/20200910/fonts):

- `NimbusRoman-Regular.ttf`, `NimbusRoman-Bold.ttf`, `NimbusRoman-Italic.ttf`, `NimbusRoman-BoldItalic.ttf`
- `NimbusSans-Regular.ttf`, `NimbusSans-Bold.ttf`, `NimbusSans-Italic.ttf`, `NimbusSans-BoldItalic.ttf`

Use the `.ttf` files, not the `.otf` ones from the same repository or your Linux distribution's package.
The `.ttf` files have the same line height as Times New Roman, and the line spacing of the template relies on it.

In the web app, upload the files anywhere in your project, they are picked up automatically.
On the command line, install them on your system, or keep them in a folder and pass it to Typst:

```sh
typst watch --font-path fonts main.typ
```

With Nix, the repository's flake has them as a package:

```sh
export TYPST_FONT_PATHS=$(nix build --no-link --print-out-paths github:gepbird/unofficial-oe-nik-thesis/v0.1.0#nimbus)/share/fonts
typst watch main.typ
```

## Features

The template takes care of the formal requirements:

- the typography: the page layout, the fonts, the headings and paragraphs, and the numbering of chapters, figures, tables and equations
- the cover page
- the mandatory parts in the right order: the abstracts, the table of contents, the summaries in Hungarian and English, and the bibliography
- the optional parts: the lists of figures and tables, the list of abbreviations and the appendices
- the list of the AI tools you used, which the university requires if you used any
- the length limits of the main content and the summaries, checked before you submit

The worksheet, the student declaration, the consultation log and the confidentiality document (only if your thesis is confidential) have to be signed, so the template can't generate them.
Instead, you need to insert the signed PDFs, until then a placeholder marks their place.

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `lang` | `"en"` | `"en"` or `"hu"`, the language of the cover page, the generated titles, the captions and the references |
| `degree` | required | `"BSc"`, `"BProf"` or `"SZT"` for a thesis, `"MSc"` for a thesis work |
| `year` | required | the year of submission, e.g. `2026` |
| `title` | required | the title of the thesis, it's only in the PDF's metadata, the cover page doesn't have it |
| `author` | required | your name |
| `registration-number` | required | your registration number (törzsszám) from Neptun, not the Neptun code, e.g. `"T/0012345/FI12904/N"` |
| `worksheet`, `declaration`, `consultation-log` | `auto` | the signed forms, e.g. `path("signed/worksheet.pdf")` |
| `confidentiality` | `none` | the signed confidentiality document, only if your thesis is confidential |
| `abstract`, `summary` | `auto` | in both languages, e.g. `(hu: include "chapters/abstract-hu.typ", en: include "chapters/abstract-en.typ")` |
| `bibliography` | `auto` | e.g. `bibliography("bibliography.bib")`, in IEEE style |
| `abbreviations` | `auto` | e.g. `((key: "pdf", short: "PDF", long: "Portable Document Format"),)`, used in the text as `@pdf` |
| `list-of-figures`, `list-of-tables` | `true` | `false` leaves the list out, an empty list is left out anyway |
| `appendices` | `none` | each appendix is a subchapter, e.g. `[== Source code ...]` |
| `ai-tools` | `none` | the AI tools you used, see below |
| `body-length`, `summary-length` | `auto` | changes to the length limits, see below |
| `draft` | `true` | `false` for the version to submit |

A part that is `auto` is still missing and shows up as a red note, `none` leaves it out.

### AI tools

The rector's instruction requires a list of the AI tools you used at the end of the thesis.
Add each tool with `ai-tool` and a label, then reference it in the text where you used it.
Text written by AI has to be in italics followed by the reference, `ai-generated` does that:

```typ
#import "@preview/unofficial-oe-nik-thesis:0.1.0": ai-generated, ai-tool, thesis-template

#show: thesis-template.with(
  // ...
  ai-tools: [
    #ai-tool(
      developer: [Anthropic],
      name: [Claude],
      type: [generative AI chatbot],
      version: [Claude Sonnet 5.5],
      usage: [suggesting wrong parameter values for testing],
      date: datetime(year: 2026, month: 9, day: 14),
    ) <ai-test-cases>
  ],
)

I tested the template with wrong parameter values suggested by an AI chatbot @ai-test-cases.
#ai-generated(<ai-test-cases>)[An unknown degree and a missing registration number.]
```

All fields are required, and `date` can also be a period, like `(datetime(...), datetime(...))`.

### Length limits

The length of the thesis is checked when `draft` is `false`:

| Degree | Chapters | Up to the end of the appendices | Each summary |
| --- | --- | --- | --- |
| BSc, BProf, SZT | at least 40 pages and 60,000 characters | at most 60 pages | 1,500 to 2,500 characters |
| MSc | at least 60 pages and 80,000 characters | at most 80 pages | 1,500 to 2,500 characters |

The characters include spaces.
If your supervisor approved an exception, change a limit like `body-length: (min-pages: 39)` or `summary-length: (max-characters: 3000)`.
A limit set to `none` isn't checked, and `none` turns off all the checks of that parameter.

### Signed forms

Print the forms, sign them, scan them into PDFs, and put them in the project, for example in a `signed` folder:

```typ
worksheet: path("signed/worksheet.pdf"),
declaration: path("signed/declaration.pdf"),
consultation-log: path("signed/consultation-log.pdf"),
```

The worksheet has 2 pages and the other forms have 1.
If your scan has a different number of pages, use `pdf-pages` (import it like `thesis-template`):

```typ
consultation-log: pdf-pages(path("signed/consultation-log.pdf"), pages: 2),
```

Scanned images also work, one image or an array of images, one per page, e.g. `declaration: image("signed/declaration.png")`.

### Draft mode

While `draft` is `true`, the missing parts and other problems are red notes in the document, so you can compile it at any time.
Before you submit, turn it off with `draft: false`, or without changing the source:

```sh
typst compile --input draft=false main.typ
```

The red notes become errors, and the length limits are checked too.
Setting a part to `none` silences its note and its error, so only use it for parts your thesis really doesn't need.

## Sources

The template follows these documents:

- the faculty's thesis preparation guide, 2025/2026/1 ([English](https://nik.uni-obuda.hu/wp-content/uploads/2025/10/NIK_SZD_DM_TAJ_2025_2026_01_ENG.pdf), [Hungarian](https://nik.uni-obuda.hu/wp-content/uploads/2025/10/NIK_SZD_DM_TAJ_2025_2026_01.pdf), and the [newer Hungarian version](https://nik.uni-obuda.hu/wp-content/uploads/2025/12/NIK_SZD_DM_TAJ_20252601_2025.pdf)),
- the faculty's [Word sample thesis](https://nik.uni-obuda.hu/wp-content/uploads/2025/12/SZD_DM_Word_dolgozat_sablon_2025.docx),
- the [18/2026. rector's instruction](https://uni-obuda.hu/wp-content/uploads/2026/10/18_2026_rektori_utasitas_mesterseges_intelligencia_oktatas.pdf) on the use of AI.

These documents sometimes contradict each other or leave things open, in those places the template makes its best guess.
Where the guides differ, the newer Hungarian guide wins, and the Word sample fills in what they leave open.
A few choices were approved by my supervisor, including the one-sided pages and the free Nimbus Roman font instead of Times New Roman.

## License

The template is licensed under [MIT-0](LICENSE), you can use it without attribution.

The Óbuda University logo (`src/cover/oe-logo.svg`) and the seal of the faculty (`src/cover/nik-seal.png`) are not covered by this license.
They are owned by Óbuda University and are distributed with the template with its permission.
They are converted from the cover page of the faculty's [Word sample thesis](https://nik.uni-obuda.hu/wp-content/uploads/2025/12/SZD_DM_Word_dolgozat_sablon_2025.docx), which the faculty publishes for students to write their theses with.
The university's [rector's instruction on its logo](https://uni-obuda.hu/wp-content/uploads/2025/01/3_2025_Rektori_Utasitas_jubileum_logo.pdf) asks to use its visual identity in its original form, without changing its colors, fonts or layout.
