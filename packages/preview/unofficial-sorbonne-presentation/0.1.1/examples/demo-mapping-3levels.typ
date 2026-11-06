#import "@preview/unofficial-sorbonne-presentation:0.1.1": *

#show: template.with(
  title: [Complex Mapping Guide],
  subtitle: [Part, Section & Subsection Hierarchy],
  author: [David Hajage],
  // Complex mapping: 3 levels of hierarchy
  mapping: (part: 1, section: 2, subsection: 3),
  // Numbering for the Part (Level 1)
  part-numbering-format: "I",
  // Numbering for Sections (Level 2) and Subsections (Level 3)
  numbering-format: "1.a",
  show-outline: true,
)

#slide[
  When a level is mapped to `part`:
  - The transition slide is centered and "quiet" (no roadmap).
  - It usually represents a major thematic block.
  - The numbering follows `part-numbering-format` (here: "I").
]

= First Part
== Introduction Section
=== Context
#slide[
  In this 3-level setup:
  - Level 1 (`=`) is a *Part*.
  - Level 2 (`==`) is a *Section*.
  - Level 3 (`===`) is a *Subsection*.
  
  The Section transition (Level 2) will show a roadmap of all Subsections (Level 3) within it.
]

=== Problem Statement
#slide[
  Look at the breadcrumb: it now tracks three levels of depth.
]

= Second Part
== Results Section
=== Data Analysis
#slide[
  The `numbering-format` starts from the Section level. 
  Here, `numbering-format: "1.a"` means sections are "1", "2", and subsections are "1.a", "1.b".
]
