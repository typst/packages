# Keisen

Create elegant **display tables** from tabular data.

_Keisen_ (罫線) is Japanese for the ruled lines of a table.
The library implements the **display-table grammar** in a declarative API for Typst documents, inspired by [`gt`](https://gt.rstudio.com) (R) and [`great_tables`](https://posit-dev.github.io/great-tables/) (Python).

Documentation: <https://m.canouil.dev/keisen>.

## Quick look

```typst
#import "@preview/keisen:0.1.0": *

#display-table(
  sales,
  table-header(
    title: [Regional sales],
    subtitle: [Financial year 2025 to 2026],
  ),
  table-stub(rowname: "product", group: "region", label: [Product]),
  columns-label(
    units: [Units],
    revenue: [Revenue],
    margin: [Margin],
  ),
  table-spanner([Performance], ("revenue", "margin")),
  format-integer("units"),
  format-currency("revenue", currency: "EUR", decimals: 0),
  format-percent("margin", decimals: 1),
  substitute-missing(auto, replacement: [--]),
  summary-rows(
    functions: (Subtotal: aggregate-sum),
    columns: ("units", "revenue"),
  ),
  grand-summary-rows(
    functions: (Total: aggregate-sum),
    columns: ("units", "revenue"),
  ),
  table-style(
    style(text: (fill: rgb("#c8442f"), weight: "bold")),
    locations: cells-body(columns: "margin", rows: row => row.margin < 0.05),
  ),
  data-colour(
    ("#fbfbf8", "#2c5f82"),
    columns: "revenue",
  ),
  table-footnote(
    [Excludes intra-group sales.],
    locations: cells-column-labels("revenue"),
  ),
  table-source-note([Source: internal ledger, extracted 2026-04-01.]),
  theme: theme-booktabs(),
)
```

Every part of a display table is addressed by name: the header, the stub with its row groups, the column labels and their spanners, the body, the summary rows, the source notes, and the footnotes whose marks are numbered in reading order.
Cells are styled by what the data says, not by where they sit, and numbers are formatted in Typst's `decimal` type rather than in floats.
A row group spanning a page break reprints its label, because groups are rendered as native repeating subheaders.

## AI assistants

The documentation ships a machine-readable copy for large language models at <https://m.canouil.dev/keisen/llms.txt>.
Every page also has a `.llms.md` companion.

An installable skill will follow once the API settles.
A skill that documents a moving surface is worse than none.

