#import "@preview/sanor:0.1.0": *

// Set up presentation format
#set page(paper: "presentation-16-9", margin: 2cm, fill: rgb("#1a1a1a"))
#set text(fill: white, size: 24pt)

// Title slide
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[
      #text(size: 48pt, weight: "bold")[Sanor Examples]
      #v(1cm)
      #text(size: 32pt)[Presentation Framework for Typst]
      #v(2cm)
      #text(size: 24pt)[Demonstrating Key Features]
    ]
  },
  controls: (
    apply("title"),
  ),
)

// Basic Animation Example
#slide(
  s => {
    let tag = tag.with(s)
    tag("header")[= Basic Animation]
    tag("item1")[- First item appears]
    tag("item2")[- Second item appears]
    tag("item3")[- Third item appears]
    tag("conclusion")[All items are now visible!]
  },
  controls: (
    once("header"),
    apply("item1"),
    apply("item2"),
    apply("item3"),
    apply("conclusion"),
  ),
)

// Apply vs Once Demonstration
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Apply vs Once]
    tag("persistent")[This content stays visible (apply)]
    tag("temporary")[This appears only briefly (once)]
    tag("next")[Next step - temporary content is gone]
  },
  controls: (
    once("title"),
    apply("persistent"),
    once("temporary"),
    (), // Empty step to show temporary content disappears
    apply("next"),
  ),
)

// Content Modification
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Content Modification]
    tag("text", text(size: 28pt)[Hello World])
  },
  controls: (
    once("title"),
    apply("text"),
    apply("text", text.with(fill: blue)),
    apply("text", text.with(fill: red, weight: "bold")),
    apply("text", text.with(fill: green, style: "italic")),
  ),
)

// Object System
#let colored-box = object(
  rect,
  normal: (width: 4cm, height: 3cm, fill: blue, stroke: 2pt),
  highlighted: (width: 4cm, height: 3cm, fill: yellow, stroke: 3pt + red),
  large: (width: 6cm, height: 4.5cm, fill: blue, stroke: 2pt),
)

#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Object System]
    tag("box", colored-box()[Normal Box])
  },
  controls: (
    once("title"),
    apply("box"),
    apply("box", "highlighted"),
    apply("box", "large"),
  ),
)

// Complex Animation with Multiple Elements
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Complex Animation]
    tag("diagram", align(center)[
      #rect(width: 2cm, height: 1cm, fill: blue)[A]
      #h(1cm)
      #rect(width: 2cm, height: 1cm, fill: gray)[B]
      #h(1cm)
      #rect(width: 2cm, height: 1cm, fill: gray)[C]
    ])
    tag("arrow1", align(center)[→])
    tag("arrow2", align(center)[→])
    tag("explanation")[Processing step by step]
  },
  controls: (
    once("title"),
    apply("diagram"),
    apply("arrow1"),
    apply("explanation"),
    (
      apply("diagram", it => {
        show "A": set rect(fill: green)
        it
      }),
      apply("arrow2"),
    ),
  ),
  hider:  it => none, // No space reserved for hidden content
)

// Code Presentation
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Code Presentation]
    tag("code", ```typst
    #import "@preview/sanor:0.1.0": *

    #slide(
      s => {
        let tag = tag.with(s)
        tag("content")[Hello Sanor!]
      },
      controls: (
        apply("content"),
      ),
    )
    ```)
  },
  controls: (
    once("title"),
    apply("code"),
    apply("code", it => {
      show "slide": set text(fill: blue)
      show "tag": set text(fill: green)
      it
    }),
  ),
)

// Mathematical Content
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Mathematical Animation]
    tag("equation", $ E = m c^2 $)
    tag("explanation")[Einstein's famous equation]
  },
  controls: (
    once("title"),
    apply("equation"),
    apply("explanation"),
    apply("equation", it => {
      show "E": set text(fill: red, weight: "bold")
      show "m": set text(fill: blue)
      show "c": set text(fill: green)
      it
    }),
  ),
)

// State Management with Clear
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= State Management]
    tag("content", [This text changes appearance])
  },
  controls: (
    once("title"),
    apply("content"),
    apply("content", text.with(fill: red)),
    apply("content", text.with(fill: blue, size: 32pt)),
    clear("content"), // Back to original
    apply("content", text.with(fill: green, style: "italic")),
  ),
)

// Multiple Simultaneous Changes
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Simultaneous Changes]
    tag("left", place(left)[Left side content])
    tag("right", place(right)[Right side content])
    tag("center", place(center)[Center content])
  },
  controls: (
    once("title"),
    apply("center"),
    (apply("left"), apply("right")), // Both at once
    (clear("left"), clear("right")), // Both disappear
  ),
)

// Custom States Example
#slide(
  s => {
    let tag = tag.with(s)
    tag("title")[= Custom States]
    tag("demo", [Demo Text], faded: text.with(fill: gray), highlighted: text.with(fill: yellow, weight: "bold"))
  },
  defined-states: (
    faded: text.with(fill: gray),
    highlighted: text.with(fill: yellow, weight: "bold"),
  ),
  controls: (
    once("title"),
    apply("demo"),
    apply("demo", "faded"),
    apply("demo", "highlighted"),
    apply("demo", "faded", "highlighted"), // Multiple states
  ),
)

// Handout Mode Example
#slide(
  info: (handout: true, handout-index: 3),
  s => {
    let tag = tag.with(s)
    tag("title")[= Handout Mode]
    tag("step1")[Step 1: Introduction]
    linebreak()
    tag("step2")[Step 2: Details]
    linebreak()
    tag("step3")[Step 3: Conclusion]
  },
  controls: (
    once("title"),
    apply("step1"),
    apply("step2"),
    apply("step3"),
  ),
)

// Final slide
#slide(
  s => {
    let tag = tag.with(s)
    tag("thanks")[
      #text(size: 36pt, weight: "bold")[Thank You!]
      #v(1cm)
      #text(size: 24pt)[For exploring Sanor examples]
      #v(2cm)
      #text(size: 18pt)[Visit the documentation for more features]
    ]
  },
  controls: (
    apply("thanks"),
  ),
)
