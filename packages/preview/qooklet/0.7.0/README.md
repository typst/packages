# Qooklet

Qooklet is a Typst template for scientific notes and booklet-style documents. It
provides chapter pages, front matter, localized labels, equation and figure
numbering, theorem environments, CSV tables, and styled code blocks with a small
set of configurable TOML files.

## Features

- Note mode and booklet mode:
  - note mode is the default and is useful for single chapters or lecture notes;
  - booklet mode is activated after `cover()` is called and enables book-like
    front matter, part pages, chapter pages, and appendix pages.
- Book structure helpers:
  - `cover()`, `epigraph()`, `preface()`, `contents()`, and `part-page()`;
  - `chapter()` for normal chapters;
  - `appendix()` for appendices.
- Automatic numbering:
  - equations are numbered by chapter or appendix;
  - figures and tables use localized supplements;
  - references are formatted through the template style.
- Scientific writing utilities:
  - theorem-like environments from
    [theorion](https://github.com/OrangeX4/typst-theorion);
  - running headers through
    [hydra](https://github.com/tingerrr/hydra);
  - styled raw code blocks through
    [codly](https://github.com/Dherse/codly).
- Configurable labels, fonts, page sizes, spacing, and language through TOML.

## Installation

### From Typst Universe

```typst
#import "@preview/qooklet:0.6.2": *
```

### From a Local Checkout

Clone this repository into Typst's local package directory:

- Linux:
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS: `~/Library/Application Support/typst/packages/local`
- Windows: `%APPDATA%/typst/packages/local`

Then import the local package:

```typst
#import "@local/qooklet:0.1.0": *
```

The local package keeps the version at `0.1.0` for development convenience.

## Quick Start

### Note Mode

Use note mode when you only need a chapter-based document without cover pages or
front matter.

```typst
#import "@preview/qooklet:0.6.2": *

#let info = (
  title: "Qooklet Note",
  author: "Your Name",
  footer: "Qooklet Note",
  header: "",
  lang: "en",
)

#chapter(
  title: "Bellman Equation",
  info: info,
)[

= Bellman Equation

Your content starts here.
]
```

![Note mode example](https://raw.githubusercontent.com/ivaquero/typst-qooklet/refs/heads/main/example.png)

### Booklet Mode

Calling `cover()` switches the document to booklet mode.

```typst
#import "@preview/qooklet:0.6.2": *

#let info = (
  title: "Qooklet Booklet",
  author: "Your Name",
  footer: "Qooklet Booklet",
  header: "",
  lang: "en",
)

#cover(info, date: datetime.today())

#epigraph(info: info)[
  A short quote or motto.
]

#preface(info: info)[
  Preface content.
]

#contents(depth: 2, info: info)

#part-page("Main Text", info: info)

#chapter(
  title: "First Chapter",
  info: info,
)[

= First Section

Chapter content.
]

#part-page("Appendix", info: info)

#appendix(
  title: "Supplementary Material",
  info: info,
)[

= Additional Notes

Appendix content.
]
```

![Booklet mode example](https://raw.githubusercontent.com/ivaquero/typst-qooklet/refs/heads/main/example-book.png)

## Configuration

Most public functions accept `info`, `styles`, or `names` arguments. The default
values are loaded from `0.1.0/config`.

### Document Info

`info` controls metadata and language. It is commonly passed to `cover()`,
`preface()`, `contents()`, `part-page()`, `chapter()`, and `appendix()`.

```typst
#let info = toml("config/info.toml").example
```

```toml
[example]
    title = "Your Booklet Name"
    author = "Your Name"
    footer = "Footer Text"
    header = "Header Text"
    lang = "en" # "en" or "zh" by default
```

### Localized Names

Qooklet includes English and Chinese labels by default. Add another language by
creating a compatible names table and passing it to the style functions.

```toml
[sections.fr]
    preface = "Préface"
    chapter = "Chapitre"
    content = "Table des matières"
    appendix = "Annexe"
    bibliography = "Bibliographie"

[blocks.fr]
    algorithm = "Algorithme"
    table = "Tableau"
    figure = "Figure"
    equation = " Eq. "
    rule = "Règle"
    law = "Loi"
```

```typst
#let info = toml("config/info.toml").example
#let names = toml("config/names.toml")

#chapter(
  title: "Chapitre 1",
  info: info,
  names: names,
)[
  ...
]
```

Make sure `info.lang` matches a language key in `names` and `styles`.

### Visual Styles

`styles` controls page sizes, spacing, font sizes, and font families. The font
platform can be `windows` or `macos`; any other value fails fast. The default is
Windows. On macOS, compile with `--input qooklet-font-platform=macos` to prefer
macOS system fonts.

```toml
[paper]
    note = "a4"
    booklet = "iso-b5"

[spaces]
    par-indent = 2
    par-leading = 1
    par-spacing = 1
    list-indent = 1.2
    block-above = 1
    block-below = 1
    contents-indent = 1.2

[sizes]
    chapter = 24
    chapter-index = 50
    cover = 36
    author = 24
    date = 18
    epigraph = 16
    preface = 22
    contents = 22
    part = 36
    heading-1 = 16
    heading-2 = 14
    heading-3 = 12
    heading-4 = 10.5
    context = 10.5
    header = 8
    footer = 8

font-platform = "windows"

[font-roles.en]
    default = "text"
    chapter = "display"
    context = "text"
    math = "latin"

[font-roles.zh]
    default = "cjk-song"
    chapter = "cjk-kai"
    context = "cjk-song"
    math = "cjk-kai"

[font-roles.cjk-latin]
    default = "latin"

[fonts.macos]
    display = "Palatino"
    text = "Georgia"
    latin = "Times New Roman"
    cjk-kai = "Kaiti SC"
    cjk-song = "Songti SC"

[fonts.windows]
    display = "Palatino Linotype"
    text = "Georgia"
    latin = "Times New Roman"
    cjk-kai = "KaiTi"
    cjk-song = "SimSun"
```

See `0.1.0/src/config/styles.toml` for all available roles.

```typst
#let styles = toml("config/styles.toml")

#chapter(
  title: "Custom Styled Chapter",
  styles: styles,
)[
  ...
]
```

## API Reference

### Structure

- `cover(info, date: datetime.today(), styles: default-styles)`: creates a cover
  page and activates booklet mode.
- `epigraph(info: default-info, styles: default-styles)[body]`: creates an
  epigraph page.
- `preface(info: default-info, styles: default-styles, names: default-names)[body]`:
  creates a preface page.
- `contents(depth: 1, info: default-info, styles: default-styles)`: creates a
  table of contents. In note mode, `depth: 1` lists first-level headings and
  `depth: 2` also lists second-level headings. In booklet mode, `depth: 1` lists
  chapter and appendix titles, and `depth: 2` also lists first-level headings.
- `part-page(title, info: default-info, styles: default-styles)`: creates a part
  divider page.

### Styles

- `chapter(title: "", info: default-info, styles: default-styles, names: default-names, outline-on: false, heading-depth: 3)[body]`:
  applies chapter layout, headers, footers, heading styles, numbering, references,
  and theorem styling.
- `appendix(...)`: same as `chapter()`, but uses appendix numbering.
- `chapter-style(...)` and `appendix-style(...)`: compatibility helpers for older
  documents. They use a safer, limited style path for repeated `#show` rules.
  Prefer `chapter()` and `appendix()` for full styling in new multi-chapter
  documents.
- `front-matter-style(styles: default-styles)[body]`: styles front matter pages.
- `cover-style(styles: default-styles)[body]`: applies cover/booklet page style.
- `contents-style(depth: 1, lang: "en", names: default-names, styles: default-styles)[body]`:
  lower-level table-of-contents style helper.

### Tables

`tableq(data, k, inset: 0.3em, stroke-color: rgb("000"))` renders flattened CSV
data as a centered table using Qooklet's three-line style.

```typst
#let data = csv("data.csv")

#figure(
  tableq(data, 5, inset: 0.31em),
  caption: "Dataset Summary",
  supplement: "Table",
  kind: table,
)
```

Available stroke helpers:

- `table-three-line(stroke-color)`: three-line table style.
- `table-no-left-right(stroke-color)`: grid style without left and right borders.

Use the stroke helpers directly with Typst's built-in `table` when you need more
control than `tableq()` exposes.

### Code Blocks

`code(text, lang: "python", breakable: true, width: 100%)` renders a styled raw
code block from a string.

```typst
#let compose = read("docker-compose.yml")
#code(compose, lang: "yaml")
```

## Examples

- [`examples/example.typ`](examples/example.typ): a compact note-mode example.
- [`examples/example-book.typ`](examples/example-book.typ): a booklet-mode
  tutorial and regression example.

## Credits

Qooklet is inspired by
[haobook](https://github.com/ParaN3xus/haobook) by @ParaN3xus.

Thanks also to the creators of
[hydra](https://github.com/tingerrr/hydra),
[codly](https://github.com/Dherse/codly), and
[theorion](https://github.com/OrangeX4/typst-theorion).
