#import "@preview/elsearticle:0.4.2": *

#let abstract = lorem(100)

#show: elsearticle.with(
  title: "Title of the paper",
  authors: (
    (
      name: "A. Author",
      affiliation: "University A, City A, Country A",
      corr: "a.author@univa.edu",
      id: "a",
    ),
    (
      name: "B. Author",
      affiliation: "University B, City B, Country B",
      id: "b"
    ),
    (name: lorem(2)),
    (name: lorem(3)),
    (name: "A. Author"),
    (name: "A. Author"),
  ),
  journal: "Name of the Journal",
  abstract: abstract,
  keywords: ("keyword 1", "keyword 2"),
  format: "review",
  // line-numbering: true,
)

= Introduction

#lorem(100)

= Section 1

#lorem(50)

== Subsection 1

#lorem(10) (see @eq1) @Aut10.

$
y = a x +b
$ <eq1>
where ...

$
  x = integral_0^x d x #<eqa>\
  (u v)' = u' v + v' u #<eqb>
$ <eq2>

@eqa is a simple integral, while @eqb is the derivative of a product of two functions. These equations are grouped in @eq2.

== Features

=== Table

Below is @tab:tab1.

#let tab1 = {
  table(
  columns: 3,
  table.header(
    [*Header 1*],
    [*Header 2*],
    [*Header 3*],
  ),
  [Row 1], [12.0], [92.1],
  [Row 2], [16.6], [104],
)
}

#figure(
    tab1,
    kind: table,
    caption : [Example]
) <tab:tab1>

=== Figures

Below is @fig:logo.

#figure(
  image("images/typst-logo.svg", width: 50%),
  caption : [Typst logo - Credit: \@fenjalien]
) <fig:logo>

=== Subfigures

Below are @figa and @figb, which are part of @fig:typst.

#subfigure(
figure(image("images/typst-logo.svg"), caption: []), <figa>,
figure(image("images/typst-logo.svg"), caption: []), <figb>,
columns: (1fr, 1fr),
caption: [(a) Left image and (b) Right image],
label: <fig:typst>,
)

#show: appendix

= Appendix A

== Figures

In @fig:app

#figure(
  image("images/typst-logo.svg", width: 50%),
  caption : [Books cover]
) <fig:app>

== Subfigures

Below are @figa-app and @figb-app, which are part of @fig:typst-app.

#subfigure(
figure(image("images/typst-logo.svg"), caption: []), <figa-app>,
figure(image("images/typst-logo.svg"), caption: []), <figb-app>,
columns: (1fr, 1fr),
caption: [(a) Left image and (b) Right image],
label: <fig:typst-app>,
)

== Tables

In @tab:app

#figure(
    tab1,
    kind: table,
    caption : [Example]
) <tab:app>

== Equations

In @eq

$
y = f(x)
$ <eq>

#nonumeq[$
    y = g(x)
    $
]

$
y = f(x) \
y = g(x)
$

#bibliography("refs.bib")
