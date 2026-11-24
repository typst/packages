# Non-boring notes

A modular, colorful, and highly customizable Typst template for academic
documentation, lecture notes, and assignments. Designed to be simple to use,
yet powerful.

## Quick Start

You can initialize a project directly from the CLI:

```bash
typst init @preview/non-boring-notes
```

Or copy this template into your existing document:

```typst
#import "@preview/non-boring-notes:0.3.0": *

#show: template.with(
  title: [Document Title],
  subtitle: [Optional Subtitle],
  short_title: "Notes",
  description: [Document description],
  abstract: [
    Your abstract or brief summary goes here.
  ],
  creation_date: datetime.today(),
  authors: (
    (
      name: "Your Name",
      link: "https://example.com",
    ),
  ),
  paper_size: "us-letter",
  cols: 1,
  h1_prefix: "lecture",
  text_lang: "en",
)

= Introduction

Start writing your notes here...
```

For a lighter setup for assignments and short documents, use
`minimal_template` instead. It styles fonts, enumerated lists, and theorem-like
boxes without adding a separate title page, page header, table of contents, or
bibliography:

```typst
#import "@preview/non-boring-notes:0.3.0": *

#show: minimal_template.with(
  title: [Document Title],
  subtitle: [Optional Subtitle],
)

= Exercise 1

Start writing here...
```

A longer example using most of the features is available in
[examples/showcase.typ](./examples/showcase.typ).

## Documentation

| Page | What it covers |
| :--- | :--- |
| [Template reference](./docs/template.md) | Every `template` parameter, defaults, recipes, and common pitfalls. |
| [Theorem-like environments](./docs/theorem-like-envs.md) | All 16 environments, numbering, labels, and references. |
| [Utilities](./docs/utilities.md) | `indent`, `quote-box`, `mathbox`, and the bundled fletcher, cetz, and unify packages. |

## Features

- 16 pre-styled theorem-like environments for theorems, definitions, proofs,
  exercises, notes, and more.
- Localized labels, dates, and headers in English, Spanish, German, and Italian.
- Configurable page size, orientation, columns, colors, and fonts.
- Automatic page headers, table of contents, and lists of figures and tables.
- Built-in bibliography support and syntax-highlighted code blocks.
- Re-exported drawing and unit typesetting packages: fletcher, cetz, and unify.

## License

Released under the [MIT License](./LICENSE).
