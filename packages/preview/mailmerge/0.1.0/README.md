# Typst Mail Merge (`mailmerge`)

A powerful, flexible, and production-ready **Mail Merge** package for Typst. Easily generate personalized letters, certificates, invoices, address labels, conference badges, envelopes, and reports directly from CSV files or inline data structures.

---

## 📚 Documentation & Wiki

Explore our complete **[GitHub Wiki](https://github.com/aurghya-0/typst-mailmerge/wiki)** for detailed guides, API reference, preset specs, and examples:

- 🚀 **[Getting Started](https://github.com/aurghya-0/typst-mailmerge/wiki/Getting-Started)** — Installation, CSV data loading, and first merge letter setup.
- 📄 **[Document Mail Merge](https://github.com/aurghya-0/typst-mailmerge/wiki/Document-Mail-Merge)** — Multi-page documents & page counter resets.
- 🏷️ **[Label & Badge Sheets](https://github.com/aurghya-0/typst-mailmerge/wiki/Label-&-Badge-Sheets)** — Avery sticker presets, grid layout engine, cut lines & cell fills.
- 🔧 **[Fields & Formatters](https://github.com/aurghya-0/typst-mailmerge/wiki/Fields-&-Formatters)** — Smart key normalization, currency formatters, and address cleaner.
- 🔀 **[Filtering, Sorting & Pagination](https://github.com/aurghya-0/typst-mailmerge/wiki/Filtering,-Sorting-&-Pagination)** — Filtering conditions, custom sorting, reversing, and batch pagination.
- 📊 **[API Reference](https://github.com/aurghya-0/typst-mailmerge/wiki/API-Reference)** — Full signature and parameter documentation.
- 💡 **[Examples & Templates](https://github.com/aurghya-0/typst-mailmerge/wiki/Examples-&-Templates)** — Ready-to-use Typst code templates.

---

## ✨ Features

- 📑 **Document Mail Merge (`mail-merge`)**: Seamless single or multi-page personalized document generation.
- 🏷️ **Label & Badge Sheet Layouts (`mail-merge-labels`)**: Grid layout engine with built-in presets for Avery address/shipping labels, name badges, and card sheets.
- 🎯 **Smart Field Access & Normalization (`field`)**: Normalizes field names (e.g. matching `"First Name"`, `"first_name"`, `"First-Name"`, or fallback candidate arrays).
- 🧹 **Address Joining (`join-fields`)**: Cleanly joins address lines, automatically omitting blank optional fields (e.g., `Address 2`).
- 🎨 **Field Formatters (`fmt-field`)**: Quick presets for `"upper"`, `"lower"`, `"title"`, `"currency"`, or custom transform closures.
- 🔀 **Filtering & Sorting**: Filter records with functions or dictionary conditions, sort by string fields or custom functions, reverse order, and paginate (`start`, `limit`).
- 🔢 **Page Counter Management**: Resets page numbers per recipient document with `reset-page-counter: true`.
- 📊 **Dataset Statistics & Fast Preview**: Inspect fields and record counts with `mail-merge-stats` and preview drafts with `mail-merge-preview`.

---

## 🚀 Quick Start

### 1. Simple Letter Merge

```typst
#import "@preview/mailmerge:0.1.0": mail-merge, field, fmt-field, join-fields, if-field

#mail-merge(
  csv("data/clients.csv", row-type: dictionary),
  filter: record => field(record, "Status") == "Active",
  sort-by: "Last Name",
  reset-page-counter: true,
  record => [
    #align(right)[#datetime.today().display("[Month repr:long] [Day], [Year]")]

    *Dear #field(record, "First Name"),*

    Thank you for being a valued customer since #field(record, "Join Date").

    #block(
      fill: rgb("#f7fafc"),
      inset: 10pt,
      radius: 4pt,
      [
        *Recipient Address:* \
        #fmt-field(record, "First Name") #fmt-field(record, "Last Name") \
        #if-field(record, "Company", c => [#c \ ])
        #field(record, "Address 1") \
        #join-fields(record, ("City", "State"), separator: ", ") #field(record, "Zip")
      ]
    )

    Your outstanding balance is *#fmt-field(record, "Balance", fmt: "currency")*.

    Best regards, \
    The Acme Team
  ]
)
```

---

### 2. Address Labels & Badge Sheet

```typst
#import "@preview/mailmerge:0.1.0": mail-merge-labels, presets, field, fmt-field, join-fields

// Render 3x10 Avery 5160 Address Sticker Sheet with cut guidelines
#mail-merge-labels(
  csv("data/clients.csv", row-type: dictionary),
  preset: presets.avery-5160,
  show-cut-lines: true,
  record => [
    #text(size: 9pt, weight: "bold")[#fmt-field(record, "First Name") #fmt-field(record, "Last Name")] \
    #text(size: 8pt)[
      #field(record, "Address 1") \
      #join-fields(record, ("City", "State"), separator: ", ") #field(record, "Zip")
    ]
  ]
)
```

---

## 📖 API Reference

### `mail-merge`

Main function for generating one document per record.

```typst
#mail-merge(
  data,
  template,
  filter: none,
  sort-by: none,
  reverse: false,
  start: 1,
  limit: none,
  pagebreak: true,
  reset-page-counter: false,
  trim: true,
  default-value: "",
  on-empty: [No matching records found.]
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `data` | `str \| array` | *Required* | Path to CSV, pre-loaded `csv(...)`, array of dicts, or array of row arrays. |
| `template` | `function` | *Required* | Content closure `record => content`. |
| `filter` | `none \| function \| dict` | `none` | Filter closure `r => bool` or dict `(Status: "Active")`. |
| `sort-by` | `none \| str \| function` | `none` | Key name or closure `r => key` to sort records. |
| `reverse` | `bool` | `false` | Reverse sort order. |
| `start` | `int` | `1` | 1-based start record index for pagination. |
| `limit` | `none \| int` | `none` | Maximum number of records to process. |
| `pagebreak` | `bool` | `true` | Inserts `#pagebreak()` between rendered records. |
| `reset-page-counter` | `bool` | `false` | Resets `#counter(page)` to 1 for each record. |
| `trim` | `bool` | `true` | Trims whitespace from CSV string fields. |
| `default-value` | `str` | `""` | Fallback string for empty or missing CSV fields. |
| `on-empty` | `content` | `[...]` | Content displayed if zero records match. |

---

### `mail-merge-labels`

Engine for multi-column label grids, sticker sheets, and badges.

```typst
#mail-merge-labels(
  data,
  template,
  preset: none,
  columns: none,
  rows: none,
  width: none,
  height: none,
  column-gutter: none,
  row-gutter: none,
  page-margin: none,
  paper: none,
  cell-padding: none,
  show-cut-lines: false,
  fill: none,
  ..options
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `preset` | `dictionary` | `none` | Preset layout from `presets.*` (e.g. `presets.avery-5160`). |
| `columns` | `int` | `3` | Number of grid columns per sheet. |
| `rows` | `int` | `8` | Number of grid rows per sheet. |
| `width` | `length \| 1fr` | `1fr` | Width of each label cell. |
| `height` | `length \| 1fr` | `1fr` | Height of each label cell. |
| `column-gutter` | `length` | `0pt` | Space between columns. |
| `row-gutter` | `length` | `0pt` | Space between rows. |
| `show-cut-lines` | `bool \| stroke` | `false` | Visual guidelines around labels. |
| `fill` | `none \| color \| function` | `none` | Background fill or closure `record => color`. |

---

### 🏷️ Label Presets (`presets`)

Pre-configured grid dimensions for standard label sheets:

- `presets.avery-5160`: 3x10 Address Labels (2.625" x 1.0", Letter)
- `presets.avery-5161`: 2x10 Address Labels (4.0" x 1.0", Letter)
- `presets.avery-5162`: 2x7 Folder Labels (4.0" x 1.33", Letter)
- `presets.avery-5163`: 2x5 Shipping Labels (4.0" x 2.0", Letter)
- `presets.avery-5164`: 2x3 Large Shipping Labels (4.0" x 3.33", Letter)
- `presets.avery-l7160`: 3x7 Metric Address Labels (63.5mm x 38.1mm, A4)
- `presets.avery-l7163`: 2x7 Metric Address Labels (99.1mm x 38.1mm, A4)
- `presets.a4-3x8`: 3x8 Standard A4 Labels (70mm x 36mm, A4)
- `presets.a4-2x7`: 2x7 Standard A4 Labels (105mm x 42.3mm, A4)
- `presets.badge-2x4`: 2x4 Name Badges (3.5" x 2.25", Letter)
- `presets.card-2x2`: 2x2 Place Cards / Large Badges (3.75" x 4.5", Letter)

---

### 🔧 Utility Functions

- **`field(record, key, fmt: none, default: "")`**: Retrieves and optionally formats a field value with smart key normalization (matches `"First Name"`, `"first_name"`, `"First-Name"` or candidate array `("FirstName", "Name")`). Supports `fmt: "upper"`, `"lower"`, `"title"`, `"currency"`, or custom function.
- **`bind-field(record)`**: Binds a record to `field` for ultra-concise `#f("Field Name")` template syntax (`let f = bind-field(record)` or `let f = field.with(record)`).
- **`fmt-field(record, key, fmt: none, default: "")`**: Alias for `field(record, key, fmt: fmt, default: default)`.
- **`join-fields(record, keys, separator: ", ", default: "")`**: Joins multiple non-empty fields, automatically omitting blank optional lines.
- **`if-field(record, key, then-content, else-content: [])`**: Conditionally renders `then-content` when field is present and non-empty.
- **`is-empty(record, key)`** / **`is-non-empty(record, key)`**: Helper predicates for conditional checks.
- **`record-index(record)`** / **`record-total(record)`**: Returns 1-based current record index and total records count.
- **`is-first-record(record)`** / **`is-last-record(record)`**: Boolean flags for first/last record in merged set.
- **`mail-merge-stats(data)`**: Returns `(total-records: int, fields: array, sample-record: dict)`.
- **`mail-merge-preview(data, template, limit: 3)`**: Convenience wrapper for rapid draft rendering.

---

## 📁 Repository Examples

Check out the `examples/` directory for full working `.typ` templates:

1. [`examples/letter_merge.typ`](examples/letter_merge.typ) — Personalized letters and invoices.
2. [`examples/certificate_merge.typ`](examples/certificate_merge.typ) — Landscape certificate of completion templates.
3. [`examples/label_merge.typ`](examples/label_merge.typ) — Address sticker sheets and conference name badges.
4. [`examples/envelope_merge.typ`](examples/envelope_merge.typ) — DL envelope printing.
5. [`examples/advanced_features.typ`](examples/advanced_features.typ) — Advanced sorting, filtering, statistics, and inline array data.

---

## 📄 License

Distributed under the [MIT License](LICENSE).
