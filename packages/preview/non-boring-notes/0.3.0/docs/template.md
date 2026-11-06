# Template reference

[Back to README](../README.md)

`template` is the main entry point of the package. It builds the title block,
sets up the page, styles headings and code, adds the outlines, and places the
bibliography at the end.

This page documents **v0.3.0**. Every parameter is optional except `body`.

## Quick start

```typst
#import "@preview/non-boring-notes:0.3.0": *

#show: template.with(
  title: [Introduction to Analysis],
  subtitle: [Lecture notes],
  short_title: "Analysis",
  authors: (
    (name: "Ada Lovelace", link: "https://example.com"),
  ),
  creation_date: datetime.today(),
  h1_prefix: "lecture",
  text_lang: "en",
)

= Metric spaces

Start writing here.
```

The `#show: template.with(...)` rule must appear before any content. Everything
that follows it becomes the `body` argument.

The title block is assembled in this order: title, subtitle, description,
abstract, authors, dates, and finally the table of contents and other outlines.
The bibliography is appended after the body.

## Document metadata

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `content` | `"Lecture Notes Title"` | Document title, centered at the top of the first page and set as document metadata. |
| `subtitle` | `content` | `none` | Secondary line below the title. |
| `short_title` | `content` | `none` | Short form used in the page header. Falls back to `title` when `none`. |
| `authors` | `array` | `()` | List of author dictionaries. See below. |
| `description` | `content` | `none` | Short italic description shown below the subtitle. |
| `abstract` | `content` | `none` | Abstract paragraph, prefixed with a localized "Abstract" label. |
| `creation_date` | `datetime` | `none` | Date the document was created. |
| `updated_date` | `boolean` | `true` | Show the date the document was last compiled. |

### Authors

`authors` is an array of dictionaries. `name` is required; `link` is optional and
must be a URL string, not a Markdown link.

```typst
authors: (
  (name: "Ada Lovelace", link: "https://example.com"),
  (name: "Alan Turing"),
),
```

- With no authors, no author line is rendered.
- Names are joined with a localized "and". English also gets a serial comma for
  three or more authors.
- The author line is centered and shown before the dates.

### Dates

`creation_date` is a `datetime` and is rendered with a localized "Created"
label. `updated_date` renders today's date at compile time with a localized
"Last updated" label, so it changes every time the document is rebuilt, not when
the file was edited. Set it to `false` if you want a fixed date.

When both dates are shown they are placed side by side; if only one is shown it
is centered. Setting `creation_date: none` and `updated_date: false` removes the
date block entirely.

The date format follows `text_lang`:

| Language | Format | Example |
| :--- | :--- | :--- |
| `en` | month / day / year | `08 / 11 / 2025` |
| `de` | day.month.year | `11.08.2025` |
| `es`, `it` | day/month/year | `11/08/2025` |
| anything else | falls back to English | `08 / 11 / 2025` |

## Page and layout

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `paper_size` | `string` | `"a4"` | Any Typst paper name, such as `"a4"`, `"a5"`, or `"us-letter"`. |
| `paper_color` | `string` | `"#ffffff"` | Page background color, as a hex string. |
| `text_color` | `string` | `"#000000"` | Body text color, as a hex string. |
| `landscape` | `boolean` | `false` | Flip the page to landscape orientation. |
| `cols` | `integer` | `1` | Number of page columns. Use `2` for two-column notes. |
| `paragraph_indent` | `length` | `1em` | First-line indent. Set to `0pt` to disable indentation. |
| `justify` | `boolean` | `true` | Justify body text. Set to `false` for ragged-right text. |

Page numbers are centered at the bottom and start at `1`.

```typst
#show: template.with(
  title: [Two-column notes],
  paper_size: "us-letter",
  cols: 2,
  paragraph_indent: 0pt,
  justify: false,
)
```

## Typography

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `text_font` | `array` | font stack | Font families for body text, in fallback order. |
| `code_font` | `array` | font stack | Font families for inline and block code. |
| `math_font` | `array` | font stack | Font families for equations. |
| `equation_size` | `length` | `1.1em` | Font size for equations relative to body text. |
| `text_lang` | `string` | `"en"` | Language used for hyphenation, labels, and dates. |

The default font stacks are:

```typst
text_font: ("Charter", "XCharter", "Libertinus Serif", "Linux Libertine", "Source Serif 4", "Georgia", "serif"),
code_font: ("IoskeleyMono Nerd Font", "MonoLisa", "JetBrains Mono", "Fira Code", "Cascadia Code", "monospace"),
math_font: ("Erewhon Math", "Libertinus Math", "STIX Two Math", "New Computer Modern Math", "Cambria Math", "serif"),
```

Typst uses the first installed family in each list and silently falls back to the
next one when a family is missing. Missing fonts produce "unknown font family"
warnings during compilation; they are harmless. A generic family such as
`"serif"` at the end of a list is a fallback, not a font name, and may also
produce a warning.

`text_lang` accepts any Typst language code. Complete labels and date formats
are available for **English (`en`)**, **Spanish (`es`)**, **German (`de`)**,
and **Italian (`it`)**. Other languages fall back to English labels while still
setting the language for hyphenation.

## Headings and numbering

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `heading_numbering` | `string` | `"1.1"` | Numbering pattern for level-2 and deeper headings. |
| `show_prefix` | `boolean` | `true` | Show a localized prefix (for example "Lecture") on level-1 headings. It is also used in the page header when heading numbers are shown. |
| `show_numbering` | `boolean` | `true` | Show heading numbers. |
| `h1_prefix` | `string` | `"lecture"` | Which localized prefix to use for level-1 headings. |
| `math_equation_numbering` | `boolean` | `false` | Number equations by level-1 heading. |

Level-1 headings have their own format. With the defaults, a heading becomes:

```typst
= Introduction
// Lecture 1: Introduction
```

The flags change it like this:

| `show_prefix` | `show_numbering` | Result |
| :--- | :--- | :--- |
| `true` | `true` | `Lecture 1: Introduction` |
| `false` | `true` | `1: Introduction` |
| `true` | `false` | `Lecture: Introduction` |
| `false` | `false` | `— Introduction` |

`show_numbering: false` also removes numbers from level-2 and deeper headings.
It does **not** affect theorem-like boxes: their numbering is independent and
keeps following the heading counters.

`h1_prefix` must be a key in the translation table, not free text. The useful
values are:

| `h1_prefix` | English | Spanish | German | Italian |
| :--- | :--- | :--- | :--- | :--- |
| `"lecture"` | Lecture | Clase | Vorlesung | Lezione |
| `"chapter"` | Chapter | Capítulo | Kapitel | Capitolo |

Any other key from the translation table technically works but produces the
corresponding label. An unknown key stops compilation with a "dictionary does
not contain key" error.

When `math_equation_numbering` is `true`, equations are numbered with the current
level-1 heading and an equation counter, such as `(1.1)`. The counter resets at
each level-1 heading.

## Header and accent

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `fancy_header` | `boolean` | `true` | Show a page header with the document short title and the current level-1 heading. |
| `accent` | `string` | `"#222354"` | Accent color used by the header, links, and the header rule. |

The header does not appear on the first page. It appears on later pages only
after a level-1 heading has been seen, and it contains:

- the short title (or the full title when `short_title` is `none`) on the left;
- the current level-1 heading, with its localized prefix and number when enabled,
  on the right;
- a thin rule in the accent color.

`fancy_header: false` removes the header entirely. `accent` is a hex string; it
does not recolor headings or theorem-like boxes.

## Bibliography

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `bibliography_file` | `path`, `string`, or `none` | `none` | Path to a `.bib` file. |
| `bibstyle` | `string` | `"ieee"` | Built-in `"ieee"` style, or a path to a `.csl` file. |

When `bibliography_file` is set, a "References" section is appended after the
body, separated from the content by a short decorative rule. The heading is
localized and has its numbering disabled. Entries are rendered when cited with
`#cite(<key>)` or `@key`.

Pass a project-root-relative path with `path("/...")`:

```typst
#show: template.with(
  title: [Notes with sources],
  bibliography_file: path("/references.bib"),
  bibstyle: "ieee",
)

= First lecture

The foundations are covered in #cite(<knuth1984>).
```

A bare string such as `"references.bib"` is resolved relative to the template's
own source file inside the installed package, not relative to your document. Use
`path("/references.bib")` (root-relative) or an absolute path to avoid this.

## Outlines

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `toc` | `boolean` | `true` | Add a localized table of contents. |
| `toc_depth` | `integer` | `3` | Maximum heading depth included in the table of contents. |
| `lof` | `boolean` | `false` | Add a localized list of figures. |
| `lot` | `boolean` | `false` | Add a localized list of tables. |
| `lol` | `boolean` | `false` | Add a localized list of listings. |

The outlines appear after the dates and before the body. Each one gets an
unnumbered, localized heading. `lof` and `lot` list standard Typst figures of
kind `image` and `table`; `lol` targets figures of kind `raw`.

> **Known limitation in 0.3.0:** code blocks styled by `codly` are not figures of
> kind `raw`, so `lol: true` usually renders an empty list of listings.

## Body

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `body` | `content` | required | The document content. |

`body` is filled by everything after the `#show` rule, so you never pass it
explicitly. The bibliography, when enabled, is appended after it.

## Minimal template

`minimal_template` is a smaller alternative for assignments and short documents.
It does not create a separate title page, page header, TOC, author list,
abstract, date block, or bibliography. It does apply the theorem-like environment rules, so all
the boxes work.

```typst
#import "@preview/non-boring-notes:0.3.0": *

#show: minimal_template.with(
  title: [Assignment 1],
  subtitle: [Due Friday],
  font_size: 11pt,
)

= Exercise 1

#exercise[Show that $1 + 1 = 2$.]

#solution[By definition.]
```

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `title` | `content` | `""` | Title shown at the top. If empty, no title block is rendered. |
| `subtitle` | `content` | `""` | Subtitle below the title. |
| `text_lang` | `string` | `"en"` | Language for labels and hyphenation. |
| `text_font` | `array` | same stack as `template` | Body font families. |
| `code_font` | `array` | same stack as `template` | Code font families. |
| `math_font` | `array` | same stack as `template` | Math font families. |
| `font_size` | `length` | `11.5pt` | Body font size. |
| `list_numbering` | `string` | `"1.a.i."` | Numbering pattern for enumerated lists. |
| `paragraph_indent` | `length` | `1em` | First-line indent. Set to `0pt` to disable. |
| `body` | `content` | required | The document content. |

`minimal_template` keeps headings unnumbered, but it still advances the heading
counters. Theorem-like boxes therefore number from the headings as usual: the
first exercise under `= Exercise 1` is `Exercise 1.1`. If you also want visible
heading numbers, enable them normally:

```typst
#show: minimal_template.with(title: [Assignment 1])

#set heading(numbering: "1.1")

= Exercise 1

#exercise[Numbered as Exercise 1.1.]
```

## Recipes

### A chapter-based book

```typst
#show: template.with(
  title: [A Short Course],
  h1_prefix: "chapter",
  text_lang: "en",
)

= Foundations
```

### Spanish or German notes

```typst
#show: template.with(
  title: [Apuntes de análisis],
  text_lang: "es",
  h1_prefix: "lecture",
)
```

Switch `text_lang` to `"de"` or `"it"` for German or Italian. Labels, dates, the
table of contents, the header, and theorem-like environments all follow the
language.

### Custom colors and fonts

```typst
#show: template.with(
  title: [Branded notes],
  accent: "#0f766e",
  paper_color: "#fffdf7",
  text_color: "#1f2933",
  text_font: ("Libertinus Serif", "Georgia"),
  code_font: ("JetBrains Mono", "monospace"),
)
```

Fonts that are not installed are skipped, so it is safe to list several
fallbacks.

### Numbered equations

```typst
#show: template.with(
  title: [Analysis],
  math_equation_numbering: true,
)

= Limits

$ lim_(x -> 0) frac(sin x, x) = 1 $
```

The equation is numbered `(1.1)`: lecture 1, equation 1. It resets at the next
level-1 heading.

### Fixed dates

```typst
#show: template.with(
  title: [Archived notes],
  creation_date: datetime(year: 2025, month: 8, day: 11),
  updated_date: false,
)
```

### A figure, a table, and their lists

```typst
#show: template.with(
  title: [Notes with figures],
  lof: true,
  lot: true,
)

#figure(
  image("diagram.png", width: 60%),
  caption: [A diagram.],
)

#figure(
  table(columns: 2, [A], [B]),
  caption: [A table.],
)
```

## Gotchas

- **`h1_prefix` must be a translation key.** Use `"lecture"` or `"chapter"`;
  arbitrary text such as `"module"` raises an error.
- **`updated_date` is the compile date.** It changes on every rebuild unless you
  set it to `false`.
- **Bibliography paths are resolved inside the package.** Prefer
  `path("/references.bib")` over `"references.bib"`.
- **`lol` is usually empty.** `codly` code blocks are not `raw` figures, so the
  list of listings does not pick them up in 0.3.0.
- **Disabling both heading flags leaves an em dash.** With `show_prefix: false`
  and `show_numbering: false`, a level-1 heading renders as `— Introduction`.
- **`show_numbering` does not unnumber theorem-like boxes.** Their counters keep
  following the headings.
- **Missing fonts are warnings, not errors.** Typst falls back to the next family
  in the list.

## See also

- [Theorem-like environments](theorem-like-envs.md)
- [Utilities](utilities.md)
- [Examples showcase](../examples/showcase.typ)
