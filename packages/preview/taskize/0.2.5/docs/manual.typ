#import "@preview/taskize:0.2.5": tasks, tasks2, tasks3, tasks4, tasks-reset, tasks-setup

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
    align: (left + top, center + top),
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
        inset: 6pt,
        radius: 3pt,
        stroke: 0.5pt + luma(85%),
        fill: luma(98%),
      )[
        #set text(size: 9pt)
        #body
      ]
    ],
  )
  #v(0.5em)
]

// =============================================================================
// TITLE PAGE
// =============================================================================

#align(center)[
  #v(2cm)
  #text(size: 28pt, weight: "bold")[taskize]
  #v(0.5em)
  #text(size: 16pt)[Typst Package]
  #v(1em)
  #text(size: 12pt, style: "italic")[Horizontal Columned Lists]
  #v(2cm)
  #line(length: 60%, stroke: 0.5pt)
  #v(1cm)
  #text(size: 11pt)[
    A compact list layout for exercises and multiple-choice questions\
    Version 0.2.6\
    Nathan Scheinmann
  ]
]

#pagebreak()

// =============================================================================
// TABLE OF CONTENTS
// =============================================================================

#outline(indent: 1em)

#pagebreak()

// =============================================================================
// INTRODUCTION
// =============================================================================

= Introduction

`taskize` is a Typst package for horizontal, columned task lists. Items flow left-to-right across columns, making it ideal for exercises, quizzes, and compact lists that need a tidy grid.

== Features

- Indentation-independent parsing
- Horizontal or vertical flow directions
- Flexible column counts and column spanning
- Multiple label formats and custom label functions
- Resume numbering across task blocks
- Fine-grained spacing and alignment controls

== Installation

Import the package in your Typst document:

```typst
#import "@preview/taskize:0.2.5": tasks
```

== Quick Start

#example(
  [```typst
  #tasks[
    + First item
    + Second item
    + Third item
    + Fourth item
  ]
  ```],
  [#tasks[
    + First item
    + Second item
    + Third item
    + Fourth item
  ]]
)

// =============================================================================
// BASIC USAGE
// =============================================================================

= Basic Usage

== Column Counts

Use `columns:` or shorthand functions (`tasks2`, `tasks3`, `tasks4`) for quick layouts.

#example(
  [```typst
  #tasks(columns: 3)[
    + Option A
    + Option B
    + Option C
    + Option D
    + Option E
    + Option F
  ]
  ```],
  [#tasks(columns: 3)[
    + Option A
    + Option B
    + Option C
    + Option D
    + Option E
    + Option F
  ]]
)

#example(
  [```typst
  #tasks3[
    + Item 1
    + Item 2
    + Item 3
    + Item 4
    + Item 5
    + Item 6
  ]
  ```],
  [#tasks3[
    + Item 1
    + Item 2
    + Item 3
    + Item 4
    + Item 5
    + Item 6
  ]]
)

== Labels and Formats

#example(
  [```typst
  #tasks(label: "A)")[+ Alpha + Beta + Gamma]
  #tasks(label: "(1)")[+ One + Two + Three]
  #tasks(label: n => "Q" + str(n) + ":")[
    + What is 2 + 2?
    + What is the capital of France?
    + What color is the sky?
  ]
  ```],
  [
    #tasks(label: "A)")[+ Alpha + Beta + Gamma]
    #v(0.4em)
    #tasks(label: "(1)")[+ One + Two + Three]
    #v(0.4em)
    #tasks(label: n => "Q" + str(n) + ":")[
      + What is 2 + 2?
      + What is the capital of France?
      + What color is the sky?
    ]
  ]
)

== Column Spanning

Use `(N)` to span N columns or `()` to span all columns.

#example(
  [```typst
  #tasks(columns: 3)[
    + (2) Long statement spanning two columns
    + Short
    + () Full width note across all columns
    + Another
  ]
  ```],
  [#tasks(columns: 3)[
    + (2) Long statement spanning two columns
    + Short
    + () Full width note across all columns
    + Another
  ]]
)

== Flow Direction

Horizontal is default. Use `flow: "vertical"` to fill columns top-to-bottom.

#example(
  [```typst
  #tasks(columns: 2, flow: "vertical")[
    + a
    + b
    + c
    + d
    + e
    + f
  ]
  ```],
  [#tasks(columns: 2, flow: "vertical")[
    + a
    + b
    + c
    + d
    + e
    + f
  ]]
)

// =============================================================================
// CONFIGURATION
// =============================================================================

= Configuration

== Global Defaults

Use `tasks-setup()` to set defaults for the rest of the document.

#example(
  [```typst
  #tasks-setup(
    columns: 3,
    label-format: "1)",
    column-gutter: 1.2em,
    row-gutter: 0.7em,
    label-weight: "bold",
  )

  #tasks[
    + Item 1
    + Item 2
    + Item 3
    + Item 4
    + Item 5
    + Item 6
  ]
  ```],
  [
    #tasks-setup(
      columns: 3,
      label-format: "1)",
      column-gutter: 1.2em,
      row-gutter: 0.7em,
      label-weight: "bold",
    )

    #tasks[
      + Item 1
      + Item 2
      + Item 3
      + Item 4
      + Item 5
      + Item 6
    ]
  ]
)

== Resume Numbering

#example(
  [```typst
  #tasks[
    + First
    + Second
    + Third
  ]

  #tasks(resume: true)[
    + Fourth
    + Fifth
  ]

  #tasks-reset()
  #tasks[
    + Back to one
    + Two again
  ]
  ```],
  [
    #tasks[
      + First
      + Second
      + Third
    ]

    #tasks(resume: true)[
      + Fourth
      + Fifth
    ]

    #tasks-reset()
    #tasks[
      + Back to one
      + Two again
    ]
  ]
)

// =============================================================================
// PARAMETER REFERENCE
// =============================================================================

= Parameter Reference

The `tasks()` function supports the following parameters:

#table(
  columns: (1.4fr, 1fr, 1fr, 2fr),
  stroke: (x: none, y: 0.3pt + luma(85%)),
  inset: 6pt,
  [*Parameter*], [*Type*], [*Default*], [*Description*],
  [columns], [int], [2], [Number of columns],
  [label], [string/function], ["a)"], [Label format shorthand],
  [label-format], [string/function], ["a)"], [Explicit label format],
  [start], [int], [1], [Starting number],
  [resume], [bool], [false], [Continue numbering from previous tasks],
  [column-gutter], [length], [1em], [Space between columns],
  [row-gutter], [length], [0.6em], [Space between rows],
  [label-width], [auto/length], [auto], [Reserved width for labels],
  [label-align], [alignment], [right], [Label alignment],
  [label-baseline], [string/length], ["center"], [Vertical alignment of labels],
  [label-weight], [string], ["regular"], [Font weight for labels],
  [indent-after-label], [length], [0.4em], [Space after label],
  [indent], [length], [0pt], [Left indentation of the block],
  [above], [length], [0.5em], [Space before the block],
  [below], [length], [0.5em], [Space after the block],
  [flow], [string], ["horizontal"], ["horizontal" or "vertical" flow],
)

// =============================================================================
// END
// =============================================================================
