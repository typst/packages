#import "@preview/touying:0.5.2": *
#import "@preview/touying-unistra-pristine:1.0.0": *

#show: unistra-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [_Subtitle_],
    author: [Author],
    date: datetime.today().display("[month repr:long] [day], [year repr:full]"),
    logo: image("unistra.svg", width: auto, height: 100%),
  ),
)

#title-slide(logo-inset: 5mm)[]

= Example Section Title

== Example Slide

A slide with *important information*.

#pause

=== Highlight
This is #highlight(fill: blue)[highlighted in blue]. This is #highlight(fill: yellow)[highlighted in yellow]. This is #highlight(fill: green)[highlighted in green]. This is #highlight(fill: red)[highlighted in red].

#hero(
  image("cat1.jpg", height: 70%),
  title: "Hero",
  subtitle: "Subtitle",
  hide-footer: false,
)

#hero(
  image("cat1.jpg", height: 100%),
  txt: "This is an " + highlight(fill: yellow-light)[RTL#footnote[RTL = right to left. Oh, and here's a footnote!] hero with text and no title] + ".\n" + lorem(40),
  enhanced-text: false,
  rows: (80%),
  direction: "rtl",
  gap: 1em,
  hide-footer: false,
)

#hero(
  image("cat1.jpg", height: 100%),
  txt: "This is an " + highlight(fill: yellow-light)[up-to-down hero with text and no title] + ".\n" + lorem(40),
  direction: "utd",
  enhanced-text: false,
  hide-footer: false,
  gap: 1em,
)

#gallery(
  image("cat1.jpg", height: 55%),
  image("cat2.jpg", height: 55%),
  image("cat1.jpg", height: 55%),
  image("cat2.jpg", height: 55%),
  title: "Gallery",
  captions: (
    "Cat 1",
    "Cat 2",
    "Cat 1 again",
    "Cat 2 again",
  ),
  columns: 4,
)

#focus-slide(
  theme: "smoke",
  [
    This is a focus slide \ with theme "smoke"
  ],
)

#slide[
  This is a normal slide with *admonitions*:

  #brainstorming[
    This is a brainstorming (in French).
  ]

  #definition[
    This is a definition (in French).
  ]
]

#focus-slide(
  theme: "neon",
  [
    This is a focus slide \ with theme "neon"
  ],
)

#focus-slide(
  theme: "yellow",
  [
    This is a focus slide \ with theme "yellow"
  ],
)

#focus-slide(
  c1: black,
  c2: white,
  [
    This is a focus slide \ with custom colors
    \ Next: Section 2
  ],
  text-color: yellow-light,
)

= Section 2

== Hey! New Section!

#lorem(30)

=== Heading 3

#lorem(10)

==== Heading 4

#lorem(99)

#quote(attribution: [from the Henry Cary literal translation of 1897])[
  ... I seem, then, in just this little thing to be wiser than this man at
  any rate, that what I do not know I do not think I know either.
]

#slide[
  First column. #lorem(15)
][
  Second column. #lorem(15)
]