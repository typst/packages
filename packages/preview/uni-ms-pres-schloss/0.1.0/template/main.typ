#import "@preview/uni-ms-pres-schloss:0.1.0": *

#show: pres-theme.with(
  author: [Your Name],
  title: [Presentation Title],
  date: ez-today.today(lang: "en"),
  text-lang: "en",
)

#show: document => conf-equations(document) // Adds useful equation-numbering behavior.

#title-slide(
  subtitle: [a possible subtitle],
)


#outline-slide(multipage: false)

#header-slide()[Header slide]

#slide(heading: [Basic Slide])[
  #lorem(84)
]

#header-slide()[Some examples of content]


#slide(heading: [Code])[
  ```py
  import torch

  if (torch.cuda.is_available()):
  {
    print("cuda is there wohoo!")
  }
  break; # Oh no Java! // lelolalu

  variable = variable * 100.000 +- >< | && 
  
  ```
]

#slide(
  heading: [Let's make some bullet points]
)[
  #item-by-item(mode: gray)[
  - #lorem(1)
    #item-by-item(start: 2, mode: gray)[
    - #lorem(2)
    ]
  ]
  #item-by-item(start: 3, mode: gray)[
  - #lorem(3)
  - #lorem(5)  
  - #lorem(7)
  ]
  you can also use one-by-one, only, alternatives and mote like this:

  #only((beginning: 6))[
  + #lorem(7)
  ]
  #only((beginning: 7))[
  + #lorem(11)
  ]
]

#slide(
  heading: [How to use equations],
)[
  You can define equations like this:
  $a + b != c$.
  These equations are numbered when you add a label:
  $ a^2 + b^2 = c^2 $ <pythagoras>
  @pythagoras references Pythagoras' theorem. A proof can be found in @gerwig2021satz.
]

#slide(
  heading: [Multi-Column-slide],
)[
  #toolbox.side-by-side()[#lorem(42)][#lorem(27)][#lorem(35)]
]

#slide(
  block-height: 80%,
)[
  #figure(
    caption: [Example image#footnote([Thanks to #link("https://www.svgrepo.com/") for the inspiration and Florian Bohlken for this remade image])],
  )[#image("example-image.svg", height: 70%)]
  You can also combine footnotes and images. With footnotes, adjust `block-height` to avoid unwanted page breaks.
]

#header-slide()[Useful features and hints]

#slide()[
  Don't know how to write this mathematical symbol in Typst? Check this website:

  #align(center)[
    #block(
      stroke: 2.5pt + lapis,
      fill: light-grey,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      #link("https://detypify.quarticcat.com/")
    ]
  ]

  What else is possible with polylux?
  #align(center)[
    #block(
      stroke: 2.5pt + lapis,
      fill: light-grey,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: rgb(0, 0, 255, 255))
      #set align(center + horizon)
      #link("https://polylux.dev/book/getting-started/getting-started.html")
    ]
  ]

  How can I generate a handout from my presentation? (Turn animations off.)
  #align(center)[
    #block(
      stroke: 2.5pt + lapis,
      fill: light-grey,
      radius: 0.5em,
      inset: 0.5em,
    )[
      #set text(fill: lapis)
      #set align(center + horizon)
      Add this command near the beginning of your file
      ```typ
      #enable-handout-mode(true)
      ```
    ]
  ]
]

#slide(
  heading: ["Animations"],
)[
  Did you notice it? On the previous slide, we used this command:
  #align(center)[
    #block(
      stroke: 2.5pt + lapis,
      fill: light-grey,
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
  to reveal these boxes one after another. There are many more helper functions here:
  #align(center)[
    #block(
      stroke: 2.5pt + lapis,
      fill: light-grey,
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

#counter("logical-slide").step()
= Bibliography

#bibliography(
  "example.bib",
  style: "ieee",
)


