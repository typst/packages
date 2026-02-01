#import "../lib.typ": render-transition

#set page(paper: "a4", flipped: true, margin: 2cm)
#set text(font: "Lato", size: 11pt)
#set heading(numbering: "1.1", outlined: false) // Global headings are not outlined

#let navy = rgb("#1a5fb4")

// Mock slide function for testing: renders a framed block
#let test-slide-func(fill: white, body) = block(
  width: 100%, 
  height: 8cm, // Force a height so v(40%) looks like a slide
  fill: fill.lighten(30%), 
  stroke: 1pt + fill, 
  inset: 1em, 
  radius: 5pt,
  [
    #set text(fill: fill.darken(20%))
    #align(center)[*Transition Slide*]
    #v(0.5em)
    #body
  ]
)

// Helper to show code and result stacked
#let test-case(code-str, body) = stack(
  dir: ttb,
  spacing: 0.8em,
  block(fill: luma(248), inset: 10pt, radius: 4pt, width: 100%,
    text(size: 7.5pt, font: "DejaVu Sans Mono", code-str)),
  // We enable outlining only for the example headings
  block(width: 100%, stroke: 0.5pt + gray, inset: 1em, radius: 4pt, {
    set heading(outlined: true)
    body
  })
)

*Transition Engine Test Suite*

= Basic Usage Example
This section tests the basic setup described in the guide.

#test-case(
"show heading: h => render-transition(
  h, mapping: (section: 1, subsection: 2),
  slide-func: test-slide-func,
  transitions: (filter: h => h.label == <ex1>)
)

= Introduction <ex1>
== Welcome <ex1>",
{
  show heading: h => render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: blue, accent: orange),
    slide-func: test-slide-func,
    transitions: (filter: h => h.label == <ex1>)
  )

  [= Introduction <ex1>]
  lorem(5)
  [== Welcome <ex1>]
  lorem(5)
})

#v(1em)

= Filtering Example
This section tests the transition filter (only 'Part' headings should trigger a slide).

#test-case(
"show heading: h => render-transition(
  h, mapping: (section: 1),
  slide-func: test-slide-func,
  transitions: (
    filter: h => h.label == <ex2> and repr(h.body).contains('Part')
  )
)

= Part I: The beginning <ex2>
= Introduction <ex2>",
{
  show heading: h => render-transition(
    h,
    mapping: (section: 1),
    theme-colors: (primary: green, accent: green),
    slide-func: test-slide-func,
    transitions: (
      // Combine test isolation filter and example filter
      filter: h => h.label == <ex2> and repr(h.body).contains("Part")
    )
  )

  [= Part I: The beginning <ex2>]
  
  [= Introduction <ex2>]
})

#v(1em)

= Selective Visibility Example
This section tests different layouts for sections and subsections.

#test-case(
"show heading: h => render-transition(
  h, mapping: (section: 1, subsection: 2),
  slide-func: test-slide-func,
  transitions: (
    filter: h => h.label == <ex3>,
    sections: (visibility: (section: 'all', subsection: 'none')),
    subsections: (visibility: (section: 'current', subsection: 'current-parent')),
  )
)

= Methodology <ex3>
== Data Collection <ex3>
== Analysis <ex3>",
{
  show heading: h => render-transition(
    h,
    mapping: (section: 1, subsection: 2),
    theme-colors: (primary: purple, accent: purple),
    slide-func: test-slide-func,
    transitions: (
      // Filter to keep only headings from this specific example
      filter: h => h.label == <ex3>,
      sections: (visibility: (section: "all", subsection: "none")),
      subsections: (visibility: (section: "current", subsection: "current-parent")),
    )
  )

  [= Introduction <ex3>]
  [= Methodology <ex3>]
  [== Data Collection <ex3>]
  [== Analysis <ex3>]
})
