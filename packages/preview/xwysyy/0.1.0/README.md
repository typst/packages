<h1 align="center">xwysyy</h1>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://typst.app"><img src="https://img.shields.io/badge/Typst-%E2%89%A5%200.14-239dad.svg" alt="Typst version: >= 0.14"></a>
  <a href="https://github.com/touying-typ/touying"><img src="https://img.shields.io/badge/touying-0.7.3-blueviolet.svg" alt="touying version: 0.7.3"></a>
  <a href="#-themes"><img src="https://img.shields.io/badge/Themes-sky%20%7C%20sunset-ff69b4.svg" alt="Built-in themes: sky and sunset"></a>
  <a href="https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/THEME-GENERATOR.md"><img src="https://img.shields.io/badge/AI-Theme%20Generator-orange.svg" alt="AI Theme Generator"></a>
</p>

<p align="center">
  <a href="https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/README-zh.md">中文</a> | <b>English</b>
</p>

> Academic presentation and note-taking theme built on [touying](https://github.com/touying-typ/touying). Suitable for research talks, thesis defenses, academic sharing, and literature notes. Derived from [Carlos-Mero/may](https://github.com/Carlos-Mero/may) (MIT).

## ✨ Features

- Built-in **sky** / **sunset** color schemes with one-parameter switching, plus [AI custom themes](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/THEME-GENERATOR.md)
- 7 slide layouts + academic note mode, covering title, outline, section transition, focus, and more
- `textbox` multi-column boxes, `red` / `yellow` highlight macros, CJK synthetic italics, and other academic typesetting components
- `#pause` progressive reveal animations with built-in `frozen-counters` to prevent numbering issues
- Optional extension `xwysyy-extras.typ`: cetz drawing / fletcher diagrams + theorion theorem environments
- Compatible with all touying 0.7.x advanced features

## 👀 Preview

> Example decks are in the `examples/` directory:

```bash
typst compile examples/slides-sky.typ           # sky theme slides
typst compile examples/slides-sunset.typ        # sunset theme slides
typst compile examples/note.typ                  # academic notes
```

### 🌤️ Sky Theme

| Cover | Lists & Highlights |
|:---:|:---:|
| ![Sky theme cover slide](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sky-p1-01.png) | ![Sky theme lists and highlights](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sky-p4-04.png) |
| **Textbox Components** | **Code & Equations** |
| ![Sky theme textbox components](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sky-p5-05.png) | ![Sky theme code and equations](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sky-p8-08.png) |

### 🌅 Sunset Theme

| Cover | Lists & Highlights |
|:---:|:---:|
| ![Sunset theme cover slide](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sunset-p1-01.png) | ![Sunset theme lists and highlights](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sunset-p4-04.png) |
| **Textbox Components** | **Code & Equations** |
| ![Sunset theme textbox components](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sunset-p5-05.png) | ![Sunset theme code and equations](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-sunset-p8-08.png) |

### 📝 Note Mode

| Title & TOC | Lists & Code | Tables & Quotes |
|:---:|:---:|:---:|
| ![Note mode title and TOC](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-note-p1-1.png) | ![Note mode lists and code](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-note-p2-2.png) | ![Note mode tables and quotes](https://raw.githubusercontent.com/xwysyy/xwysyy-typst/7b4d308/assets/preview-note-p3-3.png) |

## 🚀 Quick Start

Copy `xwysyy.typ` to your project directory, then:

```typst
#import "@preview/xwysyy:0.1.0": *

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

## 🎨 Themes

Select a built-in theme via the `theme` parameter, or create custom color schemes with the [AI Theme Generator](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/THEME-GENERATOR.md).

| Field | Purpose | sky | sunset |
|-------|---------|-----|--------|
| `sea` | Primary color | `#3b60a0` | `#970014` |
| `sky` | Accent color | `#bdd0f1` | `#D8A6A2` |
| `skyl` | Light background | `#eff3ff` | `#fdf0f0` |
| `skyll` | Code block / textbox fill | `#f4f9ff` | `#FFF8F6` |
| `paper` | Text on dark backgrounds | `#f5f6f8` | `#f5f6f8` |
| `header-fill` | Header bar background | sea blue | `#F7EEE7` |
| `header-text` | Header bar text | paper white | `#970014` |
| `page-fill` | Page background | white | `#fffefd` |

## 🧩 Component Reference

| Category | API | Usage |
|----------|-----|-------|
| Slide entry | `xwysyy-pre` | `#show: xwysyy-pre.with(theme: "sky", ...)` |
| Title slide | `title-slide` | `#title-slide()` |
| Outline | `outline-slide` | `#outline-slide()` auto-collects section headings |
| Content slide | `xwysyy-slide` | `== Title` auto-triggers |
| Section transition | `new-section-slide` | `= Title` auto-triggers |
| Focus slide | `focus-slide` | `#focus-slide[Large text]` |
| Full-screen image | `image-slide` | `#image-slide(img: image("bg.png"))` |
| End slide | `end-slide` | `#end-slide(title: [...])` |
| Text box | `textbox` | `#textbox[Content]` / `#textbox([Col 1], [Col 2])` |
| Red highlight | `red` / `bred` | `#red[text]` / `#bred[bold red]` |
| Yellow highlight | `yellow` / `byellow` | `#yellow[text]` / `#byellow[bold yellow]` |
| Note entry | `xwysyy-note` | `#show: xwysyy-note.with(title: [...])` |
| Extensions | `xwysyy-extras` | cetz drawing + fletcher diagrams + theorion theorem environments |

Full API reference: [docs/USAGE.md](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/USAGE.md). Customization guide: [docs/CUSTOMIZATION.md](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/CUSTOMIZATION.md).

## ⚙️ Requirements

- Typst >= 0.14
- touying 0.7.3 (auto-downloaded on first compile)
- physica 0.9.8 (auto-downloaded on first compile)
- Fonts: Times New Roman + Noto Serif CJK SC (CJK) + Maple Mono (code)

## 📖 Documentation

| Document | Content |
|----------|---------|
| [USAGE.md](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/USAGE.md) | Full API reference: layouts, components, extensions, non-slide document entry |
| [CUSTOMIZATION.md](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/CUSTOMIZATION.md) | Customization guide: colors, fonts, layouts, touying advanced features, extensions |
| [THEME-GENERATOR.md](https://github.com/xwysyy/xwysyy-typst/blob/7b4d308/docs/THEME-GENERATOR.md) | AI theme generator: create custom themes from screenshots or descriptions |

## 🙏 Acknowledgements

- Theme derived from [Carlos-Mero/may](https://github.com/Carlos-Mero/may) (MIT)
- Built on [touying](https://github.com/touying-typ/touying)

## 📄 License

[MIT](./LICENSE)
