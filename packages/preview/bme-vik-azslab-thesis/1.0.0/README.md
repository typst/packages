# BME VIK Thesis Template

A Typst template for BSc and MSc theses at the Faculty of Electrical Engineering and Informatics (VIK), Budapest University of Technology and Economics (BME).

The template aims to provide a convenient starting point that follows the faculty's formatting requirements while taking advantage of Typst's modern typesetting features. The skeleton of this work is based on the original LaTeX template.

## Features

- BSc and MSc thesis support
- Hungarian and English documents
- Automatic chapter, figure, table, equation, and appendix numbering
- Bibliography and citations
- Theorem-like environments
- List of figures and tables
- Hungarian-aware references
- Generative AI usage declaration
- Support for single- and double-sided layouts

## Usage

Create a new project from the template:

```bash
typst init @preview/bme-vik-thesis-template:1.0.0
```

Compile the document with:

```bash
typst compile thesis.typ
```

or automatically recompile it when the source changes:

```bash
typst watch thesis.typ
```

The included example document demonstrates the available features and serves as a more detailed guide to using the template.

### Example

Here's how to use the template:

```typst
#import "@preview/bme-vik-azslab-thesis:1.0.0": *

#let lang = "hu"  // LANGUAGE OF THE DOCUMENT

#show: thesis.with(
  authors: ("Gipsz Jakab"),
  lang: lang,
  supervisors: ("Dr. Első konzulens", "Második konzulens"),
  title: "Elektronikus Terelők"
)

#show: front-matter
#include "content/abstract.typ"

#show: main-matter

#include "content/<your-content>.typ"

#show: back-matter

#include "content/acknowledgement.typ"

#bibliography("bibliography/bib.bib")

#show: appendix
#include "content/appendices.typ"

#show: genai-declaration.with(true)
#let gen-ai-names = gen-ai-names-all.at(lang) // To be adjusted to the language

#{
    show table.cell: set text(size: 10pt)

    table(
    columns: (1.3fr, 1fr, 1fr, 1fr),
    stroke: 0.5pt,
    align: horizon,
    table.header(
      gen-ai-names.titles.types, gen-ai-names.titles.names, gen-ai-names.titles.sections, gen-ai-names.titles.usage
    ),
    gen-ai-names.literature, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.codegen, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.ideas, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.outline, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.textblocks, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.figures, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.plots, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.presentation, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.others, [], [], [],
    ..gen-ai-prompt(),

    ..gen-ai-all-percentage(),
    gen-ai-all-text()
  )
}
```

## Requirements

A recent version of Typst is required. The template can be used either with the Typst web application or with a local Typst installation.

## Disclaimer

This is an unofficial template. Always check the current requirements of BME VIK and your department before submitting your thesis.

## License

The template source code is licensed under the MIT License. University names, logos, and official texts included or referenced by the template may be subject to their respective owners' terms and are not necessarily covered by this license.
