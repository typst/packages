# bypst: BIPS Presentation Template

A 16:9 presentation template for [BIPS](https://www.leibniz-bips.de/) using [Typst](https://typst.app/) and [Touying](https://touying-typ.github.io/). Based on the institutional style from [bips-beamer](http://github.com/bips-hb/bips-beamer).

## Quick Start

```typst
#import "@preview/bypst:0.6.0": *

// Declare presentation info once: config-info() sets the PDF document metadata
// and title-slide() reads these fields, so they need not be repeated.
#show: bips-theme.with(
  config-info(
    title: "Your Presentation Title",
    author: "Your Name",
    institution: bips-en, // or bips-de
    date: datetime.today().display(),
  ),
  // logo: image("path/to/logo.png"),
)

#title-slide()

#bips-slide(title: "Introduction")[
  - Bullet points
  - *Bold* and _italic_ in BIPS blue
  - Math: $s^2 = 1/(n-1) sum_(i=1)^n (x_i - overline(x))^2$

  #pause

  - Revealed on click
]

#thanks-slide(
  contact-author: "Your Name",
  email: "your.email@leibniz-bips.de",
  qr-url: "https://link-to-slides.example.com",
)
```

## Installation

The theme is available from the [Typst package registry](https://typst.app/universe/package/bypst), just import it like any other package:

```typst
#import "@preview/bypst:0.6.0": *
```

Please note that the official BIPS logo is not bundled with the package to avoid licensing concerns.
See below on how to include your local copy of the logo in the slides.

### Local development

To work on the theme itself, clone and install locally:

```sh
git clone https://github.com/bips-hb/bips-typst.git
cd bips-typst
just install
```

Then use the local import instead:

```typst
#import "@local/bypst:0.6.0": *
```

## Slide Types

| Function | Purpose |
|---|---|
| `#title-slide()` | Opening slide with author, institution, date |
| `#bips-slide()` | Content slide with optional title/subtitle (preset over `base-slide`) |
| `#section-slide()` | Section divider |
| `#thanks-slide()` | Closing slide with contact info and optional QR code |
| `#bibliography-slide[]` | References |
| `#empty-slide[]` | Minimal slide without branding (preset over `base-slide`) |
| `#base-slide()` | Flexible base slide with all chrome toggles; use when `bips-slide`/`empty-slide` presets don't cover your layout |

### Content slide options

```typst
#bips-slide(
  title: "Slide Title",
  subtitle: "Optional Subtitle",
  content-align: center + horizon, // center content vertically and horizontally
  text-size: 16pt,                 // override text size for this slide
)[
  Content here
]
```

`content-align` accepts any Typst alignment: `center`, `horizon`, `center + horizon`, etc.

### Authors and affiliations

`#title-slide()` reads `author:` and `institution:` from `config-info()`, so a
single author at one institution needs nothing beyond the [Quick
Start](#quick-start). `institution:` defaults to `bips-en`; set it only for
`bips-de` or an external affiliation.

For several authors, or one author with several affiliations, pass the plural
`authors:` and `institutions:` to `#title-slide()`. `inst(n)` renders the
superscript marker linking an author to the *n*-th entry of `institutions:`:

```typst
#title-slide(
  title: "Collaborative Research",
  authors: (
    "Jane Doe" + inst(1,2),
    "John Smith" + inst(1),
  ),
  institutions: (
    "BIPS",
    "University of Bremen",
  ),
)
```

Unlike the singular forms, the plurals are not read from `config-info()`.
Putting them there has no effect.

### Title slide sizes

Each line of the title slide takes its own size override, e.g. a larger name for a single-speaker talk:

```typst
#title-slide(author-size: 26pt)
```

The defaults are `title-size: 26pt`, `subtitle-size: 20pt`, `author-size: 20pt`, `institution-size: 18pt` and `date-size: 16pt` (`date-size` also applies to `occasion`).
`author-size` and `institution-size` apply to the plural `authors:` and `institutions:` as well.

### Section slides

```typst
#section-slide("Results")
#section-slide("Methods", show-logo: false)
```

## Layout Helpers

```typst
// Two columns (equal by default)
#two-columns[Left][Right]
#two-columns(columns: (2fr, 1fr), gutter: 2em)[Wide][Narrow]

// Three columns
#three-columns[A][B][C]
```

## Utilities

### Color helpers

```typst
#blue[text]  #orange[text]  #green[text]  #gray[text]  #logo-blue[text]
```

### Callout boxes

```typst
#callout[Plain shaded box]                  // no type: neutral default
#callout(type: "note")[Information]
#callout(type: "tip")[Helpful hint]
#callout(type: "warning")[Caution]
#callout(type: "important")[Critical]
#callout(type: "tip", title: "Custom Title")[With a title]
#callout(type: "note", icon: [→])[Custom icon]
```

The icon style is set once for the deck with `bips-theme(callout-icons: ...)`:

| Value | Icons | Needs |
|-------|-------|-------|
| `"symbol"` (default) | ℹ ✓ ⚠ ‼ in the callout colour | nothing: Typst's bundled fonts cover them, though their design varies with the fonts installed |
| `"emoji"` | 📝 💡 ⚠️ ❗ | an emoji font, otherwise they render as empty boxes |
| `"drawn"` | coloured shapes with `i`, a check mark, `!` | nothing, and identical on every machine |
| `none` | no icons | |

A per-callout `icon:` overrides the style and takes any content.

Per-type shorthands are available: `#callout-note[…]`, `#callout-tip[…]`,
`#callout-warning[…]`, `#callout-important[…]` (each takes an optional `title:`).

### Cards

A titled panel for framing a definition, a result, or an aside — the Beamer
theorem-block shape. Heavier than a callout and icon-free, so the two read as
different things.

```typst
#card(title: "Definition")[The estimand is ...]
#card(title: "Result", color: bips-green)[Recolors bar and body tint]
#card[Without a title, a plain shaded panel]
#card(title: "Custom", fill: luma(230), title-color: white)[Explicit body fill]
```

`color:` sets the title bar and, unless `fill:` says otherwise, a light tint of
it for the body. The bar's text is white by default, so pass a dark `color`
(or override `title-color:`).

### Citations

natbib-style convenience wrappers over Typst's `cite()`. They inherit the
document's citation style and need a `bibliography()` somewhere in the document
(exactly like bare `@label`).

```typst
#citet(<label>)   // textual: "Author (Year)"   (natbib \citet)
#citep(<label>)   // parenthetical: "(Author, Year)"   (natbib \citep)
#sideref(<label>) // small citation pushed to the right edge (form: "prose" for textual)
text#footcite(<label>) // superscript marker + the citation in the footnote area
```

### Compact list spacing

For dense layouts (e.g. multi-column slides), use `#compact` to tighten list spacing:

```typst
#compact[
  - Item A
  - Item B
  - Item C
]
```

Adjustable: `#compact(spacing: 0.2em, leading: 0.2em)[...]`

For lighter adjustments, `#set list(spacing: 0.4em)` works as a local override.

### Vertical and horizontal fill

For when you want to fill space until the lower or rightmost end of the current slide (or slide column, grid cell, etc.).

```typst
#vfill  // shorthand for v(1fr)
#hfill  // shorthand for h(1fr)
```

### Institutional names

```typst
#bips-en  // Leibniz Institute for Prevention Research and Epidemiology — BIPS
#bips-de  // Leibniz-Institut für Präventionsforschung und Epidemiologie — BIPS
```

### Language

Set the document language once and the whole deck follows — Typst's own output
(figure supplements, quotation marks, hyphenation, outline title, bibliography
terms) and the theme's chrome (thank-you line, contact block, references title,
institution name) together:

```typst
#set text(lang: "de")
#show: bips-theme.with()
```

German and English ship with the theme; any other language falls back to
English. Placement doesn't matter — before or after the `#show` rule both work.

To pin the deck to one language regardless of `text.lang`, pass `lang:`. The
theme sets `text.lang` itself in that case, so the two can never disagree:

```typst
#show: bips-theme.with(lang: "en")
```

Every localized string stays overridable per slide:

```typst
#thanks-slide(
  thanks-text: "Danke!",
  contact-title: "Anschrift",
  institution: bips-de,
  address: [Musterweg 1\ 12345 Musterstadt],
  website: "www.example.org",
)
#bibliography-slide(title: "Literatur", bib: read("references.bib"))
```

## Animations

The theme re-exports Touying's animation functions:

```typst
#pause                              // reveal on click
#uncover(2)[On second click]        // show on specific subslide
#only(1)[First click only]          // only on specific subslide
#alternatives[Version A][Version B] // swap content
```

`#pause` works inside `#two-columns` and `#three-columns`; reveals follow document flow order across cells. `#uncover()` and `#only()` are useful for index-driven reveals without consuming a pause step.

### Handout mode

Handout mode collapses every pause step to a single page per slide, producing one page per logical slide. Enable it from the command line without editing the source:

```sh
typst compile --input handout=true slides.typ
```

Or set it on the theme directly with `bips-theme.with(handout: true)`.

## Global Customization

### Logo

The theme ships with a placeholder logo. Replace it with your own:

```typst
#show: bips-theme.with(
  logo: image("bips-logo.png"),
)
```

Set `logo: none` to hide the logo entirely.

The actual BIPS logo (`bips-logo.png`) is available in the [GitHub repository](https://github.com/bips-hb/bips-typst) but is not included in the Typst package due to unclear redistribution licensing. Download it and place it next to your `.typ` file, then use `logo: image("bips-logo.png")`.

### Progress bar

An optional progress bar spans the bottom edge of the slide, filling as the deck advances:

```typst
#show: bips-theme.with(
  progress-bar: true,
)
```

It is off by default. The bar appears only on counted content slides, so title, section, thanks, and uncounted `empty-slide`s stay clean. Override it for an individual slide with `bips-slide(progress-bar: false)` or `base-slide(progress-bar: false)`.

### Fonts and sizes

```typst
#show: bips-theme.with(
  aspect-ratio: "16-9",       // default
  title-align: left,          // slide title alignment: left (default), center, right
  // Font families (string or array with fallbacks)
  font: "Fira Sans",
  code-font: "Fira Mono",
  math-font: "New Computer Modern Math",
  // Font sizes
  base-size: 20pt,            // scales headings, small/tiny proportionally
  slide-title-size: 28pt,     // explicit pt overrides take precedence
  slide-subtitle-size: 22pt,
  heading-1-size: 22pt,
  heading-2-size: 20pt,
  heading-3-size: 18pt,
  page-number-size: 16pt,
  code-block-scale: 0.9,
  code-inline-scale: 1,
  footnote-scale: 0.8,        // footnote text as a fraction of base size
)
```

### Text size utilities

```typst
#huge[Largest text for emphasis]
#large[Larger text for subheadings]
#small[Smaller text for captions or notes]
#tiny[Even smaller text for fine print]
```

## Examples

The [`gallery/`](https://github.com/bips-hb/bips-typst/tree/v0.6.0/gallery) directory in the repository holds example decks, one per feature area or ecosystem topic (citations, speaker notes, diagrams, data visualisation, a German deck, R with knitr, and more); its README lists them all.
They are not part of the package.

`typst init @preview/bypst` starts from the `basic` template.
The package also ships `complete.typ`, a longer template that walks through the theme's features.

## Development

```sh
just install    # install package locally
just all        # compile all gallery demos
just test       # run test suite
just format     # format all Typst sources
just fonts      # download the Fira fonts into .fonts/
just clean      # remove generated PDFs
```

Gallery decks and tests import the theme from the working tree, so they pick up edits immediately.
Run `just install` again only for decks that import `@local/bypst`.

### Project Structure

```txt
bypst.typ        # package entrypoint (re-exports src/theme.typ)
src/
  theme.typ      # orchestrator (imports config/helpers/slides/extras)
  config.typ     # branding constants (colors, fonts, sizes)
  helpers.typ    # internal plumbing (title area, page number, background)
  slides.typ     # slide types
  extras.typ     # public layout/color utilities
docs/            # design notes and architecture decision records
logo.png         # bundled placeholder logo (override via bips-theme(logo: ...))
bips-logo.png    # the real BIPS logo (not shipped in the package)
typst.toml       # package metadata
template/        # Typst Universe templates
gallery/         # example presentations
tests/           # test suite
```

## Fonts

The theme uses [Fira Sans](https://fonts.google.com/specimen/Fira+Sans) for body text and [Fira Mono](https://fonts.google.com/specimen/Fira+Mono) for code.
Typst packages cannot ship fonts, so install these yourself.
The theme needs these files (OTF from [mozilla/Fira](https://github.com/mozilla/Fira) or TTF from Google Fonts both work):

| File | Used for |
|------|----------|
| `FiraSans-Regular` | body text |
| `FiraSans-Italic` | emphasis |
| `FiraSans-Medium` | title-slide title and author |
| `FiraSans-SemiBold` | slide titles |
| `FiraSans-Bold` | strong text, headings, section and thanks slides |
| `FiraSans-BoldItalic` | strong text inside emphasis |
| `FiraMono-Regular` | code |

Install them as regular system fonts, or put them in a folder and point Typst at it with `typst compile --font-path fonts/ deck.typ` (or the `TYPST_FONT_PATHS` environment variable).
Run `typst fonts --variants` to check what Typst sees.

Without Fira, the theme falls back as follows:

| Role | Preferred | Fallback |
|------|-----------|----------|
| Body text | Fira Sans | Arial (Windows, macOS), DejaVu Sans (Linux) |
| Code | Fira Mono | DejaVu Sans Mono (Typst built-in) |
| Math | New Computer Modern Math | (Typst built-in) |

Typst bundles no sans-serif font: if none of the body fonts is found, text renders in the serif Libertinus.
Typst prints an `unknown font family` warning for each listed font it cannot find; these are harmless.
Override the families with the `font:`, `code-font:`, and `math-font:` parameters on `bips-theme()`.

## Requirements

- Typst >= 0.15.0
- Dependencies: touying and codetastic, resolved automatically by Typst (exact versions are in the imports of `src/theme.typ` and `src/slides.typ`)

## License

The theme code itself is licensed under the MIT license.  
The BIPS logo is owned by BIPS itself (Leibniz Institute for Prevention Research and Epidemiology - BIPS GmbH).

## Related

The BIPS presentation theme zoo for "I don't want to use PowerPoint" folks:

| Markup format | Intermediate format | Output format | Based on | Repo / Package | Status |
|---|---|---|---|---|---|
| LaTeX | --- | PDF | | [bips-beamer](https://github.com/bips-hb/bips-beamer) | Stable |
| [RMarkdown](https://rmarkdown.rstudio.com/) | LaTeX | PDF | bips-beamer | [bipsdown](https://github.com/bips-hb/bipsdown) | Stable |
| [RMarkdown](https://rmarkdown.rstudio.com/) | [xaringan](http://slides.yihui.name/xaringan/) | HTML | | [bipsdown](https://github.com/bips-hb/bipsdown) | Experimental |
| [Quarto](https://quarto.org/) | LaTeX | PDF | bips-beamer | [bips-quarto](https://github.com/bips-hb/bips-quarto) | Stable |
| [Quarto](https://quarto.org/) | reveal.js | HTML | | [bips-quarto](https://github.com/bips-hb/bips-quarto) | Experimental |
| [typst](https://typst.app/) | --- | PDF | | [bips-typst](https://github.com/bips-hb/bips-typst) / [bypst](https://typst.app/universe/package/bypst) | Stable |
