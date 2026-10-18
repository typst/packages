# bypst — BIPS Presentation Template

A 16:9 presentation template for [BIPS](https://www.leibniz-bips.de/) using [Typst](https://typst.app/) and [Touying](https://touying-typ.github.io/). Based on the institutional style from [bips-beamer](http://github.com/bips-hb/bips-beamer).

## Quick Start

```typst
#import "@preview/bypst:0.2.0": *
#show: bips-theme

#title-slide(
  title: "Your Presentation Title",
  author: "Your Name",
  institute: bips-en, // or bips-de
  date: datetime.today().display(),
)

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

Available from the [Typst package registry](https://typst.app/universe/package/bypst) — no installation needed:

```typst
#import "@preview/bypst:0.2.0": *
```

### Local development

To work on the theme itself, clone and install locally:

```sh
git clone https://github.com/bips-hb/bips-typst.git
cd bips-typst
just install
```

Then use the local import instead:

```typst
#import "@local/bypst:0.2.0": *
```

## Slide Types

| Function | Purpose |
|---|---|
| `#title-slide()` | Opening slide with author, institute, date |
| `#bips-slide()` | Content slide with optional title/subtitle |
| `#section-slide()` | Section divider |
| `#thanks-slide()` | Closing slide with contact info and optional QR code |
| `#bibliography-slide[]` | References |
| `#empty-slide[]` | Blank slide without branding |

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

### Multi-author title slides

```typst
#title-slide(
  title: "Collaborative Research",
  authors: (
    "Jane Doe" + inst(1,2),
    "John Smith" + inst(1),
  ),
  institutes: (
    "BIPS",
    "University of Bremen",
  ),
)
```

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
#blue[text]  #orange[text]  #green[text]  #gray[text]
```

### Callout boxes

```typst
#callout(type: "note")[Information]
#callout(type: "tip")[Helpful hint]
#callout(type: "warning")[Caution]
#callout(type: "important")[Critical]
#callout(type: "tip", title: "Custom Title")[With a title]
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

### Vertical fill

```typst
#vfill  // shorthand for v(1fr)
```

### Institutional names

```typst
#bips-en  // Leibniz Institute for Prevention Research and Epidemiology — BIPS
#bips-de  // Leibniz-Institut für Präventionsforschung und Epidemiologie — BIPS
```

## Animations

The theme re-exports Touying's animation functions:

```typst
#pause                              // reveal on click
#uncover(2)[On second click]        // show on specific subslide
#only(1)[First click only]          // only on specific subslide
#alternatives[Version A][Version B] // swap content
```

**Note**: Do not use `#pause` inside `#two-columns` / `#three-columns`. Use `#uncover()` or `#only()` instead.

## Global Customization

### Logo

The theme ships with a placeholder logo. Replace it with your own:

```typst
#show: bips-theme.with(
  logo: image("my-logo.png"),
)
```

Set `logo: none` to hide the logo entirely.

### Fonts and sizes

```typst
#show: bips-theme.with(
  aspect-ratio: "16-9",       // default
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
  small-size: 16pt,
  tiny-size: 14pt,
  page-number-size: 16pt,
  code-block-scale: 0.9,
  code-inline-scale: 1,
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

The `gallery/` directory contains example presentations:

- `basic.typ` — starter template
- `complete.typ` — comprehensive feature showcase
- `bibliography.typ` — citations and references
- `aspect-ratio.typ` — 4:3 format
- `lecture-demo.typ` — realistic 100-slide scale test

## Development

```sh
just install    # install package locally
just all        # compile all gallery demos
just test       # run test suite
just clean      # remove generated PDFs
```

After editing theme files, run `just install` before compiling.

### Project Structure

```txt
bypst.typ        # package entrypoint
theme.typ        # theme implementation
logo.png         # placeholder logo (replace with your own)
typst.toml       # package metadata
template/        # Typst Universe templates
gallery/         # example presentations
tests/           # test suite
```

## Fonts

The theme uses [Fira Sans](https://fonts.google.com/specimen/Fira+Sans) for body text and [Fira Mono](https://fonts.google.com/specimen/Fira+Mono) for code, with automatic fallbacks if they are not installed:

| Role | Preferred | Fallback |
|------|-----------|----------|
| Body text | Fira Sans | Noto Sans |
| Code | Fira Mono | DejaVu Sans Mono (Typst built-in) |
| Math | New Computer Modern Math | (Typst built-in) |

For the best results, install the Fira fonts. Override with the `font:`, `code-font:`, and `math-font:` parameters on `bips-theme()`.

## Requirements

- Typst >= 0.12.0
- Dependencies: touying 0.7.1, codetastic 0.2.2 (resolved automatically)

## License

MIT
