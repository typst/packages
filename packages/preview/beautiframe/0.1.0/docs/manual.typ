#import "@preview/beautiframe:0.1.0": *

#set document(title: "Beautiframe Manual", author: "Nathan Scheinmann")
#set page(
  margin: (x: 2.5cm, y: 2cm),
  header: context {
    if counter(page).get().first() > 1 [
      #text(size: 9pt, fill: gray)[Beautiframe Manual #h(1fr) #counter(page).display()]
    ]
  }
)
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(justify: true)

// Title page
#align(center)[
  #v(3cm)
  #text(size: 32pt, weight: "bold")[Beautiframe]
  #v(0.5em)
  #text(size: 16pt, fill: gray)[Beautiful Theorem-Like Environments for Typst]
  #v(1em)
  #text(size: 12pt)[Version 0.1.0]
  #v(2cm)
  #text(size: 11pt)[Nathan Scheinmann]
  #v(4cm)
]

#pagebreak()

#outline(indent: auto, depth: 3)

#pagebreak()

= Introduction

*Beautiframe* is a Typst package for creating beautiful theorem-like environments (theorems, definitions, lemmas, proofs, etc.) with multiple visual styles.

== Features

- *7 distinct styles*: classic, modern, elegant, colorful, boxed, minimal, academic
- *6 variants per style*: prominent, standard, subtle, accent, minimal, inline
- *Flexible mapping*: Assign any variant to any environment type
- *Independent counters*: Each environment type has its own counter
- *Customizable labels*: Change "Theorem" to "Théorème", "Satz", etc.
- *QED symbol presets*: □, ■, ∎, CQFD, //, Q.E.D.
- *Color themes*: Pre-built themes (ocean, forest, sunset, lavender)
- *Language presets*: French, German, Spanish
- *Print-friendly modes*: color, grayscale, black & white

== Quick Start

```typst
#import "@preview/beautiframe:0.1.0": *

#theorem(name: "Pythagorean")[
  In a right triangle: $a^2 + b^2 = c^2$
]

#definition[
  A *limit* is the value that a function approaches.
]

#proof[
  The proof is left as an exercise.
]
```

#pagebreak()

= Environments

== Available Environments

Beautiframe provides 8 environment types:

#table(
  columns: (auto, auto, auto, auto),
  align: (left, left, center, left),
  [*Environment*], [*Default Variant*], [*Counter*], [*Usage*],
  [`theorem`], [prominent], [Optional], [Main results],
  [`definition`], [standard], [Optional], [Foundational concepts],
  [`lemma`], [standard], [Optional], [Supporting results],
  [`proposition`], [standard], [Optional], [Secondary results],
  [`corollary`], [standard], [Optional], [Consequences],
  [`remark`], [subtle], [Optional], [Commentary],
  [`example`], [accent], [Optional], [Illustrations],
  [`proof`], [(special)], [No], [Demonstrations],
)

== Basic Usage

Each environment function accepts:
- `name`: Optional name (e.g., "Pythagorean")
- `number`: `auto` (default), `none`, or custom value
- `body`: The content

```typst
#theorem(name: "Fermat's Last")[
  There are no positive integers $a$, $b$, $c$ such that
  $a^n + b^n = c^n$ for $n > 2$.
]
```

#beautiframe-setup(style: "classic")
#beautiframe-reset()

#theorem(name: "Fermat's Last")[
  There are no positive integers $a$, $b$, $c$ such that
  $a^n + b^n = c^n$ for $n > 2$.
]

== Numbering Control

=== Automatic Numbering (default)

```typst
#theorem[First theorem]   // Theorem 1
#theorem[Second theorem]  // Theorem 2
```

=== No Numbering

```typst
#theorem(number: none)[Unnumbered theorem]
#definition(number: none)[Unnumbered definition]
```

#theorem(number: none, name: "Example")[This theorem has no number.]

=== Custom Numbering

```typst
#theorem(number: "A")[Special theorem A]
#theorem(number: "★")[Starred theorem]
```

#theorem(number: "A")[Special theorem A]

=== Numbered Remarks

By default, remarks have no number. To number them:

```typst
#remark(number: auto)[This remark will be numbered.]
```

#remark(number: auto)[This remark is numbered.]
#remark[This remark is not numbered (default).]

=== Counter Reset

Reset all counters manually:

```typst
#beautiframe-reset()
```

#pagebreak()

= Styles

Beautiframe includes 7 visual styles. Each style provides 6 variants.

== Classic Style

Traditional textbook layout with badge on the left and content with left border. Based on the exercise-bank pattern.

```typst
#beautiframe-setup(style: "classic")
#theorem(name: "Classic")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
#remark[This is the default style.]
```

#beautiframe-setup(style: "classic")
#beautiframe-reset()

#theorem(name: "Classic")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
#remark[This is the default style.]

== Modern Style

Contemporary design with thick accent bars and rule separators.

```typst
#beautiframe-setup(style: "modern")
#theorem(name: "Modern")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
```

#beautiframe-setup(style: "modern")
#beautiframe-reset()

#theorem(name: "Modern")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]

== Elegant Style

Sophisticated styling with centered headers and decorative ornaments.

```typst
#beautiframe-setup(style: "elegant")
#theorem(name: "Elegant")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
```

#beautiframe-setup(style: "elegant")
#beautiframe-reset()

#theorem(name: "Elegant")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]

== Colorful Style

Each environment type has a distinct color for visual differentiation.

```typst
#beautiframe-setup(style: "colorful")
#theorem[Red for theorems.]
#definition[Blue for definitions.]
#example[Green for examples.]
```

#beautiframe-setup(style: "colorful")
#beautiframe-reset()

#theorem[Red for theorems.]
#definition[Blue for definitions.]
#example[Green for examples.]

== Boxed Style

Full framed boxes with optional backgrounds and header bars.

```typst
#beautiframe-setup(style: "boxed", border-radius: 3pt)
#theorem(name: "Boxed")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
```

#beautiframe-setup(style: "boxed", border-radius: 3pt)
#beautiframe-reset()

#theorem(name: "Boxed")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]

== Minimal Style

Ultra-clean, print-friendly. Minimal ink usage.

```typst
#beautiframe-setup(style: "minimal")
#theorem(name: "Minimal")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
```

#beautiframe-setup(style: "minimal")
#beautiframe-reset()

#theorem(name: "Minimal")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]

== Academic Style

Formal research paper style matching AMS/journal conventions.

```typst
#beautiframe-setup(style: "academic")
#theorem(name: "Academic")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]
```

#beautiframe-setup(style: "academic")
#beautiframe-reset()

#theorem(name: "Academic")[In a right triangle: $a^2 + b^2 = c^2$]
#definition[A continuous function preserves limits.]

#pagebreak()

= Variants

Each style provides variants that can be assigned to any environment type. The 6 core variants are available in all styles:

#table(
  columns: (auto, 1fr, auto),
  [*Variant*], [*Description*], [*Default for*],
  [`prominent`], [Strongest visual emphasis, thick borders, bold colors], [theorem],
  [`standard`], [Normal, balanced styling], [definition, lemma, proposition, corollary],
  [`subtle`], [Lighter, less prominent, muted colors], [remark],
  [`accent`], [Uses environment-specific color], [example],
  [`minimal`], [Very light styling, minimal visual elements], [—],
  [`inline`], [No structural elements, flows with text], [—],
)

*Boxed style* has 3 additional variants:

#table(
  columns: (auto, 1fr),
  [*Variant*], [*Description*],
  [`titled`], [Label breaks the top border line (beautitled-style)],
  [`centered`], [Label centered at top, breaking the border],
  [`corner`], [L border (top + left sides)],
  [`corner2`], [Inverted L border (left + bottom sides)],
)

== Assigning Variants

Map any variant to any environment type:

```typst
#beautiframe-setup(
  theorem-variant: "prominent",  // Theorems get maximum emphasis
  lemma-variant: "subtle",       // Lemmas are de-emphasized
  remark-variant: "inline",      // Remarks flow inline
  example-variant: "accent",     // Examples use their color
)
```

== Visual Gallery: All Variants × All Styles

#pagebreak()

=== Classic Style

#beautiframe-setup(style: "classic")
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

=== Modern Style

#beautiframe-setup(style: "modern")
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

=== Elegant Style

#beautiframe-setup(style: "elegant")
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

=== Colorful Style

#beautiframe-setup(style: "colorful")
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

=== Boxed Style

#beautiframe-setup(style: "boxed", border-radius: 3pt)
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
  [*Titled:* #beautiframe-setup(theorem-variant: "titled") #theorem(name: "Name")[Sample text.]],
  [*Centered:* #beautiframe-setup(theorem-variant: "centered") #theorem(name: "Name")[Sample text.]],
  [*Corner:* #beautiframe-setup(theorem-variant: "corner") #theorem(name: "Name")[Sample text.]],
  [*Corner2:* #beautiframe-setup(theorem-variant: "corner2") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

=== Minimal Style

#beautiframe-setup(style: "minimal")
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

=== Academic Style

#beautiframe-setup(style: "academic")
#beautiframe-reset()

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.8em,
  [*Prominent:* #beautiframe-setup(theorem-variant: "prominent") #theorem(name: "Name")[Sample text.]],
  [*Standard:* #beautiframe-setup(theorem-variant: "standard") #theorem(name: "Name")[Sample text.]],
  [*Subtle:* #beautiframe-setup(theorem-variant: "subtle") #theorem(name: "Name")[Sample text.]],
  [*Accent:* #beautiframe-setup(theorem-variant: "accent") #theorem(name: "Name")[Sample text.]],
  [*Minimal:* #beautiframe-setup(theorem-variant: "minimal") #theorem(name: "Name")[Sample text.]],
  [*Inline:* #beautiframe-setup(theorem-variant: "inline") #theorem(name: "Name")[Sample text.]],
)

#pagebreak()

= Proofs and QED Symbols

== Basic Proof

```typst
#proof[
  By direct calculation, we have $2^2 = 4$.
]
```

#beautiframe-setup(style: "classic", theorem-variant: "standard")

#proof[
  By direct calculation, we have $2^2 = 4$.
]

== QED Symbol Presets

Beautiframe provides several QED symbol presets:

```typst
#qed-square()     // □ (default)
#qed-filled()     // ■
#qed-tombstone()  // ∎
#qed-cqfd()       // CQFD (French)
#qed-slashes()    // //
#qed-text()       // Q.E.D.
#qed-none()       // (no symbol)
```

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [
    *Default (□):*
    #qed-square()
    #proof[Hollow square.]
  ],
  [
    *Filled (■):*
    #qed-filled()
    #proof[Filled square.]
  ],
  [
    *Tombstone (∎):*
    #qed-tombstone()
    #proof[Tombstone symbol.]
  ],
  [
    *CQFD:*
    #qed-cqfd()
    #proof[French style.]
  ],
  [
    *Slashes:*
    #qed-slashes()
    #proof[Double slash.]
  ],
  [
    *Q.E.D.:*
    #qed-text()
    #proof[Latin abbreviation.]
  ],
)

== Custom QED Symbol

```typst
#beautiframe-setup(qed-symbol: text(fill: green, sym.checkmark))
```

#beautiframe-setup(qed-symbol: text(size: 1.4em, fill: rgb("#27ae60"), sym.checkmark))
#proof[Custom green checkmark.]

#beautiframe-setup(qed-symbol: sym.square.stroked)

#pagebreak()

= Colors and Themes

== Global Colors

```typst
#beautiframe-setup(
  primary-color: rgb("#1a5276"),
  secondary-color: rgb("#7f8c8d"),
  accent-color: rgb("#2980b9"),
)
```

== Per-Environment Colors

Used primarily by the colorful style:

```typst
#beautiframe-setup(
  theorem-color: rgb("#c0392b"),    // Red
  definition-color: rgb("#2980b9"), // Blue
  lemma-color: rgb("#8e44ad"),      // Purple
  example-color: rgb("#27ae60"),    // Green
  remark-color: rgb("#7f8c8d"),     // Gray
)
```

== Color Themes

Pre-built color schemes:

#beautiframe-setup(style: "colorful")

*Ocean Theme:*
#theme-ocean()
#beautiframe-reset()
#theorem(number: none)[Blue tones throughout.]

*Forest Theme:*
#theme-forest()
#beautiframe-reset()
#theorem(number: none)[Green tones throughout.]

*Sunset Theme:*
#theme-sunset()
#beautiframe-reset()
#theorem(number: none)[Warm red and orange tones.]

*Lavender Theme:*
#theme-lavender()
#beautiframe-reset()
#theorem(number: none)[Purple tones throughout.]

== Print-Friendly Modes

For B&W printing:

```typst
#beautiframe-setup(color-mode: "color")      // Full color (default)
#beautiframe-setup(color-mode: "grayscale")  // Grayscale
#beautiframe-setup(color-mode: "bw")         // Pure black and white
```

#beautiframe-setup(style: "boxed", border-radius: 3pt)

*Color mode:*
#beautiframe-setup(color-mode: "color")
#beautiframe-reset()
#theorem(number: none)[Full color styling.]

*Grayscale mode:*
#beautiframe-setup(color-mode: "grayscale")
#beautiframe-reset()
#theorem(number: none)[Grayscale for B&W printers.]

*B&W mode:*
#beautiframe-setup(color-mode: "bw")
#beautiframe-reset()
#theorem(number: none)[Pure black and white.]

#beautiframe-setup(color-mode: "color")

#pagebreak()

= Language Presets

== French

```typst
#preset-french()
```

#beautiframe-setup(style: "classic")
#preset-french()
#beautiframe-reset()

#theorem(name: "Pythagore")[Dans un triangle rectangle: $a^2 + b^2 = c^2$]
#definition[Une fonction continue préserve les limites.]
#proof[Immédiat.]

== German

```typst
#preset-german()
```

#preset-german()
#beautiframe-reset()

#theorem(name: "Pythagoras")[In einem rechtwinkligen Dreieck: $a^2 + b^2 = c^2$]
#definition[Eine stetige Funktion erhält Grenzwerte.]
#proof[Offensichtlich.]

== Spanish

```typst
#preset-spanish()
```

#preset-spanish()
#beautiframe-reset()

#theorem(name: "Pitágoras")[En un triángulo rectángulo: $a^2 + b^2 = c^2$]
#definition[Una función continua preserva límites.]
#proof[Inmediato.]

== Custom Labels

```typst
#beautiframe-setup(
  theorem-label: "Théorème",
  definition-label: "Définition",
  proof-label: "Démonstration",
)
```

#pagebreak()

= Layout Configuration

== Classic Style Layout

The classic style uses a grid layout with configurable dimensions:

```typst
#beautiframe-setup(
  line-position: 2cm,   // Distance from left to vertical line
  label-extra: 1cm,     // Extension into left margin
  border-width: 1.5pt,  // Line thickness
)
```

== Spacing

```typst
#beautiframe-setup(
  theorem-above: 1.2em,   // Space before theorems
  theorem-below: 1em,     // Space after theorems
  header-gap: 0.4em,      // Gap between label and body
)
```

== Typography

Control label appearance:

```typst
#beautiframe-setup(
  label-weight: "bold",   // "bold", "regular", "semibold", etc.
  label-size: 11pt,       // Size of "Theorem", "Definition", etc.
  name-style: "italic",   // Style for theorem names: "italic" or "normal"
)
```

#beautiframe-setup(style: "boxed", border-radius: 3pt)
#beautiframe-reset()

*Bold label (default):*
#beautiframe-setup(label-weight: "bold")
#theorem(name: "Name")[Sample text.]

*Regular label:*
#beautiframe-setup(label-weight: "regular")
#theorem(name: "Name")[Sample text.]

#beautiframe-setup(label-weight: "bold")

== Boxed Style Options

```typst
#beautiframe-setup(
  inset: (x: 1em, y: 0.8em),  // Padding inside boxes
  border-radius: 4pt,         // Rounded corners
  border-width: 1.5pt,        // Border thickness
)
```

= Custom Environments

Create your own environment types with independent counters using `new-env`:

```typst
// Create custom environments
#let conjecture = new-env("Conjecture", base: "theorem")
#let propriete = new-env("Propriété", base: "definition", numbered: false)
#let formule = new-env("Formule", base: "lemma", color: green)
#let axiom = new-env("Axiom", base: "theorem", numbered: true)

// Use them like built-in environments
#conjecture[Every even number greater than 2 is the sum of two primes.]
#conjecture(name: "Goldbach")[Famous unsolved problem.]
#propriete[A property without number.]
#formule[The quadratic formula: $x = (-b plus.minus sqrt(b^2-4a c))/(2a)$]
```

#let conjecture = new-env("Conjecture", base: "theorem")
#let axiom = new-env("Axiom", base: "definition")

#beautiframe-setup(style: "boxed", theorem-variant: "titled", definition-variant: "titled")
#beautiframe-reset()

#conjecture[Every even number greater than 2 is the sum of two primes.]

#conjecture(name: "Goldbach")[Famous unsolved problem in number theory.]

#axiom[Two points determine a unique line.]

== Parameters

```typst
#let my-env = new-env(
  "Label",           // Display label (required)
  base: "theorem",   // Inherit style from: theorem, definition, lemma, etc.
  numbered: true,    // Auto-number by default
  color: none,       // Optional custom color
)
```

== Plural Forms

All environments support a `plural` parameter. Default plurals are provided for English and all language presets:

```typst
#theorem(plural: true)[Multiple theorems grouped together.]
#definition(plural: true)[Several related definitions.]
```

#beautiframe-setup(style: "boxed", theorem-variant: "titled")
#beautiframe-reset()

#theorem[A single theorem.]

#theorem(plural: true)[Multiple theorems can be grouped in one box.]

Language presets automatically set the correct plural forms:

```typst
#preset-french()  // Sets: Théorèmes, Définitions, Lemmes, etc.
#preset-german()  // Sets: Sätze, Definitionen, Lemmata, etc.
#preset-spanish() // Sets: Teoremas, Definiciones, Lemas, etc.
```

Custom environments also support plurals:

```typst
#let conjecture = new-env("Conjecture", plural: "Conjectures", base: "theorem")
#conjecture(plural: true)[Two famous conjectures.]
```

== Resetting Custom Counters

```typst
#reset-env("Conjecture")  // Reset specific custom environment
#beautiframe-reset()      // Reset all built-in counters
```

#pagebreak()

= API Reference

== Environment Functions

```typst
#theorem(name: none, number: auto)[body]
#definition(name: none, number: auto)[body]
#lemma(name: none, number: auto)[body]
#proposition(name: none, number: auto)[body]
#corollary(name: none, number: auto)[body]
#remark(name: none, number: none)[body]
#example(name: none, number: auto)[body]
#proof[body]
```

== Setup Function

#text(size: 9pt)[
```typst
#beautiframe-setup(
  style: "classic",              // Style selection
  // Variant mapping
  theorem-variant: "prominent",
  definition-variant: "standard",
  lemma-variant: "standard",
  proposition-variant: "standard",
  corollary-variant: "standard",
  remark-variant: "subtle",
  example-variant: "accent",
  // Colors
  primary-color: rgb("#2c3e50"),
  secondary-color: rgb("#7f8c8d"),
  accent-color: rgb("#2980b9"),
  theorem-color: rgb("#c0392b"),
  definition-color: rgb("#2980b9"),
  // ... (more per-environment colors)
  // Typography
  label-size: 11pt,
  label-weight: "bold",
  name-style: "italic",
  // Spacing
  theorem-above: 1em,
  theorem-below: 0.8em,
  header-gap: 0.3em,
  // Layout
  inset: (x: 0.8em, y: 0.6em),
  border-width: 1pt,
  border-radius: 0pt,
  line-position: 2cm,
  label-extra: 1cm,
  // Numbering
  link-to-section: false,
  // Labels
  theorem-label: "Theorem",
  definition-label: "Definition",
  // ... (more labels)
  proof-label: "Proof",
  // QED
  qed-symbol: sym.square.stroked,
  // Advanced
  breakable: true,
  color-mode: "color",
)
```
]

== Utility Functions

```typst
#beautiframe-reset()    // Reset all counters

// Language presets
#preset-french()
#preset-german()
#preset-spanish()

// Color themes
#theme-ocean()
#theme-forest()
#theme-sunset()
#theme-lavender()

// QED presets
#qed-square()      // □
#qed-filled()      // ■
#qed-tombstone()   // ∎
#qed-cqfd()        // CQFD
#qed-slashes()     // //
#qed-text()        // Q.E.D.
#qed-none()        // (none)
```
