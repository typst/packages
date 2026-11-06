// To use with a local installation (after `just install`):
// #import "@local/bypst:0.4.0": *
#import "@preview/bypst:0.4.0": *

#show: bips-theme

#title-slide(
  title: "Your Presentation Title",
  subtitle: "Optional Subtitle",
  author: "Your Name",
  institute: bips-en,
  date: datetime.today().display(),
)

#bips-slide(title: "Introduction")[
  Your content here...

  - Bullet points
  - Math: $x^2 + y^2 = z^2$
  - *Bold* and _italic_ text
]

#section-slide("Results")

// `composer:` splits the whole slide into panes — the trailing content blocks
// become the panes (here a narrow 1fr and a wider 2fr). Column helpers like
// `two-columns` can be nested inside a pane.
#bips-slide(title: "Main Findings", composer: (1fr, 2fr))[
  - First finding
  - Second finding
  - Third finding
][
  A wider pane with room for more detail.

  #two-columns[
    A nested two-column layout.
  ][
    #blue[The nested right column.]
  ]

  Text continues below the nested columns.
]

#thanks-slide(
  contact-author: "Your Name",
  email: "your.email@leibniz-bips.de",
)
