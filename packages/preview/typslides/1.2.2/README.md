<p align="center">
    <img src="img/logo.png" alt="logo" width="400"/>
</p>

![License](https://img.shields.io/badge/license-GPLv3-blue)
[![Contributors](https://badgen.net/github/contributors/manjavacas/typslides)]()
[![Release](https://badgen.net/github/release/manjavacas/typslides)]()
![GitHub Repo stars](https://img.shields.io/github/stars/manjavacas/typslides)

Minimalistic [typst](https://typst.app/) slides!

# Quickstart

This is a simple usage example:

```typst
#import "@preview/typslides:1.2.2": *

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
)

// The front slide is the first slide of your presentation
#front-slide(
  title: "This is a sample presentation",
  subtitle: [Using _typslides_],
  authors: "Antonio Manjavacas",
  info: [#link("https://github.com/manjavacas/typslides")],
)

// Custom outline
#table-of-contents()

// Title slides create new sections
#title-slide[
  This is a _Title slide_
]

// A simple slide
#slide[
  - This is a simple `slide` with no title.
  - #stress("Bold and coloured") text by using `#stress(text)`.
  - Sample link: #link("typst.app")
  - Sample references: @typst, @typslides.#footnote[Bibliography only works when using typslides *locally*.]

  #framed[This text has been written using `#framed(text)`. The background color of the box is customisable.]

  #framed(title: "Frame with title")[This text has been written using `#framed(title:"Frame with title")[text]`.]
]

// Focus slide
#focus-slide[
  This is an auto-resized _focus slide_.
]

// Blank slide
#blank-slide[
  - This is a `#blank-slide`.

  - Available #stress[themes]:

  #framed(back-color: white)[
    #bluey("bluey"), #reddy("reddy"), #greeny("greeny"), #yelly("yelly"), #purply("purply"), #dusky("dusky"), darky.
  ]
]

// Slide with title
#slide(title: "This is the slide title")[
  #lorem(20)
  #grayed([This is a `#grayed` text. Useful for equations.])
  #grayed($ P_t = alpha - 1 / (sqrt(x) + f(y)) $)
  #lorem(20)
]

// Bibliography (not available via API)
// #bibliography-slide("bibliography.bib")
```

# Sample slides

<kbd><img src="img/slide-1.svg" width="300"></kbd> <kbd><img src="img/slide-2.svg" width="300"></kbd> <kbd><img src="img/slide-3.svg" width="300"></kbd> <kbd><img src="img/slide-4.svg" width="300"></kbd> <kbd><img src="img/slide-5.svg" width="300"></kbd> <kbd><img src="img/slide-6.svg" width="300"></kbd> <kbd><img src="img/slide-7.svg" width="300"></kbd> <kbd><img src="img/slide-8.svg" width="300"></kbd>