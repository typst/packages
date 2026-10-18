#import "@preview/nidaros-ntnu-thesis:0.1.0": *

#show: ntnu-thesis.with(
  title: [The title of your master's thesis],
  author: "Your Name",
)

#title-page(
  author: "Your Name",
  title: "The title of your master's thesis should be written here",
  subtitle: "Any undertitle is written here",
  programme: "Master's thesis in Physics and Mathematics",
  supervisor: "Supervisor Name",
  co-supervisor: "Co-supervisor Name",
  date: "June 2026",
  faculty: "Faculty of Natural Sciences",
  department: "Department of Physics",
  // logo: image("figures/ntnu-logo.png", width: 28%),
)

#front-matter[
  #front-chapter("Abstract")[
    Write an abstract/summary of your thesis, and state your main findings here.

    A summary should be included in both English and a second language if this is applicable.
  ]

  #pagebreak()

  #front-chapter("Preface")[
    Write the preface of your thesis here. You may include acknowledgements and thanks as part of your preface.
  ]

  #pagebreak()

  #contents()

  #front-chapter("Abbreviations")[
    List abbreviations in alphabetic order:

    - *EDA* Exploratory Data Analysis
    - *GNSS* Global Navigation Satellite System
    - *NTNU* Norwegian University of Science and Technology
  ]
]

#main-matter(short-title: [The title])[
  = Introduction

  == Motivation

  This is the beginning of your thesis. Cite sources with `@knuth1984texbook` and reference figures with labels.

  == Project Description

  Typst lets you write chapters, sections, figures, equations, tables, citations, and references with compact markup.

  === Stakeholders

  Add your thesis text here.

  = Theory

  == Equations

  Numbered equations follow the current chapter:

  $ integral_0^1 x^2 dif x = 1 / 3 $

  == Tables and Footnotes

  #figure(
    table(
      columns: 3,
      [Feature], [Mean], [Std. dev.],
      [Speed], [12.4], [2.1],
      [Altitude], [108.0], [14.3],
    ),
    caption: [Dynamic feature statistics with outliers],
  ) <tab-stats>

  See @tab-stats for a compact table.

  == A Single Figure

  #figure(
    rect(width: 70%, height: 5cm, stroke: 0.8pt, inset: 1em)[
      #align(center + horizon)[Figure placeholder]
    ],
    caption: [Illustration of latitude and longitude],
  ) <fig-latlong>

  See @fig-latlong for a figure reference.

  == Citations

  This sentence cites @knuth1984texbook.

  = Methods

  == Section One

  Method text goes here.

  === Subsection One

  More method text goes here.

  === Subsection Two

  More method text goes here.

  == Section Two

  Add more thesis content here.

  = Results

  == More Figures

  #figure(
    rect(width: 72%, height: 5cm, stroke: 0.8pt, inset: 1em)[
      #align(center + horizon)[Result figure placeholder]
    ],
    caption: [Trajectory angle],
  ) <fig-trajectory>

  = Discussion

  == Future Work

  Discuss limitations, implications, and future work.

  = Conclusions

  Conclude your thesis here.

  #references[
    #bibliography("bibliography.bib", title: "References", style: "ieee")
  ]
]

#appendices[
  = Github Repository

  Add appendix material here.

  = Sidenote Statistics

  Add additional tables, figures, or notes here.
]
