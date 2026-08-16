# beautitled

A Typst package for creating beautiful, print-friendly title styles for documents. Perfect for textbooks, course materials, academic papers, and any document that needs professional heading styles.

## Features

- **19 distinctive styles** - From classic academic to modern creative
- **Print-friendly** - All styles use minimal ink (no heavy backgrounds)
- **Fully configurable** - Colors, sizes, spacing, and numbering
- **Styled Table of Contents** - Each style has a matching TOC design
- **Optional parts** - LaTeX-like parts above chapters
- **Page breaks** - Optional automatic page breaks before chapters
- **Multilingual** - Customizable prefixes for any language
- **Native Typst support** - Works with `= Heading` syntax
- **Cross-references** - `beautitled-ref` for labelled heading refs with optional page numbers

**[View the full manual (PDF)](https://github.com/nathan-ed/typst-package-beautitled/blob/db6bf5b51ac9346ba4cc0ff55c55575472c25a9d/docs/manual.pdf)**

## Quick Start

```typst
#import "@preview/beautitled:0.2.7": *

#beautitled-setup(style: "titled")
#show: beautitled-init

= My Chapter Title
== My Section Title
=== My Subsection Title
```

## Parts

Typst has generic heading levels, but not a dedicated LaTeX-style `\part`.
`beautitled` provides one with `#part[...]`. By default each part gets its own
dedicated page with the title vertically and horizontally centred — matching
LaTeX's default behavior. Every style has its own coherent part renderer.

```typst
#part[Foundations]
#chapter[Numbers]
#section[Integers]
```

### Part with image

```typst
#part(
  image: image("cover.png", width: 70%),
  image-caption: [A conceptual overview],
  image-position: "below",  // "above" or "below" (default)
)[Advanced Topics]
```

### Disable full-page parts

```typst
#beautitled-setup(part-fullpage: false)  // global
#part(fullpage: false)[Appendices]       // per call
```

### Native headings as parts

```typst
#beautitled-setup(enable-parts: true)
#show: beautitled-init

= Foundations
== Numbers
=== Integers
==== Arithmetic
```

## Available Styles (19)

| Category | Style | Description |
|----------|-------|-------------|
| **Original** | `titled` | Boxed sections with floating labels (DEFAULT) |
| **General** | `classic` | Traditional with underlines |
| | `modern` | Clean geometric with accent |
| | `elegant` | Refined with ornaments |
| | `bold` | Strong left border |
| | `creative` | Student portfolio style |
| | `minimal` | Ultra-clean |
| | `vintage` | Classic book ornaments |
| **Educational** | `schoolbook` | Textbook style |
| | `notes` | Course notes |
| | `clean` | Maximum simplicity |
| **Academic** | `technical` | Documentation |
| | `academic` | Professional academic |
| | `textbook` | Bold numbers, clear hierarchy |
| | `scholarly` | Centered with thin rules |
| | `classical` | Small caps, minimal |
| | `educational` | Left border with numbers |
| | `structured` | Boxed numbers |
| | `magazine` | Editorial style |

## Style Gallery

<table>
  <tr>
    <td align="center"><img src="gallery/styles/titled.png" width="220" alt="titled style: chapter heading with boxed floating label"><br><strong>titled</strong></td>
    <td align="center"><img src="gallery/styles/classic.png" width="220" alt="classic style: traditional heading with underline"><br><strong>classic</strong></td>
    <td align="center"><img src="gallery/styles/modern.png" width="220" alt="modern style: clean geometric heading with accent bar"><br><strong>modern</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/styles/elegant.png" width="220" alt="elegant style: refined heading with ornamental rules"><br><strong>elegant</strong></td>
    <td align="center"><img src="gallery/styles/bold.png" width="220" alt="bold style: strong left border heading"><br><strong>bold</strong></td>
    <td align="center"><img src="gallery/styles/creative.png" width="220" alt="creative style: student portfolio heading"><br><strong>creative</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/styles/minimal.png" width="220" alt="minimal style: ultra-clean heading with no decoration"><br><strong>minimal</strong></td>
    <td align="center"><img src="gallery/styles/vintage.png" width="220" alt="vintage style: classic book heading with ornaments"><br><strong>vintage</strong></td>
    <td align="center"><img src="gallery/styles/schoolbook.png" width="220" alt="schoolbook style: textbook heading with number badge"><br><strong>schoolbook</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/styles/notes.png" width="220" alt="notes style: course notes heading with tab marker"><br><strong>notes</strong></td>
    <td align="center"><img src="gallery/styles/clean.png" width="220" alt="clean style: maximum simplicity heading"><br><strong>clean</strong></td>
    <td align="center"><img src="gallery/styles/technical.png" width="220" alt="technical style: documentation heading with monospace number"><br><strong>technical</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/styles/academic.png" width="220" alt="academic style: professional academic heading with serif"><br><strong>academic</strong></td>
    <td align="center"><img src="gallery/styles/textbook.png" width="220" alt="textbook style: bold numbered heading with clear hierarchy"><br><strong>textbook</strong></td>
    <td align="center"><img src="gallery/styles/scholarly.png" width="220" alt="scholarly style: centered heading with thin rules"><br><strong>scholarly</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/styles/classical.png" width="220" alt="classical style: small caps heading with minimal decoration"><br><strong>classical</strong></td>
    <td align="center"><img src="gallery/styles/educational.png" width="220" alt="educational style: left border heading with large number"><br><strong>educational</strong></td>
    <td align="center"><img src="gallery/styles/structured.png" width="220" alt="structured style: boxed number with indented heading"><br><strong>structured</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/styles/magazine.png" width="220" alt="magazine style: editorial heading with decorative rule"><br><strong>magazine</strong></td>
    <td></td>
    <td></td>
  </tr>
</table>

## Parts Gallery

<table>
  <tr>
    <td align="center"><img src="gallery/parts/parts-1.png" width="160" alt="modern style full-page part page with accent bar and title centred"><br><strong>modern</strong></td>
    <td align="center"><img src="gallery/parts/parts-2.png" width="160" alt="elegant style full-page part page with ornamental rules and small caps"><br><strong>elegant</strong></td>
    <td align="center"><img src="gallery/parts/parts-3.png" width="160" alt="titled style full-page part page with boxed border"><br><strong>titled</strong></td>
    <td align="center"><img src="gallery/parts/parts-4.png" width="160" alt="scholarly style full-page part page with thin horizontal rules"><br><strong>scholarly</strong></td>
  </tr>
</table>

## TOC Style Gallery

<table>
  <tr>
    <td align="center"><img src="gallery/toc/toc-titled.png" width="200" alt="Table of contents in titled style with floating chapter labels"><br><strong>titled</strong></td>
    <td align="center"><img src="gallery/toc/toc-classic.png" width="200" alt="Table of contents in classic style with dot leaders"><br><strong>classic</strong></td>
    <td align="center"><img src="gallery/toc/toc-modern.png" width="200" alt="Table of contents in modern style with accent bar"><br><strong>modern</strong></td>
    <td align="center"><img src="gallery/toc/toc-elegant.png" width="200" alt="Table of contents in elegant style with ornamental rules"><br><strong>elegant</strong></td>
  </tr>
  <tr>
    <td align="center"><img src="gallery/toc/toc-bold.png" width="200" alt="Table of contents in bold style with left border"><br><strong>bold</strong></td>
    <td align="center"><img src="gallery/toc/toc-minimal.png" width="200" alt="Table of contents in minimal style with clean layout"><br><strong>minimal</strong></td>
    <td align="center"><img src="gallery/toc/toc-scholarly.png" width="200" alt="Table of contents in scholarly style with centered titles"><br><strong>scholarly</strong></td>
    <td align="center"><img src="gallery/toc/toc-simple.png" width="200" alt="Table of contents in simple style"><br><strong>simple</strong></td>
  </tr>
</table>

## Configuration

### Full Parameter Reference

```typst
#beautitled-setup(
  // Style
  style: "titled",              // Style name

  // Colors
  primary-color: rgb("#2c3e50"),
  secondary-color: rgb("#7f8c8d"),
  accent-color: rgb("#2980b9"),

  // Font sizes
  part-size: 24pt,
  chapter-size: 18pt,
  section-size: 14pt,
  subsection-size: 12pt,
  subsubsection-size: 11pt,

  // Numbering
  enable-parts: false,          // false: = Chapter, true: = Part and == Chapter
  show-part-number: true,
  show-chapter-number: true,
  show-section-number: true,
  show-subsection-number: true,
  show-chapter-in-section: true,
  part-numbering: auto,         // auto keeps the style default; or use "I", "A", ...
  chapter-numbering: auto,
  section-numbering: auto,      // e.g. "1.1"
  subsection-numbering: auto,   // e.g. "1.1.a"
  subsubsection-numbering: auto,

  // Prefixes (localization)
  part-prefix: "Partie",
  chapter-prefix: "Chapitre",
  section-prefix: "Section",

  // Page breaks
  part-fullpage: true,          // LaTeX-style: part gets its own centred page
  part-pagebreak: true,         // (inline mode) break before parts after the first
  chapter-pagebreak: false,

  // Table of Contents
  toc-style: none,              // Different style for TOC (none = same as headings)
  toc-indent: 1em,
  toc-part-size: 14pt,
  toc-fill: repeat[.],
)
```

### Custom numbering patterns

Use Typst numbering patterns to override the rendered numbers while keeping
beautitled's counters, table of contents, and `beautitled-ref` in sync.

```typst
#beautitled-setup(
  part-numbering: "A",
  chapter-numbering: "I",
  section-numbering: "I.1",
  subsection-numbering: "I.1.a",
  subsubsection-numbering: "I.1.a.i",
)
```

The default value is `auto`, which preserves each style's existing numbering
look.

## Table of Contents

```typst
// Basic TOC
#beautitled-toc()

// Custom title
#beautitled-toc(title: "Contents")

// Different style for TOC
#beautitled-toc(title: "Index", style: "elegant")
```

### Mix Heading and TOC Styles

```typst
#beautitled-setup(style: "titled")
#show: beautitled-init

// TOC uses "scholarly" style
#beautitled-toc(title: "Table of Contents", style: "scholarly")

= First Chapter
...
```

## Page Breaks

```typst
#beautitled-setup(
  style: "textbook",
  chapter-pagebreak: true,  // Page break before each chapter
)
#show: beautitled-init
```

## Language Presets

```typst
#preset-french()   // "Partie", "Chapitre", "Section"
#preset-english()  // "Part", "Chapter", "Section"
#preset-german()   // "Teil", "Kapitel", "Abschnitt"
#preset-no-numbers()
```

## Color Themes

```typst
#theme-ocean()   // Blue
#theme-forest()  // Green
#theme-royal()   // Purple
#theme-mono()    // Grayscale
#theme-warm()    // Orange/brown
#theme-coral()   // Red
```

## Manual & Demo

- Full manual: `manual.typ` / `manual.pdf`
- Style showcase: `demo.typ` / `demo.pdf`

## Changelog

### [0.2.7] - 2026-06-15

#### Added
- `beautitled-header(level: 1)` — new running-header function that returns the title of the most recent chapter (or section) for use in `#set page(header: ...)`, compatible with both `beautitled-init` and direct function calls
- `colon-space()` helper exported for French typographic colon spacing (inserts a non-breaking space before `:` when `text.lang == "fr"`)
- French colon spacing applied to part outline titles automatically
- Custom heading numbering patterns via `numbering-pattern` parameter (e.g. `"1."`, `"A."`, `"I."`) — all 19 themes support per-call overrides through `beautitled-init` and direct heading functions

#### Fixed
- `numbered: false` no longer advances the display counter — unnumbered headings no longer cause gaps in subsequent numbered headings (occurrence counters still increment for correct page-break behavior)
- `beautitled-init` counter undo corrected for multi-level counters — prevents doubled numbering when using native `= Heading` syntax

### v0.2.6 — 2026-06-09

#### Added
- `part-fullpage: true` (new default): each part gets its own vertically and horizontally centred page, matching LaTeX's `\part` behavior — each style has its own coherent part renderer
- `#part(fullpage: false)`: per-call override to use inline parts
- `#part(image: ...)`: optional image on the part page (fullpage mode only)
- `#part(image-caption: ...)`: caption rendered via Typst's native `figure`
- `#part(image-position: "above"|"below")`: place image above or below the title (default: `"below"`)

### v0.2.5 — 2026-06-09

#### Added
- `beautitled-ref` / `btl-ref`: cross-reference any labelled part, chapter, section, subsection, or subsubsection with a clickable, numbered link
  - `show-page: true` appends a page number
  - `short: true` shows the number without the prefix word (e.g. `1.1` instead of `Section 1.1`)
  - Prefix words respect the active language preset

### v0.2.0

- **Fix**: Use Unicode word joiners (`\u{2060}`) around dots in section numbering — prevents decimal-comma localization from rendering "1.2" as "1,2" in affected locales
- Applied to `lib.typ` and all 19 style files
- Compiler requirement updated to `0.14.2`

### v0.1.0

- Initial release: 19 styles, TOC support, language presets, color themes, show-rule integration

## License

MIT License - see LICENSE file for details.
