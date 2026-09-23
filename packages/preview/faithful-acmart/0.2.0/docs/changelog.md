# Changelog

## 0.2.0 (2026-09-17)

This release follows LaTeX `acmart` 2.21 and includes changes to defaults, citation handling, and page layout.

### Upgrading from 0.1.0

Check these settings before recompiling an existing paper:

| Change | Action |
|---|---|
| The minimum Typst version is now 0.14.0, up from 0.12.0. | Upgrade your compiler if needed. |
| The default format is now `"manuscript"`, previously `"acmsmall"`. | Set `format: "acmsmall"` explicitly to keep the previous layout choice. |
| `doi` now defaults to a placeholder, and proceedings formats supply placeholder conference metadata. | Supply your publication details, or use `doi: none` and `conference: none` to omit them. |
| Every supplied affiliation requires a nonempty `country`. | Add a country to incomplete affiliation dictionaries. |
| At most one author may set `corresponding: true`. | Mark only the corresponding author. |
| The custom bibliography backends reject unsupported arguments instead of ignoring them. | Follow the [bibliography argument contract](reference.md#bibliography-input-and-arguments); use `cite(..., form: none)` to include an uncited entry. |

Recheck line and page breaks after upgrading: title spacing, headings, lists, captions, footnotes, and bibliography formatting have changed.
The new `fix-quirks` option is off by default, so its corrections require an explicit opt-in.

### New features

The release adds the following document and bibliography features:

- `fix-quirks: true` corrects selected inherited LaTeX behavior, including DOI prefixes and punctuation; see the [correction list](reference.md#corrections).
- Theorem environments support Typst labels and references.
- Citations support page locators through `@key[note]`, additional citation forms, full references in the body, and entries included without a printed citation.
- `tabular` and the booktabs rule helpers provide rule spacing and table-header tagging.
- `ccs` accepts output pasted from the ACM CCS tool, including CCSXML.
- `sigchi-a` supports margin notes, margin figures and tables, and content spanning the body and margin column.
- Document helpers support anonymized passages, grant information, author contact overrides, and additional headings.

### Fixes

These changes improve agreement with the bundled LaTeX class and bibliography styles:

- Correct title and heading spacing, nested-list geometry, caption styling, front-matter marks, and page headers and footers across formats and font sizes.
- Apply review and author-draft page-number and list-spacing behavior separately, as acmart does.
- Preserve theorem numbering across unnumbered headings and localize abstract and bibliography headings.
- Improve BibTeX sorting, cross-references, field formatting, and string-macro handling, including macros shared across bibliography files.
- Improve BibLaTeX date parsing, sorting, name disambiguation, inheritance, and formatting of editor, translator, patent, and software fields.

## 0.1.0

Initial release with ACM journal and conference formats, author and publication metadata, three bibliography backends, and theorem environments.
