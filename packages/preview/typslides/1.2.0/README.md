<p align="center">
    <img src="img/logo.png" alt="logo" width="400"/>
</p>

![License](https://img.shields.io/badge/license-GPLv3-blue)
[![Contributors](https://badgen.net/github/contributors/manjavacas/typslides)]()
[![Release](https://badgen.net/github/release/manjavacas/typslides)]()
![GitHub Repo stars](https://img.shields.io/github/stars/manjavacas/typslides)

_Minimalistic [typst](https://typst.app/) slides!_

# Quickstart

This is a simple usage example:

```typst
#import "@preview/typslides:1.2.0": *

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey"
)

// Available themes: bluey, reddy, greeny, yelly, purply, dusky, darky

// The front slide is the first slide of your presentation
#front-slide(
  title: "This is a sample presentation",
  subtitle: "Using typslides",
  authors: "Florence Foo, Nathan Nothing",
  info: "Univeristy of Typstland"
)

// Custom outline
#table-of-contents()

// Title slides represent new sections
#title-slide[
  This is a title slide
]

// A simple slide
#slide()[
  - This is a simple `slide` with no title.
  - #stress("Bold and coloured") text by using `#stress(text)`.
  - Sample link: #link("typst.app")
  - Sample references: @typst, @typslides.

  #framed[This text has been written using `#framed(text)`. The background color of the box is customisable.]

  #framed(title: "Frame with title")[This text has been written using `#framed(title:"Frame with title")[text]`.]
]

// Focus slide
#focus-slide[
  This is an auto-resized _focus slide_.
]

// Slide with title
#slide(title: "This is the slide title")[
  #grayed([This is a `grayed` text.])\
  #grayed($P_t = alpha - 1 / (sqrt(x) + f(y))$)\
  #lorem(80)
]

// Bibliography
#bibliography-slide("bibliography.bib")
```

# Sample slides

<kbd><img src="img/slide-1.jpg" width="300"></kbd> <kbd><img src="img/slide-2.jpg" width="300"></kbd> <kbd><img src="img/slide-3.jpg" width="300"></kbd> <kbd><img src="img/slide-4.jpg" width="300"></kbd> <kbd><img src="img/slide-5.jpg" width="300"></kbd> <kbd><img src="img/slide-6.jpg" width="300"></kbd> <kbd><img src="img/slide-7.jpg" width="300"></kbd>