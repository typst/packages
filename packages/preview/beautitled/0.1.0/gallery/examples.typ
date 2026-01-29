// Gallery renders for manual examples
#import "@preview/beautitled:0.1.0": *

#set page(width: 16cm, height: 12cm, margin: 0.8cm)
#set text(font: "Linux Libertine", size: 10pt)

#let example-box(body) = rect(width: 100%, stroke: 0.5pt + gray, inset: 1em)[
  #body
]

// Example 1: Basic Document with Chapter
#example-box[
  #reset-counters()
  #beautitled-setup(style: "titled", show-chapter-in-section: true)
  #chapter[Vector Geometry]
  #section[Vector Space]
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  #subsection[Basic Definitions]
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
]

#pagebreak()

// Example 2: Without Chapter (Sections Only)
#example-box[
  #reset-counters()
  #beautitled-setup(style: "titled", show-chapter-in-section: false)
  #section[Vectors]
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  #subsection[Vector Addition]
  Ut enim ad minim veniam, quis nostrud exercitation.
]

#pagebreak()

// Example 3: Academic Style with Custom Colors
#example-box[
  #reset-counters()
  #beautitled-setup(
    style: "academic",
    primary-color: rgb("#1a5276"),
    secondary-color: rgb("#5dade2"),
    chapter-size: 20pt,
    section-size: 15pt,
  )
  #chapter[Introduction to Analysis]
  #section[Limits and Continuity]
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  #subsection[Definition of Limits]
  Ut enim ad minim veniam, quis nostrud exercitation.
]

#pagebreak()

// Example 4: English Document
#example-box[
  #reset-counters()
  #beautitled-setup(
    style: "scholarly",
    chapter-prefix: "Chapter",
    section-prefix: "Section",
  )
  #chapter[Theoretical Framework]
  #section[Literature Review]
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  #subsection[Previous Studies]
  Ut enim ad minim veniam, quis nostrud exercitation.
]

#pagebreak()

// Example 5: Without Numbering
#example-box[
  #reset-counters()
  #beautitled-setup(
    style: "elegant",
    show-chapter-number: false,
    show-section-number: false,
    show-subsection-number: false,
  )
  #chapter[Poetry]
  #section[Flowers of Evil]
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  #subsection[Spleen and Ideal]
  Ut enim ad minim veniam, quis nostrud exercitation.
]

#pagebreak()

// Example 6: Different Styles Comparison
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Modern Style:*
    #rect(width: 100%, stroke: 0.5pt + gray, inset: 0.8em)[
      #reset-counters()
      #beautitled-setup(style: "modern")
      #chapter[Chapter]
      #section[Section]
      Content...
    ]
  ],
  [
    *Classical Style:*
    #rect(width: 100%, stroke: 0.5pt + gray, inset: 0.8em)[
      #reset-counters()
      #beautitled-setup(style: "classical")
      #chapter[Chapter]
      #section[Section]
      Content...
    ]
  ],
)

#v(1em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Textbook Style:*
    #rect(width: 100%, stroke: 0.5pt + gray, inset: 0.8em)[
      #reset-counters()
      #beautitled-setup(style: "textbook")
      #chapter[Chapter]
      #section[Section]
      Content...
    ]
  ],
  [
    *Educational Style:*
    #rect(width: 100%, stroke: 0.5pt + gray, inset: 0.8em)[
      #reset-counters()
      #beautitled-setup(style: "educational")
      #chapter[Chapter]
      #section[Section]
      Content...
    ]
  ],
)
