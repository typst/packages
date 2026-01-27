#import "@preview/exercise-bank:0.3.0": *

// =============================================================================
// DOCUMENT SETUP
// =============================================================================

#set page(margin: (x: 1.8cm, y: 2cm))
#set text(size: 10.5pt, font: "New Computer Modern")
#set heading(numbering: "1.")
#set par(justify: true)

#show raw.where(lang: "typst"): it => block(
  fill: luma(97%),
  radius: 3pt,
  inset: 8pt,
  stroke: 0.5pt + luma(85%),
)[#it]

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Two-column example layout with code and preview
#let example(code, body) = block(breakable: false)[
  #table(
    columns: (1fr, 1fr),
    stroke: none,
    inset: 6pt,
    align: (left + top, left + top),
    [
      #set text(size: 8.5pt)
      *Code*
      #v(0.3em)
      #code
    ],
    [
      *Preview*
      #v(0.3em)
      #box(
        width: 100%,
        inset: (left: 1.8cm, right: 6pt, y: 6pt),
        radius: 3pt,
        stroke: 0.5pt + luma(85%),
        fill: luma(98%),
        clip: true,
      )[
        #set text(size: 9pt)
        // Use smaller font and margins for examples to fit in preview box
        #exo-setup(margin-position: 1.6cm, label-extra: 0.6cm, label-font-size: 9pt)
        #body
      ]
    ],
  )
  #v(0.5em)
]

/// Full-width example for larger previews
#let example-full(code, body) = block(breakable: false)[
  #set text(size: 8.5pt)
  *Code*
  #v(0.3em)
  #code
  #v(0.5em)
  *Preview*
  #v(0.3em)
  #box(
    width: 100%,
    inset: (left: 2.2cm, right: 8pt, y: 8pt),
    radius: 3pt,
    stroke: 0.5pt + luma(85%),
    fill: luma(98%),
    clip: true,
  )[
    #set text(size: 9.5pt)
    // Use smaller font and margins for examples to fit in preview box
    #exo-setup(margin-position: 2cm, label-extra: 0.6cm, label-font-size: 10pt)
    #body
  ]
  #v(0.8em)
]

// =============================================================================
// TITLE PAGE
// =============================================================================

#align(center)[
  #v(2cm)
  #text(size: 28pt, weight: "bold")[exercise-bank]
  #v(0.5em)
  #text(size: 16pt)[Typst Package]
  #v(1em)
  #text(size: 12pt, style: "italic")[Exercise Management & Banking System]
  #v(2cm)
  #line(length: 60%, stroke: 0.5pt)
  #v(1cm)
  #text(size: 11pt)[
    A comprehensive solution for creating, organizing, and filtering exercises\
    Version 0.3.0\
    Nathan Scheinmann
  ]
]

#pagebreak()

// =============================================================================
// TABLE OF CONTENTS
// =============================================================================

#outline(indent: 1em, depth: 2)

#pagebreak()

// =============================================================================
// INTRODUCTION
// =============================================================================

= Introduction

`exercise-bank` is a Typst package for creating and managing exercises with solutions, metadata, filtering, and exercise banks. Perfect for teachers, textbook authors, and educational content creators.

== Features

- Exercises with inline or deferred solutions
- Teacher corrections with fallback and append modes
- Draft mode for work-in-progress documents
- Multiple solution display modes
- Metadata support (topic, level, author, competencies)
- Exercise banks: define once, display anywhere
- Powerful filtering by any criteria
- Automatic numbering with reset options
- Customizable labels (localization support)

== Installation

Import the package in your Typst document:

```typst
#import "@preview/exercise-bank:0.3.0": exo, exo-setup
```

== Quick Start

#example-full(
  [```typst
#exo(
  exercise: [Solve the equation $2x + 5 = 13$.]
)
  ```],
  [
    #exo-setup(exercise-label: "Exercise", solution-label: "Solution")
    #exo(exercise: [Solve the equation $2x + 5 = 13$.])
  ]
)

#pagebreak()

// =============================================================================
// BASIC USAGE
// =============================================================================

= Basic Usage

== Simple Exercise

#example-full(
  [```typst
#exo(
  exercise: [Calculate $3 + 4 times 2$.]
)
  ```],
  [
    #exo-reset-counter()
    #exo(exercise: [Calculate $3 + 4 times 2$.])
  ]
)

== Exercise with Solution

#example-full(
  [```typst
#exo(
  exercise: [Calculate $3 + 4 times 2$.],
  solution: [$3 + 4 times 2 = 3 + 8 = 11$],
)
  ```],
  [
    #exo-reset-counter()
    #exo(
      exercise: [Calculate $3 + 4 times 2$.],
      solution: [$3 + 4 times 2 = 3 + 8 = 11$],
    )
  ]
)

== Multiple Exercises

Exercises are automatically numbered:

#example-full(
  [```typst
#exo(exercise: [Simplify $x^2 + 2x + 1$.])
#exo(exercise: [Factor $x^2 - 4$.])
#exo(exercise: [Solve $2x - 6 = 0$.])
  ```],
  [
    #exo-reset-counter()
    #exo(exercise: [Simplify $x^2 + 2x + 1$.])
    #exo(exercise: [Factor $x^2 - 4$.])
    #exo(exercise: [Solve $2x - 6 = 0$.])
  ]
)

#pagebreak()

// =============================================================================
// SOLUTION MODES
// =============================================================================

= Solution Display Modes

Control how and where solutions appear using `solution-mode`.

== Inline (Default)

Solutions appear immediately after each exercise:

#example-full(
  [```typst
#exo-setup(solution-mode: "inline")

#exo(
  exercise: [Solve $x + 3 = 7$.],
  solution: [$x = 4$],
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "inline")
    #exo(
      exercise: [Solve $x + 3 = 7$.],
      solution: [$x = 4$],
    )
  ]
)

== No Solutions

Hide all solutions (for student worksheets):

#example-full(
  [```typst
#exo-setup(solution-mode: "none")

#exo(
  exercise: [Solve $x + 3 = 7$.],
  solution: [$x = 4$],  // Hidden
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "none")
    #exo(
      exercise: [Solve $x + 3 = 7$.],
      solution: [$x = 4$],
    )
  ]
)

== Solutions at End of Section

Collect solutions and display them later:

#example-full(
  [```typst
#exo-setup(solution-mode: "end-section")

#exo(exercise: [Exercise 1], solution: [Answer 1])
#exo(exercise: [Exercise 2], solution: [Answer 2])

#exo-print-solutions()  // Print collected solutions
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "end-section")
    #exo(exercise: [Exercise 1], solution: [Answer 1])
    #exo(exercise: [Exercise 2], solution: [Answer 2])
    #exo-print-solutions()
  ]
)

== Solutions Only

Show only solutions (for answer keys):

#example-full(
  [```typst
#exo-setup(solution-mode: "only")

#exo(
  exercise: [This is hidden],
  solution: [Only this solution is shown],
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "only")
    #exo(
      exercise: [This is hidden],
      solution: [Only this solution is shown],
    )
  ]
)

#pagebreak()

// =============================================================================
// CORRECTIONS
// =============================================================================

= Corrections (Teacher Version)

Corrections are detailed solutions for teachers, including pedagogical notes and teaching tips.

== Exercise with Correction

#example-full(
  [```typst
#exo(
  exercise: [Solve $x^2 = 9$.],
  correction: [
    *Teacher notes:*
    $x = plus.minus 3$

    Common mistake: forgetting the negative root.
  ],
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "inline")
    #exo(
      exercise: [Solve $x^2 = 9$.],
      correction: [
        *Teacher notes:*
        $x = plus.minus 3$

        Common mistake: forgetting the negative root.
      ],
    )
  ]
)

== Fallback to Correction

When `fallback-to-correction` is enabled, corrections are shown when solutions are missing:

#example-full(
  [```typst
#exo-setup(fallback-to-correction: true)

#exo(
  exercise: [Simplify $2x + 3x$.],
  correction: [
    $2x + 3x = 5x$
    (Combine like terms)
  ],
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "inline", fallback-to-correction: true)
    #exo(
      exercise: [Simplify $2x + 3x$.],
      correction: [
        $2x + 3x = 5x$
        (Combine like terms)
      ],
    )
  ]
)

== Appending Solutions to Corrections

Combine corrections with solutions using custom formatting:

#example-full(
  [```typst
#exo-setup(
  append-solution-to-correction: true,
  solution-in-correction-style: (
    weight: "bold",
    fill: rgb("#1565c0"),
  ),
)

#exo(
  exercise: [Solve $x^2 = 9$.],
  correction: [
    Look for values where x squared equals 9.
    Don't forget both positive and negative roots.
  ],
  solution: [$x = 3$ or $x = -3$],
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(
      solution-mode: "inline",
      append-solution-to-correction: true,
      solution-in-correction-style: (
        weight: "bold",
        fill: rgb("#1565c0"),
      ),
    )
    #exo(
      exercise: [Solve $x^2 = 9$.],
      correction: [
        Look for values where x squared equals 9.
        Don't forget both positive and negative roots.
      ],
      solution: [$x = 3$ or $x = -3$],
    )
  ]
)

#pagebreak()

// =============================================================================
// DRAFT MODE
// =============================================================================

= Draft Mode

Show placeholders for incomplete exercises during document preparation.

== With Draft Mode ON

#example-full(
  [```typst
#exo-setup(
  draft-mode: true,
  solution-placeholder: [_[To be written]_],
)

#exo(
  exercise: [Solve $x + 5 = 12$],
  solution: [],  // Empty - shows placeholder
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(
      solution-mode: "inline",
      draft-mode: true,
      solution-placeholder: [_\[To be written\]_],
    )
    #exo(
      exercise: [Solve $x + 5 = 12$],
      solution: [],
    )
  ]
)

== With Draft Mode OFF (Default)

Empty solutions show minimal space without placeholders:

#example-full(
  [```typst
#exo-setup(draft-mode: false)

#exo(
  exercise: [Solve $x + 5 = 12$],
  solution: [],  // Empty - no placeholder
)
  ```],
  [
    #exo-reset-counter()
    #exo-setup(solution-mode: "inline", draft-mode: false)
    #exo(
      exercise: [Solve $x + 5 = 12$],
      solution: [],
    )
  ]
)

#pagebreak()

// =============================================================================
// EXERCISE BANKS
// =============================================================================

= Exercise Banks

Define exercises once, display them anywhere. Perfect for creating reusable exercise collections.

== Defining Bank Exercises

Use `exo-define` to register exercises without displaying them:

```typst
#exo-define(
  id: "quad-1",
  exercise: [Solve $x^2 - 5x + 6 = 0$.],
  topic: "quadratics",
  level: "1M",
  solution: [$x = 2$ or $x = 3$],
)

#exo-define(
  id: "geom-1",
  exercise: [Find the area of a circle with radius 5.],
  topic: "geometry",
  level: "1M",
  solution: [$A = 25pi$],
)
```

== Displaying Bank Exercises

Use `exo-show` to display a specific exercise:

#example-full(
  [```typst
#exo-show("quad-1")
  ```],
  [
    #exo-reset-counter()
    #exo-clear-registry()
    #exo-setup(solution-mode: "inline")
    #exo-define(
      id: "quad-1",
      exercise: [Solve $x^2 - 5x + 6 = 0$.],
      topic: "quadratics",
      level: "1M",
      solution: [$x = 2$ or $x = 3$],
    )
    #exo-show("quad-1")
  ]
)

== Selecting Multiple Exercises

Use `exo-select` with filters:

```typst
// All quadratics exercises
#exo-select(topic: "quadratics")

// Level 1M exercises only
#exo-select(level: "1M")

// Multiple topics
#exo-select(topics: ("quadratics", "geometry"))

// Limit count
#exo-select(topic: "algebra", max: 5)

// Custom filter
#exo-select(where: ex => ex.metadata.level == "hard")
```

== Including Exercises from External Files

For larger projects, organize exercises in separate files and import them as needed.

*File structure:*
```
project/
├── main.typ
├── exercises/
│   ├── algebra.typ
│   ├── geometry.typ
│   └── calculus.typ
```

*exercises/algebra.typ:*
```typst
#import "@preview/exercise-bank:0.3.0": exo-define

#exo-define(
  id: "alg-linear-1",
  exercise: [Solve $2x + 5 = 13$.],
  topic: "linear-equations",
  level: "1M",
  solution: [$x = 4$],
)

#exo-define(
  id: "alg-linear-2",
  exercise: [Solve $3x - 7 = 2x + 4$.],
  topic: "linear-equations",
  level: "1M",
  solution: [$x = 11$],
)

#exo-define(
  id: "alg-quadratic-1",
  exercise: [Solve $x^2 - 5x + 6 = 0$.],
  topic: "quadratics",
  level: "2M",
  solution: [$x = 2$ or $x = 3$],
)
```

*main.typ:*
```typst
#import "@preview/exercise-bank:0.3.0": *

// Import exercise definitions (registers them in the bank)
#include "exercises/algebra.typ"
#include "exercises/geometry.typ"

// Now use them anywhere in your document
= Linear Equations
#exo-select(topic: "linear-equations")

= Quadratics
#exo-select(topic: "quadratics")

// Or pick specific exercises
= Mixed Review
#exo-show("alg-linear-1")
#exo-show("alg-quadratic-1")
```

*Tips:*
- Use `#include` (not `#import`) to execute the file and register exercises
- Exercise IDs must be unique across all included files
- Exercises are registered globally, so include order doesn't matter for display

#pagebreak()

// =============================================================================
// METADATA & FILTERING
// =============================================================================

= Metadata and Filtering

== Adding Metadata

Tag exercises for organization and filtering:

```typst
#exo(
  exercise: [Solve $x + 1 = 5$.],
  topic: "algebra",
  level: "easy",
  authors: ("Prof. Smith",),
)
```

== Filtering Exercises

Display only exercises matching criteria:

```typst
#exo-filter(topic: "algebra")
#exo-filter(level: "easy")
#exo-filter(topic: "algebra", level: "hard")
```

#pagebreak()

// =============================================================================
// COMPETENCIES
// =============================================================================

= Competency Tags

Tag exercises with competencies and display them visually.

#example-full(
  [```typst
#exo-setup(show-competencies: true)

#exo-define(
  id: "comp-ex",
  exercise: [Solve and explain your reasoning.],
  competencies: ("C1.1", "C2.3", "C4.1"),
  solution: [Detailed solution here],
)

#exo-show("comp-ex")
  ```],
  [
    #exo-reset-counter()
    #exo-clear-registry()
    #exo-setup(solution-mode: "inline", show-competencies: true)
    #exo-define(
      id: "comp-ex",
      exercise: [Solve and explain your reasoning.],
      competencies: ("C1.1", "C2.3", "C4.1"),
      solution: [Detailed solution here],
    )
    #exo-show("comp-ex")
  ]
)

== Filter by Competency

```typst
#exo-select(competency: "C1.1")
#exo-select(competencies: ("C1.1", "C2.3"))
```

#pagebreak()

// =============================================================================
// CONFIGURATION
// =============================================================================

= Configuration

== Global Setup

Use `exo-setup` to configure defaults:

```typst
#exo-setup(
  solution-mode: "inline",
  exercise-label: "Exercise",
  solution-label: "Solution",
  correction-label: "Correction",
  counter-reset: "section",
  show-id: false,
  show-competencies: false,
  fallback-to-correction: false,
  append-solution-to-correction: false,
  draft-mode: false,
  badge-style: "box",      // "box", "circled", "filled-circle", "pill", "tag"
  badge-color: black,      // Color for badge
)
```

== Badge Styles

Change the visual style of exercise badges:

```typst
// Circled number (no label text)
#exo-setup(badge-style: "circled")

// Filled circle with white number
#exo-setup(badge-style: "filled-circle", badge-color: rgb("#2563eb"))

// Pill-shaped badge
#exo-setup(badge-style: "pill")

// Arrow tag
#exo-setup(badge-style: "tag", badge-color: rgb("#1e40af"))
```

Available styles: `"box"` (default), `"circled"`, `"filled-circle"`, `"pill"`, `"tag"`

== Localization

Change labels for different languages:

#example(
  [```typst
// French
#exo-setup(
  exercise-label: "Exercice",
  solution-label: "Solution",
)

// German
#exo-setup(
  exercise-label: "Aufgabe",
  solution-label: "Lösung",
)
  ```],
  [
    #text(size: 9pt)[
      *French:* Exercice, Solution\
      *German:* Aufgabe, Lösung\
      *Spanish:* Ejercicio, Solución
    ]
  ]
)

== Counter Reset Options

Control when numbering resets:

```typst
#exo-setup(counter-reset: "section")  // Reset each section
#exo-setup(counter-reset: "chapter")  // Reset each chapter
#exo-setup(counter-reset: "global")   // Never reset
```

Use hooks to trigger resets:

```typst
= New Section
#exo-section-start()  // Resets if counter-reset: "section"

= New Chapter
#exo-chapter-start()  // Resets if counter-reset: "chapter"
```

// =============================================================================
// VISUAL STYLES
// =============================================================================

= Visual Styles

Set the badge style with `exo-setup(badge-style: "...")`.

== Box (Default)

#example(
  [```typst
#exo-setup(badge-style: "box")
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "box")
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Circled

#example(
  [```typst
#exo-setup(badge-style: "circled")
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "circled")
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Filled Circle

#example(
  [```typst
#exo-setup(
  badge-style: "filled-circle",
  badge-color: rgb("#2563eb"),
)
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "filled-circle", badge-color: rgb("#2563eb"))
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Pill

#example(
  [```typst
#exo-setup(badge-style: "pill")
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "pill")
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Tag

#example(
  [```typst
#exo-setup(
  badge-style: "tag",
  badge-color: rgb("#1e40af"),
)
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "tag", badge-color: rgb("#1e40af"))
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Border Accent

#example(
  [```typst
#exo-setup(
  badge-style: "border-accent",
  badge-color: rgb("#3b82f6"),
)
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "border-accent", badge-color: rgb("#3b82f6"))
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Underline

#example(
  [```typst
#exo-setup(badge-style: "underline")
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "underline")
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Rounded Box

#example-full(
  [```typst
#exo-setup(badge-style: "rounded-box")
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "rounded-box")
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

== Header Card

#example-full(
  [```typst
#exo-setup(badge-style: "header-card", badge-color: rgb("#3b82f6"))
#exo(exercise: [Solve $x + 3 = 7$])
  ```],
  [
    #exo-reset-counter()
    #exo-setup(badge-style: "header-card", badge-color: rgb("#3b82f6"))
    #exo(exercise: [Solve $x + 3 = 7$])
  ]
)

#pagebreak()

// =============================================================================
// PARAMETER REFERENCE
// =============================================================================

= Parameter Reference

== `exo` Function

#table(
  columns: (1.2fr, 0.8fr, 0.8fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Parameter*], [*Type*], [*Default*], [*Description*],
  [`exercise`], [content], [none], [Exercise content (required)],
  [`solution`], [content], [none], [Solution content],
  [`correction`], [content], [none], [Correction for teachers],
  [`id`], [string], [auto], [Unique exercise ID],
  [`topic`], [string], [none], [Topic metadata],
  [`level`], [string], [none], [Difficulty level],
  [`authors`], [array], [()], [Author names],
)

== `exo-define` Function

Same as `exo`, plus:

#table(
  columns: (1.2fr, 0.8fr, 0.8fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Parameter*], [*Type*], [*Default*], [*Description*],
  [`competencies`], [array], [()], [Competency tags],
  [`points`], [number], [none], [Points (for exam mode)],
)

== `exo-select` Function

#table(
  columns: (1.2fr, 0.8fr, 0.8fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Parameter*], [*Type*], [*Default*], [*Description*],
  [`topic`], [string], [none], [Filter by topic],
  [`level`], [string], [none], [Filter by level],
  [`author`], [string], [none], [Filter by author],
  [`competency`], [string], [none], [Filter by competency],
  [`topics`], [array], [none], [Filter by any topic],
  [`levels`], [array], [none], [Filter by any level],
  [`competencies`], [array], [none], [Filter by any competency],
  [`where`], [function], [none], [Custom filter function],
  [`renumber`], [bool], [true], [Renumber sequentially],
  [`max`], [int], [none], [Maximum exercises],
)

== `exo-setup` Function

*Content & Behavior:*

#table(
  columns: (1.6fr, 0.8fr, 1fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Parameter*], [*Type*], [*Default*], [*Description*],
  [`solution-mode`], [string], ["inline"], ["inline", "end-section", "end-chapter", "none", "only"],
  [`exercise-label`], [string], ["Exercise"], [Label for exercises],
  [`solution-label`], [string], ["Solution"], [Label for solutions],
  [`correction-label`], [string], ["Correction"], [Label for corrections],
  [`counter-reset`], [string], ["section"], ["section", "chapter", "global"],
  [`show-id`], [bool], [false], [Show exercise IDs],
  [`show-competencies`], [bool], [false], [Show competency tags],
  [`show-metadata`], [bool], [false], [Show metadata],
  [`fallback-to-correction`], [bool], [false], [Show correction when solution missing],
  [`append-solution-to-correction`], [bool], [false], [Append solution to correction],
  [`draft-mode`], [bool], [false], [Show placeholders for empty content],
  [`solution-placeholder`], [content], [_To be completed_], [Placeholder text],
  [`correction-placeholder`], [content], [_To be completed_], [Placeholder text],
)

#v(0.5em)
*Visual Styling:*

#table(
  columns: (1.6fr, 0.8fr, 1fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Parameter*], [*Type*], [*Default*], [*Description*],
  [`badge-style`], [string], ["box"], [Style: "box", "circled", "filled-circle", "pill", "tag", "border-accent", "underline", "rounded-box", "header-card"],
  [`badge-color`], [color], [black], [Color for exercise badges],
  [`solution-color`], [color], [green], [Color for solution badges],
  [`correction-color`], [color], [green], [Color for correction badges],
  [`label-font-size`], [length], [12pt], [Font size for badge labels],
  [`margin-position`], [length/auto], [auto], [Width reserved for badge column (auto = computed from label)],
  [`label-extra`], [length], [1cm], [Extra space for labels to extend into left margin],
)

#pagebreak()

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

= Utility Functions

#table(
  columns: (1fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Function*], [*Description*],
  [`exo-reset-counter()`], [Reset exercise numbering to 0],
  [`exo-clear-registry()`], [Clear all registered exercises],
  [`exo-section-start()`], [Call at section start (triggers reset if configured)],
  [`exo-chapter-start()`], [Call at chapter start (triggers reset if configured)],
  [`exo-print-solutions()`], [Print collected solutions (for end-section/chapter modes)],
  [`exo-count(topic: ..)`], [Count exercises matching criteria],
  [`exo-show("id")`], [Display exercise by ID],
  [`exo-show-many("a", "b")`], [Display multiple exercises by ID],
  [`exo-filter(topic: ..)`], [Filter and display matching exercises],
)
