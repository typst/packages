#import "@preview/elegant-polimi-thesis:0.2.1": *
#import "@preview/touying:0.7.4": *

#show: polimi-digital-presentation.with(
  config-info(
    title: "Title of the Presentation",
    author: "Name Surname",
    subtitle: "Subtitle",
    theme: "Theme",
    date: datetime.today(),
  ),
)

#title-slide()

#make-outline()

= First Section

== Slide in first section

#lorem(50)

#lorem(40)

== Split slide

#split-slide(
  left: [
    #lorem(30)

    #lorem(30)
  ],
  right: [
    === Paragraph title
    #lorem(120)

    === Paragraph title
    #lorem(120)
  ],
)

= Second Section

== Slide in second section

#lorem(20)

#lorem(20)

#lorem(20)

#focus-slide[Thanks for listening]
