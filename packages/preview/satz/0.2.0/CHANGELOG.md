# Changelog

## Unreleased — work toward 0.2.0

The manifest identifies this tree as 0.2.0, but the package has not been
published. This is a release candidate, not a claim of complete
LaTeX/KOMA-Script parity.

### Report typography and reusable components

- Style native headings without nested layout wrappers. Preserve native
  page-start trimming and attachment to following content.
- Expose `h1-above` through `h4-above`; `auto` preserves native spacing by
  omitting the override. Below-spacing and paragraph indentation remain
  configurable. See [the typography guide](docs/typography.md).
- Route book subsection headings through the shared measured spacing policy;
  retain the distinct chapter opener and check visible gaps in the book fixture.
- Honor `tables.font-size` and `tables.inset`, which previously existed in
  configuration but were ignored.
- Add `scientific-table`: explicit header cells, stronger top/bottom rules,
  a thinner header separator, repeated headings/rules across pages, native
  table cells and optional group separators.
- Add the opt-in `scientific-tables` show rule for table figures,
  top captions, ragged-right caption text and deliberate breakability. Related
  native tables can share one figure, caption and reference.
- Add `callout`: breakable explanatory boxes, consistent paragraph/list gaps,
  inherited body type and leading, and body-height preservation for smaller
  code-only lines. The research report now consumes this shared helper.
- Keep headings ragged-right and unhyphenated by default, even in justified
  prose. Add optional attached, palette-colored callout titles with a deliberate
  title/body gap; see `examples/callout.typ`.
- Preserve left-aligned reading text in callouts nested inside centered figures.
- Use hanging figure and table captions with regular label weight by default;
  `captions.hanging` and `captions.label-weight` customize the layout and label.
  Reports default to floating figures (`figures.placement: auto`); set it to
  `none` to keep figures in source order. Native labels and references and the
  long-caption/short-list workflow remain available.
- Default table text to left alignment without justification; individual table
  alignment settings can override the default.
- Add `chapter-numbering` scopes: figure/table/equation prefixes remain correct
  in forward, backward and cross-appendix references. Add opt-in
  `headings.h1-pagebreak` for report chapters that start on a new page.
- Fix internal reference colors: resolved references also carry a fallback
  citation field, so testing for that field incorrectly skipped their styling.
- Expose `typography.math-font`; `auto` retains Typst's native math typeface.
  The research report explicitly selects STIX Two Math to match its LaTeX source.
- Expose `typography.mono-font` independently; `auto` retains native raw-text
  styling, while the research report selects Fira Code.
- Refine contents, figure-list, and table-list typography with configurable
  entry size, leading, row gaps, title gaps, and section gaps. Preserve Typst's
  native numbering, links, page-number formatting, and wrapped-entry indents.
- Keep report contents, figure lists, and table lists disabled by default; enable
  each with its `depth: none` setting. The lists are independent; omit empty lists
  and figures marked `outlined: false`. Compact lists keep custom numbering and
  page formats while omitting captions.
- Make the six named palettes available as report themes and custom document
  palettes. Reports now default to neutral black-on-white colors; opt into a
  colored palette with `theme:`. Explicit nested color settings take precedence.
- Control list spacing with `typography.list-spacing`, a fraction of the body
  baseline distance (default `0.5`). This replaces the earlier decorative list
  spacing controls and can reflow existing reports.

- Remove the fixed neuroscience illustration from research covers; the drawing
  is archived for possible future use. Covers remain optional and customizable.

### Other development work already committed

- Expose `custom()` for author-defined document structures. Named templates
  share the internal `document-class()` integration layer; `personal()` is not
  part of the 0.2.0 API.
- Hydra running headers and an optional Glossarium namespace.
- Native placeholder figures and composable cover presets.
- An article entry point with native columns, author affiliations and abstract.
- Grouped chapter entries in the report contents.
- An experimental book entry point and educational components. This remains
  under review and is not the same specimen as the research report.
- A one-file letter quick start and named enclosures without embedded files.

### Letter and invoice inputs

- Letters place the date in the standalone right-aligned block by default when
  no reference fields are supplied. `show-date-label: false` hides its label.

- Breaking change: the letter template is exported as `letter` with English
  argument and address-field names. Replace `brief` and German letter options
  when migrating from 0.1.1; German output remains available with `language: "de"`.

- Accept English top-level names and English sender/recipient fields for postal
  templates; invoice retains its existing German input aliases.
- Accept invoice items as `(description, quantity, unit-price)` records or keep
  the original tuple form. Invoice output remains German; English input does not
  imply localization.
- Report a field-specific conflict when callers provide both spellings, and
  identify missing fields in English invoice item records.

### Shared appearance precedence

- Resolve letter and invoice themes, direct appearance arguments, and nested
  config overrides through one adapter while preserving DIN-specific geometry.
- Apply the shared theme palette to article and book entry points. Book
  `accent`, `math-font`, and other direct appearance arguments now participate
  in the documented precedence order instead of bypassing nested config.
- Reject unsupported letter/invoice appearance groups and keys with a
  field-specific error. `examples/latex-parity/check_appearance_precedence.py`
  checks palette application, nested overrides, and rejection behavior.
- Validate journal dates as real calendar dates and support ISO `YYYY-MM-DD`,
  `DD/MM/YY`, and `DD/MM/YYYY` for month grouping. Optional weekday prefixes
  are accepted; blank dates remain valid for drafts and group under “Undated”.
  See `examples/latex-parity/check_journal_dates.py`.
- Validate article author/affiliation record shapes, required author names,
  one-based indices, and affiliation content types with field-specific errors.
  Unknown author keys remain available for caller metadata.
- Validate letter/invoice address record shapes and text fields, plus invoice
  item tuples/records and numeric ranges, without rejecting extension keys.
- Validate letter language values, DFG form-date/page-check types, and require
  an integer source-checked NWO year.
- Validate known shared config groups at the class boundary so common typos
  such as `typography.leadng` fail clearly. Caller extension groups and the
  documented DFG/book-specific keys remain accepted.
- Validate proposal budget records and Gantt row/span shapes, NWO key-output
  fields and page-budget limits, Klageschrift attachments/page limits, guest
  contract enums/types/ranges, direct letter/invoice options, cover layout/theme
  types, and book contents depth.
- Add regressions for `headings.spacing`, shared-config typo detection,
  preserved extension groups and the audited public records/options.
- Complete the candidate configuration reference with shared and
  template-specific defaults, exported argument signatures, record/array
  shapes, enum contracts, extension policy and version availability. Compile
  its starter against the isolated 0.2.0 tree.

### Verification and remaining release work

- Exclude `tools/**` and local workbook conversions from the Typst package.
  A staged-package check now compiles report, article, journal, letter, invoice,
  cover, proposal, and configuration starters from the manifest-filtered tree. The isolated
  0.2.0 candidate check passes against the current source tree.
- GitHub Actions runs the staged-package check and focused public API/PDF
  regressions on pushes and pull requests, including tables, callouts,
  placeholders, paragraph rhythm, proposal forms, and the input-validation
  audit. Python PDF inspection dependencies are pinned.
- Compile stable letter, invoice, report, journal, and cover starters against
  an isolated download of the published 0.1.1 package; this avoids a local
  package alias masking the actual published source. This compatibility check
  passes locally.
- Install the staged source tree in isolation as `@local/satz:0.2.0` and
  compile its representative starters without changing the repository version.
- Declare Typst 0.15.0 as the candidate minimum compiler version; all release
  checks currently run with that version.
- Replace the email-like contact in the letter example with an `example.com`
  placeholder; the tracked-example privacy scan is clean.

The [research report audit](docs/report-parity-audit.md) distinguishes shared
package fixes from document settings and records remaining conversion/layout
gaps. Focused PDF checks cover heading flow, callout fragmentation, scientific
rules, table configuration and repeated table headings. A successful compile
does not establish visual or content parity.

The configuration-reference and input-validation gates are complete and
committed. The research report's missing verdict macros, grouped table captions,
chapter references and math/code typefaces are now corrected. All pages were
rendered and visually reviewed against LaTeX. The remaining float-placement
differences are documented and accepted when content stays readable and
correctly captioned; sparse chapter endings are handled in the workbook with a
document-level heading option. Article geometry and journal date, header, and
theme behavior have focused PDF checks, without a claim of broad visual parity.
The final integrated package review remains in progress. The outline example
compiles and its extracted text contains the expected contents and lists; the
PyMuPDF geometry assertions are in `examples/latex-parity/check_outlines.py`.
