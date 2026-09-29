#import "@preview/alcyone:0.1.0"

#show: alcyone.slides.with(
  title: "Alcyone",
  author: (
    "John Smith",
    (
      "Jane Doe",
      "jane@example.com",
    ),
  ),
  subtitle: "Strong Typography, Procedural backgrounds",
  date: (
    datetime(year: 2026, month: 06, day: 21),
    "[month repr:long] [day], [year]",
  ),
  outline-page: true,
  outline-page-heading: "Agenda",
  font-size: 20pt,
)

= Getting Started

== Using the theme

Everything starts with one call to ```typst #show: slides.with(..)``` at the top of your document. Pass your metadata once, then write plain markup underneath. No need to memorize custom function calls.

```typst
#show: slides.with(
  title: "My Talk",
  subtitle: "A subtitle",
  author: "Your Name",
)
```

Heading level does the layout work for you: a level-1 heading (`=`) opens a full-bleed section divider, and a level-2 heading (`==`) starts a new titled slide. Regular text flows underneath until the next heading.

== Structuring a slide

Bullets, numbers, and definitions all inherit the accent color automatically:

- Bullets for quick, unordered points
- Numbered lists for anything sequential

+ Write your outline as headings
+ Fill in content underneath each one
9. You can also manually specify numbers.

/ Section: A level-1 heading. Renders as a divider slide.
/ Slide: A level-2 heading. Renders as a titled content page.
/ Subheading: A level-3 heading. Renders as a subheading on the current page.

#quote(
  block: true,
  attribution: "the Halcyon template",
  [You can do full-slide blockquotes.],
)

== Type scale, at a glance

Every text size in the theme derives from one `font-size` and a 1.25× step, so changing one number rescales the whole deck consistently.

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, center, center),
  table.header([Role], [Multiplier], [Size at 20pt]),
  [Fine print], [× 0.64], [12.8pt],
  [Captions], [× 0.80], [16pt],
  [Body text], [× 1.00], [20pt],
  [Lead-ins], [× 1.25], [25pt],
  [Headings], [× 1.56], [31.3pt],
  [Display], [× 1.95], [39.1pt],
  [Titles], [× 2.44], [48.8pt],
)

#figure(
  $ s_n = s_0 times 1.25^n $,
  caption: [The formula behind the previous table.],
)

#figure(
  ```typst
  #figure(
    $ s_n = s_0 times 1.25^n $,
    caption: [The formula behind the previous table.],
  )
  ```,
  caption: [Figure calls are set on their own slide. \ Swap this out for your own diagrams and screenshots.],
)

== Columns

#columns(2)[
  Divide a slide into columns using the standard function calls:

  ```typst
  #columns(2)[
    Some text here.
  ]
  ```

  Insert manual column breaks with:

  ```typst
  #colbreak()
  ```

  #colbreak()

  You can insert images, figures, diagrams and the like as per normal.

  #image("image.webp")
]

== Citations

Citations are handled as per normal, e.g. @smith2020.

Insert a bibliography by calling the standard function:

```typst
#bibliography(style: "apa", "refs.bib")
```

The template will automatically format the bibliography as its own slide with a smaller font and hanging indent @doe2019.

#bibliography(style: "apa", "refs.bib")

== Lorem Ipsum

#lorem(500)

=== Subheading

#lorem(10)

