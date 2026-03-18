#import "@preview/rectangles-polylux:0.1.0": *

#show: rectangles-theme.with(
  aspect-ratio: "16-9",
  title: "Title",
  subtitle: "Subtitle",
  authors: ("Me", "Myself", "And I"),
  date: "19 January 2038",
  text-size: 20pt,
)

#title-slide()

#outline-slide(highlight-section: "Introduction")

#slide(title: "Introduction", new-section: "Introduction")[
  - Here are some bullet points.
  - They also use the accent color.
  - #lorem(5)
]

#slide(title: "Figures", new-section: "Examples")[
  #set align(center)
  #figure(
    block(fill: aqua, width: 55%, height: 70%)[
      Replace me with an ```typst #image()```!
    ],
    supplement: [Figure],
    caption: [Here, we have a beautiful image!]
  )
]

#slide(title: "Math")[
  $e^(i pi) = -1$, where
  $
    e^x = exp(x)
    = sum_(n=0)^infinity (x^n)/(n!)
    = lim_(n arrow infinity) (1 + x/n)^n.
  $
]

#slide(title: "Listings")[
  Here is an implementation of `fibonacci` in Python:

  ```python
  def fibonacci(n):
    if n < 0:
      return None
    if n == 0 or n == 1:
      return n
    return fibonacci(n-1) + fibonacci(n-2)
  ```
]
