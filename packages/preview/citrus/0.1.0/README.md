# citrus 🍋

> _Fresh citations for Typst_

A CSL (Citation Style Language) processor implemented in pure Typst.

Use standard CSL style files — the same format used by Zotero, Mendeley, and thousands of citation managers — to format your citations and bibliographies. Squeeze the zest out of your references!

## Installation

```typst
#import "@preview/citrus:0.1.0": init-csl, csl-bibliography
```

## Quick Start

```typst
#import "@preview/citrus:0.1.0": init-csl, csl-bibliography

#show: init-csl.with(
  read("references.bib"),
  read("style.csl"),
)

As demonstrated by @smith2020, this approach works well.

#csl-bibliography()
```

## Features

- **Standard CSL support** — Parse and render using CSL 1.0.2 style files
- **CSL-M extensions** — Multilingual layouts, institutional authors, legal citations
- **BibTeX input** — Use your existing `.bib` files via [citegeist](https://typst.app/universe/package/citegeist/)
- **CSL-JSON input** — Native CSL-JSON format for lossless data transfer
- **Bilingual support** — Automatic language detection for mixed Chinese/English bibliographies
- **Citation styles** — Numeric, author-date, and note styles (footnotes auto-generated)
- **Year disambiguation** — Automatic a/b/c suffixes for same-author-same-year entries
- **Citation collapsing** — Numeric ranges `[1-4]`, year-suffix `(Smith, 2020a, b)`
- **Multiple citations** — Combine citations with `multicite()`
- **Full formatting** — Italics, bold, small-caps, text-case, and more
- **Bibliography linking** — Auto-link DOI, URL, PMID, PMCID in bibliography

## Documentation

- [English Documentation](examples/example-en.typ) — Chicago style example
- [中文文档](examples/example-zh.typ) — GB/T 7714-2025 style example

## API Reference

### `init-csl`

Initialize the CSL processor with BibTeX bibliography data and style.

```typst
#show: init-csl.with(
  bib-content,      // BibTeX file content (string)
  csl-content,      // CSL style file content (string)
  locales: (:),     // Optional: external locale files
  auto-links: true, // Optional: auto-link DOI/URL/PMID/PMCID
)
```

### `init-csl-json`

Initialize the CSL processor with CSL-JSON bibliography data. CSL-JSON is the native format for CSL processors — properties map directly to CSL variables, avoiding translation losses from BibTeX.

```typst
#import "@preview/citrus:0.1.0": init-csl-json, csl-bibliography

#show: init-csl-json.with(
  read("references.json"),   // CSL-JSON file content
  read("style.csl"),         // CSL style file content
  locales: (:),              // Optional: external locale files
  auto-links: true,          // Optional: auto-link DOI/URL/PMID/PMCID
)

As shown by @smith2023...

#csl-bibliography()
```

CSL-JSON format example:

```json
[
  {
    "id": "smith2023",
    "type": "article-journal",
    "title": "Example Article",
    "author": [{ "family": "Smith", "given": "John" }],
    "container-title": "Journal of Examples",
    "volume": "42",
    "page": "1-10",
    "issued": { "date-parts": [[2023, 5, 15]] },
    "DOI": "10.1234/example"
  }
]
```

**Advantages of CSL-JSON over BibTeX:**

- Properties map 1:1 to CSL variables (no translation needed)
- Names are pre-structured (`{"family": "...", "given": "..."}`)
- Dates use standard CSL format (`{"date-parts": [[2023, 5, 15]]}`)
- All CSL types supported directly
- Better for CSL-M extensions (`original-author`, `container-author`, etc.)

### `csl-bibliography`

Render the bibliography.

```typst
#csl-bibliography()

// Custom title:
#csl-bibliography(title: heading(level: 2)[References])

// Full custom rendering:
#csl-bibliography(full-control: entries => {
  for e in entries [
    [#e.order] #e.rendered-body #e.ref-label
    #parbreak()
  ]
})
```

### `get-cited-entries`

Low-level API for complete control over bibliography rendering.

```typst
context {
  let entries = get-cited-entries()
  for e in entries {
    // Each entry provides:
    // - key, order, year-suffix, lang, entry-type
    // - fields, parsed-names
    // - rendered (full), rendered-body (without number)
    // - ref-label, labeled-rendered
  }
}
```

### `multicite`

Combine multiple citations.

```typst
#multicite("smith2020", "jones2021", "wang2022")

// With page numbers:
#multicite(
  (key: "smith2020", supplement: [p. 42]),
  "jones2021",
)
```

## Supported CSL Elements

| Element    | Status | Element        | Status |
| ---------- | ------ | -------------- | ------ |
| `<text>`   | ✅     | `<group>`      | ✅     |
| `<choose>` | ✅     | `<names>`      | ✅     |
| `<name>`   | ✅     | `<date>`       | ✅     |
| `<number>` | ✅     | `<label>`      | ✅     |
| `<sort>`   | ✅     | `<substitute>` | ✅     |

## CSL-M Support

This library includes support for key CSL-M (CSL Multilingual) extensions:

| Feature               | Description                                                    |
| --------------------- | -------------------------------------------------------------- |
| **Multiple layouts**  | `<layout locale="en es de">` for language-specific formatting  |
| **cs:institution**    | Institutional author handling with subunit parsing             |
| **cs:conditions**     | Nested condition groups with `match="any/all/nand"`            |
| **Legal types**       | `legal_case`, `legislation`, `regulation`, `hearing`, `treaty` |
| **Legal variables**   | `authority`, `jurisdiction`, `country`, `hereinafter`          |
| **Date conditions**   | `has-day`, `has-year-only`, `has-to-month-or-season`           |
| **Context condition** | `context="citation"` or `context="bibliography"`               |
| **Locale matching**   | Prefix matching: `en` matches `en-US`, `en-GB`, etc.           |
| **suppress-min/max**  | Suppress names by count, or separate personal/institutional    |
| **require/reject**    | `require="comma-safe"` for locator punctuation safety          |

### Built-in Locales

10 languages with automatic fallback:
`en-US`, `zh-CN`, `zh-TW`, `de-DE`, `fr-FR`, `es-ES`, `ja-JP`, `ko-KR`, `pt-BR`, `ru-RU`

## Entry Type Handling

This library uses [citegeist](https://typst.app/universe/package/citegeist/) to parse BibTeX files. Most standard entry types are supported, but some extended types are not recognized by citegeist.

### Supported Types (auto-detected)

`article`, `book`, `booklet`, `inbook`, `incollection`, `inproceedings`, `conference`, `manual`, `mastersthesis`, `phdthesis`, `proceedings`, `techreport`, `unpublished`, `misc`, `online`, `patent`, `thesis`, `report`, `dataset`, `software`, `periodical`, `collection`

### Unsupported Types (require `mark` field)

For types not recognized by citegeist, use `@misc` with a `mark` field:

| Type        | Mark          | Notes                       |
| ----------- | ------------- | --------------------------- |
| Standard    | `S`           | `@standard` not recognized  |
| Newspaper   | `N`           | `@newspaper` not recognized |
| Legislation | `LEGISLATION` | CSL-M legal type            |
| Legal case  | `LEGAL_CASE`  | CSL-M legal type            |
| Regulation  | `REGULATION`  | CSL-M legal type            |

Note: Use `@online` instead of `@webpage` — citegeist supports `@online` but not `@webpage`.

Example:

```bib
@misc{gb7714,
  mark      = {S},
  title     = {Information and documentation — Rules for bibliographic references},
  number    = {GB/T 7714—2015},
  publisher = {Standards Press of China},
  year      = {2015},
}
```

The `mark` field follows GB/T 7714 document type codes:

- `M` — Book, `C` — Conference, `N` — Newspaper, `J` — Journal
- `D` — Thesis, `R` — Report, `S` — Standard, `P` — Patent
- `G` — Collection, `EB` — Electronic resource, `DB` — Database
- `A` — Analytic (chapter), `Z` — Other

## CSL 1.0.2 Specification Coverage

This library implements the full CSL 1.0.2 specification. Key features include:

### Rendering Elements

| Element         | Status | Notes                                       |
| --------------- | ------ | ------------------------------------------- |
| `cs:text`       | ✅     | Variables, macros, terms, values            |
| `cs:number`     | ✅     | Numeric, ordinal, long-ordinal, roman forms |
| `cs:date`       | ✅     | Localized and non-localized date formatting |
| `cs:names`      | ✅     | Full name formatting with et-al, delimiter  |
| `cs:name`       | ✅     | Name order, form, delimiter-precedes-\*     |
| `cs:name-part`  | ✅     | Per-part formatting (family/given)          |
| `cs:label`      | ✅     | Variable labels with plural detection       |
| `cs:group`      | ✅     | Conditional groups with delimiter           |
| `cs:choose`     | ✅     | if/else-if/else conditions                  |
| `cs:substitute` | ✅     | Fallback rendering for empty names          |

### Style Structure

| Element           | Status | Notes                                   |
| ----------------- | ------ | --------------------------------------- |
| `cs:style`        | ✅     | Style metadata, class, locale           |
| `cs:info`         | ✅     | Style information (parsed but not used) |
| `cs:locale`       | ✅     | Inline locale overrides                 |
| `cs:macro`        | ✅     | Reusable formatting macros              |
| `cs:citation`     | ✅     | Citation formatting with layout         |
| `cs:bibliography` | ✅     | Bibliography formatting with layout     |
| `cs:sort`         | ✅     | Sorting by variable or macro            |

### Disambiguation

| Feature                  | Status | Notes                             |
| ------------------------ | ------ | --------------------------------- |
| Year suffixes (a, b, c)  | ✅     | Automatic for same-author-year    |
| Add names                | ✅     | Expand truncated name lists       |
| Add givenname            | ✅     | Show initials or full given names |
| `disambiguate` condition | ✅     | CSL disambiguate="true" condition |

### Bibliography Features

| Feature                        | Status | Notes                          |
| ------------------------------ | ------ | ------------------------------ |
| `subsequent-author-substitute` | ✅     | Em-dash for repeated authors   |
| `complete-all` rule            | ✅     | Substitute entire name list    |
| `complete-each` rule           | ✅     | Per-name substitution          |
| `partial-each` rule            | ✅     | Partial name matching          |
| `partial-first` rule           | ✅     | First-name-only matching       |
| Bibliography linking           | ✅     | Auto-link DOI/URL/PMID/PMCID   |
| Hanging indent                 | ✅     | Via `hanging-indent` attribute |
| Second-field-align             | ✅     | Label alignment modes          |

### Formatting & Affixes

| Feature           | Status | Notes                                      |
| ----------------- | ------ | ------------------------------------------ |
| `font-style`      | ✅     | italic, oblique, normal                    |
| `font-weight`     | ✅     | bold, light, normal                        |
| `font-variant`    | ✅     | small-caps, normal                         |
| `text-decoration` | ✅     | underline, none                            |
| `text-case`       | ✅     | lowercase, uppercase, capitalize-\*, title |
| `vertical-align`  | ✅     | sup, sub, baseline                         |
| `prefix`/`suffix` | ✅     | Affixes on all elements                    |
| `delimiter`       | ✅     | Element and group delimiters               |
| `quotes`          | ✅     | Locale-aware quotation marks               |
| `strip-periods`   | ✅     | Remove periods from abbreviations          |

### Localization

| Feature              | Status | Notes                                 |
| -------------------- | ------ | ------------------------------------- |
| Built-in locales     | ✅     | 10 languages with automatic fallback  |
| External locales     | ✅     | Load via `locales` parameter          |
| Ordinal suffixes     | ✅     | Full ordinal-00 to ordinal-99 support |
| Long ordinals        | ✅     | "first" through "tenth" with fallback |
| Term forms           | ✅     | long, short, verb, verb-short, symbol |
| `limit-day-ordinals` | ✅     | Locale option for day ordinals        |

## Known Limitations

### Bilingual Styles (CSL-M `original-*` variables)

Some Chinese citation styles (e.g., "原子核物理评论") require bilingual output with both Chinese and English metadata. These styles use CSL-M extension variables like `original-author`, `original-title` which map to BibTeX fields with `-en` suffix (`author-en`, `title-en`, etc.).

**Current status:**

| Variable                                                                                       | CSL-JSON | BibTeX |
| ---------------------------------------------------------------------------------------------- | -------- | ------ |
| `original-title`, `original-container-title`, `original-publisher`, `original-publisher-place` | ✅       | ✅     |
| `original-author`, `original-editor`                                                           | ✅       | ❌     |
| `display="block"` attribute                                                                    | ✅       | ✅     |

**BibTeX limitation:** `original-author` and `original-editor` require citegeist to parse `author-en`/`editor-en` fields into `parsed_names`. Use CSL-JSON input for full bilingual name support.

### CSL-M Extensions Not Implemented

The following CSL-M (Juris-M/Multilingual Zotero) extensions are **not supported**:

| Feature                                       | Description                                       |
| --------------------------------------------- | ------------------------------------------------- |
| `parallel-first` / `parallel-last`            | Parallel citation suppression for legal documents |
| `form="imperial"`                             | Japanese Imperial calendar date format            |
| `commenter` / `contributor`                   | Additional name variables                         |
| `cs:court-class`                              | Court classification element                      |
| `track-containers` / `consolidate-containers` | Container tracking for legal citations            |
| `subgroup-delimiter`                          | Publisher/publisher-place grouping                |
| `year-range-format`                           | Separate year range collapsing format             |

These features are primarily used for legal citation styles (Jurism). Standard academic CSL styles work correctly.

## Related Projects

- [citegeist](https://typst.app/universe/package/citegeist/) — BibTeX parser for Typst
- [CSL Styles Repository](https://github.com/citation-style-language/styles) — Thousands of CSL styles
- [Zotero Chinese Styles](https://github.com/zotero-chinese/styles) — Chinese CSL styles

## License

MIT
