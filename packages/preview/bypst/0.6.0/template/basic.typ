// To use with a local installation (after `just install`):
// #import "@local/bypst:0.6.0": *
#import "@preview/bypst:0.6.0": *

// config-info() sets the PDF metadata; title-slide() reads the same fields.
#show: bips-theme.with(
  config-info(
    title: "Your Presentation Title",
    subtitle: "Optional Subtitle",
    author: "Your Name",
    date: datetime.today().display(),
  ),
  // logo: image("bips-logo.png"),
)

#title-slide()

#bips-slide(title: "Introduction")[
  Your content here...

  - Bullet points
  - Math: $x^2 + y^2 = z^2$
  - *Bold* and _italic_ text

  #pause

  - Revealed on the next click
]

#section-slide("Results")

#bips-slide(title: "Main Findings")[
  #two-columns[
    - First finding
    - Second finding
  ][
    #callout-tip[Callouts frame a key message.]
  ]
]

#thanks-slide(
  contact-author: "Your Name",
  email: "your.email@leibniz-bips.de",
)
