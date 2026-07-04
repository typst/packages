<h1 align="center">xwysyy</h1>

<p align="center">
  <a href="https://typst.app/universe/package/xwysyy"><img src="https://img.shields.io/badge/Typst%20Universe-available-239dad.svg" alt="Typst Universe"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://typst.app"><img src="https://img.shields.io/badge/Typst-%E2%89%A5%200.14.0-239dad.svg" alt="Typst version: >= 0.14.0"></a>
  <a href="https://github.com/touying-typ/touying"><img src="https://img.shields.io/badge/touying-0.7.4-blueviolet.svg" alt="touying version: 0.7.4"></a>
  <a href="#-themes"><img src="https://img.shields.io/badge/Themes-6%20built--in-ff69b4.svg" alt="Built-in themes"></a>
</p>

<p align="center">
  <a href="https://github.com/xwysyy/xwysyy-typst/blob/v0.3.0/README-zh.md">中文</a> | <b>English</b>
</p>

Academic presentation and note-taking templates built on [touying](https://github.com/touying-typ/touying). The package covers slide decks, handouts, speaker notes, and A4 notes from one Typst source. The visual theme is derived from [Carlos-Mero/may](https://github.com/Carlos-Mero/may) under MIT.

## Features

- Universe template support: `typst init @preview/xwysyy:0.3.0` creates a ready-to-compile deck.
- Six built-in themes: `sky`, `sunset`, `forest`, `midnight`, `violet`, and `graphite`.
- Custom theme dictionaries can be passed directly to `theme`, so users can customize colors without forking the package.
- Slide font parameters match note mode: `font`, `code-font`, and `lang`.
- Touying handout mode, `#speaker-note`, and pdfpc export are documented with source examples.
- `xwysyy-doc` compiles one source as a 16:9 deck by default and as A4 notes with `--input mode=note`.

## Preview

Rendered previews are generated from the source repository. The source examples are available at <https://github.com/xwysyy/xwysyy-typst/tree/v0.3.0/examples>.

### Slide Themes

| sky | sunset | forest |
|:---:|:---:|:---:|
| ![Sky theme cover](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-theme-sky-p1-01.png) | ![Sunset theme cover](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-theme-sunset-p1-01.png) | ![Forest theme cover](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-theme-forest-p1-01.png) |

| midnight | violet | graphite |
|:---:|:---:|:---:|
| ![Midnight theme cover](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-theme-midnight-p1-01.png) | ![Violet theme cover](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-theme-violet-p1-01.png) | ![Graphite theme cover](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-theme-graphite-p1-01.png) |

### Component Pages

| Sky cover | Sky components |
|:---:|:---:|
| ![Sky theme cover slide](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-sky-p1-01.png) | ![Sky theme textbox components](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-sky-p5-05.png) |

| Sunset cover | Sunset components |
|:---:|:---:|
| ![Sunset theme cover slide](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-sunset-p1-01.png) | ![Sunset theme textbox components](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-sunset-p5-05.png) |

| Note title | Note code | Note table |
|:---:|:---:|:---:|
| ![Note mode title and TOC](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-note-p1-1.png) | ![Note mode lists and code](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-note-p2-2.png) | ![Note mode tables and quotes](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/v0.3.0/assets/preview-note-p3-3.png) |

## Quick Start

Create a new project from the Universe template:

```bash
typst init @preview/xwysyy:0.3.0 my-talk
cd my-talk
typst compile main.typ
```

Use the package in an existing Typst project:

```typst
#import "@preview/xwysyy:0.3.0": *

#show: xwysyy-pre.with(
  theme: "sunset",
  config-info(
    title: [My Presentation Title],
    subtitle: [Subtitle],
    author: " ",
    date: datetime.today(),
    institution: " ",
  ),
)

#title-slide()
#outline-slide()

= Section Title

== Slide Title

Body text with *bold* and #red[red highlight].

#textbox(
  [*Module A*

  First column],

  [*Module B*

  Second column],
)

#end-slide(title: [Thank You!], body: [Questions?])
```

## Themes

Select a built-in theme by name:

```typst
#show: xwysyy-pre.with(
  theme: "forest",
  config-info(title: [My Presentation]),
)
```

Pass a custom dictionary directly:

```typst
#let my-theme = (
  sea: rgb("#1f5d45"),
  sky: rgb("#a8d5ba"),
  skyl: rgb("#e9f5ee"),
  skyll: rgb("#f5fbf7"),
  paper: rgb("#f7faf8"),
  header-fill: none,
  header-text: none,
  page-fill: white,
)

#show: xwysyy-pre.with(
  theme: my-theme,
  config-info(title: [My Presentation]),
)
```

Each theme has the same eight fields:

| Field | Purpose |
|-------|---------|
| `sea` | Primary dark color for headers, links, table heads, badges, and focus slides |
| `sky` | Accent color |
| `skyl` | Light background color |
| `skyll` | Code block, table row, and textbox fill |
| `paper` | Text on dark backgrounds |
| `header-fill` | Header bar fill, `none` falls back to `sea` |
| `header-text` | Header bar text, `none` falls back to `paper` |
| `page-fill` | Slide page background |

## Component Reference

| Category | API | Usage |
|----------|-----|-------|
| Slide entry | `xwysyy-pre` | `#show: xwysyy-pre.with(theme: "sky", ...)` |
| Dual-output entry | `xwysyy-doc` | default deck, `--input mode=note` for A4 notes |
| Title slide | `title-slide` | `#title-slide()` |
| Outline | `outline-slide` | `#outline-slide()` auto-collects section headings |
| Content slide | `xwysyy-slide` | `== Title` auto-triggers |
| Section transition | `new-section-slide` | `= Title` auto-triggers |
| Focus slide | `focus-slide` | `#focus-slide[Large text]` |
| Full-screen image | `image-slide` | `#image-slide(img: image("bg.png"))` |
| End slide | `end-slide` | `#end-slide(title: [...])` |
| Text box | `textbox` | `#textbox[Content]` or `#textbox([Col 1], [Col 2])` |
| Highlight | `red` / `bred` | `#red[text]` / `#bred[bold red]` |
| Highlight | `yellow` / `byellow` | `#yellow[text]` / `#byellow[bold yellow]` |
| Note entry | `xwysyy-note` | `#show: xwysyy-note.with(title: [...])` |
| Extensions | `cetz-canvas` / `fletcher-diagram` | cetz, fletcher, and theorion integrations |

## Handouts And Speaker Notes

Enable touying handout mode by passing `config-common(handout: true)` through `xwysyy-pre`:

```typst
#show: xwysyy-pre.with(
  config-common(handout: true),
  config-info(title: [My Presentation]),
)
```

```bash
typst compile main.typ slides-handout.pdf
```

Speaker notes are available because `xwysyy.typ` re-exports touying:

```typst
#speaker-note[
  Mention the ablation table before moving to the next section.
]
```

Export pdfpc metadata:

```bash
typst query main.typ --field value --one "<pdfpc-file>" > slides.pdfpc
```

## One Source, Two Outputs

Use `xwysyy-doc` when one source should produce both deck and notes:

```typst
#import "@preview/xwysyy:0.3.0": *

#show: xwysyy-doc.with(
  title: [One Source, Two Outputs],
  subtitle: [Deck and A4 notes],
  theme: "forest",
)
```

Compile the deck:

```bash
typst compile main.typ slides.pdf
```

Compile the A4 notes:

```bash
typst compile --input mode=note main.typ notes.pdf
```

## Requirements

- Typst >= 0.14.0
- touying 0.7.4, downloaded on first compile
- physica 0.9.8, downloaded on first compile
- Default local fonts: Times New Roman, Noto Serif CJK SC, and Maple Mono
- Typst web app users can pass web-available fonts with `font:` and `code-font:`

## Documentation

Full API reference: [docs/USAGE.md](https://github.com/xwysyy/xwysyy-typst/blob/v0.3.0/docs/USAGE.md). Customization guide: [docs/CUSTOMIZATION.md](https://github.com/xwysyy/xwysyy-typst/blob/v0.3.0/docs/CUSTOMIZATION.md). Theme generator: [docs/THEME-GENERATOR.md](https://github.com/xwysyy/xwysyy-typst/blob/v0.3.0/docs/THEME-GENERATOR.md).

## Acknowledgements

- Theme derived from [Carlos-Mero/may](https://github.com/Carlos-Mero/may) under MIT
- Built on [touying](https://github.com/touying-typ/touying)

## License

[MIT](./LICENSE)
