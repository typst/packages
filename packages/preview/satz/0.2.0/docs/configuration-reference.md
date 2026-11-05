# Satz configuration reference — 0.2.0 candidate

This is the 0.2.0 reference for the shared styling interface, exposed for custom documents as `custom(theme:, config:)`.
It documents the executable baseline in `defaults.typ`; it does not claim that
every template consumes every key. `report`, `article`, `book`, `journal`,
`cover-page`, `letter`, `invoice`, and proposal templates add or override
settings in their own APIs. Their documented differences take precedence over
the shared baseline. The declared minimum compiler version is Typst 0.15.0.

Pass only values to change. Satz deep-merges dictionaries: an override such as
`(colors: (brand-primary: blue))` preserves the other color defaults. Arrays,
scalars, and non-dictionary values replace the old value. The generic `merge`
helper does not validate unknown keys. Validation is performed by individual
public APIs where supported; in particular, letters, invoices, and covers reject
unsupported keys in their documented appearance groups.

## Shared defaults

Values below come from `defaults.typ`. Lengths use Typst units. Colors are
Typst color values. `auto` delegates a choice or policy to the template;
`none` disables a feature or selects the template's fallback where stated.

| Key | Type and accepted values | Shared default | Meaning and scope |
| --- | --- | --- | --- |
| `page.paper` | Typst paper name or custom page size | `"a4"` | Paper size. See [Typst page](https://typst.app/docs/reference/layout/page/). |
| `page.margin` | dictionary of edge names to lengths | `(top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm)` | Page margins. Two-sided templates may derive inside/outside margins. |
| `page.binding` | `none` or a horizontal alignment (`left` / `right`) | `none` | Enables two-sided inside/outside layout where supported. |
| `page.binding-correction` | length | `0pt` | Extra binding-side space when two-sided layout is enabled. |
| `page.headers` | boolean | `false` | Enables a running header in templates that implement it. |
| `page.columns` | positive integer | `1` | Number of page columns where the template supports columns. |
| `page.column-gutter` | length | `5mm` | Gap between columns. |
| `typography.font` | font family name | `"Libertinus Serif"` | Main text family. Font must be installed or embedded by the runtime. |
| `typography.math-font` | font family name or `auto` | `auto` | Math typeface; `auto` retains Typst's native selection. |
| `typography.mono-font` | font family name or `auto` | `auto` | Monospaced typeface; `auto` retains Typst's native raw-text style. |
| `typography.size` | length | `11pt` | Main text size. |
| `typography.line-spacing` | positive number or `none` | `none` | Optional baseline-to-baseline distance as a multiple of the body font size (for example `1.5`). Uses the selected font metrics and overrides `typography.leading`. |
| `typography.leading` | length | `0.65em` | Distance between line bounds, not a multiplier. |
| `typography.list-spacing` | non-negative number | `0.5` | Additional list-item gap as a fraction of the calculated body baseline distance. Follows `typography.line-spacing`, or font metrics and `typography.leading`; `0` adds no extra gap. |
| `typography.paragraph-spacing` | length | `1.2em` | Vertical gap between paragraphs. It is independent of line spacing. If paragraphs are identified by indentation, reduce this gap separately; Satz does not change it when indentation is enabled. |
| `typography.first-line-indent` | boolean | `false` | `true` indents the first line of every paragraph by one em (the current body font size, e.g. 11pt at 11pt text size), including the first paragraph in a document/container and paragraphs after headings; `false` uses no indent. The horizontal indent is independent of vertical line and paragraph spacing. |
| `typography.hyphenate` | boolean | `false` | Enables automatic word hyphenation. |
| `typography.justify` | boolean | `true` | Justifies body paragraphs when supported. |
| `headings.numbering` | Typst numbering pattern/function or `none` | `"1.1"` | Heading numbering passed to the native heading system. |
| `headings.hyphenate` | boolean | `false` | Hyphenation within headings. |
| `headings.h1-pagebreak` | boolean | `false` | Starts level-one headings on a new page where supported. |
| `headings.spacing` | `"koma"` or `"native"` | `"koma"` | Uses translated KOMA baseline skips or leaves native Typst spacing. |
| `headings.h1-size` … `headings.h4-size` | length | `14pt`, `12pt`, `11pt`, `11pt` | Size for heading levels one through four. Templates may override these. |
| `headings.h1-above` … `headings.h4-above` | `auto` or length | `auto` | Space before each level. `auto` follows `headings.spacing`; an explicit length overrides the policy. |
| `headings.h1-below` … `headings.h4-below` | `auto` or length | `auto` | Space after each level. `auto` follows native/template policy. |
| `journal.header-below` | length | `1.5em` | Gap between the complete entry header/date and notes. Journal only. |
| `journal.running-gutter` | length | `1em` | Gap between running-header columns. Journal only. |
| `journal.running-leading` | length | `0.35em` | Line gap in a multi-line running header. Journal only. |
| `journal.running-header-size` | length | `9pt` | Running-header text size. Journal only. |
| `journal.date-size` | length | `10pt` | Journal date text size. Journal only. |
| `journal.keywords-size` | length | `9pt` | Journal keyword text size. Journal only. |
| `decorative.header-size` | length | `9pt` | Running-header text size. |
| `decorative.footer-size` | length | `10pt` | Footer text size where implemented. |
| `decorative.date-size` | length | `10pt` | Date text size where implemented. |
| `decorative.keywords-size` | length | `9pt` | Keyword text size where implemented. |
| `page-footer.format` | Typst numbering pattern/function | `"1"` | Page-number format where the template uses the shared footer. |
| `page-footer.size` | length | `10pt` | Page-number size. |
| `page-footer.weight` | Typst font-weight value | `"regular"` | Page-number weight. |
| `line-numbers.enabled` | boolean | `false` | Shows line numbers for document lines when enabled; uses Typst's native paragraph line numbering. |
| `line-numbers.format` | Typst numbering pattern | `"1"` | Format for line numbers. |
| `line-numbers.scope` | `"document"` or `"page"` | `"document"` | Keep numbering continuous or reset at each page. |
| `line-numbers.size` | length | `8pt` | Text size of line numbers. |
| `line-numbers.color` | Typst color | `#64748B` | Line-number color. |
| `line-numbers.clearance` | `auto` or length | `auto` | Gap between line numbers and text. |
| `links.color`, `links.url-color` | color | `#0563C1`, `#0563C1` | Internal-reference and external-URL colors in the default neutral palette. |
| `tables.stroke` | length | `0.5pt` | Default table rule thickness for shared table helpers. |
| `tables.inset` | length or dictionary such as `(x: 8pt, y: 4pt)` | `(x: 8pt, y: 4pt)` | Cell padding for shared table helpers. |
| `tables.font-size` | length | `10pt` | Text size in shared styled tables. |
| `tables.caption-position` | `top` or `bottom` | `top` | Caption position for the scientific-table show rule. |
| `tables.caption-gap` | length | `6pt` | Space between a table caption and its table. |
| `figures.placement` | `auto`, `none`, or a vertical alignment | `none` | Native placement policy for figures, including tables represented as figures. `none` keeps them in source order; `auto` lets Typst place them at a suitable page edge. Report defaults to `auto`; other templates use `none` unless noted. |
| `callouts.inset` | length | `9pt` | Inner padding for `callout`. |
| `callouts.radius` | length | `3pt` | Corner radius for `callout`. |
| `callouts.stroke` | length | `0.8pt` | Border thickness for `callout`. |
| `callouts.title-below` | length | `1em` | Gap between callout title and body. |
| `callouts.paragraph-spacing` | length | `1em` | Paragraph gap inside a callout. |
| `callouts.list-spacing` | length | `1.2em` | List-item gap inside a callout. |
| `captions.size` | length | `10pt` | Caption text size. |
| `captions.weight` | Typst font-weight value | `"regular"` | Caption text weight. |
| `captions.alignment` | Typst alignment | `left` | Caption alignment when `hanging` is false. |
| `captions.label-weight` | Typst font-weight value | `"regular"` | Weight of the caption label, independently of caption text. |
| `captions.hanging` | boolean | `true` | Put the label in its own column so wrapped lines align with the caption text. Set to `false` for an inline label. |

| `toc.depth` | `none` or non-negative integer | `none` | `0` disables automatic contents in report/thesis templates. Reports override the shared default to `0`; set `none` to enable all levels. `book-contents(depth: 0)` instead renders an empty titled list. Other depths depend on the template. |
| `toc.title` | content or `none` | `[Table of Contents]` | Contents title; `none` omits it. |
| `toc.indent` | `auto` or length | `auto` | Entry indentation policy. |
| `toc.entry-size` | length | `10pt` | Contents entry size. |
| `toc.leading` | length | `0.65em` | Line gap in wrapped entries. |
| `toc.entry-above` | length | `0.65em` | Gap between ordinary entries. |
| `toc.main-entry-above` | length | `1.25em` | Extra gap before main-section entries. |
| `toc.title-below` | length | `1.5em` | Gap below the contents title. |
| `toc.below` | length | `2em` | Gap after the contents. |
| `lof.*`, `lot.*` | Same value forms as matching `toc.*` keys, plus boolean `compact` | `depth: none`, titles `[List of Figures]` / `[List of Tables]`, `indent: auto`, `entry-size: 10pt`, `leading: 0.65em`, `entry-above: 0.85em`, `title-below: 1.5em`, `below: 2em`, `compact: false` | Figure/table list settings. Here `depth: none` selects automatic depth. Empty lists are omitted by the report implementation. `compact: true` omits caption text. |
| `bibliography.style` | CSL style name | `"apa"` | Citation style where bibliography support is enabled. |
| `colors.bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`, `text-main`, `text-muted` | Typst color | `white`, `white`, `black`, `black`, `black`, `black` | Neutral black-on-white default. Use `theme: "slate"` for the former blue-gray palette. |

To bold only the label while keeping the hanging layout and caption text regular:

```typst
#show: report.with(config: (
  captions: (label-weight: "bold"),
))
```

Set `captions.hanging: false` separately if you want the label inline with the caption text.

## Template-specific appearance defaults

These values override the shared baseline when the named template is used.
They are appearance defaults only; the wrappers also expose content-specific
arguments described in their source API comments and guides.

| Template | Defaults or notable differences |
| --- | --- |
| `report` | Defaults to `theme: "neutral"`, `figures.placement: auto`, and `toc.depth`, `lof.depth`, `lot.depth: 0` (no automatic lists); set a depth to `none` to enable that list. Other appearance defaults come from the shared document class. Set `figures.placement: none` to keep figures in source order. `theme: none` skips a named palette and uses shared defaults. |
| `custom` | Defaults to the neutral palette and no automatic contents, figure list, or table list (`toc.depth`, `lof.depth`, `lot.depth: 0`); set a depth to `none` to enable it. Other values follow the shared defaults. `kind` defaults to `"report"`; other kinds can change front matter, numbering, headers, and bibliography behavior. `theme` accepts the built-in palettes. |
| all document templates | Default to `theme: "neutral"` or the equivalent black-on-white template defaults. Use `theme: "slate"` for the former shared blue-gray palette where themes are accepted. |
| `article` | Defaults to `theme: "neutral"`; `page.columns: 2`; `typography.size: 10pt`, `hyphenate: true`; heading numbering `none`, sizes `12pt`, `10.5pt`, `10pt`, `10pt`; `toc.depth`, `lof.depth`, `lot.depth: 0`; white paper. Article layout fields: title `18pt`, author `11pt`, affiliation `8.5pt`, abstract `9pt`, title gap `1.2em`, body gap `2.2em`. |
| `journal-entry` / `journal-index` | Default to `theme: "neutral"`; `page.paper: "iso-b5"`; margins `(left: 2cm, right: 2cm, top: 2.5cm, bottom: 2.5cm)`; body `Libertinus Serif 11pt`, `0.65em` leading, no hyphenation, justified; h1 `16pt`, h2 `12pt`, h3/h4 `11pt`; date `10pt`, running header `9pt`, footer `10pt`; list gap `0.65em`; black-on-white palette. Journal block, metadata, list, and running-header settings use `journal.*` above. |
| `letter` | DIN A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 25mm)`, Inter `11pt`, `0.65em` leading, justified, no hyphenation, black text/accent, white paper. Canonical direct options include `font`, `paper`, `margins`, `font-size`, `line-spacing`, and `justify`. Nested config only accepts the documented page, typography, color, and link keys. |
| `invoice` / `rechnung` | Same DIN page geometry and Inter `11pt`, `0.65em` leading; output remains German. Canonical direct names are `sender`, `recipient`, `date`, `items`, `qr`, `qr-amount`, and `qr-purpose`; German names are aliases. Nested config accepts the same limited appearance keys as letters. |
| `book` (experimental) | A4; margins `(left: 27mm, right: 25mm, top: 25mm, bottom: 27mm)`; left binding with `5mm` correction; Libertinus Serif `11pt`; New Computer Modern Math; `0.74em` leading; `14pt` paragraph gap; no page headers; neutral black accent/ink by default. `theme: "slate"` selects the former blue-gray palette. |
| `cover-page` | A4, `2.5cm` margins, Libertinus Serif `11pt`, black-on-white neutral cover palette; `theme` defaults to `"neutral"`, and layout defaults to `"classic"`. Generated title content requires `layout: "research"` or `"minimal"`; classic requires `body` and remains the composable slot-based layout. Covers consume only the documented page, font, and color keys; other valid shared keys are accepted and ignored. They do not inherit a following document's `theme` or `config`. The research layout leaves `4.5cm` above its title block. |
| `research-proposal` / `project-proposal` | No contents/lists; margins `(x: 25mm, y: 25mm)`; white paper, black text and links; paragraph gap `0.7em`; heading numbering `"1.1"`. |
| `dfg-proposal` | DFG form 53.01 (09/26), A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 15mm)`; Arial `11pt`, form-specific leading, four-level numbering `"1.1.1.1"`; no contents/lists; black text/links; left captions. |
| `nwo-proposal` | Only source-checked 2026 profiles; A4 with `25mm` margins; Arial, 9.5pt pre-proposal or 10pt Vici full form; no contents/lists; black text/links. Form profile controls remaining typography and page budget. |

These wrappers intentionally do not share identical layouts. Their appearance
inputs follow the documented per-template contract; omitted values use the
template-specific defaults in this table.

## Candidate examples

This compiles with the candidate `custom` API and illustrates a minimal
override for a custom document structure. Usually start with a named template
such as `report`, `article`, `journal-entry`, or `book`; call `custom`
directly when you want to supply your own structure:

```typst
#import "@local/satz:0.2.0": custom
#show: custom.with(config: (
  typography: (font: "EB Garamond", size: 12pt),
  line-numbers: (enabled: true, scope: "document"),
  colors: (brand-primary: rgb("#355D50")),
))
= A heading
Body text.
```

`@local/satz:0.2.0` refers to the isolated candidate package tree used by the
release check. For ordinary use, import the published package version. The
0.2.0 candidate has not been published.

The versioned reference covers exported entry points and their Satz-specific input contracts. The isolated candidate and published-package checks compile examples against the versions they declare. The candidate requires Typst 0.15.0, so local checks must run in that environment.

Journal entry dates have a separate value contract: empty strings are allowed
for drafts; otherwise use ISO `YYYY-MM-DD`, `DD/MM/YY`, or `DD/MM/YYYY`, with an
optional weekday prefix separated by a comma or one space. Calendar values are
validated, and an empty date is grouped as “Undated” in the monthly index. See
the [journal guide](site/guides/journals.md).

For `article`, `authors` accepts one author dictionary directly or an array of
dictionaries. Each record has a required `name` (string or content) and optional
`affiliations` (an array of one-based integer indices). The top-level
`affiliations` value is an array of strings or content. Out-of-range indices
and malformed records produce field-specific errors; unknown author dictionary
keys are preserved for caller-side metadata.

Letter and invoice sender/recipient values must be dictionaries. Text address
fields (`name`, street, postal-code/city, country, and contact/billing fields)
must be strings; sender logos accept Typst content or `none`. Invoice items are
three-value arrays `(description, quantity, unit-price)` or records with those
three fields. Descriptions accept strings or content, quantities are positive
numbers, and unit prices are non-negative numbers. The existing German tuple
form remains supported.

`letter` accepts only `language: "de"` or `language: "en"` (the German
alias is `lang:`). DFG proposals accept `form-date` as a display string and
`check-pages` as a boolean. NWO profiles currently require the integer year
`2026`; an equal-looking floating-point value is rejected.

## Exported entry points and input contracts

The following public entry points are re-exported by lib.typ. Content means ordinary Typst content; native Typst options retain Typst's own validation. Optional arguments default to the values shown here or in the executable signatures. See the linked guides and source doc comments for detailed field semantics.

| API | Input contract |
| --- | --- |
| custom | kind defaults to report; `theme` defaults to neutral; config, optional header/footer, required body. Shared configuration is listed above. `personal()` is not exported in 0.2.0. |
| report | required body, config, theme (neutral by default; none retains its legacy palette). |
| article | optional title, authors, affiliations, abstract and date; config/theme; required body. `authors` accepts one record directly or an array of records, each with a required string/content name and optional one-based affiliation indices. Affiliations are strings/content. |
| letter | English canonical fields are `sender`, `recipient`, `date`, `reference-line`, `subject`, `enclosure-list`, `attachments`, `signature-addition`, and `postal-mark`; optional `language` is `de` or `en`. Sender/recipient are records with string address fields; optional logo is content/none. Appearance flags and layout options are booleans, strings, lengths, or dictionaries. Letter argument and record names are English. Omitting `date` uses the compilation date; `show-date: false` hides the date without hiding supplied reference fields. |
| rechnung / invoice | English canonical fields are `sender`, `recipient`, `date`, `invoice-number`, `service-date`, `subject`, and `items`; `qr`, `qr-amount`, and `qr-purpose` control payment encoding. Sender/recipient follow the letter record contract. Items are records or three-value tuples: description (string/content), positive numeric quantity, nonnegative numeric unit price. Output is German; German input names are aliases. |
| journal-entry | title/date/keywords strings, required body, config/theme. Date is blank or a valid YYYY-MM-DD, DD/MM/YY, or DD/MM/YYYY date, optionally prefixed with weekday. |
| journal-index | config/theme; queries journal entries and groups blank dates under Undated. remember and question are content blocks. |
| cover-page | config, logos/body/footer/footer-left, layout, theme and generated title fields. Layout is classic/research/minimal; theme is neutral/slate/soft-jade/soft-slate/warm-editorial/plum/soft-rose. Classic requires custom body; generated layouts require title. Pass `theme` and `config` explicitly to share them with another template. |
| book (experimental) | required body and title unless `cover-image` is supplied; subtitle/author/eyebrow/note/date, accent/ink/theme, page, font, binding, binding-correction, and running-headers options, plus config. `config.book.running-headers` overrides the direct `running-headers` argument. Compose with book-contents(title, depth), book-mainmatter(numbering), book-appendix(body), book-backmatter(body), and book-index(body, ...). Educational components exercise, worked-example, analysis-note and answer-grid accept content and optional layout settings; `exercise` requires the book class. |
| research-proposal / project-proposal | title/applicants/institution, optional date/summary/short-title, English/German language, config, required body. proposal-budget takes item records with description, nonnegative integer-cent unit-cost, and optional positive integer quantity (default 1). |
| proposal-gantt | nonempty rows, periods (positive integer), unit (month/quarter), optional start-year, resource labels, widths, size/color, English/German language. Task/group rows have label and inclusive spans; milestones have label and integer at-period. Work-package accepts title/objective, lead/period, arrays of tasks/deliverables/milestones, risk, language and body. |
| dfg-proposal | applicant/project content, English/German language, positive integer max-pages, string form-date, boolean check-pages, config and required doc content. dfg-supplement has no arguments; dfg-publications accepts one optional bibliography source and size of at least 9pt. DFG config additionally accepts page.header-ascent and decorative.list-indent/list-body-indent/list-spacing/list-block-spacing. See proposals.md for supported form scope. |
| nwo-proposal | scheme/domain/stage/year profile, applicant/title, config and required body. Only source-checked 2026 combinations are supported; see nwo-proposals.md. nwo-text takes a field and plain string. nwo-key-output allows up to three string/content indicators, two URL strings, and boolean/none open-access. nwo-page-budget takes a unique nonempty key and positive page limit. |
| complaint / klageschrift | English canonical fields: court, court-address, plaintiff, plaintiff-street, plaintiff-postal-code-city, defendant, defendant-street, defendant-postal-code-city, amount-in-dispute, exhibits, exhibits-pdf, exhibit-page-limit, date, plaintiff-designation, font, and required body. `exhibit-page-limit` must not exceed the PDF page count. Output is German; German names are aliases. |
| guest-contract / gastspielvertrag | document mode (vertrag/angebot/rechnung), fee mode (fest/prozent), string artist/event fields, nonnegative integer costs and counts, percentage 0–100, booleans for technician/photographer/small-business, nonnegative transport rate, font and required body. `small-business` defaults to true and emits the § 19 VAT note. In `rechnung` mode only the title is rendered; `body` is ignored. Output is German; German names are aliases. |
| scientific-table / scientific-tables | table columns, nonempty header, config and remaining native table arguments; show-rule body, breakable flag and config. |
| callout | required body, optional title/config and fill/stroke overrides. |
| placeholder | width, height, label and config; wrap in a native figure for caption and numbering. |
| satz-figure | required body, optional full/short captions and remaining native figure arguments. |
| chapter-numbering | required body, chapter number and appendix flag. |
| citepre | citation key and optional prefix content. |
| proposal-citations / proposal-publications | BibTeX text, highlight-key array, optional CSL style and body; bibliography size and highlight limit. Highlight keys must exist in the bibliography. |
| theme-config / document-themes | palette selection and optional config. Available palettes are neutral, slate, soft-jade, soft-slate, warm-editorial, plum and soft-rose. |
| merge / defaults | generic deep dictionary merge and root defaults. Unknown keys remain permitted for caller extensions and may be unused. |

Known shared configuration groups (page, typography, headings, journal, decorative, page-footer, line-numbers, links, tables, figures, callouts, captions, toc/lof/lot, bibliography, and colors) validate their direct keys and require dictionary values. Page margins also accept inside/outside/x/y. DFG adds page.header-ascent and decorative.list-indent/list-body-indent/list-spacing/list-block-spacing; book adds headings.h1-number-size. Unknown top-level groups remain open for template-specific settings and caller extensions. This catches common misspellings such as typography.leadng without rejecting custom extension groups. Postal templates additionally validate their closed appearance groups. Satz-specific enums and record shapes are checked at public entry points, while forwarded native Typst options use Typst validation.

The staged candidate check compiles the quick-start and representative template examples against 0.2.0 source. The published-package check separately compiles stable examples against 0.1.1. The contracts above were compared with exported signatures and implementation checks.

## Exact candidate signatures
These signatures are taken from the current source; they show every optional argument and default. Aliases share the signature of their target: `invoice` / `rechnung`, `complaint` / `klageschrift`, and `guest-contract` / `gastspielvertrag`. `project-proposal` is `research-proposal`, and `research-cover` / `minimal-cover` fix the corresponding `cover-page.layout`. `defaults`, `cover-themes`, and `document-themes` are exported dictionaries; `merge(base, overrides)` recursively merges dictionaries and otherwise replaces values.

### `letter` ([`lib.typ`](../lib.typ))

```text
#let letter(
  body,
  sender: none,
  recipient: none,
  date: none,
  show-date-label: none,
  reference-line: none,
  subject: none,
  enclosure-list: none,
  attachments: none,
  signature-addition: none,
  postal-mark: none,
  language: none,
  signature: none,
  fold-marks: none,
  address-window: none,
  page-numbers: none,
  digital-sender: none,
  date-right: none,
  justify: none,
  show-sender: none,
  show-recipient: none,
  show-date: none,
  show-subject: none,
  paper: none,
  margins: none,
  font-size: none,
  line-spacing: none,
  block-spacing: none,
  subject-size: none,
  digital-sender-height: none,
  theme: "neutral",
  config: (:),
  font: "Inter",
)
```

`letter` uses English argument and address field names. Set `language: "de"` for German labels or `"en"` for English labels.

A single `reference-line` accepts a `(label, value)` pair; several references use an array of pairs.

### `rechnung` ([`invoice/rechnung.typ`](../invoice/rechnung.typ))

```text
#let rechnung(
  absender: none,
  empfaenger: none,
  datum: none,
  rechnungsnummer: none,
  leistungsdatum: none,
  betreff: none,
  posten: none,
  sender: none,
  recipient: none,
  date: none,
  invoice-number: none,
  service-date: none,
  subject: none,
  items: none,
  qr: true,
  qr-betrag: none,
  qr-amount: none,
  qr-verwendungszweck: none,
  qr-purpose: none,
  font: "Inter",
  kleinunternehmer: none,
  small-business: none,
  theme: "neutral",
  config: (:),
  body
)
```

### `dfg-proposal` ([`dfg-proposal/dfg.typ`](../dfg-proposal/dfg.typ))

```text
#let dfg-proposal(
  applicant: [], project: [], language: "english", max-pages: 17,
  form-date: "09/26", check-pages: true, config: (:), doc,
)
```

### `dfg-supplement` ([`dfg-proposal/dfg.typ`](../dfg-proposal/dfg.typ))

```text
#let dfg-supplement()
```

### `dfg-publications` ([`dfg-proposal/dfg.typ`](../dfg-proposal/dfg.typ))

```text
#let dfg-publications(source: none, size: 9pt, style: "apa", ..args)
```

### `research-proposal` ([`proposal/template.typ`](../proposal/template.typ))

```text
#let research-proposal(
  title: [], applicants: [], institution: [], date: none, summary: none,
  short-title: none, language: "english", config: (:), body,
)
```

### `proposal-budget` ([`proposal/components.typ`](../proposal/components.typ))

```text
#let proposal-budget(items, language: "english", total-label: none)
```

### `proposal-gantt` ([`proposal/planning.typ`](../proposal/planning.typ))

```text
#let proposal-gantt(
  rows, periods: 24, unit: "month", start-year: none,
  resources: (), label-width: 40mm, resource-width: 10mm,
  size: 11pt, color: rgb("314158"), language: "english",
)
```

### `work-package` ([`proposal/planning.typ`](../proposal/planning.typ))

```text
#let work-package(
  title: [], objective: [], lead: none, period: none,
  tasks: (), deliverables: (), milestones: (), risk: none,
  language: "english", body: [],
)
```

### `proposal-citations` ([`proposal/citations.typ`](../proposal/citations.typ))

```text
#let proposal-citations(bib, highlight: (), style: none, body)
```

### `proposal-publications` ([`proposal/citations.typ`](../proposal/citations.typ))

```text
#let proposal-publications(size: 11pt, max-highlight: none)
```

### `complaint` / `klageschrift` ([`legal-complaint/template.typ`](../legal-complaint/template.typ))

```text
#let klageschrift(
  gericht: none,
  gericht_ort: none,
  klagername: none,
  klagerin_str: none,
  klagerin_plz: none,
  beklagter: none,
  beklagter_str: none,
  beklagter_plz: none,
  streitwert: none,
  anlagen: none,
  anlagen_pdf_path: none,
  anlagen_max_pages: none,
  datum: none,
  court: none,
  court-address: none,
  plaintiff: none,
  plaintiff-street: none,
  plaintiff-postal-code-city: none,
  defendant: none,
  defendant-street: none,
  defendant-postal-code-city: none,
  amount-in-dispute: none,
  exhibits: none,
  exhibits-pdf: none,
  exhibit-page-limit: none,
  date: none,
  plaintiff-designation: none,
  font: "Inter",
  body,
)
```

Defaults resolve to court `"Amtsgericht"`, empty party/value fields, a
30-page exhibit limit, the compilation date, and `"Kläger/in"`. The output
remains German.

### `guest-contract` / `gastspielvertrag` ([`gastspielvertrag/template.typ`](../gastspielvertrag/template.typ))

```text
#let gastspielvertrag(
  // Document type
  dokument: none,
  document-type: none,

  // Artist info
  kuenstler: none,
  kuenstler_vertreter: none,
  kuenstler_anschrift: none,
  artist: none,
  artist-representative: none,
  artist-address: none,

  // Event
  veranstaltung: none,
  location: none,
  datum: none,
  auftrittszeit: none,
  auftrittsdauer: none,
  einlass: none,
  curfew: "",
  event: none,
  venue: none,
  date: none,
  performance-time: none,
  performance-duration: none,
  doors: none,

  // Personnel
  musiker: none,
  techniker: none,
  fotograf: none,
  musicians: none,
  technician: none,
  photographer: none,

  // Fee
  gage_typ: none,
  festgage: none,
  prozentsatz: none,
  mindestgage: none,
  kleinunternehmer: none,
  fee-type: none,
  fixed-fee: none,
  percentage: none,
  minimum-fee: none,
  small-business: none,

  // Transport
  transport_km: none,
  transport_satz: none,
  travel-km: none,
  travel-rate: none,

  // Optional costs
  techniker_honorar: none,
  uebernachtung: none,
  sonstiges_text: none,
  sonstiges_betrag: none,
  technician-fee: none,
  accommodation: none,
  other-description: none,
  other-amount: none,

  // Hospitality
  buyout_pro_person: none,
  buyout-per-person: none,

  // Styling
  font: "Inter",

  // Extra content
  body,
)
```

Defaults resolve to `"vertrag"`, placeholder artist details, a fixed fee of 0,
80% of ticket sales when percentage mode is selected, the § 19 VAT note enabled,
30 cents per kilometre, and a 15 EUR hospitality buy-out. The output remains
German.

### `journal-entry` ([`journal/template.typ`](../journal/template.typ))

```text
#let journal-entry(
  title: "",
  date: "",
  keywords: "",
  body,
  config: (:),
  theme: "neutral",
)
```

### `journal-index` ([`journal/template.typ`](../journal/template.typ))

```text
#let journal-index(config: (:), theme: "neutral")
```

### `remember` ([`journal/components.typ`](../journal/components.typ))

```text
#let remember(body)
```

### `question` ([`journal/components.typ`](../journal/components.typ))

```text
#let question(body)
```

### `report` ([`report/template.typ`](../report/template.typ))

```text
#let report(body, config: (:), theme: report-defaults.theme)
```

### `article` ([`article/template.typ`](../article/template.typ))

```text
#let article(title: none, authors: (), affiliations: (), abstract: none, date: none, config: (:), theme: "neutral", body)
```

### `book` ([`book/template.typ`](../book/template.typ))

```text
#let book(
  body,
  title: none,
  cover-image: none,
  subtitle: none,
  author: none,
  eyebrow: none,
  note: none,
  date: none,
  accent: none,
  ink: none,
  theme: "neutral",
  paper: none,
  margin: none,
  math-font: none,
  font: none,
  font-size: none,
  leading: none,
  paragraph-spacing: none,
  binding: auto,
  binding-correction: none,
  running-headers: "bottom",
  config: (:),
)
```

### `book-contents` ([`book/template.typ`](../book/template.typ))

```text
#let book-contents(title: [Contents], depth: 1)
```

### `book-mainmatter` ([`book/template.typ`](../book/template.typ))

```text
#let book-mainmatter(body, numbering: none)
```

### `book-appendix` ([`book/template.typ`](../book/template.typ))

```text
#let book-appendix(body)
```

### `book-backmatter` ([`book/template.typ`](../book/template.typ))

```text
#let book-backmatter(body)
```

### `book-index` ([`book/template.typ`](../book/template.typ))

```text
#let book-index(
  body,
  title: [Index],
  column-count: 2,
  gutter: 18pt,
  indent: 10pt,
  spacing: 3pt,
)
```

`spacing` controls the gap between entries and the paragraph spacing inside each
hanging-indent entry.

### `exercise` ([`book/components.typ`](../book/components.typ))

```text
#let exercise(body, kind: "Core", grid: none)
```

### `worked-example` ([`book/components.typ`](../book/components.typ))

```text
#let worked-example(body, above: none, below: none, inset: none)
```

### `analysis-note` ([`book/components.typ`](../book/components.typ))

```text
#let analysis-note(body, title: [In your analysis])
```

### `answer-grid` ([`book/components.typ`](../book/components.typ))

```text
#let answer-grid(height: 25mm, cell: 5mm, color: none, width: none)
```

### `cover-page` ([`cover.typ`](../cover.typ))

```text
#let cover-page(
  config: (:),
  logos: none,
  body: none,
  footer: none,
  footer-left: none,
  layout: "classic",
  theme: "neutral",
  title: none,
  subtitle: none,
  author: none,
  date: none,
  keywords: none,
  supervisors: none,
)
```

### `custom` ([`class.typ`](../class.typ))

```text
// Use a named template for its ready-made document structure. Use
// custom when you want to write your own structure with Satz styling.
#let custom(
  kind: "report",
  theme: "neutral",
  config: (:),
  header: none,
  footer: none,
  body,
)
```

`personal()` is not exported in 0.2.0. Templates share the internal
`document-class()` layer; users writing their own structure use `custom()`.

### `satz-figure` ([`class.typ`](../class.typ))

```text
#let satz-figure(body, caption: none, short-caption: none, ..args)
```

### `citepre` ([`citation.typ`](../citation.typ))

```text
#let citepre(key, pre: none)
```

### `placeholder` ([`figures.typ`](../figures.typ))

```text
#let placeholder(width: 100%, height: 4cm, label: [Placeholder], config: (:))
```

### `scientific-table` ([`tables.typ`](../tables.typ))

```text
#let scientific-table(columns: 1, header: (), config: (:), ..args)
```

### `scientific-tables` ([`tables.typ`](../tables.typ))

```text
#let scientific-tables(body, breakable: false, config: (:))
```

### `callout` ([`callouts.typ`](../callouts.typ))

```text
#let callout(body, title: none, config: (:), fill: auto, stroke: auto)
```

### `chapter-numbering` ([`chapter-numbering.typ`](../chapter-numbering.typ))

```text
#let chapter-numbering(body, chapter: 1, appendix: false)
```

### `nwo-proposal` ([`nwo-proposal/template.typ`](../nwo-proposal/template.typ))

```text
#let nwo-proposal(
  scheme: "veni", domain: "science", stage: "pre", year: 2026,
  applicant: [], title: [], config: (:), body,
)
```

### `nwo-profile` ([`nwo-proposal/profiles.typ`](../nwo-proposal/profiles.typ))

```text
#let nwo-profile(scheme: "veni", domain: "science", stage: "pre", year: 2026)
```

### `nwo-text` ([`nwo-proposal/components.typ`](../nwo-proposal/components.typ))

```text
#let nwo-text(field, response)
```

### `nwo-key-output` ([`nwo-proposal/components.typ`](../nwo-proposal/components.typ))

```text
#let nwo-key-output(reference: [], output-type: [], contribution: [], indicators: (), urls: (), open-access: none)
```

### `nwo-page-budget` ([`nwo-proposal/components.typ`](../nwo-proposal/components.typ))

```text
#let nwo-page-budget(key, max-pages: 14, body)
```

### `theme-config` ([`themes.typ`](../themes.typ))

```text
#let theme-config(name, config: (:))
```
