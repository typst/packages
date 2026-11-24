# Package reference

Use this page to look up an option or resolve a specific question.
For installation, a quick start, and rendered examples, see the [README](../README.md).

- [Configure the document](#configure-the-document)
- [Format and page settings](#format-and-page-settings)
- [Authors and affiliations](#authors-and-affiliations)
- [Abstract, keywords, and CCS](#abstract-keywords-and-ccs)
- [Language and translations](#language-and-translations)
- [Publication metadata](#publication-metadata)
- [Receipt history and badges](#receipt-history-and-badges)
- [Submission and version settings](#submission-and-version-settings)
- [Citations and bibliographies](#citations-and-bibliographies)
- [Tables](#tables)
- [Theorems and acknowledgments](#theorems-and-acknowledgments)
- [Other document helpers](#other-document-helpers)
- [Special formats](#special-formats)
- [Corrections / `fix-quirks`](#corrections)
- [Compatibility](#compatibility)

## Configure the document

Import the public API and put one show rule before your content:

```typst
#import "@preview/faithful-acmart:0.2.0": *
#show: acmart.with(format: "acmsmall", nonacm: true)

= Introduction
Your paper starts here.
```

The tables below describe arguments to `acmart.with(...)` unless another function is named.
Examples containing only a show rule replace the rule in your paper; examples containing body content go after it.
Keep one `acmart` show rule and add options to it rather than stacking several document styles.

Typst values used here include strings (`"plain text"`), formatted content (`[some *text*]`), arrays (`("one", "two")`), and dictionaries (`(name: "Ada", country: "UK")`).
Use `none` to omit an optional value where supported.
`auto` asks the package to derive a value; it is not interchangeable with `none`.

## Format and page settings

See the [format list](../README.md#choose-a-format) for the available layouts.

| Option | Meaning |
|---|---|
| `format` | Selects the layout; defaults to `"manuscript"`. |
| `font-size` | `auto` uses the format's size; explicit choices are `8pt`, `9pt`, `10pt`, `11pt`, and `12pt`. |
| `title`, `subtitle` | Text or content for the paper title. With `title: none`, no title block is printed. |
| `title-note`, `subtitle-note` | Optional notes attached to the title or subtitle. |
| `short-title`, `short-authors` | Running-head text; `auto` derives it from the title and authors. |
| `print-folios` | Whether to print page numbers. `auto` follows the format and conference metadata; `review: true` enables them. |
| `start-page` | Positive integer for the first page number; omitted by default. |
| `screen` | Colors links when true; some journals enable this automatically. |
| `url-break-on-hyphens` | Allows breaks at hyphens in links by default; set false to prevent them. |

An explicit `font-size` selects the corresponding acmart size step, including its derived font sizes and spacing.
Most papers should retain the format's default size.

## Authors and affiliations

`authors` is an ordered array of dictionaries.
Each author requires `name`; other fields are optional.

| Author field | Shape and effect |
|---|---|
| `name` | String or content. Use a string to include the name in PDF author metadata. |
| `email` | Email address as a string. |
| `orcid` | Identifier or full URL as a string; links the author's name. |
| `affiliation` | One affiliation dictionary or an array of them. |
| `note` | Content or an array of notes. Identical notes share a mark. |
| `corresponding` | Boolean; at most one author can be marked as corresponding. |

Affiliation fields are `institution`, `department`, `city`, `state`, and `country`.
Proceedings author blocks also support `position`, printed before the institution.
Every supplied affiliation requires a nonempty `country`.

```typst
#show: acmart.with(
  format: "acmsmall",
  nonacm: true,
  title: "Your paper's title",
  authors: ((
    name: "Ada Lovelace",
    email: "ada@example.org",
    orcid: "0000-0002-1825-0097",
    corresponding: true,
    affiliation: (
      (institution: "Analytical Engine Institute", city: "London", country: "UK"),
      (institution: "Example Research Institute", city: "Paris", country: "France"),
    ),
    note: [Work performed while visiting the second institution.],
  ),),
)
```

The contact block preserves the order in which email, affiliations, and affiliation fields are declared.
For a shared affiliation in a journal title block, put the affiliation on the last author in the group; see the [README example](../README.md#add-authors-and-paper-metadata).
For proceedings, `authors-per-row` sets the number of authors per row; `0` chooses automatically.

| Related option | Meaning |
|---|---|
| `authors-addresses` | `auto` derives the contact block from authors; `none` suppresses it; content replaces it. |
| `thanks` | A note or array of notes in the front-matter footnotes. |
| `editors` | Array of editor names for the proceedings reference strip. |

## Abstract, keywords, and CCS

These options describe the paper's content and appear in its front matter:

| Option | Shape |
|---|---|
| `abstract` | Formatted content; omitted by default. |
| `keywords` | An array of keywords, or text/content ready to print. String values also populate PDF keywords. |
| `ccs` | An array of `(significance, area, concept)` triples, or a raw block/string containing the ACM CCS tool's output. |
| `print-ccs` | Whether to print CCS concepts; true by default. |
| `teaser` | Content for a wide illustration in the front matter, typically a `figure`. |

```typst
#show: acmart.with(
  format: "sigconf",
  nonacm: true,
  title: "Your paper's title",
  abstract: [Write a short summary of your paper here.],
  keywords: ("ACM", "Typst"),
  ccs: ((500, "Mathematics of computing", "Graph algorithms"),),
)
```

Alternatively, paste the output of the [ACM CCS tool](https://dl.acm.org/ccs) into a raw block:

````typst
#show: acmart.with(
  title: "Your paper's title",
  nonacm: true,
  ccs: ```
\ccsdesc[500]{Mathematics of computing~Graph algorithms}
```,
)
````

The parser accepts complete tool output, including CCSXML.
If both XML and `\ccsdesc` commands are present, the commands take precedence.

## Language and translations

`language` takes one of `"english"`, `"french"`, `"german"`, or `"spanish"`.
It selects the main text language and localized labels.
Omitting it uses English with the default American spelling of “Acknowledgments”; explicit `"english"` uses “Acknowledgements”, following acmart's Babel behavior.

`translations` is a dictionary keyed by secondary language names.
Each value may contain `title`, `subtitle`, `keywords`, and `abstract`.
Supply translations yourself; the package arranges and labels them but does not translate text.
Do not include the main language in this dictionary.

```typst
#show: acmart.with(
  format: "acmsmall",
  nonacm: true,
  language: "english",
  title: "Your paper's title",
  abstract: [This example includes a French translation.],
  translations: (french: (
    title: "Le titre de votre article",
    abstract: [Cet exemple comprend une traduction française.],
    keywords: ("ACM", "Typst"),
  )),
)
```

## Publication metadata

Supply the identifiers and publication details assigned to your paper:

| Option | Meaning |
|---|---|
| `journal` | ACM journal code, such as `"JACM"` or `"TOG"`; omitted by default. |
| `acm-volume`, `acm-number` | Volume and issue; both have placeholder defaults. |
| `acm-article` | Article number, if assigned. |
| `acm-year`, `acm-month` | Publication year and numeric month. If omitted, they use the compile date. |
| `doi` | Bare DOI, without `https://doi.org/`; `none` suppresses it. The default is a placeholder. |
| `conference` | Dictionary described below; `auto` supplies acmart's placeholders for proceedings formats, and `none` suppresses conference metadata. |
| `booktitle` | Proceedings title. If omitted, it is derived from `conference.name` and `conference.short`. |
| `isbn` | Proceedings ISBN; the default is a placeholder. |
| `print-acm-reference` | `auto` normally prints the ACM Reference Format block, except with `nonacm` or `acmcp`. An explicit boolean overrides that choice. |

For a proceedings paper:

```typst
#show: acmart.with(
  format: "sigconf",
  title: "Your paper's title",
  authors: ((name: "Ada Lovelace", affiliation: (country: "UK")),),
  conference: (
    name: "Example Conference",
    short: "Example '26",
    date: "July 6–8, 2026",
    venue: "London, UK",
  ),
  booktitle: [Proceedings of the Example Conference],
  acm-year: 2026,
  acm-month: 7,
  doi: "10.1145/nnnnnnn.nnnnnnn",
  isbn: "978-x-xxxx-xxxx-x",
)
```

The conference details, DOI, and ISBN above are placeholders.
Use the values provided for your paper.
Supplying conference metadata can also change the reference-strip layout in a journal format.

### Copyright notices

`copyright` chooses the notice text; it does not grant a license or determine which publishing agreement applies to your paper.
Use the mode specified by your publication instructions.

| Option | Meaning |
|---|---|
| `copyright` | Notice mode; defaults to `"acmlicensed"`. |
| `copyright-year` | Year in the notice; defaults to `acm-year`. |
| `cc-type` | With `copyright: "cc"`, selects `"by"`, `"by-sa"`, `"by-nd"`, `"by-nc"`, `"by-nc-sa"`, `"by-nc-nd"`, or `"zero"`. |
| `cc-version` | `"3.0"` or `"4.0"` for the CC licenses; defaults to `"4.0"`. CC0 always uses its 1.0 designation. |

The notice modes are `"none"`, `"acmcopyright"`, `"acmlicensed"`, `"rightsretained"`, `"usgov"`, `"usgovmixed"`, `"cagov"`, `"cagovmixed"`, `"licensedusgovmixed"`, `"licensedcagov"`, `"licensedcagovmixed"`, `"othergov"`, `"licensedothergov"`, `"iw3c2w3"`, `"iw3c2w3g"`, and `"cc"`.
Use the string `"none"`, rather than Typst's `none`, for no copyright notice.

## Receipt history and badges

`received` prints receipt history after the document body.
Use an ordered array of `(stage, date)` pairs:

```typst
#show: acmart.with(
  format: "acmsmall",
  nonacm: true,
  received: (
    ("", "20 February 2026"),
    ("revised", "12 March 2026"),
    ("accepted", "5 June 2026"),
  ),
)

= Conclusion
The receipt history appears after the document body.
```

An empty stage becomes “Received” for the first entry and “revised” thereafter.
Dates are printed as supplied; they are not parsed as bibliographic dates.
You can also pass fully formatted content to `received` if you need different wording.

`badges` takes a dictionary with optional `left` and `right` content, placed at the left and right of the first-page header.
For example:

```typst
#show: acmart.with(
  format: "acmsmall",
  nonacm: true,
  title: "Your paper's title",
  badges: (
    left: box(stroke: 0.5pt, inset: 4pt)[Left badge],
    right: box(stroke: 0.5pt, inset: 4pt)[Right badge],
  ),
)
```

The boxes are placeholders showing the positions.
Replace them with image content, for example `image("badge.svg", width: 2cm)`, when you have a badge to display.

## Submission and version settings

These options default to false unless stated otherwise.

| Option | Effect |
|---|---|
| `anonymous` | Hides author identities in front matter and PDF author metadata; suppresses acknowledgments. Body content is only replaced where wrapped in `anon`. |
| `submission-id` | Identifier shown in anonymous front matter; omitted by default. |
| `review` | Enables line numbers and page numbers, and applies acmart's review list spacing. |
| `author-draft` | Enables review line numbers, a draft watermark, and a timestamp. Set `review: true` too if you need its page-number and list-spacing behavior. |
| `timestamp` | Adds the compile date to the running page decoration. |
| `nonacm` | Suppresses ACM publication notices and normally the ACM Reference Format block; also affects list spacing. A Creative Commons notice is retained when `copyright: "cc"`. |
| `author-version` | Omits the standard permission paragraph and, outside manuscript format, prints the author-version notice. |
| `screen` | Uses colored links. |

`anon(body, substitute: "ANONYMIZED")` replaces its body only in anonymous mode.
For example, `#anon(substitute: [Repository withheld])[Our repository URL]`.

### Compatibility options

These LaTeX settings are accepted without effect or explicitly rejected:

| Setting | Behavior |
|---|---|
| `balance`, `pbalance` | Accepted but ineffective; they do not balance columns. |
| `natbib` | Accepted but ineffective; choose `bib-backend` to select bibliography processing. |
| `acmthm` | Accepted but ineffective; theorem helpers remain available. |
| `draft: true` | Rejected. LaTeX's overfull-line markers are unsupported. Use `author-draft` for a draft watermark. |

## Citations and bibliographies

Keep the wildcard import so that `cite` and `bibliography` refer to this package's wrappers.
Set these options on `acmart.with(...)`:

| Option | Values and default |
|---|---|
| `bib-backend` | `"bibtex"` (default) follows ACM's BibTeX style; `"biblatex"` follows ACM's BibLaTeX styles; `"typst"` uses Typst's native CSL implementation. |
| `cite-style` | `"numeric"` (default) or `"author-year"` for the custom backends. Has no effect with `bib-backend: "typst"`, where the native style controls citations. |

### Bibliography input and arguments

Call `bibliography("refs.bib")` once, usually near the end of the paper.
The custom `"bibtex"` and `"biblatex"` backends read `.bib` files directly.
The native `"typst"` backend uses Typst's bibliography reader.

| Argument or behavior | `"bibtex"` / `"biblatex"` | `"typst"` |
|---|---|---|
| One file | A relative or project-absolute path | Forwarded to Typst |
| Multiple files | One array of project-absolute paths, e.g. `bibliography(("/a.bib", "/b.bib"))` | Forwarded to Typst |
| `title` | `auto` uses the localized heading; content replaces it; `none` omits it | Forwarded to Typst |
| `full: true` | Unsupported; include individual entries with `cite(..., form: none)` | Lists uncited entries too |
| `style` | Must remain `auto`; reference formatting comes from the ACM backend | Accepts a native bibliography style |
| Other named arguments | Rejected | Forwarded to Typst |

A project-absolute path begins with `/` and is relative to the Typst project root, not the computer's filesystem root.

### Citation forms

For the custom backends, `cite` accepts one or more keys, as strings or labels, and the named arguments `form` and `supplement`.
`cite(style: ...)` is not supported by those backends.

| Call | Purpose |
|---|---|
| `@key` or `#cite(<key>)` | Ordinary citation |
| `#cite(<key-a>, <key-b>)` | Several sources in one citation |
| `#cite-text(<key>)` | Author in the sentence; equivalent to `form: "prose"` |
| `#cite-author(<key>)` | Author label; equivalent to `form: "author"` |
| `#cite-year(<key>)` | Year; equivalent to `form: "year"` |
| `#cite(<key>, form: "full")` | Full reference in the body |
| `#cite(<key>, form: none)` | Include the entry in the bibliography without printing a citation here |

Use `@key[p. 42]` or `#cite(<key>, supplement: [p. 42])` for a page locator.
The `"full"` and `none` forms do not accept a supplement.
The BibTeX backend follows natbib in dropping supplements from numeric author-only and year-only citations, unless [`fix-quirks`](#corrections) is enabled.

Additional single-key helpers are `cite-alt` (prose citation without the outer year brackets), `cite-yearpar` (bracketed year), and `short-cite` (bracketed year for author–year citations, ordinary citation for numeric citations).
They take an optional `supplement`.
With the native backend, `cite-alt` maps to prose, `cite-yearpar` to year, and `short-cite` to a normal citation; the extra ACM distinctions are not reproduced.
Native multi-key calls render separate Typst citations rather than one custom ACM group.

### TeX in bibliography fields

The custom backends interpret common TeX accents, character commands, text formatting, and a bounded set of inline math commands.
Unknown commands produce an error.
Keep capitalization-protecting braces in `.bib` fields; they also affect names and sorting.

Use `tex-render` to expand a custom command before the default renderer sees it:

```typst
#show: acmart.with(
  nonacm: true,
  tex-render: s => default-tex-render(s.replace("\\myunit", "kg")),
)
```

The callback receives a field string and returns Typst content.
It changes field presentation; sorting and plain-text citation labels still use the built-in parser.

The BibLaTeX backend supports partial dates, full calendar dates, explicit intervals (including open ends), uncertain or approximate dates, seasons, and unspecified components such as `200X` and `2005-XX`.
It also supports negative years.
These are bibliography field values, separate from the paper's `acm-year`, `acm-month`, and `received` metadata.

## Tables

`tabular` wraps a Typst table and adds booktabs-style spacing around horizontal rules.
Use it inside `figure` for a numbered caption; see the [source and rendered example](../README.md#tables).

| Helper or option | Use |
|---|---|
| `toprule()`, `bottomrule()` | Heavier outer rules |
| `midrule()` | Lighter separator rule |
| `columns` | Pass directly to `tabular`, so it can determine row boundaries. |
| `header-rows` | Number of leading rows to tag as headers when safe to infer; defaults to 1. Set 0 for no inferred header. |
| `table.header(...)` | Explicit header for a complex table; takes precedence over inference. |

Pass `columns` directly to `tabular`; header inference cannot read an inherited `set table(columns: ...)` setting.
For positioned cells or a span crossing the intended header boundary, provide a `table.header(...)` explicitly.
The rule helpers accept arguments to Typst's `table.hline`, such as a column range or custom stroke.

## Theorems and acknowledgments

The package provides two groups of numbered environments:

| Environments | Body style |
|---|---|
| `theorem`, `lemma`, `corollary`, `proposition`, `conjecture` | Italic |
| `definition`, `example`, `remark` | Upright |

All share one counter, reset by each numbered level-one heading.
Before the first numbered section, the section part of the number is zero.

Each environment takes content as its body, optional `name` for a parenthetical name, and optional `title` to replace the environment label.
For example, `#lemma(name: "A useful identity")[...]` prints a numbered lemma with that name.
Put a Typst label after the environment and use `@label` to refer to it.
See the [theorem source and rendered output](../README.md#theorems-and-proofs).

`proof(body, name: none)` supplies a localized heading and an end-of-proof square.
Set `name` for a heading such as `[Proof of the lemma]`.

`acks(body)` adds an unnumbered acknowledgment heading and hides the section in anonymous mode.
`acknowledgments` is an alias.

## Other document helpers

Use these helpers for headings, grant information, and typesetting logos:

| Helper | Purpose |
|---|---|
| `part(body)` | Unnumbered display heading in acmart's paragraph-heading style |
| `noindentparagraph(body)` | Run-in paragraph heading without its usual indentation |
| `grantsponsor(id, name, url)` | Prints the sponsor name; the ID and URL are not displayed. |
| `grantnum(id, num, url: none)` | Prints a grant number, with a linked URL when supplied. |
| `latex-logo`, `tex-logo`, `bibtex-logo` | Content values for the corresponding typesetting logos |
| `acm-orange`, `acm-purple` | Color values used by the package |

Ordinary Typst headings, lists, equations, figures, and footnotes receive the format's styles through the document show rule.
For a numbered figure, wrap the illustration in `figure` and place a label after it:

```typst
#figure(
  rect(width: 5cm, height: 2cm, fill: luma(230)),
  caption: [A sample illustration.],
) <sample-figure>

Refer to the figure by its label: @sample-figure.
```

Replace the rectangle with an image or diagram.
Use `placement: top` on `figure` to float it to the top of a page or column; in a two-column format, `scope: "parent"` makes a floating figure span both columns.

## Special formats

The following options and helpers apply to individual ACM formats.

### EngageCSEdu

For `format: "acmengage"`, supply `engage-metadata` as ordered label/value pairs:

```typst
#show: acmart.with(
  format: "acmengage",
  nonacm: true,
  title: "An introduction to Typst",
  engage-metadata: (
    ("Course", "Technical writing"),
    ("Topic", "Figures and tables"),
  ),
  abstract: [Students add a figure and a table to a document.],
)
```

### Cover-page articles

`format: "acmcp"` requires `acmcp-logo`, normally `image("journal-logo.png")`.
The journal logo is not bundled.

| Option | Meaning |
|---|---|
| `article-type` | `"Research"`, `"Review"`, `"Discussion"`, `"Invited"`, or `"Position"`; defaults to `"Research"`. |
| `code-data-link` | Content for code and data links in the cover infobox |
| `contributions` | Content describing contributions in that infobox |

### Margin notes

The `"sigchi-a"` format provides a margin-note column.
Use `sidebar(body)` for a note, or wrap a `figure` in `marginfigure(body)` or `margintable(body)` for a centered margin figure or table.
`fulltextwidth(body)` extends content across the body and margin-note column.
These helpers require `sigchi-a`.

## Compatibility

The package targets the bundled LaTeX `acmart` 2.21 sources.
It compares representative documents against LaTeX, but does not guarantee identical output for every paper.

### Corrections

Set `fix-quirks: true` to apply the following corrections to inherited LaTeX behavior.
The option is off by default.

| Correction | Applies to |
|---|---|
| Normalize `doi.org` and `dx.doi.org` URLs to avoid doubling the resolver prefix. | The document's `doi` option; BibLaTeX references |
| Begin an `inbook` reference with its author, when present, and place the editor after the book title. | BibLaTeX references |
| Omit empty date parentheses and their separator. | BibLaTeX references |
| Avoid adding a second period after a punctuated author, editor, or organization at the start of a reference. | BibLaTeX author–year references |
| Keep supplied locators on author-only and year-only numeric citations. | BibTeX citations |
| Insert a space between `See` and an article's cross-reference. | BibTeX references |
| Recognize punctuation after uppercase letters and inside closing quotes, so `UK.` keeps one period. | Headings, proof names, author notes, and contact information |

The option does not change Typst's native bibliography formatting.

### Layout

These differences affect page layout and document appearance:

| Area | Difference or limitation |
|---|---|
| Line and page breaks | Typst lacks TeX's stretchable page glue, final-column balancing, and microtype font expansion and protrusion. Pages remain ragged at the bottom; breaks can differ. |
| Math | Uses Libertinus Math and approximate display spacing, without TeX's short-display skips or exact math metrics. |
| Baselines, captions, floats, footnotes | Small spacing differences can arise from the engines' different line-box depths. |
| Wrapped numbered headings | No hanging indent; this preserves tagged-PDF reading order. |
| Term lists and quotations | Term lists do not reproduce acmart's label-column geometry; the separate LaTeX quotation layout is unsupported. |
| Paragraphs after displays or code blocks | Continue without indentation. Add explicit horizontal spacing if an indent is needed. |
| Widow and orphan control | Uses Typst's layout costs, which do not exactly match TeX's penalties. |
| `sigchi-a` | Footnotes stay in the body. Margin notes can overlap at the same anchor; use separate paragraphs for consecutive notes. |
| `acmcp` | Long URLs and email addresses wrap differently in the narrow infobox. |
| Front-matter marks | Use consistent superscript sizes rather than LaTeX's oversized section-sign mark; corresponding-author marks have a fixed order. |
| Timestamp and PDF metadata | The timestamp contains a date without the time of day. Typst's document API does not provide PDF Subject metadata. |

### Bibliography fidelity

The custom backends reproduce ACM reference styles with the following limits:

- BibLaTeX sorting approximates Unicode collation; accent-only ties, punctuation, and unsupported character commands can sort differently.
- BibLaTeX citation disambiguation can expand name lists, but that expansion does not propagate to long reference-list names or sort keys.
- Punctuation-only initials retain their period throughout a grouped citation; BibLaTeX can omit it after a preceding entry.
- The TeX field renderer supports a subset of commands and inline math.
  In math, `/` becomes a fraction and `\left`/`\right` do not resize delimiters.
  URLs bypass TeX rendering, and plain-text citation labels do not support inline math.
- BibTeX warning diagnostics are not reproduced.
- The native backend uses CSL field mapping and formatting, so its references can differ from both custom ACM backends.

For arguments that are rejected or have no effect, see [compatibility options](#compatibility-options) and [bibliography arguments](#bibliography-input-and-arguments).
To investigate an unexpected rendering difference, use the contributor [comparison workflow](https://github.com/fzaiser/faithful-acmart/blob/v0.2.0/CONTRIBUTING.md#investigating-a-difference).
