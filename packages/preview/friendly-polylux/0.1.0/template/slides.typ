#import "@preview/polylux:0.4.0": *
#import "@preview/friendly-polylux:0.1.0" as friendly
#import friendly: titled-block

#show: friendly.setup.with(
  short-title: [Short title],
  short-speaker: [Short speaker],
)

#set text(size: 30pt, font: "Andika")
#show raw: set text(font: "Fantasque Sans Mono")
#show math.equation: set text(font: "Lete Sans Math")

#friendly.title-slide(
  title: [Title],
  speaker: [Speaker],
  conference: [The Conference],
  speaker-website: "url-to-the-speaker.org", // use `none` to disable
  slides-url: "URL to slides", // use `none` to disable
  qr-caption: text(font: "Excalifont")[Get these slides],
  logo: auto,
)

#slide[
  = My first slide
  With some maths: $x^2 + y^2 = z^2$

  And some code: `Typst *rocks*!`

  #titled-block(title: [A block])[
    Some important content
  ]
]

#friendly.last-slide(
  title: [That's it!],
  project-url: "URL to project",
  qr-caption: text(font: "Excalifont")[My project on GitHub],
  contact-appeal: [Get in touch #emoji.hand.wave],
  // leave out any of the following if they don't apply to you:
  email: "foo@bar.org",
  mastodon: "@foo@baz.org",
  website: "bar.org"
)
