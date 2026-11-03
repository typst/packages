// To use with a local installation (after `just install`):
// #import "@local/bypst:0.2.0": *
#import "@preview/bypst:0.2.0": *

#show: bips-theme

#title-slide(
  title: "Complete BIPS Presentation Example",
  subtitle: "Showcasing all features",
  authors: (
    [Jane Doe#inst(1, 2)],
    [John Smith#inst(1)],
  ),
  institutes: (
    bips-en,
    "University of Bremen",
  ),
  date: datetime.today().display(),
  occasion: "Annual Conference",
)

#bips-slide(title: "Features Overview")[
  This template includes:

  - Multiple slide types (content, section, thanks, empty)
  - Callout boxes (note, tip, warning, important)
  - Animations via `#pause`, `#uncover`, `#only`
  - Multi-column layouts
  - Bibliography support
  - QR code generation
]

#section-slide("Examples")

#bips-slide(title: "Callout Boxes")[
  #callout(type: "note")[
    This is a note callout.
  ]

  #callout(type: "tip", title: "Pro Tip")[
    Callouts can have custom titles.
  ]

  #callout(type: "warning")[
    This is a warning callout.
  ]
]

#bips-slide(title: "Animations")[
  - First item

  #pause

  - Second item appears on click

  #pause

  - Third item appears last
]

#bips-slide(title: "Two-Column Layout")[
  #two-columns[
    *Left column*

    Text, images, or any content.
  ][
    *Right column*

    Side-by-side comparisons.
  ]
]

#thanks-slide(
  contact-author: "Jane Doe",
  email: "jane.doe@leibniz-bips.de",
  qr-url: "https://github.com/bips-hb/bips-typst",
)
