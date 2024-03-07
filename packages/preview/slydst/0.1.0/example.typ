#import "@preview/slydst:0.1.0": *

#set page(fill: white)

#show: slides.with(
  title: "Slydst: Slides in Typst",
  authors: ("Gaspard Lambrechts",),
)

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

== Outline

#outline()

= Usage

== Setup

To start, just use the following preamble.

```typst
#import "@preview/slydst:0.1.0": *

#show slides.with(
  title: "Insert your title here", // Required
  subtitle: none,
  date: none,
  authors: (),
  layout: "medium",
  title-color: none,
)

Insert your content here.
```

== Content

- *Level-one headings* corresponds to new sections.
- *Level-two headings* corresponds to new slides.
- Blank space can be filled with *vertical spaces* like `#v(1fr)`.

```typst
== Outline

#outline()

= First section

== First slide

#figure(image("figure.png", width: 60%), caption: "Caption")

#v(1fr)

#lorem(20)
```

...and longer slides are automatically numbered.

= Components

== Definitions, theorems and others

#definition(title: "An interesting definition")[
  #lorem(10)
]

#theorem(title: "An interesting theorem")[
  Let $p(x, y)$ a probability distribution, we have,
  $
    p(x, y) = p(x) p(y | x)
  $
]

#lemma(title: "An interesting lemma")[
  #lorem(20)
]

#corollary(title: "An interesting corollary")[
  #lorem(30)
]

= Summary

== Summary

- Slydst provides simple static slides.
- Slides are named according to the headings.
- Some more components are available.
