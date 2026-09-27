# beautitled

A Typst package for creating beautiful, print-friendly title styles for documents. Perfect for textbooks, course materials, academic papers, and any document that needs professional heading styles.

## Features

- **19 distinctive styles** - From classic academic to modern creative
- **Print-friendly** - All styles use minimal ink (no heavy backgrounds)
- **Fully configurable** - Colors, sizes, spacing, and numbering
- **Styled Table of Contents** - Each style has a matching TOC design
- **Page breaks** - Optional automatic page breaks before chapters
- **Multilingual** - Customizable prefixes for any language
- **Native Typst support** - Works with `= Heading` syntax
- **Cross-references** - Full outline and bookmark support

**[View the full manual (PDF)](https://github.com/nathan-ed/typst-package-beautitled/blob/a0af23f163d15326c7034c252c239400550a3bdf/docs/manual.pdf)**

## Quick Start

```typst
#import "@preview/beautitled:0.2.0": *

#beautitled-setup(style: "titled")
#show: beautitled-init

= My Chapter Title
== My Section Title
=== My Subsection Title
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
  chapter-size: 18pt,
  section-size: 14pt,
  subsection-size: 12pt,
  subsubsection-size: 11pt,

  // Numbering
  show-chapter-number: true,
  show-section-number: true,
  show-subsection-number: true,
  show-chapter-in-section: true,

  // Prefixes (localization)
  chapter-prefix: "Chapitre",
  section-prefix: "Section",

  // Page breaks
  chapter-pagebreak: false,

  // Table of Contents
  toc-style: none,              // Different style for TOC (none = same as headings)
  toc-indent: 1em,
  toc-fill: repeat[.],
)
```

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
#preset-french()   // "Chapitre", "Section"
#preset-english()  // "Chapter", "Section"
#preset-german()   // "Kapitel", "Abschnitt"
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

### v0.2.0

- **Fix**: Use Unicode word joiners (`\u{2060}`) around dots in section numbering — prevents decimal-comma localization from rendering "1.2" as "1,2" in affected locales
- Applied to `lib.typ` and all 19 style files
- Compiler requirement updated to `0.14.2`

### v0.1.0

- Initial release: 19 styles, TOC support, language presets, color themes, show-rule integration

## License

MIT License - see LICENSE file for details.
