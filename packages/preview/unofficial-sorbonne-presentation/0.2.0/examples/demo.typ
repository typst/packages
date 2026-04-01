#import "@preview/unofficial-sorbonne-presentation:0.2.0": *
#import "@preview/cetz:0.4.2": canvas, draw

#let theme-choice = sys.inputs.at("theme", default: "sorbonne")
#let is-dark = sys.inputs.at("dark", default: "false") == "true"

#let my-template = if theme-choice == "iplesp" {
  iplesp-template.with(
    title: [(Unofficial) Laboratory Template: Complete Guide],
    theme: "blue",
    dark-mode: is-dark,
  )
} else {
  sorbonne-template.with(
    title: [(Unofficial) Example Template: Complete Guide],
    faculty: "univ",
    dark-mode: is-dark,
  )
}

#show: my-template.with(
  subtitle: [Demonstration of all features and components],
  short-title: [Template guide],
  short-author: [D. Hajage],
  author: [David Hajage],
  affiliation: [Example University / Laboratory],
  show-outline: true,
  mapping: (section: 1),
)

// ==========================================
= How to use this Demo
// ==========================================

#slide(title: "Compiling this Gallery")[
  This file (`demo.typ`) is a living manual. Since it supports multiple themes and dark mode, it must be compiled using the `--input` flag:

  ```bash
  # For Example (default)
  typst compile demo.typ --input theme=sorbonne

  # For Laboratory (Dark mode)
  typst compile demo.typ --input theme=iplesp --input dark=true
  ```

  *Current settings:*
  - Theme: #highlight-box(fill-mode: "fill", theme-choice)
  - Mode: #highlight-box(fill-mode: "fill", if is-dark [Dark] else [Light])
]

// ==========================================
= Basic Components & Layout
// ==========================================

#slide(title: "Slides & Lists")[
  The `#slide()` function is the core component. It supports standard Typst content.
  
  + First item
  + Second item
    - Sub-item
]

#slide(title: "Text Styles")[
  Three functions to prioritize information:
  
  - *Alert*: For #alert[critical] information.
  - *Muted*: For #muted[secondary] information.
  - *Subtle*: For #subtle[tertiary] information.
]

#slide(title: "Multi-column Layouts", allow-slide-breaks: true)[
  The template provides dedicated functions for balanced layouts:
  
  - `two-col(left, right, ..)` and `three-col(left, center, right, ..)`
  - *Parameters*:
    - `columns`: Array of widths (e.g., `(1fr, 2fr)`). Defaults to equal widths.
    - `gutter`: Spacing between columns (default: `2em`).

  #v(0.5em)
  #two-col(
    [*Two-col*: Default equal width. #lorem(5)],
    [#lorem(10)]
  )
  #v(0.5em)
  #two-col(
    [*Custom width*: Using `columns: (1fr, 2fr)`.], [#lorem(10)],
    columns: (1fr, 2fr)
  )
  #v(0.5em)
  #three-col(
    [*Three-col*], [Equal width], [distribution]
  )
  #v(0.5em)
  #grid-2x2(
    [*Grid-2x2*], [Top Right],
    [Bottom Left], [Bottom Right]
  )
]

#slide(title: "Automatic Page Breaks", allow-slide-breaks: true)[
  When a slide contains too much content (like a long list or a bibliography), you can use `allow-slide-breaks: true`.
  
  - Content flows naturally to the next physical slide.
  - Headers and footers are automatically repeated.
  - A suffix (default: " (cont.)") is added to the title from the 2nd page.
  
  *Long List Example:*
  #for i in range(1, 16) [
    + Item number #i
  ]
]

#slide(title: "Manual slide Breaks", allow-slide-breaks: true)[
  You can also force a break manually using `#slide-break()`.
  
  - This is the first part of the slide.
  - Useful for logically separating long content.
  
  #slide-break()
  
  - This is the second part, after a manual break.
  - The title is automatically suffixed with "(cont.)".
]

#slide(subtitle: "Demonstrating auto-title with manual subtitle")[
  This slide has no manual `title` parameter. 
  
  Because `auto-title` is `true` (default), it automatically uses the name of the current section ("Basic Components & Layout") as the title, while displaying the provided `subtitle` below it.
]

#slide(
  title: "Slide with Background",
  background: block(width: 100%, height: 100%, {
    let logo-path = if theme-choice == "iplesp" { "../assets/iplesp/iplesp.png" } else { "../assets/sorbonne/sorbonne-univ.png" }
    place(center + horizon, image(logo-path, width: 40%))
    place(top + left, rect(fill: white.transparentize(50%), width: 100%, height: 100%))
  })
)[
  You can add a background to any slide using the `background` parameter.
  
  In this example, we use the institutional logo with a semi-transparent white overlay to ensure content readability.
]

// ==========================================
= Boxes & Blocks
// ==========================================

#slide(title: "Institutional Boxes")[
  #highlight-box(title: "Highlight Box")[Key points using theme color.]
  #v(0.5em)
  #alert-box(title: "Alert Box", fill-mode: "fill")[Warnings using alert color.]
  #v(0.5em)
  #example-box(title: "Example Box", fill-mode: "full")[Examples using green.]
]

#slide(title: "Technical Blocks")[
  #algorithm-box(title: "Algorithm Box")[
    + Step 1: Initialize
    + Step 2: Process
  ]
  #v(1em)
  #themed-block(title: "Themed Block")[Adapts to the chosen faculty/theme color.]
]

// ==========================================
= Citations & References
// ==========================================

#slide(title: "Citations Style")[
  Inline citations like @smith2023 or @einstein1905 are highlighted.
  
  You can also use corner boxes:
  
  #cite-box("smith2023", position: "bottom-right")
  #cite-box("doe2024", display-label: "Jane Doe (2024)", position: "top-right")

  _Note: The citation style can be customized via the `bib-style` parameter (default: "apa")._
]

#slide(title: "Bibliography Slide")[
  The bibliography is standard and should be placed in a `#slide()`.
  
  #bibliography("refs.bib", title: none)
]

// ==========================================
= Special Slide Types
// ==========================================

#focus-slide[
  This is a `#focus-slide` for impactful messages.
]

#figure-slide(
  canvas({
    import draw: *
    set-style(
      rect: (stroke: 0.5pt, radius: 5pt),
      line: (stroke: 1pt, mark: (end: "stealth", fill: black, scale: 0.6)),
      content: (padding: 10pt)
    )
    
    // Nodes
    rect((-1.5, 0.5), (1.5, -0.5), fill: blue.lighten(90%), stroke: blue, name: "data")
    content("data", [*Data*])
    
    rect((3.5, 0.5), (6.5, -0.5), fill: red.lighten(90%), stroke: red, name: "proc")
    content("data.east", h(2.5em)) // spacing
    content("proc", [*Analysis*])
    
    rect((1, -2.5), (4, -3.5), fill: green.lighten(90%), stroke: green, name: "viz")
    content("viz", [*Results*])
    
    // Connections
    line("data.east", "proc.west")
    line("proc.south", (5, -3), "viz.east")
    line("viz.west", (0, -3), "data.south")
    
    // Center text
    content((2.5, -1.5), text(gray, size: 0.8em)[_Workflow Cycle_])
  }),
  title: "Figure Slide",
  caption: [A polished diagram generated with CeTZ.]
)

#acknowledgement-slide(
  subtitle: [Special thanks to my supervisor:],
  people: ((name: "Prof. Smith", role: "Supervisor"),),
  institutions: ("Example University",),
)

#equation-slide(
  $ f(x) = 1 / (sigma sqrt(2 pi)) exp(- 1/2 ( (x - mu) / sigma )^2) $,
  title: [Equation Slide],
  definitions: [
    / $mu$: Mean of the distribution
    / $sigma$: Standard deviation
  ],
  citation: (bib-key: "gauss1809", label: "Gaussian Distribution")
)

// ==========================================
= Dynamic Features
// ==========================================

#slide(title: "Sequential Reveal with pause")[
  The `presentate` package allows for step-by-step reveals:
  
  - Point 1: Always visible.
  #show: pause
  - Point 2: Appears after a click.
  #show: pause
  - Point 3: Final point.

]

#slide(title: "Precise Control: only and uncover")[
  You can control exactly which subslide an element appears on:
  
  #two-col(
    [
      #uncover(2, 3, 4)[Visible from step 2.] \
      #uncover(3, 4)[Visible only at step 3.]
    ],
    [
      #only(1)[Step 1 content.]
      #only(2)[Step 2 content.]
      #only(3, 4)[Step 3 content.]
    ]
  )
  
  #uncover(4)[
    #v(1em)
    #alert-box(title: "Important Limitation")[
      Dynamic animations are *incompatible* with the `allow-slide-breaks: true` option.
    ]
  ]

]

// ==========================================
= Template Configuration
// ==========================================

#slide(title: "Appendix & Hierarchy Control")[
  #two-col(
    [
      *Using Appendices*
      - Call `#appendix()` to start.
      - Resets heading counters.
      - Displays a focus slide using `annex-main-title`.
      - Changes numbering style to `annex-title` + `annex-numbering-format`.
    ],
    [
      *Mapping Logic*
      - `mapping` defines roles for levels:
      - `(section: 1)` : Level 1 is a section.
      - `(part: 1, section: 2)` : Level 1 is a Part, Level 2 is a Section.
      - Transition slides and breadcrumbs adapt to these roles.
    ]
  )
]

#slide(title: "Theme Configuration Reference (1/2)")[
  #set text(size: 0.72em)
  #two-col(
    [
      *Identification & Date*
      - `title`, `short-title`, `subtitle`.
      - `author`, `short-author`, `affiliation`.
      - `date`: Defaults to today.
      
      *Visual Identity*
      - `faculty`: `"univ"` (default), `"sante"`, `"sciences"`, `"lettres"`.
      - `theme` (Laboratory): `"blue"`, `"red"`, `"green"`, etc.
      - `primary-color` / `alert-color`: Manual hex/rgb overrides.
      - `logo-slide` / `logo-transition`: Image paths.
      - `logo-left` / `logo-center` / `logo-right`: Laboratory header bar.
      
      *Typography & Global*
      - `text-font` / `text-size`: e.g., `"Fira Sans"`, `20pt`.
      - `aspect-ratio`: `"16-9"` or `"4-3"`.
    ],
    [
      *Outline (TOC)*
      - `show-outline`: Toggle summary slide.
      - `outline-title`: Title of the TOC.
      - `outline-depth`: Levels shown in TOC.
      - `outline-columns`: Number of columns for TOC.
      
      *Header & Numbering*
      - `show-header-numbering`: Toggle all numbers.
      - `numbering-format`: For sections (e.g., `"1.1"`).
      - `part-numbering-format`: For parts (e.g., `"I"`).
    ]
  )
]

#slide(title: "Theme Configuration Reference (2/2)")[
  #set text(size: 0.8em)
  *Navigation & Appendix*
  - `mapping`: Dict of roles (part/section/subsection) vs levels.
  - `auto-title`: Boolean. If true, slides without a title use the section name.
  - `transitions`: Dictionary for `navigator` roadmap customization.
  - `bib-style`: Bibliography style (default: `"apa"`).
  - `annex-title`: Prefix for single appendix (e.g., `"Appendix"`).
  - `annex-main-title`: Focus slide text (e.g., `"Technical Annexes"`).
  - `annex-numbering-format`: Numbering style (e.g., `"A"`, `"I"`, `"1"`).
  - `progress-bar`: Position of the bar (`"none"`, `"top"`, `"bottom"`).
  - `slide-break-suffix`: Suffix for broken slides (default: `" (cont.)"`).
  - `footer-author` / `footer-title`: Boolean toggles for footer info.
  - `max-length`: (`int` or `dict`) Truncate breadcrumb titles. Ex: `20` or `(section: 10, subsection: 20)`.
  - `dark-mode`: Boolean. Enable dark theme for content slides.
]

#slide(title: "Dark Mode Support")[
  The template includes a built-in dark mode for content slides.
  
  - *Usage*: Set `dark-mode: true` in the `template` configuration.
  - *Behavior*: Automatically switches background to dark and adjusts text/box colors for optimal contrast.
  - *Institutional Identity*: Remains compatible with all preset presets.
]

#ending-slide()
