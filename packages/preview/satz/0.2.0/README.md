# satz

**[Read the Satz documentation](https://kylekahraman.github.io/satz/)** · [Start a journal](https://kylekahraman.github.io/satz/guides/journals/) · [Write your first report](https://kylekahraman.github.io/satz/getting-started/report/)

A Typst package for everyday documents — letters, invoices, reports, journals, and grant proposals.

Satz is a package, not a LaTeX-style class. Inside it, a collection of optional templates and components sits on a shared document layer (`class.typ` + `defaults.typ`). The wrappers give you ready-made structures; the shared layer supplies page setup, headings, links, outlines, and deep-merged configuration. Use `custom()` when you want the shared styling without a fixed structure.

## Quick start: a report

Create `main.typ`, import Satz, and start writing. You do not need to copy a
template file or create a separate configuration file:

```typst
#import "@preview/satz:0.2.0": report
#show: report.with()

= Introduction

Write your report here.

== Background

Continue with ordinary Typst markup.
```

Compile with `typst compile main.typ`, or paste this into a Typst web-app
project for live preview. The report adds numbered headings while
your content remains ordinary Typst. Contents, figure lists, table lists, and a
cover are optional. Add configuration only when you need to change a default.

See the [full report quick start](https://kylekahraman.github.io/satz/getting-started/report/) or browse
the [Satz documentation](https://kylekahraman.github.io/satz/) for journal,
letter, figure, table, and layout guides. The site source is in `docs/site/`.

## Choose an article, report, or book

| Template | Start here when you are writing | Default layout |
|---|---|---|
| `article()` | A paper or essay organized into sections | Two columns; title, authors, affiliations, and abstract can appear above the text |
| `report()` | A report, protocol, or thesis organized into chapters or sections | One column; numbered headings; contents optional |
| `book()` (experimental) | A book or thesis with book-style front matter and chapter layout | Two-sided pages, a cover, and explicit front and main matter |

For most theses, start with `report()`. Choose `book()` when you want its
book-style cover, facing pages, and front- and back-matter structure; it is still
experimental. Both can use ordinary Typst figures, tables, and references.
The difference between sections and chapters is a way to organize your content,
not a restriction on what you may write in either template.

Reports keep top-level headings on the current page by default to avoid wasted
space. To start each chapter on a new page, set:

```typst
#show: report.with(config: (headings: (h1-pagebreak: true)))
```

Articles default to two columns; choose one or more columns with
`config: (page: (columns: 1))`, and set `column-gutter` if needed. See
[article layouts](https://kylekahraman.github.io/satz/getting-started/article/) and the
[book guide](docs/book-api.md) for examples.

## Quick Usage

### Write a letter in one file

This is a complete `main.typ`; no copied template file or separate `config.typ`
is required:

```typst
#import "@preview/satz:0.2.0": letter
#show: letter.with(
  sender: (name: "Example Author", street: "Example Street 1", postal-code-city: "12345 Example City"),
  recipient: (name: "Example Recipient", street: "Sample Road 2", postal-code-city: "54321 Sample City"),
  date: "2026-10-27",
  subject: "Appointment request",
  language: "en",
)

Dear Example Recipient,

Could we arrange an appointment next week?

Kind regards,
```

`letter` uses English argument names and supports German or English output labels.
The package supplies the page layout, sender/recipient blocks, date, subject, and
signature line. Write the salutation and closing in the body. Argument and record
names are English. The date is explicit
here so recompiling later does not silently change the letter; omit it to use the
compilation date. For a digital letter, see the options below.

### Two-column articles

Satz includes an article entry point. Start writing
immediately after the show rule; a separate template or config file is optional:

```typst
#import "@preview/satz:0.2.0": article
#show: article.with(
  title: [My paper],
  authors: (name: "Example Author", affiliations: (1,)),
  affiliations: ([Example Institute],),
  abstract: [A short account of the question and findings.],
)

= Introduction
Start writing here.
```

Articles use two native page columns, a full-width title/author/abstract block,
unnumbered headings, and page numbers starting at 1. Set
`config: (page: (columns: 1))` for a single-column article. The shared
`page.column-gutter` controls the column gap (default 5mm). Reports also accept
these column settings; their generated front matter stays single-column.
An article's optional `toc.depth` inserts contents inline; automatic figure and
table lists remain a report feature.

The `config` argument accepts the shared Satz sections (`page`, `typography`,
`headings`, `colors`, `toc`, and others) plus `article` settings. For example,
set text and math fonts independently with
`typography: (font: "STIX Two Text", math-font: "STIX Two Math")`. Shared
defaults are listed in [the configuration reference](docs/configuration-reference.md)
and defined in `defaults.typ`; article-specific defaults are in
`article/defaults.typ` (two columns, 10pt text, unnumbered headings, and no
automatic contents by default).

Use ordinary `figure` for a column-width figure, with `image(..., width: 100%)`
to fit the column. Add `scope: "parent", placement: top` to span both columns.
Mixed column/page floats can appear out of numerical order; where order matters,
try bottom placement for the wide figure, or a deliberate `pagebreak()` before
it to establish a new page.
See [the complete article example](examples/article.typ). Native columns are
sufficient for this layout; Meander remains an option for custom text flow.

### Reports and journals

```typst
#import "@preview/satz:0.2.0": report
#show: report.with(config: (
  typography: (font: "Libertinus Serif"),
  lof: (depth: none, compact: true), // Enable a compact List of Figures
))

= My Report
...
```

```typst
#import "@preview/satz:0.2.0": journal-entry
#show: journal-entry.with(
  title: "Experiment 42",
  date: "2025-03-15",
  keywords: "synthesis, characterization",
)

...
```

## Templates

| Template | Function | Description |
|---|---|---|
| **letter** | `letter(...)` | DIN 5008-style postal letter with fold/punch marks. Canonical fields: `sender`, `recipient`, `date`, `subject`, `language`, `reference-line`, `enclosure-list`. `language` is `"de"` / `"en"`; Letter argument and record names are English. |
| **invoice** | `invoice(...)` / `rechnung(...)` | German invoice adapted from the letter template. Canonical fields: `sender`, `recipient`, `date`, `items`, `qr`, `qr-amount`, `qr-purpose`. Optional EPC QR code; output remains German. |
| **journal** | `journal-entry(..)`, `journal-index(..)` | Research diary on ISO B5 with entries, keywords, and auto-generated monthly index |
| **article** | `article(...)` | Articles and manuscripts with title, authors, affiliations, and abstract; configurable columns |
| **report** | `report(body, config: (:), theme: "neutral")` | Reports, protocols, and theses — numbered headings, optional contents and figure/table lists, two-sided layout, pre-styled bibliography |
| **book (experimental)** | `book(...)`, `book-contents()`, `book-mainmatter[...]`, `book-appendix[...]`, `book-backmatter[...]`, `book-index[...]` | KOMA-Script-inspired book layout with adjustable or image cover, alternating running titles, back-matter pages, two-column index, and optional exercise components |
| **dfg-proposal** | `dfg-proposal(...)`, `dfg-supplement()`, `dfg-publications(...)` | DFG 53.01 (09/26), German/English starters, separate page limits and counters |
| **research/project proposal** | `research-proposal(...)` / `project-proposal(...)`, `proposal-budget(...)` | Flexible proposal with inline title/summary, current/total page headers, and exact budget totals |
| **NWO proposal (experimental)** | `nwo-proposal(...)`, `nwo-profile(...)` | 15 represented Veni/Vidi/Vici 2026 scheme/domain/stage profiles; not full NWO form coverage |
| **legal-complaint** | `complaint(...)` / `klageschrift(...)` | German civil complaint (ZPO) — Rubrum, Streitwert, Anlagen. Output remains German. |
| **guest contract** | `guest-contract(...)` / `gastspielvertrag(...)` | German guest performance contract (§1–8, transport, buy-out, 3 document modes). Output remains German. |
| **cover** | `research-cover(...)`, `minimal-cover(...)`, `cover-page(...)` | Optional ready-made title pages or composable logo/body/footer slots. No implicit inheritance from the document. |

The manifest identifies 0.2.0 as the release candidate. It requires Typst 0.15.0
or newer. Examples target 0.2.0; before that version reaches Typst Universe,
substitute `@local/satz:0.2.0` for local testing. Each template states its support
level explicitly: DFG
support is limited to form 53.01 (09/26), NWO support covers only the
represented profiles, and book support remains experimental. None of these
imply support for every proposal form or complete LaTeX/KOMA-Script parity.
See the [release plan](docs/release-0.2.0-plan.md).

### Canonical English names and compatibility aliases

English names are the documented interface throughout 0.2.0. Existing German
argument names still normalize to the same templates, so documents written for
0.1.1 keep working. Nested sender and recipient fields are translated too:

```typst
#show: letter.with(
  sender: (name: "Example Sender", street: "Example Street 1", postal-code-city: "London"),
  recipient: (name: "Example Recipient", street: "Sample Road 2", postal-code-city: "York", country: "UK"),
  subject: "A letter in German",
  language: "de",
)
```

English field spelling does not select the output language; `language:` controls
letter labels and hyphenation. Invoices accept English `items:` records with
`description`, `quantity`, and `unit-price`; invoice output remains German.
The guest contract and civil complaint also accept English content fields, but
their legal output remains German. Supplying both spellings of a field produces
an error that names the conflict.

### Shared appearance options

All document templates default to the `neutral` black-on-white palette. The
former dark blue-gray base palette is now the opt-in `slate` theme. Other
available themes are `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and
`soft-rose`. The appearance order is shared defaults, template defaults,
selected `theme:`, explicit direct appearance arguments, then nested `config:` overrides. Nested
dictionaries merge by key, so an override can change one color without
replacing the other palette values. `theme: none` skips the theme and keeps
the template's own defaults.

Letters and invoices retain their DIN page geometry and accept `config:` keys
in these groups: `page.paper` and `page.margin`; `typography.font`, `size`,
`leading`, `justify`, and `hyphenate`; `colors.bg-paper`, `brand-primary`, and
`text-main`; and `links.color` and `url-color`. Unsupported groups or keys fail
with an error naming the setting. For example, this changes the subject accent
while keeping the selected palette's other colors:

```typst
#show: letter.with(
  theme: "soft-jade",
  config: (colors: (brand-primary: rgb("#336699"),)),
)
```

These appearance options are new in 0.2.0. The book also resolves `accent`,
`math-font`, and the nested config through this precedence order, so a raw
argument cannot bypass an explicit nested override. See the
[0.2.0 configuration reference](docs/configuration-reference.md) for the shared
defaults and their value contracts.

### Letters — language and PDF applications

`letter()` accepts `language: "de"` (default) or `"en"`.
This changes labels for phone, email, date, attachments, and page numbers, and
sets the Typst text language for hyphenation. It does not change argument names.
Use English argument and record names in either language.

The postal layout remains the default. For an application sent as a PDF, hide
the envelope-specific components:

```typst
#import "@preview/satz:0.2.0": letter

#show: letter.with(
  sender: (name: "Your Name", email: "you@example.org", website: "example.org"),
  recipient: (name: "Recipient", care-of: "University"),
  date: "2026-10-27",
  subject: "Application for a PhD position",
  language: "en",
  fold-marks: false,
  address-window: false,
  page-numbers: false,
  digital-sender: true,
  date-right: true,
  justify: false,
  block-spacing: ("sender-recipient": 0.65em),
  signature: false,
)

Dear Recipient,

Your letter text.
```

`postal-mark: ""` already hides the postal note. `signature: false` omits the
printed signing rule and sender name; include a closing in the body. These
options default to the postal behaviour, so existing letters render as before.

Page format, margins, and text size are configurable with `paper`, `margins`,
and `font-size`; `line-spacing` controls body leading and default gaps.
`block-spacing` accepts partial overrides for `sender-recipient`, `sender-date`,
`sender-subject`, `sender-body`, `recipient-date`, `recipient-subject`,
`recipient-body`, `date-subject`, `subject-body`, `date-body`, and `signature`.
Set `show-sender`, `show-recipient`, `show-date`, or `show-subject` to `false`
to omit those blocks. Hiding the date keeps separately supplied reference fields.
`subject-size` and `digital-sender-height` adjust the subject size and digital
header height.

Use `enclosure-list: ("Protocol copy", "Schedule copy")` to print an enclosure
list without embedding files. If `attachments` also contains file paths, the
named list supplies their display labels; without it, the paths are the fallback.

Migration from 0.1.1: replace `brief` with `letter` and use English argument and address field names, such as `sender`, `recipient`, `street`, and `postal-code-city`.

### Invoice — EPC QR code

Set `qr: true` (default) to embed a scannable GiroCode:
- Encodes IBAN, BIC, amount (totalled from items or overridden with `qr-amount`), and purpose (`qr-purpose`)
- Banking apps such as N26 or Sparkasse auto-fill transfer details when scanned

Invoice output remains German. The 0.1.1 German argument names remain aliases.

### Cover pages — ready-made layouts or full control

For a research notebook, pass the usual title details directly. No separate
`config.typ` is needed:

```typst
#import "@preview/satz:0.2.0": research-cover

#research-cover(
  title: [MEG Connectivity Analysis in #box[Non-Conscious] Working Memory],
  subtitle: "Research Notebook",
  author: "Your Name",
  date: "October 2026",
  supervisors: ("Supervisor One", "Supervisor Two"),
  theme: "soft-jade",
  config: (page: (paper: "iso-b5")),
)
```

Use `minimal-cover` for a centered title page, or
`cover-page(layout: "classic", body: [...])` to compose the logo/body/footer
slots yourself. Built-in themes are `neutral`, `slate`, `soft-jade`, `soft-slate`,
`warm-editorial`, `plum`, and `soft-rose`. `neutral` is the default and uses
black text and accents on white; the research layout leaves 4.5 cm between the
top logo area and its title block. Override individual colors with
`config: (colors: (brand-primary: ...))`.

A cover is deliberately optional and standalone. It does not inherit the
following report's `theme` or `config`, and it should not: many documents have a
designed cover that differs from the body, and replacing a cover image should
not restyle the document. When you do want a shared look, pass the same values
explicitly:

```typst
#let shared-theme = "soft-jade"
#let shared-config = (typography: (font: "EB Garamond"),)

#cover-page(
  layout: "research",
  title: [Field notes],
  theme: shared-theme,
  config: shared-config,
)
#show: report.with(theme: shared-theme, config: shared-config)
= Introduction
```

The cover consumes page paper/margins, font family and size, and the cover color
keys. Other valid shared settings are accepted but ignored. Invalid known keys
fail, so a typo does not silently do nothing.

## Structure

Satz's named templates such as `report()`, `article()`, `journal-entry()`, and `book()` share one internal document layer. Use a ready-made template when its structure fits. Use the public `custom()` function when you want to design your own structure while reusing Satz's page and typography foundation. It reads defaults from `defaults.typ` and accepts per-document overrides through a `config` dictionary (deep merge — nested dictionaries are merged, not overwritten). This is why Satz is best described as a package of templates plus shared components, not as a Typst "class".

```
lib.typ              ← public API
defaults.typ         ← unified defaults + merge()
class.typ            ← shared document layer + public `custom()` + satz-figure
citation.typ         ← citepre() — author-year cite without parens
cover.typ            ← cover-page() — logos/body/footer slots
letter/              ← letter implementation — DIN 5008, i18n (de/en)
invoice/             ← rechnung() — German invoice, EPC QR code
journal/             ← journal-entry / journal-index + remember/question
report/              ← report() — thin wrapper around the shared document layer
dfg-proposal/        ← dfg-proposal — 53.01 (WIP)
legal-complaint/     ← klageschrift — ZPO
gastspielvertrag/    ← gastspielvertrag — guest performance contract
```

## Configuration

Override only what you need — everything else keeps its default:

Pass small overrides directly in the show rule. A reusable `config.typ` is
optional and useful when several documents should share settings. Named
templates accept the nested `config` dictionary; letters and invoices also keep
their direct appearance options for compatibility. A direct option is applied
before `config`, so the nested override wins.

```typst
#show: report.with(config: (
  typography: (font: "EB Garamond"),
  colors: (brand-primary: blue),
  lof: (depth: none, compact: true), // enable a compact List of Figures
))
```

Available sections (see the exported `defaults` dictionary for every shared key): `page`, `typography`, `headings`, `journal`, `decorative`, `page-footer`, `links`, `tables`, `figures`, `callouts`, `captions`, `toc`, `lof`, `lot`, `bibliography`, and `colors`.

To inspect the shared config beside the templates in your editor, use one namespace import and hover `satz.defaults`:

```typst
#import "@preview/satz:0.2.0" as satz
#show: satz.report.with(config: (captions: (label-weight: "bold")))
```

You can also hover `satz.report` for report-specific defaults. The shared config schema is documented once on `satz.defaults`; template docstrings describe only their effective overrides and template-specific behavior.

Captions default to a regular label in a hanging layout: wrapped lines align
with the caption text. To bold only the label, set
`captions: (label-weight: "bold")`; set `hanging: false` separately to make the
label inline. The full options are in the [configuration reference](docs/configuration-reference.md).

### Contents, figure lists, and table lists

Satz 0.2.0 uses native heading numbers and hanging indents
in the contents. Main sections are bold and separated by larger gaps;
subsections retain their complete numbers (`2.1`, `2.1.1`, etc.). Wrapped entries
use normal line leading. Outline links use the body text color.

`toc`, `lof`, and `lot` accept `entry-size`, `leading`, `entry-above`,
`title-below`, and `indent`; `toc.main-entry-above` controls section separation.
Defaults use 10pt entries, 0.65em leading, 0.65em contents row gaps, and 1.25em
before main sections. Figure/table lists use 0.85em row gaps. These gaps replace
the space between text edges: values below `leading` tighten the list.

Reports start without any of these lists. Enable each independently with
`config: (toc: (depth: none), lof: (depth: none), lot: (depth: none))`;
use a positive `toc.depth` to limit heading levels. Set a list's depth to `0`
to disable it. Empty figure/table lists and figures with `outlined: false` produce no list page.
A table needs a captioned `figure` to have a number, caption, and list entry:

```typst
#figure(
  table(columns: 2, [Measure], [Value], [Example], [12]),
  kind: table,
  caption: [Summary measurements.],
) <tab:summary>
```

A bare `table(...)` is a layout element with no caption to list. For a short
table-list caption, use `satz-figure(..., kind: table, caption: [...],
short-caption: [...])`. Compact lists retain the actual figure/table numbering
and page format, including Roman numerals. See [the complete outline
example](examples/outline.typ).

Bullet and numbered lists use `typography.list-spacing`, a fraction of the
calculated body baseline distance. Its default `0.5` adds half a line between
items; set it to `0` for no extra gap. The setting follows
`typography.line-spacing` when provided, or the selected font metrics and
`typography.leading` otherwise. Native local list rules still override package
defaults. Callout lists use their separate `callouts.list-spacing` setting.

### Report palettes

Reports default to `neutral`: white paper, black body text and headings, blue
links, and gray secondary text and panels. Colored heading accents are opt-in.
The cover themes are also available as document palettes: `neutral`, `slate`,
`soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and `soft-rose`. The
`slate` theme preserves the former blue-gray shared palette.

```typst
#import "@preview/satz:0.2.0": report
#show: report.with(theme: "soft-jade")
```

Pass `theme: "slate"` for the former shared blue-gray palette. Explicit `config.colors` and
`config.links` overrides win over the selected theme. The public
`document-themes` dictionary also makes the same palettes available for custom
`custom(config: (colors: document-themes.plum))` layouts. Report-specific
defaults set the report theme and floating figure placement; other layout defaults
come from the shared configuration.

Callout colors can be chosen independently of the report theme: pass
`config: (colors: (brand-primary: my-color, bg-subtle: my-fill))` to `callout`
for its title/border and background, or use its direct `fill:` and `stroke:`
options. Pass the same color config to the report and callout to share an accent.

#### Migrating existing report appearance

The 0.2.0 development defaults use neutral black on white across document
templates, and improve contents/list spacing. Documents that rely on the former
dark blue-gray palette can now set `theme: "slate"`.

```typst
#show: report.with(config: (
  colors: (
    bg-paper: rgb("#FFFFFF"), bg-subtle: rgb("#F5F5F5"),
    text-main: rgb("#242422"), text-muted: rgb("#5e5e5a"),
    brand-primary: rgb("#111110"), brand-accent: rgb("#2f2f2c"),
  ),
  links: (color: rgb("#B4313F"), url-color: rgb("#45556c")),
  typography: (list-spacing: 0.5),
))
```

The corrected `tables.font-size` and `tables.inset` settings now affect native
tables; their defaults are 10pt and `(x: 8pt, y: 4pt)`. Tables that depended on
inherited body size or the old hard-coded padding may wrap or paginate
differently. Use a table-local `set text(size: ...)` or `inset:` when a specific
table needs a different treatment.

### Heading and paragraph rhythm

Satz 0.2.0 defaults to shared KOMA-Script heading spacing.
It translates baseline skips using the actual font metrics, including stacked
and wrapped headings. Explicit per-level gaps remain available; set
`headings.spacing: "native"` to opt out. See the
[shared spacing guide](docs/heading-spacing.md). Existing documents can reflow.

Paragraphs default to `paragraph-spacing: 1.2em` and `first-line-indent: false`.
For an explicit baseline-to-baseline line-spacing multiple, use
`typography.line-spacing`. For example, `1.5` means each line baseline is 1.5
times the body font size below the previous one. Satz measures the selected
font's cap-height and calculates the required Typst leading. This option
overrides `typography.leading`; leave it as `none` to keep using the direct
Typst line-box gap. Paragraph spacing remains independent:

```typst
#show: report.with(config: (typography: (
  size: 12pt,
  line-spacing: 1.5,
  paragraph-spacing: 0.85em,
)))
```

For indented prose with a smaller paragraph gap:

```typst
#show: report.with(config: (typography: (
  line-spacing: 1.25,
  paragraph-spacing: 0.65em,
  first-line-indent: true,
)))
```

`first-line-indent: true` indents the first line of every paragraph by one em,
which equals the current body font size (11pt when `size: 11pt`). This includes
the first paragraph after a heading. It does not set vertical line spacing.
`paragraph-spacing` still controls the vertical gap between paragraphs; it is
independent, so set it to `0pt` or another chosen value when you prefer
indentation to provide the paragraph break cue. The same config works in
journal entries. See
the [native/KOMA typography comparison](https://github.com/kylekahraman/satz/blob/28f0595/examples/latex-parity/README.md) for the
specimen and checks.

### Table text and padding

Satz 0.2.0 applies `tables.font-size` (default `10pt`) and
`tables.inset` (default `(x: 8pt, y: 4pt)`) to native tables. These existing keys
were previously ignored, so the corrected font size can change wrapping and
pagination. Explicit rules inside an individual table still override them.
See the [research workbook migration](docs/workbook-migration.md) for the
multi-page table and diagram findings.

### Running headers

Two-sided reports and theses use
[`hydra:0.6.3`](https://typst.app/universe/package/hydra/) for heading selection:

```typst
#import "@preview/satz:0.2.0": report
#show: report.with(config: (page: (binding: left, headers: true)))
```

Even page counters show the chapter at the left; odd counters show the current
section, falling back to the chapter, at the right. Headers use the last relevant
heading on the page, including a section introduced on that page. Chapter-opening
pages have no running header. Unnumbered, outlined chapters participate;
headings with `outlined: false` do not. Headers remain disabled by default.
Custom header content takes precedence over the generated header.

The existing report page-number offset and counter-based alignment are retained.
See the [paired KOMA-Script comparison](https://github.com/kylekahraman/satz/blob/28f0595/examples/latex-parity/README.md) for
reproducible checks. Hydra also imports `oxifmt:1.0.0`; Typst downloads missing
packages on the first compilation.

### Glossaries and abbreviations

Satz exports the pinned
[`glossarium:0.5.10`](https://typst.app/universe/package/glossarium/) namespace.
Keep one list of term definitions and install its show rule before the report:

```typst
#import "@preview/satz:0.2.0": report, glossarium
#show: glossarium.make-glossary
#show: report

#let terms = (
  (key: "api", short: "API", long: "application programming interface"),
)
#glossarium.register-glossary(terms)

= Introduction
An @api connects programs. The @api is used again here.

= List of abbreviations
#glossarium.print-glossary(terms, disable-back-references: true)
```

First use expands the term; later uses show the abbreviation. Unused terms are
hidden by default; pass `show-all: true` to print them too. Glossarium setup is
optional and its upstream API remains available under the namespace. Importing
satz downloads the package if it is missing; ordinary documents need no glossary
configuration. See
[the complete example](examples/glossary.typ), including ordinary figures,
tables, and short/long captions. Avoid broad `show figure` transformations when
using Glossarium: it uses a special figure kind internally.

For long captions use `satz-figure` — long text under the figure, short title in the List of Figures (or `short-caption: []` for compact):

```typst
#import "@preview/satz:0.2.0": satz-figure
#satz-figure(image("plot.png"), caption: [Very long ...], short-caption: [Short title])
```

### Books and workbooks

Satz has an experimental `book` entry point for
KOMA-Script-like book authoring: set the title, typeface, and accent once, then
write with ordinary headings. `book-contents`, `book-mainmatter`,
`book-appendix`, and `book-backmatter` mark the document parts. Optional
components add worked examples, analysis prompts, and exercises with answer
grids. Books can use alternating running titles at the bottom, continuous
page numbering through back matter, an optional EPUB cover image, and a fresh
two-column index via `book-index`. See [the complete example](examples/book.typ) and
[the API and layout guide](docs/book-api.md). Its source-PDF measurements and
remaining parity gaps are in [the workbook comparison](docs/book-workbook-parity.md).
The RSA workbook specimen and rebuild instructions are saved in the ignored local
`workbook-conversion/` directory; its source PDF and personal details are not
included in the package.

### Placeholder figures

Draft a report before the illustrations are ready with `placeholder`, available
in Satz. It draws a labeled empty box using native
Typst, with no additional dependency:

```typst
#import "@preview/satz:0.2.0": placeholder

#figure(
  placeholder(width: 80%, height: 4cm, label: [Planned result plot]),
  caption: [Results will be inserted here.],
) <fig:planned>

See @fig:planned.
```

`placeholder()` defaults to the available width, 4cm height, and the label
“Placeholder”. It also works inside `satz-figure` for short/long captions. The
box itself adds no caption, numbering, or outline entry; the surrounding figure
provides those. An optional `config` supplies satz color/caption-style overrides.
See [the complete report example](examples/placeholders.typ).

## License

MIT


### Scientific tables and callouts (unreleased)

The development version exports `scientific-table` and `callout`. A scientific
table has explicit column headings, stronger top/bottom rules and a thinner
header rule. Headings and boundary rules repeat across page breaks. Native
cells, alignment and group separators remain available:

```typst
#import "@preview/satz:0.2.0": scientific-table, callout

#scientific-table(
  columns: (1fr, auto),
  align: (left, right),
  header: ([Condition], [Mean]),
  [Baseline], [0.12],
  [Treatment], [0.38],
)

#callout[
  *Main finding*

  Explain the finding here. The box can continue onto the next page.
]
```

Wrap the table in `figure(..., kind: table, caption: [...])` for captions and
references. For a multi-page table figure, also add
`#show figure.where(kind: table): set block(breakable: true)` in its surrounding
scope; ordinary figures are kept together by default. Pass `config:` explicitly
to either helper to share a document palette or override component settings.
The table helper uses `tables.font-size`, `tables.inset` and `tables.stroke`
(the thin rule; boundary rules are 1.6 times thicker). Native table arguments
such as `inset:` can override the helper's padding locally.

See the [complete table example](examples/scientific-table.typ),
[heading and paragraph guide](docs/typography.md), and
[research report parity audit](docs/report-parity-audit.md).
`headings.h1-above` through `h4-below` accept explicit block gaps;
`auto` selects the measured KOMA default. The audit lists remaining differences:
Satz does **not** yet claim complete LaTeX/KOMA parity.
[Unreleased changes](CHANGELOG.md) are prepared for the 0.2.0 candidate;
the package has not been published yet.

### Report numbering, captions and fonts (unreleased)

Use `#show: scientific-tables` for scientific table figures with top captions;
pass `breakable: true` only when the enclosing figure should split across pages.
Related native tables can share one figure and caption. See the
[table guide](docs/scientific-tables.md).

Use `chapter-numbering(chapter: 2)[...]` around a chapter to reset figure,
table and equation counters while retaining correct prefixes in references
from other chapters. `appendix: true` selects letter prefixes. This leaves
heading numbering and page breaks to the document; see the
[numbering guide](docs/chapter-numbering.md).

Use `unnumbered-heading(level: 1)[References]` for a heading that keeps Satz's
normal style but has no number. It remains in the table of contents by
default; pass `outlined: false` to omit it. For multiple appendices, use an
unnumbered `Appendices` heading, then scope `#set heading(numbering: "A.1")`
around the appendix headings and reset the heading counter to zero. The
appendix titles then display A, B, C, with subsections A.1, A.2, B.1, etc.
Keep appendix titles themselves free of repeated “Appendix A” wording.

Configuration adds `typography.math-font` and `typography.mono-font`
(both default to `auto`), `captions.alignment`, `captions.label-weight`,
`captions.hanging` (true by default),
`captions.hanging` (true by default),
and opt-in `headings.h1-pagebreak`. Callouts accept an attached `title:`.
The [research report audit](docs/report-parity-audit.md) records what was
visually verified and what still differs from LaTeX. These APIs are unreleased.

### Research and grant proposals (unreleased)

Start from the complete [English DFG form](dfg-proposal/example.typ) or
[German DFG form](dfg-proposal/example-de.typ). The 09/26 layout uses Arial,
four numbered heading levels, and separately checked 17/8-page parts. Insert
`dfg-supplement()` before section 4 to restart the header at page 1 of max. 8.
For a proposal with your own structure, use `research-proposal` (also
`project-proposal`); see [the example](proposal/example.typ). Both can use
`proposal-budget` for exact euro-cent calculations. Add `proposal-gantt` for
monthly/quarterly schedules and `work-package` for numbered summaries with
references. See the [planning guide](docs/proposal-planning.md) and
[complete example](examples/proposal-planning.typ).

The [proposal guide](docs/proposals.md) covers imports, bibliography sizing,
budgets, verification and scope. DFG support here covers form 53.01 project
descriptions; other DFG forms are future work. NWO Veni, Vidi and Vici now
have 2026 profiles and starters; see the [NWO guide](docs/nwo-proposals.md)
for the 15 represented scheme/domain/stage combinations and remaining gaps.

### Journal setup and appearance (unreleased)

The [journal starter guide](docs/journal-starter.md) covers a ready-to-edit
project for VS Code and Tinymist on Windows, macOS and Linux. The optional
standalone `journal` command creates entries and opens your editor; users need
no Python, Node, Go, Bash or Make. Cover identity, layout, paper and palette live in one config.

Use `theme:` on journal entries and indexes, or the reusable `theme-config`
helper for other templates. The [journal theme guide](docs/journal-themes.md)
explains the seven palettes and keeping config as minimal overrides so updated
Satz defaults can take effect.
