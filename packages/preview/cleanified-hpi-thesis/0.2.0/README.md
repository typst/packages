# HPI Thesis Template

This template is for HPI students writing their Bachelor's or Master's thesis.

## Disclaimer

- This template is not official.
- Official university guidelines may differ from the ones used in this template.

## Getting Started

```bash
typst init @preview/cleanified-hpi-thesis
```

## Configuration

An example configuration is located in [`example/`](./example/main.typ).

```typst
#import "@preview/cleanified-hpi-thesis:0.2.0": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  translation: "Eine adäquate Übersetzung meines Titels",
  name: "Max Mustermann",
  date: "17. Juli, 2025",
  study-program: "IT-Systems Engineering",
  chair: "Data-Intensive Internet Computing",
  professors: ("Prof. Dr. Rosseforp Renttalp", "Prof. Dr. Erika Mustermann"),
  advisors: ("Dr. Karla Musterfrau",),
  abstract: "Some abstract",
  abstract-de: "Der deutsche Abstract...",
  acknowledgements: "Thanks to ...",
  // acronyms: [API -- Application Programming Interface],
  // ai-declaration: [Describe any use of generative AI tools here.],
  type: "Master",
  bibliography: bibliography("references.bib"),
  // lang: "de",
  // typography: (font: "STIX Two Text", body-text-size: 12pt),
  // layout: (for-print: true, toc-depth: 2),
  // appearance: (accent-color: rgb("#B1063A")),
  // labels: (declaration-city: "Berlin"),
)

... your content ...
```

`professors` and `advisors` are ordered tuples. Their entries appear in the
given order, one name per line, on the title page. A tuple containing one person
requires a trailing comma, for example `("Dr. Karla Musterfrau",)`.

Set `acronyms` to optional content that should appear after the acknowledgements
and before the table of contents. The template does not prescribe how that
content is generated, so it can be supplied by a glossary package or written
directly.

Set `ai-declaration` to disclose the use of generative AI tools in the final,
signed declaration of authorship. The disclosure is placed after the authorship
statement and before the place, date, and signature. When the option is left
empty, the regular declaration of authorship is rendered unchanged. The
combined title is localized through `lang` and can be overridden with the
`ai-declaration-title` label.

Keep the declaration concise. If detailed documentation of tools, prompts, or
affected passages is required, place it in an appendix and refer to it from the
declaration.

## Logo Usage

Please note the logo usage guidelines of University of Potsdam ([UP Logo Usage Guidelines](https://www.uni-potsdam.de/fileadmin/projects/zim/files/MMP/PDF_Dateien_MMP/250509-Leitfaden_DigitalPrint-web.pdf)) and Hasso Plattner Institute ([HPI Logo Usage Guidelines](https://hpi.de/en/imprint/)). The logos are subject to copyright of the respective institutions.
