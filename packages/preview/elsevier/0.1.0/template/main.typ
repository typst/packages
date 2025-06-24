#import "@preview/elsevier:0.1.0": *

#show: elsevier.with(
  journal: newast,
  paper-type: none,
  title: [Foundations of geometric thought: From practical measurement to mathematical harmony],
  keywords: (
    "Elsevier",
    "Typst",
    "Template",
  ),
  authors: (
    (name: [S. Pythagoras], institutions: ("a",), corresponding: true, orcid: "0000-0001-2345-6789", email:"s.pythagoras@croton.edu"),
    (name: [M. Thales], institutions: ("b", )),
  ),
  institutions: (
    "a": [School of Pythagoreans, Croton, Magna Graecia],
    "b": [Milesian School of Natural Philosophy, Miletus, Ionia],
  ),
  abstract: lorem(100),
  paper-info: (
    year: [510 BCE],
    paper-id: [123456],
    volume: [1],
    issn: [1234-5678],
    received: [01 June 510 BCE],
    revised: [01 July 510 BCE],
    accepted: [01 August 510 BCE],
    online: [01 September 510 BCE],
    doi: "https://doi.org/10.1016/j.aam.510bce.101010",
    open: cc-by,
    extra-info: [Communicated by C. Eratosthenes],
  )
)

= Introduction
#lorem(100)

#lorem(150) (see Eq.~@eq1).

$
c^2 = a^2 + b^2
$ <eq1>
where ...

$
  x = integral_0^x d x #<eqa>\
  (u v)' = u' v + v' u #<eqb>
$ <eq2>

Eq.~@eqa is a simple integral, while Eq.~@eqb is the derivative of a product of two functions. These equations are grouped in Eq.~@eq2.

#lorem(50)

== Section
#lorem(50) @Tha600 @Pyt530 @Pyt520.

=== Subsection
#lorem(50)

= Tables

Below is Table~@tab:tab1.

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

= Figures

== Simple figure

Below is Fig.~@fig:logo.

#figure(
  image("images/typst-logo.svg", width: 50%),
  caption : [Typst logo - Credit: \@fenjalien]
) <fig:logo>

== Subfigures

=== Subfigures

Below are Figs.~@figa and~@figb, which are part of Fig.~@fig:typst.

#subfigure(
figure(image("images/typst-logo.svg"), caption: []), <figa>,
figure(image("images/typst-logo.svg"), caption: []), <figb>,
columns: (1fr, 1fr),
caption: [(a) Left image and (b) Right image],
label: <fig:typst>,
)

#show: appendix

= Appendix A

#lorem(50) (see Eq.~@eq:app-eq1 and Fig.~@fig:logo-app).

$
  y = x^2
$ <eq:app-eq1>

#figure(
  image("images/typst-logo.svg", width: 50%),
  caption : [Typst logo - Credit: \@fenjalien]
) <fig:logo-app>

#bibliography("refs.bib")