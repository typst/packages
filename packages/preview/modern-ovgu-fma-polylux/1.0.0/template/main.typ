#import "@preview/modern-ovgu-fma-polylux:1.0.0": *

#show: ovgu-fma-theme.with(
  author: [Firstname Lastname],
  title: [Presentation Title],
  date: ez-today.today(),
  text-lang: "en",
)

#show: document => conf-equations(document) // This apply some mathmatical useful shortcuts

#title-slide(
  subtitle: [a possible subtitle],
)

#outline-slide()

#header-slide()[Some Examples for content]

#slide(
  heading: [How to use equations],
)[
  You could define Equations like this:
  $ a/b = c/d $
  This equations will be numbered, if you put a lable on it:
  $ a^2 + b^2 = c^2 $ <pythagoras>
  The @pythagoras describes Pythagoras theorem. A proof you could find in @gerwig2021satz.
]

#slide(
  heading: [Multi-Column-sliden],
)[
  #toolbox.side-by-side()[#lorem(39)][#lorem(30)][#lorem(35)]
]

#slide(
  block-height: 85%,
)[
  #figure(
    caption: [Exampleimage#footnote([Thanks to Malte for creating this image])],
  )[#image("example-image.jpg", height: 70%)]
  You could also use footnotes and images. In the case of Footnotes you have to change the block-height to not cause a pagebreak.
]

#header-slide()[Usefull features and hints]

#slide()[
  Don't know how to write this mathmatical symbol in Typst? Check this website:

  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      #link("https://detypify.quarticcat.com/")
    ]
  ]

  #show: later

  What else is possible with polylux?
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      #link("https://polylux.dev/book/getting-started/getting-started.html")
    ]
  ]

  #show: later

  How could I generate a handout from my presentation? ( turn "animations" off)
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      Put in the beginning of your code this command
      ```typ
      #enable-handout-mode(true)
      ```
    ]
  ]
]

#slide(
  heading: ["animations"],
)[
  Did you noticed it? On the slide before we used this command
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      ```typ
      #show: later
      ```
    ]
  ]
  to let pop up this boxes one after an other. There are much more helper functions. You could look them up under:
  #align(center)[
    #block(
      stroke: 2.5pt + fma,
      fill: fma-lighter,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      #link("https://polylux.dev/book/dynamic/helper.html")
    ]
  ]
]

#header-slide()[Bibliography]

#slide-base(
  show-section: false,
)[
  #bibliography(
    "example.bib",
    style: "institute-of-electrical-and-electronics-engineers",
  )
]
