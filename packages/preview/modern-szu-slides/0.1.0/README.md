# SZU Typst Slides Template

<p align="right">
  <strong>English</strong> | <a href="README_zh.md">中文</a>
</p>

[![Typst version: 0.14+](https://img.shields.io/badge/Typst-0.14%2B-blue)](https://typst.app/)
[![Touying version: 0.7.4](https://img.shields.io/badge/Touying-0.7.4-orange)](https://touying-typ.github.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A clean, modern, and professional [Typst](https://typst.app/) slide template for Shenzhen University (SZU) presentations and thesis defenses, powered by [Touying](https://touying-typ.github.io/).

Two SZU-branded themes are included: **Metropolis** (dark red accent) and **University** (classic style). Dedicated English and Chinese templates (`xxx_en.*` / `xxx_zh.*`) are provided out-of-the-box with tailored typography and localized metadata.

<p align="center">
  <img src="assets/szu-logo.svg" width="120" alt="SZU logo">
</p>

---

## Features

- **SZU Brand Visual Identity**: Accurate SZU primary red (`#A20040`), secondary tones, and official vectors.
- **Dual Themes**: Easily switch between Metropolis and University themes.
- **Separated Bilingual Templates**: Clean English (`main_en.typ`) and Chinese (`main_zh.typ`) slide decks without mixed labels.
- **Rich Components**: Built-in cards, conclusion blocks, key metrics display, note blocks, custom tables, and more.
- **Modern Typst Ecosystem**: Fully compatible with Typst 0.14+ and Touying 0.7.4.

---

## Quick Start

### 1. Install Typst

- **macOS** (Homebrew):
  ```bash
  brew install typst
  ```
- **Arch Linux**:
  ```bash
  pacman -S typst
  ```
- **Windows** (Winget / Scoop):
  ```powershell
  winget install --id Typst.Typst
  # or
  scoop install typst
  ```
- Or download prebuilt binaries directly from [Typst Releases](https://github.com/typst/typst/releases).

### 2. Clone the Repository

```bash
git clone https://github.com/<your-username>/szu-typst-slides.git
cd szu-typst-slides
```

### 3. Choose Your Language & Fill Information

- For **English** slides: edit `section-cover_en.typ` to update your thesis title, candidate name, advisor, college, and major.
- For **Chinese** slides: edit `section-cover_zh.typ` to fill in your title, name, advisor, college, etc.

### 4. Compile to PDF

```bash
# Compile English slides:
typst compile main_en.typ main_en.pdf

# Compile Chinese slides:
typst compile main_zh.typ main_zh.pdf

# Backward-compatible default:
typst compile main.typ
```

### 5. Live Preview / Auto-recompile

```bash
# Watch English slides for changes:
typst watch main_en.typ

# Watch Chinese slides for changes:
typst watch main_zh.typ
```

---

## Switching Themes

Edit `main_en.typ` (or `main_zh.typ`) and comment/uncomment the theme import at the top:

```typst
// Metropolis Theme (default, dark red accent)
#import "libs/szu-met-theme.typ": *

// University Theme (classic university header & sidebar style)
// #import "libs/szu-uni-theme.typ": *
```

---

## File Structure

The project follows a uniform bilingual naming convention (`xxx_en.*` and `xxx_zh.*`):

```text
szu-typst-slides/
├── README.md                 # English documentation (entry point)
├── README_zh.md              # Chinese documentation
├── README_en.md              # English documentation alias
├── main_en.typ               # Entry point: English slides
├── main_zh.typ               # Entry point: Chinese slides
├── main.typ                  # Compatibility entry point (includes main_zh.typ)
├── libs/
│   ├── szu-colors.typ        # SZU brand color definitions (red, gold, blue, cyan)
│   ├── szu-met-theme.typ     # SZU Metropolis theme implementation
│   └── szu-uni-theme.typ     # SZU University theme implementation
├── slide-text.typ            # Global font family, sizing, and color variables
├── slide-functions.typ       # Reusable layout and presentation components
├── slide-components.typ      # Re-export compatibility shim
├── section-cover_en.typ      # English title / cover slide
├── section-cover_zh.typ      # Chinese title / cover slide
├── section-outline_en.typ    # English table of contents slide
├── section-outline_zh.typ    # Chinese table of contents slide
├── section-background_en.typ # English research background sample section
├── section-background_zh.typ # Chinese research background sample section
├── section-work_en.typ       # English core work & experiments section
├── section-work_zh.typ       # Chinese core work & experiments section
├── section-summary_en.typ    # English summary & future outlook section
├── section-summary_zh.typ    # Chinese summary & future outlook section
├── section-thanks_en.typ     # English closing / acknowledgements slide
├── section-thanks_zh.typ     # Chinese closing / acknowledgements slide
├── section-appendix_en.typ   # English appendix section
├── section-appendix_zh.typ   # Chinese appendix section
├── assets/                   # Vector logos and flag assets
└── ref.bib                   # BibTeX references database
```

---

## Built-in Components

Reusable components are defined in `slide-functions.typ`:

| Component | Usage | Description |
|-----------|-------|-------------|
| `card(title, body)` | `#card([Title], [Body text])` | Rounded container block for key concepts |
| `conclusion-card(title, body)` | `#conclusion-card([Title], [Body])` | Accent-bordered conclusion container |
| `result-conclusion(body, label: [Conclusion:])` | `#result-conclusion([Key takeaway])` | Auto-labeled conclusion highlight |
| `metric(label, value, note)` | `#metric([Accuracy], [94.8%], [+4.2% vs baseline])` | Key performance indicator block |
| `small-title(text)` | `#small-title[Subheading]` | SZU red section subheading |
| `outline-item(index, title, subtitle)` | See `section-outline_*.typ` | Numbered outline item card |
| `soft-note(body)` | `#soft-note[Note details]` | Light-colored contextual note block |
| `issue-row(tag, desc)` | `#issue-row([Problem], [Description])` | Tagged issue and resolution row |
| `img(path, caption, width)` | `#img("assets/szu-logo.svg", [Caption], width: 60%)` | Centered image with caption |
| `slide-table(...)` | `#slide-table(columns: 2, ...)` | Table wrapper with optimized presentation typography |

---

## Customization

1. **Cover Information**: Edit `section-cover_en.typ` or `section-cover_zh.typ` to update metadata variables:
   - `thesis-title` / `cover-title`
   - `thesis-subtitle`
   - `college-name`
   - `major-name`
   - `candidate-name`
   - `advisor-names`
2. **Slides Content**: Customize or replace the sample sections (`section-background_*.typ`, `section-work_*.typ`, `section-summary_*.typ`).
3. **Slide Order**: Add, remove, or reorder `#xxx-section` calls at the bottom of `main_en.typ` or `main_zh.typ`.
4. **Typography**: Fine-tune font sizes and spacing in `slide-text.typ`.

---

## Dependencies & Requirements

| Dependency | Required Version | Purpose |
|------------|------------------|---------|
| **Typst** | `0.14+` (tested on `0.14.2`) | Document compiler & CLI |
| `@preview/touying` | `0.7.4` | Presentation slide framework |
| `@preview/theorion` | `0.4.0` | Theorem and mathematical environments |
| `@preview/numbly` | `0.1.0` | Flexible heading numbering format |
| `@preview/cuti` | `0.4.0` | Chinese fake bold synthesis |

> Packages from Typst's official `@preview` package registry will be downloaded automatically by Typst on first compilation.

---

## Fonts

- **Chinese**: `Heiti SC` (macOS system font)
- **English**: `Times New Roman`

To customize fonts for Linux or Windows, change `zh-font` and `en-font` in `slide-text.typ`:
```typst
#let zh-font = "SimHei"       // e.g., for Windows
#let en-font = "Times New Roman"
```

---

## License

MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Touying](https://touying-typ.github.io/) — Powerful slides framework for Typst
- [modern-szu-slides](https://github.com/yjdyamv/modern-szu-slides) — Original LaTeX inspiration
- Shenzhen University (SZU)
