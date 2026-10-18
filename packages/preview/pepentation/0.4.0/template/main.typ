#import "@preview/pepentation:0.4.0": *

#show: setup-presentation.with(
  title-slide: (
    enable: true,
    title: "Long version of the title",
    authors: ("LastName1 FirstName1", "LastName2 FirstName2"),
    institute: "University of SWAG",
  ),
  footer: (
    enable: true,
    title: "Title",
    institute: "USWAG",
    authors: ("Author1", "Author2", "Author3"),
  ),
  table-of-contents: "detailed",
  header: true,
  locale: "EN"
)

= Section Name

== Slide Title

This is a slide with a title

#lorem(100)

// A slide without a title is omitted from the table of contents.
==

This is slide with no title

#lorem(100)

#section-slide(title: "Math", subtitle: "Simple example of math presentation")

== Greatest common divisor

#text(size: 0.95em)[
  #definition[
    *Definition – Euclid's algorithm*

    The function `gcd(a, b)` returns the greatest common divisor of two integers.
  ]

  #warning[
    *Warning – undefined case*

    `gcd(a, 0)` is fine, but `gcd(0, 0)` is mathematically undefined.
    Your implementation should reject or handle this explicitly
  ]

  #remark[
    *Remark – symmetry property*

    `gcd(a, b)` should always equal `gcd(b, a)`. You can use this to test
    your implementation
  ]

  #hint[
    *Hint – simplifying fractions with gcd*

    Once `gcd(a,b)` works, you can reduce fractions to lowest terms
  ]
]

#section-slide(title: "Cards", subtitle: "Laying a slide out in pieces")

== A row of cards

Cards are short panels with an accent bar down one side. `#card-grid` lays them
out like `#grid` does, and gives every card in a row the height of the tallest
one, so the row lines up along its bottom edge.

#card-grid(
  columns: 3,
  ("Ownership", [every value has exactly one owner]),
  ("Borrowing", [many readers, or one writer]),
  ("Lifetimes", [a reference cannot outlive its subject]),
)

== Numbering, and a bar on each side

`numbered: true` numbers the cards in reading order. `edge` takes an array the
way `#grid`'s own `fill` and `align` do, cycled over the cells — so a row can
differ in where its bar sits.

#card-grid(
  columns: 4,
  edge: (left, top, top, right),
  numbered: true,
  ("Algorithm", [euclid, with two subtractions]),
  ("Implementation", [the subtractions are one call]),
  ("Correctness", [the first divisor that divides both is the answer]),
  ("Complexity", [O(log min(a, b)) steps]),
)

A cell written as a dictionary sets its own options; everything else inherits
the grid's.

#card-grid(
  columns: 2,
  edge: top,
  (title: [Takes a bar on the left], body: [this cell names its own `edge`], edge: left),
  ([Inherits `top`], [this cell takes the bar from the grid]),
)

== Spans, skips and placement

A dictionary cell can span columns or rows, `none` leaves one slot empty, and
a cell can name its own column and row, exactly the way `grid.cell` does.
`numbered` and an `edge` array see only the cards, so a skip costs neither a
number nor a bar.

#card-grid(
  columns: 3,
  numbered: true,
  ("Ownership", [one owner per value]),
  (: title: [Lifetimes], body: [spans two columns], colspan: 2),
  ("Left", [row two, first slot]),
  none,
  ("Right", [row two, third slot]),
)

#card-grid(
  columns: 3,
  edge: (left, top),
  ("Skip", [costs no number]),
  none,
  ("Between", [left again after the skip]),
)

== A single card

A card outside a grid spans the whole text measure, and `accent` takes a theme
key as well as a color.

#card(
  "Reading the library",
  [
    The header stays readable at a fixed size from slide to slide, so a long
    section name never pushes the body down. A card is for one short piece of
    that, not for a paragraph.
  ],
  accent: "blocks.info-color",
)
