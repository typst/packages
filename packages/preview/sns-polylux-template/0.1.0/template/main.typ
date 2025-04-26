#import "@preview/polylux:0.4.0": *
#import "@preview/sns-polylux-template:0.1.0" as sns-theme: *

/*
  ACHTUNG: You should seriously consider downloading
  the recommended fonts for this package.
  You can find the fonts here:
    https://fonts.google.com/share?selection.family=Roboto
    https://fonts.google.com/share?selection.family=Raleway
  You can find the installation guide here:
    https://typst.app/docs/reference/text/text/#parameters-font
*/

#set text(lang: "en")
#show: sns-theme.with(
  aspect-ratio    : "16-9",
  title           : "Long Title",
  subtitle        : "Subtitle",
  event           : [University Name Long\ Date],
  short-title     : "Short Title",
  short-event     : "Univ. Name Short — Da/te/short",
  logo-2          : image("pics/logo_SNS_verde.svg"),
  logo-1          : image("pics/logo_SNS_bianco.svg"),
  authors         : (
    {
      set text(top-edge: 0pt, bottom-edge: 0pt)
      grid(gutter: 2em, columns: (1fr, 1.2fr),
        align(right,[First Author]),
        align(left,[#link("first.author@uni.uni")])
      )
    },{
      set text(top-edge: 0pt, bottom-edge: 0pt)
      grid(gutter: 2em, columns: (1fr, 1.2fr),
        align(right,[Second Author]),
        align(left,[#link("second.author@uni.uni")])
      )
    },{
      set text(top-edge: 0pt, bottom-edge: 0pt)
      grid(gutter: 2em, columns: (1fr, 1.2fr),
        align(right,[Third Author]),
        align(left,[#link("third.author@uni.uni")])
      )
    }
  )
)

#title-slide()

#toc-slide()

#slide(
  title: "Slide title",
  subtitle: "Slide subtitle"
)[
  This slide does not belong to any section.
]

#new-section-slide("First section")

#slide(
  title: "A slide without subtitle"
)[
  This slide does not have a subtitle, but belongs to the first section.
]

#new-section-slide("Second section")

#slide(
  subtitle: "Hidden subtitle"
)[
  This slide however does not have a title. It belongs to the second section.
]

#new-section-slide("Third section")

#focus-slide()[
  This is a _focus-slide_.
]

#slide(new-sec: true, title: "Fourth section")[
  A slide can also open a new section...
]

#focus-slide(new-sec: "Fifth section")[
  ... and also a focus-slide can do it!
]

#empty-slide()[
  Ending slide
]
