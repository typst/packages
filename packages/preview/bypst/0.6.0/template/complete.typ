// To use with a local installation (after `just install`):
// #import "@local/bypst:0.6.0": *
#import "@preview/bypst:0.6.0": *

// One `#set text(lang: "de")` here would switch Typst's output and the
// theme's own strings (thanks slide, references title) to German.
#show: bips-theme.with(
  config-info(
    title: "Complete BIPS Presentation Example",
    subtitle: "A tour of the theme's features",
    author: "Jane Doe",
    date: datetime.today().display(),
  ),
  // logo: image("bips-logo.png"),
  progress-bar: true,
  // callout-icons: "drawn", // or "emoji", none
)

// Several authors need the plural forms, which config-info() does not carry.
#title-slide(
  authors: (
    [Jane Doe#inst(1, 2)],
    [John Smith#inst(1)],
  ),
  institutions: (
    bips-en,
    "University of Bremen",
  ),
  occasion: "Annual Conference",
)

#bips-slide(title: "Overview", subtitle: "What this template shows")[
  - Slide types: title, content, section, empty, references, thanks
  - Cards and callouts for definitions and key messages
  - Citations, tables, figures and quotes in the theme's styling
  - Reveals with `#pause`, `#uncover` and `#only`
  - Column layouts and composer panes
]

// Trailing content appears below the section title; the title alone goes
// into the PDF outline.
#section-slide("Methods")[Estimands and study design]

#bips-slide(title: "Definitions")[
  #card(title: "Definition: average treatment effect")[
    $ tau = EE[Y(1) - Y(0)] $
    the mean difference between the potential outcomes under treatment and control #citep(<rubin1974>).
  ]

  #card(title: "Assumption", color: bips-green.darken(35%))[
    No unmeasured confounding: $Y(a) perp A | L$ for $a in {0, 1}$.
  ]
]

#bips-slide(title: "Callouts")[
  #callout-note[A note for background information.]
  #callout-tip(title: "Tip")[Callouts take an optional title.]
  #callout-warning[A warning about a common pitfall.]
  #callout-important[A point the audience must not miss.]
]

#bips-slide(title: "Step-by-Step Reveals")[
  + Define the target population
  #pause
  + Specify the estimand
  #pause
  + Choose the estimator

  #uncover(3)[#blue[All three steps follow #citet(<rothman2008>).]]
]

#section-slide("Results")

#bips-slide(title: "Results Table")[
  #figure(
    table(
      columns: 3,
      align: (left, right, right),
      [*Group*], [*n*], [*Risk (%)*],
      [Exposed], [1 204], [12.4],
      [Unexposed], [3 518], [8.1],
    ),
    caption: [Risk of the outcome by exposure (illustrative numbers).],
  )
]

// `composer:` splits the slide into panes; each trailing block fills one.
#bips-slide(title: "Composer Panes", composer: (2fr, 1fr))[
  The wider pane carries the main argument.

  #two-columns[
    #orange[Nested left column]
  ][
    #green[Nested right column]
  ]

  #small[Smaller text]#footnote[Footnotes collect at the bottom of the slide.] and #tiny[fine print].
][
  #quote(block: true, attribution: [George Box])[
    All models are wrong, but some are useful.
  ]
]

#empty-slide(content-align: center + horizon)[
  #huge[#blue[An empty slide for a single statement]]
]

#bibliography-slide(bib: read("references.bib"))

#thanks-slide(
  contact-author: "Jane Doe",
  email: "jane.doe@leibniz-bips.de",
  qr-url: "https://github.com/bips-hb/bips-typst",
)
