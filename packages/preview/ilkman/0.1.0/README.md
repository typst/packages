# ilkman

A modular kit for **books, lecture notes and slides** that share one design language.
Every component is its own `im-` function, sizes come from roles (body, table, code,
inline code), and fonts and colors are applied as **groups** you pick from palettes.

![Ten generative cover styles: waveform, pcm, packet, bits, gitgraph, minimap, neural, solid, topo and halftone](https://raw.githubusercontent.com/ilkermansur/ilkman/v0.1.0/docs/covers.png)

- 📄 `im-doc` — books and notes with a wide left column for side notes
- 🖥️ `im-slides` — presentations built on [Touying](https://typst.app/universe/package/touying)
- 🎨 15 color palettes × 4 font palettes, applied as a whole
- 🧩 `im-code`, `im-table`, `im-grid`, `im-note`, `im-explain`, `im-steps`, …
- 🌊 10 generative cover styles, shared by book covers and title slides
- 🇹🇷 / 🇬🇧 labels in Turkish (`lang: "tr"`, default) or English (`lang: "en"`)

## Quick start

```bash
typst init @preview/ilkman:0.1.0 my-notes
```

or import it into an existing file:

```typst
#import "@preview/ilkman:0.1.0": *

#show: im-doc.with(
  title: [SIP and VoIP Basics],
  author: "ilker",
  lang: "en",
  fonts: "plex",
  colors: "okyanus",
)

#im-cover(style: "waveform")
#im-toc()

= Introduction
Hello, *ilkman*.
```

### Fonts

All default fonts are SIL OFL licensed and available in the Typst web app.
For local use install them from Google Fonts. If a font is missing, Typst falls
back to its embedded fonts and the document still compiles (with a warning).

| `fonts:`  | Body / headings              | Tables                  | Code            |
|-----------|------------------------------|-------------------------|-----------------|
| `mulish`  | Mulish                       | Mulish                  | JetBrains Mono  |
| `plex`    | IBM Plex Sans                | IBM Plex Sans Condensed | IBM Plex Mono   |
| `source`  | Source Serif 4 / Source Sans 3 | Source Sans 3         | Source Code Pro |
| `fira`    | Fira Sans                    | Fira Sans Condensed     | Fira Mono       |

Override single roles and keep the rest of a palette:

```typst
#show: im-doc.with(fonts: (base: "plex", body: "Avenir Next"))
```

### Colors

![Sample pages of the color palettes, each with a heading, colored boxes, a zebra table, a code block and a callout](https://raw.githubusercontent.com/ilkermansur/ilkman/v0.1.0/docs/palettes.png)

`okyanus`, `fiyort`, `gece`, `çelik`, `okabe`, `orman`, `nane`, `zeytin`,
`kiremit`, `kehribar`, `gül`, `bordo`, `lavanta`, `mürdüm`, `grafit`
(ASCII aliases: `celik`, `gul`, `murdum`).

Each palette has five roles — `ink` (text), `primary` (headings, header rows,
solid backgrounds), `accent` (links, highlights), `tint` and `wash` (zebra rows,
boxes, code background). `okabe` is derived from the colorblind-safe Okabe–Ito
set. A custom palette is a dictionary:

```typst
#show: im-doc.with(colors: (primary: rgb("#005f73"), accent: rgb("#ee9b00")))
```

Named fills such as `"blue"`, `"green"`, `"red"`, `"yellow"`, `"orange"`,
`"purple"`, `"teal"`, `"pink"`, `"gray"` are bent toward the active palette and
are **always light**, so text on them stays readable.

### Sizes

Every role is relative to the body size, so slide density changes everything at once.

| Role        | Doc    | Slides |
|-------------|--------|--------|
| Body        | 11pt   | 22pt   |
| H1 / H2 / H3| 20 / 15 / 12.5pt | 40 / 30 / 24pt |
| Table       | 9.5pt  | 18pt   |
| Code block  | 9pt    | 16pt   |
| Inline code | 0.9em  | 0.9em  |
| Caption / note | 9pt | 16pt   |

## Documents

```typst
#show: im-doc.with(
  lang: "tr",             // "tr" | "en"
  fonts: "mulish",
  colors: "okyanus",
  paper: "a4",
  note-column: 1/4,       // left note column; 0 = off
  chapter-label: true,    // "BÖLÜM 1" above H1
  chapter-start: "any",   // "odd" = chapters start on right-hand pages
  par-indent: true,       // indented paragraphs, automatic block spacing
  title: none, subtitle: none, author: none, date: auto, version: none,
  header: (left: none, center: none, right: "chapter"),
  footer: (left: none, center: none, right: "page"),
  header-rule: true,
  footer-rule: false,
  mirror: false,          // swap left/right on even pages (print)
  print: false,           // true = link URLs also as footnotes
)
```

![Three document pages with a chapter heading, a side note with an arrow, a code block, tables, grid boxes and callouts](https://raw.githubusercontent.com/ilkermansur/ilkman/v0.1.0/docs/document.png)

**Header and footer slots** take `"chapter"`, `"section"`, `"title"`, `"author"`,
`"date"`, `"version"`, `"page"`, `"page-total"`, any string or content, a
function `c => ...`, or `none`. `header: none` removes the whole header.

**Numbering**: H1–H3 are numbered (`1`, `1.1`, `1.1.1`), H4 is not. Figures,
tables and listings are numbered per chapter (`Şekil 2.3`). Reference with
`<label>` and `@label`.

| Function | Purpose |
|---|---|
| `im-cover(style: ..)` | Full-page cover without margins (see [Covers](#covers)) |
| `im-toc(depth: 2)` | Table of contents, printed without the note column |
| `im-figures-list()` / `im-tables-list()` | Lists of figures / tables |
| `im-appendix[...]` | Chapters inside are numbered A, B, C |
| `im-explain("term", fill: "yellow")[note]` | Highlighted term + arrow to a note in the left column |

## Components

### `im-code`

````typst
#im-code(
  numbering: true,     // line numbers
  title: "server.py",  // file-name bar
  hl: (3, 5),          // highlighted lines (int, array or range)
  width: 100%,         // or 60%, or auto = as wide as the longest line
  align: "left",       // where the box sits when narrower: left | center | right
  caption: none,       // numbered caption ("Kod 1.2")
)[```py
print("test")
```]
````

Code is always left-aligned inside the box, so indentation is preserved.
On slides, `hl-steps: ((1, 2), (3, 4))` highlights a different set of lines at
each animation step. Inline code uses normal backticks.

> **Why the extra backticks?** A `[...]` block is Typst markup — quotes turn
> into typographic quotes and `#`, `*`, `_` are interpreted. Code must arrive
> as a raw block.

### `im-table`

Two input forms, one function:

````typst
// Text form — fast to type. Rows = lines, cells = "|".
#im-table(fill: "blue", zebra: true)[```
Protocol | Port | Transport
SIP      | 5060 | UDP/TCP
SIPS     | 5061 | TLS
```]

// Cell form — any formatting inside cells.
#im-table(cols: 3)[*Protocol*][Port][Transport][SIP][`5060`][UDP]
````

| Parameter | Default | |
|---|---|---|
| `cols` | `auto` | Column count (text form: widest row) |
| `header` | `true` | First row is the header |
| `fill` | `"primary"` | Color family for header and zebra rows; `none` = plain |
| `zebra` | `true` | Two alternating light tones |
| `align` | `auto` | Numeric columns right, text left; or an alignment / array |
| `widths` | `auto` | e.g. `(1fr, 2fr, auto)` |
| `caption` | `none` | Numbered caption |
| `sep` | `"\|"` | Separator for the text form; escape with `\|` |
| `markup` | `false` | Text form: evaluate cells as Typst markup |

Lines made only of `-`, `|` and `:` are ignored, so Markdown tables can be pasted.

### `im-grid`

```typst
#im-grid("1/1")[left][right]            // two equal columns
#im-grid("1/2")[narrow][wide]           // 1/3 – 2/3
#im-grid("1/1/1", fill: "blue")[A][B][C][D][E][F]   // extra bodies wrap
#im-grid("1/1", fill: ("green", "red"), stroke: true)[Do][Don't]
```

The ratio is a **string** — `(1/2)` would be evaluated to `0.5` by Typst.
Options: `gutter: 1em`, `stroke: none | true | "green" | color`,
`fill: none | "green" | color | array`, `radius: 4pt`, `inset: 0.8em`, `align: top`.
Fills are always kept light.

### Other components

```typst
#im-note(kind: "info")[...]        // info | tip | warn | danger; title: auto | none | [..]
#im-term("SIP")[Session Initiation Protocol]
#im-steps[
  + Install
  + Configure
]
#im-kbd("Ctrl+Shift+P")
#im-img(image("topology.png"), width: 80%, caption: [Topology])
#im-diagram(width: 70%, caption: [Flow])[ /* any drawing: mermaid, cetz, fletcher … */ ]
#im-plot(width: 100%)[ /* e.g. a lilaq plot */ ]
```

`im-img` needs `image("file.png")` or `path("file.png")`: a bare string would be
resolved relative to the package, not to your document. `im-diagram` / `im-plot`
scale whatever you draw with your favourite package to the given width.

## Slides

```typst
#import "@preview/ilkman:0.1.0": *

#show: im-slides.with(
  title: [SIP Basics], author: "ilker",
  fonts: "fira", colors: "okyanus",
  aspect: "16-9",     // or "4-3"
  dense: "mid",       // default density: "low" | "mid" | "high" | number
  mode: "light",      // or "dark"
  progress: true,
  footer: (left: "title", center: none, right: "page"),
)

#im-title-slide(style: "neural")

= Section          // section slide
== First slide     // content slide
- point one
#im-pause
- point two
#im-speaker[Notes for the presenter view.]
```

![Slide deck pages: title slide, section slide, a slide with a code block, a dense text slide and a focus slide](https://raw.githubusercontent.com/ilkermansur/ilkman/v0.1.0/docs/slides.png)

| Function | Purpose |
|---|---|
| `im-slide(title: .., dense: ..)[..]` | Explicit slide; `==` headings also create slides |
| `im-title-slide(style: ..)` | Title slide in any of the 10 cover styles |
| `im-section[..]` | New section (same as `=`) |
| `im-focus[..]` | One big message on a colored slide |
| `im-pause` | Next animation step (Touying `pause`) |
| `im-speaker[..]` | Speaker note |
| `im-dense("high")` | Density from this slide on (put it inside a slide); `auto` resets |

### Density

Text-heavy slide? Shrink everything — body, tables, code and spacing — at once:

| `dense:` | Body | Slide title | Table | Code |
|---|---|---|---|---|
| `"low"` | 25pt | 33pt | 21pt | 18pt |
| `"mid"` | 22pt | 30pt | 18pt | 16pt |
| `"high"` | 17pt | 26pt | 14pt | 12pt |

A number such as `dense: 0.65` is used as a factor. Headings shrink less than body text.

## Covers

![The ten cover styles laid out as 16:9 title slides](https://raw.githubusercontent.com/ilkermansur/ilkman/v0.1.0/docs/title-slides.png)

Ten styles: `waveform`, `pcm`, `packet`, `bits`, `gitgraph`, `minimap`,
`neural`, `solid`, `topo`, `halftone`. The same options work for `im-cover`
and `im-title-slide`.

```typst
#im-cover(
  style: "neural",
  series: "Lecture notes", volume: 1,   // small line above the title
  subtitle: [From protocol to production],
  seed: auto,          // auto = derived from the title; a number = another variation
  art-height: auto,    // share of the page used by the artwork, e.g. 65%
  text-pos: "bottom",  // or "top"
  title-size: auto,
  bg: auto,            // "white" | "primary" | color name | color
  art-color: auto,     // main color of the artwork
  logo: none,          // e.g. image("logo.svg")
  neural: (layers: (8, 12, 12, 4), highlight: none),
)
```

Generated artwork is deterministic: the same title always gives the same cover.

| Style | Options (defaults) |
|---|---|
| `waveform` | `bars: 40`, `shape: "round"`, `mirror: true`, `accent-every: 5` |
| `pcm` | `samples: 24`, `levels: 8`, `show-wave: true`, `stems: true` |
| `packet` | `fields: ("V=2", "PT", "seq", "SSRC")`, `bits: 32`, `ruler: true`, `footer: auto` |
| `bits` | `text: auto` (title), `group: 8`, `highlight: 9` |
| `gitgraph` | `branch: "main"`, `lanes: 4`, `commits: 18`, `merges: 0.3` |
| `minimap` | `lines: 46`, `max-indent: 3`, `viewport: (30%, 50%)` |
| `neural` | `layers: (12, 6, 8, 6, 3)`, `highlight: 2`, `edges: 0.7` |
| `solid` | `rule: false` |
| `topo` | `rings: 9`, `center: (70%, 30%)`, `wobble: 0.15` |
| `halftone` | `grid: 20`, `origin: "top-left"`, `falloff: 1.0` |

Options of styles that are not selected are ignored, so switching styles never breaks.

## Development

```bash
# Link the working copy as a local package, then compile everything
ln -s "$PWD" ~/.local/share/typst/packages/preview/ilkman/0.1.0
tests/run.sh --font-path path/to/fonts
```

## License

MIT. Fonts are not bundled; the default families are licensed under the SIL OFL.
Slides depend on [Touying](https://github.com/touying-typ/touying) (MIT).
