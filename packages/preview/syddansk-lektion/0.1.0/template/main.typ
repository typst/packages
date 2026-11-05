#import "@preview/syddansk-lektion:0.1.0": *

#show: sdu-theme.with(
  institution: "IMADA",
  website: "sdu.dk",
  hashtag: "#sdudk",
  // logo: image("my-logo.png", alt: "My custom logo"),
  date: datetime.today(),
  aspect-ratio: "16-9",
  colors: config-colors(
    neutral-lightest: white,
    neutral-darkest: black,
    primary-darkest: rgb("#789d4a"),
    primary-lightest: rgb("#aeb862"),
    secondary-lightest: rgb("#f2c75c"),
  )
)
