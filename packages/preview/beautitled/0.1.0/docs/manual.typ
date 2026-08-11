// beautitled - User Manual
// ============================================================================
#import "@preview/beautitled:0.1.0": *

#set page(margin: 2.5cm)
#set text(font: "Linux Libertine", size: 11pt)
#set par(justify: true)

#beautitled-setup(
  style: "modern",
  chapter-prefix: "Chapter",
  section-prefix: "Section",
)
#show: beautitled-init

#align(center)[
  #text(size: 32pt, weight: "bold")[beautitled]
  #v(0.5em)
  #text(size: 16pt, fill: gray)[User Manual]
  #v(0.3em)
  #text(size: 11pt, fill: gray)[Version 0.1.0]
  #v(0.5em)
  #text(size: 11pt)[Nathan Scheinmann]
]

#v(2em)

#beautitled-toc(title: "Table of Contents", style: "simple", title-align: left)

#pagebreak()

// ============================================================================
= Introduction

*beautitled* is a Typst package that provides 19 beautiful, print-friendly title styles for documents. It is designed for educational materials, academic papers, textbooks, and any document that needs professional heading styles.

== Features

- *19 distinctive styles* - From classic academic to modern creative
- *Print-friendly* - All styles use minimal ink (no heavy backgrounds)
- *Fully configurable* - Colors, sizes, spacing, and numbering
- *Multilingual* - Customizable prefixes for any language
- *Native Typst support* - Works with `= Heading` syntax
- *Four heading levels* - Chapter, section, subsection, subsubsection

// ============================================================================
= Quick Start

== Installation

```typst
#import "@preview/beautitled:0.1.0": *
```

== Basic Usage

```typst
#import "@preview/beautitled:0.1.0": *

#beautitled-setup(style: "titled")
#show: beautitled-init

= My Chapter Title
== My Section Title
=== My Subsection Title
==== My Subsubsection Title
```

// ============================================================================
= Configuration

All configuration is done through the `beautitled-setup` function. You can call it multiple times to change settings at any point in your document.

== Complete Parameter Reference

#table(
  columns: (auto, auto, 1fr),
  inset: 8pt,
  stroke: 0.4pt + gray,
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Parameter*], [*Default*], [*Description*],

  // Style
  [`style`], [`"titled"`], [The visual style to use (see Available Styles)],

  // Colors
  [`primary-color`], [`rgb("#2c3e50")`], [Main color for titles],
  [`secondary-color`], [`rgb("#7f8c8d")`], [Secondary color for labels and decorations],
  [`accent-color`], [`rgb("#2980b9")`], [Accent color for highlights],
  [`background-color`], [`white`], [Background color (rarely used)],

  // Font sizes
  [`chapter-size`], [`18pt`], [Font size for chapter titles],
  [`section-size`], [`14pt`], [Font size for section titles],
  [`subsection-size`], [`12pt`], [Font size for subsection titles],
  [`subsubsection-size`], [`11pt`], [Font size for subsubsection titles],

  // Numbering
  [`show-chapter-number`], [`true`], [Show chapter numbers],
  [`show-section-number`], [`true`], [Show section numbers],
  [`show-subsection-number`], [`true`], [Show subsection numbers],
  [`show-chapter-in-section`], [`true`], [Show chapter info in section labels (titled style)],

  // Prefixes
  [`chapter-prefix`], [`"Chapter"`], [Text before chapter number],
  [`section-prefix`], [`"Section"`], [Text before section number],

  // Spacing
  [`chapter-above`], [`1.2em`], [Space above chapters],
  [`chapter-below`], [`0.5em`], [Space below chapters],
  [`section-above`], [`0.5em`], [Space above sections],
  [`section-below`], [`0.4em`], [Space below sections],
  [`subsection-above`], [`0.5em`], [Space above subsections],
  [`subsection-below`], [`0.3em`], [Space below subsections],
)

// ============================================================================
= Available Styles

== Style Categories

=== Original
- *titled* - Boxed sections with floating labels showing chapter info (DEFAULT)

=== General Purpose
- *classic* - Traditional academic with underlines
- *modern* - Clean geometric with accent colors
- *elegant* - Refined with decorative ornaments
- *bold* - Strong left border emphasis
- *creative* - Student portfolio style
- *minimal* - Ultra-clean with maximum whitespace
- *vintage* - Classic book ornamental style

=== Educational
- *schoolbook* - Textbook style for lessons
- *notes* - Course notes and study materials
- *clean* - Maximum simplicity

=== Academic
- *technical* - Engineering documentation style
- *academic* - Professional academic with underlined chapters
- *textbook* - Bold numbers with clear hierarchy
- *scholarly* - Centered chapters with thin rules
- *classical* - Small caps, refined and minimal
- *educational* - Left border with large colored numbers
- *structured* - Boxed chapter numbers
- *magazine* - Editorial/magazine style

// ============================================================================
= Examples

== Example 1: Basic Document with Chapter

#image("/gallery/examples/example-1.png", width: 100%)

*Code:*
```typst
#beautitled-setup(style: "titled", show-chapter-in-section: true)
#show: beautitled-init

= Vector Geometry
== Vector Space
Lorem ipsum dolor sit amet...
=== Basic Definitions
Ut enim ad minim veniam...
```

== Example 2: Without Chapter (Sections Only)

#image("/gallery/examples/example-2.png", width: 100%)

*Code:*
```typst
#beautitled-setup(style: "titled", show-chapter-in-section: false)
#show: beautitled-init

== Vectors
Lorem ipsum dolor sit amet...
=== Vector Addition
Ut enim ad minim veniam...
```

== Example 3: Academic Style with Custom Colors

#image("/gallery/examples/example-3.png", width: 100%)

*Code:*
```typst
#beautitled-setup(
  style: "academic",
  primary-color: rgb("#1a5276"),
  secondary-color: rgb("#5dade2"),
  chapter-size: 20pt,
  section-size: 15pt,
)
#show: beautitled-init

= Introduction to Analysis
== Limits and Continuity
...
```

== Example 4: English Document

#image("/gallery/examples/example-4.png", width: 100%)

*Code:*
```typst
#beautitled-setup(
  style: "scholarly",
  chapter-prefix: "Chapter",
  section-prefix: "Section",
)
#show: beautitled-init

= Theoretical Framework
== Literature Review
...
```

== Example 5: Without Numbering

#image("/gallery/examples/example-5.png", width: 100%)

*Code:*
```typst
#beautitled-setup(
  style: "elegant",
  show-chapter-number: false,
  show-section-number: false,
  show-subsection-number: false,
)
#show: beautitled-init

= Poetry
== Flowers of Evil
...
```

== Example 6: Different Styles Comparison

#image("/gallery/examples/example-6.png", width: 100%)

// ============================================================================
= Table of Contents

beautitled provides a styled table of contents that matches your heading style.

== Basic Usage

```typst
#beautitled-toc()
```

== Custom Title

```typst
#beautitled-toc(title: "Contents")
#beautitled-toc(title: "Table of Contents")
#beautitled-toc(title: "Sommaire")
```

== Parameters

#table(
  columns: (auto, auto, 1fr),
  inset: 8pt,
  stroke: 0.4pt + gray,
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Parameter*], [*Default*], [*Description*],
  [`title`], [`"Table of Contents"`], [Title displayed above the TOC],
  [`depth`], [`3`], [Maximum heading level to include (1=chapters, 2=+sections, 3=+subsections)],
  [`style`], [`none`], [Override style for TOC (none = use heading style)],
  [`title-align`], [`center`], [Title alignment: `center`, `left`, or `right`],
)

== Simple Style with Sections Only

For a clean, flat TOC showing only sections (no chapters):

```typst
#beautitled-toc(
  title: "Table of Contents",
  style: "simple",
  title-align: left,
  depth: 2,  // Show chapters and sections only
)
```

== Mixing Styles

You can use different styles for your headings and TOC:

```typst
#beautitled-setup(style: "titled")
#show: beautitled-init

// TOC uses "scholarly" style
#beautitled-toc(title: "Contents", style: "scholarly")

= First Chapter
...
```

== TOC Configuration Options

These options can be set via `beautitled-setup`:

#table(
  columns: (auto, auto, 1fr),
  inset: 8pt,
  stroke: 0.4pt + gray,
  fill: (col, row) => if row == 0 { luma(230) } else { none },
  [*Parameter*], [*Default*], [*Description*],
  [`toc-style`], [`none`], [Different style for TOC (overrides heading style)],
  [`toc-indent`], [`1em`], [Indentation per level],
  [`toc-chapter-size`], [`12pt`], [Font size for chapters in TOC],
  [`toc-section-size`], [`11pt`], [Font size for sections in TOC],
  [`toc-subsection-size`], [`10pt`], [Font size for subsections in TOC],
  [`toc-fill`], [`repeat[.]`], [Fill between title and page number],
  [`toc-show-subsections`], [`true`], [Include subsections in TOC],
)

== Available TOC Styles (8)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #text(size: 9pt, weight: "bold")[titled] #text(size: 8pt, fill: gray)[(default)]
    #v(0.3em)
    #image("/gallery/toc/toc-titled.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[classic]
    #v(0.3em)
    #image("/gallery/toc/toc-classic.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[modern]
    #v(0.3em)
    #image("/gallery/toc/toc-modern.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[elegant]
    #v(0.3em)
    #image("/gallery/toc/toc-elegant.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[bold]
    #v(0.3em)
    #image("/gallery/toc/toc-bold.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[minimal]
    #v(0.3em)
    #image("/gallery/toc/toc-minimal.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[scholarly]
    #v(0.3em)
    #image("/gallery/toc/toc-scholarly.png", width: 100%)
  ],
  [
    #text(size: 9pt, weight: "bold")[simple]
    #v(0.3em)
    #image("/gallery/toc/toc-simple.png", width: 100%)
  ],
)

// ============================================================================
= Page Breaks

Enable automatic page breaks before chapters:

```typst
#beautitled-setup(
  style: "textbook",
  chapter-pagebreak: true,
)
#show: beautitled-init

= First Chapter
// Content...

= Second Chapter  // Automatic page break here
// Content...
```

Note: The first chapter does not trigger a page break.

// ============================================================================
= Built-in Presets

beautitled includes several presets for common configurations. Presets are called *before* `beautitled-init`:

== Complete Example

```typst
#import "@preview/beautitled:0.1.0": *

// 1. Choose a style
#beautitled-setup(style: "scholarly")

// 2. Apply language preset
#preset-english()

// 3. Apply color theme
#theme-ocean()

// 4. Initialize
#show: beautitled-init

= My Chapter
== My Section
```

== Language Presets

```typst
#preset-french()      // "Chapitre", "Section"
#preset-english()     // "Chapter", "Section"
#preset-german()      // "Kapitel", "Abschnitt"
#preset-no-numbers()  // Hide all numbering
```

== Color Themes

```typst
#theme-ocean()   // Blue tones
#theme-forest()  // Green tones
#theme-royal()   // Purple tones
#theme-mono()    // Grayscale
#theme-warm()    // Orange/brown tones
#theme-coral()   // Red tones
```

// ============================================================================
= Tips and Best Practices

== Choosing a Style

- *For math/science textbooks:* `titled`, `schoolbook`, `textbook`, `academic`
- *For course notes:* `notes`, `clean`, `minimal`
- *For formal academic papers:* `scholarly`, `classical`, `academic`
- *For creative projects:* `creative`, `modern`, `magazine`
- *For classic book feel:* `vintage`, `elegant`

== Print Considerations

All styles are designed to be print-friendly:
- No heavy background fills
- Thin strokes and borders
- High contrast text
- Minimal ink usage

== Combining with Other Packages

beautitled works well with other Typst packages. Just make sure to call `beautitled-setup` after importing the package.

// ============================================================================
= Changelog

== Version 0.1.0
- Initial release
- 19 styles
- Full configuration support
- Native Typst heading support
- Language presets
- Color themes
- Styled Table of Contents
- Page break support

#pagebreak()

// ============================================================================
// Style Showcase - not in TOC
#align(center)[
  #text(size: 24pt, weight: "bold")[Style Showcase]
  #v(0.3em)
  #text(size: 11pt, fill: gray)[All 19 available styles]
]
#v(1em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1em,
  [#text(size: 9pt, weight: "bold")[titled] #v(0.3em) #image("/gallery/styles/titled.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[classic] #v(0.3em) #image("/gallery/styles/classic.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[modern] #v(0.3em) #image("/gallery/styles/modern.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[elegant] #v(0.3em) #image("/gallery/styles/elegant.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[bold] #v(0.3em) #image("/gallery/styles/bold.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[creative] #v(0.3em) #image("/gallery/styles/creative.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[minimal] #v(0.3em) #image("/gallery/styles/minimal.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[vintage] #v(0.3em) #image("/gallery/styles/vintage.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[schoolbook] #v(0.3em) #image("/gallery/styles/schoolbook.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[notes] #v(0.3em) #image("/gallery/styles/notes.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[clean] #v(0.3em) #image("/gallery/styles/clean.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[technical] #v(0.3em) #image("/gallery/styles/technical.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[academic] #v(0.3em) #image("/gallery/styles/academic.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[textbook] #v(0.3em) #image("/gallery/styles/textbook.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[scholarly] #v(0.3em) #image("/gallery/styles/scholarly.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[classical] #v(0.3em) #image("/gallery/styles/classical.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[educational] #v(0.3em) #image("/gallery/styles/educational.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[structured] #v(0.3em) #image("/gallery/styles/structured.png", width: 100%)],
  [#text(size: 9pt, weight: "bold")[magazine] #v(0.3em) #image("/gallery/styles/magazine.png", width: 100%)],
)
