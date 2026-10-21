# beautitled

[![beautitled on Typst Universe](https://img.shields.io/badge/Typst_Universe-v._0.3.0-239dad?labelColor=eee)](https://typst.app/universe/package/beautitled)
[![Full package manual as PDF](https://img.shields.io/badge/Manual-pdf-333333?labelColor=eee)](https://github.com/nathan-ed/typst-package-beautitled/blob/7e64f98d858c8c31286a146969570de63288f137/docs/manual.pdf)
[![Distributed under the MIT license](https://img.shields.io/badge/License-MIT-333333?labelColor=eee)](LICENSE)

Sleek, print-friendly heading styles for chapters, sections, parts, and tables of contents. Perfect for textbooks, course materials, academic papers, and any document that needs professional heading styles.

## Features

- **3 next-generation styles** - A focused, sleeker collection for new documents
- **19 legacy styles** - Every existing style remains available with unchanged rendering
- **Print-friendly** - All styles use minimal ink (no heavy backgrounds)
- **Fully configurable** - Colors, sizes, spacing, and numbering
- **Styled Table of Contents** - Each style has a matching TOC design
- **Optional parts** - LaTeX-like parts above chapters
- **Page breaks** - Optional automatic page breaks before chapters
- **Multilingual** - Customizable prefixes for any language
- **Native Typst support** - Works with `= Heading` syntax
- **Cross-references** - `beautitled-ref` for labelled heading refs with optional page numbers

## Quick Start

```typst
#import "@preview/beautitled:0.3.0": *

#beautitled-setup(style: "anchor")
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

## Available Styles (22)

### Next-generation collection

These are the recommended choices for new documents. They use calmer
typographic contrast, tighter alignment, finer rules, and less decoration.

| Style | Best for | Character |
|-------|----------|-----------|
| `folio` | Essays, books, academic writing | Quiet contemporary editorial typography |
| `terrace` | Reports and course books | Number and title coupled in a tight, lower-set grid |
| `anchor` | Maximum clarity | One axis and one rail bind the label-number tag directly to the title |

`terrace` and `anchor` include curated vertical-spacing profiles and start
chapters on a new page by default. Passing explicit
`chapter-above`, `section-above`, or `chapter-pagebreak` values still wins.

The optional `heading-font` setting is especially effective with these styles:

```typst
#beautitled-setup(
  style: "anchor",
  heading-font: "Your Sans Font",
)
```

### Legacy collection (unchanged)

The original 19 style names and renderers are retained for output compatibility.

| Category | Style | Description |
|----------|-------|-------------|
| **Original** | `titled` | Boxed sections with floating labels (legacy default) |
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
    <td align="center"><img src="gallery/styles/folio.png" width="220" alt="folio style: restrained editorial hierarchy with an oversized chapter number"><br><strong>folio</strong></td>
    <td align="center"><img src="gallery/styles/terrace.png" width="220" alt="terrace style: lower-set chapter number and title in a tight two-column grid"><br><strong>terrace</strong><br><em>spacing-first</em></td>
    <td align="center"><img src="gallery/styles/anchor.png" width="220" alt="anchor style: lower-set chapter label number and title bound by a thin vertical rail"><br><strong>anchor</strong><br><em>clarity-first</em></td>
  </tr>
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
    <td align="center"><img src="gallery/parts/parts-folio.png" width="160" alt="folio style full-page part with restrained editorial typography"><br><strong>folio</strong></td>
    <td align="center"><img src="gallery/parts/parts-terrace.png" width="160" alt="terrace style full-page part with a tightly coupled number and title"><br><strong>terrace</strong></td>
    <td align="center"><img src="gallery/parts/parts-anchor.png" width="160" alt="anchor style full-page part with a grouped label number and title beside a fine rail"><br><strong>anchor</strong></td>
    <td></td>
  </tr>
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
    <td align="center"><img src="gallery/toc/toc-folio.png" width="200" alt="Table of contents in folio style with restrained editorial rules and a fixed page column"><br><strong>folio</strong></td>
    <td align="center"><img src="gallery/toc/toc-terrace.png" width="200" alt="Table of contents in terrace style using a strict leader-free alignment grid"><br><strong>terrace</strong></td>
    <td align="center"><img src="gallery/toc/toc-anchor.png" width="200" alt="Table of contents in anchor style with railed chapter groups and circled page markers"><br><strong>anchor</strong></td>
    <td></td>
  </tr>
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

### Interoperability: native `counter(heading)`

beautitled keeps Typst's built-in `counter(heading)` synchronized with its own
counters (part, chapter, section, ...). Packages that read the heading counter —
theorem numbering, exercise numbering (e.g. exercise-bank's
`number-prefix: "heading"`), running headers — therefore work out of the box,
in both native `= Heading` mode and direct function-call mode:

```typst
#context counter(heading).get()   // e.g. (2, 1) in chapter 1 of part 2
```

Without parts, the first component is the chapter number. With
`enable-parts: true`, it is the part number and the chapter comes second — a
package that only reads the first component should use beautitled's exported
`chapter-counter` instead.

## Table of Contents

```typst
// Basic TOC
#beautitled-toc()

// Custom title
#beautitled-toc(title: "Contents")

// Different style for TOC
#beautitled-toc(title: "Index", style: "elegant")
```

The new TOC systems deliberately solve different reading problems: `folio`
uses a fixed page-number column, `terrace` replaces leaders with a strict grid,
and `anchor` visually binds every chapter to its sections.

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

## Changelog

### [0.3.0] - 2026-07-14

#### Added
- Three opt-in next-generation styles: `folio`, `terrace`, and `anchor`
- Spacing-aware chapter-opening profiles for `terrace` and `anchor`; explicit spacing settings remain authoritative
- Matching part and table-of-contents renderers for all three styles
- Exported `beautitled-next-styles` and `beautitled-legacy-styles` registries
- New styles honor `heading-font` without changing legacy renderer output
- Native `counter(heading)` is now kept in sync with beautitled's internal counters (previously it stayed at zero), so heading-counter consumers — theorem packages, exercise-bank's `number-prefix: "heading"`, running headers — work without configuration

#### Compatibility
- All 19 existing style names still resolve to their original renderer
- The default remains `titled`; existing documents do not change unless they opt in

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
