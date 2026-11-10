#import "@preview/unofficial-sorbonne-presentation:0.1.0": *

#show: template.with(
  title: [Standard Mapping Guide],
  subtitle: [Section & Subsection Hierarchy],
  author: [David Hajage],
  // Standard mapping: Level 1 (=) is a Section, Level 2 (==) is a Subsection
  mapping: (section: 1, subsection: 2),
  // Numbering format for sections and subsections
  numbering-format: "1.1",
  show-outline: true,
)

= Introduction
== Description
#slide[
  In this configuration:
  - Heading level 1 (`=`) acts as a *Section*.
  - Heading level 2 (`==`) acts as a *Subsection*.
]

== Roadmap
#slide[
  Section transitions will display a "Roadmap" (mini table of contents) listing all the subsections within that section.

  Subsections (Level 2) are displayed in the roadmap of the parent section transition slide.
  
  They also appear in the breadcrumb at the bottom of the slide.
]

= Technical Details

== Implementation
#slide(title: "The numbering-format option")[
  The `numbering-format` parameter controls how sections and subsections are numbered.
  
  For example, `numbering-format: "1.1"` will produce:
  - *1.* for the first section.
  - *1.1* for the first subsection.
]
#slide[
  You can change it to `"1.a"` or `"I.1"` depending on your preferences.
]
