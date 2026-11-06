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
#import "@preview/typslides:1.1.1": *

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
  - This slide has no title.
  - #stress("Bold and coloured") text by using `#stress(text)`. 
  - Theme color: #get-color, obtained with `#get-color`.
  - Link: #link("typst.app")
  
  #framed[This text has been written using `#framed(text)`. The background color of the box is customisable.]
  
  #framed(title:"Frame with title")[This text has been written using `#framed(title:"Frame with title")[text]`.]
]

// Focus slide
#focus-slide[
  This is an auto-resized _focus slide_.
]

// Slide with title
#slide(title: "This is the slide title")[
  #lorem(165)
]

// bibliography-slide is also available for references: 
// #bibliography-slide("bibliography.bib")
```

# Sample slides

<kbd><img src="img/slide-1.jpg" width="300"></kbd> <kbd><img src="img/slide-2.jpg" width="300"></kbd> <kbd><img src="img/slide-3.jpg" width="300"></kbd> <kbd><img src="img/slide-4.jpg" width="300"></kbd> <kbd><img src="img/slide-5.jpg" width="300"></kbd> <kbd><img src="img/slide-6.jpg" width="300"></kbd> <kbd><img src="img/slide-7.jpg" width="300"></kbd> <kbd><img src="img/slide-8.jpg" width="300"></kbd>