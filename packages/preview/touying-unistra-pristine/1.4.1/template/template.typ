#import "@preview/touying:0.6.1": *
#import "@preview/touying-unistra-pristine:1.4.1": *

#show: unistra-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
    logo: image("unistrafooter.svg"),
  ),
)

#title-slide(logo: image("unistra.svg"))

= Example Section Title

== Example Slide

A slide with *important information*.

#focus-slide(
  theme: "neon",
  [
    This is a focus slide \ with theme "neon"
  ],
)
