#import "../setup/macros.typ": *
= Problem Analysis

It is easy to test a layout by providing blind text...

#lorem(30)


== Basic Syntax

A lot of the syntax is inspired by the Markdown syntax, like *bold* and _emphasised_ text.
The same goes with lists:

- Item 1
- Item 2
  - A sub-item

And enumerations:

1. Ordered item using a specified number
5. Another ordered item using a specified number
+ Ordered item using the previous number + 1

And even a terms list (like `description` in LaTeX):

/ Term: Description

This text is a new paragraph and is not attached to the term.

/ Another term: #[
  It is possible to have multiple paragraphs on the right-hand side of a paragraph though.

  Just nest it in a content block using the `#[]` notation.
]

The documentation also has a #link("https://typst.app/docs/guides/guide-for-latex-users/")[guide for LaTeX users].

== Citing

The citation style is determined by the ```typ bibliography()``` command in `main.typ`
#footnote[https://typst.app/docs/reference/model/bibliography/].

Citing works the same as referencing, by using `@`. @einstein
It's also possible to add a supplement to the source using ```typ @source[supplement]``` notation.
@einstein[pp.~10]

We can also change the citation style using the ```typ #cite()``` command:

... This has been shown by #cite(form: "prose", <einstein>).


== Math

The math syntax is fundamentally different from its LaTeX counterpart.
We can make inline math $a^2 + b^2 = c^2$.

And blocked equations by adding spaces in the `$` notation, as seen in @eq:quad-polym-roots.
$ x = (-b plus.minus sqrt(b^2 − 4 a c)) / (2 dot a)  $ <eq:quad-polym-roots>


== Figures & Labels <sec:figures>

Unlike LaTeX, Typst does not have floats.
All figures are placed immediately, or at the top or bottom of the page.
The default is immediately, but can be changed with `placement: auto` (or specifically `top` or `bottom`)

Labels for figures and headings are denoted by the ```typ <i-am-a-label>``` syntax, and referenced with ```typ @i-am-a-label```

In @sec:figures we show how figures work, specifically @tab:example.

#figure(
  table(
    columns: 2,
    stroke: none,
    [*Name*], [*Age*],
    table.hline(),
    [Alice], [25],
    [Bob], [28],
    [Chad], [24]
  ),
  caption: [I am placed is put in the document, and may cause bad page breaks.]
) <tab:example>

Include an image by using `image("../figures/your-image.png")` in place of the `table()` function.
Typst will automatically infer the type of figure, and reference it accordingly.


=== Subfigures

Write subfigures using ```typ #subfig()```, which uses the `subpar` package internally (see `setup/macros.typ`).

These can be individually referenced as @a, @b and @full.

#subfig(
  figure(
    // normally, you would put `image("../figures/image.png")` here
    [_First image goes here_],
    caption: [
      The subcaption
    ]
  ), <a>,

  figure(
    [_Second image goes here_],
    caption: [
      The second subcaption
    ]
  ), <b>,

  columns: (1fr, 1fr),
  caption: [A figure composed of two sub figures.],
  label: <full>,
)
