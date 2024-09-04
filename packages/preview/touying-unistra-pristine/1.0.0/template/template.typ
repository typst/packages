#import "@preview/touying:0.5.2": *
#import "../src/unistra.typ": *
#import "../src/colors.typ": *
#import "../src/admonition.typ": *
#import "../src/settings.typ" as settings

#show: unistra-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [_Subtitle_],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
  ),
)

#title-slide[]

= Example Section Title

== Example Slide

A slide with *important information*.


#focus-slide(
  theme: "neon",
  [
    This is a focus slide \ with theme "neon"
  ],
)