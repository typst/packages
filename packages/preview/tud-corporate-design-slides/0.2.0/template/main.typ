#import "@preview/tud-corporate-design-slides:0.1.0": *

#show: tud-slides.with(
  title: "Presentation templates",
  subtitle: "Corporate design rules - Guidelines for using the template and ensuring accessibility",
  author: "Firstname Lastname",
  organizational-unit: "Directorate 7 - Strategy and Communication",
  location-occasion: "Location or occasion of the presentation",
  lang: "en",
)

#title-slide

#slide[
  = Slide title

  - #lorem(3)
  - #lorem(5)
  - #lorem(2)
]

#slide[
  = Slide title

  #lorem(30)
]

#slide[
  = _Slide title_ *for* a slide with a figure

  #figure(
    rect(
      width: 80%,
      height: 80%,
      radius: .25em,
      fill: tud-gradient,
    )[
      #set text(fill: white, weight: "bold")
      #align(horizon)["Hello, world!"]
    ],
    caption: "Figure caption"
  )
]

#section-slide(
  title: "Section title",
  subtitle: "Section subtitle",
)

#slide[
  = Slide title

  - #lorem(4)
  - _#lorem(2)_
  - #lorem(3)
]
