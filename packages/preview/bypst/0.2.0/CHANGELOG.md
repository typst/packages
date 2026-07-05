# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.2.0] - April 2026

### Added
- `title-align` parameter on `bips-theme()` for horizontal alignment of slide titles (left, center, right)
- `base-size` parameter on `bips-theme()` to scale all text proportionally; headings, page numbers, `#small[]`, and `#tiny[]` adjust automatically via em-based sizing
- Size override parameters on `bips-theme()`: `slide-title-size`, `slide-subtitle-size`, `heading-1-size`, `heading-2-size`, `heading-3-size`, `page-number-size`, `small-size`, `tiny-size`
- `#huge[]`, `#large[]`, `#small[]`, and `#tiny[]` text size utility functions that scale proportionally with `base-size`
- `#compact[]` utility for tighter list/enum spacing (applies recursively to nested lists)
- `#vfill` shorthand (equivalent to `#v(1fr)`)
- Color helpers: `#blue[]`, `#orange[]`, `#green[]`, `#gray[]`
- `callout()` blocks with types note, tip, warning, important and optional `title:` parameter
- `two-columns[][]` and `three-columns[][][]` layout helpers with customizable widths and gutter
- `content-align` parameter on `bips-slide()` for body content alignment (e.g. `center + horizon`)
- Per-slide overrides: `text-size`, `title-size`, `subtitle-size`, `code-block-scale`, `code-inline-scale` on `bips-slide()`
- Code scaling parameters `code-block-scale` and `code-inline-scale` on `bips-theme()`
- Heading show rules for levels 1, 2, and 3 in BIPS blue with em-based sizing (1.11em, 1em, 0.89em)
- `bibliography-slide()` for reference lists
- `empty-slide[]` for minimal slides without branding
- tytanic test suite with 10 compile-only tests covering all slide types and features
- typstyle formatting for consistent code style
- GitHub Actions workflow to compile gallery demos and deploy previews to GitHub Pages

### Changed
- Renamed built-in institute name variables to kebab case for consistency: `bips_en` -> `bips-en`, `bips_de` -> `bips-de`.
- **Upgraded Touying from 0.6.1 to 0.7.0** with new API for aspect ratios, config parameters, and page setup
- Page numbers use Touying's logical slide counter rendered in slide content via `place()`, fixing off-by-one errors on animated slides
- Slides without page numbers (`title-slide`, `section-slide`, `thanks-slide`, `empty-slide`) freeze the slide counter so numbering is sequential without gaps
- Page background overrides use `config: config-page(...)` instead of `set page()` in `setting:` callbacks (Touying 0.7.0 requirement)
- Aspect ratio uses `utils.page-args-from-aspect-ratio()` instead of `paper: "presentation-..."`
- Font size overrides use a state bridge (`_bips-sizes`) to pass computed values from `bips-theme()` to slide functions
- `thanks-slide` uses the `setting:` callback pattern consistently with other slide types
- `empty-slide` simplified from variadic `..content` to single `body` parameter
- `title-slide` no longer redundantly re-sets the page background
- **Renamed package from `bips-typst` to `bypst`** for Typst Universe naming compliance
- Multi-author title slides separate names with horizontal space instead of commas
- Gallery condensed from 13 demos to 5 focused examples (basic, complete, bibliography, aspect-ratio, lecture-demo)
- Emphasis (`_text_`) renders as blue italic; strong (`*text*`) renders as blue bold
- List/enum styling uses ascender/descender edges for consistent bullet alignment
- Nested lists use tighter spacing
- Gallery and test files use relative imports instead of versioned `@local` imports

### Removed
- Dead `show-page-number` parameter from `section-slide` (was accepted but silently ignored)
- Unused typography variables: `font-weight-base`, `font-color-small`, `font-weight-small`, `font-color-tiny`, `font-weight-tiny`, `font-size-heading-*`
- 8 redundant gallery demos (animations, callouts, columns, content-elements, customization, font-customization, multi-author, qr-code) — all covered by `complete.typ`

### Fixed
- Size override parameters in `bips-theme()` were silently ignored — now functional
- Heading levels 1–3 had no styling (rendered as default black text) — now styled globally with BIPS blue (h1/h2) and gray (h3)
- Page numbers remain stable across `#pause` subslides
- Content overflow on animated slides no longer creates blank pages for all subslides

## [0.1.1] - 2025

### Changed
- Restructured project layout: moved theme files from `lib/` to project root
- Improved slide number logic to handle presentations with or without title slide
- Expanded and consolidated test suite into single `test-suite.typ`

### Fixed
- Slide counter properly adjusts numbering based on title slide presence

## [0.1.0] - 2025

### Added
- Initial release of BIPS Typst presentation template
- Core slide types: title-slide, bips-slide, section-slide, thanks-slide, empty-slide
- Multi-author support with institute affiliations via `inst()`
- QR code generation for contact slides via codetastic
- Animation support via Touying (`#pause`, `#uncover`, `#only`, `#alternatives`, `#meanwhile`)
- Bibliography slide helper
- Customizable font sizes and styling
- BIPS branding (colors, logo, Fira Sans / Fira Mono fonts)
- 16:9 and 4:3 aspect ratio support
- Gallery of example presentations
- Test suite for validation

[Unreleased]: https://github.com/bips-hb/bips-typst/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/bips-hb/bips-typst/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/bips-hb/bips-typst/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bips-hb/bips-typst/releases/tag/v0.1.0
