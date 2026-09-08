#import "@preview/unofficial-sorbonne-presentation:0.5.0": *

#let theme-choice = sys.inputs.at("theme", default: "sorbonne")

#let my-template = if theme-choice == "iplesp" {
  iplesp-template.with(
    title: [Presentation Theme Demo],
    subtitle: [4:3 Format Showcase],
    author: [David Hajage],
    short-author: [D. Hajage],
    affiliation: [Example University / Laboratory],
    date: [May 2026],
    aspect-ratio: "4-3",
    mapping: (section: 1),
  )
} else if theme-choice == "aphp" {
  aphp-template.with(
    title: [Presentation Theme Demo],
    subtitle: [4:3 Format Showcase],
    author: [David Hajage],
    short-author: [D. Hajage],
    affiliation: [AP-HP · Example University],
    date: [May 2026],
    aspect-ratio: "4-3",
    mapping: (section: 1),
  )
} else {
  sorbonne-template.with(
    title: [Presentation Theme Demo],
    subtitle: [4:3 Format Showcase],
    author: [David Hajage],
    short-author: [D. Hajage],
    affiliation: [Example University],
    date: [May 2026],
    aspect-ratio: "4-3",
    faculty: "sante",
    mapping: (section: 1),
  )
}

#show: my-template

= Overview

#slide(title: "Key Features")[
  This presentation demonstrates the theme at 4:3 aspect ratio.

  - Clean institutional design with consistent typography
  - Section transitions and breadcrumb navigation
  - Flexible layout components (columns, boxes)
  - Focus slides and ending slide
]

#slide(title: "Two-Column Layout")[
  #two-col(
    [
      *Left column*

      Main finding or key argument goes here.

      #highlight-box(title: "Key Point")[
        Results support the primary hypothesis.
      ]
    ],
    [
      *Right column*

      Supporting information or secondary point.

      #alert-box(title: "Note")[
        Consider potential confounders.
      ]
    ]
  )
]

#slide(title: "Structured List")[
  + *First step* — define the research question clearly
  + *Second step* — collect and clean the data
  + *Third step* — run the statistical analysis
  + *Fourth step* — interpret and report results

  #v(0.5em)

  #themed-block(title: "Summary")[
    A well-structured workflow ensures reproducibility.
  ]
]

#focus-slide[Any questions?]

#ending-slide(
  title: [Thank you!],
  subtitle: [Questions & Discussion],
  contact: ("david.hajage\@example.com",),
)
