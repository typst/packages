#import "@local/pepentation:0.2.0": *

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
    authors: ("Author1", "Author2"),
  ),
  table-of-contents: "detailed",
  header: true,
  locale: "EN"
)

= Section Name

== Slide Title

This is a slide with a title

#lorem(100)

//If no title is provided it will not be shown in table of content
==

This is slide with no title

#lorem(100)

= Math

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
