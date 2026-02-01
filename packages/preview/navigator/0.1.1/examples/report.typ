#import "../lib.typ": progressive-outline

#set page(paper: "a4", margin: 2.5cm, numbering: "1")
#set text(size: 11pt, lang: "en")
#set heading(numbering: "1.1.")

// Component to display a local roadmap at the start of a section
#let local-outline() = block(
  width: 100%,
  fill: luma(245),
  inset: 1.5em,
  radius: 5pt,
  stroke: 0.5pt + luma(200),
  [
    #set text(size: 0.9em)
    #text(weight: "bold", fill: blue.darken(20%))[In this section:]
    #v(0.5em)
    #progressive-outline(
      level-1-mode: "none",
      level-2-mode: "current-parent",
      show-numbering: true,
      text-styles: (
        level-2: (active: (weight: "bold", fill: blue.darken(20%)))
      )
    )
  ]
)

#align(center)[
  #text(size: 24pt, weight: "bold")[Research Report] \ 
  #v(1em)
  #text(size: 14pt, style: "italic")[Using Navigator in a standard textual document]
]

#v(2em)
#outline(indent: 2em)
#pagebreak()

= Introduction
#lorem(50)

= Literature Review
#local-outline()

== Historical Background
#lorem(100)

== State of the Art
#lorem(80)

== Research Gaps
#lorem(60)

#pagebreak()

= Methodology
#local-outline()

== Data Collection
#lorem(70)

== Processing Algorithms
#lorem(90)

== Evaluation Metrics
#lorem(50)

#pagebreak()

= Results and Discussion
#local-outline()

== Quantitative Analysis
#lorem(120)

== Qualitative Analysis
#lorem(80)

== Practical Implications
#lorem(100)

= Conclusion
#lorem(50)
